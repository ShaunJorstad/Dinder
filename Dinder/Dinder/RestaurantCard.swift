//
//  RestaurantCard.swift
//  Dinder
//
//  Created by Shaun Jorstad on 12/7/20.
//

import Foundation
import SwiftUI

struct RestaurantCard: View {
    @EnvironmentObject var session: SessionStore
    
    private var name: String
    
    private var photo: PhotoReference?
    
    @State private var translation: CGSize = .zero
    @State private var swipeStatus: LikeDislike = .none
    private var thresholdPercentage: CGFloat = 0.2
    private enum LikeDislike: Int {
        case like, dislike, none
    }
    
    init (restaurant: Restaurant) {
        self.name = restaurant.name
        self.photo = restaurant.photos?[0]
    }
    
    private func getGesturePercentage(_ geometry: GeometryProxy, from gesture: DragGesture.Value) -> CGFloat {
        gesture.translation.width / geometry.size.width
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading) {
                ZStack(alignment: self.swipeStatus == .like ? .topLeading : .topTrailing) {
                    Image("Doggo")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geometry.size.width, height: geometry.size.height * 0.6)
                        .clipped()
                    
                    if self.swipeStatus == .like {
                        Text("LIKE")
                            .font(.headline)
                            .padding()
                            .cornerRadius(10)
                            .foregroundColor(Color.green)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.green, lineWidth: 3.0)
                            ).padding(24)
                            .rotationEffect(Angle.degrees(-45))
                    } else if self.swipeStatus == .dislike {
                        Text("DISLIKE")
                            .font(.headline)
                            .padding()
                            .cornerRadius(10)
                            .foregroundColor(Color.red)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.red, lineWidth: 3.0)
                            ).padding(.top, 45)
                            .rotationEffect(Angle.degrees(45))
                    }
                }
                
                HStack {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("\(name)")
                            .font(.title)
                            .bold()
                    }
                    
                }
                .padding(.horizontal)
            }
            .padding(.bottom)
            .background(Color.white)
            .cornerRadius(10)
            .animation(.interactiveSpring())
            .offset(x: self.translation.width, y: 0)
            .rotationEffect(.degrees(Double(self.translation.width / geometry.size.width) * 25), anchor: .bottom)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        self.translation = value.translation
                        
                        if (self.getGesturePercentage(geometry, from: value)) >= self.thresholdPercentage {
                            self.swipeStatus = .like
                        } else if self.getGesturePercentage(geometry, from: value) <= -self.thresholdPercentage {
                            self.swipeStatus = .dislike
                        } else {
                            self.swipeStatus = .none
                        }
                        
                    }.onEnded { value in
                        if abs(self.getGesturePercentage(geometry, from: value)) > self.thresholdPercentage {
                            if self.swipeStatus == .like {
                                session.likeRestaurant(name: self.name)
                                print("liked \(name)")
                            }
                            session.removeTopCard()
                        } else {
                            self.translation = .zero
                        }
                    }
            )
        }
    }
}




struct ResetaurantCard_Previews: PreviewProvider {
    static var previews: some View {
        Group {
//            RestaurantCard()
        }
    }
}
