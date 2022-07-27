//
//  File.swift
//  
//
//  Created by Kembene Nkem on 7/27/22.
//

import Foundation
import UIKit
import Core

class DataEntryViewController: BaseOnboardingViewController, HasCustomView {
    
    typealias CustomView = DataEntryControllerPresenter
    
    var viewModel: DataEntryViewModel?
    var onboardingFlowViewModel: OnboardingFlowViewModel?
    
    
    override func loadView() {
        /// inject presenter's dependencies
        let theView = DataEntryControllerPresenter()
        theView.theme = onboardingFlowViewModel?.theme
        theView.resources = onboardingFlowViewModel?.resources
        theView.config = onboardingFlowViewModel?.configuration
        theView.resourceLoader = onboardingFlowViewModel?.resourceLoader
        theView.prepareView()
        view = theView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        /// ask the presenter to build and render the form unto itself
        customView.attachForm(formType: viewModel?.category, form: viewModel?.viewModelForm)
        customView.onFormSubmitted = {values in
            if let category = self.viewModel?.category {
                self.onboardingFlowViewModel?.saveEnteredData(forCategory: category, data: values)
                self.onboardingFlowViewModel?.gotoNextForm(currentViewController: self)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let category = viewModel?.category{
            onboardingFlowViewModel?.syncDisplayedFormWithCurrentIndex(formType: category)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isMovingFromParent {
            viewModel = nil
            onboardingFlowViewModel = nil
        }
    }
}
