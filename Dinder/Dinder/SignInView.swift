//
//  SignInView.swift
//  Dinder
//
//  Created by Shaun Jorstad on 11/1/20.
//

import Foundation
import SwiftUI

struct SignInView : View {
    @State var email: String = ""
    @State var password: String = ""
    @State var confirmPassword: String = ""
    @State var loading = false
    @State var error = false
    @State var errorMessage: String = ""
    @State var state: String = "onboard"
    
    @EnvironmentObject var session: SessionStore
    
    func signIn () {
        loading = true
        error = false
        session.signIn(email: email, password: password) { (result, error) in
            self.loading = false
            if error != nil {
                self.error = true
                self.errorMessage = error.debugDescription
            } else {
                self.email = ""
                self.password = ""
            }
        }
    }
    
    func signUp() {
        loading = true
        error = false
        session.signUp(email: email, password: password) { (result, error) in
            self.loading = false
            if error != nil {
                self.error = true
                self.errorMessage = error.debugDescription
            } else {
                self.email = ""
                self.password = ""
            }
        }
    }
    
    var body: some View {
        Group {
            if (self.state == "onboard") {
                VStack {
                    Spacer()
                    Text("Dinder")
                        .font(.largeTitle)
                        .fontWeight(.black)
                        .foregroundColor(Color(hex: "2F4858"))
                    Rectangle()
                        .frame(width: 280.0, height: 280.0)
                        .cornerRadius(/*@START_MENU_TOKEN@*/38.0/*@END_MENU_TOKEN@*/)
                    Text("onboarding info")
                    Spacer()
                    Spacer()
                    Button(action: {
                        withAnimation {
                            self.state = "signin"
                        }
                    }) {
                        Text("continue")
                            .padding()
                            .background(Color(hex: "2F4858"))
                            .cornerRadius(12.0)
                            .foregroundColor(.white)
                    }
                    Spacer()
                }
            }
            else if (self.state == "signin") {
                VStack {
                    Spacer()
                    Text("Log in")
                        .font(.largeTitle)
                        .fontWeight(.black)
                        .foregroundColor(Color(hex: "2F4858"))
                    Spacer()
                    Group {
                        TextField("email", text: $email)
                            .padding()
                            .frame(width: 304, height: 60)
                            .background(Color(hex: "F2F7FC"))
                            .cornerRadius(8.0)
                        SecureField("password", text: $password)
                            .padding()
                            .frame(width: 304, height: 60)
                            .background(Color(hex: "F2F7FC"))
                            .cornerRadius(8.0)
                    }
                    Spacer()
                        .frame(height: 118.0)
                    Group {
                        Button(action: {
                            withAnimation {
                                signIn()
                            }
                        }) {
                            Text("Log In")
                                .padding()
                                .frame(width: 300)
                                .background(Color(hex: "2F4858"))
                                .cornerRadius(12.0)
                                .foregroundColor(.white)
                        }
                        Button(action: {
                            withAnimation {
                                self.state = "signup"
                            }
                        }) {
                            Text("create account")
                        }
                    }
                    Spacer()
                }.alert(isPresented: $error) {
                    Alert(title: Text("authentication error"), message: Text("\(errorMessage)"), dismissButton: .default(Text("dismiss")) )
                }
            } else {
                VStack {
                    Spacer()
                    Text("Join")
                        .font(.largeTitle)
                        .fontWeight(.black)
                        .foregroundColor(Color(hex: "2F4858"))
                    Spacer()
                    Group {
                        TextField("email", text: $email)
                            .padding()
                            .frame(width: 304, height: 60)
                            .background(Color(hex: "F2F7FC"))
                            .cornerRadius(8.0)
                        SecureField("password", text: $password)
                            .padding()
                            .frame(width: 304, height: 60)
                            .background(Color(hex: "F2F7FC"))
                            .cornerRadius(8.0)
                        SecureField("confirm password", text: $confirmPassword)
                            .padding()
                            .frame(width: 304, height: 60)
                            .background(Color(hex: "F2F7FC"))
                            .cornerRadius(8.0)
                    }
                    Spacer()
                        .frame(height: 118.0)
                    Group {
                        Button(action: {
                            if (self.password == self.confirmPassword) {
                                withAnimation {
                                    signUp()
                                }
                            }
                        }) {
                            Text("Join")
                                .padding()
                                .frame(width: 300)
                                .background(Color(hex: "2F4858"))
                                .cornerRadius(12.0)
                                .foregroundColor(.white)
                        }
                        Button(action: {
                            withAnimation {
                                self.state = "signin"
                            }
                        }) {
                            Text("cancel")
                        }
                    }
                    Spacer()
                }.alert(isPresented: $error) {
                    Alert(title: Text("authentication error"), message: Text("\(errorMessage)"), dismissButton: .default(Text("dismiss")) )
                }
            }
        }
        
    }
}

#if DEBUG
struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            SignInView(state: "onboard")
            SignInView(state: "signin")
            SignInView(state: "signup")
        }
    }
}
#endif

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
