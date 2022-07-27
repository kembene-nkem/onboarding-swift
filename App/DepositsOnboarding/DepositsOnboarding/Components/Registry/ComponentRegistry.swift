//
//  ComponentRegistry.swift
//  DepositsOnboarding
//
//  Created by Kembene Nkem on 7/26/22.
//

import Foundation

protocol ConfigurableComponent{
    func setupComponent()
}

class ComponentRegistry {
    fileprivate var registry: [ConfigurableComponent] = []
    
    static let instance = ComponentRegistry()
    
    var isInitialized = false
    
    static func initialize() {
        instance.initializeInstance()
        instance.setupComponents()
    }
    
    func initializeInstance() {
        if !isInitialized {
            registry.append(FormManagerComponent())
            registry.append(OnBoardingComponent())
            isInitialized = true
        }
    }
    
    func registerComponent(component: ConfigurableComponent){
        registry.append(component)
    }
    
    func setupComponents() {
        registry.forEach{$0.setupComponent()}
    }
}
