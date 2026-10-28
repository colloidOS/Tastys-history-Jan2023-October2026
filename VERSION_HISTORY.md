# Tastys version history

46 monthly snapshots of the Tastys iOS project, January 2023 to October 2026.

- **January 2023 to October 2026** are simulated: an earlier SwiftUI prototype of Tastys (v0.1.0 to v0.12.1) that grows month by month. Each folder has its own README.md and CHANGELOG.md.
- **December 2025 to October 2026** are based on the real project: each month contains the files that existed by then (from the `Created on` dates in the file headers and the timestamps in the Xcode project), with small UI-value differences in earlier months.
- **October 2026** is the uploaded project, byte for byte.

| Folder | Version | Changes |
|---|---|---|
| Tastys January 2023 | 0.1.0 (prototype) | Project created. Splash screen with the Tastys wordmark. |
| Tastys February 2023 | 0.1.1 (prototype) | Restaurant model and sample data. Home screen lists restaurants. |
| Tastys March 2023 | 0.1.2 (prototype) | RestaurantRowView with thumbnail, cuisine and rating. Added brand colours. |
| Tastys April 2023 | 0.2.0 (prototype) | Restaurant detail screen with a dish list. |
| Tastys May 2023 | 0.2.1 (prototype) | StarRatingView. Dishes now show an average rating and rating count. |
| Tastys June 2023 | 0.2.2 (prototype) | Theme.swift: shared colours, fonts and corner radii. |
| Tastys July 2023 | 0.3.0 (prototype) | Search screen with text filter and cuisine chips (Category Icons). |
| Tastys August 2023 | 0.3.1 (prototype) | MainTabView with Home and Search tabs. Custom tab bar icons. |
| Tastys September 2023 | 0.3.2 (prototype) | Bookmarks: FavoritesStore persisted in UserDefaults. |
| Tastys October 2023 | 0.4.0 (prototype) | Moved to Xcode 15 / iOS 17. Placeholder Profile tab. |
| Tastys November 2023 | 0.4.1 (prototype) | LocationManager. Restaurants show distance and sort by nearest. |
| Tastys December 2023 | 0.4.2 (prototype) | Unit tests for FavoritesStore and SampleData. Minor layout fixes. |
| Tastys January 2024 | 0.5.0 (prototype) | APIClient protocol with MockAPIClient, preparing for a real backend. |
| Tastys February 2024 | 0.5.1 (prototype) | HomeViewModel: loading/error states, list logic moved out of views. |
| Tastys March 2024 | 0.5.2 (prototype) | Rate a dish: Fire / Chef's Kiss / Solid / Meh reactions. |
| Tastys April 2024 | 0.6.0 (prototype) | Plates: save dishes to your plate (PlateStore, YourPlateView). |
| Tastys May 2024 | 0.6.1 (prototype) | Dietary filters on Search (Vegan, Halal, Keto, ...). |
| Tastys June 2024 | 0.6.2 (prototype) | Xcode 15.4. Leaderboard tab with top dishes and medals. |
| Tastys July 2024 | 0.7.0 (prototype) | Activity feed on Home (FeedCardView). |
| Tastys August 2024 | 0.7.1 (prototype) | Likes and comment counts on feed posts. |
| Tastys September 2024 | 0.7.2 (prototype) | CachedImage: NSCache-backed remote image loading. |
| Tastys October 2024 | 0.8.0 (prototype) | Onboarding: welcome + name entry, gated by @AppStorage. |
| Tastys November 2024 | 0.8.1 (prototype) | Food profile badges on Profile (Adventurous, Big Eater, ...). |
| Tastys December 2024 | 0.8.2 (prototype) | Force light appearance, accessibility labels, HomeViewModel tests. |
| Tastys January 2025 | 0.9.0 (prototype) | Supabase backend: SupabaseClient + SupabaseAPIClient (restaurants & dishes). |
| Tastys February 2025 | 0.9.1 (prototype) | Email sign-in with Supabase Auth (AuthService, SignInView). |
| Tastys March 2025 | 0.9.2 (prototype) | Sign-up flow. Google button placeholder. |
| Tastys April 2025 | 0.10.0 (prototype) | Profiles stored in Supabase. Edit profile screen. |
| Tastys May 2025 | 0.10.1 (prototype) | Follower / following counts on Profile. |
| Tastys June 2025 | 0.10.2 (prototype) | Leaderboard served from Supabase view `dish_leaderboard`. |
| Tastys July 2025 | 0.11.0 (prototype) | Post a rating with a photo (PhotosPicker + Storage upload). |
| Tastys August 2025 | 0.11.1 (prototype) | Map of nearby restaurants (MapKit). |
| Tastys September 2025 | 0.11.2 (prototype) | Beta waitlist screen ahead of TestFlight. |
| Tastys October 2025 | 0.12.0 (prototype) | Feed pagination and skeleton loading rows. |
| Tastys November 2025 | 0.12.1 (prototype) | Final prototype release. v2 rewrite planned for December 2025. |
| Tastys December 2025 | 1.0 (v2) | v2 rewrite begins: new Xcode project, auth & onboarding flow, Home feed, Food, Profile, Leaderboard tabs, Supabase API layer |
| Tastys January 2026 | 1.0 (v2) | AuthViewModel, Profile view models, plates (Add to Plate), Waitlist + ticket video, Sign in with Apple, Info.plist URL scheme |
| Tastys February 2026 | 1.0 (v2) | Search tab (SearchView, SearchViewModel) |
| Tastys March 2026 | 1.0 (v2) | UI polish across onboarding and profile |
| Tastys April 2026 | 1.0 (v2) | UI polish across Food and Home |
| Tastys May 2026 | 1.0 (v2) | Search result cards (Food, Foodie, Restaurant), skeleton loading, post sheet |
| Tastys June 2026 | 1.0 (v2) | Location search autocomplete (SearchCompleter), Indian category icon |
| Tastys July 2026 | 1.0 (v2) | Network reachability monitor |
| Tastys August 2026 | 1.0 (v2) | Spacing and typography polish |
| Tastys September 2026 | 1.0 (v2) | Push notifications: Firebase Messaging, AppDelegate, PushTokenManager, image cache |
| Tastys October 2026 | 1.0 (v2) | Food and restaurant image galleries. THIS IS THE ORIGINAL UPLOADED PROJECT, UNCHANGED |
