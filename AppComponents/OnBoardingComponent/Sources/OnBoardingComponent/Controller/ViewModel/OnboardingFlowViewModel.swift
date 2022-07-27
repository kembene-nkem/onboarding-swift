//
//  File.swift
//  
//
//  Created by Kembene Nkem on 7/27/22.
//

import Foundation
import FormManager
import UIKit
import Core

public enum DataCategory: String, CaseIterable{
    case personal = "personal"
    case contactUs = "contact_us"
    case login = "login"
}

public typealias OnBoardingCollectedData = [DataCategory: [String: Any?]]

open class OnboardingFlowViewModel {
    let formManager: FormManager
    
    var formsToRender: [DataCategory] = []
    var formDelegate: FormDelegate? = nil
    var currentFormIndex: Int = -1
    
    var resources: __OnboardingResource?
    var resourceLoader: BundleResourceLoader?
    var theme: OnboardingTheming?
    var configuration: OnboardingComponentConfiguration?
    var afterCollectionCallback: ValueChangeCallback<OnBoardingCollectedData>?
    
    var formData: OnBoardingCollectedData = [:]
    
    public init(formManager: FormManager, formsToRender: [DataCategory]){
        self.formManager = formManager
        self.formsToRender = formsToRender
    }
    
    func gotoNextForm(currentViewController: UIViewController){
        let nextFormIndex = currentFormIndex + 1
        var hasNext = false
        if nextFormIndex < formsToRender.count {
            if let formModel = self.prepareNextForm(forIndexAt: nextFormIndex){
                self.currentFormIndex = nextFormIndex
                /// ideally this should not be done here. Would prefer to have a centralized routing system that can instantiate a controller and insert all its dependencies before. But for sake of time, let's have it here
                let viewController = DataEntryViewController()
                viewController.viewModel = formModel
                viewController.onboardingFlowViewModel = self
                hasNext = true
                currentViewController.navigationController?.pushViewController(viewController, animated: true)
            }
        }
        if !hasNext {
            afterCollectionCallback?(formData)
        }
    }
    
    func saveEnteredData(forCategory: DataCategory, data: [String: Any?]){
        /// this is a crude way of doing this. Can actually do better
        formData[forCategory] = data
    }
    
    func syncDisplayedFormWithCurrentIndex(formType: DataCategory) {
        if let index = self.formsToRender.firstIndex(of: formType){
            self.currentFormIndex = index
        }
    }
    
    fileprivate func prepareNextForm(forIndexAt: Int)-> DataEntryViewModel?{
        let formType = formsToRender[forIndexAt]
        var form: OnBoardingBaseForm? = nil
        switch formType {
        case .personal:
            form = PersonalInformationForm(manager: formManager)
        case .contactUs:
            form = ContactUsForm(manager: formManager)
        case .login:
            form = LoginForm(manager: formManager)
        }
        
        if let form = form {
            
            form.resourceLoader = resourceLoader
            form.resources = resources
            
            if let delegate = formDelegate {
                form += delegate
            }
            return DataEntryViewModel(form: form, category: formType)
        }
        
        return nil
    }
}
