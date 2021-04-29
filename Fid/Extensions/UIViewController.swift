//
//  UIViewController.swift
//  Fid
//
//  Created by CROCODILE on 20.01.2021.
//

import Foundation
import UIKit
import RSLoadingView

extension UIViewController {
    
    func showLoadingView() {
      let loadingView = RSLoadingView(effectType: RSLoadingView.Effect.twins)
      loadingView.showOnKeyWindow()
    }

    func hideLoadingView() {
      RSLoadingView.hideFromKeyWindow()
    }
}

extension UINavigationController {

    func containsViewController(ofKind kind: AnyClass) -> Bool {
        return self.viewControllers.contains(where: { $0.isKind(of: kind) })
    }

    func popPushToVC(ofKind kind: AnyClass, pushController: UIViewController) {
        if containsViewController(ofKind: kind) {
            for controller in self.viewControllers {
                if controller.isKind(of: kind) {
                    popToViewController(controller, animated: true)
                    break
                }
            }
        } else {
            pushViewController(pushController, animated: true)
        }
    }
}
