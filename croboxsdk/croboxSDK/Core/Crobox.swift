//
//  Crobox.swift
//  croboxsdk
//
//  Created by idris yıldız on 22.05.2024.
//

import Foundation
import Alamofire
import SwiftyJSON

public class Crobox {
    
    /*
     croboxSDK instance
     */
    public static let shared = Crobox()
    
    /*
     enable or disable debug
     */
    public var isDebug = false
    
    /*
     have to setted when init SDK on app, it is
     */
    public var containerId = ""
    
    public func setContainerId(containerId:String) {
        self.containerId =  containerId
    }
    
    public func pageView(eventType:EventType!, queryParams: RequestQueryParams,
                  additionalParams:Any?,
                  closure: @escaping (_ isSuccess:Bool, _ jsonObject: JSON?) -> Void){
        CroboxAPIServices.shared.socket(eventType: eventType, additionalParams: additionalParams, queryParams: queryParams) { isSuccess, jsonObject in
            closure(isSuccess, jsonObject)
        }
    }
}
