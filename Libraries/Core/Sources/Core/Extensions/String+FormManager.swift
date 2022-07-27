//
//  File.swift
//  
//
//  Created by Kembene Nkem on 7/25/22.
//

import Foundation

extension String {
    public func hasText()-> Bool {
        return self.trimmingCharacters(in: .whitespacesAndNewlines).count > 0
    }
}
