//
//  File.swift
//  
//
//  Created by Kembene Nkem on 7/27/22.
//

import Foundation
import FormManager
import Core

open class OnBoardingBaseForm: Form {
    var resources: __OnboardingResource?
    var resourceLoader: BundleResourceLoader?
    
    var fieldTexts: OB_I18N_Field {
        return resources!.I18N.Fields
    }
}
