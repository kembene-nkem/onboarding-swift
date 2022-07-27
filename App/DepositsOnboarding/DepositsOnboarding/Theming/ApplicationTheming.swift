//
//  ApplicationTheming.swift
//  DepositsOnboarding
//
//  Created by Kembene Nkem on 7/26/22.
//

import Foundation
import UIKit
import FormManager
import Core

public class ApplicationBundlePoweredResourceLoader: BundlePoweredResourceLoader {
    
    
    var config: ApplicationConfig?
    var configuration: ApplicationConfig?{
        return config
    }
    
    init() {
        super.init(bundle: Bundle.main, settingsFile: ConfigurationFiles.generalAppConfig.rawValue, fallbackSettingsFile: nil, fallbackBundle: nil)
        self.config = self.loadConfiguration(type: ApplicationConfig.self)
    }
}

class ApplicationTheming{
    let backgroundColor: UIColor?
    let borderColor: UIColor?
    let textColorColor: UIColor?
    let primaryColor: UIColor?
    let baseFont: UIFont?
    
    init(resourceLoader: BundleResourceLoader, config: ApplicationConfig?) {
        backgroundColor = resourceLoader.color(AppResource.backgroundColor.rawValue)
        borderColor = resourceLoader.color(AppResource.borderColor.rawValue)
        textColorColor = resourceLoader.color(AppResource.textColor.rawValue)
        primaryColor = resourceLoader.color(AppResource.primaryColor.rawValue)
        baseFont = ResourceName.labelFont(fontName: config?.defaultFontName)        
        self.applyTheme()
    }
    func applyTheme() {
        let sharedApplication = UIApplication.shared
        sharedApplication.delegate?.window??.tintColor = self.primaryColor
    }
}
