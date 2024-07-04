import Foundation
import SwiftyJSON
import Alamofire

class CroboxAPIServices {
    
    static let shared = CroboxAPIServices()
    
    func promotions(placeholderId:String!,
                    queryParams:RequestQueryParams,
                    productIds: Set<String>? = Set(),
                    closure: @escaping (_ isSuccess:Bool, _ promotionResponse: PromotionResponse?) -> Void) {
        
        
        //Mandatory
        var parameters = [
            "cid": Crobox.shared.config.containerId,
            "e": "\(queryParams.viewCounter())",
            "vid": "\(queryParams.viewId)",
            "pid": "\(Crobox.shared.config.visitorId)",
            "vpid": placeholderId!
        ] as [String : String]
        
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
       
        let millis = Int64(Date().timeIntervalSince1970 * 1000)
        parameters["ts"] = CroboxEncoder.shared.toBase36(millis: millis)

        if let pageName = queryParams.pageName {
            parameters["lh"] = pageName
        }
        
        if let customProperties = queryParams.customProperties {
            for (key, value) in customProperties {
                parameters["cp.\(key)"] = value
            }
        }
        
        // URL oluşturma ve query parametrelerini ekleme
        guard var urlComponents = URLComponents(string:  "\(Constant.BASE_URL)\(Constant.Promotions_Path)") else {
            closure(false, nil)
            return
        }
        
        urlComponents.queryItems = parameters.map { URLQueryItem(name: $0.key, value: $0.value) }
        
        guard let url = urlComponents.url else {
            closure(false, nil)
            return
        }
        
        let bodyString = productIds?.enumerated().map { "\($0.offset)=\($0.element)" }.joined(separator: "&") ?? ""
        
        // Alamofire Request
        var urlRequest = URLRequest(url: url)
        urlRequest.method = .post
        urlRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = bodyString.data(using: .utf8)
        
        CroboxDebug.shared.printText(text: urlRequest.httpBody!)
        
        var promotionResponse:PromotionResponse!
        
        AF.request(urlRequest).responseData { response in
            switch response.result {
                
            case .success(let data):
                CroboxDebug.shared.printText(text: JSON(data))
                do {
                    if let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        if jsonObject["error"] == nil {
                            promotionResponse = PromotionResponse(jsonData: JSON(jsonObject))
                            closure(true, promotionResponse)
                        } else {
                            closure(false, promotionResponse)
                        }
                    } else {
                        closure(false, promotionResponse)
                    }
                } catch {
                    closure(false, promotionResponse)
                }
            case .failure(let error):
                CroboxDebug.shared.printText(text:JSON(error))
                closure(false, promotionResponse)
            }
        }
    }
    
    func socket(eventType:EventType!,
                additionalParams:Any?,
                queryParams:RequestQueryParams,
                closure: @escaping (_ isSuccess:Bool, _ jsonObject: JSON?) -> Void) {
        
        //Mandatory
        var parameters = [
            "cid":  Crobox.shared.config.containerId,
            "e": queryParams.viewCounter(),
            "vid": queryParams.viewId,
            "pid":  Crobox.shared.config.visitorId,
            "t": eventType.rawValue
        ] as [String : Any]
        
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
            parameters["tz"] = timezone
        }
        parameters["pt"] = queryParams.pageType
        if let pageName = queryParams.pageName {
            parameters["lh"] = pageName
        }
        
        if let customProperties = queryParams.customProperties {
            for (key, value) in customProperties {
                parameters["cp.\(key)"] = value
            }
        }
        
        checkEventType(eventType:eventType,
                       additionalParams: additionalParams,
                       parameters: &parameters)
        
        APIRequests.shared.request(method: .post, url: Constant.Socket_Path , parameters: parameters ) {
            (jsonObject, success) in
            
            if success {
                
                if !jsonObject.isEmpty && !jsonObject["error"].exists() {
                    
                    closure(true, jsonObject)
                    
                } else {
                    
                    closure(false, jsonObject)
                }
                
            } else {
                
                closure(false, jsonObject)
            }
        }
    }
}



// check for event type
extension CroboxAPIServices
{
    func checkEventType(eventType:EventType!, additionalParams: Any?, parameters: inout [String : Any])
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
    func errorEvent(errorQueryParams:ErrorQueryParams, parameters: inout [String : Any])
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
            parameters["l"] = line
        }
    }
}


/*
 
 The following arguments are applicable for click events( where t=click ). They are all optional
 
 */

extension CroboxAPIServices
{
    func clickEvent(clickParams:ClickQueryParams, parameters: inout [String : Any])
    {
        if let productId = clickParams.productId {
            parameters["pi"] = productId
        }
        if let price = clickParams.price {
            parameters["price"] = price
        }
        if let quantity = clickParams.quantity {
            parameters["qty"] = quantity
        }
    }
}


/*
 
 The following arguments are applicable for AddToCart events( where t=cart ). They are all optional
 
 */

extension CroboxAPIServices
{
    func cartEvent(cartQueryParams:CartQueryParams, parameters: inout [String : Any])
    {
        if let productId = cartQueryParams.productId {
            parameters["pi"] = productId
        }
        if let price = cartQueryParams.price {
            parameters["price"] = price
        }
        if let quantity = cartQueryParams.quantity {
            parameters["qty"] = quantity
        }
    }
}

/*
 
 The following arguments are applicable for click events( where t=event ). They are all optional
 
 */

extension CroboxAPIServices
{
    func customEvent(customQueryParams:CustomQueryParams, parameters: inout [String : Any])
    {
        if let name = customQueryParams.name {
            parameters["nm"] = name
        }
        if let promotionID = customQueryParams.promotionId {
            parameters["promoId"] = promotionID
        }
        if let productID = customQueryParams.productId {
            parameters["pi"] = productID
        }
        if let price = customQueryParams.price {
            parameters["price"] = price
        }
        if let quantity = customQueryParams.quantity {
            parameters["qty"] = quantity
        }
    }
}



