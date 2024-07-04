import Foundation
import SwiftyJSON
import Alamofire

class CroboxAPIServices {
    
    static let shared = CroboxAPIServices()
    
    func promotions(placeholderId:String!,
                    queryParams:RequestQueryParams,
                    productIds: Set<String>? = Set(),
                    closure: @escaping (_ result: Either<CroboxError, PromotionResponse>) -> Void) {

        //Mandatory
        var parameters = requestQueryParams(queryParams: queryParams)
        parameters["vpid"] = placeholderId!
        
        //Optional
        if let currencyCode = Crobox.shared.config.currencyCode {
            parameters["cc"] = currencyCode
        }
        if let localeCode = Crobox.shared.config.localeCode {
            parameters["lc"] = localeCode.rawValue
        }
        if let userId = Crobox.shared.config.userId {
            parameters["uid"] = userId
        }
        
        if let timezone = Crobox.shared.config.timezone {
            parameters["tz"] = "\(timezone)"
        }
        
        parameters["pt"] = "\(queryParams.pageType.rawValue)"
        
        if let pageName = queryParams.pageName {
            parameters["lh"] = pageName
        }
        
        //TODO
        //        if let customProperties = queryParams.customProperties {
        //            parameters["cp"] = customProperties
        //        }
        
        // URL oluşturma ve query parametrelerini ekleme
        guard var urlComponents = URLComponents(string:  "\(Constant.BASE_URL)\(Constant.Promotions_Path)") else {
            closure(.error(CroboxError.internalError(msg: "Failed to form promotions path")))
            return
        }
        
        urlComponents.queryItems = parameters.map { URLQueryItem(name: $0.key, value: $0.value) }
        
        guard let url = urlComponents.url else {
            closure(.error(CroboxError.internalError(msg: "Failed to form promotions parameters")))
            return
        }
        
        let bodyString = productIds?.enumerated().map { "\($0.offset)=\($0.element)" }.joined(separator: "&") ?? ""
        
        // Alamofire Request
        var urlRequest = URLRequest(url: url)
        urlRequest.method = .post
        urlRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = bodyString.data(using: .utf8)
        
        CroboxDebug.shared.printText(text: "POST \(url) - body: \(bodyString)")

        var promotionResponse:PromotionResponse!
        
        AF.request(urlRequest).responseData { response in
            switch response.result {
                
            case .success(let data):
                do {
                    if let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        if jsonObject["error"] == nil {
                            let jsonData = JSON(jsonObject)
                            CroboxDebug.shared.printText(text: jsonData)
                            promotionResponse = PromotionResponse(jsonData: jsonData)
                            closure(.success(promotionResponse))
                        } else {
                            closure(.error(CroboxError.invalidJSON(msg: "Error in \(jsonObject)")))

                        }
                    } else {
                        closure(.error(CroboxError.invalidJSON(msg: "Error in \(data)")))
                    }
                } catch {
                    closure(.error(CroboxError.internalError(msg: "\(response.result)")))
        
                }
            case .failure(let error):
                CroboxDebug.shared.printText(text: error)
                closure(.error(CroboxError.httpError(statusCode: response.response?.statusCode ?? -1, msg: "Http Error in \(response)")))
            }
        }
        .responseString { response in
          print("String:\(response.result)")
          switch(response.result) {
          case .success(_):
             if let data = response.value {
                print(data)
               }
                   
          case .failure(_):
              print("Error message:\(response)")
              break
           }
       }

    }
    
    func socket(eventType:EventType!,
                additionalParams:Any?,
                queryParams:RequestQueryParams,
                closure: @escaping (_ isSuccess:Bool, _ jsonObject: JSON?) -> Void) {
        
        //Mandatory
        var parameters = requestQueryParams(queryParams: queryParams)
        parameters["t"] = eventType.rawValue
        
        //Optional
        if let currencyCode =  Crobox.shared.config.currencyCode {
            parameters["cc"] = currencyCode
        }
        if let localeCode =  Crobox.shared.config.localeCode {
            parameters["lc"] = localeCode.rawValue
        }
        if let userId =  Crobox.shared.config.userId {
            parameters["uid"] = userId
        }
        if let timezone =  Crobox.shared.config.timezone {
            parameters["tz"] = "\(timezone)"
        }
        
        parameters["pt"] = "\(queryParams.pageType.rawValue)"
        
        if let pageName = queryParams.pageName {
            parameters["lh"] = pageName
        }
        
        //TODO
        //        if let customProperties = queryParams.customProperties {
        //            parameters["cp"] = customProperties
        //        }
        
        checkEventType(eventType:eventType,
                       additionalParams: additionalParams,
                       parameters: &parameters)
        
        APIRequests.shared.request(method: .get, url: Constant.Socket_Path , parameters: parameters ) {
            (jsonObject, success) in
            if success {
                closure(true, jsonObject)
            } else {
                closure(false, jsonObject)
            }
        }
    }
    
    private func requestQueryParams(queryParams:RequestQueryParams) -> [String: String] {
        return [
            "cid": Crobox.shared.config.containerId,
            "pid": "\(Crobox.shared.config.visitorId)",
            "e": "\(queryParams.viewCounter())",
            "vid": "\(queryParams.viewId)",
        ]
    }
}



// check for event type
extension CroboxAPIServices
{
    func checkEventType(eventType:EventType!, additionalParams: Any?, parameters: inout [String : String])
    {
        switch eventType {
        case .Click:
            if let clickParams = additionalParams as? ClickQueryParams {
                clickEvent(clickParams: clickParams, parameters: &parameters)
            }
            break
        case .AddCart, .RemoveCart:
            if let addCartQueryParams = additionalParams as? CartQueryParams {
                cartEvent(cartQueryParams: addCartQueryParams, parameters: &parameters)
            }
            break
        case .PageView:
            //TODO
            break
        case .Error:
            if let errorQueryParams = additionalParams as? ErrorQueryParams {
                errorEvent(errorQueryParams: errorQueryParams, parameters: &parameters)
            }
            break
        case .CustomEvent:
            if let customQueryParams = additionalParams as? CustomQueryParams {
                customEvent(customQueryParams: customQueryParams, parameters: &parameters)
            }
            break
        default:
            CroboxDebug.shared.eventError(error: "Unknown event type")
        }
    }
    
}


/*
 
 The following arguments are applicable for error events( where t=error ). They are all optional.
 
 */

extension CroboxAPIServices
{
    func errorEvent(errorQueryParams:ErrorQueryParams, parameters: inout [String : String])
    {
        if let tag = errorQueryParams.tag {
            parameters["tg"] = tag
        }
        if let name = errorQueryParams.name {
            parameters["nm"] = name
        }
        if let message = errorQueryParams.message {
            parameters["msg"] = message
        }
        if let file = errorQueryParams.file {
            parameters["f"] = file
        }
        if let line = errorQueryParams.line {
            parameters["l"] = "\(line)"
        }
    }
}


/*
 
 The following arguments are applicable for click events( where t=click ). They are all optional
 
 */

extension CroboxAPIServices
{
    func clickEvent(clickParams:ClickQueryParams, parameters: inout [String : String])
    {
        if let productId = clickParams.productId {
            parameters["pi"] = productId
        }
        if let price = clickParams.price {
            parameters["price"] = "\(price)"
        }
        if let quantity = clickParams.quantity {
            parameters["qty"] = "\(quantity)"
        }
    }
}


/*
 
 The following arguments are applicable for AddToCart events( where t=cart ). They are all optional
 
 */

extension CroboxAPIServices
{
    func cartEvent(cartQueryParams:CartQueryParams, parameters: inout [String : String])
    {
        if let productId = cartQueryParams.productId {
            parameters["pi"] = productId
        }
        if let price = cartQueryParams.price {
            parameters["price"] = "\(price)"
        }
        if let quantity = cartQueryParams.quantity {
            parameters["qty"] = "\(quantity)"
        }
    }
}

/*
 
 The following arguments are applicable for click events( where t=event ). They are all optional
 
 */

extension CroboxAPIServices
{
    func customEvent(customQueryParams:CustomQueryParams, parameters: inout [String : String])
    {
        if let name = customQueryParams.name {
            parameters["nm"] = name
        }
        if let promotionID = customQueryParams.promotionId {
            parameters["promoId"] = "\(promotionID)"
        }
        if let productID = customQueryParams.productId {
            parameters["pi"] = productID
        }
        if let price = customQueryParams.price {
            parameters["price"] = "\(price)"
        }
        if let quantity = customQueryParams.quantity {
            parameters["qty"] = "\(quantity)"
        }
    }
}



