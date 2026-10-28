//
//  MainTabView.swift
//  Tastys
//
//  Created by Nnagoziem Collins Okegbe on 12/12/2025.
//

import SwiftUI
import Combine

struct MainTabView: View {
    @State private var selectedTab: AppTab = .home
    @StateObject private var keyboard = KeyboardObserver()
    @StateObject private var viewModel = HomeViewModel()
    @StateObject private var locationManager = LocationManager()
    
    @AppStorage("userId") private var userId = ""
    
    // Navigation paths – one per tab (independent navigation)
    @State private var homePath = NavigationPath()
    @State private var searchPath = NavigationPath()      // was foodPath
    @State private var leaderboardPath = NavigationPath()
    @State private var profilePath = NavigationPath()
    
    @State private var homeRefreshID = UUID()
    @State private var searchRefreshID = UUID()
    @State private var leaderboardRefreshID = UUID()
    @State private var profileRefreshID = UUID()
    
    @State private var showTabButtons = true
    
    @EnvironmentObject var authVM: AuthViewModel
    var body: some View {
        ZStack {
            ZStack {
                NavigationStack(path: $homePath) {
                    HomeView(showTabButtons: $showTabButtons)
                        
                }
                .opacity(selectedTab == .home ? 1 : 0)
                .allowsHitTesting(selectedTab == .home)
                .zIndex(selectedTab == .home ? 1 : 0)
                .id(homeRefreshID)
                .environmentObject(viewModel)
                
                NavigationStack(path: $searchPath) {          // was foodPath
                    SearchView(showTabButtons: $showTabButtons)
                        .environmentObject(viewModel)
                }
                .opacity(selectedTab == .search ? 1 : 0)
                .allowsHitTesting(selectedTab == .search)
                .zIndex(selectedTab == .search ? 1 : 0)
                .id(searchRefreshID)
                
                NavigationStack(path: $leaderboardPath) {
                    LeaderboardView(showTabButtons: $showTabButtons)
                        .environmentObject(viewModel)
                }
                .opacity(selectedTab == .leaderboard ? 1 : 0)
                .allowsHitTesting(selectedTab == .leaderboard)
                .zIndex(selectedTab == .leaderboard ? 1 : 0)
                .id(leaderboardRefreshID)
                
                NavigationStack(path: $profilePath) {
                    ProfileView(showTabButtons: $showTabButtons)
                        
                }
                .opacity(selectedTab == .profile ? 1 : 0)
                .allowsHitTesting(selectedTab == .profile)
                .zIndex(selectedTab == .profile ? 1 : 0)
                .id(profileRefreshID)
                .environmentObject(viewModel)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .edgesIgnoringSafeArea(.bottom)
            .zIndex(keyboard.isVisible ? 2 : 0)
            .blur(radius: viewModel.showRatingBreakdown ? 5 : 0)
            .allowsHitTesting(!viewModel.showRatingBreakdown)
            // ... your PostView, PopUpView, Error views unchanged ...
            
//            if viewModel.showPostView {
//                Color.black
//                    .opacity(0.9)
//                    .blur(radius: 10)
//                    .ignoresSafeArea()
//                    .zIndex(2)
//                
//                PostView(isShowing: $viewModel.showPostView,
//                         prefillRestaurant: viewModel.prefillRestaurant,
//                         prefillDishes: viewModel.prefillDishes)
//                    .zIndex(2)
//                    .padding(.bottom, 70)
//                    .environmentObject(viewModel)
//            }
            
            if viewModel.showRatingBreakdown {
                RatingBreakdownView(isShowing: $viewModel.showRatingBreakdown, dishId: viewModel.breakdownDishId)
                    .environmentObject(viewModel)
                    .zIndex(10)
            }
            
            if let success = viewModel.successMessage {
                PopUpView(error: success)
            }
            
            ErrorWithTryAgainView(errorMessage: $viewModel.postErrorMessage, retryAction: {
                viewModel.retryPending()
            })
            
            if let error = viewModel.errorMessage {
                PopUpView(error: error)
            }
        }
        .overlay(
            VStack(spacing: 0) {
                Spacer()
                if !viewModel.showPostView {
                    CustomTabBar(
                        selectedTab: $selectedTab,
                        homePath: $homePath,
                        searchPath: $searchPath,           // was foodPath
                        leaderboardPath: $leaderboardPath,
                        profilePath: $profilePath,
                        homeRefreshID: $homeRefreshID,
                        searchRefreshID: $searchRefreshID,
                        leaderboardRefreshID: $leaderboardRefreshID,
                        profileRefreshID: $profileRefreshID
                    )
                    .zIndex(keyboard.isVisible ? 0 : 1)
                    .allowsHitTesting(!keyboard.isVisible)
                    .opacity(showTabButtons ? 1 : 0)
                    .animation(.easeInOut(duration: 0.3), value: showTabButtons)
                }
            }
            .ignoresSafeArea(.keyboard, edges: .bottom),
            alignment: .bottom
        )
        .ignoresSafeArea(edges: [.bottom])
        .environmentObject(keyboard)
        .environmentObject(viewModel)
        .environmentObject(locationManager)
        .sheet(isPresented: $viewModel.showPostView) {
            PostSheetView(
                isShowing: $viewModel.showPostView,
                prefillRestaurant: viewModel.prefillRestaurant,
                prefillDishes: viewModel.prefillDishes
            )
            .environmentObject(viewModel)
            .presentationDetents([.fraction(viewModel.showSuccessScreen ? 0.65 : 0.92)])      // ← 2/3 height as requested
            .presentationDragIndicator(.hidden)
            .presentationBackground(.white)              // clean white background
        }
        .onChange(of: viewModel.showRatingBreakdown) {
            UIApplication.shared.sendAction(
                #selector(UIResponder.resignFirstResponder),
                to: nil,
                from: nil,
                for: nil
            )
        }
        .onAppear {
            locationManager.requestAuthorization()   // <-- add
        }
    }
}

#Preview {
    NavigationStack {
        MainTabView()
    }
}


struct VisualEffectBlur: UIViewRepresentable {
    let blurStyle: UIBlurEffect.Style

    func makeUIView(context: Context) -> UIVisualEffectView {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: blurStyle))
        view.backgroundColor = UIColor.white.withAlphaComponent(0.62)
        return view
    }

    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: blurStyle)
    }
}


enum AppTab: Int, CaseIterable {
    case home, search, leaderboard, profile

    var image: String {
        switch self {
        case .home: return "homeButton"
        case .search: return "searchButton"
        case .leaderboard: return "leaderboardButton"
        case .profile: return "personList"
        }
    }
}



struct CustomTabBar: View {
    @Binding var selectedTab: AppTab
    
    // New bindings so we can reset navigation when the same tab is tapped again
    @Binding var homePath: NavigationPath
    @Binding var searchPath: NavigationPath
    @Binding var leaderboardPath: NavigationPath
    @Binding var profilePath: NavigationPath
    
    @Binding var homeRefreshID: UUID
    @Binding var searchRefreshID: UUID
    @Binding var leaderboardRefreshID: UUID
    @Binding var profileRefreshID: UUID
    
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: HomeViewModel
    @State private var progress: CGFloat = 0
    @State private var timer: Timer? = nil
    @AppStorage("avatar") private var avatar = ""
    @StateObject private var networkMonitor = NetworkMonitor.shared
    @State private var profileAvatarReloadID = UUID()
    var body: some View {
        HStack(spacing: 0) {
            // Left side
            HStack(spacing: 0) {
                Spacer()
                tabButton(.home)
                Spacer()
                tabButton(.search)
                Spacer()
            }
            
            // Center plus button (unchanged)
            Button {
                viewModel.prefillRestaurant = nil
                viewModel.prefillDishes = nil
                viewModel.showPostView.toggle()
            } label: {
                ZStack {
                    Circle()
                        .foregroundStyle(.tastysRed)
                        .frame(width: 52, height: 52)
                    
                    Circle()
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.white,
                                    Color.gradTastys.opacity(0.22)
                                ]),
                                startPoint: .center,
                                endPoint: .bottom
                            ),
                            lineWidth: 0.3
                        )
                        .frame(width: 51, height: 51)
                        .shadow(color: Color.plusShadow.opacity(0.4), radius: 24.5, x: 0, y: 9)
                    
                    Image("plus")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                }
            }
            
            // Right side
            HStack(spacing: 0) {
                Spacer()
                tabButton(.leaderboard)
                Spacer()
                tabButton(.profile)
                Spacer()
            }
        }
        .padding(.vertical, 3)
        .padding(.bottom, 4)
        .background {
            ZStack(alignment: .topLeading) {
                // Frosted glass background
//                VisualEffectBlur(blurStyle: .systemUltraThinMaterial)
//                    .opacity(0.95)
                Color.white
                    
                
                // Subtle gradient sheen
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.white.opacity(0.05),
                        Color.clear,
                        Color.white.opacity(0.03)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .opacity(0.3)
                
                // Top progress bar (if you still want it)
                Rectangle()
                    .foregroundStyle(.tastysRed)
                    .frame(height: 4)
                    .frame(width: (UIScreen.main.bounds.width) * progress, height: 4)
                    .clipped()
            }
            
//            .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 32)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.white.opacity(0.08), Color.clear]),
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        lineWidth: 0.8
                    )
//                    .padding(.bottom, 80)
            )
        }
        .shadow(color: Color.black.opacity(0.12), radius: 12, x: 0, y: 6)
        .ignoresSafeArea(.all, edges: .bottom)
        .onChange(of: viewModel.isCreating) { /* your progress timer unchanged */ }
        .onChange(of: networkMonitor.isConnected) { connected in
            guard connected else { return }
            profileAvatarReloadID = UUID()
        }
    }
    
    @ViewBuilder
    private func tabButton(_ tab: AppTab) -> some View {
        Button(action: {
            if selectedTab == tab {
                // ← THIS IS THE RELIABLE WAY
//                withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                    switch tab {
                    case .home:
                        homePath = NavigationPath()
                        homeRefreshID = UUID()
                    case .search:
                        searchPath = NavigationPath()
                        searchRefreshID = UUID()
                    case .leaderboard:
                        leaderboardPath = NavigationPath()
                        leaderboardRefreshID = UUID()
                    case .profile:
                        profilePath = NavigationPath()
                        profileRefreshID = UUID()
                    }
//                }
            } else {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                    selectedTab = tab
                }
            }
        }) {
            VStack(spacing: 6) {
                if tab == .profile {
                    ProfileTabAvatar(
                        avatarURL: avatar,
                        isSelected: selectedTab == tab
                    )
                    .id(profileAvatarReloadID)
                } else {
                    Image("\(tab.image)\(selectedTab != .search && selectedTab == tab ? "Filled" : "")")
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(selectedTab == tab ? .tastysRed : .gray.opacity(0.9))
                        .font(.system(size: 20, weight: .semibold))
                        .frame(width: 22, height: 22)
                }
            }
            .padding(.vertical, 10)
            .contentShape(Rectangle())
            .accessibilityAddTraits(selectedTab == tab ? .isSelected : [])
            .background(
                selectedTab == tab ?
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white.opacity(0.15))
                        .blur(radius: 40)
                    : nil
            )
            .padding(tab == .profile ? 8 : 12)
        }
        .buttonStyle(.plain)
        .frame(minHeight: 44)
    }
}



struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

@MainActor
final class KeyboardObserver: ObservableObject {
    @Published var isVisible: Bool = false
    @Published var height: CGFloat = 0

    private var cancellables = Set<AnyCancellable>()

    init() {
        let willShow = NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
        let willHide = NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
        let willChange = NotificationCenter.default.publisher(for: UIResponder.keyboardWillChangeFrameNotification)

        willShow
            .merge(with: willChange)
            .compactMap { $0.userInfo }
            .sink { [weak self] userInfo in
                guard let self = self else { return }
                let frame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect) ?? .zero
                let duration = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double) ?? 0.25
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    withAnimation(.easeOut(duration: duration)) {
                        self.height = frame.height
                        self.isVisible = frame.height > 0
                    }
                }
            }
            .store(in: &cancellables)

        willHide
            .compactMap { $0.userInfo }
            .sink { [weak self] userInfo in
                guard let self = self else { return }
                let duration = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double) ?? 0.25
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    withAnimation(.easeOut(duration: duration)) {
                        self.height = 0
                        self.isVisible = false
                    }
                }
            }
            .store(in: &cancellables)
    }
}
