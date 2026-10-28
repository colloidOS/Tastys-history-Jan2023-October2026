//
//  RatingPopUpView.swift
//  Tastys
//
//  Created by Nnagoziem Collins Okegbe on 24/12/2025.
//

import SwiftUI

struct RatingPopUpView: View {
    @Binding var isShowing: Bool
    var body: some View {
        ZStack{
            VStack(spacing: 15){
                HStack{
                    Button{
                        isShowing = false
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundStyle(.black)
                            .font(.system(size: 18))
                            .fontWeight(.semibold)
                            .padding(10)
                            .background{
                                Circle()
                                    .foregroundStyle(.ashTastys)
                            }
                    }
                    
                    Spacer()
                    
                }
                
                HStack(spacing: 15){
                    Text("Pasta")
                        .foregroundStyle(.black)
                        .font(.system(size: 13))
                        .fontWeight(.medium)
                        .padding(8)
                        .padding(.horizontal, 6)
                        .background{
                            RoundedRectangle(cornerRadius: 20)
                                .foregroundStyle(.ashTastys)
                        }
                    
                    
                    Text("Pizza")
                        .foregroundStyle(.black)
                        .font(.system(size: 13))
                        .fontWeight(.medium)
                        .opacity(0.5)
                }
                
                ZStack {
                    HalfStrokedCircleView(
                        percentages: [15, 20, 45, 20],
                        colors: [.rating50, .rating70, .rating80, .rating95]
                    )
                    .frame(height: 240)
                .padding(.top)
                    
                    VStack(spacing: 10){
                        Text("95%")
                            .foregroundStyle(.black)
                            .font(.system(size: 44))
                            .fontWeight(.medium)
                        
                        Text("Tasty's score")
                            .foregroundStyle(.black)
                            .opacity(0.5)
                            .font(.system(size: 16.5))
                            .fontWeight(.medium)
                        
                    }
                }
                
                VStack {
                    Divider()
                        .padding(.bottom)
                    
                    HStack{
                      RoundedRectangle(cornerRadius: 5)
                            .foregroundStyle(.rating50)
                            .frame(width: 23, height: 23)
                        
                        Text("Meh")
                            .foregroundStyle(.black)
                            .opacity(0.5)
                            .font(.system(size: 16.5))
                            .fontWeight(.medium)
                        
                        Text("15%")
                            .foregroundStyle(.black)
                            .font(.system(size: 16.5))
                            .fontWeight(.medium)
                        
                        Spacer()
                        
                        // Stacked Images
                        ZStack(alignment: .leading) {
                            // Bottom image (third layer) - smallest and most offset
                            Image("dishImage")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 30)
                                .clipShape(Circle())
                                .overlay{
                                    Circle()
                                        .stroke(lineWidth: 1.7)
                                        .foregroundStyle(.white)
                                }
                                .offset(x: -20)
                                .zIndex(1)
                            
                            // Middle image (second layer) - medium size and offset
                            Image("dishImage")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 30)
                                .clipShape(Circle())
                                .overlay{
                                    Circle()
                                        .stroke(lineWidth: 1.7)
                                        .foregroundStyle(.white)
                                }
                                .offset(x: -13)
                                .zIndex(2)
                            
                            // Top image (first layer) - full size
                            Image("dishImage")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 30)
                                .clipShape(Circle())
                                .overlay{
                                    Circle()
                                        .stroke(lineWidth: 1.7)
                                        .foregroundStyle(.white)
                                }
                                .offset(x: -5)
                                .zIndex(3)
                            
                            Text("+39 members")
                                .font(.system(size: 7))
                                .lineLimit(2)
                                .padding(8)
                                .background {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 23)
                                            .foregroundStyle(.white)
                                            .shadow(color: .black.opacity(0.08), radius: 8.8, x: 0, y: 2)
                                        RoundedRectangle(cornerRadius: 23)
                                            .stroke(lineWidth: 1.0)
                                            .foregroundStyle(.white)
                                        
                                    }
                                }
                                .zIndex(4)
                        }
                    }
                    
                    HStack{
                      RoundedRectangle(cornerRadius: 5)
                            .foregroundStyle(.rating70)
                            .frame(width: 23, height: 23)
                        
                        Text("Solid")
                            .foregroundStyle(.black)
                            .opacity(0.5)
                            .font(.system(size: 16.5))
                            .fontWeight(.medium)
                        
                        Text("20%")
                            .foregroundStyle(.black)
                            .font(.system(size: 16.5))
                            .fontWeight(.medium)
                        
                        Spacer()
                        
                        // Stacked Images
                        ZStack(alignment: .leading) {
                            // Bottom image (third layer) - smallest and most offset
                            Image("dishImage")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 30)
                                .clipShape(Circle())
                                .overlay{
                                    Circle()
                                        .stroke(lineWidth: 1.7)
                                        .foregroundStyle(.white)
                                }
                                .offset(x: -20)
                                .zIndex(1)
                            
                            // Middle image (second layer) - medium size and offset
                            Image("dishImage")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 28)
                                .clipShape(Circle())
                                .overlay{
                                    Circle()
                                        .stroke(lineWidth: 1.7)
                                        .foregroundStyle(.white)
                                }
                                .offset(x: -13)
                                .zIndex(2)
                            
                            // Top image (first layer) - full size
                            Image("dishImage")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 30)
                                .clipShape(Circle())
                                .overlay{
                                    Circle()
                                        .stroke(lineWidth: 1.7)
                                        .foregroundStyle(.white)
                                }
                                .offset(x: -5)
                                .zIndex(3)
                            
                            Text("+39 members")
                                .font(.system(size: 9))
                                .lineLimit(1)
                                .padding(8)
                                .background {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 23)
                                            .foregroundStyle(.white)
                                            .shadow(color: .black.opacity(0.08), radius: 8.8, x: 0, y: 2)
                                        RoundedRectangle(cornerRadius: 23)
                                            .stroke(lineWidth: 1.0)
                                            .foregroundStyle(.white)
                                        
                                    }
                                }
                                .zIndex(4)
                        }
                    }
                    
                    HStack{
                      RoundedRectangle(cornerRadius: 5)
                            .foregroundStyle(.rating80)
                            .frame(width: 24, height: 23)
                        
                        Text("Slaps")
                            .foregroundStyle(.black)
                            .opacity(0.5)
                            .font(.system(size: 16.5))
                            .fontWeight(.medium)
                        
                        Text("45%")
                            .foregroundStyle(.black)
                            .font(.system(size: 16.5))
                            .fontWeight(.medium)
                        
                        Spacer()
                        
                        // Stacked Images
                        ZStack(alignment: .leading) {
                            // Bottom image (third layer) - smallest and most offset
                            Image("dishImage")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 30)
                                .clipShape(Circle())
                                .overlay{
                                    Circle()
                                        .stroke(lineWidth: 1.7)
                                        .foregroundStyle(.white)
                                }
                                .offset(x: -20)
                                .zIndex(1)
                            
                            // Middle image (second layer) - medium size and offset
                            Image("dishImage")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 30)
                                .clipShape(Circle())
                                .overlay{
                                    Circle()
                                        .stroke(lineWidth: 1.7)
                                        .foregroundStyle(.white)
                                }
                                .offset(x: -13)
                                .zIndex(2)
                            
                            // Top image (first layer) - full size
                            Image("dishImage")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 30)
                                .clipShape(Circle())
                                .overlay{
                                    Circle()
                                        .stroke(lineWidth: 1.7)
                                        .foregroundStyle(.white)
                                }
                                .offset(x: -5)
                                .zIndex(3)
                            
                            Text("+39 members")
                                .font(.system(size: 9))
                                .lineLimit(1)
                                .padding(8)
                                .background {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 23)
                                            .foregroundStyle(.white)
                                            .shadow(color: .black.opacity(0.08), radius: 8.8, x: 0, y: 2)
                                        RoundedRectangle(cornerRadius: 23)
                                            .stroke(lineWidth: 1.0)
                                            .foregroundStyle(.white)
                                        
                                    }
                                }
                                .zIndex(4)
                        }
                    }
                    
                    HStack{
                      RoundedRectangle(cornerRadius: 5)
                            .foregroundStyle(.rating95)
                            .frame(width: 23, height: 23)
                        
                        Text("Chefs kiss")
                            .foregroundStyle(.black)
                            .opacity(0.5)
                            .font(.system(size: 16.5))
                            .fontWeight(.medium)
                        
                        Text("20%")
                            .foregroundStyle(.black)
                            .font(.system(size: 16.5))
                            .fontWeight(.medium)
                        
                        Spacer()
                        
                        // Stacked Images
                        ZStack(alignment: .leading) {
                            // Bottom image (third layer) - smallest and most offset
                            Image("dishImage")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 34)
                                .clipShape(Circle())
                                .overlay{
                                    Circle()
                                        .stroke(lineWidth: 1.7)
                                        .foregroundStyle(.white)
                                }
                                .offset(x: -20)
                                .zIndex(1)
                            
                            // Middle image (second layer) - medium size and offset
                            Image("dishImage")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 30)
                                .clipShape(Circle())
                                .overlay{
                                    Circle()
                                        .stroke(lineWidth: 1.7)
                                        .foregroundStyle(.white)
                                }
                                .offset(x: -13)
                                .zIndex(2)
                            
                            // Top image (first layer) - full size
                            Image("dishImage")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 30)
                                .clipShape(Circle())
                                .overlay{
                                    Circle()
                                        .stroke(lineWidth: 1.7)
                                        .foregroundStyle(.white)
                                }
                                .offset(x: -5)
                                .zIndex(3)
                            
                            Text("+39 members")
                                .font(.system(size: 9))
                                .lineLimit(1)
                                .padding(6)
                                .background {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 24)
                                            .foregroundStyle(.white)
                                            .shadow(color: .black.opacity(0.08), radius: 8.8, x: 0, y: 2)
                                        RoundedRectangle(cornerRadius: 23)
                                            .stroke(lineWidth: 1.0)
                                            .foregroundStyle(.white)
                                        
                                    }
                                }
                                .zIndex(4)
                        }
                    }
                    
                }
                .offset(y: -60)
                
                
                
                
                
                

                
            }
            .padding(.horizontal)
        }
        .padding(.vertical)
        .background{
            RoundedRectangle(cornerRadius: 25.0)
                .foregroundStyle(.white)
        }
        .padding()
    }
}

#Preview {
    RatingPopUpView(isShowing: .constant(true))
}
