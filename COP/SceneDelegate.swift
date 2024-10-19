//
//  SceneDelegate.swift
//  COP
//
//  Created by Mac on 21/07/24.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {

        guard let windowScene = (scene as? UIWindowScene) else { return }
        
           
        // 1. Create a UIWindow with the windowScene
        window = UIWindow(windowScene: windowScene)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        // 2. Check if the user is logged in
        let isLoggedIn = UserDefaults.standard.bool(forKey: "isLoggedIn")
        let initialViewController: UIViewController
        
        // 3. Depending on login status, decide the initial view controller
        if isLoggedIn {
            // User is logged in, show TabBarController (or other view controllers)
            initialViewController = storyboard.instantiateViewController(withIdentifier: K.tabbarView)
        } else {
            // User is not logged in, show SignInViewController embedded in a UINavigationController
            let signInVC = storyboard.instantiateViewController(withIdentifier: K.signinView) as! SignInViwController
            let navController = UINavigationController(rootViewController: signInVC)
            initialViewController = navController
        }
        
        // 4. Set the initial view controller as the root and make it visible
        window?.rootViewController = initialViewController
        window?.makeKeyAndVisible()
    }
    
    func createSigninNC() -> UINavigationController{
        let signinVC = SignInViwController()
        return UINavigationController(rootViewController: signinVC)
    }

    func isFirstLaunch() -> Bool {
           let hasLaunchedKey = "hasLaunchedBefore"
           let isFirstLaunch = !UserDefaults.standard.bool(forKey: hasLaunchedKey)

           if isFirstLaunch {
               UserDefaults.standard.set(true, forKey: hasLaunchedKey)
               UserDefaults.standard.synchronize()
           }

           return isFirstLaunch
       }

//       // Function to perform logout
//       func performLogout() {
//           UserDefaults.standard.removeObject(forKey: "isLoggedIn")
//           UserDefaults.standard.removeObject(forKey: "userToken")
//
//           let storyboard = UIStoryboard(name: "Main", bundle: nil)
//           let loginViewController = storyboard.instantiateViewController(withIdentifier: K.signinView)
//           window?.rootViewController = loginViewController
//           window?.makeKeyAndVisible()
//       }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
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
    }


}

