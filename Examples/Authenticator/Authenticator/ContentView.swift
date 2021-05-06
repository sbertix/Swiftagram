//
//  ContentView.swift
//  Authenticator
//
//  Created by Stefano Bertagno on 07/02/21.
//

import SwiftUI

import Swiftagram

struct ContentView: View {
    /// Whether it should present the login view or not.
    @State var isPresentingLoginView: Bool = false
    /// The current secret.
    @State var secret: Secret?

    /// The actual view.
    var body: some View {
        VStack(spacing: 40) {
            // The header.
            Image("header")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 50)
            // Check for token.
            if let secret = secret, let token = secret.token {
                Text(token)
                    .font(Font.headline.smallCaps())
                    .foregroundColor(.primary)
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)
                    .onTapGesture { UIPasteboard.general.string = token }
                Text("(Tap to copy it in your clipboard)")
                    .font(.caption)
                    .fixedSize(horizontal: false, vertical: true)
            } else {
                // The disclaimer.
                Text.combine(
                    Text("Please authenticate with your "),
                    Text("Instagram").bold(),
                    Text(" account to receive a token for "),
                    Text("SwiftagramTests").bold()
                )
                .fixedSize(horizontal: false, vertical: true)
                // Login.
                Button(action: { isPresentingLoginView = true }) {
                    Text("Authenticate").font(.headline)
                }.foregroundColor(.accentColor)
            }
        }
        .foregroundColor(.secondary)
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.vertical)
        .padding(.horizontal, 50)
        .sheet(isPresented: $isPresentingLoginView) { LoginView(secret: $secret) }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
