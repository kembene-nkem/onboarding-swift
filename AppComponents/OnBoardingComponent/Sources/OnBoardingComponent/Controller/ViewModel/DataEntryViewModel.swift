//
//  File.swift
//  
//
//  Created by Kembene Nkem on 7/27/22.
//

import Foundation
import FormManager

class DataEntryViewModel{
    let viewModelForm: Form
    let category: DataCategory
    init (form: Form, category: DataCategory){
        self.viewModelForm = form
        self.category = category
    }
}
