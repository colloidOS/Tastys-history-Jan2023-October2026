
import Foundation

public struct UpdateUserProfileParams {
    public let userId: UUID
    public var firstName: String?
    public var lastName: String?
    public var username: String?
    public var address: String?
    public var tiktok: String?
    public var instagram: String?
    public var avatar: String?
    public var bio: String?
    
    public init(
        userId: UUID,
        firstName: String? = nil,
        lastName: String? = nil,
        username: String? = nil,
        address: String? = nil,
        tiktok: String? = nil,
        instagram: String? = nil,
        avatar: String? = nil,
        bio: String? = nil
    ) {
        self.userId = userId
        self.firstName = firstName
        self.lastName = lastName
        self.username = username
        self.address = address
        self.tiktok = tiktok
        self.instagram = instagram
        self.avatar = avatar
        self.bio = bio
    }
}

public struct UserProfilee: Codable {
    public let userId: UUID
    public let username: String?
    public let email: String?
    public let phone: String?
    public let emailVerified: Bool
    public let phoneVerified: Bool
    public let firstName: String?
    public let lastName: String?
    public let address: String?
    public let location: String?
    public let tiktok: String?
    public let instagram: String?
    public let avatar: String?
    public let bio: String?
    public let createdAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case username
        case email
        case phone
        case emailVerified = "email_verified"
        case phoneVerified = "phone_verified"
        case firstName = "first_name"
        case lastName = "last_name"
        case address
        case location
        case tiktok
        case instagram
        case avatar
        case bio
        case createdAt = "created_at"
    }
}


//public func updateUserProfile(_ params: UpdateUserProfileParams) async throws -> UserProfile {
//    var functionParams: [String: Any] = [
//        "p_user_id": params.userId.uuidString
//    ]
//    
//    if let firstName = params.firstName {
//        functionParams["p_first_name"] = firstName
//    }
//    if let lastName = params.lastName {
//        functionParams["p_last_name"] = lastName
//    }
//    if let username = params.username {
//        functionParams["p_username"] = username
//    }
//    if let address = params.address {
//        functionParams["p_address"] = address
//    }
//    if let tiktok = params.tiktok {
//        functionParams["p_tiktok"] = tiktok
//    }
//    if let instagram = params.instagram {
//        functionParams["p_instagram"] = instagram
//    }
//    if let avatar = params.avatar {
//        functionParams["p_avatar"] = avatar
//    }
//    if let bio = params.bio {
//        functionParams["p_bio"] = bio
//    }
//    
//    let response: UserProfile = try await supabase.rpc(
//        "update_user_profile",
//        params: functionParams
//    ).execute().value
//    
//    return response
//}

public func updateUserProfile(
    _ params: UpdateUserProfileParams
) async throws -> UserProfilee {

    let rpcParams = UpdateUserProfileRPCParams(
        p_user_id: params.userId.uuidString,
        p_first_name: params.firstName,
        p_last_name: params.lastName,
        p_username: params.username,
        p_address: params.address,
        p_tiktok: params.tiktok,
        p_instagram: params.instagram,
        p_avatar: params.avatar,
        p_bio: params.bio
    )

    let response: UserProfilee = try await supabase
        .rpc("update_user_profile", params: rpcParams)
        .execute()
        .value

    return response
}



struct UpdateUserProfileRPCParams: Encodable {
    let p_user_id: String
    let p_first_name: String?
    let p_last_name: String?
    let p_username: String?
    let p_address: String?
    let p_tiktok: String?
    let p_instagram: String?
    let p_avatar: String?
    let p_bio: String?
}
