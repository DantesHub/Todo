//
//  LCTableView.swift
//  Todo
//
//  Created by Dante Kim on 10/28/20.
//  Copyright © 2020 Alarm & Calm. All rights reserved.
//

import UIKit
extension ListController: UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate, UITableViewDragDelegate, UITableViewDropDelegate {
    func reloadEditList() {
        if allSelected() {
            selectAll.label.text = "Deselect All"
        } else {
            selectAll.label.text = "Select All"
        }
    }
    
    func reloadTaskTableView(at: IndexPath, checked: Bool, repeats: String = "") {
        if checked {
            let task = completedTasks.remove(at: at.row)
            if UserDefaults.standard.bool(forKey: "toTop") {
                tasksList.insert(task, at: 0)
            } else {
                tasksList.append(task)
            }
            if !searching {
                self.tableView.performBatchUpdates({
                    self.tableView.moveRow(at: at, to: IndexPath(item: UserDefaults.standard.bool(forKey: "toTop") ? 0 : tasksList.count - 1, section: 0))
                }, completion: { [self] finished in
                    self.tableView.reloadData()
                })
            }
       
        } else {
            let cell = tableView.cellForRow(at: at) as! TaskCell
            var removedTask = TaskObject()
            for (idx,task) in tasksList.enumerated() {
                if cell.id == task.id {
                    removedTask = tasksList.remove(at: idx)
                }
            }
            completedTasks.insert(removedTask, at: 0)
            if !searching {
                self.tableView.performBatchUpdates({
                    self.tableView.moveRow(at: at, to: IndexPath(item: 0, section: 1))
                }, completion: {  finished in
                    self.tableView.reloadData { [self] in
                        if repeats != "" {
                           reloadTaskTableView(at: IndexPath(row: 0, section: 1), checked: true)
    //                        self.tableView.reloadData()
                        }
                    }
                })
            }
        
        }
    }
    
    func reloadTable() {
        getRealmData()
        tableView.reloadData()
    }
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
           return true
       }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
           return true
       }
    

    func numberOfSections(in tableView: UITableView) -> Int {
        if searching {
            return 1
        } 
        return 2
    }
    
 
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searching {
            return filteredTasks.count
        } else {
            if section == 0 {
                return tasksList.count
            } else {
                if completedExpanded == true {
                    return completedTasks.count
                } else {
                    return 0
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let completedView = UITableViewHeaderFooterView(reuseIdentifier: "completedHeader")
                
        completedView.tintColor = .clear
        if section == 1 && completedTasks.count != 0 && !searching {
            let label = UIButton()
            label.titleLabel?.font = UIFont(name: "OpenSans-Regular", size: 18)
            label.titleLabel?.textColor = .white
            label.setTitle("Completed", for: .normal)
            label.setImage(UIImage(named: "arrow")?.rotate(radians: .pi)!.withTintColor(.white).resize(targetSize: CGSize(width: 18, height: 20)), for: .normal)
            label.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
            completedView.addSubview(label)
            label.top(to: completedView, offset: 10)
            label.leadingAnchor.constraint(equalTo: completedView.leadingAnchor, constant: 5).isActive = true
            label.backgroundColor = UIColor.black.withAlphaComponent(0.6)
            label.width(tableView.frame.width * 0.35)
            label.height(25)
            label.layer.cornerRadius = 10
            label.addTarget(self, action: #selector(tappedCompleted), for: .touchUpInside)
        } else if section == 0 && sortType != "" {
            if  !editingCell {
                let label = UIButton()
                label.width(min: sortType != "Priority" && sortType != "Due Date" ? 180 : 130, max: 500, priority: .defaultHigh, isActive: true)
                label.titleLabel?.font = UIFont(name: "OpenSans-Regular", size: 20)
                label.titleLabel?.textColor = .white
                label.titleLabel?.adjustsFontSizeToFitWidth = true
                label.setTitle(sortType, for: .normal)
                if !reversed {
                    label.setImage(UIImage(named: "arrow")?.withTintColor(.white).resize(targetSize: CGSize(width: 20, height: 22)), for: .normal)
                } else {
                    label.setImage(UIImage(named: "arrow")?.withTintColor(.white).resize(targetSize: CGSize(width: 20, height: 22)).rotate(radians: .pi), for: .normal)
                }
                    if UIScreen.main.nativeBounds.height == 1792 {
                        if sortType == "Creation Date" || sortType == "Alphabetically" {
                            label.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 11, right: 0)
                        }
                    } else {
                        if sortType == "Creation Date" || sortType == "Alphabetically" {
                            label.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
                        }
                    }
                
                label.titleEdgeInsets = UIEdgeInsets(top: 10, left: 14, bottom: sortType != "Priority" ? 10 : 12, right: 0)

                completedView.addSubview(label)
                label.top(to: completedView, offset: 5)
                label.leadingAnchor.constraint(equalTo: completedView.leadingAnchor, constant: 5).isActive = true
                label.backgroundColor = UIColor.black.withAlphaComponent(0.6)
                //            label.width(tableView.frame.width * 0.35)
                label.height(28)
                label.layer.cornerRadius = 10
                label.addTarget(self, action: #selector(tappedReverse), for: .touchUpInside)
                
                let xButton = UIButton()
                completedView.addSubview(xButton)
                xButton.width(28)
                xButton.height(28)
                xButton.top(to: completedView, offset: 5)
                xButton.leadingAnchor.constraint(equalTo: label.trailingAnchor, constant: 5).isActive = true
                xButton.backgroundColor = UIColor.black.withAlphaComponent(0.6)
                xButton.setImage(UIImage(named: "x")?.withTintColor(.white).resize(targetSize: CGSize(width: 30, height: 30)), for: .normal)
                xButton.addTarget(self, action: #selector(tappedX), for: .touchUpInside)
                xButton.layer.cornerRadius = 10
            }
        }
        
        return completedView
    }
    @objc func tappedX(button: UIButton) {
        try! uiRealm.write {
            listObject.sortType = ""
            sortType = ""
            listObject.reversed = true
        }
        reversed = true
        formatter.dateFormat = "MMM dd,yyyy-h:mm a"
        let farDate  = formatter.date(from: "Jan 01, 2100-4:50 PM")!
        tasksList.sort { formatter.date(from: $0.createdAt) ?? farDate < formatter.date(from: $1.createdAt) ?? farDate }
        for (idx, task) in tasksList.enumerated() {
            try! uiRealm.write {
                task.position = idx
            }
        }
        tableViewTop?.constant = 105
        let range = NSMakeRange(0, self.tableView.numberOfSections)
        let sections = NSIndexSet(indexesIn: range)
        self.tableView.reloadSections(sections as IndexSet, with: .automatic)
    }
    @objc func tappedReverse(button: UIButton) {
        //depending on tag we need to reverse or not
        reversed = !reversed
        try! uiRealm.write {
            listObject.reversed = reversed
        }
        let  formatter = DateFormatter()
        formatter.dateFormat = "MMM dd,yyyy-h:mm a"
        let farDate  = formatter.date(from: "Jan 01, 2100-4:50 PM")!
        if reversed {
            switch sortType {
            case "Important":
                tasksList.sort { $0.favorited && !$1.favorited }
            case "Alphabetically":
                tasksList.sort { $0.name.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) < $1.name.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) }
            case "Priority":
                tasksList.sort { $0.priority > $1.priority }
            case "Due Date":
                tasksList.sort { formatter.date(from: $0.planned) ?? farDate < formatter.date(from: $1.planned) ?? farDate }
            case "Creation Date":
                tasksList.sort { formatter.date(from: $0.createdAt) ?? farDate > formatter.date(from: $1.createdAt) ?? farDate }
            default:
                break
            }
        } else {
            switch sortType {
            case "Important":
                tasksList.sort { !$0.favorited && $1.favorited }
            case "Alphabetically":
                tasksList.sort { $0.name.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) > $1.name.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) }
            case "Priority":
                tasksList.sort { $0.priority < $1.priority }
            case "Due Date":
                    tasksList.sort { formatter.date(from: $0.planned) ?? farDate > formatter.date(from: $1.planned) ?? farDate }
            case "Creation Date":
                tasksList.sort { formatter.date(from: $0.createdAt) ?? farDate < formatter.date(from: $1.createdAt) ?? farDate }
            default:
                break
            }
        }
      
        for (idx, task) in tasksList.enumerated() {
            try! uiRealm.write {
                task.position = idx
            }
        }
        try! uiRealm.write {
            listObject.reversed = reversed
        }
        let range = NSMakeRange(0, self.tableView.numberOfSections)
        let sections = NSIndexSet(indexesIn: range)
        self.tableView.reloadSections(sections as IndexSet, with: .automatic)

    }
    
    @objc func tappedCompleted(button: UIButton) {
        if !editingCell {
            if completedExpanded {
                button.setImage(UIImage(named: "arrow")?.withTintColor(.white).resize(targetSize: CGSize(width: 18, height: 20)), for: .normal)
            } else {
                button.setImage(UIImage(named: "arrow")?.withTintColor(.white).resize(targetSize: CGSize(width: 18, height: 20)).rotate(radians: .pi), for: .normal)
            }
            var indexPaths = [IndexPath]()
            for row in completedTasks.indices {
                indexPaths.append(IndexPath(row: row, section: 1))
            }
            completedExpanded = !completedExpanded
            if completedExpanded {
                tableView.insertRows(at: indexPaths, with: .fade)
                tableView.invalidateIntrinsicContentSize()
            } else {
                tableView.deleteRows(at: indexPaths, with: .fade)
                tableView.invalidateIntrinsicContentSize()
            }
        }
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
            return 40
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = TaskCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "list")
        var task = TaskObject()
        if searching {
                task = filteredTasks[indexPath.row]
        } else {
            if indexPath.section == 0 {
                task = tasksList[indexPath.row]
            } else {
                task = completedTasks[indexPath.row]
            }
        }
     
        if editingCell {
            if let selectedCell = selectedDict[task.id] {
                cell.selectedCell = selectedCell
            }
        }
        cell.allSteps = task.steps.map { $0 }
        cell.title.text = task.name
        cell.title.numberOfLines = 3
        cell.title.lineBreakMode = .byTruncatingTail
        cell.title.sizeToFit()
        cell.prioritized = task.priority
        cell.taskPlannedDate = task.planned
        cell.path = indexPath
        cell.taskCellDelegate = self
        cell.favorited = task.favorited
        cell.listTextColor = listTextColor
        cell.notes = task.note
        cell.reminderDate.text = task.reminder
        cell.completed = task.completed
        cell.repeatTask = task.repeated
        cell.id = task.id
        cell.position = task.position
        cell.parentList = task.parentList
        cell.configureBottomView()
        cell.taskObject = task
        cell.createdAt = task.createdAt
        cell.selectionStyle = .none
        cell.clipsToBounds = true
        cell.navigationController = (self.navigationController)!
        cell.layer.cornerRadius = 10
        cell.isUserInteractionEnabled = true
        return cell
    }
    
    private func tableView(tableView: UITableView,
                 willDisplayCell cell: UITableViewCell,
          forRowAtIndexPath indexPath: NSIndexPath)
    {
        cell.separatorInset = UIEdgeInsets.zero
        cell.preservesSuperviewLayoutMargins = false
        cell.layoutMargins = UIEdgeInsets.zero
    }
//
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            if tasksList[indexPath.row].name.count > 66 {
                return 120
            } else if tasksList[indexPath.row].name.count > 33 {
                return 100
            }
        } else if indexPath.section == 1 {
            if completedTasks[indexPath.row].name.count > 66 {
                return 120
            } else if completedTasks[indexPath.row].name.count > 33 {
                return 100
            }
        }
        return 80 //Choose your custom row height
    }

    
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        if sourceIndexPath == destinationIndexPath { return }
        let results = uiRealm.objects(TaskObject.self)
        tasksList = []
        try! uiRealm.write {
            for result in results {
                if result.parentList == listTitle && result.completed == false {
                    let pos = result.position
                    if (sourceIndexPath[1] < pos && destinationIndexPath[1] < pos) || (sourceIndexPath[1] > pos && destinationIndexPath[1]  > pos) {
                        } else if pos == destinationIndexPath[1] {
                            if sourceIndexPath[1] > destinationIndexPath[1]  {
                                result.position += 1
                            } else {
                                result.position -= 1
                            }
                        } else if pos == sourceIndexPath[1] {
                            result.position = destinationIndexPath[1]
                        } else if sourceIndexPath[1] > pos {
                            result.position += 1
                        } else if pos < destinationIndexPath[1]   {
                            result.position -= 1
                        }
                    tasksList.append(result)
                }
            }
        }
        tasksList.sort { (one, two) -> Bool in
            one.position < two.position
        }
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! TaskCell
        if editingStyle == .delete {
                let tasks = uiRealm.objects(TaskObject.self)
                var delIdx = 0
                var completedd = false
                for task in  tasks {
                    if task.id == cell.id {
                        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [task.id])
                        for step in task.steps {
                            try! uiRealm.write {
                                uiRealm.delete(step)
                            }
                        }
                    }
                    if indexPath.section == 0 && task.parentList == listTitle && task.id == cell.id && task.name == cell.title.text {
                        tasksList.removeAll(where: {$0.id == task.id})
                        delIdx = task.position
                        try! uiRealm.write {
                            uiRealm.delete(task)
                        }
                    } else if (indexPath.section == 1 && task.parentList == listTitle && task.id == cell.id && cell.title.text == task.name) {
                        completedd = true
                        completedTasks.removeAll(where: {$0.id == task.id})
                        delIdx = task.position
                        try! uiRealm.write {
                            uiRealm.delete(task)
                        }
                    }
                }
                
                if delIdx != -1 {
                    for task in tasks {
                        if task.parentList == listTitle && task.position > delIdx {
                            try! uiRealm.write {
                                task.position -= 1
                            }
                        }
                    }
                }
                
                    tableView.deleteRows(at: [indexPath], with: .fade)
                    tableView.reloadData()
              
            
        }
    }
  

    func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
        reloadDelegate?.reloadTableView()
        if  tableView.isValid(indexPath: indexPath ?? IndexPath(row: 250, section: 3)){
                let cell = tableView.cellForRow(at: indexPath!) as! TaskCell
                cell.clipsToBounds = true
                cell.layer.cornerRadius = 10
        }
      }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if listTitle == "Important" || listTitle == "Planned" || listTitle == "All Tasks" {
            return false
        } else {
            return true
        }
    }
    func reloadMainTable() {
        reloadDelegate?.reloadTableView()
    }
    
//
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        if editingCell {
            return UITableViewCell.EditingStyle.none
        } else {
                return UITableViewCell.EditingStyle.delete
        }
    }

    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
            pickUpSection = indexPath.section
            return tasksList.dragItems(for: indexPath)
    }
    
    func tableView(_ tableView: UITableView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UITableViewDropProposal {
        if tableView.hasActiveDrag {
            if session.items.count > 1 {
                return UITableViewDropProposal(operation: .cancel)
            } else {
                if pickUpSection == 1 || listTitle == "Planned" || listTitle == "All Tasks" || listTitle == "Important" || destinationIndexPath?.section == 1{
                    return UITableViewDropProposal(operation: .cancel)
                }
                return UITableViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
            }
        } else {
            return UITableViewDropProposal(operation: .copy, intent: .insertAtDestinationIndexPath)
        }
    }
    
    
    func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) {
        let destinationIndexPath: IndexPath
        
        if let indexPath = coordinator.destinationIndexPath {
            destinationIndexPath = indexPath
        } else {
            // Get last index path of table view.
            let section = tableView.numberOfSections - 1
            let row = tableView.numberOfRows(inSection: section)
            destinationIndexPath = IndexPath(row: row, section: section)
        }
        
        coordinator.session.loadObjects(ofClass: NSString.self) { items in
            // Consume drag items.
            let stringItems = items as! [TaskObject]
            
            var indexPaths = [IndexPath]()
            for (index, item) in stringItems.enumerated() {
                let indexPath = IndexPath(row: destinationIndexPath.row + index, section: destinationIndexPath.section)
                tasksList.addItem(item, at: indexPath.row)
                indexPaths.append(indexPath)
            }

            tableView.insertRows(at: indexPaths, with: .automatic)
        }
    }
    
}
