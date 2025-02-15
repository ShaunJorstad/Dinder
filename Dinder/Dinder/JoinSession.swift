//
//  Account.swift
//  Dinder
//
//  Created by Shaun Jorstad on 11/1/20.
//

import Foundation
import SwiftUI

struct JoinSession: View {
    @EnvironmentObject var session: SessionStore
    @State var inputSessionCode: String = ""
    
    func getCode() -> Int {
        return Int(inputSessionCode) ?? 1000
    }
    
    var body: some View {
        Group {
            if (session.sessionCode == nil && session.result == ""){
                VStack {
                    Spacer()
                    Text("Enter Code")
                        .dinderTitleStyle()
                    Spacer()
                    TextField("code", text: $inputSessionCode)
                        .textFieldStyle(DinderTextFieldStyle())
                    Button(action: {
                        session.joinSession(joinCode: getCode())
                    }) {
                        Text("Join")
                    }
                    Spacer()
                }.buttonStyle(DinderButtonStyle())
            } else if (session.sessionCode != nil && !session.sessionLive && session.result == "" || session.sessionCode != nil && session.sessionLive && session.restaurantList == nil && session.result == "") {
                Text("Waiting for session to start")
                    .dinderTitleStyle()
            } else if (session.sessionCode != nil && session.sessionLive && session.result == "") {
                LiveSession(created: false)
            } else if (session.sessionCode != nil && !session.sessionLive && session.result != "") {
                Text("You all chose: \(session.result)").dinderTitleStyle()
            }
        }
        .onDisappear {
            if (session.sessionCode != nil) {
                session.leaveSession()
            }
        }
    }
}

struct JoinSession_Previews: PreviewProvider {
    static var previews: some View {
        JoinSession()
    }
}
