//
//  SkeletonView.swift
//  Tastys
//
//  Created by Nnagoziem Collins Okegbe on 07/05/2026.
//

import SwiftUI

struct SkeletonView: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    SkeletonView()
}


struct DishesRowSkeletonView: View {
    var body: some View {
        HStack(spacing: 12) {
            
            // Rank
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.gray.opacity(0.15))
                .frame(width: 32, height: 32)
                .shimmering()
            
            // Dish image
            Circle()
                .fill(Color.gray.opacity(0.12))
                .frame(width: 37, height: 37)
                .shimmering()
            
            // Text section
            VStack(alignment: .leading, spacing: 5) {
                
                // Dish name
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.gray.opacity(0.15))
                    .frame(width: 111, height: 14)
                    .shimmering()
                
                // Ratings
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.gray.opacity(0.1))
                    .frame(width: 75, height: 12)
                    .shimmering()
            }
            
            Spacer()
            
            // Score badge
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.gray.opacity(0.12))
                .frame(width: 47, height: 24)
                .shimmering()
            
            // Bookmark button
            Circle()
                .fill(Color.gray.opacity(0.1))
                .frame(width: 40, height: 40)
                .shimmering()
        }
    }
}


struct RestaurantDetailSkeletonView: View {
    var body: some View {
        ZStack {
            Color.gray.opacity(0.3)
                .ignoresSafeArea()
            
            // Placeholder for top image
            GeometryReader { geometry in
                Rectangle()
                    .fill(Color.gray.opacity(0.5))
                    .frame(width: geometry.size.width, height: 400)
                    .clipped()
                    .ignoresSafeArea(edges: .top)
            }
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    Color.clear.frame(height: 148)
                    
                    // "Most popular" placeholder
                    Rectangle()
                        .fill(Color.gray.opacity(0.5))
                        .frame(width: 120, height: 20)
                        .cornerRadius(10)
                        .padding(10)
                        .background(Color.gray.opacity(0.3))
                        .cornerRadius(25)
                        .padding(.horizontal, 15)
                    
                    // Address placeholder
                    Rectangle()
                        .fill(Color.gray.opacity(0.5))
                        .frame(width: 200, height: 17)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                    
                    // Restaurant name + buttons placeholder
                    HStack {
                        Rectangle()
                            .fill(Color.gray.opacity(0.5))
                            .frame(width: 200, height: 35)
                        
                        Spacer()
                        
                        Circle()
                            .fill(Color.gray.opacity(0.5))
                            .frame(width: 40, height: 40)
                        
                        Circle()
                            .fill(Color.gray.opacity(0.5))
                            .frame(width: 40, height: 40)
                    }
                    .padding(.horizontal, 11)
                    .padding(.vertical, 5)
                    .background(Color.gray.opacity(0.3))
                    
                    ZStack {
                        Color.gray.opacity(0.3)
                            .ignoresSafeArea()
                        
                        VStack {
                            // Most highly rated dish section placeholder
                            HStack {
                                Circle()
                                    .fill(Color.gray.opacity(0.5))
                                    .frame(height: 39)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Rectangle()
                                        .fill(Color.gray.opacity(0.5))
                                        .frame(width: 150, height: 12)
                                    
                                    Rectangle()
                                        .fill(Color.gray.opacity(0.5))
                                        .frame(width: 120, height: 17)
                                }
                                
                                Spacer()
                                
                                Rectangle()
                                    .fill(Color.gray.opacity(0.5))
                                    .frame(width: 24, height: 20)
                            }
                            .padding(.horizontal, 15)
                            .padding(.vertical, 12)
                            .background(Color.gray.opacity(0.3))
                            .cornerRadius(16)
                            .padding(.horizontal, 17)
                            .padding(.vertical, 8)
                            
                            // Two cards: Restaurant Rating and Total Visits placeholders
                            HStack {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(height: 111)
                                    .cornerRadius(16)
                                
                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(height: 111)
                                    .cornerRadius(16)
                            }
                            .padding(.horizontal, 15)
                            
                            // Top Rated Dishes section
                            VStack(alignment: .leading) {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.5))
                                    .frame(width: 151, height: 16)
                                    .padding(.leading, 15)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack {
                                        ForEach(0..<6) { _ in
                                            DishCardSkeletonView()
                                        }
                                    }
                                    .padding(.leading, 14)
                                }
                            }
                            .padding(.vertical, 9)
                            
                            // Feed selector buttons placeholder
                            HStack {
                                Capsule()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: 120, height: 32)
                                
                                Capsule()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: 104, height: 32)
                            }
                            .padding(.horizontal, 15)
                            
                            // Feed posts placeholders
                            ForEach(0..<3) { _ in
                                FeedCardSkeletonView()
                                    .padding(.horizontal, 15)
                                    .padding(.vertical, 8)
                            }
                        }
                    }
                }
            }
        }
        .redacted(reason: .placeholder)
        .shimmering()  // Assuming you have this modifier
    }
}
