//
//  CardContentViewController.swift
//  Cards
//
//  Created by Mark G on 9/17/19.
//

import UIKit

public protocol CardContentProvider {
    var scrollView: UIScrollView! { get set }
    var card: Card? { get set }
    
}

open class CardContentViewController: UIViewController, CardContentProvider {
    @IBOutlet public weak var scrollView: UIScrollView!
    public weak var card: Card?
    

    open override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        card?.containerVC?.scrollView = scrollView
    }
}
