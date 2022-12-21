//
//  File.swift
//  ios-itmo-2022-assignment2
//
//  Created by mac on 22.10.2022.
//

import Foundation

class Film {
    var id: Int = 0
    var name: String
    var director: String
    var date: String
    var rate: Int
    var poster: String
    
    init(name: String, director: String, date: String, rate: Int, poster: String) {
        self.name = name
        self.director = director
        self.date = date
        self.rate = rate
        self.poster = poster
    }
}

struct DatedFilms: Comparable{
    static func < (lhs: DatedFilms, rhs: DatedFilms) -> Bool {
        lhs.year < rhs.year
    }
    
    static func == (lhs: DatedFilms, rhs: DatedFilms) -> Bool {
        return lhs.year == rhs.year
    }
    
    var year: String
    public var films = [Film]()
}

