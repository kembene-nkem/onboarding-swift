//
//  File.swift
//  
//
//  Created by Kembene Nkem on 7/26/22.
//

import Foundation
import UIKit

extension UIFont {
    public func step(by: CGFloat = 1)-> UIFont? {
        return UIFont(name: self.fontName, size: self.pointSize + (2.0 * by))
    }
}
