import UIKit

extension ListController: KeyboardToolbarDelegate, ReloadSlider {
    @objc func keyboardWillShow(notification: NSNotification) {
        let info:NSDictionary = notification.userInfo! as NSDictionary
        let keyboardSize = (info[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        if !creating {
            let _: CGFloat = info[UIResponder.keyboardAnimationDurationUserInfoKey] as! NSNumber as! CGFloat
            if stabilize {
                    self.addTaskField.frame.origin.y = self.addTaskField.frame.origin.y - lastKeyboardHeight - 65
            }
            addedStep = true
            stabilize = false
        } else {
            if keyboard == true || keyboard2 {
                lastKeyboardHeight = keyboardSize.height + 93
            } else {
                lastKeyboardHeight = keyboardSize.height
                keyboard2 = true
            }
            self.customizeListView.frame.origin.y = self.customizeListView.frame.origin.y - lastKeyboardHeight - 140
            createdNewList = true
        }
    }
    
    @objc func keyboardWillChangeFrame(notification: NSNotification) {
        let info:NSDictionary = notification.userInfo! as NSDictionary
        let keyboardSize = (info[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        if !creating {
            if addedStep || createdNewList {
                lastKeyboardHeight = keyboardSize.height + 185
            } else {
                lastKeyboardHeight = keyboardSize.height
            }
        }
           
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        self.addTaskField.frame.origin.y = self.view.frame.height
        self.customizeListView.frame.origin.y = self.view.frame.height
    }
    func reloadSlider() {
        if tappedIcon == "List Options" {
            slideUpViewTapped()
        } else if tappedIcon == "Sort Options" {
            slideUpViewTapped()
        } else {
            slideUpViewTapped()
            addTaskField.becomeFirstResponder()
        }
    }
    
    func keyboardToolbar(button: UIButton, type: KeyboardToolbarButton, isInputAccessoryViewOf textField: UITextField) {
        slideUpView.reloadData()
        switch type {
        case .done:
            addTaskField.resignFirstResponder()
        case .addToList:
            tappedIcon = "Add to a List"
            addTaskField.resignFirstResponder()
            createSlider()
        case .priority:
            tappedIcon = "Priority"
            addTaskField.resignFirstResponder()
            createSlider()
        case .dueDate:
            planned = true
            tappedIcon = "Due"
            addTaskField.resignFirstResponder()
            dueDateTapped = false
            laterTapped = false
            createSlider()
        case .reminder:
            reminder = true
            addTaskField.resignFirstResponder()
            createSlider()
            dueDateTapped = false
            laterTapped = false
            tappedIcon = "Reminder"
        case .favorite:
            favorited = true
            //add it to input accessory bar
            addTaskField.addButton(leftButton: .favorited, toolBarDelegate: self)
            if !firstAppend {
                scrollView.contentSize.width = scrollView.contentSize.width + 170
            } else {
                firstAppend = false
            }
            
        case .favorited:
            favorited = false
            addTaskField.addButton(leftButton: .favorite, toolBarDelegate: self)
            if !firstAppend {
                scrollView.contentSize.width = scrollView.contentSize.width - 170
            } else {
                if scrollView.contentSize.width <= UIScreen.main.bounds.width {
                    firstAppend = true
                }
            }
        case .prioritized:
            addTaskField.addButton(leftButton: .priority, toolBarDelegate: self)
            if !firstAppend {
                scrollView.contentSize.width = scrollView.contentSize.width - 170
            } else {
                if scrollView.contentSize.width <= UIScreen.main.bounds.width {
                    firstAppend = true
                }
            }
        case .addedReminder:
            reminder = false
            addTaskField.addButton(leftButton: .reminder, toolBarDelegate: self)
            if scrollView.contentSize.width > UIScreen.main.bounds.width  {
                    if selectedDate == "Pick a Date & Time" {
                        if added50ToReminder == true {
                            scrollView.contentSize.width = scrollView.contentSize.width - 50
                            added50ToReminder = false
                            firstAppend = true
                        } else {
                            scrollView.contentSize.width = scrollView.contentSize.width - 300
                        }
                    } else {
                        scrollView.contentSize.width = scrollView.contentSize.width - 170
                    }
            } else {
                    firstAppend = true
            }
            laterTapped = false
            dateReminderSelected = ""
            timeReminderSelected = ""
            selectedDate = ""
        case .addedDueDate:
            planned = false
            addTaskField.addButton(leftButton: .dueDate, toolBarDelegate: self)
            if !firstAppend {
                if selectedDueDate == "Pick a Date & Time" {
                    if added50ToDueDate == true {
                        scrollView.contentSize.width = scrollView.contentSize.width - 50
                        added50ToDueDate = false
                        firstAppend = true
                    } else {
                        scrollView.contentSize.width = scrollView.contentSize.width - 300
                    }
                } else {
                    scrollView.contentSize.width = scrollView.contentSize.width - 170
                }
                
            } else {
                if scrollView.contentSize.width <= UIScreen.main.bounds.width {
                    firstAppend = true
                }
            }
            dueDateTapped = false
            laterTapped = false
            dateDueSelected = ""
            timeDueSelected = ""
            selectedDueDate = ""
            laterTapped = false
        case .addedToList:
            selectedList = ""
            addTaskField.addButton(leftButton: .addToList, toolBarDelegate: self)
            if !firstAppend {
                scrollView.contentSize.width = scrollView.contentSize.width - 200
            } else {
                scrollView.contentSize.width = scrollView.contentSize.width - 50
            }
        }
    }
}
