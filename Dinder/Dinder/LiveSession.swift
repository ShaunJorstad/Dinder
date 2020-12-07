//
//  Account.swift
//  Dinder
//
//  Created by Shaun Jorstad on 11/1/20.
//

import Foundation
import SwiftUI

struct LiveSession: View {
    @EnvironmentObject var session: SessionStore
    
    var creator = false
    @State var likeRestaurant: Bool = false
    @State var translation: CGSize = .zero
    @State var index: Int = 0
    @State var currentRestaurant: Restaurant = Restaurant(name: "", geometry: Geometry.init(location: Location.init(lat: 0.0, lng: 0.0)), vicinity: "")
    @State var restaurantList: [Restaurant] = []
    @State var likedRestaurants: [Restaurant] = []
    
    init(created: Bool) {
        self.creator = created
    }
    
    func getNextRestaurant() -> Restaurant {
        return restaurantList[index]
    }
    
    func getSwipeDirection(_ geometry: GeometryProxy, translation: CGSize) -> CGFloat {
        return translation.width / geometry.size.width
    }

    var body: some View {
        Group {
            GeometryReader { geometry in
                VStack {
                    Text("Session just started!")
                        .dinderTitleStyle()
                    
                    if let photo = currentRestaurant.photos?[0] {
                        VStack {
                            Text(currentRestaurant.name)
                            PlaceReferenceImage(fromReference: photo.photoReference, width: photo.width, height: photo.height)
                        }
                    }
                    
                }.gesture(DragGesture() .onChanged { value in
                    if(self.getSwipeDirection(geometry, translation: value.translation) >= 0.5) {
                        likeRestaurant = false
                        print("Restaurant liked :)")
                    } else if (self.getSwipeDirection(geometry, translation: value.translation) <= -0.5) {
                        likeRestaurant = true
                        print("Restaurant hated :(")
                    }
                    
                }.onEnded { value in
                    if(self.getSwipeDirection(geometry, translation: value.translation) > 0.5) {
                        likedRestaurants.append(currentRestaurant)
                    }
                    
                    if(index < restaurantList.count) {
                        currentRestaurant = self.getNextRestaurant()
                        index += 1
                    }
                    
                })
            }
        }
        .onDisappear {
            if (session.sessionCode != nil && self.creator) {
                session.deleteSession()
            } else if (session.sessionCode != nil && !self.creator) {
                session.leaveSession()
            }
        }.onAppear {
            if (session.restaurantList?.results) != nil {
                restaurantList = session.restaurantList!.results
                currentRestaurant = self.getNextRestaurant()
                index += 1
            }
        }
    }
}

struct LiveSession_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            LiveSession(created: true)
            LiveSession(created: false)
        }
    }
}
