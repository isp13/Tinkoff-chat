//
//  AppDelegate.swift
//  TinkoffChat
//
//  Created by Никита Казанцев on 13.02.2021.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    let loggingEnabled: Bool = true
    
    var state: String = ""

       var temporaryState: String {
           switch UIApplication.shared.applicationState {
           case .active:
               return "UIApplicationStateActive"
           case .inactive:
               return "UIApplicationStateInactive"
           case .background:
               return "UIApplicationStateBackground"
           default:
               break
           }
           return ""
       }
    
    func logCicle(_ function: String = #function) {
        if loggingEnabled {
            print("Application moved from \(state) to \(temporaryState)")
            state = temporaryState
            print(function)
        }
    }
    
    // MARK: Launch
    
    /**
     When an iOS app is launched the first thing called is
     
     This method is intended for initial application setup. Storyboards have already been loaded at this point but state restoration hasn’t occurred yet.
     
     can potentially be launched with options identifying that the app was called to handle a push notification or url or something else. You need to return true if your app can handle the given activity or url.
     */
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        logCicle(#function)
        
        return true
    }
    
    
    /**
     Is called next.
     
     This callback method is called when the application has finished launching and restored state and can do final initialization such as creating UI.
     
     can potentially be launched with options identifying that the app was called to handle a push notification or url or something else. You need to return true if your app can handle the given activity or url.
     */
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        logCicle(#function)
        
        return true
    }
    
    
    /**
     is called after application: didFinishLaunchingWithOptions: or if your app becomes active again after receiving a phone call or other system interruption.
     */
    func applicationWillEnterForeground(_ application: UIApplication) {
        logCicle(#function)
    }
    
    
    /**
     is called after applicationWillEnterForeground: to finish up the transition to the foreground.
     */
    func applicationDidBecomeActive(_ application: UIApplication) {
        logCicle(#function)
    }
    
    
    
    // MARK: Termination
    
    /**
     is called when the app is about to become inactive (for example, when the phone receives a call or the user hits the Home button).
     */
    func applicationWillResignActive(_ application: UIApplication) {
        logCicle(#function)
    }
    
    
    /**
     is called when your app enters a background state after becoming inactive. You have approximately five seconds to run any tasks you need to back things up in case the app gets terminated later or right after that.
     */
    func applicationDidEnterBackground(_ application: UIApplication) {
        logCicle(#function)
    }
    
    
    /**
     is called when your app is about to be purged from memory. Call any final cleanups here.
     */
    func applicationWillTerminate(_ application: UIApplication) {
        logCicle(#function)
    }
}

