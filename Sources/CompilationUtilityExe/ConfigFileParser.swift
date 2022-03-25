//
//  ConfigFileParser.swift
//  CompilationUtility
//
//  Created by Roberto on 23/12/21.
//

import Foundation

class ConfigFileParser{
    
    var dataModel:ConfigFileDataModel?
    
    private static var sharedInstance: ConfigFileParser = {
           let instance = ConfigFileParser()

           return instance
       }()
    
    private init(){
    }
    
    class func shared() -> ConfigFileParser {
        return sharedInstance
    }
    
    func parse(fileNamePath: String){
        
        Logger.infoLog(infoMessage: "Parsing Configuration File", enableBox: true)
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: fileNamePath), options: .mappedIfSafe)
            let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
            if let jsonResult = jsonResult as? Dictionary<String, AnyObject> {
                
                parseAppName(jsonObject:jsonResult)
                
                if let webServicesJson = jsonResult["webservices"] as? Array<Dictionary<String, AnyObject>> {
                    
                    self.dataModel?.servicesList = [ServiceDataModel]()
                    for webServiceJson in webServicesJson {

                        parseWebService(jsonObject: webServiceJson)
                    }
                    
                } else {
                    //TODO: devo considerare mandatorio "webservices"?
                    print("No webservices")
                    return
                }

            }
        } catch let error as NSError {
            Logger.errorLog(errorMessage: error.localizedDescription)
            exit(1)
        }
    }
    
    private func parseAppName(jsonObject:Dictionary<String, AnyObject>){
        
        if let registryParams = jsonObject["appRegistry"] as? Dictionary<String, AnyObject> {
            
            guard let appName = registryParams["appName"] as? String else {
                Logger.errorLog(errorMessage: "appName field not found!")
                exit(1)
            }
            
            self.dataModel = ConfigFileDataModel(appName: appName)
            
            if let appName = self.dataModel?.appName {
                Logger.infoLog(infoMessage: "Parse appName: \(appName)")
            }
        }
    }
    
    private func parseWebService(jsonObject:Dictionary<String, AnyObject>){
        
        if let serviceName = jsonObject["name"] as? String {
            
            let serviceData = ServiceDataModel(name: serviceName)
            Logger.infoLog(infoMessage: "Parse webService name : \(serviceData.name)", enableBox: true)
            
            parseSkipSSL(jsonObject: jsonObject, serviceData: serviceData)
            parseBaseUrl(jsonObject: jsonObject, serviceData: serviceData)
            parseRelativeUrls(jsonObject: jsonObject, serviceData: serviceData)
            parsePinningCertificates(jsonObject: jsonObject, serviceData: serviceData)
            parseWsOptions(jsonObject: jsonObject, serviceData: serviceData)
            parseWsOptionsArray(jsonObject: jsonObject, serviceData: serviceData)
            
            self.dataModel?.servicesList?.append(serviceData)
            
        } else {
            Logger.errorLog(errorMessage: "webService name field not found!")
            exit(1)
        }
    }
    
    private func parseSkipSSL(jsonObject:Dictionary<String, AnyObject>, serviceData:ServiceDataModel) {
        
        if let skipSLL = jsonObject["skipSSL"] as? Bool {
            
            serviceData.skipSSL = skipSLL
            Logger.infoLog(infoMessage: "Parse webService skipSSL: \(serviceData.skipSSL)")

        }
    }
    
    private func parseBaseUrl(jsonObject:Dictionary<String, AnyObject>, serviceData:ServiceDataModel) {
        
        if let baseUrl = jsonObject["baseurl"] as? String {
            
            serviceData.baseUrl = baseUrl
            if let baseURL = serviceData.baseUrl {
                Logger.infoLog(infoMessage: "Parse webService baseUrl: \(baseURL)")
            }
        }
    }
    
    private func parseRelativeUrls(jsonObject:Dictionary<String, AnyObject>, serviceData:ServiceDataModel){
        
        if let relativeUrls = jsonObject["relativeUrls"] as? Array<AnyObject> {
                
            serviceData.relativeUrls = [[String:String]]()
            for relativeUrl in relativeUrls {
                
                if let relativeUrl = relativeUrl as? Dictionary<String, String> {
                    
                    let urlName = relativeUrl["name"]!
                    let urlValue = relativeUrl["relurl"]!
                    
                    if ((!urlName.isEmpty)&&(!urlValue.isEmpty)){
                        serviceData.relativeUrls?.append(["name":urlName,"relurl":urlValue])
                    } else {
                        Logger.errorLog(errorMessage: "webService relativeUrl not valid for \(serviceData.name)")
                        exit(1)
                    }
                    
                    print("relativeUrl: \(urlName) ==> \( urlValue)");
                } else {
                    Logger.errorLog(errorMessage: "webService relativeUrl not valid for \(serviceData.name)")
                    exit(1)
                }
            }
            
            if let relativeUrls = serviceData.relativeUrls {
                Logger.infoLog(infoMessage: "Parse webService relativeUrls: \(String(describing: relativeUrls))")
            }
        } else {
            //TODO lo devo considerare mandatorio?
            return
        }
    }
    
    private func parseWsOptions(jsonObject:Dictionary<String, AnyObject>, serviceData:ServiceDataModel){
        
        if let wsOptionsJson = jsonObject["wsOptions"] as? Dictionary<String, String> {
            
            serviceData.wsOptions = [String:String]()
            for (wsOptionKey, wsOptionValue) in wsOptionsJson {
                
                if ((!wsOptionKey.isEmpty)&&(!wsOptionValue.isEmpty)){
                    serviceData.wsOptions?[wsOptionKey] = wsOptionValue
                    print( "Parse webservice wsOption: \(wsOptionKey) ==> \(wsOptionValue)")
                }
            }
        }
        if let wsOptions = serviceData.wsOptions {
            Logger.infoLog(infoMessage: "Parse webService wsOptions : \(String(describing: wsOptions))")
        }
    }
    
    private func parseWsOptionsArray(jsonObject:Dictionary<String, AnyObject>, serviceData:ServiceDataModel){
        
        if let wsOptionsJson = jsonObject["wsOptionsArray"] as? Dictionary<String, Array<String>> {
            
            serviceData.wsOptionsArray = [String:[String]]()
            for (wsOptionKeyArray, wsOptionValueArray) in wsOptionsJson {
                
                print("OptionArray Key: \(wsOptionKeyArray)")
                
                var arrayValue = [String]()
                for wsOption in wsOptionValueArray {
                    print("OptionArray Value: \(wsOption)")
  
                    arrayValue.append(wsOption)
                }
                serviceData.wsOptionsArray?[wsOptionKeyArray] = arrayValue
            }

        }
        
        if let optionsArray = serviceData.wsOptionsArray {
            Logger.infoLog(infoMessage: "Parse webService wsOptionsArray : \(String(describing: optionsArray))")
        }
    }
    
    private func parsePinningCertificates(jsonObject:Dictionary<String, AnyObject>, serviceData:ServiceDataModel){
        
        if let pinningCertificatesJson = jsonObject["pinningCertificates"] as? Array<String> {
            
            serviceData.pinningCertificates = [String]()
            
            for pinningCertificate in pinningCertificatesJson {
                
                if(!pinningCertificate.isEmpty){
                    serviceData.pinningCertificates?.append(pinningCertificate)
                    print( "pinningCertificate: \(pinningCertificate)")
                }
            }
            
            if let pinningCertificates = serviceData.pinningCertificates {
                Logger.infoLog(infoMessage: "Parse webService pinningCertificates: \(pinningCertificates)")
            }
        }
    }
}
