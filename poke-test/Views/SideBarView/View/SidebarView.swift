//
//  SidebarView.swift
//  poke-test
//
//  Created by Samantha Cruz on 12/10/23.
//

import UIKit

public protocol SidebarViewDelegate: AnyObject {
    func sidebarView(didSelectItemAt type: MenuOption)
}

public final class SidebarView: NSObject {
    
    private enum Section: Int, CaseIterable {
        case main
    }
    
    private typealias DataSource = UICollectionViewDiffableDataSource<Section, Option>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Option>
    
    // MARK: - Variables and Delegate
    
    private let viewModel = SideMenuViewModel()
    private let isDisplayedLeadingConstant: CGFloat = 0
    weak var applicationScreenWindow: UIWindow?
    private weak var delegate: SidebarViewDelegate?
    private var backgroundBlurEffectView: UIVisualEffectView?
    private var sidebarViewOrigin: CGPoint = .zero
    private var sidebarContainerViewLeadingAnchor: NSLayoutConstraint?
    private var sidebarContainerViewWidthAnchor: NSLayoutConstraint?
    public private(set) var sidebarViewIsShowing: Bool = false
    public var dismissesOnSelection: Bool = true
    public var shouldPushRootControllerOnDisplay: Bool = false
    
    public var allowsPullToDisplay: Bool = false {
        didSet {
            if allowsPullToDisplay && applicationScreenWindow?.gestureRecognizers?.contains(panGesture) == true {
                applicationScreenWindow?.visibleViewController()?.view.addGestureRecognizer(panGesture)
            } else if !allowsPullToDisplay {
                applicationScreenWindow?.visibleViewController()?.view.removeGestureRecognizer(panGesture)
            }
        }
    }
    
    public var dimmedBackgroundColor: UIColor = .white.withAlphaComponent(0.5) {
        didSet {
            self.backgroundBlurView.backgroundColor = dimmedBackgroundColor
        }
    }
    
    public var sidebarCornerRadius: CGFloat = 0 {
        didSet {
            self.sidebarContainerView.prepareToRound(corners: [.topRight, .bottomRight], withRadius: sidebarCornerRadius)
        }
    }
    
    public var blurBackgroundEffect: UIBlurEffect? {
        didSet {
            self.initializeBackgroundBlurView(withBlurEffect: blurBackgroundEffect)
        }
    }
    
    public var sidebarBackgroundColor: UIColor = .white {
        didSet {
            collectionView.backgroundColor = sidebarBackgroundColor
        }
    }
    
    public var sidebarViewScreenPercentageWidth: CGFloat = 0.75 {
        didSet {
            guard
                sidebarViewScreenPercentageWidth > 0 &&
                    sidebarViewScreenPercentageWidth <= 1.0
            else {
                fatalError("The width of the SidebarView as a percentage must not be 0 and must be less than or equal to 1")
            }
            sidebarContainerViewWidthAnchor?.constant = sidebarViewWidthConstant
            containerView.layoutIfNeeded()
            collectionView.collectionViewLayout.invalidateLayout()
        }
    }
    
    private var deviceScreenWidth: CGFloat {
        return UIScreen.main.bounds.width
    }
    
    private var sidebarViewWidthConstant: CGFloat {
        let sidebarViewWidth: CGFloat = deviceScreenWidth * self.sidebarViewScreenPercentageWidth
        return sidebarViewWidth
    }
    
    private var isDismissedLeadingConstant: CGFloat {
        return -sidebarViewWidthConstant
    }
    
    private lazy var panGesture: UIPanGestureRecognizer = {
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(panGesture:)))
        gesture.delegate = self
        return gesture
    }()
    
    private let registerCell = UICollectionView.CellRegistration<UICollectionViewListCell, Option> { cell, indexPath, option in
        var configuration = cell.defaultContentConfiguration()
        configuration.text = option.name
        configuration.image = UIImage(systemName: option.icon)
        configuration.imageProperties.tintColor = .label
        cell.contentConfiguration = configuration
        
        cell.accessories = [.disclosureIndicator(displayed: .always)]
    }
    
    private lazy var dataSource: DataSource = {
        let dataSource = DataSource(collectionView: collectionView) { collectionView, indexPath, item -> UICollectionViewCell in
            collectionView.dequeueConfiguredReusableCell(using: self.registerCell, for: indexPath, item: item)
        }
        return dataSource
    }()
    
    public private(set) lazy var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()
    
    public private(set) lazy var backgroundBlurView: UIView = {
        var frame: CGRect = CGRect.zero
        let view = UIView(frame: CGRect.zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = dimmedBackgroundColor
        view.isUserInteractionEnabled = true
        view.alpha = 0.0
        return view
    }()
    
    private var sidebarContainerView: SidebarViewContainer = {
        let view = SidebarViewContainer()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        return view
    }()
    
    private lazy var collectionView: SidebarCollectionView = {
        let collectionView = SidebarCollectionView()
        collectionView.backgroundColor = sidebarBackgroundColor
        collectionView.delegate = self
        return collectionView
    }()
    
    // MARK: - Initializers
    
    public init(delegate: SidebarViewDelegate?) {
        super.init()
        self.delegate = delegate
        setupUIElementsWithKeyWindow()
    }
    
    // MARK: - Functions
    
    private func setupUIElementsWithKeyWindow() {
        guard let window = UIApplication.shared.keyWindow else {
            fatalError("No available keyWindow")
        }
        
        applicationScreenWindow = window
        let dismissTapGesture = UITapGestureRecognizer(target: self, action: #selector(performDismissFromBackground(tapGesture:)))
        backgroundBlurView.addGestureRecognizer(dismissTapGesture)
        
        window.addSubview(containerView)
        containerView.addSubview(backgroundBlurView)
        containerView.addSubview(sidebarContainerView)
        
        sidebarContainerView.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: window.leadingAnchor),
            containerView.topAnchor.constraint(equalTo: window.topAnchor),
            containerView.trailingAnchor.constraint(equalTo: window.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: window.bottomAnchor),
            
            backgroundBlurView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            backgroundBlurView.topAnchor.constraint(equalTo: containerView.topAnchor),
            backgroundBlurView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            backgroundBlurView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            
            sidebarContainerView.topAnchor.constraint(equalTo: containerView.topAnchor),
            sidebarContainerView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            
            collectionView.leadingAnchor.constraint(equalTo: sidebarContainerView.leadingAnchor),
            collectionView.topAnchor.constraint(equalTo: sidebarContainerView.topAnchor),
            collectionView.trailingAnchor.constraint(equalTo: sidebarContainerView.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: sidebarContainerView.bottomAnchor)
        ])
        
        sidebarContainerViewLeadingAnchor = sidebarContainerView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: isDismissedLeadingConstant)
        sidebarContainerViewLeadingAnchor?.isActive = true
        
        sidebarContainerViewWidthAnchor = sidebarContainerView.widthAnchor.constraint(equalToConstant: sidebarViewWidthConstant)
        sidebarContainerViewWidthAnchor?.isActive = true
        
        applySnapshot()
    }
    
    private func initializeBackgroundBlurView(withBlurEffect blurEffect: UIBlurEffect?) {
        if blurEffect != nil {
            if backgroundBlurEffectView != nil {
                backgroundBlurEffectView?.removeFromSuperview()
                backgroundBlurEffectView = nil
            }
            backgroundBlurEffectView = UIVisualEffectView(effect: blurEffect)
            backgroundBlurEffectView?.translatesAutoresizingMaskIntoConstraints = false
            backgroundBlurView.addSubview(backgroundBlurEffectView!)
            backgroundBlurView.backgroundColor = .clear
            
            if backgroundBlurView.frame != .zero {
                backgroundBlurView.layoutIfNeeded()
            }
            
            backgroundBlurEffectView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            if let backgroundBlurEffectView = backgroundBlurEffectView {
                NSLayoutConstraint.activate([
                    backgroundBlurEffectView.leadingAnchor.constraint(equalTo: backgroundBlurView.leadingAnchor),
                    backgroundBlurEffectView.topAnchor.constraint(equalTo: backgroundBlurView.topAnchor),
                    backgroundBlurEffectView.trailingAnchor.constraint(equalTo: backgroundBlurView.trailingAnchor),
                    backgroundBlurEffectView.bottomAnchor.constraint(equalTo: backgroundBlurView.bottomAnchor)
                ])
            }
        }
    }
    
    private func applySnapshot() {
        var snapshot = Snapshot()
        snapshot.appendSections(Section.allCases)
        Section.allCases.forEach { snapshot.appendItems(viewModel.menuOptions, toSection: $0) }
        dataSource.apply(snapshot)
    }
}

// MARK: - Animation

extension SidebarView {
    
    @available(*, unavailable, renamed: "show")
    public func showSidebarView() {
        performAnimationForSidebarView(shouldDisplay: true, completion: nil)
    }
    
    public func show() {
        performAnimationForSidebarView(shouldDisplay: true, completion: nil)
    }
    
    @objc private func performDismissFromBackground(tapGesture: UITapGestureRecognizer) {
        dismiss()
    }
    
    @objc public func dismiss() {
        performAnimationForSidebarView(shouldDisplay: false) { [unowned self] in
            containerView.isHidden = true
        }
    }
    
    private func performAnimationForSidebarView(shouldDisplay: Bool, completion: (() -> ())?) {
        containerView.isHidden = false
        sidebarContainerViewLeadingAnchor?.constant = shouldDisplay ? isDisplayedLeadingConstant : isDismissedLeadingConstant
        
        let rootViewControllerOriginX: CGFloat = shouldDisplay ? sidebarViewWidthConstant : 0
        UIView.animate(withDuration: 0.5, delay: 0.0,
                       usingSpringWithDamping: 1.0,
                       initialSpringVelocity: 0.5,
                       options: .curveEaseInOut,
                       animations: { [weak self] in
            guard let self = self else { return }
            self.backgroundBlurView.alpha = shouldDisplay ? 1.0 : 0.0
            self.applicationScreenWindow?.layoutIfNeeded()
            
            if self.shouldPushRootControllerOnDisplay {
                self.applicationScreenWindow?.visibleViewController()?.view.frame = CGRect(x: rootViewControllerOriginX,
                                                                                           y: 0,
                                                                                           width: self.deviceScreenWidth,
                                                                                           height: UIScreen.main.bounds.height)
            }
        }, completion: { [unowned self] _ in
            sidebarViewIsShowing.toggle()
            completion?()
        })
    }
    
    @objc private func handlePanGesture(panGesture: UIPanGestureRecognizer) {
        guard !sidebarViewIsShowing else { return }
        
        let threshold: CGFloat = 0.35
        
        if let window = applicationScreenWindow, let rootView = window.visibleViewController()?.view {
            let translation = panGesture.translation(in: rootView)
            switch panGesture.state {
            case .began:
                sidebarViewOrigin = collectionView.frame.origin
            case .ended, .failed, .cancelled:
                if translation.x >= rootView.frame.width * threshold {
                    show()
                } else {
                    dismiss()
                }
            default:
                if translation.x >= rootView.frame.width * threshold {
                    show()
                } else {
                    let newOrigin: CGPoint = CGPoint(x: sidebarViewOrigin.x + (translation.x * 1.5), y: sidebarViewOrigin.y)
                    sidebarContainerViewLeadingAnchor?.constant = newOrigin.x
                    backgroundBlurView.alpha = (translation.x) / (rootView.frame.width * threshold)
                }
            }
        }
    }
}

extension SidebarView: UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let menuOption = dataSource.itemIdentifier(for: indexPath) else { return }
        delegate?.sidebarView(didSelectItemAt: menuOption.type)
        
        if dismissesOnSelection {
            dismiss()
        }
        
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}

extension SidebarView: UIGestureRecognizerDelegate {
    
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let window = applicationScreenWindow, let controllerView = window.visibleViewController()?.view else { return false }
        if let panGesture = gestureRecognizer as? UIPanGestureRecognizer {
            let velocity = panGesture.velocity(in: controllerView)
            return abs(velocity.x) > abs(velocity.y)
        }
        return true
    }
}

