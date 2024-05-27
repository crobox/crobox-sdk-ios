//
//  Crobox.swift
//  croboxsdk
//
//  Created by idris yıldız on 22.05.2024.
//

import Foundation
import Alamofire
import SwiftyJSON

class Crobox {
    
    public static let shared = Crobox()
    
    /*
     enable or disable debug
     */
    var isDebug = false
    
    /*
     index (Home Page)

     */
    func pageIndex(languageCode:String, closure: @escaping (_ isSuccess:Bool, _ promotionResponse: PromotionResponse?) -> Void){
        //TODO
        let parameters = ["":""]
        CroboxAPIServices.shared.promotions(parameters: parameters) { isSuccess, promotionResponse in
            closure(isSuccess, promotionResponse)
        }
    }
    
    /*
     overview (Product Lister Page)


     */
    func pageOverView(){
   
        
    }
    
    
    /*
     detail (Product Detail Page)


     */
    func pageDetail(){
   
        
    }
    
    /*
     cart (Cart Page)



     */
    func pageCart(){
   
        
    }
    
    
    
    /*
     checkout (Checkout Page)



     */
    func pageCheckout(){
   
        
    }
    
    
    /*
     complete (Complete / Confirmation page)


     */
    func pageComplete(){
   
        
    }
    
    
    /*
     search (Search Result page)


     */
    func pageSearch(){
   
        
    }
   
}
