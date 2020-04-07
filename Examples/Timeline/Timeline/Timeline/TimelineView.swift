//
//  TimelineView.swift
//  Timeline
//
//  Created by Stefano Bertagno on 10/03/2020.
//  Copyright © 2020 Stefano Bertagno. All rights reserved.
//

import SwiftUI
import UIKit

struct TimelineView: View {
    /// The model.
    @ObservedObject var model: TimelineModel
    /// The currently displayed sheet view.
    @State var shouldDisplayLogin: Bool = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                ForEach(model.posts ?? [], content: PostView.init)
                // Load more.
                if model.posts?.isEmpty == false {
                    Button(action: { self.model.next() }) {
                        Text(self.model.isLoading ? "Loading" : "Load more")
                            .font(Font.footnote.smallCaps())
                            .foregroundColor(.secondary)
                            .padding()
                            .frame(maxWidth: .infinity)
                    }
                    .disabled(self.model.isLoading)
                    .frame(maxWidth: .infinity)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.01), radius: 4, x: 0, y: 2)
                    .padding()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .animation(.interactiveSpring())
        }
        .onAppear {
            guard self.model.secret == nil else { return }
            self.shouldDisplayLogin = true
        }
        .sheet(isPresented: $shouldDisplayLogin) { LoginView(secret: self.$model.secret) }
        .navigationBarTitle("Timeline")
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
