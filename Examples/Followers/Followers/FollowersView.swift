//
//  FollowersView.swift
//  Followers
//
//  Created by Stefano Bertagno on 10/03/2020.
//  Copyright © 2020 Stefano Bertagno. All rights reserved.
//

import SwiftUI
import UIKit

struct FollowersView: View {
    /// The model.
    @ObservedObject var model: FollowersModel

    /// The underlying view.
    var body: some View {
        List {
            // Check for followers.
            if let followers = model.followers {
                // If it's empty, just let the user know.
                if followers.isEmpty {
                    Text("No followers.").padding(.vertical)
                } else {
                    ForEach(followers, id: \.identifier) { user in
                        Button(action: {
                            // Open their profile on tap.
                            guard let url = URL(string: "https://instagram.com/"+user.username) else { return }
                            UIApplication.shared.open(url,
                                                      options: [:],
                                                      completionHandler: nil)
                        }) {
                            UserCell(user: user).padding(.vertical)
                        }
                    }
                }
            } else {
                Text("Loading…").padding(.vertical)
            }
        }
        .listStyle(PlainListStyle())
        .sheet(isPresented: model.shouldPresentLoginView) { LoginView(didAuthenticate: model.authenticate).id("login") }
        .navigationTitle("Followers")
        .navigationBarItems(trailing: AvatarButton(user: model.current, action: model.logOut))
    }
}
