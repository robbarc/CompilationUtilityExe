//
//  ConfigFileManager.swift
//  CompilationUtility
//
//  Created by Roberto on 15/12/21.
//

import Foundation

class ConfigFileManager{
    var outputDirURL: URL?
    var headerSectionWritten:Bool = false
    var fileNameURL: URL? {
        guard let fileName = fileName else {
            print("FileName not yet set!")
            return nil
        }
        guard let fileNameURL = URL(string:(outputDirURL!.path+"/\(String(describing: fileName))"+".h")) else {
            print("outputDirURL not yet set!")
            return nil
        }
        return fileNameURL
    }
    
    var fileName:String?
    
    private static var sharedInstance: ConfigFileManager = {
           let instance = ConfigFileManager()

           return instance
       }()
    
    private init(){
        outputDirURL = nil
        fileName = nil
    }
    
    class func shared() -> ConfigFileManager {
        return sharedInstance
    }
    
    func checkFileExists(_ FilePath:String) -> Bool {
        return FileManager.default.fileExists(atPath: FilePath)
    }
                                              
    func createOutputDir(outputDirURL:URL){
        
        if (FileManager.default.fileExists(atPath: outputDirURL.path)){
            do {
                Logger.infoLog(infoMessage: "Directory \(outputDirURL.path) already exists!!!")
                try FileManager.default.removeItem(atPath: outputDirURL.path)
                
                //TODO valutare se si risparmia tempo rimuovendo solo i file nella directory ed evitando di ricrearla, ma non credo
                Logger.infoLog(infoMessage: "Removing Directory \(outputDirURL.path)")
                
            } catch {
                Logger.errorLog(errorMessage: "Error in removing Directory: \(error)")
                exit(1)
            }
        }
     
        do {
            try FileManager.default.createDirectory(atPath: outputDirURL.path, withIntermediateDirectories: true, attributes: nil)
            Logger.infoLog(infoMessage: "Creating directory ==> \(outputDirURL.path)")
        } catch {
            Logger.errorLog(errorMessage: "You don't have permissions to write on ==> \(outputDirURL.path)")
            exit(1)
        }
        
        self.outputDirURL = outputDirURL
    }
    
    //MARK: write file methods
    func createFile(fileName: String){
        
        self.fileName = fileName
        
        print("Creating \(fileName) file ...")
        
        guard let fileNameURL = fileNameURL else {
            Logger.errorLog(errorMessage: "Unable to create file Path URL!")
            exit(1)
        }
        
        if (FileManager.default.createFile(atPath: fileNameURL.path, contents: nil, attributes: nil)) {
            
            print("File \(fileNameURL.path) has been created!")
        } else {
            Logger.errorLog(errorMessage: "An error occured while creating \(fileNameURL.lastPathComponent) file")
            exit(1)
        }
    }
    
    func writeHeaderFile() throws {
        
        let version = Constants.version
        
        if self.headerSectionWritten {
            Logger.errorLog(errorMessage: "Header Section Already written!!")
            exit(1)
        }
        
        guard let fileName = fileName else {
            Logger.errorLog(errorMessage: "File Name is nil!!")
            exit(1)
        }
        
        guard let fileNameURL = fileNameURL else {
            Logger.errorLog(errorMessage: "File Path URL is nil!!")
            exit(1)
        }
        
        Logger.infoLog(infoMessage: "Writing \(fileName) file ...", enableBox: true)

        //TODO ottimizzare per evitare l'apertura e chiusura del file per scrivere ogni riga, magari definire una sola stringa anche se meno leggibile

        try ("//\n" +
                "// \(fileName).h \n" +
                 "//\n" +
                 "// Codice autogenerato da CompilationUtility versione \(version)\n" +
                 "// NON EDITARE QUESTO FILE, le modifiche andranno perse con la prossima compilazione\n" +
                 "//\n\n" +
                 "#ifndef \(fileName)_h\n" +
                 "#define \(fileName)_h\n\n\n").appendToURL(fileURL: fileNameURL)

        self.headerSectionWritten = true;
    }
    
    func writeFooterFile() throws {
        
        if (!self.headerSectionWritten){
            Logger.errorLog(errorMessage: "File Header is not already written!!")
            exit(1)
        }
        
        guard let fileName = fileName else {
            Logger.errorLog(errorMessage: "File Name is nil!!")
            exit(1)
        }
        
        guard let fileNameURL = fileNameURL else {
            Logger.errorLog(errorMessage: "File Path URL is nil!!")
            exit(1)
        }
        
        try "\n#endif /*\(fileName)_h */".appendToURL(fileURL: fileNameURL)
        
        self.fileName = nil
        self.headerSectionWritten = false
        
        Logger.infoLog(infoMessage: "Done Writing \(fileName)", enableBox: true)
    }
    
    //MARK: Global file write methods
    func createGlobalFile(fileName: String, appName:String) throws {
            
        createFile(fileName: fileName)
        try writeHeaderFile()
        try writeRegistryParams(appName: appName)
        try writeFooterFile()
    }
    
    func writeRegistryParams(appName: String) throws {
        
        if (!self.headerSectionWritten){
            Logger.errorLog(errorMessage: "File Header is not already written!!")
            exit(1)
        }
        
        guard fileName != nil else {
            Logger.errorLog(errorMessage: "File Name is nil!!")
            exit(1)
        }
        
        guard let fileNameURL = fileNameURL else {
            Logger.errorLog(errorMessage: "File Path URL is nil!!")
            exit(1)
        }
        
        try ("// ATTENZIONE: I SEGUENTI PARAMETRI SONO OBBLIGATORI E DEVONO ESSERE SPECIFICATI NEL JSON DI CONFIGURAZIONE NELLA ROOT DEL JSON \n" +
            "// appName \n" +
            "//\n" +
            "/* ESEMPIO DI CONFIGURAZIONE \n\t\t\"appRegistry\": {\n\t\t\t\"appName\" : \"app-up\",\n\t\t} */ \n\n" +
        
             "// AppRegistry params configuration \n" +
        
             "#define kAppNameRegistry @\"\(appName)\"\n").appendToURL(fileURL: fileNameURL)
            
            print("kAppNameRegistry => \(appName)")
    }
    
    //MARK: Service file write methods
    func skipSSL(_ serviceDataModel:ServiceDataModel) throws {
        
        if (!self.headerSectionWritten){
            Logger.errorLog(errorMessage: "File Header is not already written!!")
            exit(1)
        }
        
        guard let fileName = fileName else {
            Logger.errorLog(errorMessage: "File Name is nil!!")
            exit(1)
        }
        
        guard let fileNameURL = fileNameURL else {
            Logger.errorLog(errorMessage: "File Path URL is nil!!")
            exit(1)
        }
        
        let skipSLL = serviceDataModel.skipSSL
            
        print("Web service SkipSSL: \(skipSLL)")
        if(skipSLL){
            let skipSSLString = skipSLL ? "1": "0"
            try ("// SkipSSL Policy \n" +
                "#define kSkipSSL\(fileName) \(skipSSLString)\n\n").appendToURL(fileURL: fileNameURL)
        }
    }
    
    func baseUrl(_ serviceDataModel:ServiceDataModel) throws {
        
        if (!self.headerSectionWritten){
            Logger.errorLog(errorMessage: "File Header is not already written!!")
            exit(1)
        }
        
        guard let fileName = fileName else {
            Logger.errorLog(errorMessage: "File Name is nil!!")
            exit(1)
        }
        
        guard let fileNameURL = fileNameURL else {
            Logger.errorLog(errorMessage: "File Path URL is nil!!")
            exit(1)
        }
        
        if let baseUrl = serviceDataModel.baseUrl {
            
            print("Web service baseurl: \(baseUrl)")
            
            try ("\n// BaseURL per \(fileName)\n" +
                "#define kBaseURL\(fileName) @\"\(baseUrl)\"\n").appendToURL(fileURL: fileNameURL)
        }
    }
    
    func relativeUrls(_ serviceDataModel:ServiceDataModel) throws {
        
        if (!self.headerSectionWritten){
            Logger.errorLog(errorMessage: "File Header is not already written!!")
            exit(1)
        }
        
        guard let fileName = fileName else {
            Logger.errorLog(errorMessage: "File Name is nil!!")
            exit(1)
        }
        
        guard let fileNameURL = fileNameURL else {
            Logger.errorLog(errorMessage: "File Path URL is nil!!")
            exit(1)
        }
        
        if let relativeUrls = serviceDataModel.relativeUrls {

            print("Web service relativeUrls:")
            
            try "\n// RelativeURL per \(fileName)\n".appendToURL(fileURL: fileNameURL)
            
            for relativeUrl in relativeUrls {
                    
                let urlName = relativeUrl["name"]!
                let urlValue = relativeUrl["relurl"]!
                
                try "#define k\(urlName)RelativeURL @\"\(urlValue)\"\n".appendToURL(fileURL: fileNameURL)
                
                print("relativeURL : \(urlName) ==> \( urlValue)");
            }
        }
    }
    
    func pinningCertificates(_ serviceDataModel: ServiceDataModel) throws {
        
        if (!self.headerSectionWritten){
            Logger.errorLog(errorMessage: "File Header is not already written!!")
            exit(1)
        }
        
        guard let fileName = fileName else {
            Logger.errorLog(errorMessage: "File Name is nil!!")
            exit(1)
        }
        
        guard let fileNameURL = fileNameURL else {
            Logger.errorLog(errorMessage: "File Path URL is nil!!")
            exit(1)
        }
        
        if let pinningCertificatesJson = serviceDataModel.pinningCertificates {
            
            var certificatesString = "@["
            var count = 0
            
            for pinningCertificate in pinningCertificatesJson {
                
                print("Certificate name : \(pinningCertificate)")
                certificatesString += "@\"\(pinningCertificate)\""
                
                if(count < pinningCertificatesJson.count-1){
                    certificatesString += ", "
                }
                count += 1
            }
            
            certificatesString += "]"
            
            try ("\n// Pinning certificates for \(fileName)\n" +
                "#define k\(fileName)CertificatesPinning \(certificatesString)\n").appendToURL(fileURL: fileNameURL)
            
            print("Web service CertificatesPinning => \(certificatesString)")
            
        } else {
            
            try ("\n// NO Pinning certificates defined for \(fileName)\n" +
                 "#define k\(fileName)CertificatesPinning @[]\n").appendToURL(fileURL: fileNameURL)
            
            print("Web service CertificatesPinning => @[]")
        }
    }
    
    func wsOptionsArray(_ serviceDataModel:ServiceDataModel) throws {
        
        if (!self.headerSectionWritten){
            Logger.errorLog(errorMessage: "File Header is not already written!!")
            exit(1)
        }
        
        guard let fileName = fileName else {
            Logger.errorLog(errorMessage: "File Name is nil!!")
            exit(1)
        }
        
        guard let fileNameURL = fileNameURL else {
            Logger.errorLog(errorMessage: "File Path URL is nil!!")
            exit(1)
        }
        
        if let wsOptionsJson = serviceDataModel.wsOptionsArray {
            
            try "\n// WSOptionsArray defined for \(fileName)\n".appendToURL(fileURL: fileNameURL)
            
            for (wsOptionKeyArray, wsOptionValueArray) in wsOptionsJson {
                
                print("OptionsArray Key: \(wsOptionKeyArray)")
                var wsOptionsString = "@["
                var count = 0
                
                for wsOption in wsOptionValueArray {
                    print("OptionsArray Value: \(wsOption)")
                    wsOptionsString += "@\"\(wsOption)\""
                    
                    if(count < wsOptionValueArray.count-1){
                        wsOptionsString += ", "
                    }
                    count += 1
                }
                
                wsOptionsString += "]"
                
                    //NOTE ho modificato la stampa aggiungendo la chiave perchè credo che in java sia stata dimenticata
                try ("\n// WSOptionsArray \(wsOptionKeyArray) for \(fileName)\n" +
                         "#define k\(fileName)\(wsOptionKeyArray) \(wsOptionsString)\n").appendToURL(fileURL: fileNameURL)
                
                print("Web service WSOptionsArray => \(wsOptionsString)")
            }

        } else {
            try ("\n// WSOptionsArray defined for \(fileName)\n" +
                     "\n// NO Object Arrays defined for \(fileName)\n" +
                     "#define k\(fileName)ObjectsArray @[]\n").appendToURL(fileURL: fileNameURL)
            
            print("Web service WSOptionsArray => @[]")
        }
    }
    
    func wsOptions(_ serviceDataModel: ServiceDataModel) throws {
        
        if (!self.headerSectionWritten){
            Logger.errorLog(errorMessage: "File Header is not already written!!")
            exit(1)
        }
        
        guard let fileName = fileName else {
            Logger.errorLog(errorMessage: "File Name is nil!!")
            exit(1)
        }
        
        guard let fileNameURL = fileNameURL else {
            Logger.errorLog(errorMessage: "File Path URL is nil!!")
            exit(1)
        }
        
        if let wsOptionsJson = serviceDataModel.wsOptions {
            
            print("Web service WSOptions:")
            
            try "\n// WSOptions defined for \(fileName)\n".appendToURL(fileURL: fileNameURL)
            
            for (wsOptionKey, wsOptionValue) in wsOptionsJson {
                
                try "#define k\(fileName)\(wsOptionKey)WSOptions @\"\(wsOptionValue)\"\n".appendToURL(fileURL: fileNameURL)
                
                print("wsOption : \(wsOptionKey) => \( wsOptionValue)");
            }

        } else {
            
            //TODO secondo me è una duplicazione, ma lo lascio per fare esattamente come l'utility java
            try ("\n// WSOptions defined for \(fileName)\n" +

                 "\n// NO options defined for \(fileName)\n" +

            //TODO: non so quanto sia coerente a differenza del caso di wsOptionsArray perchè in quel caso sia che il campo ci sia nel json o meno si tratta sempre di un array, qui in assenza di campo sembra un dizionario vuoto, ma se c'è il campo viene tradotto un una serie di semplici define di stringhe
                 "#define k\(fileName)Options @{}\n").appendToURL(fileURL: fileNameURL)

            
            print("Web service WSOptions: @{}")
        }
    }
    
    func writeServiceFileContent(_ serviceDataModel:ServiceDataModel) throws {

        if (!self.headerSectionWritten){
            Logger.errorLog(errorMessage: "File Header is not already written!!")
            exit(1)
        }
        
        guard fileName != nil else {
            Logger.errorLog(errorMessage: "File Name is nil!!")
            exit(1)
        }
        
        guard fileNameURL != nil else {
            Logger.errorLog(errorMessage: "File Path URL is nil!!")
            exit(1)
        }
        
        try skipSSL(serviceDataModel)
        try baseUrl(serviceDataModel)
        try relativeUrls(serviceDataModel)
        try pinningCertificates(serviceDataModel)
        try wsOptionsArray(serviceDataModel)
        try wsOptions(serviceDataModel)
    }

}
