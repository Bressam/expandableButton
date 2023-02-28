//
//  NSObject+Extension.swift
//  ExpandableButton
//
//  Created by Giovanne Bressam on 27/02/23.
//

import Foundation

extension NSObject {
    func copyView<T:NSObject>() throws -> T? {
        let data = try NSKeyedArchiver.archivedData(withRootObject:self, requiringSecureCoding:false)
        return try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? T
    }
}
