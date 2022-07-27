//
//  File.swift
//  
//
//  Created by Kembene Nkem on 7/26/22.
//

import Foundation
import UIKit

public class DefaultFormItemFormatter: FormItemFormatter {
    let order: Int
    public init(order: Int = 0) {
        self.order = order
    }
    
    public func formatterName()-> String {
        return "Default"
    }
    
    public func formatterOrder() -> Int {
        return self.order
    }
    
    public func formatterGroupName() -> String {
        return FormatterGroupKey.Label.formLabel
    }
    
    public func canFormat(field: FormField)-> Bool {
        return true
    }
    
    public func format(manager: FormManager, field: FormField, theme: FormTheming) {
        if let label = field.getLabelView() as? UILabel{
            label.textColor = theme.textColor
            if let font = theme.titleFont{
                label.font = font
            }
        }        
    }
}

public protocol FieldBorderFormatterAdapter{
    func formatBorder(manager: FormManager, field: FormField, theme: FormTheming)
}

public class FieldBorderFormatter: FormItemFormatter {
    var supportedFieldTypes: [String]?
    let order: Int
    public static let name = "FieldBorderFormatter"
    public init(supportedFieldTypes: [String]? = nil, order: Int = 0){
        self.supportedFieldTypes = supportedFieldTypes
        self.order = order
    }
    
    public func formatterName()-> String {
        return FieldBorderFormatter.name
    }
    
    public func formatterOrder() -> Int {
        return order
    }
    
    public func formatterGroupName() -> String {
        return FormatterGroupKey.Field.fieldBorder
    }
    
    public func addSupportedType(type: String){
        if supportedFieldTypes == nil{
            supportedFieldTypes = []
        }
        self.supportedFieldTypes?.append(type)
    }
    
    public func canFormat(field: FormField)-> Bool {
        return self.supportedFieldTypes == nil || self.supportedFieldTypes?.contains(field.getFieldType()) == true
    }
    
    public func format(manager: FormManager, field: FormField, theme: FormTheming) {
        if let borderFormatter = field as? FieldBorderFormatterAdapter {
            borderFormatter.formatBorder(manager: manager, field: field, theme: theme)
            return
        }
        doFormatting(manager: manager, field: field, theme: theme)
        
    }
    
    public func doFormatting(manager: FormManager, field: FormField, theme: FormTheming) {
        let interactiveView = field.getInteractiveFieldView()
        interactiveView.layer.borderColor = theme.borderColor?.cgColor
        interactiveView.layer.cornerRadius = theme.borderRadius ?? 0
    }
}

public class UnderLineBorderFormatter: FieldBorderFormatter {
    public static let key = "UnderLineBorderFormatter"
    
    
    override public func formatterName() -> String {
        return UnderLineBorderFormatter.key
    }
    
    override public func doFormatting(manager: FormManager, field: FormField, theme: FormTheming) {
        let interactiveView = field.getInteractiveFieldView()
        var border = field.getViewKeyedBy(key: FormField.DataKey.View.underLineBorderView)
        if border == nil {
            border = UIView()
            field.registerViewInBag(key: FormField.DataKey.View.underLineBorderView, data: border!)
            if let superView = interactiveView.superview {
                superView.addSubview(border!)
                border?.snp.makeConstraints({ make in
                    make.leading.equalTo(interactiveView)
                    make.trailing.equalTo(interactiveView)
                    make.top.equalTo(interactiveView.snp.bottom).offset(2)
                    make.height.equalTo(0)
                })
            }
        }
        border?.snp.updateConstraints({ make in
            make.height.equalTo(theme.borderWidth ?? 1)
        })
        border?.backgroundColor = theme.borderColor
    }
}

extension FormField.DataKey.View{
    static let underLineBorderView = "UnderLineBorderFormatter"
}
