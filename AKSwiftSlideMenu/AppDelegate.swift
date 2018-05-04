//
//  AppDelegate.swift
//  AKSwiftSlideMenu
//
//  Created by i on 3/10/18.
//  Copyright © 2018 Kode. All rights reserved.
//

import UIKit
import BWWalkthrough
import Firebase
import CoreData
import Stripe

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    //Variables
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        //To initializa the Stripe payment
        STPPaymentConfiguration.shared().publishableKey = "pk_test_94ZtCFJ3sRtRKr4VNRfPfYAo"
        //To initializa the Paypal payment
        PayPalMobile .initializeWithClientIds(forEnvironments: [PayPalEnvironmentProduction:"AagtePaLT6mAp-tcAfEm5gsrt_5d4PDD3OIsIDnj9IhaFxyqmKkeEAJgIB8upDjooQSJFdecDQKZnyx5", PayPalEnvironmentSandbox: "kapadiya.sarrhak-facilitator@gmail.com"])
        // Override point for customization after application launch.
        FirebaseApp.configure()
        Database.database().isPersistenceEnabled = true
        // Skip login on every launch if user has already logged in on the same device
        let launchedBefore = UserDefaults.standard.bool(forKey: "Signup")
        if launchedBefore  {
            print("hi")
            if Auth.auth().currentUser !== nil{
                // instantiate ScanViewController
                let rootController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "abc")
                self.window?.rootViewController = rootController
            }
            else if Auth.auth().currentUser == nil {
                // instantiate signupviewcontroller
                let rootController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "SignUp")
                self.window?.rootViewController = rootController
            }
        } else {
            do {
                try Auth.auth().signOut()
            } catch {
                
            }
            let rootController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "ad")
            self.window?.rootViewController = rootController
            UserDefaults.standard.set(true, forKey: "Signup")
            UserDefaults.standard.synchronize()
        }
   
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        self.saveContext()
    }

    func applicationDidFinishLaunching(_ application: UIApplication) {
        // increase the launch time for launchscreen
        Thread.sleep(forTimeInterval : 4.0)
    }
    //method to handle 3D touch on app icon
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        if Auth.auth().currentUser !== nil{
            let rootController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "abc")
            self.window?.rootViewController = rootController
        }
        else if Auth.auth().currentUser == nil {
            let rootController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "SignUp")
            self.window?.rootViewController = rootController
        }
    }
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "AKSwiftSlideMenu")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}
