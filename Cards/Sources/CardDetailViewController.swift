//
//  DetailViewController.swift
//  Cards
//
//  Created by Paolo Cuscela on 23/10/17.
//

import UIKit

open class CardDetailViewController: CardContentViewController {
    var contentView: UIView? {
        return scrollView.subviews.first?.subviews.first
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        guard let contentView = contentView else { return }
        contentView.superview!.constraints
            .first { ($0.firstItem === contentView || $0.secondItem === contentView) && $0.firstAttribute == .top }?
            .constant = card.backgroundIV.bounds.maxY
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        scrollView.addSubview(card.backgroundIV)
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        contentView?.alpha = 1
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        
        contentView?.alpha = 0
        super.viewWillDisappear(animated)
    }

}
