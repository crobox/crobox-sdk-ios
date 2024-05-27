//
//  Context.swift
//  croboxSDK
//
//  Created by idris yıldız on 24.05.2024.
//

import Foundation
struct Context: Codable {
    let groupName: String
    let pid, sid: UUID
    let experiments: [Experiment]
}
