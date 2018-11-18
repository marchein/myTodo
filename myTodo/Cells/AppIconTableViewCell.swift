//
//  AppIconTableViewCell.swift
//  myTodo
//
//  Created by Marc Hein on 15.11.18.
//  Copyright © 2018 Marc Hein Webdesign. All rights reserved.
//

import UIKit

class AppIconTableViewCell: UITableViewCell {

    @IBOutlet weak var appIcon: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        let maskImage = UIImage(named: "app_mask")!
        let maskView = UIImageView(image: maskImage)
        appIcon.mask = maskView
        maskView.frame = appIcon.bounds
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setTitle(title: String?) {
        titleLabel.text = title
    }

}
