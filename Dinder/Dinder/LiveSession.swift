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
    
    var creator: Bool
    @State var likeRestaurant: Bool = false
    @State var translation: CGSize = .zero
    @State var likedRestaurants: [Restaurant] = []
    @State var restaurantList: [Restaurant] = []
    @State var timeRemaining = 100
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    init(created: Bool) {
        self.creator = created
    }
    
    func getSwipeDirection(_ geometry: GeometryProxy, translation: CGSize) -> CGFloat {
        return translation.width / geometry.size.width
    }
    
    var body: some View {
        VStack {
            Spacer()
            Group {
                VStack {
                    HStack {
                        if self.creator {
                            Spacer()
                        }
                        Text("\(timeRemaining)")
                            .font(.title)
                            .onReceive(timer) { _ in
                                if self.timeRemaining > 0 {
                                    self.timeRemaining -= 1
                                }
                                if self.timeRemaining == 0 {
                                    session.endSession()
                                }
                            }
                        if self.creator {
                            Spacer()
                            Button(action: {
                                print("session ended")
                                session.endSession()
                            }) {
                                Text("Finish Session")
                            }
                            Spacer()
                        }
                        
                    }.padding()
                }.frame(width: 350)
                .background(Color.white)
                .cornerRadius(10)
                .shadow(radius: 5)
            }
            Spacer()
            Group {
                ZStack {
                    if restaurantList.count == 0 {
                        Text("Fuck off")
                    } else {
                        ForEach(restaurantList.reversed(), id: \.name) { restaurant in
//                            Group {
//                                GeometryReader { geometry in
//                                    VStack {
//                                        RestaurantView(restaurant: restaurant, width: geometry.size.width, height: geometry.size.height)
//                                    }.gesture(DragGesture() .onChanged { value in
//                                        if(self.getSwipeDirection(geometry, translation: value.translation) >= 0.5) {
//                                            likeRestaurant = false
//                                            print("Restaurant hated :(")
//                                        } else if (self.getSwipeDirection(geometry, translation: value.translation) <= -0.5) {
//                                            likeRestaurant = true
//                                            print("Restaurant liked :)")
//                                        }
//                                    }.onEnded { value in
//                                        if(self.getSwipeDirection(geometry, translation: value.translation) > 0.5) {
//                                            likedRestaurants.append(restaurant)
//                                        }
//
//                                        if (!restaurantList.isEmpty) {
//                                            restaurantList.removeFirst()
//                                            print("Begone whore!")
//                                        }
//                                    })
//                                }
//                            }
                            //initialize RestaurantCard(restaurant)
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
            Spacer()
            Spacer()
        }.onAppear(perform: {
            self.timeRemaining = session.time * 60
        })
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
