//
//  CreateSession.swift
//  Dinder
//
//  Created by Luke on 11/3/20.
//

import SwiftUI

struct CreateSession: View {
    @EnvironmentObject var session: SessionStore
    
    @State var timeLimit: Int = 1
    @State var radius: Int = 1
    
    var form: some View {
        VStack {
            Spacer()
            Text("Share this code:")
                .dinderTitleStyle()
            if let code = session.sessionCode {
                Text(verbatim: "\(code)")
                    .dinderTitleStyle()
            } else {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .onAppear(perform: session.createSession)
            }
            Spacer()
            HStack {
                Text("Travel Radius:")
                    .dinderRegularStyle()
                Stepper(value: $radius, in: 1...100) {
                    Text("\(radius) mile")
                        .dinderRegularStyle()
                }
            }.padding()
            HStack {
                Text("Time Limit:")
                    .dinderRegularStyle()
                Stepper(value: $timeLimit, in: 1...10) {
                    Text("\(timeLimit) minutes")
                        .dinderRegularStyle()
                }
            }.padding()
            Spacer()
            Text("Party of \(session.numParticipants)")
                .dinderRegularStyle()
            Button(action: start) {
                Text("Start")
            }.disabled(session.sessionCode == nil)
            Spacer()
        }.buttonStyle(DinderButtonStyle())
    }
    
    var body: some View {
        Group {
            if (!session.sessionLive) {
                form
            } else if (session.sessionLive && session.restaurantList == nil) {
                VStack {
                    Text("Fetching Restaraunt List")
                        .dinderTitleStyle()
                    ProgressView()
                }
            } else if (session.sessionLive) {
                LiveSession(created: true)
            }
        }
        //Replace with actual api call
        .onReceive(loadJsonFromBundle(filename: "response", fileExtension: "json"), perform: updateRestaurantList)
        .onDisappear {
            if !session.sessionLive {
                session.deleteSession()
            }
        }
    }
    
    func updateRestaurantList(list: RestaurantList?) {
        guard let list = list else {
            return
        }
        
        print("Hello")
        
        session.updateRestaurantList(list: list)
    }
    
    func start() {
        session.updateSessionTime(time: timeLimit)
        session.updateSessionRadius(radius: radius)
        session.startSession()
    }
}

struct CreateSession_Previews: PreviewProvider {
    static var previews: some View {
        let session = SessionStore()
        session.signIn(email: "test@example.com", password: "qwerty", handler: {_,_  in})
        
        return Group {
            CreateSession().environmentObject(session)
        }
    }
}
