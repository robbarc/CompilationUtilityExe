//
//  main.swift
//  CompilationUtility
//
//  Created by Roberto on 15/12/21.
//

import Foundation

struct Constants {
     static let version: String = "0.1.0"
 }

//TODO:
// - fare un unico metodo per la scrittura di una stringa sul file che gestisca all'interno l'eccezione per evitare di dover scrivere ogni volta il try catch

func createWebServiceFile(_ serviceDataModel:ServiceDataModel) throws {

    ConfigFileManager.shared().createFile(fileName: serviceDataModel.name)
    try ConfigFileManager.shared().writeHeaderFile()
    try ConfigFileManager.shared().writeServiceFileContent(serviceDataModel)
    try ConfigFileManager.shared().writeFooterFile()
}

func writeFilesFromDataModel(_ dataModel: ConfigFileDataModel) throws {
    
    try ConfigFileManager.shared().createGlobalFile(fileName: "GlobalConfiguration", appName:dataModel.appName)
        
    guard let serviceDataList = dataModel.servicesList else {
        Logger.errorLog(errorMessage: "serviceDataList is nil!")
        exit(1)
    }
    
    for webServiceData in serviceDataList {
        try createWebServiceFile(webServiceData)
    }
}


//func createGlobalFile(fileName: String, appName:String) throws {
//
//    ConfigFileManager.shared().createFile(fileName: fileName)
//    try ConfigFileManager.shared().writeHeaderFile()
//    try ConfigFileManager.shared().writeRegistryParams(appName: appName)
//    try ConfigFileManager.shared().writeFooterFile()
//}

public func runConfig(){
    let startTime = CFAbsoluteTimeGetCurrent()
    //TODO capire come funziona dropFirst
    if (CommandLine.arguments.count != 3){
        Logger.errorLog(errorMessage: "E' necessario fornire il path del file di json di configurazione ed il path in cui salvare i relativi header di configurazione")
        exit(1)
    }
    
    let FileNamePath = CommandLine.arguments[1]
    Logger.infoLog(infoMessage: "Input File = \(FileNamePath)")

    let DirNamePath = CommandLine.arguments[2]
    Logger.infoLog(infoMessage: "Output Directory = \(DirNamePath)")
    
    guard let outputDirURL = URL(string: DirNamePath) else {
        Logger.errorLog(errorMessage: "Error in create output URL from string!")
        exit(1)
    }
    
    let outputDirURLFull = outputDirURL.appendingPathComponent("WSConfigurations")
    
    Logger.infoLog(infoMessage: "Starting Configuration", enableBox: true)
    
    ConfigFileManager.shared().createOutputDir(outputDirURL: outputDirURLFull)
    
    if (!ConfigFileManager.shared().checkFileExists(FileNamePath)){
        Logger.errorLog(errorMessage: "Input Configuration file not found!!")
        exit(1)
    }
    
    ConfigFileParser.shared().parse(fileNamePath: FileNamePath)
    guard let dataModel = ConfigFileParser.shared().dataModel else {
        Logger.errorLog(errorMessage: "DataModel is nil!!")
        exit(1)
    }
    
    do {
        try writeFilesFromDataModel(dataModel)
    } catch {
        Logger.errorLog(errorMessage: error.localizedDescription)
        exit(1)
    }
    
    //TODO eliminare solo per debug
    let endTime = CFAbsoluteTimeGetCurrent()
    print("DURATION = \(endTime-startTime)")
}

runConfig()


