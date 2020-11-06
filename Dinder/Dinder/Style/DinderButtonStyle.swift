//
//  DinderButtonStyle.swift
//  Dinder
//
//  Created by Luke on 11/2/20.
//

import SwiftUI

struct DinderButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button(configuration: configuration)
    }
    
    struct Button: View {
        let configuration: ButtonStyle.Configuration
        
        @Environment(\.isEnabled) private var isEnabled: Bool
        
        var body: some View {
            configuration.label
                .frame(maxWidth: 300)
                .foregroundColor(.white)
                .font(Font.body.bold())
                .padding()
                .background(isEnabled ? Color(hex: "2F4858").opacity(
                    configuration.isPressed ? 0.5 : 1
                ) : Color.gray)
                .cornerRadius(12)
        }
    }
}


struct DinderButtonStyle_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Button(action: {}) {
                Text("Enabled")
            }
            Button(action: {}) {
                Text("Disabled")
            }.disabled(true)
        }.buttonStyle(DinderButtonStyle())
    }
}
