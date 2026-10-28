//
//  FollowingsView.swift
//  Tastys
//
//  Created by Nnagoziem Collins Okegbe on 15/12/2025.
//

import SwiftUI

struct FollowingsView: View {
    @ObservedObject var viewModel: ProfileViewModel
    @EnvironmentObject private var homeVM: HomeViewModel
    @Environment(\.dismiss) var dismiss
    @State private var searchText = ""
    @FocusState private var isTextFieldFocused: Bool
    var filteredFollowing: [FollowUser] {
        if searchText.isEmpty {
            return viewModel.following
        } else {
            return viewModel.following.filter {
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
                        .font(.system(size: 11))
                    
                    
                    TextField("Search following", text: $searchText)
                        .foregroundStyle(.black)
                        .font(.system(size: 14))
                        .focused($isTextFieldFocused)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 17)
                .background{
                    Color.fakeWhite
                        .clipShape(RoundedRectangle(cornerRadius: 25.0))
                }
//                .padding(.horizontal, 10)
                
                ScrollView{
                    if filteredFollowing.isEmpty {
                            VStack {
                                Spacer(minLength: 80)

                                Text(searchText.isEmpty ? "You aren't following anyone yet" : "No followings found")
                                    .foregroundStyle(.black.opacity(0.5))
                                    .font(.system(size: 16))
                                    .fontWeight(.medium)

                                Spacer()
                            }
                            .frame(maxWidth: .infinity)
                        } else {
                        ForEach(filteredFollowing) { user in
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
                                                    .frame(width: 49, height: 49)
                                                    .clipShape(Circle())
                                            } placeholder: {
                                                Color.ashTastys
                                                    .opacity(0.8)
                                                    .frame(width: 49, height: 49)
                                                    .clipShape(Circle())
                                                    .shimmering()
                                            }
                                        } else {
                                            Image(systemName: "person")
                                                .foregroundStyle(.gray)
                                                .font(.system(size: 21))
                                                .padding(8)
                                                .frame(width: 49, height: 49)
                                                .background{
                                                    Color.ashTastys
                                                    
                                                        .clipShape(Circle())
                                                }
                                            
                                            
                                        }
                                        
                                        VStack(alignment: .leading, spacing: 6){
                                            Text("@\(user.username)")
                                                .foregroundStyle(.black)
                                                .font(.system(size: 13))
                                                .fontWeight(.bold)
                                                .lineLimit(3)
                                            
                                            Text("\(user.first_name) \(user.last_name)")
                                                .foregroundStyle(.black)
                                                .opacity(0.4)
                                                .font(.system(size: 15))
                                                .fontWeight(.medium)
                                                .lineLimit(3)
                                            
                                        }
                                        
                                        Spacer()
                                        
                                        Button{
                                            Haptics.slide()
                                            print(user.user_id)
                                            Task {
                                                await viewModel.unfollowSpecific(otherUserId: user.user_id)
                                            }
                                        } label: {
                                            Text("unfollow")
                                                .foregroundStyle(.black)
                                                .font(.system(size: 15))
                                                .fontWeight(.medium)
                                                .padding(.horizontal, 22)
                                                .padding(.vertical, 8)
                                                .background{
                                                   
                                                    CustomRoundedRect()
                                                }
                                                .padding(.trailing, 5)
                                            
                                        }
                                    }
                                    .padding(.bottom, 14)
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
        .onAppear{
            Haptics.prepare()
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
//        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("\(viewModel.following.count) Following")
                    .foregroundStyle(.black)
                    .font(.system(size: 20))
                    .fontWeight(.bold)
            }
        }
        .enableSwipeBack()
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
    FollowingsView(viewModel: ProfileViewModel(userId: ""), showTabButtons: .constant(true))
}


