//
//  Json.swift
//  Dinder
//
//  Created by Luke on 12/5/20.
//

import Foundation

struct Restaurant: Codable {
    var name: String
    var geometry: Geometry
    var vicinity: String
    var photos: [PhotoReference]?
    var rating: Double?
}

struct RestaurantList: Codable {
    var results: [Restaurant]
}

struct Geometry: Codable {
    var location: Location
}

struct Location: Codable {
    var lat: Double
    var lng: Double
}

struct PhotoReference: Codable {
    var width: Int
    var height: Int
    var photoReference: String
    
    enum CodingKeys: String, CodingKey {
        case width, height
        case photoReference = "photo_reference"
    }
}
