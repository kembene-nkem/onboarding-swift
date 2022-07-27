//
//  File.swift
//  
//
//  Created by Kembene Nkem on 7/26/22.
//

import Foundation
import UIKit
import Core

public protocol FormDelegate {
    func beforeFieldsAdded(form: Form)
    func afterFieldsAdded(form: Form)
}

open class Form{
    var form: FormBuilder
    var controller: FormController?
    
    public var onSubmitButtonClicked: ValueChangeCallback<[String: Any?]>?
    
    var formDelegate = MulticastDelegate<FormDelegate>()
    
    public var builder: FormBuilder{
        return form
    }
    
    public init(manager: FormManager, fieldUpdater: ValueChangeCallback<(FormField, FormManager?)>? = nil){
        form = FormBuilder(manager: manager, configure: fieldUpdater)
        controller = self.initializeFormController(form: form)
        form += self
    }
    
    public func addField(toRowWithFieldName searchField: String, field: FormField)-> Bool{
        if let row = form.findRow(forFieldWithName: searchField){
            row.addField(field: field)
            return true
        }
        return false
    }
    
    public func addField(field: FormField){
        form.sections.last?.rows.last?.addField(field: field)
    }
    
    open func prepareForm(populateField: ValueChangeCallback<Form>? = nil)-> Form{
        formDelegate |> {delegate in
            delegate.beforeFieldsAdded(form: self)
        }
        self.addFirstField(builder: form)
        populateField?(self)
        formDelegate |> {delegate in
            delegate.afterFieldsAdded(form: self)
        }
        return self
    }
    
    public func attachToButton(button: UIButton){
        button.addTarget(self, action: #selector(onButtonClicked), for: .touchUpInside)
    }
    
    public func submitFields() {
        if isValid() {
            self.onSubmitButtonClicked?(self.getAllFieldValues())
        }
    }
    
    @objc func onButtonClicked() {
        self.submitFields()
    }
    
    public func registerValidator(validator: FieldValidator){
        getController()?.validatorProvider.registerValidator(validator: validator)
    }
    
    public func addFieldValidator(field: FormField, validatorName: String, validatorCheckData: Any? = nil, errorMessageKey: String? = nil){
        getController()?.validatorProvider.registerValidatorForField(field: field, validatorName: validatorName, validatorCheckData: validatorCheckData, messageKey: errorMessageKey)
    }
    
    open func addFirstField(builder: FormBuilder) {
        
    }
    
    func getAllFieldValues()-> [String: Any?] {
        var values: [String: Any?] = [:]        
        self.form.allFields().forEach { (field) in
            let name = field.fieldName
            values[name] = self.getFieldValue(fieldName: name)
        }
        return values
    }
    
    open func getFieldValue(fieldName: String, forcePull: Bool = false)-> Any? {
        return getController()?.getFieldValue(fieldName: fieldName, forcePull: forcePull)
    }
    
    open func getFieldValueAsType<T>(fieldName: String, forcePull: Bool = false)-> T? {
        return getController()?.getFieldValue(fieldName: fieldName, forcePull: forcePull) as? T
    }
    
    open func initializeFormController(form: FormBuilder)-> FormController {
        return FormController(builder: form)
    }
    
    open func isValid()-> Bool {
        return getController()?.validateForm() ?? true
    }
    
    open func getController()-> FormController? {
        return controller
    }
    
    public func buildFormView()-> UIView {
        return form.buildView()
    }
    
    open func dispose() {
        self.form.dispose()
        self.getController()?.dispose()
    }
    
    public static func += (left: Form, delegate: FormDelegate) {
        left.formDelegate += delegate
    }
    
    public static func -=(left: Form, delegate: FormDelegate) {
        left.formDelegate -= delegate
    }
}


extension Form: FormBuildDelegate {
    public func formDidPostBuild(form: FormBuilder) {
        
    }
    
    public func formDidPreBuild(form: FormBuilder) {
        if self.getController() == nil {
            self.controller = self.initializeFormController(form: form)
        }
        self.getController()?.rebindToFields()
    }
    
    public func didDisposeBuiltForm(form: FormBuilder) {
        getController()?.dispose()
        controller = nil
    }
}
