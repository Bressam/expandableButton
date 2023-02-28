//
//  UIButton+Extension.swift
//  ExpandableButton
//
//  Created by Giovanne Bressam on 27/02/23.
//

import UIKit

extension UIButton {
    func copyButton() -> UIButton? {
        guard let newButton = try? self.copyView() as? UIButton else { return nil }
        newButton.frame = self.bounds
        newButton.layer.cornerRadius = self.layer.cornerRadius
        newButton.layer.masksToBounds = self.layer.masksToBounds
        return newButton
    }
//    
//    func centerButtonAndImageWiths(spacing: CGFloat) {
//        let insetAmount: CGFloat = spacing/2.0;
//        imageEdgeInsets = UIEdgeInsets(top: 0, left: -insetAmount, bottom: 0, right: insetAmount);
//        titleEdgeInsets = UIEdgeInsets(top: 0, left: insetAmount, bottom: 0, right: -insetAmount);
//        contentEdgeInsets = UIEdgeInsets(top: 0, left: insetAmount, bottom: 0, right: insetAmount);
//    }
}
