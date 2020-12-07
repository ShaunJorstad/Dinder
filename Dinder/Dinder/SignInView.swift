//
//  SignInView.swift
//  Dinder
//
//  Created by Shaun Jorstad on 11/1/20.
//

import Foundation
import SwiftUI

struct AlertId: Identifiable {
    
    var id: AlertType
    
    enum AlertType {
        case invalidEmail
        case confirmReset
    }
}

struct SignInView : View {
    @State var email: String = ""
    @State var password: String = ""
    @State var confirmPassword: String = ""
    @State var loading = false
    @State var error = false
    @State var errorTitle: String = ""
    @State var errorMessage: String = ""
    @State var alertId: AlertId?
    @State var state: String = "onboard"
    @State var resetPasswordPrompt = false
    
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
                self.errorTitle = "authentication error"
                self.errorMessage = error.debugDescription
            } else {
                self.email = ""
                self.password = ""
            }
        }
    }
    
    func resetPassword() {
        session.sendPasswordResetEmail(email: email) { (error) in
            self.loading = false
            if error != nil {
                self.error = true
                self.errorTitle = "authentication error"
                self.errorMessage = error.debugDescription
            }
        }
    }
    
    private func createAlert(alertId: AlertId) -> Alert {
        switch alertId.id {
        case .invalidEmail:
            return Alert(title: Text("Can't reset email"), message: Text("please enter email in email field"), dismissButton: .default(Text("dismiss")))
        case .confirmReset:
            return Alert(title: Text("Confirm reset"), message: Text("A password recovery email will be sent to \(email)"), primaryButton: .destructive(Text("reset")) {
                resetPassword()
            }, secondaryButton: .cancel() )
        }
    }
    
    var body: some View {
        Group {
            if (self.state == "onboard") {
                VStack {
                    Spacer()
                    Text("Dinder")
                        .dinderTitleStyle()
                    Image("logo")
                        .resizable()
                             .aspectRatio(contentMode: .fill)
                             .frame(width: 250.0, height: 250.0, alignment: .center)
                             .clipped()
                    Text("We help you decide on restaurants quickly and easily! \n1. Create or join a session\n2.Swipe left or right on restaurants\n3. We do the rest!").padding()
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
                        .dinderTitleStyle()
                    Spacer()
                    Group {
                        TextField("email", text: $email)
                        SecureField("password", text: $password)
                        Button(action: {
                            if (self.email == "") {
                                self.alertId = AlertId(id: .invalidEmail)
                            } else {
                                self.alertId = AlertId(id: .confirmReset)
                            }
                        }) {
                            Text("recover password")
                                .frame(width: 300, alignment: .leading)
                        }.alert(item: $alertId) { (alertId) -> Alert in
                            createAlert(alertId: alertId)
                        }
                    }.textFieldStyle(DinderTextFieldStyle())
                    Spacer()
                        .frame(height: 118.0)
                    Group {
                        Button(action: {
                            withAnimation {
                                signIn()
                            }
                        }) {
                            Text("Log In")
                        }.buttonStyle(DinderButtonStyle())
                        .alert(isPresented: $error) {
                            Alert(title: Text("\(errorTitle)"), message: Text("\(errorMessage)"), dismissButton: .default(Text("dismiss")) )
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
                }
            } else {
                VStack {
                    Spacer()
                    Text("Join")
                        .dinderTitleStyle()
                    Spacer()
                    Group {
                        TextField("email", text: $email)
                        SecureField("password", text: $password)
                        SecureField("confirm password", text: $confirmPassword)
                    }.textFieldStyle(DinderTextFieldStyle())
                    Spacer()
                        .frame(height: 118.0)
                    Group {
                        Button(action: {
                            if (self.password == self.confirmPassword) {
                                withAnimation {
                                    signUp()
                                }
                            } else {
                                self.error = true
                                self.errorMessage = "Passwords did not match"
                            }
                        }) {
                            Text("Join")
                        }.buttonStyle(DinderButtonStyle())
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
