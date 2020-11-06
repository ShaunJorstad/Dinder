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
                HomeView()
            } else {
                SignInView()
            }
        }.onAppear(perform: getUser)
    }
}

struct HomeView: View {
    @State private var selection = 0
    
    var body: some View {
        NavigationView{
            TabView {
                VStack{
                    NavigationLink(destination: CreateSession()){
                        Text("Create Session")
                    }
                }.tabItem{VStack{
                    Image(systemName: "mappin.and.ellipse")
                    Text("Sessions")
                }}.tag(0)
                Account().tabItem{VStack{
                    Image(systemName: "person.circle.fill")
                    Text("Settings")
                }}.tag(1)
            }
        }
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
