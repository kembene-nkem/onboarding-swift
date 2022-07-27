//
//  File.swift
//  
//
//  Created by Kembene Nkem on 7/27/22.
//

import Foundation
import Core
import UIKit

public protocol OnboardingTheming: Theming {
    
}

public class OnboardingComponentConfiguration: ResourceBundleConfiguration{
    fileprivate var decodingContainer: KeyedDecodingContainer<DynamicKey>?
    fileprivate var defaultDecodingContainer: KeyedDecodingContainer<DynamicKey>?
    
    public var defaultFontName: String?
    public var borderWidth: Double?
    public var borderRadius: Double?
    public var horizontalEdge: Double?
    public var verticalEdge: Double?
    
    open override func doPerformDecoding(){
        defaultFontName = string(key: __OB_Config_Keys.fontName)
        borderRadius = double(key: __OB_Config_Keys.borderRadius)
        borderWidth = double(key: __OB_Config_Keys.borderWidth)
        horizontalEdge = double(key: __OB_Config_Keys.controllerHorizontalEdge)
        verticalEdge = double(key: __OB_Config_Keys.controllerVerticalEdge)
    }
    
    public func labelFont()-> UIFont? {
        return ResourceName.labelFont(fontName: defaultFontName)
    }    
}

public class OnboardingComponentResourceLoader: BundlePoweredResourceLoader {
    
    private var _baseFont: UIFont?
    private var _titleFont: UIFont?
    
    var config: OnboardingComponentConfiguration?
    
    var resources: __OnboardingResource
    
    var configuration: OnboardingComponentConfiguration?{
        return config
    }
    
    public init(prefix: String = "", bundle: Bundle, settingsFile: String, resource: __OnboardingResource? = nil) {
        self.resources = resource ?? __OnboardingResource()
        super.init(loaderPrefix: prefix, bundle: bundle, settingsFile: settingsFile, fallbackSettingsFile: "onboarding_configuration", fallbackBundle: Bundle.module)
        self.config = self.loadConfiguration(type: OnboardingComponentConfiguration.self)
    }
    
    public func getResources()-> __OnboardingResource{        
        return resources
    }
    
    public func setBaseFont(font: UIFont){
        self._baseFont = font
    }
    
    public func setTitleFont(font: UIFont){
        self._titleFont = font
    }
    
    
}


extension OnboardingComponentResourceLoader: OnboardingTheming{
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
