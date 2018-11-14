//
//  AppIconCollectionViewController.swift
//  myTodo
//
//  Created by Marc Hein on 13.11.18.
//  Copyright © 2018 Marc Hein Webdesign. All rights reserved.
//

import UIKit

private let reuseIdentifier = "appIcons"

class AppIconCollectionViewController: UICollectionViewController {
    var appIcons: [String?]?

    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 11.0, *) {
            collectionView?.contentInsetAdjustmentBehavior = .always
        }
    }
    
    // MARK:- Image functions
    
    fileprivate func getImageFor(value: String?) -> UIImage? {
        if let imageName = value {
            return UIImage(named: imageName)
        } else {
            return Bundle.main.icon
        }
    }
    
    func changeIcon(to name: String?) {
        guard UIApplication.shared.supportsAlternateIcons else {
            return;
        }
        UIApplication.shared.setAlternateIconName(name) { (error) in
            if let error = error {
                fatalError(error.localizedDescription)
            }
        }
    }
    
    func setSelectedImage(key: String?, cell: UICollectionViewCell?) {
        let currentAppIcon = UserDefaults.standard.string(forKey: "currentIcon")
        cell?.backgroundColor = key ?? "default" == currentAppIcon ? UIColor.darkGray : UIColor.lightGray
    }
    
    // MARK:- UICollectionViewDataSource
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let appIcons = appIcons else {
            fatalError()
        }
        return appIcons.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let appIcons = appIcons else {
            fatalError()
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! AppIconCollectionViewCell
        let imageOfCurrentCell = appIcons[indexPath.row]
        setSelectedImage(key: imageOfCurrentCell, cell: cell)
        cell.icon.image = getImageFor(value: imageOfCurrentCell)
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let appIcons = appIcons else {
            fatalError()
        }
        let selectedIcon = appIcons[indexPath.row]
        DispatchQueue.main.async(execute: { () -> Void in
            UserDefaults.standard.set(selectedIcon ?? "default", forKey: "currentIcon")
            self.setSelectedImage(key: selectedIcon, cell: collectionView.cellForItem(at: indexPath))
            self.collectionView.reloadData()
        })
        changeIcon(to: selectedIcon)
    }
}

extension Bundle {
    public var icon: UIImage? {
        if let icons = infoDictionary?["CFBundleIcons"] as? [String: Any],
            let primaryIcon = icons["CFBundlePrimaryIcon"] as? [String: Any],
            let iconFiles = primaryIcon["CFBundleIconFiles"] as? [String],
            let lastIcon = iconFiles.last {
            return UIImage(named: lastIcon)
        }
        return nil
    }
}
