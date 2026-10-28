
import Foundation

public func uploadUserImage(
    base64FileData: String,
    userId: String
) async throws -> String {
 
    let fileName = "\(userId)/\(Int(Date().timeIntervalSince1970 * 1000)).jpg"
    
    // Decode base64 string to Data
    guard let imageData = Data(base64Encoded: base64FileData) else {
        throw NSError(
            domain: "UploadError",
            code: 400,
            userInfo: [NSLocalizedDescriptionKey: "Invalid base64 data"]
        )
    }
    

    let uploadResponse = try await supabase.storage
        .from("avatar")
        .upload(
            path: fileName,
            file: imageData,
            options: FileOptions(
                contentType: "image/jpeg",
                upsert: true
            )
        )
    
    let publicURL = try supabase.storage
        .from("avatar")
        .getPublicURL(path: fileName)
    
    return publicURL.absoluteString
}
