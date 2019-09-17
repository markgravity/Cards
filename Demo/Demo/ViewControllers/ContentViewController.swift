//
//  DetailViewController.swift
//  Demo
//
//  Created by Paolo Cuscela on 03/11/17.
//  Copyright © 2017 Paolo Cuscela. All rights reserved.
//

import UIKit
import Cards

class ContentViewController: CardDetailViewController {
    let colors = [
        
        UIColor.red,
        UIColor.yellow,
        UIColor.blue,
        UIColor.green,
        UIColor.brown,
        UIColor.purple,
        UIColor.orange
        
    ]
    
    
    @IBAction func doMagic(_ sender: Any) {
        
        let controller = storyboard?.instantiateViewController(withIdentifier: "\(ListTableViewController.self)") as! ListTableViewController
        navigationController?.pushViewController(controller, animated: true)
        
    }
    
}
