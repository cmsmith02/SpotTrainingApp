//
//  Spot_Workout_TrainerApp.swift
//  Spot Workout Trainer
//
//  Created by Calvin Smith on 7/26/25.
//

import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}

@main
struct Spot_Workout_TrainerApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
