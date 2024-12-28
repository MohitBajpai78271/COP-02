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
        
        window = UIWindow(windowScene: windowScene)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        KeychainHelper.shared.save("http://93.127.172.217:4000", for: Ud.baseURl);
        KeychainHelper.shared.save("http://93.127.172.217:2005",for: Ud.activeUserUrl);
        KeychainHelper.shared.save("http://93.127.172.217:4000/users-location",for: Ud.locnUrl);
        
        let isLoggedIn = UserDefaults.standard.bool(forKey: Ud.isLoggedIn)
        let initialViewController: UIViewController
        
        if isLoggedIn{
            print(isLoggedIn)
            initialViewController = storyboard.instantiateViewController(withIdentifier: K.tabbarView)
        } else {
            let signInVC = storyboard.instantiateViewController(withIdentifier: K.signinView) as! SignInViwController
            let navController = UINavigationController(rootViewController: signInVC)
            initialViewController = navController
        }
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
        
        func sceneDidDisconnect(_ scene: UIScene) {
            
        }
        
        func sceneDidBecomeActive(_ scene: UIScene) {
            
        }
        
        func sceneWillResignActive(_ scene: UIScene) {
            
        }
        
        func sceneWillEnterForeground(_ scene: UIScene) {
        }
        
        func sceneDidEnterBackground(_ scene: UIScene) {
            
        }
        
        
    }
    
