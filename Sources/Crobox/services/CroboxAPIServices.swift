import Foundation

class CroboxAPIServices {
    
    static let shared = CroboxAPIServices()

    func promotions(placementId: Int,
                    view:ViewContext,
                    productIds: [String] = []) async throws -> PromotionsResponse {

        //Mandatory
        var parameters = viewParameters(view: view)
        parameters["vpid"] = String(placementId)
        let queryItems = parameters.map { URLQueryItem(name: $0.key, value: $0.value) }

        guard var urlComponents = URLComponents(string: "\(Constant.Promotions_Path)") else {
            throw CroboxError.internalRequestError(msg: "Failed to form promotions path")
        }
        urlComponents.queryItems = queryItems

        guard let url = urlComponents.url else {
            throw CroboxError.internalRequestError(msg: "Failed to form promotions parameters")
        }

        let bodyString = promotionsBody(productIds: productIds)

        let data = try await APIRequests.shared.post(url: url, body: bodyString)

        do {
            // All coding keys match the JSON keys, so no key conversion: it would also rename
            // keys inside the promotion `config` map (e.g. "Text1_color").
            let decoder = JSONDecoder()
            let promotionsResponse = try decoder.decode(PromotionsResponse.self, from: data)
            return promotionsResponse
        } catch {
            throw CroboxError.invalidJSON(msg: "Decoding error", value: "\(error)")
        }
    }

    func event(eventType:EventType!,
               params:Any?,
               view:ViewContext) async throws -> Void {
        let parameters = eventParameters(eventType: eventType, params: params, view: view)
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
                         params:Any?,
                         view:ViewContext) -> [String: String] {
        //Mandatory
        var parameters = viewParameters(view: view)
        parameters["t"] = eventType.rawValue

        checkEventType(eventType:eventType,
                       params: params,
                       parameters: &parameters)
        return parameters
    }

    private func formEncode(_ value: String) -> String {
        var allowed = CharacterSet.alphanumerics
        allowed.insert(charactersIn: "-._~")
        return value.addingPercentEncoding(withAllowedCharacters: allowed) ?? value
    }
    
    private func viewParameters(view:ViewContext) -> [String: String] {
        // Mandatory
        var parameters = [
            "cid": Crobox.shared.config.containerId,
            "pid": "\(Crobox.shared.config.visitorId)",
            "e": "\(view.viewCounter())",
            "vid": "\(view.viewId)",
            "pt": "\(view.viewType.rawValue)",
            "sdk": "1"
        ]
        // Optional
        if let localeCode = Crobox.shared.config.localeCode {
            parameters["lc"] = localeCode.code
        }
        if let userId = Crobox.shared.config.userId {
            parameters["uid"] = userId
        }
        let now = Date()
        parameters["tz"] = CroboxAPIServices.timezoneOffsetHours(Crobox.shared.config.timezone ?? TimeZone.current, at: now)
        let millis = Int64(now.timeIntervalSince1970 * 1000)
        parameters["ts"] = CroboxEncoder.shared.toBase36(millis: millis)
        
        if let viewName = view.viewName {
            parameters["lh"] = viewName
        }
        
        // Container-wide custom properties first, so that view specific ones can override them
        if let customProperties = Crobox.shared.config.customProperties {
            processCustomProperties(customProperties, &parameters)
        }
        if let customProperties = view.customProperties {
            processCustomProperties(customProperties, &parameters)
        }
        
        return parameters
    }
    
    
    // check for event type
    
    private func checkEventType(eventType:EventType!, params: Any?, parameters: inout [String : String])
    {
        switch eventType {
        case .Click:
            if let clickParams = params as? ClickParams {
                clickEvent(clickParams: clickParams, parameters: &parameters)
            }
            break
        case .AddCart, .RemoveCart:
            if let cartParams = params as? CartParams {
                cartEvent(cartParams: cartParams, parameters: &parameters)
            }
            break
        case .PageView:
            if let viewParams = params as? ViewParams {
                viewEvent(viewParams: viewParams, parameters: &parameters)
            }
            break
        case .Checkout:
            // Checkout is a pageview of a checkout view; the server only records it with that view type
            parameters["t"] = EventType.PageView.rawValue
            parameters["pt"] = "\(ViewType.checkout.rawValue)"
            if let checkoutParams = params as? CheckoutParams {
                checkoutEvent(checkoutParams: checkoutParams, parameters: &parameters)
            }
            break
        case .Purchase:
            // Purchase is a pageview of the order complete view; the server only records it with that view type
            parameters["t"] = EventType.PageView.rawValue
            parameters["pt"] = "\(ViewType.complete.rawValue)"
            if let purchaseParams = params as? PurchaseParams {
                purchaseEvent(purchaseParams: purchaseParams, parameters: &parameters)
            }
            break
        case .Error:
            if let errorParams = params as? ErrorParams {
                errorEvent(errorParams: errorParams, parameters: &parameters)
            }
            break
        default:
            if let customEventParams = params as? CustomEventParams {
                customEvent(customEventParams: customEventParams, parameters: &parameters)
            }
            break
        }
    }
    
    
    
    /*
     
     The following arguments are applicable for error events( where t=error ). They are all optional.
     
     */
    
    private func errorEvent(errorParams:ErrorParams, parameters: inout [String : String])
    {
        if let tag = errorParams.tag {
            parameters["tg"] = tag
        }
        if let name = errorParams.name {
            parameters["nm"] = name
        }
        if let message = errorParams.message {
            parameters["msg"] = message
        }
        if let file = errorParams.file {
            parameters["f"] = file
        }
        if let line = errorParams.line {
            parameters["l"] = "\(line)"
        }
    }
    
    
    
    /*
     
     The following arguments are applicable for click events( where t=click ). They are all optional
     
     */
    
    
    private func clickEvent(clickParams:ClickParams, parameters: inout [String : String])
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
    
    private  func cartEvent(cartParams:CartParams, parameters: inout [String : String])
    {
        if let productId = cartParams.productId {
            parameters["pi"] = productId
        }
        if let quantity = cartParams.quantity {
            parameters["qty"] = "\(quantity)"
        }
    }
    
    
    private func viewEvent(viewParams:ViewParams, parameters: inout [String : String])
    {
        if let title = viewParams.title {
            parameters["dt"] = "\(title)"
        }
        if let productParams = viewParams.product {
            processProductParams(productParams, &parameters)
        }
        if let impressions = viewParams.impressions {
            processImpressions(impressions, &parameters)
        }
        if let searchTerms = viewParams.searchTerms {
            parameters["st"] = "\(searchTerms)"
        }
        if let customProperties = viewParams.customProperties {
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
    
    
    private func customEvent(customEventParams:CustomEventParams, parameters: inout [String : String])
    {
        if let name = customEventParams.name {
            parameters["nm"] = name
        }
        if let promotionID = customEventParams.promotionId {
            parameters["promoId"] = "\(promotionID)"
        }
        if let productID = customEventParams.productId {
            parameters["pi"] = productID
        }
        if let quantity = customEventParams.quantity {
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


