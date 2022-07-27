//
//  File.swift
//  
//
//  Created by Kembene Nkem on 7/26/22.
//

import Foundation
import UIKit
import Core

public typealias FormBeginEditingCallback = (_ field: FormField)-> Void

open class TextField: FormField {
    
    public static let fieldType = "TextField"
    public var textBeginEditingCallback: FormBeginEditingCallback?
    
    public var keyboardType: UIKeyboardType?
    
    public var configureInput: ValueChangeCallback<(UITextField, TextField)>? = nil
    
    open override func getFieldType() -> String {
        return TextField.fieldType
    }
    
    open override func activateField() {
        interactiveView?.becomeFirstResponder()
    }
    
    open override func prepareInteractiveView() -> UIView {
        let field = UITextField(frame: .zero)
        field.delegate = self
        field.keyboardType = keyboardType ?? .default
        configureInput?((field, self))
        return field
    }
    
    open override func setFieldValue(value: Any?, notifyChange: Bool = true) {
        if let val = value {
            if let string = val as? String{
                getTextField()?.text = string
            }
            else{
                getTextField()?.text = String(describing: val)
            }
        }
        else{
            getTextField()?.text = nil
        }
        super.setFieldValue(value: value, notifyChange: notifyChange)
    }
    
    open override func postFormatted(manager: FormManager) {
        getTextField()?.attributedPlaceholder = generatePlaceHolder(formManager: manager)
        getTextField()?.textColor = getTextColor(formManager: manager)        
        if let font = getFont(formManager: manager){
            getTextField()?.font = font.step(by: -1)
        }        
    }
    
    public func getTextField()-> UITextField? {
        return getInteractiveFieldView() as? UITextField
    }
}

extension TextField: UITextFieldDelegate {
    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        self.textBeginEditingCallback?(self)
        return true
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        self.setFieldValue(value: textField.text, notifyChange: true)
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.fieldValueDidChange()
        return true
    }
    
//    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//        guard let text = textField.text else { return true }
//        /// adding an condition where we can limit the number of characters allowed to be entered in the text field
//        return true
//    }
    
    
}
