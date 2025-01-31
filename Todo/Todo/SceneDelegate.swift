//
//  SceneDelegate.swift
//  Todo
//
//  Created by Dante Kim on 9/18/20.
//  Copyright © 2020 Alarm & Calm. All rights reserved.
//

import UIKit
import Purchases
import AppsFlyerLib

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        // Processing Universal Link from the killed state
        if let userActivity = connectionOptions.userActivities.first {
          self.scene(scene, continue: userActivity)
        }
      // Processing URI-scheme from the killed state
          self.scene(scene, openURLContexts: connectionOptions.urlContexts)
          guard let _ = (scene as? UIWindowScene) else { return }
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let window = UIWindow(windowScene: windowScene)
        let defaults = UserDefaults.standard
        var launched = defaults.integer(forKey: "launchNumber") ?? 0
        launched = launched + 1
        defaults.setValue(launched, forKey: "launchNumber")
        let controller = launched == 1 ? WelcomeController() : MainViewController()
        if UserDefaults.standard.value(forKey: "lastOpened") == nil {
            mainIsRoot = true
        } else {
            mainIsRoot = false
        }
        window.rootViewController = UINavigationController(rootViewController: controller )
        
        self.window = window
        window.makeKeyAndVisible()
        
    }

        func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
            AppsFlyerLib.shared().continue(userActivity, restorationHandler: nil)
        }
        
        func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
            if let url = URLContexts.first?.url {
                AppsFlyerLib.shared().handleOpen(url, options: nil)
            }
        }

    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
        
        // Save changes in the application's managed object context when the application transitions to the background.
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }
    
    
}

