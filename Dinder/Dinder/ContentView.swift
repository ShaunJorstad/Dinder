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
    @EnvironmentObject var session: SessionStore
    
    var body: some View {
        NavigationView{
            TabView {
                VStack{
                    Spacer()
                    Text("Dinder")
                        .font(.largeTitle)
                        .fontWeight(.black)
                        .foregroundColor(Color(hex: "2F4858"))
                    Spacer()
                    NavigationLink(destination: CreateSession()){
                        Text("Create Session")
                    }
                    NavigationLink(destination: JoinSession()) {
                        Text("Join Session")
                    }
                    Spacer()
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
