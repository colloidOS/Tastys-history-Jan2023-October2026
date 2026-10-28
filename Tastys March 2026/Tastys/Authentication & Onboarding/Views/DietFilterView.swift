//
//  DietFilterView.swift
//  Tastys
//
//  Created by Nnagoziem Collins Okegbe on 09/12/2025.
//

import SwiftUI

struct DietFilterView: View {
    @State private var diets = ["Halal", "Vegan", "Vegetarian", "Gluten-free", "Diary Free", "Keto", "Paleo"]
    @State private var restaurantCount = [207, 43, 109, 207, 55, 70, 30]
    @State private var selectedDiet: Int? = nil
    @AppStorage("selectedDietFilter") private var selectedDietFilter = ""
    @EnvironmentObject var authVM: AuthViewModel
    var body: some View {
        ZStack{
            Color.fakeWhite
                .ignoresSafeArea()
            
            VStack(spacing: 19){
                
                HStack{
                    
                    Spacer()
                    
                    ZStack {
                        // Outer pill
                        RoundedRectangle(cornerRadius: 29)
                            .fill(.white)
                            .frame(width: 68, height: 28)

                        // Green progress fill (flat trailing edge)
                        GeometryReader { geo in
                            Rectangle()
                                .fill(.green)
                                .frame(
                                    width: geo.size.width * (2 / 3),
                                    height: geo.size.height
                                )
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 25))

                        // Centered text
                        Text("2/3")
                            .foregroundStyle(.black)
                            .font(.system(size: 14))
                            .fontWeight(.medium)
                    }
                    .frame(width: 68, height: 28)
                }
                .padding(.horizontal, 20)
                VStack(spacing: 8) {
                    Text("Diet filter")
                        .foregroundStyle(.black)
                        .font(.system(size: 26))
                        .fontWeight(.semibold)
                    
                    Text("Can be changed later")
                        .foregroundStyle(.black)
                        .opacity(0.5)
                        .font(.system(size: 14))
                        .fontWeight(.medium)
                }
                .padding(.top)
                
                ScrollView {
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 15) {
                        ForEach(diets.indices, id: \.self) { index in
                            Button{
                                selectedDiet = index
                                selectedDietFilter = diets[index]
                            } label: {
                                VStack(spacing: 24){
                                    Image(diets[index])
//                                        .resizable()
//                                        .scaledToFit()
//                                        .frame(height: 58)
                                    
                                    Text(diets[index])
                                        .foregroundStyle(selectedDiet == index ? .white : .black)
                                        .font(.system(size: 12))
                                        .fontWeight(.medium)
                                    
                                    Text("\(restaurantCount[index])+ \nRestaurants")
                                        .foregroundStyle(selectedDiet == index ? .white.opacity(0.7) : .black)
                                        .font(.system(size: 12))
                                        .opacity(0.5)
                                        .multilineTextAlignment(.center)
                                        .lineSpacing(4)
                                }
                                .padding(.vertical, 23)
                                .padding(.top, 5)
                                .padding(.horizontal, 21)
                                .frame(height: 251)
                                .frame(maxWidth: .infinity)
                                .background{
                                    RoundedRectangle(cornerRadius: 30)
                                        .fill(selectedDiet == index ? .selectedBlack : Color.white)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 30)
                                                .stroke(selectedDiet == index ? Color.black.opacity(0.3) : Color.clear, lineWidth: 2)
                                        )
                                }
                                .padding(.vertical, 3)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal)
                }
                
                NavigationLink{
                    SetUsernameView()
                        .environmentObject(authVM)
                } label: {
                    HStack {
                        Spacer()
                        Text("Continue")
                            .foregroundStyle(.white)
                            .font(.system(size: 14))
                            .fontWeight(.bold)
                            .padding(.vertical)
                        Spacer()
                    }
                    .background{
                        RoundedRectangle(cornerRadius: 24.0)
                            .foregroundStyle(.tastysRed)
                    }
                }
                .buttonStyle(.borderless)
                .padding(.horizontal, 29)
                .padding(.bottom)
                .disabled(selectedDiet == nil)
            }
        }
        .navigationBarBackButtonHidden()
//        .toolbar {
//            ToolbarItem(placement: .topBarTrailing) {
//                ZStack {
//                    // Outer pill
//                    RoundedRectangle(cornerRadius: 25)
//                        .fill(.white)
//                        .frame(width: 70, height: 28)
//
//                    // Green progress fill (flat trailing edge)
//                    GeometryReader { geo in
//                        Rectangle()
//                            .fill(.green)
//                            .frame(
//                                width: geo.size.width * (1 / 3),
//                                height: geo.size.height
//                            )
//                    }
//                    .clipShape(RoundedRectangle(cornerRadius: 26))
//
//                    // Centered text
//                    Text("2/3")
//                        .foregroundStyle(.black)
//                        .font(.system(size: 14))
//                        .fontWeight(.medium)
//                }
//                .frame(width: 68, height: 28)
//
//            }
//        }
    }
}

#Preview {
    DietFilterView()
        .environmentObject(AuthViewModel())
}
