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
    @State var likedRestaurants: [Restaurant] = []
    @State var restaurantList: [Restaurant] = []
    init(created: Bool) {
        self.creator = created
    }
    
    func getSwipeDirection(_ geometry: GeometryProxy, translation: CGSize) -> CGFloat {
        return translation.width / geometry.size.width
    }

    var body: some View {
        ZStack {
            if restaurantList.count == 0 {
                Text("Fuck off")
            } else {
                ForEach(restaurantList, id: \.name) { restaurant in
                    Group {
                        GeometryReader { geometry in
                            VStack {
                                Text("Session just started!").dinderTitleStyle()
                                
                                RestaurantView(restaurant: restaurant, width: geometry.size.width, height: geometry.size.height)
                            }.gesture(DragGesture() .onChanged { value in
                                if(self.getSwipeDirection(geometry, translation: value.translation) >= 0.5) {
                                    likeRestaurant = false
                                    print("Restaurant hated :(")
                                } else if (self.getSwipeDirection(geometry, translation: value.translation) <= -0.5) {
                                    likeRestaurant = true
                                    print("Restaurant liked :)")
                                }
                            }.onEnded { value in
                                if(self.getSwipeDirection(geometry, translation: value.translation) > 0.5) {
                                    likedRestaurants.append(restaurant)
                                }
                                
                                if (!restaurantList.isEmpty) {
                                    restaurantList.removeFirst()
                                    print("Begone whore!")
                                }
                            })
                        }
                    }
                }
            }
        }.onDisappear {
            if (session.sessionCode != nil && self.creator) {
                session.deleteSession()
            } else if (session.sessionCode != nil && !self.creator) {
                session.leaveSession()
            }
        }.onAppear {
            restaurantList = session.restaurantList?.results ?? []
        }
    }
}

struct RestaurantView: View {
    var restaurant: Restaurant
    var width: CGFloat
    var height: CGFloat
    
    var body: some View {
        if let photo = restaurant.photos?[0] {
            VStack {
                Text(restaurant.name)
                PlaceReferenceImage(fromReference: photo.photoReference, width: photo.width, height: photo.height).frame(width: width, height: height * 0.75).clipped()
            }
        } else {
            Text(restaurant.name)
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
