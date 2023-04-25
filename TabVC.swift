//
//  TabVC.swift
//  lolSports
//
//  Created by Alan Chung on 2023-04-07.
//

import UIKit

class TabVC: UITabBarController {
    
    var hideScore: Bool = true
    var followLeagues: [String] = ["LCK", "LPL", "LEC", "LCS", "MSI", "Worlds"]

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
}
