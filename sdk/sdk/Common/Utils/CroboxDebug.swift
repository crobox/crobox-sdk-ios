//
//  CroboxDebug.swift
//  croboxSDK
//
//  Created by crobox team on 23.05.2024.
//

import Foundation
class CroboxDebug: NSObject {
    static let shared = CroboxDebug()
    func printText(text:Any)
    {
        if(Crobox.shared.isDebug){
            print(text)
        }
    }
    func printParams(params:[String:Any])
    {
        if(Crobox.shared.isDebug){
            print(params)
        }
    }
}
