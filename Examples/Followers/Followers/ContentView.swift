//
//  ContentView.swift
//  Followers
//
//  Created by Stefano Bertagno on 10/03/2020.
//

import SwiftUI

internal struct ContentView: View {
    var body: some View {
        NavigationView {
            FollowersView(model: .init())
        }
    }
}

internal struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
