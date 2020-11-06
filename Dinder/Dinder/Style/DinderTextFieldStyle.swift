//
//  DinderTextFieldStyle.swift
//  Dinder
//
//  Created by Luke on 11/6/20.
//

import SwiftUI

struct DinderTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .frame(width: 304, height: 60)
            .background(Color(hex: "F2F7FC"))
            .cornerRadius(8.0)
    }
}
