//
//  Logger.swift
//  certificateCheck
//
//  Created by Roberto on 21/12/21.
//

import Foundation

class Logger {
    
    static func errorLog(errorMessage:String){
        print("[ERRORE]:"+errorMessage)
    }
    
    static func infoLog(infoMessage:String, enableBox: Bool = false){
        if (enableBox) {
            print("******************************************************")
        }
        print("[INFO]:"+infoMessage)
        if (enableBox){
            print("******************************************************")
        }
    }
}
