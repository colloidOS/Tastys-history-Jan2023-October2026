//
//  NotificationsView.swift
//  Tastys
//
//  Created by Nnagoziem Collins Okegbe on 09/01/2026.
//

import SwiftUI

struct NotificationsView: View {

    @EnvironmentObject var viewModel: HomeViewModel

    var body: some View {
        ZStack {

            Color.white
                .ignoresSafeArea()

            if viewModel.isLoadingNotifications {

                ProgressView()

            } else if viewModel.notifications.isEmpty {

                VStack {
                    Text("No notifications yet")
                        .italic()
                        .foregroundStyle(.gray)
                }

            } else {

                ScrollView {

                    LazyVStack(spacing: 6) {

                        ForEach(Array(viewModel.notifications.enumerated()), id: \.element.id) { index, notification in

                            HStack(alignment: .center, spacing: 12) {

                                if notification.isSystemNotification {
                                    Image("logoImage")
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 50, height: 50)
                                        .clipShape(Circle())
                                } else {
                                    AsyncImage(
                                        url: URL(
                                            string: notification.actor?.avatar ?? ""
                                        )
                                    ) { image in
                                        image
                                            .resizable()
                                            .scaledToFill()
                                    } placeholder: {
                                        Image("logoImage")
                                            .resizable()
                                            .scaledToFill()
                                    }
                                    .frame(width: 50, height: 50)
                                    .clipShape(Circle())
                                }

                                VStack(
                                    alignment: .leading,
                                    spacing: 4
                                ) {
                                    if let title = notification.title {
                                        Text(title)
                                            .foregroundStyle(.black)
                                            .font(.system(size: 14, weight: .semibold))
                                    }

                                    Text(notification.message)
                                        .foregroundStyle(.black)
                                        .font(.system(size: 12, weight: .regular))
                                        .opacity(0.6)

                                    Text(notification.timeAgoText)
                                        .font(.caption)
                                        .foregroundStyle(.gray)
                                }

                                Spacer()

                                if !notification.is_read {
                                    Circle()
                                        .fill(.tastysRed)
                                        .frame(width: 8, height: 8)
                                }
                            }
                            .padding(.horizontal)

                            if index < viewModel.notifications.count - 1 {
                                Divider()
                            }
                        }
                    }
                    .padding(.top)
                }
            }
        }
        .task {
            await viewModel.getNotifications()
            await viewModel.markNotificationsAsRead()
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Notifications")
                    .font(.system(size: 17))
                    .fontWeight(.semibold)
            }
        }
    }
}

#Preview {
    NavigationStack {
        NotificationsView()
            .environmentObject(HomeViewModel())
    }
}
