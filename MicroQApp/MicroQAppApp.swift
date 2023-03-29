//
//  MicroQAppApp.swift
//  MicroQApp
//
//  Created by Ryan D on 9/16/22.
//

import SwiftUI
import Firebase

@main
struct MicroQAppApp: App {
    init() {
        FirebaseApp.configure()
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
