//
//  swipeBackExtension.swift
//  Tastys
//
//  Created by Nnagoziem Collins Okegbe on 07/01/2026.
//

import SwiftUI
import UIKit

extension View {
    func enableSwipeBack() -> some View {
        self.onAppear {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let window = windowScene.windows.first,
                  let navigationController = window.rootViewController as? UINavigationController ??
                                              findNavigationController(in: window.rootViewController) else {
                return
            }
            
            navigationController.interactivePopGestureRecognizer?.isEnabled = true
            navigationController.interactivePopGestureRecognizer?.delegate = nil
        }
    }
    
    private func findNavigationController(in viewController: UIViewController?) -> UINavigationController? {
        guard let viewController = viewController else { return nil }
        if let navController = viewController as? UINavigationController { return navController }
        for child in viewController.children {
            if let found = findNavigationController(in: child) { return found }
        }
        return nil
    }
}
