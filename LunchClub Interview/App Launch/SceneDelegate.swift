//
//  SceneDelegate.swift
//  LunchClub Interview
//
//  Created by Austin Feight on 8/10/21.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

  var window: UIWindow?
  var coordinator: ContactListCoordinatorType = ContactListCoordinator()

  func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    guard let scene = (scene as? UIWindowScene) else { return }

    let window = UIWindow(frame: UIScreen.main.bounds)
    window.windowScene = scene
    window.makeKeyAndVisible()
    self.window = window

    window.rootViewController = coordinator.start()
  }
}
