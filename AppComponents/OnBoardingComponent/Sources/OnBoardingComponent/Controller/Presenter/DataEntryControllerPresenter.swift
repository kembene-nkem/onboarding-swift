//
//  File.swift
//  
//
//  Created by Kembene Nkem on 7/27/22.
//

import Foundation
import UIKit
import FormManager
import Core

class DataEntryControllerPresenter: UIView{
    

    
    var nextButton = UIButton(type: .system)
    var titleLabel = UILabel(frame: .zero)
    var formHolder = UIView(frame: .zero)
    
    var theme: OnboardingTheming?
    var resources: __OnboardingResource?
    var resourceLoader: BundleResourceLoader?
    var config: OnboardingComponentConfiguration?
    
    var onFormSubmitted: ValueChangeCallback<[String: Any?]>?
    
    func prepareView() {
        self.backgroundColor = theme?.backgroundColor
        self.addSubview(nextButton)
        self.addSubview(titleLabel)
        self.addSubview(formHolder)

        formHolder.backgroundColor = UIColor.clear

        let hEdge = config?.horizontalEdge ?? 0
        let VEdge = config?.verticalEdge ?? 0
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(hEdge)
            if #available(iOS 11.0, *) {
                make.top.equalTo(self.safeAreaLayoutGuide.snp.top).offset(VEdge)
            } else {
                make.top.equalToSuperview().offset(VEdge)
            }
            make.trailing.equalToSuperview().offset( 0 - hEdge)
        }
        formHolder.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel)
            make.trailing.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
        }
        nextButton.snp.makeConstraints { make in
            make.trailing.equalTo(titleLabel)
            make.leading.equalTo(titleLabel)
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(self.safeAreaLayoutGuide.snp.bottom).offset(0 - hEdge)
            } else {
                make.bottom.equalToSuperview().offset(0 - hEdge)
            }
            make.height.equalTo(40)
            make.top.equalTo(formHolder.snp.bottom).offset(10)
        }

        titleLabel.numberOfLines = 0
        titleLabel.font = theme?.baseFont?.step(by: 2)

        nextButton.layer.cornerRadius = theme?.borderRadius ?? 0
        nextButton.tintColor = theme?.backgroundColor
        nextButton.backgroundColor = theme?.primaryColor
        let buttonText = resourceLoader?.localized(resources?.I18N.Generic.next ?? "")
        nextButton.setTitle(buttonText, for: .normal)
        
    }
    
    func attachForm(formType: DataCategory?, form: Form?) {
        form?.onSubmitButtonClicked = { values in
            self.onFormSubmitted?(values)
        }
        form?.attachToButton(button: nextButton)
        let titleKey = "controller_title_\(formType?.rawValue.lowercased() ?? "_none")"
        titleLabel.text = resourceLoader?.localized(titleKey)
        /// - Note: It might be better to prepare the form here prepareForm() is what allows the fields to be populated
        ///  and then build the form ui on a later time
        if let formFieldView = form?.prepareForm().buildFormView(){
            self.formHolder.addSubview(formFieldView)
            formFieldView.snp.makeConstraints({ make in
                make.leading.equalToSuperview()
                make.trailing.equalToSuperview()
                make.top.equalToSuperview()
                make.bottom.equalToSuperview()
            })
        }
        
    }
    
}
