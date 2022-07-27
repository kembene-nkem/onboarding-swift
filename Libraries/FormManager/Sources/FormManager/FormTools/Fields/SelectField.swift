//
//  File.swift
//  
//
//  Created by Kembene Nkem on 7/26/22.
//

import Foundation
import UIKit
import Core

open class SelectField: FormField{
    public var interactiveLabel = InteractiveLabel()
    private var pickerView = UIPickerView()
    public var items: [SimpleDataItem] = []
    public var selectorStringAdapter: ValueSupplierCallback<SimpleDataItem, String>?
    public var broadcastValueOnChange = false
    
    
    private var isSetup = false
    
    public static let fieldType = "SelectField"
    
    public override init(fieldName: String, label: String?, required: Bool = false, order: Double = 10.0) {
        super.init(fieldName: fieldName, label: label, required: required, order: order)
        enableExplicitHeight = true
    }
    
    open override func activateField() {
        interactiveLabel.becomeFirstResponder()
    }
    
    open override func getFieldType() -> String {
        return SelectField.fieldType
    }
    
    open override func prepareInteractiveView() -> UIView {
        setup()
        interactiveLabel = InteractiveLabel()
        interactiveLabel.interactiveInput = pickerView
        interactiveLabel.isUserInteractionEnabled = enabled
        interactiveLabel.didResignFromFirstResponser = {
            let selectedIndex = self.pickerView.selectedRow(inComponent: 0)
            if selectedIndex < self.items.count {
                self.setFieldValue(value: self.items[selectedIndex], notifyChange: true)
            }
        }
        return interactiveLabel
    }
    
    fileprivate func setup() {
        if !isSetup {
            isSetup = true
            pickerView.delegate = self
            pickerView.dataSource = self
        }
    }
    
    override public func postLayout(renderedView: UIView, manager: FormManager) {
        let interactiveView = getInteractiveFieldView()
        let image = manager.resourceLoader()?.image(manager.resources.Asset.imageSelectPicker)
        let caret = UIImageView(image: image?.withRenderingMode(.alwaysTemplate))
        caret.tintColor = getEffectiveTheme()?.primaryColor
        caret.contentMode = .scaleAspectFit
        interactiveView.addSubview(caret)
        caret.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.centerY.equalToSuperview()
            make.height.equalTo(10)
            make.width.equalTo(10)
        }
    }
    
    override public func postFormatted(manager: FormManager) {
        if let value = self.getFieldValue() as? SimpleDataItem {
            var attributes: [NSAttributedString.Key : Any] = [:]
            if let color = getTextColor(formManager: manager){
                attributes[NSAttributedString.Key.foregroundColor] = color
            }
            if let font = getFont(formManager: manager){
                attributes[NSAttributedString.Key.font] = font.step(by: -1)
            }
            displayAsSelectedValueString(text: NSAttributedString(string: value.getItemLabel(), attributes: attributes))
        }
        else{
            displayAsSelectedValueString(text: generatePlaceHolder())
        }
    }
    
    func displayAsSelectedValueString(text: NSAttributedString?) {
        interactiveLabel.attributedText = text
    }
    
    func displayAsSelectedValueString(text: String?) {
        interactiveLabel.text = text
    }
    
}


extension SelectField: UIPickerViewDelegate {
    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let value = items[row]
        return selectorStringAdapter?(value) ?? value.getItemLabel()
    }
    
    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {        
        if row < items.count {
            let value = items[row]
            self.setFieldValue(value: value, notifyChange: broadcastValueOnChange)
        }
    }
}

extension SelectField: UIPickerViewDataSource{
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return items.count
    }
}
