//
//  File.swift
//  
//
//  Created by Kembene Nkem on 7/27/22.
//

import Foundation
import FormManager

class ContactUsForm: OnBoardingBaseForm{
    
    public static let fieldPhoneNumber = "phoneNumber"
    
    override func addFirstField(builder: FormBuilder) {
        builder.newSection { section in
            section.newRow { val in
                addContactPhone(row: val)
            }
        }
    }
    
    func addContactPhone(row: FormRow){
        let label = resourceLoader?.localized(fieldTexts.textPhoneNumber)
        let field = TextField(fieldName: ContactUsForm.fieldPhoneNumber, label: label, required: true)
        field.keyboardType = .phonePad
        field.placeholder = "Enter \(label ?? "")"
        row.addField(field: field)
    }
}
