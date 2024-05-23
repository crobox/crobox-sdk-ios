//
//  Preferences.swift
//  croboxsdk
//
//  Created by idris yıldız on 22.05.2024.
//

import Foundation
struct Preferences {
    static let sharedInstance = Preferences()
    private let defaults = UserDefaults.standard
    private let prefKey = "pref"
}
