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
    @IBOutlet weak var label: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        let toolBar = UIToolbar()
        view.addSubview(toolBar)
        
        toolBar.translatesAutoresizingMaskIntoConstraints = false

        let toolBarGuide = self.view.safeAreaLayoutGuide
        toolBar.trailingAnchor.constraint(equalTo: toolBarGuide.trailingAnchor).isActive = true
        toolBar.leadingAnchor.constraint(equalTo: toolBarGuide.leadingAnchor).isActive = true
        toolBar.bottomAnchor.constraint(equalTo: toolBarGuide.bottomAnchor).isActive = true

        image.image = Bundle.main.icon
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
