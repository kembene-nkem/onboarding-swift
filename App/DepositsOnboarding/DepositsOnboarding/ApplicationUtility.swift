//
//  ApplicationUtility.swift
//  DepositsOnboarding
//
//  Created by Kembene Nkem on 7/26/22.
//

import Foundation
import FormManager
import Core

func appConfig()-> ApplicationConfig?{
    return ApplicationUtility.appConfig
}

func appTheme()-> ApplicationTheming? {
    return ApplicationUtility.currentTheme
}

func resourceLoader()-> BundleResourceLoader?{
    return ApplicationUtility.resourceFinder
}

class ApplicationUtility{
    
    fileprivate static var currentSetTheme: ApplicationTheming?
    
    static var resourceProvider: ApplicationBundlePoweredResourceLoader = {
        return ApplicationBundlePoweredResourceLoader()
    }()
    
    static var resourceFinder: BundleResourceLoader?{
        return resourceProvider
    }
    
    static var appConfig: ApplicationConfig? {
        return resourceProvider.configuration
    }
    
    static var currentTheme: ApplicationTheming? {
        if currentSetTheme == nil {
            currentSetTheme = ApplicationTheming(resourceLoader: resourceProvider, config: appConfig)
        }
        return currentSetTheme
    }
}

extension String {
    var appResource: BundleResourceLoader?{
        return ApplicationUtility.resourceFinder
    }
    
    func appLocalized(parameters: [String: String]? = nil)-> String{
        return appResource?.localized(self, comment: "", replacements: parameters) ?? self
    }
}
