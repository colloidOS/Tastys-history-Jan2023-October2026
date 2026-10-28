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

    func load() async {
        guard let id = try? await supabase.auth.session.user.id else { return }
        profile = try? await supabase
            .from("profiles")
            .select()
            .eq("id", value: id)
            .single()
            .execute()
            .value
    }

    func save(displayName: String, bio: String) async throws {
        guard var profile else { return }
        profile.displayName = displayName
        profile.bio = bio
        try await supabase.from("profiles").update(profile).eq("id", value: profile.id).execute()
        self.profile = profile
    }
}
