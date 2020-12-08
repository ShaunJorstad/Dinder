//
//  ResultsView.swift
//  Dinder
//
//  Created by Isabella Patnode on 12/7/20.
//

import Foundation
import SwiftUI

struct ResultsView: View {
    @EnvironmentObject var session: SessionStore
    
    @State var restaurant: Restaurant = Restaurant(name: "", geometry: .init(location: Location(lat: 0.0, lng: 0.0)), vicinity: "")
    
    func getResultingRestaurant() -> Restaurant {
        if let currentList = session.restaurantList?.results {
            for restaurant in currentList {
                if restaurant.name == session.result {
                    return restaurant
                }
            }
        }
        
        return Restaurant(name: "", geometry: .init(location: Location(lat: 0.0, lng: 0.0)), vicinity: "")
    }
    
    var body: some View {
        VStack {
            GeometryReader { geometry in
                if(session.result == restaurant.name) {
                    if let photo = restaurant.photos?[0] {
                        PlaceReferenceImage(fromReference: photo.photoReference, width: photo.width, height: photo.height).frame(width: geometry.size.width, height: geometry.size.height * 0.6).clipped()
                    }
                    
                    Text("\(session.result)")
                    
                    Button(action: {
                        if let phoneCallURL = URL(string: "tel://\(restaurant.name)") {
                            let application:UIApplication = UIApplication.shared
                            if(application.canOpenURL(phoneCallURL)) {
                                application.open(phoneCallURL, options: [:], completionHandler: nil)
                            }
                        }
                    }) {
                        Text("Call")
                    }
                    
                } else {
                    Text("\(session.result)")
                }
            }
            
        }.onAppear {
            restaurant = getResultingRestaurant()
        }
    }
}
