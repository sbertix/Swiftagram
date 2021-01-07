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
    /// The currently displayed sheet view.
    @State var shouldDisplayLogin: Bool = false

    var body: some View {
        List {
            // Add rows.
            if model.followers == nil {
                Text("Loading…")
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .padding(.vertical)
            } else if model.followers?.isEmpty == true {
                Text("No followers.")
                    .padding(.vertical)
            } else {
                ForEach(model.followers ?? [], id: \.username.hashValue) { user in
                    /// Visit **Instagram** on tap.
                    Button(action: {
                        UIApplication.shared.open(URL(string: "https://instagram.com/"+user.username)!,
                                                  options: [:],
                                                  completionHandler: nil)
                    }) {
                        HStack {
                            UserCell(user: user)
                            Spacer()
                            Image(systemName: "chevron.right").imageScale(.small).foregroundColor(.secondary)
                        }
                        .padding(.vertical)
                    }
                }
            }
        }
        .listStyle(PlainListStyle())
        .onAppear {
            guard self.model.secret == nil else { return }
            self.shouldDisplayLogin = true
        }
        .sheet(isPresented: $shouldDisplayLogin) { LoginView(secret: self.$model.secret) }
        .navigationBarTitle("Followers")
        .navigationBarItems(trailing:
            model.current?.avatar.flatMap {
                RemoteImage(url: $0, placeholder: UIImage(named: "placeholder")!)
                    .frame(width: 30, height: 30)
                    .mask(Circle())
                    .shadow(radius: 1)
            }
        )
    }
}
