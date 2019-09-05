//
//  AppDelegate.swift
//  Basic Example
//
//  Created by brainCloud Support on 2018-08-14.
//  Copyright © 2018 brainCloud Support. All rights reserved.
//

import UIKit
import BrainCloud
import UserNotifications


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    var window: UIWindow?
    static var _bc: BrainCloudWrapper = BrainCloudWrapper();
    
    static var pushToken: String?;
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        UserDefaults.standard.register(defaults: ["HasAuthenticated" : true])
        
        /*
         BRAINCLOUD_INFO
         
         // We need to create the brainCloud Wrapper
         AppDelegate._bc = BrainCloudWrapper()
         
         // Let's enable debug logging to the console, to help with testing
         AppDelegate._bc.getBCClient().enableLogging(true)
         
         // Now let's pair this brainCloud Client with our app on the brainCloud dashboard
         
         // We need to change YOUR_SECRET and YOUR_APPID to match what is on the brainCloud dashboard.
         // See the readme for more info: https://github.com/getbraincloud/braincloud-objc/blob/master/README.md
         
         AppDelegate._bc.initialize("https://sharedprod.braincloudservers.com/dispatcherv2",
         secretKey: YOUR_SECRET,
         gameId: YOUR_APPID,
         gameVersion: "1.0.0",
         companyName: YOUR_COMPANY,
         gameName: YOUR_GAME_NAME)
         */
        
        AppDelegate._bc = BrainCloudWrapper()
        
        AppDelegate._bc.getBCClient().enableLogging(true)
        
        
        var dictionary: [String: String] = [:]
        
        dictionary["12720"] = "f99081d2-0644-434e-9eb5-8d721a188488"
        dictionary["12049"] = "921d9acc-e286-4b37-91b6-a394f4e6ff4f"
        
        
        
        AppDelegate._bc.initialize(withApps: "https://sharedprod.braincloudservers.com/dispatcherv2", defaultAppId: "12720", secretMap: dictionary, appVersion: "1.0.0", companyName: "brainCloud", appName: "Basic - Swift")
        
        
        
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options:[.badge, .alert, .sound]) { (granted, error) in
            // Enable or disable features based on authorization.
        }
        application.registerForRemoteNotifications()
        UNUserNotificationCenter.current().delegate = self
        
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        AppDelegate.pushToken = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
        print(AppDelegate.pushToken ?? "")
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void)
    {
        completionHandler([.alert, .badge, .sound])
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        
        print(error)
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        
    }
}

