//
//  RecommendFilterView.swift
//  Tastys
//
//  Created by Nnagoziem Collins Okegbe on 17/12/2025.
//

import SwiftUI

struct RecommendFilterView: View {
    @EnvironmentObject var viewModel: HomeViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var palletName = ""
    @State private var reason = ""
    @State private var selectedEmoji: String = ""
    @FocusState private var emojiFieldFocused: Bool
    @FocusState private var isTextFieldFocused: Bool
    var body: some View {
        ZStack {
            Color.ashTastys
                .opacity(0.9)
                .ignoresSafeArea()
            
//            if emojiFieldFocused {
//                PopUpView(error: "Pick an emoji")
//            }
            
            VStack {
                dragKnob
                
                Spacer()
                
                HStack {
                    TextField("Category name", text: $palletName)
                        .foregroundStyle(.black)
                        .font(.system(size: 14))
                        .fontWeight(.semibold)
                        .focused($isTextFieldFocused)
                    Spacer()
                    
                    ZStack {
                        TextField("", text: $selectedEmoji)
                            .keyboardType(.default)
                            .focused($emojiFieldFocused)
                            .opacity(0.01)
                            .frame(width: 2, height: 1)
                            .onChange(of: selectedEmoji) { newValue in
                                // Keep only last character
                                if newValue.count > 1 {
                                    selectedEmoji = String(newValue.suffix(1))
                                    return
                                }
                                
                                // Only allow emoji
                                if !newValue.isEmpty && !newValue.isSingleEmoji {
                                    selectedEmoji = ""
                                    return
                                }
                                
                                // Close keyboard after valid emoji
                                if newValue.isSingleEmoji {
                                    emojiFieldFocused = false
                                }
                            }
                        
//                        Button {
//                            Haptics.slide()
//                            emojiFieldFocused = true
//                        } label: {
//                            HStack {
//                                if selectedEmoji.isEmpty {
//                                    Image(systemName: "plus")
//                                        .font(.system(size: 13, weight: .semibold))
//                                    
//                                    Text("upload icon")
//                                        .font(.system(size: 13))
//                                } else {
//                                    Text(selectedEmoji)
//                                        .font(.system(size: 22))
//                                    
//                                    Image(systemName: "pencil")
//                                        .font(.system(size: 12))
//                                        .padding(10)
//                                        .background(Color.white)
//                                        .clipShape(Circle())
//                                }
//                            }
//                            .foregroundStyle(.black)
//                            .padding(.horizontal, 4)
//                            .padding(.vertical, 1)
//                            .background {
//                                Color.rectTastys
//                                    .clipShape(RoundedRectangle(cornerRadius: 21))
//                            }
//                        }
                    }
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 10)
                .background {
                    Color.white
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                }
                
                HStack {
                    TextField("Tell us why", text: $reason)
                        .foregroundStyle(.black)
                        .font(.system(size: 14))
                        .fontWeight(.semibold)
                        .focused($isTextFieldFocused)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 13)
                .background {
                    Color.white
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                
                Button {
                    Haptics.slide()
                    guard !palletName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                        viewModel.errorMessage = "Pallet name cannot be empty"

                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                viewModel.errorMessage = nil
                            }

                            return
                        }

                        guard !reason.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                            viewModel.errorMessage = "Reason cannot be empty"

                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                viewModel.errorMessage = nil
                            }

                            return
                        }
                    Task {
                        let result = await viewModel.createRecommendation(
                            name: palletName.trimmingCharacters(in: .whitespacesAndNewlines),
                            reason: reason.trimmingCharacters(in: .whitespacesAndNewlines),
                            emoji: selectedEmoji.trimmingCharacters(in: .whitespacesAndNewlines)
                        )
                        
                        if result != nil {
                            // Success: clear fields and dismiss the view
                            palletName = ""
                            reason = ""
                            selectedEmoji = ""
                            dismiss()
                        }
                        // On error: do nothing extra here; viewModel.showError() will handle the temporary message
                    }
                } label: {
                    HStack {
                        Spacer()
                        Text(viewModel.isLoading ? "Submitting..." : "Submit")
                            .foregroundStyle(.white)
                            .font(.system(size: 14))
                            .fontWeight(.bold)
                        Spacer()
                    }
                    .padding(.vertical, 13)
                    .background {
                        RoundedRectangle(cornerRadius: 27.0)
                            .foregroundStyle(viewModel.isLoading ? .gray : .tastysRed)
                    }
                }
//                .disabled(palletName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
//                          reason.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
//                          viewModel.isLoading)
                .padding(.vertical, 18)
                
//                Spacer()
            }
            .padding(13)
        }
        // Optional: Full-screen loading overlay (semi-transparent)
        .overlay {
            if viewModel.isLoading {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .overlay {
                        VStack {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(1.5)
                            Text("Submitting your recommendation...")
                                .foregroundStyle(.white)
                                .font(.system(size: 18, weight: .semibold))
                                .padding(.top, 12)
                        }
                    }
            }
        }
        .onAppear{
            Haptics.prepare()
        }
        .onTapGesture {
            isTextFieldFocused = false
        }
    }
    private var dragKnob: some View {
        RoundedRectangle(cornerRadius: 11)
            .frame(width: 39, height: 5)
            .foregroundStyle(.gray.opacity(0.5))
    }
}

#Preview {
    RecommendFilterView()
        .environmentObject(HomeViewModel())
}

extension String {
    var isSingleEmoji: Bool {
        count == 1 && containsEmoji
    }

    var containsEmoji: Bool {
        unicodeScalars.first?.properties.isEmojiPresentation == true
        || unicodeScalars.first?.properties.isEmoji == true
    }
}
