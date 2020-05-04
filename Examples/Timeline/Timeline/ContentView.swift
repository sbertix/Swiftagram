//
//  ContentView.swift
//  Timeline
//
//  Created by Stefano Bertagno on 05/04/2020.
//  Copyright © 2020 Stefano Bertagno. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            TimelineView(model: .init())
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
