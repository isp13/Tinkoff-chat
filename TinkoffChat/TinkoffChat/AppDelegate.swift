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
    var layer: CAEmitterLayer?
    private let rootAssembly = RootAssembly()
    
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
        let window = UIWindow(frame: UIScreen.main.bounds)
        
        let controller = rootAssembly.presentationAssembly.customSplashViewController()
        let navigationController = UINavigationController(rootViewController: controller)
        window.rootViewController = navigationController
        
        window.makeKeyAndVisible()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapAction(_:)))
        tap.cancelsTouchesInView = false
        
        let longTap = UILongPressGestureRecognizer(target: self, action: #selector(panAction(_:)))
        longTap.cancelsTouchesInView = false
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(panAction(_:)))
        pan.cancelsTouchesInView = false
        
        window.addGestureRecognizer(tap)
        window.addGestureRecognizer(longTap)
        window.addGestureRecognizer(pan)
        
        self.window = window
        
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
    
    @objc func tapAction(_ gestureRecognizer: UITapGestureRecognizer) {
        if let window = window {
            let layerIcons = DefaultBrandAnimationEmitter().createLayer(position: gestureRecognizer.location(in: gestureRecognizer.view?.window), size: window.bounds.size)
            window.layer.addSublayer(layerIcons)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                layerIcons.removeFromSuperlayer()
            }
        }
    }
    
    @objc func panAction(_ gestureRecognizer: UIGestureRecognizer) {
        if let window = window {
            switch gestureRecognizer.state {
            case .began:
                let layerIcons = DefaultBrandAnimationEmitter().createLayer(position: gestureRecognizer.location(in: gestureRecognizer.view?.window),
                                                                        size: window.bounds.size)
                window.layer.addSublayer(layerIcons)
                layer = layerIcons
            case .changed:
                layer?.emitterPosition = gestureRecognizer.location(in: gestureRecognizer.view?.window)
            case .ended, .cancelled:
                layer?.removeFromSuperlayer()
            case .failed, .possible:
                print("")
            default:
                fatalError()
            }
        }
    }
}
