//
//  AppDelegate.swift
//  TinkoffChat
//
//  Created by Никита Казанцев on 13.02.2021.
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    var oldStateType: UIApplication.State = .inactive
    
    // MARK: Launch
    
    /**
     When an iOS app is launched the first thing called is
     This method is intended for initial application setup. Storyboards have already been loaded at this point but state restoration hasn’t occurred yet.
     can potentially be launched with options identifying that the app was called to handle a push notification or url or something else.
     You need to return true if your app can handle the given activity or url.
     */
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        
        #if DEBUG
        print("Application moved from not running to inactive : \(#function)")
        #endif
        
        return true
    }
    
    /**
     Is called next.
     
     This callback method is called when the application has finished launching and restored state and can do final initialization such as creating UI.
     can potentially be launched with options identifying that the app was called to handle a push notification or url or something else.
     You need to return true if your app can handle the given activity or url.
     */
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        #if DEBUG
        print("Application moved from not running to inactive : \(#function)")
        #endif
        
        FirebaseApp.configure()
        
        return true
    }
    
    /**
     is called after application: didFinishLaunchingWithOptions: or if your app becomes active again after receiving a phone call or other system interruption.
     */
    func applicationWillEnterForeground(_ application: UIApplication) {
        Logger.log(stateString(oldState: oldStateType, newState: application.applicationState, funcName: #function))
    }
    
    /**
     is called after applicationWillEnterForeground: to finish up the transition to the foreground.
     */
    func applicationDidBecomeActive(_ application: UIApplication) {
        Logger.log(stateString(oldState: oldStateType, newState: application.applicationState, funcName: #function))
    }
    
    // MARK: Termination
    
    /**
     is called when the app is about to become inactive (for example, when the phone receives a call or the user hits the Home button).
     */
    func applicationWillResignActive(_ application: UIApplication) {
        Logger.log(stateString(oldState: oldStateType, newState: application.applicationState, funcName: #function))
    }
    
    /**
     is called when your app enters a background state after becoming inactive.
     You have approximately five seconds to run any tasks you need to back things up in case the app gets terminated later or right after that.
     */
    func applicationDidEnterBackground(_ application: UIApplication) {
        Logger.log(stateString(oldState: oldStateType, newState: application.applicationState, funcName: #function))
    }
    
    /**
     is called when your app is about to be purged from memory. Call any final cleanups here.
     */
    func applicationWillTerminate(_ application: UIApplication) {
        Logger.log(stateString(oldState: oldStateType, newState: application.applicationState, funcName: #function))
    }
    
    func stateString(oldState: UIApplication.State, newState: UIApplication.State, funcName: String) -> String {
        
        let res = "Application moved from \(oldState.descriptionForEventTag) to \(newState.descriptionForEventTag) : \(funcName)"
        oldStateType = newState
        return res
    }
}
