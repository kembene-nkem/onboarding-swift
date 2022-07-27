//
//  File.swift
//  
//
//  Created by Kembene Nkem on 7/27/22.
//

import Foundation
import Core

/**
 Resources that can be loaded from the Bundles .xcassets file. This include things like named images, named color, etc
 */
public struct __OB_Asset {
    public let backgroundColor = ResourceName(resourceName: "backgroundColor")
    public let borderColor = ResourceName(resourceName: "borderColor")
    public let textColor = ResourceName(resourceName: "textColor")
    public let primaryColor = ResourceName(resourceName: "primaryColor")    
}

/// Keys for localized controller title. Library consumers can create entries with this key in their localization file
public struct OB_I18N_Controller{
    public let titlePersonal = "personal_form_controller_title"
    public let titleContact = "contact_us_form_controller_title"
    public let titleLogin = "login_form_controller_title"
}

/// Keys for general text
public struct OB_I18N_General{
    public let next = "next"
}

/// localized string keys used while rendering the forms contained in this library
public struct OB_I18N_Field{
    public let textFirstName = "first_name"
    public let textLastName = "last_name"
    public let textMiddleName = "middle_name"
    public let textPhoneNumber = "phone_number"
    public let textEmail = "email"
    public let textPassword = "password"
}

public struct OB_I18N{
    public let Controller = OB_I18N_Controller()
    public let Generic = OB_I18N_General()
    public let Fields = OB_I18N_Field()
}

/// Keys that can be used to load data stored in plist file
public struct __OB_Config_Keys {
    public static let fontName = "font_name"
    public static let borderRadius = "border_radius"
    public static let borderWidth = "border_width"
    public static let controllerHorizontalEdge = "controller_horizontal_edge"
    public static let controllerVerticalEdge = "controller_vertical_edge"
}

public struct __OnboardingResource {
    public let Asset = __OB_Asset()
    public let I18N = OB_I18N()
}
