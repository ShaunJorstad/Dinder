//
//  ContentView.swift
//  Dinder
//
//  Created by Shaun Jorstad on 11/1/20.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var session: SessionStore
    
    func getUser() {
        session.listen()
    }
    
    var body: some View {
        Group {
            if (session.session != nil) {
                Account()
            } else {
                SignInView()
            }
        }.onAppear(perform: getUser)
    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(SessionStore())
    }
}
#endif
