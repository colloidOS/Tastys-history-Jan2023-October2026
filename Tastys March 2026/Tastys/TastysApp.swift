//
//  TastysApp.swift
//  Tastys
//
//  Created by Nnagoziem Collins Okegbe on 07/12/2025.
//

import SwiftUI

@main
struct TastysApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    init() {
        UITableView.appearance().backgroundColor = .white
        UITableViewCell.appearance().backgroundColor = .white
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.light)
        }
    }
}
