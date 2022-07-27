//
//  OnboardingOverviewViewModel.swift
//  DepositsOnboarding
//
//  Created by Kembene Nkem on 7/27/22.
//

import Foundation
import OnBoardingComponent
import Core

protocol OnboardingOverviewViewModel {
    func prepareDataForPresenter(rawData: Any?)-> OnboardingDataPresenterData?
}

class OnBoardingCollectedDataOverviewViewModel: OnboardingOverviewViewModel {
    
    func prepareDataForPresenter(rawData: Any?)-> OnboardingDataPresenterData? {
        if let data = rawData as? OnBoardingCollectedData{
            let dataPackage = OnboardingDataPresenterData()
            data.enumerated().forEach { collected in
                let key = collected.element.key
                let titleKey = "onboarding_summary_header_\(key.rawValue.lowercased())"
                let title = resourceLoader()?.localized(titleKey)
                
                let rows: [DefaultSimpleDataItem] = collected.element.value.enumerated().map { enteredData in
                    var result = "-"
                    if let entry = enteredData.element.value{
                        result = String(describing: entry)
                    }
                    return DefaultSimpleDataItem(title: enteredData.element.key, description: result)
                }
                dataPackage.sections.append(OnboardingDataPresenterSection(sectionTitle: title, inputedData: rows))
            }
            return dataPackage
        }
        return nil
    }
    
}
