//
//  EditProfileView.swift
//  Tastys
//
//  Created by Nnagoziem Collins Okegbe on 17/12/2025.
//

import SwiftUI
import Storage

struct EditProfileView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var vm: ProfileViewModel
    @State private var text = ""
    @State private var showImageOptions = false
    @State private var showPicker = false
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @State private var selectedUIImage: UIImage? = nil
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var username = ""
    @State private var location = ""
    @State private var bio = ""
    @State private var instagram = ""
    @State private var tikTok = ""
    @State private var isChecking = false
    @State private var isAvailable: Bool? = nil
    @State private var isUploadingAvatar = false
    @State private var foodProfile = ""
    @State private var showFoodProfileSheet = false
    
    @FocusState private var focusedField: FocusedField?
    var foodProfiles = ["Picky", "Veggies", "Adventorous", "Spicy", "Big Eater", "Light Eater"]
    
    enum FocusedField: Hashable {
        case firstName
        case lastName
        case username
        case location
        case bio
        case instagram
        case tikTok
    }
    
    var body: some View {
        ZStack{
            Color.white
                .ignoresSafeArea()
            
            if let err = vm.errorMessage {
                VStack {
                    Text(err)
                        .foregroundStyle(.black)
                        .font(.system(size: 13))
                        .fontWeight(.semibold)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 25)
                        .background(RoundedRectangle(cornerRadius: 30).fill(Color.white))
                        .shadow(color: .black.opacity(0.12), radius: 28, x: 0, y: 10.95)
                        .transition(.move(edge: .top).combined(with: .opacity))
                    Spacer()
                }
                .zIndex(1)
            }
            
            VStack(spacing: 25){
                Button{
                    Haptics.slide()
                    showImageOptions.toggle()
                } label: {
                    ZStack{
                        Circle()
                            .foregroundStyle(.rectTastys)
                            .frame(height: 109)
                            .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
                        Circle()
                            .stroke(lineWidth: 3)
                            .foregroundStyle(.white)
                            .frame(height: 109)
                        
                        if let selectedUIImage = selectedUIImage {
                            Image(uiImage: selectedUIImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 110, height: 109)
                                .clipShape(Circle())
                        } else {
                            Image("plateUsername")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 38.47, height: 38.47)
                        }
                    }
                    .overlay(alignment: .bottomTrailing) {
                        ZStack{
                            Circle()
                                .foregroundStyle(.white)
                                .frame(height: 36.5)
                                .overlay(
                                    Circle()
                                        .stroke(Color.black.opacity(0.2), lineWidth: 1.5)
                                        .blur(radius: 2)
                                        .offset(x: 0, y: 1)
                                )
                                .clipShape(Circle())
                            
                            Image(systemName: "plus")
                                .foregroundStyle(.tastysRed)
                                .font(.system(size: 18))
                                .bold()
                            
                        }
                    }
                }
                .buttonStyle(.plain)
                
                VStack(spacing: 5){
                    
                    HStack(spacing: 14){
                        Text("First name")
                            .foregroundStyle(.black)
                            .opacity(0.4)
                            .font(.system(size: 14))
                            .fontWeight(.medium)
                        
                        Spacer()
                        
                        TextField("", text: $firstName)
                            .foregroundStyle(.black)
                            .font(.system(size: 15))
                            .fontWeight(.medium)
                            .multilineTextAlignment(.trailing)
                            .frame(maxWidth: 140)
//                            .fixedSize()
//                            .frame(maxWidth: UIScreen.main.bounds.width / 3)
                            .focused($focusedField, equals: .firstName)
                        
                        Image("pencilIcon")
                        
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 14)
                    .background{
                        RoundedRectangle(cornerRadius: 15)
                            .foregroundStyle(.ashTastys)
                    }
                    .frame(width: UIScreen.main.bounds.width - 20)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        focusedField = .firstName
                    }
                    
                    HStack(spacing: 14){
                        Text("Last name")
                            .foregroundStyle(.black)
                            .opacity(0.4)
                            .font(.system(size: 14))
                            .fontWeight(.medium)
                        
                        Spacer()
                        
                        TextField("", text: $lastName)
                            .foregroundStyle(.black)
                            .font(.system(size: 15))
                            .fontWeight(.medium)
                            .multilineTextAlignment(.trailing)
                            .frame(maxWidth: 140)
//                            .fixedSize()
//                            .frame(maxWidth: UIScreen.main.bounds.width / 3)
                            .focused($focusedField, equals: .lastName)
                        
                        Image("pencilIcon")
                        
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 14)
                    .background{
                        RoundedRectangle(cornerRadius: 15)
                            .foregroundStyle(.ashTastys)
                    }
                    .frame(width: UIScreen.main.bounds.width - 20)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        focusedField = .lastName
                    }
                    
                    HStack(spacing: 14){
                        Text("username")
                            .foregroundStyle(.black)
                            .opacity(0.4)
                            .font(.system(size: 14))
                            .fontWeight(.medium)
                        
                        Spacer()
                        
                        HStack(spacing: 2) {
                            Text("@")
                                .foregroundStyle(.black)
                                .font(.system(size: 15))
                                .fontWeight(.medium)
                            TextField("", text: $username)
                                .foregroundStyle(.black)
                                .font(.system(size: 11))
                                .fontWeight(.medium)
                                .multilineTextAlignment(.trailing)
                                .frame(maxWidth: 140)
                                .fixedSize()
//                                .frame(maxWidth: UIScreen.main.bounds.width / 3)
                                .focused($focusedField, equals: .username)
                                .onChange(of: username) { old, newValue in
                                    isChecking = false
                                    isAvailable = nil
                                    
                                    if username.isEmpty {
                                        isAvailable = false
                                    } else {
                                        if newValue == vm.profile?.username {
                                            isAvailable = nil
                                            return
                                        } else {
                                            Task {
                                                try? await Task.sleep(nanoseconds: 500_000_000)
                                                if newValue == username {
                                                    checkUsername(newValue)
                                                }
                                            }
                                        }
                                    }
                                }
                        }
                        
                        if isChecking {
                            ProgressView()
//                                .scaleEffect(1.1)
                                .padding(.horizontal, 8)
                        }
                        else if isAvailable == true {
                            ZStack {
                                Circle().foregroundStyle(.greenTastys)
                                Image(systemName: "checkmark")
                                    .foregroundStyle(.white)
                                    .fontWeight(.semibold)
                            }
                            .frame(height: 24)
                            .padding(.horizontal, 8)
                        }
                        else if isAvailable == false {
                            ZStack {
                                Circle().foregroundStyle(.tastysRed)
                                Image(systemName: "xmark")
                                    .foregroundStyle(.white)
                                    .fontWeight(.semibold)
                            }
                            .frame(height: 24)
                            .padding(.horizontal, 8)
                        }
                        
                        Image("pencilIcon")
                        
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 14)
                    .background{
                        RoundedRectangle(cornerRadius: 15)
                            .foregroundStyle(.ashTastys)
                    }
                    .frame(width: UIScreen.main.bounds.width - 20)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        focusedField = .username
                    }
                    
//                    HStack(spacing: 14){
//                        Text("location")
//                            .foregroundStyle(.black)
//                            .opacity(0.4)
//                            .font(.system(size: 14))
//                            .fontWeight(.medium)
//
//                        Spacer()
//
//                        TextField("", text: $location)
//                            .foregroundStyle(.black)
//                            .font(.system(size: 15))
//                            .fontWeight(.medium)
//                            .fixedSize()
//                            .focused($focusedField, equals: .location)
//
//                        Image("pencilIcon")
//
//                    }
//                    .padding(.horizontal, 14)
//                    .padding(.vertical, 14)
//                    .background{
//                        RoundedRectangle(cornerRadius: 16)
//                            .foregroundStyle(.ashTastys)
//                    }
//                    .contentShape(Rectangle())
//                    .onTapGesture {
//                        focusedField = .location
//                    }
                    
                    
                    HStack(spacing: 16){
                        Text("Food Profile")
                            .foregroundStyle(.black)
                            .opacity(0.4)
                            .font(.system(size: 12))
                            .fontWeight(.medium)
                        
                        Spacer()
                        if foodProfile == "\"\"" {
                            Text("Picky")
                                .foregroundStyle(.black)
                                .font(.system(size: 15))
                                .fontWeight(.medium)
                                .fixedSize()
                        } else {
                            Text(foodProfile)
                                .foregroundStyle(.black)
                                .font(.system(size: 14))
                                .fontWeight(.medium)
                        }
                        
//                        Text(foodProfile)
//                            .foregroundStyle(.black)
//                            .font(.system(size: 16))
//                            .fontWeight(.medium)
//                            .fixedSize()
                        
                        Image("pencilIcon")
                        
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 14)
                    .background{
                        RoundedRectangle(cornerRadius: 15)
                            .foregroundStyle(.ashTastys)
                    }
                    .frame(width: UIScreen.main.bounds.width - 20)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        showFoodProfileSheet = true
                    }
                    
                    
                    
                    
                    
                    HStack(spacing: 14){
                        Text("Bio")
                            .foregroundStyle(.black)
                            .opacity(0.4)
                            .font(.system(size: 14))
                            .fontWeight(.medium)
                        
                        Spacer()
                        
                        TextField("", text: $bio)
                            .foregroundStyle(.black)
                            .font(.system(size: 15))
                            .fontWeight(.medium)
                            .multilineTextAlignment(.trailing)
                            .frame(maxWidth: 140)
//                            .fixedSize()
//                            .frame(maxWidth: UIScreen.main.bounds.width / 2.5)
                            .focused($focusedField, equals: .bio)
                        
                        Image("pencilIcon")
                        
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 14)
                    .background{
                        RoundedRectangle(cornerRadius: 11)
                            .foregroundStyle(.ashTastys)
                    }
                    .frame(width: UIScreen.main.bounds.width - 20)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        focusedField = .bio
                    }
                    
                    HStack(spacing: 14){
                        Text("Instagram")
                            .foregroundStyle(.black)
                            .opacity(0.4)
                            .font(.system(size: 14))
                            .fontWeight(.medium)
                        
                        Spacer()
                        
                        HStack(spacing: 2) {
                            Text("@")
                                .foregroundStyle(.black)
                                .font(.system(size: 15))
                                .fontWeight(.medium)
                            TextField("", text: $instagram)
                                .foregroundStyle(.black)
                                .font(.system(size: 15))
                                .fontWeight(.medium)
                                .multilineTextAlignment(.trailing)
                                .frame(maxWidth: 140)
                                .fixedSize()
//                                .frame(maxWidth: UIScreen.main.bounds.width / 3)
                                .focused($focusedField, equals: .instagram)
                        }
                        
                        Image("pencilIcon")
                        
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 14)
                    .background{
                        RoundedRectangle(cornerRadius: 15)
                            .foregroundStyle(.ashTastys)
                    }
                    .frame(width: UIScreen.main.bounds.width - 20)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        focusedField = .instagram
                    }
                    
                    HStack(spacing: 14){
                        Text("TikTok")
                            .foregroundStyle(.black)
                            .opacity(0.4)
                            .font(.system(size: 14))
                            .fontWeight(.medium)
                        
                        Spacer()
                        
                        HStack(spacing: 2) {
                            Text("@")
                                .foregroundStyle(.black)
                                .font(.system(size: 15))
                                .fontWeight(.medium)
                            
                            TextField("", text: $tikTok)
                                .foregroundStyle(.black)
                                .font(.system(size: 15))
                                .fontWeight(.medium)
                                .multilineTextAlignment(.trailing)
                                .frame(maxWidth: 140)
                                .fixedSize()
//                                .frame(maxWidth: UIScreen.main.bounds.width / 3)
                                .focused($focusedField, equals: .tikTok)
                        }
                        
                        Image("pencilIcon")
                        
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 14)
                    .background{
                        RoundedRectangle(cornerRadius: 15)
                            .foregroundStyle(.ashTastys)
                    }
                    .frame(width: UIScreen.main.bounds.width - 20)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        focusedField = .tikTok
                    }
                    
                    
                }
                
                Spacer()
                
                Button {
                    Haptics.slide()
                    Task {
                        var avatarURL: String? = vm.profile?.avatar
                        if let img = selectedUIImage {
                            if let data = img.jpegData(compressionQuality: 0.5) {
//                                let path = "avatar/\(vm.userId).jpg"
                                let path = "\(vm.userId)/\(Int(Date().timeIntervalSince1970 * 1000)).jpg"
                                do {
                                    isUploadingAvatar = true
                                    _ = try await supabase.storage.from("avatar").upload(path, data: data, options: FileOptions(upsert: true))
                                    let publicURL = try supabase.storage.from("avatar").getPublicURL(path: path)
                                    avatarURL = publicURL.absoluteString
                                    isUploadingAvatar = false
                                } catch {
                                    isUploadingAvatar = false
                                    print("Error uploading avatar: \(error)")
                                    vm.showError("Failed to upload avatar")
                                    return
                                }
                            }
                        }
                        
                        let newUsername = username
                        let usernameChanged = newUsername != (vm.profile?.username ?? "")
                        
                        if usernameChanged {
                            let available = await vm.isUsernameAvailable(newUsername)
                            if !available {
                                return
                            }
                            let updated = await vm.updateUsername(newUsername)
                            if updated {
                                if var p = vm.profile {
                                    p.username = newUsername
                                    vm.profile = p
                                }
                            } else {
                                return
                            }
                        }
                        
                        if firstName.isEmpty {
                            vm.showError("Add your first name")
                            return
                        } else if lastName.isEmpty{
                            vm.showError("Add your last name")
                            return
                        }
                        
                        await vm.updateOtherFields(firstName: firstName, lastName: lastName, bio: bio, location: location, instagram: instagram, tiktok: tikTok, avatar: avatarURL, foodProfile: foodProfile)
                        
                        dismiss()
                    }
                } label: {
                    HStack {
                        Spacer()
                        Text("Save changes")
                            .foregroundStyle(.white)
                            .font(.system(size: 16))
                            .fontWeight(.bold)
                            .padding(.vertical)
                        Spacer()
                        
                    }
                    .background{
                        RoundedRectangle(cornerRadius: 25.0)
                            .foregroundStyle(.tastysRed)
                    }
//                        .padding()
                    
                }
                .padding(.horizontal, 40)
                .padding(.top)
                .padding(.bottom, 70)
                .disabled(isAvailable == false || vm.isUpdateLoading || isUploadingAvatar)
                
            }
            .padding(.horizontal, 20)
            
            if vm.isUpdateLoading  || isUploadingAvatar {
                Color.ashTastys
                    .opacity(0.6)
                    .ignoresSafeArea()
                
                ProgressView("updating...")
            }
            
        }
        .onAppear{
            Haptics.prepare()
        }
//        .enableSwipeBack()
//        .navigationBarBackButtonHidden()
        .toolbar {
//            ToolbarItem(placement: .navigationBarLeading) {
//                Button{
//                    dismiss()
//                } label: {
//                    Image("backButtonIcon")
//                        .renderingMode(.template)
//                        .foregroundStyle(.black)
//                        .padding()
//                        .clipShape(Circle())
//                    .foregroundStyle(.white)
//                }
//            }
            
            
            ToolbarItem(placement: .principal) {
                Text("Edit profile")
                    .foregroundStyle(.black)
                    .font(.system(size: 20))
                    .fontWeight(.bold)
            }
        }
        
        .confirmationDialog("Select Image", isPresented: $showImageOptions) {
            Button("Take a picture") {
                sourceType = .camera
                showPicker = true
            }
            Button("Upload from gallery") {
                sourceType = .photoLibrary
                showPicker = true
            }
            Button("Cancel", role: .cancel) { }
        }
        .sheet(isPresented: $showPicker) {
            ImagePicker(sourceType: sourceType, selectedImage: $selectedUIImage)
        }
        .sheet(isPresented: $showFoodProfileSheet) {  // ← Added sheet for food profiles
            foodProfileSelectionSheet
                .presentationDetents([.medium])  // Half-sheet
                .presentationDragIndicator(.visible)
        }
        .onAppear {
            vm.errorMessage = nil
            loadProfileData()
        }
    }
    
    // Food profile selection sheet content
    private var foodProfileSelectionSheet: some View {
        VStack(spacing: 0) {
            List {
                ForEach(foodProfiles, id: \.self) { profile in
                    HStack {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundStyle(colorForFoodProfile(profile))
                                .frame(width: 50, height: 50)
                            
                            Image(profile)
                        }
                        VStack(alignment: .leading) {
                            Text(profile)
                                .foregroundStyle(.white)
                                .font(.system(size: 16))
                                .fontWeight(.semibold)
                            
                            Text(messageForFoodProfile(profile))
                                .foregroundStyle(.white)
                                .font(.system(size: 15))
                                .fontWeight(.semibold)
                                .opacity(0.7)
                        }
                        Spacer()
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        foodProfile = profile
                        showFoodProfileSheet = false  // Dismiss sheet
                    }
                }
            }
            .listStyle(.plain)
            .scrollIndicators(.never)
            .background(Color.black)  // ← Black background for list
        }
        .background(Color.black)  // ← Black background for sheet
        .preferredColorScheme(.dark)  // Ensures entire sheet is black
    }
    
    private func loadProfileData() {
        guard let profile = vm.profile else { return }
        
        firstName = profile.first_name
        lastName = profile.last_name
        username = profile.username
        bio = profile.bio ?? ""
        location = profile.location ?? ""
        instagram = profile.instagram ?? ""
        tikTok = profile.tiktok ?? ""
        foodProfile = profile.food_profile ?? "Picky"
        
        if let avatarStr = profile.avatar, let url = URL(string: avatarStr) {
            Task {
                do {
                    let (data, _) = try await URLSession.shared.data(from: url)
                    selectedUIImage = UIImage(data: data)
                } catch {
                    print("Error loading avatar: \(error)")
                }
            }
        }
        
        if !username.isEmpty {
            isAvailable = true
        }
    }
    
    func checkUsername(_ value: String) {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            isAvailable = nil
            return
        }
        
        let lower = trimmed.lowercased()
        if lower == vm.profile?.username.lowercased() ?? "" {
            isAvailable = true
            return
        }
        
        isChecking = true
        isAvailable = nil
        
        Task {
            let available = await vm.isUsernameAvailable(lower)
            
            await MainActor.run {
                self.isAvailable = available
                self.isChecking = false
            }
        }
    }
    
    func messageForFoodProfile(_ name: String) -> String {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmed.isEmpty {
            return "Shows you are a picky eater"
        }
        
        switch trimmed {
        case "Picky":
            return "Shows you are a picky eater"
        case "Veggies":
            return "Shows you are a vegetarian or vegan"
        case "Adventorous":
            return "Shows you are An Adventurous eater"
            
        case "Spicy":
            return "Shows you are a Spicy eater"
        case "Big Eater":
            return "Shows you are a Big eater"
        case "Light Eater":
            return "Shows you are a Light eater"
        default:
            return "Shows you are a picky eater"
        }
    }
    
    
    func colorForFoodProfile(_ name: String) -> Color {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmed.isEmpty {
            return .picky
        }
        
        // Or use predefined colors for specific names
        switch trimmed {
        case "Picky":
            return .picky
        case "Veggies":
            return .veggies
        case "Adventorous":
            return .adventorous
        case "Spicy":
            return .spicy
        case "Big Eater":
            return .bigEater
        case "Light Eater":
            return .lightEater
        default:
            return .picky
        }
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    var sourceType: UIImagePickerController.SourceType
    @Binding var selectedImage: UIImage?

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.allowsEditing = true
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let edited = info[.editedImage] as? UIImage {
                parent.selectedImage = edited
            } else if let original = info[.originalImage] as? UIImage {
                parent.selectedImage = original
            }
            picker.dismiss(animated: true)
        }
    }
}

#Preview {
    EditProfileView()
        .environmentObject(ProfileViewModel(userId: ""))
}




