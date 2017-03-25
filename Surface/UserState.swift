//
//  UserState.swift
//  Surface
//
//  Created by Tsai Family on 3/25/17.
//  Copyright © 2017 MakeSchool. All rights reserved.
//

import Foundation
class UserState {
    class var sharedInstance : UserState {
        struct Static {
            static let instance : UserState = UserState()
        }
        return Static.instance
    }
    
    var highScore: Int = UserDefaults.standard.integer(forKey: "myHighScore") ?? 0 {
        didSet {
            UserDefaults.standard.set(highScore, forKey:"myHighScore")
            // Saves to disk immediately, otherwise it will save when it has time
            UserDefaults.standard.synchronize()
        }
 }
}
