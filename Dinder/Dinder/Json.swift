//
//  Json.swift
//  Dinder
//
//  Created by Luke on 12/5/20.
//

import Foundation

struct Restaurant: Codable {
    var name: String
}

struct RestaurantList: Codable {
    var results: [Restaurant]
}
