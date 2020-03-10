//
//  SceneDelegate.swift
//  LittleWalk
//
//  Created by Scheggia on 28/02/2020.
//  Copyright © 2020 Flowprocess. All rights reserved.
//

import UIKit
import SwiftUI
import AppFoundation
import CoreData

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var diContainer = InjectionContainer()
    var contentViewModel: ContentViewModel = ContentViewModel()
    var interactor: FlickrInteractorType!
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        self.interactor = FlickrInteractor(locationNotifier: LocationNotifier(),
                                           api: FlickrAPI(),
                                           container: diContainer)
        let dataStore = diContainer.resolve(DataStoreType.self) as? DataStore
        guard let context = dataStore?.container.container?.viewContext else {
            fatalError("Context need to exist to run the app")
        }
        let contentView = ContentView(interactor: interactor, context: context).environmentObject(contentViewModel)

        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = UIHostingController(rootView: contentView)
            self.window = window
            window.makeKeyAndVisible()
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) { }
    func sceneDidBecomeActive(_ scene: UIScene) { }
    func sceneWillResignActive(_ scene: UIScene) { }
    func sceneWillEnterForeground(_ scene: UIScene) { }
    func sceneDidEnterBackground(_ scene: UIScene) { }
}
