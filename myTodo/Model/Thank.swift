//
//  Thank.swift
//  myTodo
//
//  Created by Marc Hein on 20.11.18.
//  Copyright © 2018 Marc Hein Webdesign. All rights reserved.
//

import Foundation
import UIKit

struct Thank {
    let name: String
    let url: String?
    
    init(name: String, url: String? = nil) {
        self.name = name
        self.url = url
    }
}
