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
                        Text("No restaurants found within the radius")
                    } else {
                        ForEach(session.restaurantList?.results ?? [], id: \.name) { restaurant in
                            RestaurantCard(restaurant: restaurant).background(Color.white)
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

struct LiveSession_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            LiveSession(created: true)
            LiveSession(created: false)
        }
    }
}
