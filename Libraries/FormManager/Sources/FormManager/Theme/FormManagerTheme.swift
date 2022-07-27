//
//  File.swift
//  
//
//  Created by Kembene Nkem on 7/25/22.
//

import Foundation
import UIKit
import Core

public protocol FormTheming: Theming {
    var fieldSpacing: FormSpacingConfig{get set}
    var rowSpacing: FormSpacingConfig{get set}
    var sectionSpacing: FormSpacingConfig{get set}
}


public class BundleFormPoweredConfiguration: ResourceBundleConfiguration {
    public var defaultFontName: String?
    public var borderWidth: Double?    
    public var borderRadius: Double?
    
    open override func doPerformDecoding(){
        defaultFontName = string(key: __FM_Config_Keys.fontName)
        borderRadius = double(key: __FM_Config_Keys.borderRadius)
        borderWidth = double(key: __FM_Config_Keys.borderWidth)
    }
    
    public func labelFont()-> UIFont? {
        return ResourceName.labelFont(fontName: defaultFontName)
    }
}


public class FormBundlePoweredResourceLoader: BundlePoweredResourceLoader {
    
    private var _baseFont: UIFont?
    private var _titleFont: UIFont?
    
    public var fieldSpacing: FormSpacingConfig = FormSpacingConfig(top: 5, bottom: 5, leading: 5, trailing: 5, height: 30, horizontal: 10, vertical: 10)
    public var rowSpacing: FormSpacingConfig = FormSpacingConfig(bottom: 15, vertical: 15)
    public var sectionSpacing: FormSpacingConfig = FormSpacingConfig(vertical: 30)
    
    var config: BundleFormPoweredConfiguration?
    
    var resources: __FM_Resource
    
    var configuration: BundleFormPoweredConfiguration?{
        return config
    }
    
    public init(prefix: String = "", bundle: Bundle, settingsFile: String, resource: __FM_Resource? = nil) {
        self.resources = resource ?? __FM_Resource()
        super.init(loaderPrefix: prefix, bundle: bundle, settingsFile: settingsFile, fallbackSettingsFile: "form_manager_settings", fallbackBundle: Bundle.formManagerBundle)
        self.config = self.loadConfiguration(type: BundleFormPoweredConfiguration.self)
    }
    
    public func getResources()-> __FM_Resource{
        return resources
    }
    
    
    public func setBaseFont(font: UIFont){
        self._baseFont = font
    }
    
    public func setTitleFont(font: UIFont){
        self._titleFont = font
    }
    
}



extension FormBundlePoweredResourceLoader: FormTheming{
    
    public var primaryColor: UIColor? {
        return self.color(resources.Asset.primaryColor)
    }
    
    public var borderRadius: CGFloat? {
        if let radius = configuration?.borderRadius{
            return CGFloat(radius)
        }
        return nil
    }
    
    public var borderWidth: CGFloat? {
        if let radius = configuration?.borderWidth{
            return CGFloat(radius)
        }
        return nil
    }
    
    public var borderColor: UIColor? {
        return self.color(resources.Asset.borderColor)
    }
    
    public var textColor: UIColor? {
        return self.color(resources.Asset.textColor)
    }
    
    public var backgroundColor: UIColor? {
        return self.color(resources.Asset.backgroundColor)
    }
    
    public var baseFont: UIFont? {
        return _baseFont ?? configuration?.labelFont()
    }
    
    public var titleFont: UIFont? {
        return _titleFont ?? baseFont?.step(by: -1)
    }
}


extension String {
    public var fm_Resource: BundleResourceLoader? {
        return FormManager.shared.resourceLoader()
    }
}
