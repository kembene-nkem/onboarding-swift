//
//  File.swift
//  
//
//  Created by Kembene Nkem on 7/27/22.
//

import Foundation
import Core


public struct __FM_Asset {
    public let backgroundColor = ResourceName(resourceName: "backgroundColor")
    public let borderColor = ResourceName(resourceName: "borderColor")
    public let textColor = ResourceName(resourceName: "textColor")
    public let primaryColor = ResourceName(resourceName: "primaryColor")
    public let imageSelectPicker = ResourceName(resourceName: "select_picker")
}

public struct __FM_Config_Keys {
    public static let fontName = "font_name"    
    public static let borderRadius = "field_border_radius"
    public static let borderWidth = "field_border_width"
}

public struct FM_I18N{
    public struct Validator{
        public static let fieldRequired = "error_required_field"
        public static let fieldMinCount = "error_min_field_count"
        public static let fieldMaxCount = "error_max_field_count"
        public static let fieldMinValue = "error_min_field_value"
        public static let fieldMaxValue = "error_max_field_value"
        public static let fieldInvalidEntry = "error_invalid_field_entry"
    }
}

public struct __FM_Resource {
    public let Asset = __FM_Asset()
    public let I18N = FM_I18N()
    public let ConfigKey = __FM_Config_Keys()
}
