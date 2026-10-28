//
//  ProfileViewModel.swift
//  Tastys
//
//  Created by Nnagoziem Collins Okegbe on 13/04/2025.
//

import Foundation
import Supabase

struct UserProfile: Codable, Identifiable {
    var id: UUID
    var displayName: String
    var bio: String?
    var avatarURL: URL?

    enum CodingKeys: String, CodingKey {
        case id, bio
        case displayName = "display_name"
        case avatarURL = "avatar_url"
    }
}

@MainActor
final class ProfileViewModel: ObservableObject {
    @Published var profile: UserProfile?
    @Published private(set) var followers = 0
    @Published private(set) var following = 0

    func load() async {
        guard let id = try? await supabase.auth.session.user.id else { return }
        profile = try? await supabase
            .from("profiles")
            .select()
            .eq("id", value: id)
            .single()
            .execute()
            .value
        followers = (try? await supabase.from("follows").select("*", head: true, count: .exact)
            .eq("following_id", value: id).execute().count) ?? 0
        following = (try? await supabase.from("follows").select("*", head: true, count: .exact)
            .eq("follower_id", value: id).execute().count) ?? 0
    }

    func save(displayName: String, bio: String) async throws {
        guard var profile else { return }
        profile.displayName = displayName
        profile.bio = bio
        try await supabase.from("profiles").update(profile).eq("id", value: profile.id).execute()
        self.profile = profile
    }
}
