//
//  Json.swift
//  Dinder
//
//  Created by Luke on 12/5/20.
//

import Foundation

struct Restaraunt: Codable {
    var name: String
}

struct RestarauntList: Codable {
    var results: [Restaraunt]
}
