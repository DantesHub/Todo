//
//  LCSearchDelegate.swift
//  Todo
//
//  Created by Dante Kim on 1/19/21.
//  Copyright © 2021 Alarm & Calm. All rights reserved.
//

import UIKit

extension ListController: UISearchBarDelegate {
    func filterContentForSearchText(_ searchText: String) {
        if searchText == "" {
            filteredTasks = []
        } else {
            filteredTasks = (tasksList + completedTasks).filter { (task: TaskObject) -> Bool in
              return (task.name.lowercased().contains(searchText.lowercased()))
            }
        }
    
//     filteredCompletedTasks = completedTasks.filter { (task: TaskObject) -> Bool in
//        return (task.name.lowercased().contains(searchText.lowercased()))
//      }
        tableView.reloadData()
    }
    

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
       filterContentForSearchText(searchBar.text!)
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterContentForSearchText(searchBar.text!)
        tableView.reloadData()
    }
}
