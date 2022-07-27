//
//  File.swift
//  
//
//  Created by Kembene Nkem on 7/26/22.
//

import Foundation
import Core

public class FormSection: Comparable {
    private var sectionOrder: Double
    var rows: [FormRow] = []
    var spaceConfig: FormSpacingConfig?
    
    public init(order: Double){
        sectionOrder = order
    }
    
    public func allFields()-> [FormField] {
        var fields: [FormField] = []
        for row in rows {
            fields.append(contentsOf: row.allFields())
        }
        return fields
    }
    
    public func findField(withName name: String)-> FormField? {
        for row in rows {
            if let field = row.findField(withName: name) {
                return field
            }
        }
        return nil
    }
    
    public func findRow(withName name: String)-> FormRow? {
        for row in rows {
            if let _ = row.findField(withName: name) {
                return row
            }
        }
        return nil
    }
    
    public func newRow( order: Double = 10.0, configure: ValueChangeCallback<FormRow>) {
        let row = FormRow(order: order)
        configure(row)
        rows.append(row)
    }
    
    func dispose(){
        rows.forEach{$0.dispose()}
    }
    
    public static func < (lhs: FormSection, rhs: FormSection) -> Bool {
        return lhs.sectionOrder < rhs.sectionOrder
    }
    
    public static func == (lhs: FormSection, rhs: FormSection) -> Bool {
        return lhs.sectionOrder == rhs.sectionOrder && rhs.rows == lhs.rows
    }
    
    func prepareForRendering(){
        rows.forEach { $0.prepareForRendering() }
        rows.sort()
    }
    
}
