
import Foundation

//email
       //signup
 public func signUpWithEmail(email: String, password: String) async throws -> AuthResponse {
    let response = try await supabase.auth.signUp(
        email: email.lowercased(),
        password: password
    )
    return response
}

 public func VerifySignUpEmailOTP(
    email: String, 
    code: String,
    firstName: String,
    lastName: String
) async throws -> (data: AuthResponse, error: Error?) {
  let { data, error } = try await supabase.auth.verifyOtp({
    email: email.lowercased(),
    token: code,
    type: .email
  });
  
  if error == nil, let userId = data.user?.id {
    do {
      _ = try await updateUserProfile(
        UpdateUserProfileParams(
          firstName: firstName,
          lastName: lastName
        )
      )
    } catch {
      print("⚠️ Failed to update user profile after email OTP verification: \(error)")
    }
  }
  
  return data, error
}

 public func ResendSignUpEmailOtp(email: String) async throws -> (data: AuthResponse, error: Error?) {
    let { data, error } = try await supabase.auth.resend(type: .signup, email: email.lowercased())
    return data, error
}




      //signin
public func signInWithEmail(email: String, password: String) async throws -> AuthResponse {
   let response = try await supabase.auth.signIn(
    email: email.lowercased(),
    password: password
   )
   return response
}





//phone
       //sign up
 public func signUpWithPhone(phone: String, password: String) async throws -> AuthResponse {
  let response = try await supabase.auth.signUp(
    phone: phone,
    password: password,
    channel: "sms"
  )
  return response
}

public func VerifyPhoneOTP(
    phone: String, 
    code: String,
    firstName: String,
    lastName: String
) async throws -> (data: AuthResponse, error: Error?) {
 let { data, error } = try await supabase.auth.verifyOtp({
   phone: phone,
   token: code,
   type: .sms
 });
 
 if error == nil, let userId = data.user?.id {
   do {

     _ = try await updateUserProfile(
       UpdateUserProfileParams(
         firstName: firstName,
         lastName: lastName
       )
     )
   } catch {
     print("⚠️ Failed to update user profile after phone OTP verification: \(error)")
   }
 }
 
 return data, error
}

public func ResendPhoneOtp(phone: String) async throws -> (data: AuthResponse, error: Error?) {
   let { data, error } = try await supabase.auth.resend(type: .sms, phone: phone)
   return data, error
}



     //signin
public func signInWithPhone(phone: String, password: String) async throws -> AuthResponse {
   let response = try await supabase.auth.signIn(
    phone: phone,
    password: password
   )
   return response
}

