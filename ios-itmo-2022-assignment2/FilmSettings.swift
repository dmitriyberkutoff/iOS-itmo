//
//  FilmSettings.swift
//  ios-itmo-2022-assignment2
//
//  Created by mac on 14.12.2022.
//

import Foundation

class FilmSettings {
    
    enum Keys: String {
        case rating
        case year
        case noPosterId
    }
    
    static var rating: Int! {
        get {
            UserDefaults.standard.integer(forKey: Keys.rating.rawValue)
        }
        set {
            let defaults = UserDefaults.standard
            let key = Keys.rating.rawValue
            if let rate = newValue {
                defaults.set(rate, forKey: key)
            } else {
                defaults.removeObject(forKey: key)
            }
        }
    }
    
    static var year: String! {
        get {
            UserDefaults.standard.string(forKey: Keys.year.rawValue)
        }
        set {
            let defaults = UserDefaults.standard
            let key = Keys.year.rawValue
            if let year = newValue {
                defaults.set(year, forKey: key)
            } else {
                defaults.removeObject(forKey: key)
            }
        }
    }
    
    static var noPosterId: String! {
        get {
            UserDefaults.standard.string(forKey: Keys.noPosterId.rawValue)
        }
        set {
            let defaults = UserDefaults.standard
            let key = Keys.noPosterId.rawValue
            if let id = newValue {
                defaults.set(id, forKey: key)
            } else {
                defaults.removeObject(forKey: key)
            }
        }
    }

}
