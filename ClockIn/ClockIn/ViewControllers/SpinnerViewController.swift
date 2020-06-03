//
//  SpinnerViewController.swift
//  ClockIn
//
//  Created by Luke Jansen on 01/03/2020.
//  Copyright © 2020 Luke Jansen. All rights reserved.
//

import UIKit

class SpinnerViewController: UIViewController {
    
    var spinner = UIActivityIndicatorView(style: .large)

    override func loadView() {
        view = UIView()
        view.backgroundColor = UIColor(white: 0, alpha: 0.9)
        
        spinner.color = UIColor(white:1, alpha:1)

        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.startAnimating()
        view.addSubview(spinner)

        spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
        spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 0).isActive = true
    }
}
