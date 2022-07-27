//
//  FormManagerComponent.swift
//  DepositsOnboarding
//
//  Created by Kembene Nkem on 7/26/22.
//

import Foundation
import FormManager

class FormManagerComponent: ConfigurableComponent {
    /// Prepares the form manager library
    func setupComponent() {
        let theming = FormBundlePoweredResourceLoader(prefix: "fm_", bundle: Bundle.main, settingsFile: ConfigurationFiles.generalAppConfig.rawValue)
        let resources = theming.getResources()
        
        resources.Asset.backgroundColor.replaceWith(name: AppResource.backgroundColor.rawValue)
        resources.Asset.primaryColor.replaceWith(name: AppResource.primaryColor.rawValue)
        resources.Asset.borderColor.replaceWith(name: AppResource.borderColor.rawValue)
        resources.Asset.textColor.replaceWith(name: AppResource.textColor.rawValue)
        
        let manager = FormManager.configureDefaultManager(theme: theming, resourceLoader: theming, labelPositioning: .topLeft)
        manager.registerValidator(validator: RequiredValidator())
        manager.registerValidator(validator: NumericValidator())
        manager.registerFormRenders(renderer: BottomErrorFieldItemRenderer())
        manager.registerFormatters(formatter: UnderLineBorderFormatter())
    }
    
}
