//
//  ServiceDataModel.swift
//  CompilationUtility
//
//  Created by Roberto on 23/12/21.
//

import Foundation

//NOTE: a giudicare da come sono scritti i file di configurazioen oggi sembra tutto opzionale a parte il nome del servizio
class ServiceDataModel {
    let name:String
    var skipSSL:Bool = false
    var baseUrl:String?
    var relativeUrls:[[String:String]]?
    var pinningCertificates:[String]?
    var wsOptionsArray:[String:[String]]?
    var wsOptions:[String:String]?
    
    init(name:String){
        self.name = name
    }
    
}
