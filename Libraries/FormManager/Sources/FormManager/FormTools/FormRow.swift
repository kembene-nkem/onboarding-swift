//
//  File.swift
//  
//
//  Created by Kembene Nkem on 7/26/22.
//

import Foundation

public class FormRow: Comparable{
    
    
    
    public var rowSpacing: FormSpacingConfig?
    var rowOrder: Double
    var fields: [FormField] = []
    var renderingIndexPath: IndexPath?
    
    public init(order: Double){
        rowOrder = order
    }
    
    public func allFields()-> [FormField] {
        var fields: [FormField] = []
        fields.append(contentsOf: self.fields)
        return fields
    }
    
    func findField(withName fieldName: String)-> FormField? {
        for field in fields {
            if field.fieldName == fieldName {
                return field
            }
        }
        return nil
    }
    
    public func addField(field: FormField){
        fields.append(field)
    }
    
    func prepareForRendering(){
        fields.sort()
    }
    
    func dispose() {
        fields.forEach{$0.cleanup()}
    }
    
    public static func < (lhs: FormRow, rhs: FormRow) -> Bool {
        return lhs.rowOrder < rhs.rowOrder
    }
    
    public static func == (lhs: FormRow, rhs: FormRow) -> Bool {
        return lhs.rowOrder == rhs.rowOrder && lhs.fields == rhs.fields
    }
}
