//
//  File.swift
//  
//
//  Created by Kembene Nkem on 7/26/22.
//

import Foundation
import UIKit
import Core

public protocol FormBuildDelegate {
    func formDidPreBuild(form: FormBuilder)
    func formDidPostBuild(form: FormBuilder)
    func didDisposeBuiltForm(form: FormBuilder)
}

extension FormBuildDelegate{
    public func formDidPreBuild(form: FormBuilder) {}
    public func formDidPostBuild(form: FormBuilder){}
    public func didDisposeBuiltForm(form: FormBuilder){}
}

public struct FormSpacingConfig {
    public var top: Double
    public var bottom: Double
    public var leading: Double
    public var trailing: Double
    public var height: Double?
    public var vertical: Double?
    public var horizontal: Double?
    
    public init(top: Double = 0, bottom: Double = 0, leading: Double = 0, trailing: Double = 0, height: Double? = nil, horizontal: Double? = nil, vertical: Double? = nil) {
        self.top = top
        self.bottom = bottom
        self.leading = leading
        self.trailing = trailing
        self.height = height
        self.horizontal = horizontal
        self.vertical = vertical
    }
}

public class FormBuilder: NSObject, CoreDisposable {
    var sections: [FormSection] = []
    var manager: FormManager
    var preConfigure: ValueChangeCallback<(FormField, FormManager?)>?
    
    var buildDelegate = MulticastDelegate<FormBuildDelegate>()
    var renderedView: RenderedFormTable?
    
    public init(manager: FormManager, configure: ValueChangeCallback<(FormField, FormManager?)>? = nil){
        self.manager = manager
        self.preConfigure = configure
    }
    
    public func newSection(order: Double = 10.0, configure: ValueChangeCallback<FormSection>) {
        let section = FormSection(order: order)
        configure(section)
        sections.append(section)
    }
    
    public func findSection(forFieldWithName fieldName: String)-> FormSection?{
        for section in sections {
            if let _ = section.findField(withName: fieldName){
                return section
            }
        }
        return nil
    }
    
    public func findField(forFieldWithName fieldName: String)-> FormField?{
        for section in sections {
            if let field = section.findField(withName: fieldName){
                return field
            }
        }
        return nil
    }
    
    public func findRow(forFieldWithName fieldName: String)-> FormRow? {
        for section in sections {
            if let row = section.findRow(withName: fieldName){
                return row
            }
        }
        return nil
    }
    
    
    public func buildView()-> UIView {
        self.renderedView?.dispose()
        self.renderedView = nil
        buildDelegate |> {delegate in
            delegate.formDidPreBuild(form: self)
        }
        let view = RenderedFormTable(frame: CGRect.zero, style: .grouped)
        sections.forEach{$0.prepareForRendering()}
        sections.sort()
        view.setup(sections: sections, manager: manager)
        buildDelegate |> {delegate in
            delegate.formDidPostBuild(form: self)
        }
        self.renderedView = view
        return view
    }
    
    public func allFields()-> [FormField] {
        var fields: [FormField] = []
        for section in sections {
            fields.append(contentsOf: section.allFields())
        }
        return fields
    }
    
    open func findField(withName name: String)-> FormField? {
        for section in sections {
            if let path = section.findField(withName: name) {
                return path
            }
        }
        return nil
    }
    
    public func dispose() {
        self.preConfigure = nil
    }
    
    public static func += (left: FormBuilder, delegate: FormBuildDelegate) {
        left.buildDelegate += delegate
    }
    
    public static func -=(left: FormBuilder, delegate: FormBuildDelegate) {
        left.buildDelegate -= delegate
    }
}

extension FormBuilder: Sequence {
    public func makeIterator() -> FormBuilderIterator {
        return FormBuilderIterator(fields: self.allFields())
    }
}

class RenderedFormTable: UITableView {
//    var builder: FormBuilder?
    
    var sections: [FormSection] = []
    var manager: FormManager!
    static let cellIdentifier = "Cell"
    
    func setup(sections: [FormSection], manager: FormManager) {
        self.sections = sections
        self.manager = manager
        self.backgroundColor = UIColor.clear
        self.register(RenderedFormTableCell.self, forCellReuseIdentifier: RenderedFormTable.cellIdentifier)
        self.rowHeight = UITableView.automaticDimension
        self.estimatedRowHeight = 50
        self.allowsSelection = false
        self.separatorStyle = .none
        self.dataSource = self
    }
    
    func dispose(){
        sections.forEach{$0.dispose()}
    }
}

extension RenderedFormTable: UITableViewDataSource {
    public func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].rows.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: RenderedFormTable.cellIdentifier, for: indexPath) as! RenderedFormTableCell
        cell.backgroundColor = UIColor.clear
        let row = sections[indexPath.section].rows[indexPath.row]
        row.renderingIndexPath = indexPath
        cell.bindFieldsToCell(row: row, manager: manager) { val in
            if let table = tableView as? RenderedFormTable{
                val.0 *= table
            }
        }
        return cell
    }
    
}

extension RenderedFormTable: FieldValueChangeDelegate {
    public func fieldValueDidChange(field: FormField) {
        if let path = field.renderingIndexPath {
            if (self.indexPathsForVisibleRows ?? []).contains(path){
                self.reloadRows(at: [path], with: .none)
            }
        }
    }
}

class RenderedFormTableCell: UITableViewCell {
    var boundFields: [FormField] = []
    
    func bindFieldsToCell(row: FormRow, manager: FormManager? = nil, configure: ValueChangeCallback<(FormField, FormManager?)>?){
        boundFields = []
        var lastView: UIView? = nil
        let lastIndex = row.fields.count - 1
        contentView.subviews.forEach{$0.removeFromSuperview()}
        row.fields.enumerated().forEach { element in
            let field = element.element
            let isAlreadyBuilt = field.isBuilt
            if !isAlreadyBuilt {
                configure?((field, manager))
            }
            field.renderingIndexPath = row.renderingIndexPath
            let view = field.buildView(manager: manager)
            let rowSpacing = row.rowSpacing ?? field.formTheme?.rowSpacing ?? manager?.rowSpacing
            let verticalSpacing = rowSpacing?.vertical ?? 0
            let topSpacing = rowSpacing?.top ?? 0
            let bottomSpacing = rowSpacing?.bottom ?? 0
            boundFields.append(field)
            contentView.addSubview(view)
            view.snp.makeConstraints { make in
                make.leading.equalToSuperview()
                make.trailing.equalToSuperview()
                if let previous = lastView{
                    make.top.equalTo(previous.snp.bottom).offset(verticalSpacing)
                }
                else{
                    make.top.equalToSuperview().offset(topSpacing)
                }
                
                if lastIndex == element.offset {
                    make.bottom.equalToSuperview().offset(0 - bottomSpacing)
                }
            }
            lastView = view
        }
        self.contentView.backgroundColor = UIColor.clear
    }
    
}


public class FormBuilderIterator: IteratorProtocol{
    let fields: [FormField]
    var currentIndex = 0
    init(fields: [FormField]){
        self.fields = fields
    }
    

    public func next() -> FormField? {
        let index = currentIndex
        if index < fields.count {
            currentIndex += 1
            return fields[index]
        }
        return nil
    }
}
