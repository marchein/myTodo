//
//  FixedUITextField.swift
//  myTodo
//
//  Created by Marc Hein on 11.11.18.
//  Copyright © 2018 Marc Hein Webdesign. All rights reserved.
//

import Foundation
import UIKit

class FixedUITextField: UITextField {   
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return false
    }
}
