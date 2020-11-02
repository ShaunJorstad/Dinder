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
    @State var signin = true
    
    @EnvironmentObject var session: SessionStore
    
    func signIn () {
        loading = true
        error = false
        session.signIn(email: email, password: password) { (result, error) in
            self.loading = false
            if error != nil {
                self.error = true
                self.email = error.debugDescription
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
                self.email = error.debugDescription
            } else {
                self.email = ""
                self.password = ""
            }
        }
    }
    
    var body: some View {
        Group {
            if (self.signin) {
                VStack {
                    TextField("email", text: $email)
                    SecureField("password", text: $password)
                    if (error) {
                        Text("ahhh crap")
                    }
                    Button(action: {
                        signIn()
                    }) {
                        Text("Log In")
                    }
                    Button(action: {
                        self.signin = false
                    }) {
                        Text("Sign Up")
                    }
                }
            } else {
                VStack {
                    TextField("email", text: $email)
                    SecureField("password", text: $password)
                    SecureField("confirm password", text: $confirmPassword)
                    if (error) {
                        Text("ahhh crap")
                    }
                    Button(action: {
                        if (self.password == self.confirmPassword) {
                            signUp()
                        }
                    }) {
                        Text("Sign up")
                    }
                    Button(action: {
                        self.signin = true
                    }) {
                        Text("cancle")
                    }
                }
            }
        }
        
    }
}

struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView()
    }
}
