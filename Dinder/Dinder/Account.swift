//
//  Account.swift
//  Dinder
//
//  Created by Shaun Jorstad on 11/1/20.
//

import Foundation
import SwiftUI

struct Account: View {
    @EnvironmentObject var session: SessionStore
    @State var deleteAccountPrompt = false
    @State var changePasswordPrompt = false
    
    var body: some View {
        VStack(spacing: 10.0) {
            Group {
                Spacer()
                Text("Settings")
                    .font(.largeTitle)
                    .fontWeight(.black)
                    .foregroundColor(Color(hex: "2F4858"))
                Spacer()
            }
            Button(action: {
                self.changePasswordPrompt = true
            }) {
                HStack {
                    Image(systemName: "pencil.circle")
                    Text("change password")
                }
            }.alert(isPresented: $changePasswordPrompt) {
                Alert(title: Text("Password Reset"), message: Text("this will send a password reset email to \(session.getEmail()) and will force you to re-sign in"), primaryButton: .destructive(Text("reset")) {
                    session.sendPasswordResetEmail(email: session.getEmail()) {(error) in
                        
                    }
                }, secondaryButton: .cancel() )
            }
            Button(action: {
                session.signOut()
            }) {
                HStack {
                    Image(systemName: "square.and.arrow.up")
                    Text("sign out")
                }
            }
            Button(action: {
                self.deleteAccountPrompt = true
            }) {
                HStack {
                    Image(systemName: "trash.fill")
                    Text("delete account")
                }
            }.alert(isPresented: $deleteAccountPrompt) {
                Alert(title: Text("Confirm deletion"), message: Text("this will permanently delete your account"), primaryButton: .destructive(Text("delete")) {
                    session.delete()
                }, secondaryButton: .cancel() )
            }
            
            Spacer()
        }
    }
}

struct Account_Previews: PreviewProvider {
    static var previews: some View {
        Account()
    }
}
