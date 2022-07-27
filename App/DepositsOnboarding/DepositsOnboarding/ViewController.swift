//
//  ViewController.swift
//  DepositsOnboarding
//
//  Created by Kembene Nkem on 7/25/22.
//

import UIKit
import FormManager
import OnBoardingComponent

class BaseViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap)
        self.view.backgroundColor = ApplicationUtility.currentTheme?.backgroundColor
    }
}

class ViewController: BaseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addTriggerButton()
        
    }
    
    @objc func startOnBoarding() {
        let formsToRender = DataCategory.allCases
        
        ///initiates the call to the onboarding component, register itself as a delegate (so it can add, remove or edit fields before they are rendered
        /// It also registers a callback which will be invoke after all forms are deemed valid
        OnBoardingComponent.shared.beginOnBoardingFlow(
            navigationController: self, formsToRender: formsToRender,
            delegate: self, onDataCollected: self.onFieldsCollectedFromOnboarding)
    }
    
    func onFieldsCollectedFromOnboarding(_ values: OnBoardingCollectedData){
        let viewModel = OnBoardingCollectedDataOverviewViewModel()
        let controller = OnboardingOverviewViewController()
        controller.viewModel = viewModel
        controller.onboardingData = values
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func addTriggerButton(){
        let button = UIButton(type: UIButton.ButtonType.system)
        button.setTitle("Start On Boarding", for: .normal)
        
        self.view.addSubview(button)
        button.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(200)
            make.height.equalTo(50)
        }
        button.layer.cornerRadius = 25
        button.addTarget(self, action: #selector(startOnBoarding), for: .touchUpInside)
        
        button.backgroundColor = ApplicationUtility.currentTheme?.primaryColor
        button.tintColor = ApplicationUtility.currentTheme?.backgroundColor
    }
    
}


extension ViewController: FormDelegate {
    func beforeFieldsAdded(form: Form) {
        
    }
    
    func afterFieldsAdded(form: Form) {
        // let's add a 'Designation' field to the top on the personal information for
        if let personalForm = form as? PersonalInformationForm {
            if let row = personalForm.builder.findRow(forFieldWithName: PersonalInformationForm.fieldFirstName){
                let field = SelectField(fieldName: "designation", label: "Designation", order: 5.0)
                field.placeholder = "Select your title"
                field.items = ["Mr", "Mrs"]
                row.addField(field: field)
            }
        }
    }
}
