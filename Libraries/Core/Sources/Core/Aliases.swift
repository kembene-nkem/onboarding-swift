//
//  File.swift
//  
//
//  Created by Kembene Nkem on 7/26/22.
//

import UIKit

public typealias EmptyCallback = () -> Void
public typealias ValueChangeCallback<T> = (_ val: T)-> Void
public typealias ValueSupplierCallback<V, T> = (_ val: V)->T?
