//
//  KanjiKanaTrainerApp.swift
//  KanjiKanaTrainer
//
//  Created by Zahirudeen Premji on 10/16/25.
//
//
//import SwiftUI
//
//@main
//struct KanjiKanaTrainerApp: App {
//    var body: some Scene {
//        WindowGroup {
//            ContentView()
//        }
//    }
//}

import SwiftUI

@main
struct KanjiKanaTrainerApp: App {
    @StateObject private var env = AppEnvironment.live()
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(env)
        }
    }
}
