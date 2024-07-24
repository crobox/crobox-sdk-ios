import Foundation
import SwiftyJSON
import Alamofire

class CroboxAPIServices {
    
    static let shared = CroboxAPIServices()
    
    func promotions(placeholderId:String!,
                    queryParams:RequestQueryParams,
                    productIds: Set<String>? = Set(),
                    closure: @escaping (_ result: Result<PromotionResponse, CroboxErrors>) -> Void) {
        
        //Mandatory
        var parameters = requestQueryParams(queryParams: queryParams)
        parameters["vpid"] = placeholderId!
        let queryItems = parameters.map { URLQueryItem(name: $0.key, value: $0.value) }
        
        guard var urlComponents = URLComponents(string: "\(Constant.Promotions_Path)") else {
            closure(.failure(CroboxErrors.internalRequestError(msg: "Failed to form promotions path")))
            return
        }
        urlComponents.queryItems = queryItems
        
        guard let url = urlComponents.url else {
            closure(.failure(CroboxErrors.internalRequestError(msg: "Failed to form promotions parameters")))
            return
        }
        
        let bodyString = productIds?.enumerated().map { "\($0.offset)=\($0.element)" }.joined(separator: "&") ?? ""
        
        APIRequests.shared.post(url: url, body: bodyString) { response in
            switch response {
            case .success(let data):
                do {
                    if let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        if jsonObject["error"] == nil {
                            let jsonData = JSON(jsonObject)
                            let promotionResponse:PromotionResponse = try PromotionResponse(jsonData: jsonData)
                            closure(.success(promotionResponse))
                        } else {
                            closure(.failure(CroboxErrors.invalidJSON(msg: "Json Serialization Error", value: "\(jsonObject)")))
                        }
                    } else {
                        closure(.failure(CroboxErrors.invalidJSON(msg: "Json Serialization Error", value: "\(data)")))
                    }
                } catch {
                    closure(.failure(CroboxErrors.internalError(msg: "Response handling error", cause: error)))
                }
            case .failure(let croboxError):
                closure(.failure(croboxError))
            }
        }
        
    }
    
    func event(eventType:EventType!,
               additionalParams:Any?,
               queryParams:RequestQueryParams,
               closure: @escaping (_ result: Result<Void, CroboxErrors>) -> Void) {
        
        //Mandatory
        var parameters = requestQueryParams(queryParams: queryParams)
        parameters["t"] = eventType.rawValue
        
        checkEventType(eventType:eventType,
                       additionalParams: additionalParams,
                       parameters: &parameters)
        
        APIRequests.shared.get(url: Constant.Event_Path , parameters: parameters, closure: closure)
    }
    
    private func requestQueryParams(queryParams:RequestQueryParams) -> [String: String] {
        // Mandatory
        var parameters = [
            "cid": Crobox.shared.config.containerId,
            "pid": "\(Crobox.shared.config.visitorId)",
            "e": "\(queryParams.viewCounter())",
            "vid": "\(queryParams.viewId)",
            "pt": "\(queryParams.pageType.rawValue)",
            "sdk": "1"
        ]
        // Optional
        if let currencyCode = Crobox.shared.config.currencyCode {
            parameters["cc"] = currencyCode.rawValue
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
        
        return parameters
    }
    
    
    // check for event type
    
    private func checkEventType(eventType:EventType!, additionalParams: Any?, parameters: inout [String : String])
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
            if let pageViewParams = additionalParams as? PageViewParams {
                pageViewEvent(pageViewParams: pageViewParams, parameters: &parameters)
            }
            break
        case .Checkout:
            parameters["t"] = EventType.PageView.rawValue
            if let checkoutParams = additionalParams as? CheckoutParams {
                checkoutEvent(checkoutParams: checkoutParams, parameters: &parameters)
            }
            break
        case .Purchase:
            parameters["t"] = EventType.PageView.rawValue
            if let purchaseParams = additionalParams as? PurchaseParams {
                purchaseEvent(purchaseParams: purchaseParams, parameters: &parameters)
            }
            break
        case .Error:
            if let errorQueryParams = additionalParams as? ErrorQueryParams {
                errorEvent(errorQueryParams: errorQueryParams, parameters: &parameters)
            }
            break
        default:
            if let customQueryParams = additionalParams as? CustomQueryParams {
                customEvent(customQueryParams: customQueryParams, parameters: &parameters)
            }
            break
        }
    }
    
    
    
    /*
     
     The following arguments are applicable for error events( where t=error ). They are all optional.
     
     */
    
    private func errorEvent(errorQueryParams:ErrorQueryParams, parameters: inout [String : String])
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
    
    
    
    /*
     
     The following arguments are applicable for click events( where t=click ). They are all optional
     
     */
    
    
    private func clickEvent(clickParams:ClickQueryParams, parameters: inout [String : String])
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
    
    
    
    /*
     
     The following arguments are applicable for AddToCart events( where t=cart ). They are all optional
     
     */
    
    private  func cartEvent(cartQueryParams:CartQueryParams, parameters: inout [String : String])
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
    
    
    private func pageViewEvent(pageViewParams:PageViewParams, parameters: inout [String : String])
    {
        if let pageTitle = pageViewParams.pageTitle {
            parameters["dt"] = "\(pageTitle)"
        }
        if let productParams = pageViewParams.product {
            processProductParams(productParams, &parameters)
        }
        if let impressions = pageViewParams.impressions {
            processImpressions(impressions, &parameters)
        }
        if let searchTerms = pageViewParams.searchTerms {
            parameters["st"] = "\(searchTerms)"
        }
        if let customProperties = pageViewParams.customProperties {
            processCustomProperties(customProperties, &parameters)
        }
    }
    
    private func checkoutEvent(checkoutParams:CheckoutParams, parameters: inout [String : String])
    {
        if let products = checkoutParams.products {
            processImpressions(products, &parameters)
        }
        if let step = checkoutParams.step {
            parameters["stp"] = step
        }
        if let customProperties = checkoutParams.customProperties {
            processCustomProperties(customProperties, &parameters)
        }
    }
    
    private func purchaseEvent(purchaseParams:PurchaseParams, parameters: inout [String : String])
    {
        if let impressions = purchaseParams.products {
            processImpressions(impressions, &parameters)
        }
        if let transactionId = purchaseParams.transactionId {
            parameters["tid"] = transactionId
        }
        if let affiliation = purchaseParams.affiliation {
            parameters["aff"] = affiliation
        }
        if let coupon = purchaseParams.coupon {
            parameters["cpn"] = coupon
        }
        if let revenue = purchaseParams.revenue{
            parameters["rev"] = "\(revenue)"
        }
        if let customProperties = purchaseParams.customProperties {
            processCustomProperties(customProperties, &parameters)
        }
    }
    
    /*
     
     The following arguments are applicable for click events( where t=event ). They are all optional
     
     */
    
    
    private func customEvent(customQueryParams:CustomQueryParams, parameters: inout [String : String])
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
    
    private func processProductParams(_ productParams:ProductParams, _ parameters: inout [String : String])
    {
        if let productId = productParams.productId {
            parameters["pi"] = productId
        }
        if let price = productParams.price {
            parameters["price"] = "\(price)"
        }
        if let quantity = productParams.quantity {
            parameters["qty"] = "\(quantity)"
        }
        if let otherProductIds = productParams.otherProductIds {
            parameters["lst"] = "\(otherProductIds.joined(separator: ","))"
        }
    }
    
    private func processImpressions(_ impressions:[ProductParams], _ parameters: inout [String : String])
    {
        let productIds = impressions.map{$0.productId}
        for (index, id) in productIds.enumerated() {
            parameters["[\(index)]"] = id
        }
    }
    
    
    private func processCustomProperties(_ customProperties:[String : String], _ parameters: inout [String : String])
    {
        for (key, value) in customProperties {
            parameters["cp.\(key)"] = value
        }
    }
}


