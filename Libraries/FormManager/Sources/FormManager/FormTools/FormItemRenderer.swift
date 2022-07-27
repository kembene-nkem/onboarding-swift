//
//  File.swift
//  
//
//  Created by Kembene Nkem on 7/26/22.
//

import Foundation
import UIKit

public struct FormBagItemLayout: Comparable {
    var order: Int
    var view: UIView
    
    public static func < (lhs: FormBagItemLayout, rhs: FormBagItemLayout) -> Bool {
        return lhs.order < rhs.order
    }
    
    public static func == (lhs: FormBagItemLayout, rhs: FormBagItemLayout) -> Bool {
        return lhs.order == rhs.order && lhs.view == rhs.view
    }
}

public class FormLayoutBag {
    var layoutBag: [String: FormBagItemLayout] = [:]
    
    public func addToBag(key: String, item: FormBagItemLayout) {
        layoutBag[key] = item
    }
    
    public func views()-> [UIView]{
        return layoutBag.values.sorted().map{$0.view}
    }
}

public protocol FormItemRenderer{
    func prepareForRendering(manager: FormManager, field: FormField, layoutBag: FormLayoutBag)-> FormBagItemLayout?
    func getKey()-> String
    func supportsField(field: FormField)-> Bool
}

extension FormItemRenderer {
    public func supportsField(field: FormField)-> Bool{
        return true
    }
}

public struct FormatterGroupKey{
    public struct Field{
        static let fieldBorder = "FieldBorder"        
    }
    
    public struct Label{
        static let formLabel = "FormLabel"
    }
}

public protocol FormItemFormatter{
    func formatterName()-> String
    func formatterGroupName()-> String
    func canFormat(field: FormField)-> Bool
    func formatterOrder()-> Int
    func format(manager: FormManager, field: FormField, theme: FormTheming)
}

extension FormItemRenderer{
    func prepareForRendering(manager: FormManager, field: FormField, layoutBag: FormLayoutBag)-> FormBagItemLayout?{return nil}
}
