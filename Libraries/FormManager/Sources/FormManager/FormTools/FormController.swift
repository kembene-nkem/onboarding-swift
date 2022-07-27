//
//  File.swift
//  
//
//  Created by Kembene Nkem on 7/26/22.
//

import Foundation
import Core

public enum FieldChangeValidationMode {
    case onlyField
    case allBeforeField
    case allFields
}

public class FormController: CoreDisposable {
    let form: FormBuilder
    var cachedValues: [String: Any?] = [:]
    let validatorProvider: FieldValidatorProvider
    public var validationMode: FieldChangeValidationMode = .onlyField
    
    init(builder: FormBuilder) {
        self.form = builder
        validatorProvider = FieldValidatorProvider(manager: builder.manager)
    }
    
    open func getFieldValue(fieldName: String, forcePull: Bool = false)-> Any? {
        if cachedValues.index(forKey: fieldName) != nil && forcePull == false{
            return cachedValues[fieldName] ?? nil
        }
        else{
            let value = form.findField(withName: fieldName)?.getFieldValue()
            cachedValues[fieldName] = value
            return value
        }
    }
    
    open func resetFields() {
        self.cachedValues = [:]
    }
    
    open func rebindToFields() {
        self.form.forEach { (field) in
            validatorProvider.addDefaultValidation(field: field)
            field += self
        }
    }
    
    public func dispose() {
        self.form.forEach { field in
            field -= self
        }
        resetFields()
    }
    
    func validateField(field: FormField, value: Any?)-> String? {
        let resourceLoader: BundleResourceLoader? = (field.formTheme as? FormBundlePoweredResourceLoader) ?? form.manager.resourceLoader()
        if let error = validatorProvider.validateAgainstField(fieldName: field.fieldName, value: value, resourceLoader: resourceLoader){
            return error
        }
        return nil
    }
    
    open func valid(field: FormField, forceShowError: Bool = false)-> Bool {
        if let fieldValue = field.getFieldValue() {
            if let valueString = fieldValue as? String {
                if let error_message = self.validateField(field: field, value: valueString) {
                    if field.displayValidationErrorMessage {
                        field.showErrorMessage(error_message, forceShowError: forceShowError)
                    }
                    return false
                }
            }
            else if let array = fieldValue as? Array<Any> {
                for value in array {
                    if let error_message = self.validateField(field: field, value: value) {
                        if field.displayValidationErrorMessage {
                            field.showErrorMessage(error_message, forceShowError: forceShowError)
                        }
                        return false
                    }
                }
            }
            else {
                if let error_message = self.validateField(field: field, value: fieldValue) {
                    if field.displayValidationErrorMessage {
                        field.showErrorMessage(error_message, forceShowError: forceShowError)
                    }
                    return false
                }
            }
        }
        else {
            if let error_message = self.validateField(field: field, value: nil) {
                if field.displayValidationErrorMessage {
                    field.showErrorMessage(error_message, forceShowError: forceShowError)
                }
                return false
            }
        }
        field.hideErrorMessage()
        return true
    }
    
    open func validateForm()-> Bool {
        var isValue = true
        form.forEach { (field) in
            cachedValues[field.fieldName] = field.getFieldValue()
            let valid = self.valid(field: field, forceShowError: true)
            if !valid {
                isValue = false
            }
        }
        return isValue
    }
    
    func getValidatorInfo(forField name: String, validatorName: String)-> ValidatorState?{
        return validatorProvider.fieldValidator[name]?.first(where: {$0.name == validatorName})
    }
    
    func validateInclusivelyFieldsBefore(field: FormField) {
        var hasHitField = false
        form.forEach { (fieldItem) in
            if hasHitField == false {
                let _ = doPerformFieldValidationOnChange(field: fieldItem)
                hasHitField = field.fieldName == fieldItem.fieldName
            }
        }
    }
    
    fileprivate func doPerformFieldValidationOnChange(field: FormField)-> Bool {
        cachedValues[field.fieldName] = field.getFieldValue()
        if field.validateOnFieldChange {
            return self.valid(field: field, forceShowError: true)
        }
        return true
    }
}

extension FormController: FieldValueChangeDelegate{
    public func fieldValueDidChange(field: FormField) {
        switch validationMode {
        case .onlyField:
            let _ = doPerformFieldValidationOnChange(field: field)
        case .allBeforeField:
            validateInclusivelyFieldsBefore(field: field)
        case .allFields:
            let _ = validateForm()
        }
    }
}
