//
//  PopUpView.swift
//  Todo
//
//  Created by Dante Kim on 10/13/20.
//  Copyright © 2020 Alarm & Calm. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

var selectedGroup: ListGroup?
extension MainViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: popUpCellId, for: indexPath) as! MainPopUpcell
        cell.nameLabel.font = UIFont(name: "OpenSans-Regular", size: 20)
        if indexPath.row == 0 {
            cell.icon.image = UIImage(named: "plus")?.resize(targetSize: CGSize(width: 30, height: 30)).withTintColor(defaultColor)
            cell.nameLabel.text = "Add List"
        } else if indexPath.row == 1 {
            cell.icon.image = UIImage(named: "rename")?.resize(targetSize: CGSize(width: 30, height: 30)).withTintColor(defaultColor)
            cell.nameLabel.text = "Edit Group Name"
        } else {
            cell.icon.image = UIImage(named: "close")?.resize(targetSize: CGSize(width: 30, height: 30)).withTintColor(defaultColor)
            cell.nameLabel.text = "Delete Group"
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            let listGroupTableView = AddListToGroupTableView(frame: view.bounds)
            listGroupTableView.reloadDelegate = self
            slideUpViewTapped()
            view.addSubview(listGroupTableView)
        } else if indexPath.row == 1{
            //tapped rename group
        } else {
            let groups = uiRealm.objects(ListGroup.self)
            let positions = uiRealm.objects(GroupPosition.self)
            
            try! uiRealm.write {
                for pos in positions {
                    if pos.groupName == selectedGroup?.name {
                        uiRealm.delete(pos)
                    }
                }
                for group in groups {
                    if group.name == selectedGroup!.name {
                        uiRealm.delete(group)
                        break
                    }
                }
             
            }
            self.getRealmData()
            slideUpViewTapped()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: slideUpView.frame.width, height: 50)
    }
    
    
    @objc func groupElipsTapped(button: UIButton) {
        let window = UIApplication.shared.keyWindow
        containerView.backgroundColor = UIColor.black.withAlphaComponent(0.9)
        containerView.frame = self.view.frame
        
        window?.addSubview(containerView)
        containerView.alpha = 0
        let screenSize = UIScreen.main.bounds.size
        let slideUpViewHeight: CGFloat = 200
        slideUpView.frame = CGRect(x: 0, y: (window?.frame.height)!, width: screenSize.width, height: slideUpViewHeight)
        slideUpView.register(MainPopUpcell.self, forCellWithReuseIdentifier: popUpCellId)
        slideUpView.layer.cornerRadius = 15
        slideUpView.dataSource = self
        slideUpView.delegate = self
          
          window?.addSubview(slideUpView)
          UIView.animate(withDuration: 0.5,
                         delay: 0, usingSpringWithDamping: 1.0,
                         initialSpringVelocity: 1.0,
                         options: .curveEaseOut, animations: {
            self.containerView.alpha = 0.8
                          self.slideUpView.frame = CGRect(x: 0, y: screenSize.height - slideUpViewHeight, width: self.slideUpView.frame.width, height: self.slideUpView.frame.height)
          }, completion: nil)
    
          let tapGesture = UITapGestureRecognizer(target: self,
                            action: #selector(slideUpViewTapped))
          containerView.addGestureRecognizer(tapGesture)
        let groupResults = uiRealm.objects(ListGroup.self)
        for group in groupResults {
            if group.name == button.accessibilityIdentifier {
                selectedGroup = group
            }
        }
      }
      
      @objc func slideUpViewTapped() {
         let window = UIApplication.shared.keyWindow
           UIView.animate(withDuration: 0.4,
                          delay: 0, usingSpringWithDamping: 1.0,
                          initialSpringVelocity: 1.0,
                          options: .curveEaseInOut, animations: {
                            self.containerView.alpha = 0
                            self.slideUpView.frame = CGRect(x: 0, y: (window?.frame.height)!, width: self.slideUpView.frame.width, height: self.slideUpView.frame.height
                            )
           }, completion: nil)
      }
      
}
