//
//  OnBoardingComponent.swift
//  DepositsOnboarding
//
//  Created by Kembene Nkem on 7/26/22.
//

import Foundation
import FormManager
import OnBoardingComponent

class OnBoardingComponent: ConfigurableComponent{
    static var shared: OnBoardingComponentProvider!
    /// Prepares the onboarding component resources
    func setupComponent() {
        /// We are going to use a different form manager for the forms build by the onboarding component its resources will be prefixed by ob_fm__
        let theming = FormBundlePoweredResourceLoader(prefix: "ob_fm__", bundle: Bundle.main, settingsFile: ConfigurationFiles.generalAppConfig.rawValue)
        let resources = theming.getResources()
        
        resources.Asset.backgroundColor.replaceWith(name: AppResource.backgroundColor.rawValue)
        resources.Asset.primaryColor.replaceWith(name: AppResource.primaryColor.rawValue)
        resources.Asset.borderColor.replaceWith(name: AppResource.borderColor.rawValue)
        resources.Asset.textColor.replaceWith(name: AppResource.textColor.rawValue)
        
        let manager = FormManager(theme: theming, resourceLoader: theming, labelPositioning: .topLeft)
        manager.registerValidator(validator: RequiredValidator())
        manager.registerValidator(validator: NumericValidator())
        manager.registerFormRenders(renderer: BottomErrorFieldItemRenderer())
        manager.registerFormatters(formatter: UnderLineBorderFormatter())
        
        let resourceLoader = OnboardingComponentResourceLoader(prefix: "onboarding__", bundle: Bundle.main, settingsFile: ConfigurationFiles.generalAppConfig.rawValue)
        let onBoardingResource = resourceLoader.getResources()
        
        onBoardingResource.Asset.backgroundColor.replaceWith(name: AppResource.backgroundColor.rawValue)
        onBoardingResource.Asset.primaryColor.replaceWith(name: AppResource.primaryColor.rawValue)
        onBoardingResource.Asset.borderColor.replaceWith(name: AppResource.borderColor.rawValue)
        onBoardingResource.Asset.textColor.replaceWith(name: AppResource.textColor.rawValue)
        
        
        OnBoardingComponent.shared = OnBoardingComponentProvider(formManager: manager, resourceLoader: resourceLoader)
        
    }
}
