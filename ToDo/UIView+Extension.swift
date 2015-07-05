//
//  UIView+Extension.swift
//  ToDo
//
//  Created by David Pirih on 05.07.15.
//  Copyright © 2015 Piri-Piri. All rights reserved.
//

import UIKit

extension UIView {
    
    var viewController: UIViewController? {
        return traverseResponderChainToFindViewController()
    }
    
    private func traverseResponderChainToFindViewController() -> UIViewController? {
        if let responder = nextResponder() as? UIViewController {
            return responder
        }
        
        if let responder = nextResponder() as? UIView {
            return responder.traverseResponderChainToFindViewController()
        }
        
        return nil
    }

}
