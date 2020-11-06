//
//  DinderTextStyle.swift
//  Dinder
//
//  Created by Luke on 11/6/20.
//

import SwiftUI

extension Text {
    func dinderTitleStyle() -> some View {
        self.font(.largeTitle)
            .fontWeight(.black)
            .foregroundColor(Color(hex: "2F4858"))
    }
    
    func dinderRegularStyle() -> some View {
        self.fontWeight(.black)
            .foregroundColor(Color(hex: "2F4858"))
    }
}
