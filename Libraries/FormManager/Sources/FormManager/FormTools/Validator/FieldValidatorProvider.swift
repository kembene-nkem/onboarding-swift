//
//  File.swift
//  
//
//  Created by Kembene Nkem on 7/27/22.
//

import Foundation
import Core

public protocol FieldValidator {
    func getValidatorName()-> String
    func validate(value: Any?, checkData: Any?, resourceLoader: BundleResourceLoader?, errorKey: String?)-> String?
}

extension FieldValidator{
    public func generateError(messageKey: String, replacements: [String: String]? = nil, resourceLoader: BundleResourceLoader?)-> String{
        return resourceLoader?.localized(messageKey, replacements: replacements) ?? messageKey
    }
}

open class RequiredValidator: FieldValidator {
    public static let name = "RequiredValidator"
    
    public init(){}
    
    public func getValidatorName()-> String {
        return RequiredValidator.name
    }
    
    open func validate(value: Any?, checkData: Any?, resourceLoader: BundleResourceLoader?, errorKey: String?)-> String?{
        let error = resourceLoader?.localized(errorKey ?? FM_I18N.Validator.fieldRequired) ?? errorKey ?? FM_I18N.Validator.fieldRequired
        if value == nil {
            return error
        }
        else if let string = value as? String, string.hasText() == false{
            return error
        }
        return nil
    }
}

public enum NumericValidatorType{
    case minValue
    case maxValue
    case minCount
    case maxCount
}

public struct NumericValidatorData{
    public var threshHold: Any
    public var validatorType: NumericValidatorType
    public init(threshold: Any, type: NumericValidatorType){
        self.threshHold = threshold
        self.validatorType = type
    }
}

open class NumericValidator: FieldValidator {
    public static let name = "NumericValidator"
    public init(){}
    
    public func getValidatorName()-> String {
        return NumericValidator.name
    }
    
    open func validate(value: Any?, checkData: Any?, resourceLoader: BundleResourceLoader?, errorKey: String?)-> String?{
        if let validationInfo = checkData as? NumericValidatorData {
            let type = validationInfo.validatorType
            switch type {
            case .maxValue, .minValue:
                let expectedCount = Double("\(validationInfo.threshHold)")!
                if let testValue = Double("\(value ?? "")"){
                    let dataDictionary: [String:String] = ["expected": "\(validationInfo.threshHold)", "entered": "\(value ?? "")"]
                    if type == .maxValue && testValue > expectedCount {
                        return generateError(messageKey: errorKey ?? FM_I18N.Validator.fieldMaxValue, replacements: dataDictionary, resourceLoader: resourceLoader)
                    }
                    else if type == .minValue && testValue < expectedCount {
                        return generateError(messageKey: errorKey ?? FM_I18N.Validator.fieldMinValue, replacements: dataDictionary, resourceLoader: resourceLoader)
                    }
                }
                else{
                    return generateError(messageKey: errorKey ?? FM_I18N.Validator.fieldInvalidEntry, replacements: nil, resourceLoader: resourceLoader)
                }
                
                
            case .maxCount, .minCount:
                let entered = "\(value ?? "")"
                let expectedCount = Int("\(validationInfo.threshHold)")!
                let testValue = entered.count
                let dataDictionary: [String:String] = ["expected": "\(validationInfo.threshHold)", "entered": "\(testValue)"]
                if type == .maxCount && testValue > expectedCount {
                    return generateError(messageKey: errorKey ?? FM_I18N.Validator.fieldMaxCount, replacements: dataDictionary, resourceLoader: resourceLoader)
                }
                else if type == .minCount && testValue < expectedCount {
                    return generateError(messageKey: errorKey ?? FM_I18N.Validator.fieldMaxCount, replacements: dataDictionary, resourceLoader: resourceLoader)
                }
            }
        }
        return nil
    }
}

class ValidatorState: Equatable{
    var name: String
    var enabled: Bool
    var data: Any?
    var errorMessageKey: String?
    init(name: String, enabled: Bool){
        self.name = name
        self.enabled = enabled
    }
    
    public static func ==(lhs: ValidatorState, rhs: ValidatorState)-> Bool {
        lhs.name == rhs.name
    }
    
}

public class FieldValidatorProvider{
    var validators: [String: FieldValidator] = [:]
    /// list of validators for each field, where the key is the fieldName, and the [String] is a list of validators to be applied to the field, which can be enabled or disabled at any time
    var fieldValidator: [String: [ValidatorState]] = [:]

    public init(manager: FormManager){
        manager.validators.forEach { item in
            validators[item.key] = item.value
        }
    }
    
    public func addDefaultValidation(field: FormField) {
        if field.required {
            registerValidatorForField(field: field, validatorName: RequiredValidator.name, validatorCheckData: nil)
        }
    }
    
    func registerValidator(validator: FieldValidator){
        self.validators[validator.getValidatorName()] = validator
    }
    
    func getValidatorInfo(forField name: String, validatorName: String)-> ValidatorState?{
        return fieldValidator[name]?.first(where: {$0.name == validatorName})
    }
    
    public func registerValidatorForField(field: FormField, validator: FieldValidator, validatorCheckData: Any?){
        registerValidatorForField(field: field, validatorName: validator.getValidatorName(), validatorCheckData: validatorCheckData)
    }
    
    public func registerValidatorForField(field: FormField, validatorName: String, validatorCheckData: Any?, messageKey: String? = nil){
        let fieldName = field.fieldName
        var validators = fieldValidator[fieldName] ?? []
        let state = ValidatorState(name: validatorName, enabled: true)
        if !validators.contains(state) {
            state.data = validatorCheckData
            state.errorMessageKey = messageKey
            validators.append(state)
        }
        fieldValidator[fieldName] = validators
    }
    
    public func enableValidator(forFieldWithName name: String, flag: Bool, validatorName: String){
        if let validators = fieldValidator[name]{
            validators.first(where: {$0.name == validatorName})?.enabled = flag
        }
    }
    
    public func validateAgainstField(fieldName: String, value: Any?, resourceLoader: BundleResourceLoader?)-> String?{
        let validators = self.fieldValidator[fieldName]?.filter({$0.enabled}).map({ (state) -> (FieldValidator, Any?, String?) in
            let validator = self.validators[state.name]
            assert(validator != nil, "No registered validator with name \(state.name) while processing filed \(fieldName)")
            return (validator!, state.data, state.errorMessageKey)
        })
        for validatorItem in (validators ?? []){
            let validator = validatorItem.0
            if let error = validator.validate(value: value, checkData: validatorItem.1, resourceLoader: resourceLoader, errorKey: validatorItem.2){
                return error
            }
        }
        return nil
    }
    
}
