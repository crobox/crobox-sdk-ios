//
//  File.swift
//  
//
//  Created by idris yıldız on 4.07.2024.
//

import Foundation
public class CroboxEncoder:NSObject
{
    public static let shared = CroboxEncoder()
    func toBase36(millis: Int64) -> String {
        return String(millis, radix: 36)
    }
}
