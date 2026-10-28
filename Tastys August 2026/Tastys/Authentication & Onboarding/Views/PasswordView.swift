//
//  PasswordView.swift
//  Tastys
//
//  Created by Nnagoziem Collins Okegbe on 16/12/2025.
//

import SwiftUI

struct PasswordView: View {
    @Environment(\.dismiss) var dismiss
    var id: String
    var firstName: String
    var lastName: String
    @State private var password = ""
    var body: some View {
        ZStack{
            Color.fakeWhite
                .ignoresSafeArea()
            
            
            VStack(alignment: .leading, spacing: 15){
//                Spacer()
                Text("Enter your password")
                    .foregroundStyle(.black)
                    .font(.system(size: 32))
                    .fontWeight(.medium)
                
                Text("Enter a safe and secure password")
                    .foregroundStyle(.black)
                    .opacity(0.5)
                    .font(.system(size: 14))
                    .fontWeight(.medium)
                
                
                ReuseableSecureField(password: $password)
                    .padding(.vertical, 25)
                
                Spacer()
                
                NavigationLink{
//                    VerifyEmailView(isUsingEmail: false, text: id)
                } label: {
                    HStack {
                        Spacer()
                        Text("Continue")
                            .foregroundStyle(.white)
                            .font(.system(size: 16))
                            .fontWeight(.bold)
                        .padding(.vertical)
                        Spacer()
                            
                    }
                    .background{
                        RoundedRectangle(cornerRadius: 25.0)
                            .foregroundStyle(.tastysRed)
                    }
                
                }
                
            }
            .padding(.horizontal)
            .padding(.vertical, 24)
        }
//        .navigationBarBackButtonHidden()
//        .toolbar {
//            ToolbarItem(placement: .navigationBarLeading) {
//                Button{
//                    dismiss()
//                } label: {
//                    Image("backButtonIcon")
//                        .renderingMode(.template)
//                        .foregroundStyle(.black)
//                        .padding()
//                        .clipShape(Circle())
//                    .foregroundStyle(.white)
//                }
//            }
//        }
    }
}

#Preview {
    PasswordView(id: "", firstName: "", lastName: "")
}
