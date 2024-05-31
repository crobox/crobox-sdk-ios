//
//  RequestQueryParams.swift
//  croboxSDK
//
//  Created by idris yıldız on 27.05.2024.
//

import Foundation

struct RequestQueryParams {
    var containerId: String!   // ContainerId (mandatory)
    var viewCounter: Int!       // ViewCounter (mandatory)
    var viewId: String!  // ViewId (mandatory)
    var visitorId: String!   // VisitorId (mandatory)
    var currencyCode: String?   // CurrencyCode (optional)
    var localeCode: LocaleCode?   // LocaleCode (optional)
    var userId: String?  // UserId (optional)
    var timestamp: String?   // Timestamp (optional)
    var timezone: Int?      // Timezone (optional)
    var pageType: PageType?      // PageType (optional)
    var customProperties: [String: String]?  // Custom Properties (optional)
    var pageUrl: String?   // ViewController Name
    var referrerUrl: String?   // ViewController Name
}

public enum PageType:Int{
    case PageOther = 0
    case PageIndex = 1
    case PageOverview = 2
    case PageDetail = 3
    case PageCart = 4
    case PageCheckout = 5
    case PageComplete = 6
    case PageSearch = 7
}

/*
 Description: Specifies the type of the event. It must be one of following
 
 */

public enum EventType:String{
    case Click = "click" // Click
    case AddCart = "cart" // Add to Shopping Cart
    case RemoveCart = "rmcart" // Remove from Shopping Cart
    case Transaction = "transaction" // Transaction
    case PageView = "pageview" // PageView
    case Error = "error" // Error
    case CustomEvent = "event" // CustomEvent
    case Product = "product" // Product
    case ProductFinder = "pf" // ProductFinder
}
