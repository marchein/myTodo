//
//  EmptyListViewController.swift
//  myTodo
//
//  Created by Marc Hein on 19.11.18.
//  Copyright © 2018 Marc Hein Webdesign. All rights reserved.
//

import UIKit

class EmptyListViewController: UIViewController {

    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var message: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
    
    fileprivate func setupView() {
        setupToolbar()
        image.image = Bundle.main.icon
    }
    
    fileprivate func setupToolbar() {
        let toolBar = UIToolbar()
        view.addSubview(toolBar)
        
        toolBar.translatesAutoresizingMaskIntoConstraints = false
        
        let toolBarGuide = self.view.safeAreaLayoutGuide
        toolBar.trailingAnchor.constraint(equalTo: toolBarGuide.trailingAnchor).isActive = true
        toolBar.leadingAnchor.constraint(equalTo: toolBarGuide.leadingAnchor).isActive = true
        toolBar.bottomAnchor.constraint(equalTo: toolBarGuide.bottomAnchor).isActive = true
    }
}
