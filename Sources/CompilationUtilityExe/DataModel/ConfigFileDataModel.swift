//
//  ConfigFileDataModel.swift
//  CompilationUtility
//
//  Created by Roberto on 23/12/21.
//

import Foundation

class ConfigFileDataModel {
    let appName:String
    var servicesList:[ServiceDataModel]?
    
    init(appName:String){
        self.appName = appName
    }
}
