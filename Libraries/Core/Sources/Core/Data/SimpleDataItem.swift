//
//  File.swift
//  
//
//  Created by Kembene Nkem on 7/26/22.
//

import Foundation
import UIKit
public protocol SimpleDataItem {
    func getItemLabel()->String
    func getItemImage()-> UIImage?
    func getItemDescription()-> String?
    func getTitleAttribute()-> NSAttributedString?
    func getDescriptionAttribute()-> NSAttributedString?
    func bindToImage(imageView: UIImageView?)
}


extension SimpleDataItem{
    public func getItemImage()-> UIImage? {
        return nil
    }
    public func getItemDescription()-> String? {
        return nil
    }
    
    public func getTitleAttribute()-> NSAttributedString? {
        return nil
    }
    public func getDescriptionAttribute()-> NSAttributedString? {
        return nil
    }
    public func bindToImage(imageView: UIImageView?){
        
    }
}

public class DefaultSimpleDataItem: SimpleDataItem {
    var title: String
    var description: String?
    var image: UIImage?
    var titleAttribute: NSAttributedString?
    var descriptionAttribute: NSAttributedString?
    
    public init(title: String, description: String? = nil, image: UIImage? = nil, titleAttr: NSAttributedString? = nil, descAttr: NSAttributedString? = nil) {
        self.title = title
        self.description = description
        self.image = image
        self.titleAttribute = titleAttr
        self.descriptionAttribute = descAttr
    }
    
    public func getItemLabel()->String {
        return title
    }
    public func getItemImage()-> UIImage? {
        return image
    }
    public func getItemDescription()-> String? {
        return description
    }
    public func getTitleAttribute()-> NSAttributedString? {
        return titleAttribute
    }
    public func getDescriptionAttribute()-> NSAttributedString? {
        return descriptionAttribute
    }
}

extension String: SimpleDataItem {
    public func getItemLabel()->String{
        return self
    }
}
