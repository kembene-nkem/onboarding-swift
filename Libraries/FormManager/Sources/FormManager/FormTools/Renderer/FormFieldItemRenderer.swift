//
//  File.swift
//  
//
//  Created by Kembene Nkem on 7/26/22.
//

import Foundation
import UIKit
import SnapKit

public class DefaultFormFieldItemRenderer: FormItemRenderer{
    static let positionOfItem = 0
    static let key = "MainItemRenderer"
    public init(){}
    public func getKey()-> String{
        return DefaultFormFieldItemRenderer.key
    }
    public func prepareForRendering(manager: FormManager, field: FormField, layoutBag: FormLayoutBag)-> FormBagItemLayout?{
        let labelPosition = field.labelPosition ?? manager.labelPosition
        var view: UIView?
        switch labelPosition {
        case .topLeft:
            view = prepareForRenderingTopLeft(manager: manager, field: field, layoutBag: layoutBag)
        case .topRight:
            view = prepareForRenderingTopRight(manager: manager, field: field, layoutBag: layoutBag)
        case .inline:
            view = prepareForRenderingInline(manager: manager, field: field, layoutBag: layoutBag)
        case .none:
            view = prepareForRenderingInNone(manager: manager, field: field, layoutBag: layoutBag)
        }
        if view != nil{
            return FormBagItemLayout(order: DefaultFormFieldItemRenderer.positionOfItem, view: view!)
        }
        return nil
    }
    
    fileprivate func createWrapperViews(field: FormField, formManager: FormManager)-> [UIView]{
        let label = UILabel()
        let input = field.getInteractiveFieldView()
        let labelWrapper = UIView()
        let inputWrapper = UIView()
        field.registerViewInBag(key: FormField.DataKey.View.labelView, data: label)
        labelWrapper.addSubview(label)
        inputWrapper.addSubview(input)
        let spacing = field.fieldSpacing ?? field.formTheme?.fieldSpacing ?? formManager.fieldSpacing
        label.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        input.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            if let height = spacing.height {
                field.registerViewInBag(key: FormField.DataKey.StateKey.heightConstraint, data: make.height.equalTo(height).constraint)
            }
        }
        labelWrapper.backgroundColor = UIColor.clear
        inputWrapper.backgroundColor = UIColor.clear
        return [inputWrapper, labelWrapper]
    }
    
    func prepareForRenderingTopLeft(manager: FormManager, field: FormField, layoutBag: FormLayoutBag)-> UIView {
        let contentView = UIView()
        let wrappers = createWrapperViews(field: field, formManager: manager)
        let inputWrapper = wrappers[0]
        let labelWrapper = wrappers[1]
        
        let spacing = field.fieldSpacing ?? field.formTheme?.fieldSpacing ?? manager.fieldSpacing
        
        contentView.addSubview(labelWrapper)
        contentView.addSubview(inputWrapper)
        
        labelWrapper.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.equalToSuperview()
        }
        inputWrapper.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.top.equalTo(labelWrapper.snp.bottom).offset(spacing.vertical ?? 0)
            make.bottom.equalToSuperview()
        }
        contentView.backgroundColor = UIColor.clear
        return contentView
    }
    
    func prepareForRenderingTopRight(manager: FormManager, field: FormField, layoutBag: FormLayoutBag)-> UIView {
        let contentView = UIView()
        let wrappers = createWrapperViews(field: field, formManager: manager)
        let labelWrapper = wrappers[1]
        let inputWrapper = wrappers[0]
        
        let spacing = field.fieldSpacing ?? field.formTheme?.fieldSpacing ?? manager.fieldSpacing
        
        contentView.addSubview(labelWrapper)
        contentView.addSubview(inputWrapper)
        
        labelWrapper.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.top.equalToSuperview()
        }
        inputWrapper.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.top.equalTo(labelWrapper.snp.bottom).offset(spacing.vertical ?? 0)
            make.bottom.equalToSuperview()
        }
        contentView.backgroundColor = UIColor.clear
        return contentView
    }
    
    func prepareForRenderingInline(manager: FormManager, field: FormField, layoutBag: FormLayoutBag)-> UIView {
        let contentView = UIView()
        let wrappers = createWrapperViews(field: field, formManager: manager)
        let labelWrapper = wrappers[1]
        let inputWrapper = wrappers[0]
        
        let spacing = field.fieldSpacing ?? field.formTheme?.fieldSpacing ?? manager.fieldSpacing
        
        contentView.addSubview(labelWrapper)
        contentView.addSubview(inputWrapper)
        
        labelWrapper.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.equalTo(inputWrapper)
            make.bottom.equalTo(inputWrapper)
        }
        inputWrapper.snp.makeConstraints { make in
            make.leading.equalTo(inputWrapper.snp.leading).offset(spacing.horizontal ?? 0)
            make.trailing.equalTo(inputWrapper)
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        contentView.backgroundColor = UIColor.clear
        return contentView
    }
    
    func prepareForRenderingInNone(manager: FormManager, field: FormField, layoutBag: FormLayoutBag)-> UIView {
        let contentView = UIView()
        let wrappers = createWrapperViews(field: field, formManager: manager)
        let inputWrapper = wrappers[0]
        
        contentView.addSubview(inputWrapper)
        
        inputWrapper.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        contentView.backgroundColor = UIColor.clear
        return contentView
    }
}

public class BottomErrorFieldItemRenderer: FormItemRenderer{
    static let positionOfRendererItem = 100
    let order: Int
    static let key = "BottomErrorRenderer"
    
    public init(order: Int = 0){
        self.order = order
    }
    
    public func getKey()-> String{
        return BottomErrorFieldItemRenderer.key
    }
    
    public func prepareForRendering(manager: FormManager, field: FormField, layoutBag: FormLayoutBag)-> FormBagItemLayout?{
        let errorLabel = UILabel()
        let wrapper = UIView()
        wrapper.addSubview(errorLabel)
        wrapper.backgroundColor = UIColor.clear
        errorLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.top.equalToSuperview().offset(0)
            make.bottom.equalToSuperview().offset(0)
        }
//        errorLabel.text = ""
        field.registerViewInBag(key: FormField.DataKey.View.errorLabel, data: errorLabel)
        return FormBagItemLayout(order: BottomErrorFieldItemRenderer.positionOfRendererItem, view: wrapper)
    }
}

extension BottomErrorFieldItemRenderer: FormItemFormatter{
    public func formatterGroupName() -> String {
        FormatterGroupKey.Field.errorLabel
    }
    
    public func formatterOrder() -> Int {
        self.order
    }
    
    public func formatterName()-> String {
        return BottomErrorFieldItemRenderer.key
    }
    
    public func canFormat(field: FormField)-> Bool {
        return true
    }
    
    public func format(manager: FormManager, field: FormField, theme: FormTheming) {
        if let label = field.getViewKeyedBy(key: FormField.DataKey.View.errorLabel) as? UILabel{
            label.isHidden = true
            if field.errorMessage != nil {
                print(field.fieldName)
                label.isHidden = false
                label.text = field.errorMessage
            }
            label.textColor = UIColor.red
            label.font = (field.formTheme ?? manager.theme)?.baseFont?.step(by: -3)
        }
    }
}

extension FormField.DataKey.View {
    public static let errorLabel = "ErrorLabel"
}

extension FormatterGroupKey.Field{
    public static let errorLabel = "ErrorLabel"
}
