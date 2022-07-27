//
//  File.swift
//  
//
//  Created by Kembene Nkem on 7/26/22.
//

import Foundation
import UIKit
import SnapKit
import Core

let defaultFormOrder = 100

public protocol FieldValueChangeDelegate {
    func fieldValueDidChange(field: FormField)
}

open class FormField: NSObject, Comparable {
    var fieldName: String
    var fieldLabel: String?
    var required: Bool = false
    var currentFieldValue: Any?
    var viewDataBag: [String: Any] = [:]
    var stateDataBag: [String: Any] = [:]
    var renderedView: UIView?
    var interactiveView: UIView?
    var enabled: Bool = true
    var isBuilt = false
    var errorMessage: String?
    var fieldChangeDelegate = MulticastDelegate<FieldValueChangeDelegate>()
    var postFieldChangeDelegate = MulticastDelegate<FieldValueChangeDelegate>()
    var layoutChangeDelegate = MulticastDelegate<FieldValueChangeDelegate>()
    var renderingIndexPath: IndexPath?
    var sortOrder: Double
    
    fileprivate var effectiveFieldItemRender: FormItemRenderer?
    fileprivate var formManager: FormManager?
    
    public struct DataKey {
        public struct View {
            public static let labelView = "labelView"
            public static let interactiveView = "interactiveView"
            public static let inputWrapper = "inputWrapper"
        }
        
        public struct StateKey {
            static let heightConstraint = "fieldHeightConstraint"
        }
    }
    
    
    
    public var labelPosition: FormLabelPositioning?
    public var formTheme: FormTheming?
    public var fieldItemRender: FormItemRenderer?
    public var formatters: [FormItemFormatter]?
    public var skipManagerRenderers = false
    public var fieldSpacing: FormSpacingConfig?
    public var placeholder: String?
    public var formattersToExclude: [String] = []
    public var enableExplicitHeight = false
    public var displayValidationErrorMessage = true
    public var validateOnFieldChange = true
    
    public var name: String{
        return fieldName
    }
    
    public var label: String? {
        return fieldLabel
    }
    
    public var isRequired: Bool {
        return required
    }
    
    
    public init(fieldName: String, label: String?, required: Bool = false, order: Double = 10.0){
        self.sortOrder = order
        self.fieldName = fieldName
        self.fieldLabel = label
        self.required = required
    }
    
    open func getFieldType()-> String {
        fatalError("Not Implemented")
    }
    
    /// A way to tell the field to become the first responder
    open func activateField() {
        
    }
    
    /// this method should return the UIView that will be seen as the view users will interact with when they want to enter value for the field.
    /// - Note: This method will be called multiple times. So ensure to always return a mutable view
    open func getInteractiveFieldView()-> UIView{
        if interactiveView == nil {
            interactiveView = prepareInteractiveView()
        }
        return interactiveView!
    }
    
    open func prepareInteractiveView()-> UIView{
        fatalError("Not implemented")
    }
    
    open func setFieldValue(value: Any?, notifyChange: Bool = true){
        currentFieldValue = value
        if notifyChange {
            self.fieldValueDidChange()
        }
    }
    
    
    open func fieldValueDidChange() {
        if isBuilt {
            self.applyFormatters()
            self.fieldChangeDelegate |> {delegate in
                delegate.fieldValueDidChange(field: self)
            }
            self.postFieldChangeDelegate |> {delegate in
                delegate.fieldValueDidChange(field: self)
            }
        }
    }
    
    open func getFieldValue()-> Any?{
        return currentFieldValue
    }
    
    open func showErrorMessage(_ message: String, forceShowError: Bool = false) {
        if forceShowError {
            self.displayErrorMessage(message)
        }
    }
    
    open func hideErrorMessage() {
        self.errorMessage = nil
        self.applyFormatters()
    }
    
    open func displayErrorMessage(_ message: String) {
        self.errorMessage = message
        self.applyFormatters()
        self.errorMessage = nil
    }
    
    
    open func setEnabled(enable: Bool) {
        interactiveView?.isUserInteractionEnabled = enable
        self.enabled = enable
    }
    
    public func registerViewInBag(key: String, data: Any?){
        self.viewDataBag[key] = data
    }
    
    public func getViewInBag(key: String)-> Any? {
        return viewDataBag[key]
    }
    
    public func registerStateInBag(key: String, data: Any?){
        self.stateDataBag[key] = data
    }
    
    public func getStateInBag(key: String)-> Any? {
        return stateDataBag[key]
    }
    
    open func cleanup() {
        (renderedView as? CoreDisposable)?.dispose()
        renderedView?.removeFromSuperview()
        renderedView = nil
        (interactiveView as? CoreDisposable)?.dispose()
        interactiveView = nil
        self.viewDataBag.enumerated().forEach { item in
            (item.element as? CoreDisposable)?.dispose()
        }
        /// we clean up the view data bag, as this usually contains view items created while rendering the view. There is no need to clear the state data base, as that should survive various rendering
        self.viewDataBag = [:]
        self.isBuilt = false
        self.effectiveFieldItemRender = nil
    }
    
    public func getLabelView()-> UIView? {
        return getViewInBag(key: FormField.DataKey.View.labelView) as? UIView
    }
    
    public func getViewKeyedBy(key: String)-> UIView? {
        return getViewInBag(key: key) as? UIView
    }
    
    public func buildView(manager: FormManager? = nil)-> UIView {
        self.formManager = manager
        if renderedView != nil {
            return renderedView!
        }
        let formManager = manager ?? FormManager.shared
        let renders = getRenderers()
        let wrapperView = renderFieldItems(renders: renders, formManager: formManager)
        
        if let heightConstraint = self.getViewInBag(key: FormField.DataKey.StateKey.heightConstraint) as? Constraint {
            if enableExplicitHeight == false{
                heightConstraint.isActive = false
            }
        }
        
        applyFormatters(renders: renders, formManager: formManager)
        self.isBuilt = true
        return wrapperView
    }
    
    fileprivate func getRenderers()-> [FormItemRenderer] {
        if let manager = formManager{
            let itemRender = (self.fieldItemRender ?? manager.defaultFormItemRenderer)
            self.effectiveFieldItemRender = itemRender
            var renders: [FormItemRenderer] = [itemRender]
            if skipManagerRenderers == false{
                renders.append(contentsOf: manager.formItemRenderers)
            }
            return renders
        }
        return []
    }
    
    fileprivate func applyFormatters(renders: [FormItemRenderer]? = nil, formManager: FormManager? = nil) {
        if let manager = self.formManager ?? formManager {
            let theme = formTheme ?? manager.theme
            
            let rendersList = renders ?? getRenderers()
            
            var layoutFormatters: [FormItemFormatter] = rendersList.compactMap { renderer in
                if let item = renderer as? FormItemFormatter {
                    return item
                }
                return nil
            }
            
            layoutFormatters.append(contentsOf: manager.formatters.values)
            layoutFormatters.append(contentsOf: formatters ?? [])
            
            var appliedFormatterGroup = ""
            
            /// sort the formatters according to their defined order
            layoutFormatters.sort { leftItem, rightItem in
                return leftItem.formatterOrder() < rightItem.formatterOrder()
            }
            
            layoutFormatters.forEach({ formatterInfo in
                /// check that a formatter belonging to the same group as this formatter has not been processed previously
                /// For example you can have two formatters that puts a border around the input field
                let groupProcessed = formatterInGroupHasBeenProcessed(formatter: formatterInfo, processedStore: appliedFormatterGroup)
                if !groupProcessed {
                    /// check that this formatter is not contained in the excluded list of formatters for this field, and that the formatter can format this field
                    if formattersToExclude.contains(formatterInfo.formatterName()) == false && formatterInfo.canFormat(field: self) {
                        appliedFormatterGroup += " ::\(formatterInfo.formatterGroupName())::"
                        formatterInfo.format(manager: manager, field: self, theme: theme)
                        
                    }
                }
            })
            
            self.postFormatted(manager: manager)
        }
        if isBuilt {
            self.layoutChangeDelegate |> {delegate in
                delegate.fieldValueDidChange(field: self)
            }
        }
    }
    
    fileprivate func formatterInGroupHasBeenProcessed(formatter: FormItemFormatter, processedStore: String)-> Bool{
        let groupName = formatter.formatterGroupName()
        return processedStore.contains("::\(groupName)::")
    }
    
    fileprivate func renderFieldItems(renders: [FormItemRenderer], formManager: FormManager)-> UIView {
        let layoutBag = FormLayoutBag()
        renders.forEach { render in
            if render.supportsField(field: self){
                if let info = render.prepareForRendering(manager: formManager, field: self, layoutBag: layoutBag){
                    layoutBag.addToBag(key: render.getKey(), item: info)
                    if render.getKey() == self.effectiveFieldItemRender?.getKey() {
                        registerViewInBag(key: FormField.DataKey.View.inputWrapper, data: info.view)
                    }
                }
            }
        }
        
        
        let wrapperView = UIView()
        wrapperView.backgroundColor = UIColor.clear
        var lastView: UIView? = nil
        let allViews = layoutBag.views()
        let lastViewIndex = allViews.count - 1
        allViews.enumerated().forEach { element in
            let currentView = element.element
            wrapperView.addSubview(currentView)
            currentView.snp.makeConstraints { make in
                make.leading.equalToSuperview()
                make.trailing.equalToSuperview()
                if let previousView = lastView {
                    make.top.equalTo(previousView.snp.bottom)
                }
                else{
                    make.top.equalToSuperview()
                }
                if lastViewIndex == element.offset{
                    make.bottom.equalToSuperview()
                }
            }
            lastView = currentView
        }
        
        self.renderedView = wrapperView
        (getLabelView() as? UILabel)?.text = fieldLabel
        self.postLayout(renderedView: wrapperView, manager: formManager)
        
        return wrapperView
    }
    
    public func postLayout(renderedView: UIView, manager: FormManager){
        
    }
    
    public func postFormatted(manager: FormManager){
        
    }
    
    func generatePlaceHolder(formManager: FormManager? = nil)-> NSAttributedString? {
        if let placeholder = self.placeholder{
            var attributes: [NSAttributedString.Key : Any] = [:]
            if let color = getTextColor(formManager: formManager) {
                attributes[NSAttributedString.Key.foregroundColor] = color.withAlphaComponent(0.4)
            }
            if let font = getFont(formManager: formManager){
                attributes[NSAttributedString.Key.font] = font.step(by: -2)
            }
            return NSMutableAttributedString(
                string: placeholder,
                attributes: attributes
            )
        }
        return nil
    }
    
    func getFont(formManager: FormManager? = nil)-> UIFont? {
        return getEffectiveTheme()?.baseFont
    }
    
    func getTextColor(formManager: FormManager? = nil)-> UIColor? {
        return getEffectiveTheme()?.textColor
    }
    
    func getEffectiveTheme(formManager: FormManager? = nil)-> FormTheming? {
        return self.formTheme ?? formManager?.theme ?? self.formManager?.theme
    }
    
    public static func -=(left: FormField, right: FieldValueChangeDelegate) {
        left.fieldChangeDelegate -= right
    }
    
    public static func *=(left: FormField, right: FieldValueChangeDelegate) {
        if !left.layoutChangeDelegate.containsDelegate(right) {
            left.layoutChangeDelegate += right
        }
    }
    
    public static func +=(left: FormField, right: FieldValueChangeDelegate) {
        if !left.fieldChangeDelegate.containsDelegate(right) {
            left.fieldChangeDelegate += right
        }
    }
    
    public static func ++=(left: FormField, right: FieldValueChangeDelegate) {
        if !left.postFieldChangeDelegate.containsDelegate(right) {
            left.postFieldChangeDelegate += right
        }
    }
    
    public static func --=(left: FormField, right: FieldValueChangeDelegate) {
        left.postFieldChangeDelegate -= right
    }
    
    public static func < (lhs: FormField, rhs: FormField) -> Bool {
        return lhs.sortOrder < rhs.sortOrder
    }
    
    public static func == (lhs: FormField, rhs: FormField) -> Bool {
        return lhs.sortOrder == rhs.sortOrder && lhs.fieldName == rhs.fieldName
    }
}

infix operator ++=
infix operator --=
