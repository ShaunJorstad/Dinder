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
    
    init(created: Bool) {
        self.creator = created
    }

    var body: some View {
        Group {
            Text("Session just started!")
                .dinderTitleStyle()
        }
        .onDisappear {
            if (session.sessionCode != nil && self.creator) {
                session.deleteSession()
            } else if (session.sessionCode != nil && !self.creator) {
                session.leaveSession()
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
