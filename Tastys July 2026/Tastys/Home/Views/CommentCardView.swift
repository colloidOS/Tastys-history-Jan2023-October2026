//
//  CommentCardView.swift
//  Tastys
//
//  Created by Nnagoziem Collins Okegbe on 14/12/2025.
//

import SwiftUI

struct CommentCardView: View {
    let postId: UUID
    @EnvironmentObject var viewModel: HomeViewModel
    @State private var commentText = ""
    @State private var comments: [PostComment] = []
    @State private var isLoading = true
    @State private var localEngagement: EngagementDetails?
    @State private var expandedComments: Set<UUID> = []
    @State private var repliesDict: [UUID: [PostReply]] = [:]
    @State private var replyingTo: UUID? = nil
    @FocusState private var isTextFieldFocused: Bool
    @Binding var showTabButtons: Bool
    
    var replyingToName: String? {
        if let replyId = replyingTo,
           let comment = comments.first(where: { UUID(uuidString: $0.comment.id) == replyId }) {
            return "\(comment.user.first_name) \(comment.user.last_name)"
        }
        return nil
    }
    
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            
            if let error = viewModel.errorMessage {
                PopUpView(error: error)
            }
            VStack(spacing: 0) {
                RoundedRectangle(cornerRadius: 25)
                    .foregroundStyle(.black)
                    .opacity(0.4)
                    .frame(width: 65, height: 4)
                    .padding(.vertical, 15)
                    .opacity(0)
                
                if isLoading && comments.isEmpty {
                    ScrollView {
                        ForEach(0..<5) { _ in
                            ShimmerView()
                                .frame(height: 80)
                                .clipShape(RoundedRectangle(cornerRadius: 15))
                                .padding(.horizontal, 15)
                                .padding(.bottom, 7)
                        }
                    }
                } else {
                    ScrollView {
                        ForEach(comments) { comment in
                            let commentId = UUID(uuidString: comment.comment.id) ?? UUID()
                            
                            HStack(alignment: .top) {
                                // Avatar
                                if comment.user.id != viewModel.currentUser?.id.uuidString {
                                    NavigationLink{
                                        FriendProfileView(friendsUserId: comment.user.id, showTabButtons: $showTabButtons)
                                            .environmentObject(viewModel)
                                    } label: {
                                        if let avatar = comment.user.avatar,
                                           let url = URL(string: avatar) {
                                            AsyncImage(url: url) { image in
                                                image.resizable()
                                                    .scaledToFill()
                                                    .frame(width: 35, height: 35)
                                                    .clipShape(Circle())
                                            } placeholder: {
                                                ShimmerAvatar()
                                                    .foregroundStyle(.gray)
                                                    .frame(width: 35, height: 35)
                                            }
                                        } else {
                                            ShimmerAvatar()
                                                .foregroundStyle(.gray)
                                                .frame(width: 35, height: 35)
                                        }
                                    }
                                } else {
                                    if let avatar = comment.user.avatar,
                                       let url = URL(string: avatar) {
                                        AsyncImage(url: url) { image in
                                            image.resizable()
                                                .scaledToFill()
                                                .frame(width: 35, height: 35)
                                                .clipShape(Circle())
                                        } placeholder: {
                                            ShimmerAvatar()
                                                .foregroundStyle(.gray)
                                                .frame(width: 35, height: 35)
                                        }
                                    } else {
                                        ShimmerAvatar()
                                            .foregroundStyle(.gray)
                                            .frame(width: 35, height: 35)
                                    }
                                }
                                
                                VStack(alignment: .leading, spacing: 6) {
                                    HStack {
                                        if comment.user.id != viewModel.currentUser?.id.uuidString {
                                            NavigationLink{
                                                FriendProfileView(friendsUserId: comment.user.id, showTabButtons: $showTabButtons)
                                                    .environmentObject(viewModel)
                                            } label: {
                                                Text("\(comment.user.first_name) \(comment.user.last_name)")
                                                    .foregroundStyle(.black)
                                                    .font(.system(size: 16, weight: .medium))
                                            }
                                        } else {
                                            Text("\(comment.user.first_name) \(comment.user.last_name)")
                                                .foregroundStyle(.black)
                                                .font(.system(size: 16, weight: .medium))
                                        }
//                                        Circle()
//                                            .frame(width: 5, height: 5)
//
//                                        Text(timeAgo(isoString: comment.comment.created_at))
//                                            .foregroundStyle(.black)
//                                            .font(.system(size: 13, weight: .medium))
//                                            .opacity(0.5)
                                    }
                                    
                                    Text(comment.comment.content)
                                        .foregroundStyle(.black)
                                        .font(.system(size: 15, weight: .medium))
                                        .opacity(0.7)
                                        .lineSpacing(5)
                                    
                                    HStack(spacing: 6) {
                                        Button {
                                            Haptics.slide()
                                            Task {
                                                await toggleLike(commentId: comment.comment.id)
                                            }
                                        } label: {
                                            Image(systemName:
                                                comment.likes.user_has_liked
                                                ? "heart.fill"
                                                : "heart"
                                            )
                                            .foregroundStyle(comment.likes.user_has_liked ? .tastysRed : .black)
                                            .font(.system(size: 14))
                                        }
                                        .buttonStyle(.plain)
                                        
                                        Text("\(comment.likes.count) Likes")
                                            .foregroundStyle(.black)
                                            .font(.system(size: 12, weight: .bold))
                                        
//                                        Spacer()
                                        Circle()
                                            .foregroundStyle(.black)
                                            .opacity(0.7)
                                            .frame(width: 9, height: 5)
                                        
                                        Text("Reply")
                                            .foregroundStyle(.black)
                                            .font(.system(size: 12, weight: .bold))
                                            .onTapGesture {
                                                replyingTo = commentId
                                                isTextFieldFocused = true
                                            }
                                    }
                                }
                                
                                Spacer()
                            }
                            .padding(.horizontal, 15)
                            .padding(.bottom, 7)
                            
                            // Replies display
                            let currentReplies = expandedComments.contains(commentId) ? (repliesDict[commentId] ?? []) : (comment.replies ?? [])
                            
                            ForEach(currentReplies) { reply in
                                HStack(alignment: .top) {
                                    Spacer().frame(width: 46)
                                    
                                    if reply.user.id != viewModel.currentUser?.id.uuidString {
                                        NavigationLink{
                                            FriendProfileView(friendsUserId: reply.user.id, showTabButtons: $showTabButtons)
                                                .environmentObject(viewModel)
                                        } label: {
                                            if let avatar = reply.user.avatar, let url = URL(string: avatar) {
                                                AsyncImage(url: url) { image in
                                                    image
                                                        .resizable()
                                                        .scaledToFill()
                                                        .frame(width: 28, height: 30)
                                                        .clipShape(Circle())
                                                } placeholder: {
                                                    ShimmerAvatar()
                                                        .frame(width: 30, height: 30)
                                                }
                                            } else {
                                                ShimmerAvatar()
                                                    .frame(width: 30, height: 30)
                                            }
                                        }
                                    } else {
                                        if let avatar = reply.user.avatar, let url = URL(string: avatar) {
                                            AsyncImage(url: url) { image in
                                                image
                                                    .resizable()
                                                    .scaledToFill()
                                                    .frame(width: 30, height: 30)
                                                    .clipShape(Circle())
                                            } placeholder: {
                                                ShimmerAvatar()
                                                    .frame(width: 30, height: 30)
                                            }
                                        } else {
                                            ShimmerAvatar()
                                                .frame(width: 30, height: 30)
                                        }
                                    }
                                            
                                            
                                    VStack(alignment: .leading, spacing: 4) {
                                        HStack {
                                            if reply.user.id != viewModel.currentUser?.id.uuidString {
                                                NavigationLink{
                                                    FriendProfileView(friendsUserId: reply.user.id, showTabButtons: $showTabButtons)
                                                        .environmentObject(viewModel)
                                                } label: {
                                                    Text("\(reply.user.first_name) \(reply.user.last_name)")
                                                        .foregroundStyle(.black)
                                                        .font(.system(size: 14, weight: .medium))
                                                }
                                            } else {
                                                Text("\(reply.user.first_name) \(reply.user.last_name)")
                                                    .foregroundStyle(.black)
                                                    .font(.system(size: 15, weight: .medium))
                                            }
                                            // Optional time ago
                                            Text(timeAgo(isoString: reply.reply.created_at))
                                                .foregroundStyle(.black)
                                                .font(.system(size: 13, weight: .medium))
                                                .opacity(0.5)
                                        }
                                        
                                        Text(reply.reply.content)
                                            .foregroundStyle(.black)
                                            .font(.system(size: 13, weight: .medium))
                                            .opacity(0.7)
                                            .lineSpacing(5)
                                    }
                                    
                                    Spacer()
                                }
                                .padding(.horizontal, 15)
                                .padding(.bottom, 5)
                            }
                            
                            // View/Hide replies button
                            if comment.replies != nil || !currentReplies.isEmpty {
                                Button {
                                    Haptics.slide()
                                    if expandedComments.contains(commentId) {
                                        expandedComments.remove(commentId)
                                    } else {
                                        expandedComments.insert(commentId)
                                        if repliesDict[commentId] != nil {
                                            Task {
                                                let fullReplies = await viewModel.getCommentReplies(commentId: commentId)
                                                repliesDict[commentId] = fullReplies ?? []
                                            }
                                        }
                                    }
                                } label: {
                                    Text(expandedComments.contains(commentId) ? "fold replies" : "see more replies")
                                        .foregroundStyle(.black)
                                        .opacity(0.6)
                                        .font(.system(size: 12, weight: .bold))
                                }
                                .buttonStyle(.plain)
                                .padding(.leading, 85)
                                .padding(.bottom, 7)
                            }
                        }
                    }
                    .padding(.top, 9)
                    .scrollDismissesKeyboard(.interactively)
                    .simultaneousGesture(
                        DragGesture().onChanged { _ in }
                    )
                }
                
                Divider()
                
                VStack(spacing: 0) {
//                    if let name = replyingToName {
//                        HStack {
//                            Text("Replying to \(name)")
//                                .foregroundStyle(.gray)
//                                .font(.system(size: 14, weight: .medium))
//                                .overlay(alignment: .topTrailing) {
//                                    Button {
//                                        replyingTo = nil
//                                        isTextFieldFocused = false
//                                    } label: {
//                                      Image(systemName: "xmark")
//                                            .foregroundStyle(.black)
//                                            .font(.system(size: 14, weight: .medium))
//                                    }
//                                }
//                            
//                            Spacer()
//                            
//                            
//                            
//                        }
//                        .padding(.horizontal, 15)
//                        .padding(.bottom, 10)
//                    }
                    
                    HStack {
                        AsyncImage(url: URL(string: viewModel.currentUser?.avatar ?? "")) { image in
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(height: 35)
                                .clipShape(Circle())
                        } placeholder: {
                            ShimmerAvatar()
                        }
                        .frame(height: 37)
                        .clipShape(Circle())
                        
                        
                        if let name = replyingToName {
                            TextField("Replying to \(name)", text: $commentText)
                                .foregroundStyle(.black)
                                .font(.system(size: 14))
                                .fontWeight(.medium)
                                .focused($isTextFieldFocused)
                                .onChange(of: isTextFieldFocused) { oldValue, newValue in
                                    if !isTextFieldFocused && commentText.isEmpty && replyingTo != nil{
                                        replyingTo = nil
                                        isTextFieldFocused = false
                                    }
                                }
                        } else {
                            TextField("Type a comment", text: $commentText)
                                .foregroundStyle(.black)
                                .font(.system(size: 14))
                                .fontWeight(.medium)
                        }
                        
//                        TextField("\(replyingTo == nil ? "Type a comment" : "Replying to \(replyingToName ?? "")")", text: $commentText)
//                            .foregroundStyle(.black)
//                            .font(.system(size: 14))
//                            .fontWeight(.medium)
//                            .focused($isTextFieldFocused)
                        
                        Spacer()
                        if !commentText.isEmpty {
                            Button {
                                Haptics.slide()
                                sendComment()
                                isTextFieldFocused = false
                            } label:{
                                Text("send")
                                    .foregroundStyle(.tastysRed)
                                    .font(.system(size: 14))
                                    
                            }
                        }
                    }
                    .padding(.horizontal, 15)
                    .padding(.vertical, 10)
                    .background {
                        Color.ashTastys
                            .clipShape(RoundedRectangle(cornerRadius: 23))
                    }
                    .padding(15)
                }
                
            }
        }
        .onAppear {
            Haptics.prepare()
            Task {
                await loadComments()
            }
        }
        .preferredColorScheme(.light)
    }
    
    private func loadComments() async {
        isLoading = true
        comments = await viewModel.getPostComments(postId: postId) ?? []
        for comment in comments {
            if let reps = comment.replies, !reps.isEmpty {
                if let cid = UUID(uuidString: comment.comment.id) {
                    repliesDict[cid] = reps
                }
            }
        }
        isLoading = false
    }
    
    private func sendComment() {
        let content = commentText
        commentText = ""
        print("trying to send")
        if let replyToId = replyingTo {
            // Optimistic reply
            print("trying to reply")
            let formatter = ISO8601DateFormatter()
            let now = formatter.string(from: Date())
            let tempReply = PostReply(
                reply: CommentDTO(
                    id: UUID().uuidString,
                    content: content,
                    created_at: now,
                    updated_at: now
                ),
                user: UserDTO(
                    id: viewModel.currentUser!.id.uuidString,
                    username: viewModel.currentUser!.username ?? "",
                    first_name: viewModel.currentUser!.firstName ?? "",
                    last_name: viewModel.currentUser!.lastName ?? "",
                    avatar: viewModel.currentUser!.avatar
                )
            )
            
            // Append since order 'oldest'
            repliesDict[replyToId, default: []].append(tempReply)
            
            // Expand if not already
            expandedComments.insert(replyToId)
            
            // localEngagement?.commentsCount += 1 // If replies count towards comments, adjust accordingly
            
            Task {
                if let _ = await viewModel.addCommentReply(commentId: replyToId, content: content) {
                    // Success
                    print("successful!")
                } else {
                    // Revert
                    if let index = repliesDict[replyToId]?.firstIndex(where: { $0.reply.id == tempReply.reply.id }) {
                        repliesDict[replyToId]?.remove(at: index)
                    }
                    print("failed to reply")
                    // localEngagement?.commentsCount -= 1
                }
            }
            
            replyingTo = nil
        } else {
            // Original comment logic
            print("trying to comment")
            let formatter = ISO8601DateFormatter()
            let now = formatter.string(from: Date())
            let tempComment = PostComment(
                comment: CommentDTO(
                    id: UUID().uuidString,
                    content: content,
                    created_at: now,
                    updated_at: now
                ),
                user: UserDTO(
                    id: viewModel.currentUser!.id.uuidString,
                    username: viewModel.currentUser!.username ?? "",
                    first_name: viewModel.currentUser!.firstName ?? "",
                    last_name: viewModel.currentUser!.lastName ?? "",
                    avatar: viewModel.currentUser!.avatar
                ),
                likes: LikesDTO(count: 0, user_has_liked: false),
                replies: nil
            )
            comments.insert(tempComment, at: 0)
            localEngagement?.commentsCount += 1
            
            Task {
                if let realComment = await viewModel.addComment(to: postId, content: content) {
                    
                    // 🔥 Replace temp with real
                    if let index = comments.firstIndex(where: { $0.comment.id == tempComment.comment.id }) {
                        await loadComments()
                    }

                } else {
                    // revert
                    if let index = comments.firstIndex(where: { $0.comment.id == tempComment.comment.id }) {
                        comments.remove(at: index)
                        localEngagement?.commentsCount -= 1
                    }
                }
                // Ensure we always exit reply mode after any send
                replyingTo = nil
            }
        }
    }
    
    private func toggleLike(commentId: String) async {
        guard let index = comments.firstIndex(where: { $0.comment.id == commentId }) else { return }
        
        // Save previous state
        let previousCount = comments[index].likes.count
        let previousLiked = comments[index].likes.user_has_liked
        
        // Optimistic update
        comments[index].likes.user_has_liked.toggle()
        comments[index].likes.count += comments[index].likes.user_has_liked ? 1 : -1
        
        // Call backend
        let result = await viewModel.toggleCommentLike(
            commentId: UUID(uuidString: commentId) ?? UUID()
        )
        
        if result == nil {
            // Revert on failure
            comments[index].likes.user_has_liked = previousLiked
            comments[index].likes.count = previousCount
        }
    }
    
    private func timeAgo(isoString: String) -> String {
        let formatter = ISO8601DateFormatter()
        guard let date = formatter.date(from: isoString) else {
            return ""
        }
        
        let relative = RelativeDateTimeFormatter()
        relative.unitsStyle = .short
        return relative.localizedString(for: date, relativeTo: Date())
    }
}

struct ShimmerView: View {
    var body: some View {
        VStack {
            Color.gray.opacity(0.3)
                .frame(height: 78)
                .shimmering()
        }
    }
}

extension View {
    func shimmering() -> some View {
        self.modifier(ShimmerModifier())
    }
}

struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .overlay(
                LinearGradient(gradient: Gradient(colors: [.clear, .white.opacity(0.2), .clear]), startPoint: .leading, endPoint: .trailing)
                    .offset(x: phase * 200 - 100)
                    .opacity(0.8)
            )
            .onAppear {
                withAnimation(Animation.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    phase = 1
                }
            }
    }
}

//#Preview {
//    CommentCardView()
//}
