//
//  FollowersView.swift
//  Tastys
//
//  Created by Nnagoziem Collins Okegbe on 15/12/2025.
//

import SwiftUI

struct FollowersView: View {
    @ObservedObject var viewModel: ProfileViewModel
    @EnvironmentObject private var homeVM: HomeViewModel
    @Environment(\.dismiss) var dismiss
    @State private var searchText = ""
    @FocusState private var isTextFieldFocused: Bool
    var filteredFollowers: [FollowUser] {
        if searchText.isEmpty {
            return viewModel.followers
        } else {
            return viewModel.followers.filter {
                $0.username.lowercased().contains(searchText.lowercased()) ||
                "\($0.first_name) \($0.last_name)".lowercased().contains(searchText.lowercased())
            }
        }
    }
    
    @Binding var showTabButtons: Bool   // Received from MainTabView
    @State private var lastOffset: CGFloat = 0
    
    var body: some View {
        ZStack{
            Color.white
                .ignoresSafeArea()
            if let error = viewModel.errorMessage {
                PopUpView(error: error)
            }
            VStack{
                HStack{
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.black)
                        .font(.system(size: 16))
                    
                    
                    TextField("Search followers", text: $searchText)
                        .foregroundStyle(.black)
                        .font(.system(size: 14))
                        .focused($isTextFieldFocused)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 14)
                .background{
                    Color.fakeWhite
                        .clipShape(RoundedRectangle(cornerRadius: 25.0))
                }
//                .padding(.horizontal, 14)
                
                ScrollView{
                    if filteredFollowers.isEmpty {
                            VStack {
                                Spacer(minLength: 80)

                                Text(searchText.isEmpty ? "No followers yet" : "No followers found")
                                    .foregroundStyle(.black.opacity(0.5))
                                    .font(.system(size: 17))
                                    .fontWeight(.medium)

                                Spacer()
                            }
                            .frame(maxWidth: .infinity)
                        } else {
                        ForEach(filteredFollowers) { user in
                            if user.id != homeVM.currentUser?.id.uuidString {
                                NavigationLink{
                                    FriendProfileView(friendsUserId: user.id, showTabButtons: $showTabButtons)
                                        .environmentObject(homeVM)
                                } label: {
                                    HStack(spacing: 15){
                                        if let avatarUrl = user.avatar, let url = URL(string: avatarUrl) {
                                            AsyncImage(url: url) { image in
                                                image
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(height: 45)
                                                    .clipShape(Circle())
                                            } placeholder: {
                                                Color.ashTastys
                                                    .opacity(0.8)
                                                    .frame(width: 50, height: 49)
                                                    .clipShape(Circle())
                                                    .shimmering()
                                            }
                                        } else {
                                            Image(systemName: "person")
                                                .foregroundStyle(.gray)
                                                .font(.system(size: 22))
                                                .padding(10)
                                                .frame(width: 49, height: 49)
                                                .background{
                                                    Color.ashTastys
                                                    
                                                        .clipShape(Circle())
                                                }
                                            
                                        }
                                        
                                        VStack(alignment: .leading, spacing: 6){
                                            Text("@\(user.username)")
                                                .foregroundStyle(.black)
                                                .font(.system(size: 14))
                                                .fontWeight(.bold)
                                                .lineLimit(1)
                                            
                                            Text("\(user.first_name) \(user.last_name)")
                                                .foregroundStyle(.black)
                                                .opacity(0.4)
                                                .font(.system(size: 13))
                                                .fontWeight(.medium)
                                                .lineLimit(1)
                                            
                                        }
                                        
                                        Spacer()
                                        
                                        
                                        Text("follows you")
                                            .foregroundStyle(.black)
                                            .font(.system(size: 14))
                                            .fontWeight(.medium)
                                            .padding(.horizontal, 20)
                                            .padding(.vertical, 8)
                                            .background{
                                                
                                                CustomRoundedRect()
                                            }
                                            .padding(.trailing, 9)
                                        
                                        
                                    }
                                    .padding(.bottom, 12)
                                }
                            }
                        }
                    }
                    GeometryReader { geo in
                        Color.clear
                            .preference(key: ScrollOffsetPreferenceKey.self, value: geo.frame(in: .global).minY)
                    }
                    .frame(height: 0)
                }
                .refreshable {
//                    if viewModel.followers.isEmpty {
                        Task {
                            await viewModel.get_user_follow_data(p_user_id: viewModel.userId)
                        }
//                    }
                }
                .scrollDismissesKeyboard(.interactively)
            }
            .padding(.top, 10)
            .padding(.horizontal, 20)
        }
        .onPreferenceChange(ScrollOffsetPreferenceKey.self) { currentOffset in
            let directionIsUp = currentOffset > lastOffset
            if abs(currentOffset - lastOffset) > 5 {
                withAnimation(.easeInOut(duration: 0.25)) {
                    showTabButtons = directionIsUp || currentOffset >= 0  // Also show when at top
                }
            }
            lastOffset = currentOffset
        }
        .onTapGesture {
            isTextFieldFocused = false
        }
//        .navigationBarBackButtonHidden()
        .toolbar {
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
            
            
            ToolbarItem(placement: .principal) {
                Text("\(viewModel.followers.count) Followers")
                    .foregroundStyle(.black)
                    .font(.system(size: 19))
                    .fontWeight(.bold)
            }
        }
//        .enableSwipeBack()
        .onAppear {
            viewModel.errorMessage = nil
            if viewModel.followers.isEmpty {
                Task {
                    await viewModel.get_user_follow_data(p_user_id: viewModel.userId)
                }
            }
        }
    }
}

#Preview {
    FollowersView(viewModel: ProfileViewModel(userId: ""), showTabButtons: .constant(true))
}


struct CustomRoundedRect: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 22)
            .fill(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 23)
                    .stroke(Color.black.opacity(0.32), lineWidth: 0.15)
                    .offset(x: 0, y: 2)
                    .blur(radius: 2)
                    .mask(RoundedRectangle(cornerRadius: 25))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 26)
                    .stroke(Color.black.opacity(0.12), lineWidth: 0.15) // Adjust
            )
            .overlay(
                RoundedRectangle(cornerRadius: 26)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [.white, .gradTastys.opacity(0.22)]), // Assuming .gradTastys is a custom Color; replace if needed
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        lineWidth: 0.55
                    )
            )
            .shadow(color: Color.dropShadow.opacity(0.24), radius: 12, x: 0, y: 4.5)
    }
}
