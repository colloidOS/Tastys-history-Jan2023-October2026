//
//  AddNewPlateView.swift
//  Tastys
//
//  Created by Nnagoziem Collins Okegbe on 11/01/2026.
//

import SwiftUI

struct AddNewPlateView: View {
//    @Binding var isShowing: Bool
//    @State private var plateName = ""
    @EnvironmentObject var viewModel: HomeViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var plateName: String = ""
    @State private var isCreating: Bool = false
    @FocusState private var isTextFieldFocused: Bool
    let onSuccess: () -> Void
    var body: some View {
        ZStack{
            Color.ashTastys
                .opacity(0.9)
                .ignoresSafeArea()
                .blur(radius: 2)
            VStack{
                dragKnob
                    .padding(.vertical, 10)
//                Button {
//                    dismiss()
//                } label: {
//                    Image(systemName: "xmark")
//                        .foregroundStyle(.white)
//                        .font(.system(size: 20))
//                        .fontWeight(.bold)
//                        .padding(10)
//                }
                
                Spacer()
                
                HStack {
                    
                    ZStack (alignment: .leading){
                        TextField("", text: $plateName)
                            .font(.system(size: 12))
                            .fontWeight(.semibold)
                            .foregroundStyle(.black)
                            .multilineTextAlignment(.leading)
                            .focused($isTextFieldFocused)
                            .disabled(isCreating)
                        if plateName.isEmpty {
                            Text("plate name")
                                .foregroundStyle(.black)
                                .opacity(0.5)
                                .font(.system(size: 18))
                                .fontWeight(.semibold)
                        }
                        
                    }
                    
                    
                }
                .padding([.horizontal], 18)
                .padding(.vertical, 12)
                .background {
                    RoundedRectangle(cornerRadius: 15)
                        .foregroundStyle(.white)
                }
                .padding([.horizontal/*, .vertical*/], 20)
                
                
                Button{
                    Haptics.slide()
                    guard !plateName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                        viewModel.errorMessage = "Plate name cannot be empty"

                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                viewModel.errorMessage = nil
                            }

                            return
                        }
                    createPlate()
                } label: {
                    HStack {
                        Spacer()
                        if isCreating {
                            HStack (spacing: 3){
                                ProgressView()
                                Text("Creating..")
                                    .foregroundStyle(.white)
                                    .font(.system(size: 16))
                                    .fontWeight(.bold)
                            }
                            .padding(.vertical)
                        } else {
                            Text("Create Plate")
                                .foregroundStyle(.white)
                                .font(.system(size: 16))
                                .fontWeight(.bold)
                                .padding(.vertical)
                        }
                        Spacer()
                        
                    }
                    .background{
                        RoundedRectangle(cornerRadius: 23.0)
                            .foregroundStyle(.tastysRed)
                    }
                    .padding([.horizontal, .bottom], 20)
                }
                .disabled(isCreating)
            }
//            if !isCreating{
//                Color.ashTastys
//                    .opacity(0.2)
////                    .ignoresSafeArea()
//                
//                ProgressView()
//            }
        }
        .onAppear{
            Haptics.prepare()
        }
        .onTapGesture {
            isTextFieldFocused = false
        }
    }
    private var dragKnob: some View {
        RoundedRectangle(cornerRadius: 10)
            .frame(width: 40, height: 5)
            .foregroundStyle(.gray.opacity(0.4))
            .padding(.top, 8)
    }
    
    private func createPlate() {
        guard let userId = viewModel.session?.user.id else {
            return
        }
        
        isCreating = true
        Task {
            if let _ = await viewModel.createUserPlate(userId: userId, plateName: plateName) {
                await MainActor.run {
                    onSuccess()
                    dismiss()
                }
            }
            await MainActor.run {
                isCreating = false
            }
        }
    }
}

#Preview {
    AddNewPlateView(onSuccess: {})
//    CreatePlateView(onSuccess: {})
        .environmentObject(HomeViewModel())
}


