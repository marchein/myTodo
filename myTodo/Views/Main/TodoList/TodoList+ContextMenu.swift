//
//  TodoList+ContextMenu.swift
//  myTodo
//
//  Created by Marc Hein on 27.09.19.
//  Copyright © 2019 Marc Hein Webdesign. All rights reserved.
//

import Foundation
import UIKit

@available(iOS 13.0, *)
extension TodoListTableViewController: UIContextMenuInteractionDelegate {
   
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        if let indexPath = self.tableView.indexPathForRow(at: location) {
        let todoFromCoreData = self.fetchedResultsController.object(at: indexPath)
            self.selectedIndexPath = indexPath
            self.selectedTodo = todoFromCoreData
            return createContextMenu(todo: todoFromCoreData, indexPath: indexPath)
        }
        return nil
    }
    
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
        animator.addCompletion {
            if let splitVC = self.splitViewController, splitVC.viewControllers.count == 2 {
                let detailNavVC = self.getDetailViewController()
                detailNavVC.setNavigationBarHidden(false, animated: false)
                detailNavVC.setToolbarHidden(false, animated: false)
                let detailVC = splitVC.viewControllers[1]
                detailVC.show(detailNavVC, sender: detailVC)
            } else {
                let detailNavVC = self.getDetailViewController()
                detailNavVC.setNavigationBarHidden(false, animated: false)
                detailNavVC.setToolbarHidden(false, animated: false)
                self.show(detailNavVC, sender: self)
            }
        }

    }
    
    func getDetailViewController() -> UINavigationController {
        let storyBoard = UIStoryboard(name: "Detail", bundle: nil)
        if let detailNavVC = storyBoard.instantiateViewController(withIdentifier: "DetailViewController") as? UINavigationController,
           let detailVC = detailNavVC.viewControllers[0] as? TodoDetailTableViewController {
            detailVC.todo = selectedTodo
            detailVC.indexPath = selectedIndexPath
            detailVC.todoListTableVC = self
            detailVC.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
            detailVC.navigationItem.leftItemsSupplementBackButton = true
            detailNavVC.setNavigationBarHidden(true, animated: false)
            detailNavVC.setToolbarHidden(true, animated: false)

            detailVC.isPeeking = true
            
            return detailNavVC
        }
        return UINavigationController()
    }
        
    private func createContextMenu(todo: Todo, indexPath: IndexPath) -> UIContextMenuConfiguration {
        let actionProvider: UIContextMenuActionProvider = { _ in
            let share = UIAction(title: NSLocalizedString("share", comment: ""), image: UIImage(systemName: "square.and.arrow.up")) { action in
                if let shareSheet = getShareSheet(for: todo) {
                    if let popoverController = shareSheet.popoverPresentationController {
                        popoverController.sourceRect = self.tableView.bounds
                        popoverController.sourceView = self.tableView
                        popoverController.permittedArrowDirections = .left
                    }
                    self.present(shareSheet, animated: true, completion: nil)
                }
            }
            // Here we specify the "destructive" attribute to show that it’s destructive in nature
            let delete = UIAction(title: NSLocalizedString("delete", comment: ""), image: UIImage(systemName: "trash"), attributes: .destructive) { action in
                self.tableView(self.tableView, commit: .delete, forRowAt: indexPath)
                self.notification.notificationOccurred(.warning)
            }
            return UIMenu(title: "", children: [share, delete])
        }

        return UIContextMenuConfiguration(identifier: nil, previewProvider: {
            return self.getDetailViewController()
        }, actionProvider: actionProvider)
    }


}
