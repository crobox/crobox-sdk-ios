//
//  ViewController.swift
//  CroboxTestApp
//
//  Created by idris yıldız on 5.06.2024.
//

import UIKit
import Crobox
import Alamofire
import SwiftyJSON

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /// Crobox.shared is the single point of contact for all interactions, keeping the configuration and providing all functionality
//        Crobox.shared.initConfig(config: CroboxConfig(containerId: "xlhvci", visitorId: UUID.init(), localeCode: .en_US))
//        
//        /// Enable/Disable debugging
//        Crobox.shared.isDebug = true
//        
//        /// RequestQueryParams contains page specific parameters, shared by all event and promotion requests sent from the same page/view.
//        /// Request params must be re-created when user visits a page/view, eg. CartPage,
//        let overviewPageParams = RequestQueryParams.init(viewId: UUID(), pageType: .PageOverview, customProperties: ["test":"test"])
//        
//        //***************** EVENTS *********************
//                
//        /// Sending Click events with optional event specific parameters
//        let clickQueryParams = ClickQueryParams(productId: "4", price: 2.0, quantity: 3)
//        Crobox.shared.clickEvent(queryParams: overviewPageParams, clickQueryParams: clickQueryParams)
//        
//        /// Sending Add To Cart events with optional event specific parameters
//        let addCartQueryParams = CartQueryParams(productId: "3", price: 1.0, quantity: 12)
//        Crobox.shared.addCartEvent(queryParams: overviewPageParams, addCartQueryParams:addCartQueryParams )
//        
//        /// Sending Remove From Cart events with optional event specific parameters
//        let rmCartQueryParams = CartQueryParams(productId: "3", price: 1.0, quantity: 12)
//        Crobox.shared.removeCartEvent(queryParams: overviewPageParams, rmCartQueryParams: rmCartQueryParams)
//        
//        /// Sending Error events with optional event specific parameters
//        //let errorParams = ErrorQueryParams(tag: "ParsingError", name: "IllegalArgumentException", message: "bad input")
//        //Crobox.shared.errorEvent(queryParams: overviewPageParams, errorQueryParams: errorParams)
//        
//        /// Sending general-purpose Custom event
//        let customParams = CustomQueryParams(name: "custom-event", promotionId: UUID(), productId: "3", price: 1.0, quantity: 1)
//        Crobox.shared.customEvent(queryParams: overviewPageParams, customQueryParams: customParams)
//        
//        //*****************PROMOTIONS*********************
//        
//        /// Requesting for a promotion from an overview Page with placeholderId configured for Overview Pages in Crobox Container for a collection of products/impressions
//        Crobox.shared.promotions(placeholderId: "1",
//                                 queryParams: overviewPageParams,
//                                 productIds: ["1", "2", "3"]) { isSuccess, promotionResponse in
//            /// process PromotionResponse
//            if let items = promotionResponse?.promotions
//            {
//                for item in items
//                {
//                    print(item.content?.config?.data ?? "no data")
//                    print(item.campaignId!)
//                    print(item.id!)
//                    print(item.productId! )
//                }
//            }
//        }
//                
//        /// Requesting for a promotion from a product detail page with another placeholderId for a single product
//        let detailPageParams = RequestQueryParams.init(viewId: UUID(), pageType: .PageDetail)
//        Crobox.shared.promotions(placeholderId: "1",
//                                 queryParams: detailPageParams,
//                                 productIds: ["1"]) { isSuccess, promotionResponse in
//            /// process PromotionResponse
//
//        }
//
//        /// Requesting for a promotion from Checkout Page with another placeholderId without any product
//        let checkoutPageParams = RequestQueryParams.init(viewId: UUID(), pageType: .PageCheckout)
//        Crobox.shared.promotions(placeholderId: "2", queryParams: checkoutPageParams) { isSuccess, promotionResponse in
//            /// process PromotionResponse
//        }
//        
        
        
        let vid = UUID.init()
        print(vid)
        Crobox.shared.initConfig(config: CroboxConfig(containerId: "k8d303", visitorId: vid, localeCode: .en_US))
        
        Crobox.shared.isDebug = true
        
        let overviewPageParams = RequestQueryParams.init(viewId: UUID(), pageType: .PageOverview, customProperties: ["test":"test"])
        
        print("sending promoiton")
        
        print("dispatch")
        promotions(placeholderId: "1",
                                 queryParams: overviewPageParams,
                                 productIds: ["IE3437", "298444JQ", "3ABC"]) { isSuccess, promotionResponse in
            print(isSuccess)
            print(promotionResponse ?? "")
        }
        
        print("finished")
    }
    
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
        
        if let pageName = queryParams.pageName {
            parameters["lh"] = pageName
        }
        
        if let customProperties = queryParams.customProperties {
            parameters["cp"] = "\(customProperties)"
        }
        
        
        // URL oluşturma ve query parametrelerini ekleme
        guard var urlComponents = URLComponents(string:  "https://api.crobox.com/promotions") else {
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
        
        print(url)
        
        var promotionResponse:PromotionResponse!
        
//        AF.request(urlRequest).responseData { response in
//            switch response.result {
//           
//            case .success(let data):
//                do {
//                    if let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
//                        if jsonObject["error"] == nil {
//                            promotionResponse = PromotionResponse(jsonData: JSON(jsonObject))
//                            closure(true, promotionResponse)
//                        } else {
//                            closure(false, promotionResponse)
//                        }
//                    } else {
//                        closure(false, promotionResponse)
//                    }
//                } catch {
//                    closure(false, promotionResponse)
//                }
//            case .failure(let error):
//                closure(false, promotionResponse)
//            }
//        }
        
        AF.request(urlRequest).responseData { response in
               switch response.result {
               case .success(let data):
                   do {
                       if let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                           print("JSON Object: \(jsonObject)") // Debug için JSON'u yazdırma
                           if jsonObject["error"] == nil {
                               let promotionResponse = PromotionResponse(jsonData: JSON(jsonObject))
                               closure(true, promotionResponse)
                           } else {
                               print("Error in response: \(jsonObject["error"]!)") // Hata mesajını yazdırma
                               closure(false, nil)
                           }
                       } else {
                           print("Failed to cast JSON object")
                           closure(false, nil)
                       }
                   } catch {
                       print("JSON parsing error: \(error.localizedDescription)") // Hata mesajını yazdırma
                       closure(false, nil)
                   }
               case .failure(let error):
                   print("Request failed: \(error.localizedDescription)") // Hata mesajını yazdırma
                   closure(false, nil)
               }
           }
    }
}

