//
//  CardContainerViewController.swift
//  Cards
//
//  Created by Mark G on 9/16/19.
//

import UIKit

internal class CardContainerViewController: UIViewController {
    fileprivate var xButton = XButton()
    fileprivate var scrollPosition = CGFloat()
    fileprivate var scrollViewOriginalYPosition = CGFloat()
    
    let containerNavVC = UINavigationController()
    var blurView = UIVisualEffectView(effect: UIBlurEffect(style: .extraLight ))
    var isViewAdded = false
    var snap = UIView()
    weak var card: Card?
    weak var delegate: CardDelegate?
    
    var scrollView: UIScrollView? {
        didSet {
            guard let scrollView = scrollView else { return }
            scrollView.delegate = self
            scrollView.alwaysBounceVertical = true
            scrollView.showsVerticalScrollIndicator = false
            scrollView.showsHorizontalScrollIndicator = false
            scrollView.translatesAutoresizingMaskIntoConstraints = true
            
            if #available(iOS 11.0, *) {
                scrollView.contentInsetAdjustmentBehavior = .never
            }
            
            xButton.frame = CGRect (x: scrollView.frame.maxX - 20 - 40,
                                    y: scrollView.frame.minY + 20,
                                    width: 40,
                                    height: 40)
        }
    }
    
    var isFullscreen = false {
        didSet { scrollViewOriginalYPosition = isFullscreen ? 0 : 40 }
    }
    
    
    override var prefersStatusBarHidden: Bool {
        if isFullscreen { return true }
        else { return false }
    }
    
    
    //MARK: - Init
    convenience init(rootViewController: CardContentViewController) {
        self.init()
        containerNavVC.setViewControllers([rootViewController], animated: false)
    }
    
    //MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !isViewAdded  {
            self.setupView()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //originalFrame = scrollView.frame
        
        if isFullscreen {
            view.addSubview(xButton)
        }
        
        view.insertSubview(snap, belowSubview: blurView)
    }
    
    override func viewWillDisappear(_ animated: Bool) {

        snap.removeFromSuperview()
        xButton.removeFromSuperview()
        super.viewWillDisappear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
}

extension CardContainerViewController {
    func setupView() {
        
        // Make navigation bar transparent
        containerNavVC.navigationBar.setBackgroundImage(UIImage(), for: .default)
        containerNavVC.navigationBar.shadowImage = UIImage()
        containerNavVC.navigationBar.isTranslucent = true
        containerNavVC.view.backgroundColor = .clear
        containerNavVC.view.clipsToBounds = true
        containerNavVC.view.layer.cornerRadius = isFullscreen ? 0 :  20
        containerNavVC.edgesForExtendedLayout = []
        
        self.snap = UIScreen.main.snapshotView(afterScreenUpdates: true)
        self.view.addSubview(blurView)
        
        // Add navigation to front
        self.view.addSubview(containerNavVC.view)
        addChild(containerNavVC)
        self.view.bringSubviewToFront(containerNavVC.view)
        
        blurView.frame = self.view.bounds
        
        
        xButton.addTarget(self, action: #selector(dismissVC), for: .touchUpInside)
        blurView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissVC)))
        xButton.isUserInteractionEnabled = true
        view.isUserInteractionEnabled = true
        
        isViewAdded = true
    }
    
    //MARK: - Layout & Animations for the content ( rect = Scrollview + card + detail )
    func layout(_ rect: CGRect, isPresenting: Bool, isAnimating: Bool = true, transform: CGAffineTransform = CGAffineTransform.identity){
        
        guard let card = card else { return }
        card.log("DetailVC>> Will layout to: ---> \(rect)")
        
        let view = containerNavVC.view!
        
        // Layout for dismiss
        guard isPresenting else {
            
            view.frame = rect.applying(transform)
            scrollView?.frame = view.bounds
            view.layer.cornerRadius = card.cardRadius
            card.backgroundIV.frame = scrollView?.bounds ?? card.backgroundIV.frame
            card.layout(animating: isAnimating)
            return
        }
        
        // Layout for present in fullscreen
        if isFullscreen {
            
            view.layer.cornerRadius = 0
            view.frame = view.bounds
            view.frame.origin.y = 0
            scrollView?.frame = view.bounds
            card.backgroundIV.layer.cornerRadius = 0
            
            // Layout for present in non-fullscreen
        } else {
            view.frame.size = CGSize(width: LayoutHelper.XScreen(90), height: LayoutHelper.YScreen(100) - 20)
            view.center = blurView.center
            view.frame.origin.y = 40
        }
        
        view.frame = view.frame.applying(transform)
        
        scrollView?.frame = view.bounds
        card.backgroundIV.frame.origin = view.bounds.origin
        card.backgroundIV.frame.size = CGSize( width: view.bounds.width,
                                               height: card.backgroundIV.bounds.height)
        
        card.layout(animating: isAnimating)
        
    }
    
    //MARK: - Actions
    @objc func dismissVC(){
        scrollView?.contentOffset.y = 0
        containerNavVC.popToRootViewController(animated: false)
        dismiss(animated: true, completion: nil)
    }
}

//MARK: - Navigation
extension CardContainerViewController {
    func pushViewController(_ viewController: CardContentViewController, animated: Bool) {
        containerNavVC.pushViewController(viewController, animated: animated)
    }
    
    func popViewController(animated: Bool) {
        containerNavVC.popViewController(animated: animated)
    }
    
    func popToRootViewController(animated: Bool) {
        containerNavVC.popToRootViewController(animated: animated)
    }
}

//MARK: - ScrollView Behaviour

extension CardContainerViewController: UIScrollViewDelegate {
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let y = scrollView.contentOffset.y
        let offset = scrollView.frame.origin.y - scrollViewOriginalYPosition
        
        // Behavior when scroll view is pulled down
        if (y<0) {
            containerNavVC.view.frame.origin.y -= y/2
            scrollView.contentOffset.y = 0
            
            // Behavior when scroll view is pulled down and then up
        } else if ( offset > 0) {
            
            scrollView.contentOffset.y = 0
            containerNavVC.view.frame.origin.y -= y/2
        }
    }
    
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        let offset = containerNavVC.view.frame.origin.y - scrollViewOriginalYPosition
        
        // Pull down speed calculations
        let max = 4.0
        let min = 2.0
        var speed = Double(-velocity.y)
        if speed > max { speed = max }
        if speed < min { speed = min }
        speed = (max/speed*min)/10
        
        guard offset < 60 else { dismissVC(); return }
        guard offset > 0 else { return }
        
        // Come back after pull animation
        UIView.animate(withDuration: speed, animations: {
            self.containerNavVC.view.frame.origin.y = self.scrollViewOriginalYPosition
            self.scrollView?.contentOffset.y = 0
        })
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        let offset = scrollView.frame.origin.y - scrollViewOriginalYPosition
        guard offset > 0 else { return }
        
        // Come back after pull animation
        UIView.animate(withDuration: 0.1, animations: {
            scrollView.frame.origin.y = self.scrollViewOriginalYPosition
            self.scrollView?.contentOffset.y = 0
        })
    }
    
}

class XButton: UIButton {
    
    private let circle = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    
    override var frame: CGRect {
        didSet{
            setNeedsDisplay()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(circle)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let xPath = UIBezierPath()
        let xLayer = CAShapeLayer()
        let inset = rect.width * 0.3
        
        xPath.move(to: CGPoint(x: inset, y: inset))
        xPath.addLine(to: CGPoint(x: rect.maxX - inset, y: rect.maxY - inset))
        
        xPath.move(to: CGPoint(x: rect.maxX - inset, y: inset))
        xPath.addLine(to: CGPoint(x: inset, y: rect.maxY - inset))
        
        xLayer.path = xPath.cgPath
        
        xLayer.strokeColor = UIColor.white.cgColor
        xLayer.lineWidth = 2.0
        self.layer.addSublayer(xLayer)
        
        circle.frame = rect
        circle.layer.cornerRadius = circle.bounds.width / 2
        circle.clipsToBounds = true
        circle.isUserInteractionEnabled = false
        
        
    }
    
    
}
