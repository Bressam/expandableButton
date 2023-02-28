//
//  UIView+Extension.swift
//  ExpandableButton
//
//  Created by Giovanne Bressam on 27/02/23.
//

import UIKit

extension UIView {
    func fadeIn(_ duration: TimeInterval? = 0.2, onCompletion: ((Bool) -> Void)? = nil) {
        self.alpha = 0
        self.isHidden = false
        UIView.animate(withDuration: duration!,
                       animations: { self.alpha = 1 },
                       completion: { (hasCompleted: Bool) in
            if !hasCompleted {
                self.alpha = 1
                self.isHidden = true
            }
            onCompletion?(hasCompleted)
        })
    }
    
    func fadeOut(_ duration: TimeInterval? = 0.2, onCompletion: ((Bool) -> Void)? = nil) {
        UIView.animate(withDuration: duration!,
                       animations: { self.alpha = 0 },
                       completion: { (hasCompleted: Bool) in
            if !hasCompleted {
                self.alpha = 0
                self.isHidden = true
            }
            onCompletion?(hasCompleted)
        })
    }
}
