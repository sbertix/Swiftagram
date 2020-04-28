//
//  LoginView.swift
//  Ghoster
//
//  Created by Stefano Bertagno on 23/03/2020.
//  Copyright © 2020 Stefano Bertagno. All rights reserved.
//

import SwiftUI

import Swiftagram

struct LoginView: View {
    /// The context.
    @Environment(\.managedObjectContext) var context
    /// The presentation mode.
    @Environment(\.presentationMode) var presentationMode
    /// The login model.
    @ObservedObject var model: LoginModel
    /// The binding.
    @Binding var secret: Secret?
    
    /// Init.
    init(secret: Binding<Secret?>) {
        self.model = .init()
        self._secret = secret
    }
    
    /// The actual body.
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // header.
            Group {
                Spacer()
                Image(systemName: "person.crop.circle.fill")
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 40)
                    .fixedSize()
                Text("Instagram")
                    .font(.largeTitle)
                    .bold()
                    .lineLimit(1)
                    .fixedSize(horizontal: false, vertical: true)
                Divider().padding(.vertical, 8)
            }
            // inputs.
            if model.stage.shouldDisplayBasicAuth {
                Text("Username").font(Font.caption.smallCaps())
                TextField("your.username.here", text: $model.username)
                    .autocapitalization(.none)
                    .textContentType(.username)
                    .disableAutocorrection(true)
                    .padding(.bottom, 8)
                Text("Password").font(Font.caption.smallCaps())
                SecureField("••••••••••••", text: $model.password)
                    .autocapitalization(.none)
                    .textContentType(.password)
                    .disableAutocorrection(true)
                    .padding(.bottom, 8)
            } else if model.stage.shouldDisplayCode {
                Text("Code").font(Font.caption.smallCaps())
                TextField("••••••", text: $model.code)
                    .autocapitalization(.none)
                    .textContentType(.oneTimeCode)
                    .disableAutocorrection(true)
                    .padding(.bottom, 8)
            }
            Button(model.stage.button) {
                // notify signing in.
                withAnimation { self.model.advance() }
            }
            .disabled(model.stage.isLocked)
            // disclarimer.
            Group {
                Spacer()
                Spacer()
                Text("Your password is never saved and cookies always stored encrypted.")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.trailing, 100)
            }
        }
        .padding()
        .onReceive(model.$secret.compactMap { $0 }) {
            // store model.
            self.secret = $0
            // dismiss.
            self.presentationMode.wrappedValue.dismiss()
        }
    }
}
