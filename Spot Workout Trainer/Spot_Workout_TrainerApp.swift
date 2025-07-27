//
//  Spot_Workout_TrainerApp.swift
//  Spot Workout Trainer
//
//  Created by Calvin Smith on 7/26/25.
//

import SwiftUI
#if os(macOS)
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}
#endif

@main
struct Spot_Workout_TrainerApp: App {
    #if os(macOS)
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    #endif
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
