//
//  LastNameView.swift
//  Tastys
//
//  Created by Nnagoziem Collins Okegbe on 21/12/2025.
//

import SwiftUI

struct LastNameView: View {
    @Environment(\.dismiss) var dismiss
    var id: String
    var firstName: String
    @State private var lastName = ""
    var body: some View {
        ZStack{
            Color.fakeWhite
                .ignoresSafeArea()
            
            
            VStack(alignment: .leading, spacing: 15){
//                Spacer()
                Text("Enter your Last name")
                    .foregroundStyle(.black)
                    .font(.system(size: 32))
                    .fontWeight(.medium)
                
                Text("Enter your last name so we \nget to know a bit more about you")
                    .foregroundStyle(.black)
                    .opacity(0.5)
                    .font(.system(size: 14))
                    .fontWeight(.medium)
                
                
                ReuseableTextField(text: $lastName, placeholder: "Last name")
                    .padding(.vertical, 25)
                
                Spacer()
                
                NavigationLink{
                    PasswordView(id: id, firstName: firstName, lastName: lastName)
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
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button{
                    dismiss()
                } label: {
                    Image("backButtonIcon")
                        .renderingMode(.template)
                        .foregroundStyle(.black)
                        .padding()
                        .clipShape(Circle())
                    .foregroundStyle(.white)
                }
            }
        }
    }
}

#Preview {
    LastNameView(id: "", firstName: "")
}
