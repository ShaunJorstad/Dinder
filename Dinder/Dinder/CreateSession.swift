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
    
    var body: some View {
        Group {
            if (!session.sessionLive) {
                VStack {
                    Spacer()
                    Text("Share this code:")
                        .font(.largeTitle)
                        .fontWeight(.black)
                        .foregroundColor(Color(hex: "2F4858"))
                    if let code = session.sessionCode {
                        Text(verbatim: "\(code)")
                            .font(.largeTitle)
                            .fontWeight(.black)
                            .foregroundColor(Color(hex: "2F4858"))
                    } else {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .onAppear(perform: session.createSession)
                    }
                    Spacer()
                    HStack {
                        Text("Travel Radius:")
                            .fontWeight(.black)
                            .foregroundColor(Color(hex: "2F4858"))
                        Stepper(value: $radius, in: 1...100) {
                            Text("\(radius) mile")
                                .fontWeight(.black)
                                .foregroundColor(Color(hex: "2F4858"))
                        }
                    }.padding()
                    HStack {
                        Text("Time Limit:")
                            .fontWeight(.black)
                            .foregroundColor(Color(hex: "2F4858"))
                        Stepper(value: $timeLimit, in: 1...10) {
                            Text("\(timeLimit) minutes")
                                .fontWeight(.black)
                                .foregroundColor(Color(hex: "2F4858"))
                        }
                    }.padding()
                    Spacer()
                    Text("Party of \(session.numParticipants)")
                    Button(action: {
                        session.updateSessionTime(time: timeLimit)
                        session.updateSessionRadius(radius: radius)
                        session.startSession()
                        //TODO go to next view
                    }) {
                        Text("Start")
                    }.disabled(session.sessionCode == nil)
                    Spacer()
                }.buttonStyle(DinderButtonStyle())
            } else if (session.sessionLive){
                LiveSession(created: true)
            }
        }.onDisappear(perform: {
            if !session.sessionLive {
                session.deleteSession()
            }
        })
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
