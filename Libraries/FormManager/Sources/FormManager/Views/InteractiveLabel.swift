//
//  File.swift
//  
//
//  Created by Kembene Nkem on 7/26/22.
//

import Foundation
import UIKit
import Core

public class InteractiveLabel: UILabel {
    public var interactiveInput: UIView?
    public var interactiveToolbar: UIToolbar?
    
    public var didResignFromFirstResponser: EmptyCallback?
    
    private var doneButton: UIBarButtonItem!
    
    private let _inputAccessoryToolbar: UIToolbar = {
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.sizeToFit()

        return toolBar
    }()
    
    override public var inputAccessoryView: UIView? {
        if let bar = interactiveToolbar{
            return bar
        }
        return _inputAccessoryToolbar
    }
    
    override public var inputView: UIView? {
        return interactiveInput
    }
    
    override public var canBecomeFirstResponder: Bool {
        return true
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    init() {
        super.init(frame: CGRect.zero)
        setup()
    }
    
    func setup() {
        doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.plain, target: self, action: #selector(doneClick))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        
        _inputAccessoryToolbar.setItems([ spaceButton, doneButton], animated: false)
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(launchPicker))
        self.addGestureRecognizer(tapRecognizer)
    }
    
    public func getToolbar()-> UIToolbar? {
        return _inputAccessoryToolbar
    }
    
    public func getDoneButton()-> UIBarButtonItem? {
        return doneButton
    }
    
    override public func resignFirstResponder() -> Bool {
        let resigned = super.resignFirstResponder()
        self.didResignFromFirstResponser?()
        return resigned
    }
    
    @objc func doneClick() {
        let _ = resignFirstResponder()
    }
    
    @objc func launchPicker() {
        self.becomeFirstResponder()
    }
    
}
