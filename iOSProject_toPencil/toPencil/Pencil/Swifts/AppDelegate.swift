//
//  AppDelegate.swift
//  Pencil
//
//  Created by Lakr Sakura on 2018/7/31.
//  Copyright © 2018 Lakr Sakura. All rights reserved.
//

import UIKit

let Math_Pi         = CGFloat.pi
var TargetIPAddr_1  = 192
var TargetIPAddr_2  = 168
var TargetIPAddr_3  = 6
var TargetIPAddr_4  = 233    //Set IP To _._._._
var TargetPort      = 11006
var URLStr: String  = "192.168.6.233"
var iPv6Addr: String  = "fe80::0000:0000:0000:0000%00"
var PencilDetected  = false

var MessgaeNO       = 2147483647

var isiPv6          = false

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        MessgaeNO = 0
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

