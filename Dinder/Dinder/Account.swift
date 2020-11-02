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

    var body: some View {
        VStack {
            Text(session.getEmail())
            Button(action: {
                session.signOut()
            }) {
                Text("sign out")
            }
        }
    }
}
