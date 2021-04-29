//
//  AppDelegate.swift
//  Fid
//
//  Created by CROCODILE on 13.01.2021.
//

import UIKit
import Firebase
import GoogleSignIn
import CoreSpotlight
import OneSignal
import RealmSwift
import IQKeyboardManager
import GoogleMaps
import GooglePlaces
import FBSDKCoreKit
import FBSDKLoginKit

let realm = try! Realm()
let falsepredicate = NSPredicate(value: false)

@main
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        self.statusBarColorChange()
        
        // Google map initialize
        GMSServices.provideAPIKey(GoogleMapKey.mapKey)
        GMSPlacesClient.provideAPIKey(GoogleMapKey.mapKey)
                
        //-----------------------------------------------------------------------------------------------------------------------------------------
        // SyncEngine initialization
        //-----------------------------------------------------------------------------------------------------------------------------------------
        SyncEngine.initBackend()
        SyncEngine.initUpdaters()
        SyncEngine.initObservers()
                
        // For realtime chat
//        LocationManager.start()
        Media.cleanupExpired()
                        
        // For Google Signin
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        
        //Facebook
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        
        // IQKeyboardManager initialize
        IQKeyboardManager.shared().isEnabled = true
        IQKeyboardManager.shared().disabledTouchResignedClasses.add(RCPrivateChatView.self)
        IQKeyboardManager.shared().disabledToolbarClasses.add(RCPrivateChatView.self)
        IQKeyboardManager.shared().disabledTouchResignedClasses.add(RCGroupChatView.self)
        IQKeyboardManager.shared().disabledToolbarClasses.add(RCGroupChatView.self)
        IQKeyboardManager.shared().disabledTouchResignedClasses.add(BenefitVC.self)
        IQKeyboardManager.shared().disabledToolbarClasses.add(BenefitVC.self)

        //-----------------------------------------------------------------------------------------------------------------------------------------
        // Push notification initialization
        //-----------------------------------------------------------------------------------------------------------------------------------------
        let authorizationOptions: UNAuthorizationOptions = [.sound, .alert, .badge]
        UNUserNotificationCenter.current().requestAuthorization(options: authorizationOptions, completionHandler: { granted, error in
            if (error == nil) {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        })

        //-----------------------------------------------------------------------------------------------------------------------------------------
        // OneSignal initialization
        //-----------------------------------------------------------------------------------------------------------------------------------------
        OneSignal.initWithLaunchOptions(launchOptions, appId: ONESIGNAL_APPID, handleNotificationReceived: nil,
                                        handleNotificationAction: nil, settings: [kOSSettingsKeyAutoPrompt: false])
        OneSignal.setLogLevel(ONE_S_LOG_LEVEL.LL_NONE, visualLevel: ONE_S_LOG_LEVEL.LL_NONE)
        OneSignal.inFocusDisplayType = .none

        //-----------------------------------------------------------------------------------------------------------------------------------------
        // Manager initialization
        //-----------------------------------------------------------------------------------------------------------------------------------------
        _ = ChatManager.shared
        _ = Connectivity.shared
        _ = LocationManager.shared

        //-----------------------------------------------------------------------------------------------------------------------------------------
        // MediaUploader initialization
        //-----------------------------------------------------------------------------------------------------------------------------------------
        _ = MediaUploader.shared
        
        return true
    }
    
    func statusBarColorChange(){

        
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    //MARK: - Google Signin
    
    @available(iOS 9.0, *)
    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any])
      -> Bool {
        let returnFacebook = ApplicationDelegate.shared.application(application, open: url, options: options)
        let returnGoogle = GIDSignIn.sharedInstance().handle(url)
      return returnGoogle || returnFacebook
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
                
        return GIDSignIn.sharedInstance().handle(url)
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
      
        if let error = error {
            debugPrint("Could not sign in with google: \(error)")
        } else {
            guard let controller = GIDSignIn.sharedInstance()?.presentingViewController as? RegisterVC else { return }
            guard let authentication = user.authentication else { return }
            let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
            
            if let email = user.profile.email {
                defaults.setValue(email, forKey: "social_email_google")
            }
            
            if let firstname = user.profile.givenName {
                defaults.setValue(firstname, forKey: "social_firstname")
            }
            
            if let lastname = user.profile.familyName {
                defaults.setValue(lastname, forKey: "social_lastname")
            }
                                                
            controller.firebaseLogin(credential, appleLoggedIn: false, googleLogin: true, faebookLogin: false, apple_credential: nil)
        }
    }

    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
        // ...
    }
    
    //---------------------------------------------------------------------------------------------------------------------------------------------
    func applicationWillResignActive(_ application: UIApplication) {

    }

    //---------------------------------------------------------------------------------------------------------------------------------------------
    func applicationDidEnterBackground(_ application: UIApplication) {

        LocationManager.stop()

        Persons.update(lastTerminate: Date().timestamp())
    }

    //---------------------------------------------------------------------------------------------------------------------------------------------
    func applicationWillEnterForeground(_ application: UIApplication) {
        print("WillEnterForeground")
    }

    //---------------------------------------------------------------------------------------------------------------------------------------------
    func applicationDidBecomeActive(_ application: UIApplication) {

        LocationManager.start()
        Media.cleanupExpired()

        NotificationCenter.post(notification: NOTIFICATION_APP_STARTED)

        DispatchQueue.main.async(after: 0.5) {
            Persons.update(lastActive: Date().timestamp())
            Persons.update(oneSignalId: PushNotification.oneSignalId())
        }
    }

    //---------------------------------------------------------------------------------------------------------------------------------------------
    func applicationWillTerminate(_ application: UIApplication) {

    }

    // MARK: - CoreSpotlight methods
    //---------------------------------------------------------------------------------------------------------------------------------------------
//    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
//
//        if (userActivity.activityType == CSSearchableItemActionType) {
//            if let userId = userActivity.userInfo?[CSSearchableItemActivityIdentifier] as? String {
//                if (AuthUser.userId() != "") {
//                    peopleView.actionUser(userId: userId)
//                    return true
//                }
//            }
//        }
//        return false
//    }
//    
//    // MARK: - Home screen dynamic quick action methods
//    //---------------------------------------------------------------------------------------------------------------------------------------------
//    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
//
//        if (AuthUser.userId() != "") {
//            if (shortcutItem.type == "newchat") {
//                chatsView.actionNewChat()
//            }
//            if (shortcutItem.type == "newgroup") {
//                groupsView.actionNewGroup()
//            }
//            if (shortcutItem.type == "recentuser") {
//                if let userInfo = shortcutItem.userInfo as? [String: String] {
//                    if let userId = userInfo["userId"] {
//                        chatsView.actionRecentUser(userId: userId)
//                    }
//                }
//            }
//        }
//
//        if (shortcutItem.type == "shareapp") {
//            if let topViewController = topViewController() {
//                var shareitems: [AnyHashable] = []
//                shareitems.append(TEXT_SHARE_APP)
//                let activityView = UIActivityViewController(activityItems: shareitems, applicationActivities: nil)
//                topViewController.present(activityView, animated: true)
//            }
//        }
//    }

    // MARK: -
    //---------------------------------------------------------------------------------------------------------------------------------------------
    func topViewController() -> UIViewController? {

        let keyWindow = UIApplication.shared.windows.first { $0.isKeyWindow }
        var viewController = keyWindow?.rootViewController

        while (viewController?.presentedViewController != nil) {
            viewController = viewController?.presentedViewController
        }
        return viewController
    }

}

extension UIApplication {

var statusBarView: UIView? {
    return value(forKey: "statusBar") as? UIView
   }
}
