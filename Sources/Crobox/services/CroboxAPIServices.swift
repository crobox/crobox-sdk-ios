import Foundation

class CroboxAPIServices {
    
    static let shared = CroboxAPIServices()

    func promotions(placeholderId:String!,
                    queryParams:RequestQueryParams,
                    productIds: [String]? = []) async throws -> PromotionResponse {

        //Mandatory
        var parameters = requestQueryParams(queryParams: queryParams)
        parameters["vpid"] = placeholderId!
        let queryItems = parameters.map { URLQueryItem(name: $0.key, value: $0.value) }

        guard var urlComponents = URLComponents(string: "\(Constant.Promotions_Path)") else {
            throw CroboxErrors.internalRequestError(msg: "Failed to form promotions path")
        }
        urlComponents.queryItems = queryItems

        guard let url = urlComponents.url else {
            throw CroboxErrors.internalRequestError(msg: "Failed to form promotions parameters")
        }

        let bodyString = promotionsBody(productIds: productIds)

        let data = try await APIRequests.shared.post(url: url, body: bodyString)

        do {
            // All coding keys match the JSON keys, so no key conversion: it would also rename
            // keys inside the promotion `config` map (e.g. "Text1_color").
            let decoder = JSONDecoder()
            let promotionResponse = try decoder.decode(PromotionResponse.self, from: data)
            return promotionResponse
        } catch {
            throw CroboxErrors.invalidJSON(msg: "Decoding error", value: "\(error)")
        }
    }

    func event(eventType:EventType!,
               additionalParams:Any?,
               queryParams:RequestQueryParams) async throws -> Void {
        let parameters = eventParameters(eventType: eventType, additionalParams: additionalParams, queryParams: queryParams)
        return try await APIRequests.shared.get(url: Constant.Event_Path , parameters: parameters)
    }

    /// The form-encoded body of a promotions request. The server ranks promotions in this order.
    func promotionsBody(productIds: [String]?) -> String {
        return (productIds ?? []).enumerated()
            .map { "\($0.offset)=\(formEncode($0.element))" }
            .joined(separator: "&")
    }

    /// All query parameters of an event request
    func eventParameters(eventType:EventType!,
                         additionalParams:Any?,
                         queryParams:RequestQueryParams) -> [String: String] {
        //Mandatory
        var parameters = requestQueryParams(queryParams: queryParams)
        parameters["t"] = eventType.rawValue

        checkEventType(eventType:eventType,
                       additionalParams: additionalParams,
                       parameters: &parameters)
        return parameters
    }

    private func formEncode(_ value: String) -> String {
        var allowed = CharacterSet.alphanumerics
        allowed.insert(charactersIn: "-._~")
        return value.addingPercentEncoding(withAllowedCharacters: allowed) ?? value
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
        if let localeCode = Crobox.shared.config.localeCode {
            parameters["lc"] = localeCode.rawValue
        }
        if let userId = Crobox.shared.config.userId {
            parameters["uid"] = userId
        }
        let now = Date()
        parameters["tz"] = CroboxAPIServices.timezoneOffsetHours(TimeZone.current, at: now)
        let millis = Int64(now.timeIntervalSince1970 * 1000)
        parameters["ts"] = CroboxEncoder.shared.toBase36(millis: millis)
        
        if let pageName = queryParams.pageName {
            parameters["lh"] = pageName
        }
        
        // Container-wide custom properties first, so that view specific ones can override them
        if let customProperties = Crobox.shared.config.customProperties {
            processCustomProperties(customProperties, &parameters)
        }
        if let customProperties = queryParams.customProperties {
            processCustomProperties(customProperties, &parameters)
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
            // Checkout is a pageview of a checkout page; the server only records it with that page type
            parameters["t"] = EventType.PageView.rawValue
            parameters["pt"] = "\(PageType.PageCheckout.rawValue)"
            if let checkoutParams = additionalParams as? CheckoutParams {
                checkoutEvent(checkoutParams: checkoutParams, parameters: &parameters)
            }
            break
        case .Purchase:
            // Purchase is a pageview of the order complete page; the server only records it with that page type
            parameters["t"] = EventType.PageView.rawValue
            parameters["pt"] = "\(PageType.PageComplete.rawValue)"
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
        parameters["tid"] = purchaseParams.transactionId
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
        if let quantity = customQueryParams.quantity {
            parameters["qty"] = "\(quantity)"
        }
    }
    
    private func processProductParams(_ productParams:ProductParams, _ parameters: inout [String : String])
    {
        if let productId = productParams.productId {
            parameters["pi"] = productId
        }
        if let quantity = productParams.quantity {
            parameters["qty"] = "\(quantity)"
        }
        if let list = productParams.list {
            parameters["lst"] = list
        }
    }
    
    /// Sends each product as `imp[n].id`, with its position (1-based) and, when known, its quantity and list.
    /// A plain `imp[n]=id` would make the server record every position as 0 (unknown) and every quantity as 1.
    private func processImpressions(_ impressions:[ProductParams], _ parameters: inout [String : String])
    {
        let products = impressions.filter { $0.productId != nil }
        for (index, product) in products.enumerated() {
            let prefix = "imp[\(index)]"
            parameters["\(prefix).id"] = product.productId
            parameters["\(prefix).pos"] = "\(index + 1)"
            if let quantity = product.quantity {
                parameters["\(prefix).qty"] = "\(quantity)"
            }
            if let list = product.list {
                parameters["\(prefix).lst"] = list
            }
        }
    }

    /// The UTC offset in hours, positive east of UTC, as the web snippet sends it (`getTimezoneOffset() / -60`):
    /// "1" in Amsterdam in winter, "5.5" in India.
    static func timezoneOffsetHours(_ timeZone: TimeZone, at date: Date) -> String {
        let seconds = timeZone.secondsFromGMT(for: date)
        if seconds % 3600 == 0 {
            return "\(seconds / 3600)"
        }
        return "\(Double(seconds) / 3600)"
    }
    
    
    private func processCustomProperties(_ customProperties:[String : String], _ parameters: inout [String : String])
    {
        for (key, value) in customProperties {
            parameters["cp.\(key)"] = value
        }
    }
}


