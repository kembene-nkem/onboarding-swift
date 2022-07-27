//
//  File.swift
//  
//
//  Created by Kembene Nkem on 7/27/22.
//

import Foundation
import FormManager

open class PersonalInformationForm: OnBoardingBaseForm {
    
    public static let fieldFirstName = "firstName"
    public static let fieldLastName = "lastName"
    public static let fieldMiddleName = "middleName"
    
    
    
    public override func addFirstField(builder: FormBuilder) {
        builder.newSection(order: 1.0) { section in
            section.newRow{row in
                self.addFirstName(row: row)
                self.addLastName(row: row)
                self.addMiddleName(row: row)
            }
        }
    }
    
    func addFirstName(row: FormRow){
        let firstNameLabel = resourceLoader?.localized(fieldTexts.textFirstName)
        let field = TextField(fieldName: PersonalInformationForm.fieldFirstName, label: firstNameLabel, required: true)
        field.placeholder = "Enter \(firstNameLabel ?? "")"
        row.addField(field: field)
    }
    
    func addLastName(row: FormRow){
        let lastNameLabel = resourceLoader?.localized(fieldTexts.textLastName)
        let field = TextField(fieldName: PersonalInformationForm.fieldLastName, label: lastNameLabel, required: true)
        field.placeholder = "Enter \(lastNameLabel ?? "")"
        row.addField(field: field)
    }
    
    func addMiddleName(row: FormRow){
        let middleNameLabel = resourceLoader?.localized(fieldTexts.textMiddleName)
        let field = TextField(fieldName: PersonalInformationForm.fieldMiddleName, label: middleNameLabel, required: true)
        field.placeholder = "Enter \(middleNameLabel ?? "")"
        row.addField(field: field)
    }
}
