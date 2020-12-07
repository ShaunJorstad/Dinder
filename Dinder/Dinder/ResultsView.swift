//
//  ResultsView.swift
//  Dinder
//
//  Created by Isabella Patnode on 12/7/20.
//

import Foundation
import SwiftUI

struct ResultsView: View {
    @EnvironmentObject var session: SessionStore
    
    var body: some View {
        
        Text("\(session.result)")
    }
}
