//
//  File.swift
//  
//
//  Created by Kembene Nkem on 7/25/22.
//

import Foundation
import UIKit

public struct DynamicKey: CodingKey{
    public var stringValue: String
    public var intValue: Int?
    
    public init?(stringValue: String) {
        self.stringValue = stringValue
    }
    
    public init?(intValue: Int) {
        self.intValue = intValue
        self.stringValue = "\(intValue)"
    }
}

public protocol Theming {
    var primaryColor: UIColor?{get}
    var borderRadius: CGFloat? {get}
    var borderWidth: CGFloat? {get}
    var borderColor: UIColor? {get}
    var textColor: UIColor? {get}
    var backgroundColor: UIColor? {get}
    var baseFont: UIFont? {get}
    var titleFont: UIFont? {get}
}

open class ResourceBundleConfiguration: Decodable{
    fileprivate var decodingContainer: KeyedDecodingContainer<DynamicKey>?
    fileprivate var defaultDecodingContainer: KeyedDecodingContainer<DynamicKey>?
    
    var prefix: String?
    
    public required init(from decoder: Decoder) throws {
        decodingContainer = try? decoder.container(keyedBy: DynamicKey.self)
    }
    
    fileprivate func performDecoding(){
        doPerformDecoding()
        decodingContainer = nil
        defaultDecodingContainer = nil
    }
    
    open func doPerformDecoding() {
        
    }
    
    public func string(key: String)-> String? {
        if let val = decodeData(key: key, type: String.self), val.hasText(){
            return val
        }
        return nil
    }
    
    public func int(key: String)-> Int? {
        return decodeData(key: key, type: Int.self)
    }
    
    public func double(key: String)-> Double? {
        return decodeData(key: key, type: Double.self)
    }
    
    public func bool(key: String)-> Bool? {
        return decodeData(key: key, type: Bool.self)
    }
    
    public func date(key: String)-> Date? {
        return decodeData(key: key, type: Date.self)
    }
    
    public func data(key: String)-> Data? {
        return decodeData(key: key, type: Data.self)
    }
    
    
    public func decodeData<T: Decodable>(key: String, type: T.Type)-> T?{
        let prefixedKey = "\(prefix ?? "")\(key)"
        return (try? decodingContainer?.decodeIfPresent(type, forKey: DynamicKey(stringValue: prefixedKey)!))
            ?? (try? decodingContainer?.decodeIfPresent(type, forKey: DynamicKey(stringValue: key)!))
            ?? (try? defaultDecodingContainer?.decodeIfPresent(type, forKey: DynamicKey(stringValue: key)!))
    }
}

public class ResourceName {
    var resourceName: String
    var replacedName: String?
    
    var value: String{
        return replacedName ?? resourceName
    }
    
    public init(resourceName: String){
        self.resourceName = resourceName
    }
    
    public func replaceWith(name: String){
        self.replacedName = name
    }
    
    public static func labelFont(fontName: String? = nil)-> UIFont? {
        if let fontName = fontName, fontName.hasText(), let font = UIFont(name: fontName, size: UIFont.labelFontSize){
            if #available(iOS 11.0, *) {
                return UIFontMetrics.default.scaledFont(for: font)
            } else {
                return font
            }
        }
        return nil
    }
}

open class BundleResourceLoader{
    var bundle: Bundle
    var resourcePrefix: String
    var fallbackBundle: Bundle?
    public init(loaderPrefix: String = "", bundle: Bundle, fallbackBundle: Bundle?) {
        self.bundle = bundle
        resourcePrefix = loaderPrefix
        self.fallbackBundle = fallbackBundle
    }
    
    public func localized(_ resource: String, comment: String = "", replacements: [String: String]? = nil)-> String {

        /// find the string first in the {prefixed}_Localizable string table of the bundle specified
        let prefixedTable = "\(resourcePrefix)Localizable"
        var value = _localized(resource, comment: comment, bundle: bundle, table: prefixedTable)
        if value == resource {
            let prefixedResource = "\(resourcePrefix)\(resource)"
            /// next find it the resource in Localizable with the resource name prefixed by the loader prefix
            value = _localized(prefixedResource, comment: comment, bundle: bundle)
            if value == prefixedResource {
                /// find the un-prefixed version on the resource, this time in the Localizable table
                value = _localized(resource, comment: comment, bundle: bundle)
                if value == resource && fallbackBundle != nil{
                    /// lastly find it using the primary resource name associated with the current bundle
                    value = _localized(resource, comment: comment, bundle: fallbackBundle!)
                }
            }
        }
        replacements?.enumerated().forEach { item in
            value = value.replacingOccurrences(of: "@@\(item.element.key)", with: item.element.value)
        }
        return value
    }
    
    fileprivate func _localized(_ resourceName: String, comment: String, bundle: Bundle, table: String? = nil)-> String {
        return NSLocalizedString(resourceName, tableName: table, bundle: bundle, comment: comment)
    }
    
    public func image(_ resource: ResourceName, defaultImage: UIImage? = nil)-> UIImage?{
        let prefixedResourceName = "\(resourcePrefix)\(resource.resourceName)"
        return _image(resource.value, defaultImage: nil, bundle: bundle)
        /// check if there is a resource that is prefixed
            ?? _image(prefixedResourceName, defaultImage: nil, bundle: bundle)
        /// else fallback to that defined in the module
            ?? _image(resource.resourceName, defaultImage: nil, bundle: fallbackBundle) ?? defaultImage
    }
    
    public func image(_ resource: String, defaultImage: UIImage? = nil)-> UIImage?{
        return _image(resource, defaultImage: nil, bundle: bundle)
            ?? _image(resource, defaultImage: nil, bundle: fallbackBundle) ?? defaultImage
    }
    
    fileprivate func _image(_ resourceName: String, defaultImage: UIImage? = nil, bundle: Bundle? = nil)-> UIImage? {
        if #available(iOS 13.0, *) {
            return UIImage(named: resourceName, in: bundle, with: nil) ?? defaultImage
        } else {
            if let image = UIImage(named: resourceName){
                return image
            }
            else if let url = bundle?.path(forResource: resourceName, ofType: "png"){
                return UIImage(contentsOfFile: url) ?? defaultImage
            }
        }
        return defaultImage
    }
    
    public func color(_ resource: ResourceName, defaultColor: UIColor? = nil)-> UIColor? {
        let prefixedResourceName = "\(resourcePrefix)\(resource.resourceName)"
        return _color(resource.value, defaultColor: nil, bundle: bundle)
        /// check if there is a resource that is prefixed
        ?? _color(prefixedResourceName, defaultColor: nil, bundle: bundle)
        /// else fallback to that defined in the module
        ?? _color(resource.resourceName, defaultColor: nil, bundle: fallbackBundle) ?? defaultColor
    }
    
    public func color(_ resource: String, defaultColor: UIColor? = nil)-> UIColor? {        
        return _color(resource, defaultColor: nil, bundle: bundle)
        /// else fallback to that defined in the module
        ?? _color(resource, defaultColor: nil, bundle: fallbackBundle) ?? defaultColor
    }
    
    fileprivate func _color(_ resourceName: String, defaultColor: UIColor? = nil, bundle: Bundle? = nil)-> UIColor? {
        if #available(iOS 13.0, *) {
            return UIColor(named: resourceName, in: bundle, compatibleWith: .current) ?? defaultColor
        } else if #available(iOS 11.0, *) {
            // Fallback on earlier versions
            return UIColor(named: resourceName) ?? defaultColor
        }
        return defaultColor
    }
    
    
}

open class BundlePoweredResourceLoader: BundleResourceLoader {
    var settingsFile: String?
    var fallbackSettingsFile: String?
    
    public init(loaderPrefix: String = "", bundle: Bundle, settingsFile: String?, fallbackSettingsFile: String?, fallbackBundle: Bundle?) {
        super.init(loaderPrefix: loaderPrefix, bundle: bundle, fallbackBundle: fallbackBundle)
        self.settingsFile = settingsFile
        self.fallbackSettingsFile = fallbackSettingsFile
    }
    
    public func loadConfiguration<T: ResourceBundleConfiguration>(type: T.Type)-> T?{
        return BundleSettingsInformation.loadSettings(prefix: self.resourcePrefix, settingsFile: settingsFile, fallbackSettingsFile: fallbackSettingsFile, type: type, bundle: bundle, fallbackBundle: fallbackBundle)
    }
    
}

public class BundleSettingsInformation: Decodable {
    var settingsPlistFile: String?
    
    fileprivate var settingsPlistFileKey: String?
    
    fileprivate var decodingContainer: KeyedDecodingContainer<DynamicKey>?
    required public init(from decoder: Decoder) throws {
        decodingContainer = try? decoder.container(keyedBy: DynamicKey.self)
    }
    
    fileprivate func performDecoding() {
        if let key = settingsPlistFileKey {
            self.settingsPlistFile = try? decodingContainer?.decodeIfPresent(String.self, forKey: DynamicKey(stringValue: key)!)
        }
        decodingContainer = nil
    }
    
    /// Loads configuration settings from a plist file, decoding each entry into an object of ResourceBundleConfiguration
    public static func loadSettings<T: ResourceBundleConfiguration>(prefix: String, settingsFile: String?, fallbackSettingsFile: String?, type: T.Type, bundle: Bundle, fallbackBundle: Bundle?)-> T?{
        
        var fallbackProvider: T? = nil
        var settingsProvider: T? = nil
        if let fallback = fallbackSettingsFile, let fallBundle = fallbackBundle {
            fallbackProvider = loadSettings(settingsFile: fallback, type: type, bundle: fallBundle)
        }
        if let settings = settingsFile {
            settingsProvider = loadSettings(settingsFile: settings, type: type, bundle: bundle)
            settingsProvider?.defaultDecodingContainer = fallbackProvider?.decodingContainer
        }
        else{
            settingsProvider = fallbackProvider
        }
        settingsProvider?.prefix = prefix
        settingsProvider?.performDecoding()
        return settingsProvider
        
    }
    
    public static func loadSettings<T: ResourceBundleConfiguration>(settingsFile: String, type: T.Type, bundle: Bundle)-> T?{
        let fileURL = bundle.url(forResource: settingsFile, withExtension: "plist")
        
        if let settingsURL = fileURL, let settingsData = try? Data(contentsOf: settingsURL) {
            guard let settings = try? PropertyListDecoder().decode(type, from: settingsData) else {
              return nil
            }
            return settings
        }
        else{
            return nil
        }
        
    }
}
