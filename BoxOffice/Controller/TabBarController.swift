//
//  TabBarViewController.swift
//  BoxOffice
//
//  Created by kwon on 2021/09/08.
//

import UIKit

class TabBarController: UITabBarController {
    
    var movies: [Movie] = []
    var orderBy: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
