//
//  dang_dangApp.swift
//  dang_dang
//
//  Created by user on 2024/05/20.
//

import SwiftUI

@main
struct dang_dangApp: App {
    var body: some Scene {
            WindowGroup {
                ContentView()
                    //.onAppear {
                    //    showInitialStoryboard()
                    //}
            }
        }
    /*
    func showInitialStoryboard() {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                if let initialViewController = storyboard.instantiateInitialViewController() {
                    window.rootViewController = initialViewController
                    window.makeKeyAndVisible()
                }
            }
        }
     */
}
