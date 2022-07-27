//
//  OnboardingOverviewViewController.swift
//  DepositsOnboarding
//
//  Created by Kembene Nkem on 7/27/22.
//

import Foundation
import UIKit
import Core
import OnBoardingComponent

class OnboardingOverviewViewController: BaseViewController, HasCustomView{
    typealias CustomView = OnboardingDataPresenter
    
    var onboardingData: Any?
    var viewModel: OnboardingOverviewViewModel?
    
    override func loadView() {
        let theView = OnboardingDataPresenter()
        theView.preparePresenter()
        self.view = theView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let data = viewModel?.prepareDataForPresenter(rawData: onboardingData){
            customView.renderData(data: data)
        }
    }
    
}
