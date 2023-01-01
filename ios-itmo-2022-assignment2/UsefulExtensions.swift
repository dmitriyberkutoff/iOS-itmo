//
//  UsefulExtensions.swift
//  ios-itmo-2022-assignment2
//
//  Created by mac on 25.12.2022.
//

import UIKit

extension UIColor {
    func image(_ size: CGSize = CGSize(width: 1, height: 1)) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { rendererContext in
            self.setFill()
            rendererContext.fill(CGRect(origin: .zero, size: size))
        }
    }
}

extension UIApplication {
    var keyWindow: UIWindow? {
        return UIApplication.shared.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .first(where: { $0 is UIWindowScene })
            .flatMap({ $0 as? UIWindowScene })?.windows
            .first(where: \.isKeyWindow)
    }
}

enum Coordinator {
  static func topViewController(_ viewController: UIViewController? = nil) -> UIViewController? {
      let vc = viewController ?? UIApplication.shared.keyWindow?.rootViewController
    if let navigationController = vc as? UINavigationController {
      return topViewController(navigationController.topViewController)
    } else if let tabBarController = vc as? UITabBarController {
      return tabBarController.presentedViewController != nil ? topViewController(tabBarController.presentedViewController) : topViewController(tabBarController.selectedViewController)
      
    } else if let presentedViewController = vc?.presentedViewController {
      return topViewController(presentedViewController)
    }
    return vc
  }
}
