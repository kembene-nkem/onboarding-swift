import Foundation
import Core

fileprivate var manager: FormManager?

public enum FormLabelPositioning{
    case topLeft
    case topRight
    case inline
    case none
}

/// The start point to the form management system. The FormManager holds necessary information that is shared among other parts of the form processing system
public class FormManager {
    var formTheme: FormTheming
    var resourceFinder: BundleResourceLoader
    var labelPositioning: FormLabelPositioning
    var defaultAssetPrefix = ""
    var formItemRenderers: [FormItemRenderer] = []
    var formatters: [String: FormItemFormatter] = [:]
    var validators: [String: FieldValidator] = [:]
    var resources: __FM_Resource
    
    
    public var fieldSpacing: FormSpacingConfig {
        return formTheme.fieldSpacing
    }
    
    public var rowSpacing: FormSpacingConfig{
        return formTheme.rowSpacing
    }
    
    public var sectionSpacing: FormSpacingConfig{
        return formTheme.sectionSpacing
    }
    
    public var defaultFormItemRenderer: FormItemRenderer = DefaultFormFieldItemRenderer()
    
    
    public var resourcePrefix: String {
        return defaultAssetPrefix
    }
    
    public var theme: FormTheming {
        return formTheme
    }
    
    public var labelPosition: FormLabelPositioning {
        return labelPositioning
    }
    
    public static var shared: FormManager {
        return manager!
    }
    
    public init(theme: FormTheming, resourceLoader: BundleResourceLoader, labelPositioning: FormLabelPositioning){
        self.formTheme = theme
        self.resourceFinder = resourceLoader
        self.labelPositioning = labelPositioning
        resources = (resourceLoader as? FormBundlePoweredResourceLoader)?.resources ?? __FM_Resource()
        self.registerFormatters(formatter: DefaultFormItemFormatter())
    }
    
    public func registerFormRenders(renderer: FormItemRenderer){
        self.formItemRenderers.append(renderer)
    }
    
    public func registerFormatters(formatter: FormItemFormatter){
        self.formatters[formatter.formatterName()] = formatter
    }
    
    public func registerValidator(validator: FieldValidator){
        self.validators[validator.getValidatorName()] = validator
    }
    
    public func resourceLoader()-> BundleResourceLoader?{
        return formTheme as? FormBundlePoweredResourceLoader
    }
    
    public static func configureDefaultManager(theme: FormTheming, resourceLoader: BundleResourceLoader, labelPositioning: FormLabelPositioning)-> FormManager {
        if manager == nil {
            manager = FormManager(theme: theme, resourceLoader: resourceLoader, labelPositioning: labelPositioning)
        }
        else{
            manager?.formTheme = theme
            manager?.resourceFinder = resourceLoader
            manager?.labelPositioning = labelPositioning
        }
        return manager!
    }
    
    
    public func setFormManagerPrefix(prefix: String){
        assert(prefix.hasText())
        defaultAssetPrefix = prefix
    }
    
}

extension Bundle {
    static var formManagerBundle: Bundle {
        return Bundle.module
    }
}
