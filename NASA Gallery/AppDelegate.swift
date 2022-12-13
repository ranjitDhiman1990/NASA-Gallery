//
//  AppDelegate.swift
//  NASA Gallery
//
//  Created by Dhiman Ranjit on 08/12/22.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var isConnectedToInternet: Bool = true
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        self.listenToInternetConnection()
        return true
    }
    
    func listenToInternetConnection() {
        if #available(iOS 12, *) {
            NetworkMonitor.shared.startMonitoring { status in
                if status == .satisfied {
                    self.isConnectedToInternet = true
                    self.showInternetConnectionStatus(message: "Connected to Internet")
                } else if status == .requiresConnection {
                    self.isConnectedToInternet = false
                    self.showInternetConnectionStatus(message: "No Internet Connection", success: false, autoHide: false)
                }
            }
        } else {
            if !Reachability.isConnectedToNetwork() {
                self.isConnectedToInternet = false
                self.showInternetConnectionStatus(message: "No Internet", success: false, autoHide: false)
            } else {
                self.isConnectedToInternet = true
                self.dismissInternetConnectionStatus()
            }
        }
    }

    // MARK: UISceneSession Lifecycle
    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    @available(iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

}

extension AppDelegate {
    func showInternetConnectionStatus(message: String, success: Bool = true, autoHide: Bool = true) {
        self.dismissInternetConnectionStatus()
        DispatchQueue.main.async {
            var keyWindow: UIWindow?
            if #available(iOS 13.0, *) {
                keyWindow = UIApplication.shared.connectedScenes
                    .map({$0 as? UIWindowScene})
                    .compactMap({$0})
                    .first?.windows
                    .filter({$0.isKeyWindow}).first
            } else {
                // Fallback on earlier versions
                keyWindow = UIApplication.shared.windows.first
            }
            let screenHeight = keyWindow?.frame.size.height ?? 0
            let screenWidth = keyWindow?.frame.size.width ?? 0
            let toastLabel = UILabel(frame: CGRect(x: 0, y: screenHeight - 50, width:  screenWidth, height: 50))
            toastLabel.backgroundColor = success ? UIColor.green : UIColor.red
            toastLabel.textColor = UIColor.white
            toastLabel.font = .systemFont(ofSize: 15.0)
            toastLabel.textAlignment = .center;
            toastLabel.text = message
            toastLabel.alpha = 1.0
            toastLabel.tag = 999999
            toastLabel.roundCorners(radius: 4, corners: [.topLeft, .topRight])
            keyWindow?.addSubview(toastLabel)
            
            if autoHide {
                UIView.animate(withDuration: 8, delay: 0.1, options: .curveEaseOut, animations: {
                    toastLabel.alpha = 0.0
                }, completion: {(isCompleted) in
                    toastLabel.removeFromSuperview()
                })
            }
        }
    }
    
    func dismissInternetConnectionStatus() {
        DispatchQueue.main.async {
            if #available(iOS 13.0, *) {
                let keyWindow = UIApplication.shared.connectedScenes
                    .map({$0 as? UIWindowScene})
                    .compactMap({$0})
                    .first?.windows
                    .filter({$0.isKeyWindow}).first
                if let toastLabel = keyWindow?.viewWithTag(999999) as? UILabel {
                    toastLabel.removeFromSuperview()
                }
            } else {
                // Fallback on earlier versions
                let keyWindow = UIApplication.shared.windows.first
                if let toastLabel = keyWindow?.viewWithTag(999999) as? UILabel {
                    toastLabel.removeFromSuperview()
                }
            }
        }
    }
}
