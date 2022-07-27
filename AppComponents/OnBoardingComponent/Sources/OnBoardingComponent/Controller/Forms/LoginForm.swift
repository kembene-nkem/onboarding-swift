//
//  File.swift
//  
//
//  Created by Kembene Nkem on 7/27/22.
//

import Foundation
import FormManager

class LoginForm: OnBoardingBaseForm{
    
    public static let fieldEmail = "email"
    
    override func addFirstField(builder: FormBuilder) {
        builder.newSection { section in
            section.newRow { val in
                addEmail(row: val)
            }
        }
    }
    
    func addEmail(row: FormRow){
        let label = resourceLoader?.localized(fieldTexts.textEmail)
        let field = TextField(fieldName: LoginForm.fieldEmail, label: label, required: true)
        field.keyboardType = .emailAddress
        field.placeholder = "Enter \(label ?? "")"
        row.addField(field: field)
    }
}
