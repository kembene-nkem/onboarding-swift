//
//  ApplicationConfig.swift
//  DepositsOnboarding
//
//  Created by Kembene Nkem on 7/26/22.
//

import Foundation
import FormManager
import Core

enum AppResource: String {
    case backgroundColor = "appBackgroundColor"
    case primaryColor = "appPrimaryColor"
    case borderColor = "appBorderColor"
    case textColor = "appTextColor"
}

struct AppConfigKeys{
    public static let fontName = "font_name"
    public static let borderRadius = "border_radius"
    public static let borderWidth = "border_width"
    public static let controllerHorizontalEdge = "controller_horizontal_edge"
    public static let controllerVerticalEdge = "controller_vertical_edge"
}

enum ConfigurationFiles: String{
    case generalAppConfig = "app_config"
}

public class ApplicationConfig: ResourceBundleConfiguration{
    
    fileprivate var decodingContainer: KeyedDecodingContainer<DynamicKey>?
    fileprivate var defaultDecodingContainer: KeyedDecodingContainer<DynamicKey>?
    
    public var defaultFontName: String?
    public var borderWidth: Double?
    public var borderRadius: Double?
    public var horizontalEdge: Double?
    public var verticalEdge: Double?
    
    
    open override func doPerformDecoding() {
        defaultFontName = string(key: AppConfigKeys.fontName)
        borderRadius = double(key: AppConfigKeys.borderRadius)
        borderWidth = double(key: AppConfigKeys.borderWidth)
        horizontalEdge = double(key: AppConfigKeys.controllerHorizontalEdge)
        verticalEdge = double(key: AppConfigKeys.controllerVerticalEdge)
    }
}
