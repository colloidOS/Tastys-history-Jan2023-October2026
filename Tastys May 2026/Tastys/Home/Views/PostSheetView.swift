//
//  PostSheetView.swift
//  Tastys
//
//  Created by Nnagoziem Collins Okegbe on 08/05/2026.
//

import SwiftUI
import PhotosUI

struct PostSheetView: View {
    @Binding var isShowing: Bool
    @State private var selectedDish: Dish?
    @EnvironmentObject var viewModel: HomeViewModel
    @State private var postDish: PostDish = PostDish()
    @State private var showDishSheet = false
    @State private var commentText = ""
    @State private var ratings = ["Meh", "Solid", "Fire", "Chef's Kiss"]
    private let ratingColors: [Color] = [
        .rating50,
        .rating70,
        .rating80,
        .rating95
    ]
    @State private var showRestaurantSheet = false
    @State private var selectedRestaurant: RestaurantDetails?
    @State private var showTagsPreview = false
    @State private var showCategoryOptions = false
    @FocusState private var isTextFieldFocused: Bool
    
    
    @State private var categoryOptions = ["Burgers", "Sushi", "Pizza", "Ramen", "Indian", "Dessert", "Steak", "Coffee", "Thai", "Chinese", "French", "Mexican", "Italian", "Breakfast", "Barbeque", "Seafood", "Vietnamese", "Mediterranean", "Japanese", "Korean", "Greek", "Spanish", "American"]
    
    @State private var tags = ["🌶️ Spicy", "🧀 Cheesy", "🍗 Crispy", "💧 Juicy", "🍖 Tender", "🌿 Fresh", "🍯 Sweet", "🧂 Salty", "⭐ Flavorful", "🍝 Saucy"]
    @State private var animateSelected = false
    private let ratingMap: [String: Int] = [
        "Meh": 50,
        "Solid": 70,
        "Fire": 80,
        "Chef's Kiss": 95
    ]
    
    private let ratingImage: [String: String] = [
        "Meh": "mehIcon",
        "Solid": "solidIcon",
        "Fire": "fireIcon",
        "Chef's Kiss": "chefsKissIcon"
    ]
    
    init(isShowing: Binding<Bool>, prefillRestaurant: RestaurantDetails? = nil, prefillDishes: [Dish]? = nil) {
        _isShowing = isShowing
        _selectedRestaurant = State(initialValue: prefillRestaurant)
        
        if let prefill = prefillDishes?.first {
            _postDish = State(initialValue: PostDish(selectedDish: prefill))
        } else {
            _postDish = State(initialValue: PostDish())
        }
    }
    
//    @ViewBuilder
    // MARK: - Submit
    private func submitReview() async {
        guard let userId = viewModel.session?.user.id else { return }
        guard let restaurantId = selectedRestaurant?.id else { return }
        
        let pd = postDish
        
        guard let ratingInt = ratingMap[pd.selectedRating] else { return }
        
        // build image data
        var imageData: [Data] = []
        for image in pd.selectedImages {
            if let data = image.jpegData(compressionQuality: 0.8) {
                imageData.append(data)
            }
        }
        
        let dishId = pd.selectedDish?.id.uuidString
        let dishName = pd.selectedDish == nil ? pd.newDishName : nil
        
        let dishRating = HomeViewModel.DishRatingInput(
            dishId: dishId,
            dishName: dishName,
            description: "",
            imageData: imageData,
            rating: ratingInt,
            categories: pd.selectedCategory.isEmpty ? [] : [pd.selectedCategory],
            diets: pd.selectedDiets,
            tags: pd.selectedTags
        )
        
        viewModel.pendingUserId = userId
        viewModel.pendingRestaurantId = restaurantId.uuidString
        viewModel.pendingDishRatings = [dishRating]
        viewModel.pendingComment = commentText.isEmpty ? nil : commentText
        
        await viewModel.createRatingPost2(
            userId: userId,
            restaurantId: restaurantId.uuidString,
            dishRatings: [dishRating],
            comment: commentText.isEmpty ? "" : commentText,
            tags: [] // post-level tags (you can pass selectedTags if you want)
        )
        Haptics.revealDone()
        
        if let dishId = viewModel.CurrentDishId {
            await viewModel.fetchDishDetail(dishId: dishId, userId: viewModel.session?.user.id.uuidString)
            await viewModel.loadDishPosts(dishId: dishId, sortBy: "recent")
        }
        
        if let restaurantId = viewModel.CurrentRestaurantId {
            await viewModel.fetchRestaurantDetail(restaurantId: restaurantId, userId: viewModel.session?.user.id.uuidString)
        }
        
        await viewModel.getTrendingDishesNearUser(
            limit: 20,
            category: nil
        )
        
        await viewModel.getTopRatedDishesNearUser(
            limit: 20,
            category: nil
        )
        // show success screen instead of instantly dismissing
    }
    
    // MARK: - Reset for "Add another Dish"
    private func resetForm() {
        postDish = PostDish()           // fresh dish
        selectedDish = nil
        newDishName = ""
        commentText = ""
        currentPage = 0
        viewModel.showSuccessScreen = false
        
        // reset validation
        isrestaurantCorrect = true
        isDishCorrect = true
        isCategoryCorrect = true
        isratingCorrect = true
    }
    @State private var isSubmitting = false
//    @State private var showSuccessScreen = false
    @State private var isrestaurantCorrect = true
    @State private var isDishCorrect = true
    @State private var isCategoryCorrect = true
    @State private var isratingCorrect = true
    
    @State private var currentPage = 0
    let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 3)
    @State private var diets = ["Halal", "Vegan", "Vegetarian", "Gluten-free", "Diary Free", "Keto", "Paleo"]
    @State private var selectedDiet: [String] = []
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var selectedImages: [UIImage] = []
    @State private var newDishName = ""
    
    var body: some View {
        ZStack {
            if viewModel.showSuccessScreen {
                SuccessSubmittedView(
                    isShowing: $isShowing,
                    onAddAnother: resetForm          // ← connects the button
                )
            } else {
                VStack(spacing: 20) {
                    
                    RoundedRectangle(cornerRadius: 40)
                        .foregroundStyle(.grayTastys)
                        .opacity(0.6)
                        .frame(width: 50, height: 4)
                    
                    // MARK: Header
                    ZStack {
                        
                        Text(currentPage == 0 ? "New Review" : "More Details")
                            .foregroundStyle(.black)
                            .font(.system(size: 20))
                            .fontWeight(.semibold)
                        
                        HStack {
                            
                            // Page 2 back button
                            if currentPage == 1 {
                                Button {
                                    withAnimation(.easeInOut) {
                                        currentPage = 0
                                    }
                                } label: {
                                    Image(systemName: "chevron.left")
                                        .foregroundStyle(.black)
                                        .font(.system(size: 18))
                                        .fontWeight(.bold)
                                        .background {
                                            Circle()
                                                .foregroundStyle(.grayTastys)
                                                .opacity(0.6)
                                                .frame(width: 39, height: 40)
                                        }
                                        .frame(width: 40, height: 40)
                                }
                            } else {
                                // X button
                                Button {
                                    resetForm()
                                    selectedRestaurant = nil
                                    isShowing = false
                                } label: {
                                    Image(systemName: "xmark")
                                        .foregroundStyle(.black)
                                        .font(.system(size: 18))
                                        .fontWeight(.bold)
                                        .background {
                                            Circle()
                                                .foregroundStyle(.grayTastys)
                                                .opacity(0.6)
                                                .frame(width: 40, height: 40)
                                        }
                                        .frame(width: 40, height: 40)
                                }
                            }
                            
                            Spacer()
                            
                            
                            
                        }
                    }
                    
                    // MARK: Pages
                    TabView(selection: $currentPage) {
                        
                        // MARK: PAGE 1
                        ScrollView(showsIndicators: false) {
                            VStack(spacing: 20) {
                                
                                VStack(alignment: .leading) {
                                    Text("Where was it from?*")
                                        .foregroundStyle(isrestaurantCorrect ? .black : .tastysRed)
                                        .font(.system(size: 16))
                                        .fontWeight(.medium)
                                        .onChange(of: selectedRestaurant?.id) {
                                            if selectedRestaurant != nil {
                                                isrestaurantCorrect = true
                                            }
                                        }
                                    
                                    Button {
                                        showRestaurantSheet.toggle()
                                    } label: {
                                        HStack {
                                            Image(systemName: "magnifyingglass")
                                                .foregroundStyle(.black)
                                                .font(.system(size: 16))
                                                .fontWeight(.bold)
                                                .opacity(0.4)
                                            
                                            Text((selectedRestaurant?.name.capitalized) ?? "Search for a restaurant")
                                                .foregroundStyle(.black)
                                                .font(.system(size: 16))
                                                .fontWeight(.medium)
                                                .opacity(selectedRestaurant?.name.isEmpty ?? true ? 0.4 : 1)
                                                .lineLimit(1)
                                            
                                            Spacer()
                                        }
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 15)
                                        .background {
                                            RoundedRectangle(cornerRadius: 25)
                                                .foregroundStyle(.ashTastys)
                                                .opacity(0.7)
                                        }
                                    }
                                }
                                
                                VStack(alignment: .leading) {
                                    Text("What did you eat?*")
                                        .foregroundStyle(isDishCorrect ? .black : .tastysRed)
                                        .font(.system(size: 16))
                                        .fontWeight(.medium)
                                    
                                    Button {
                                        if selectedRestaurant == nil {
                                            showRestaurantSheet.toggle()
                                        } else {
                                            showDishSheet.toggle()
                                        }
                                    } label: {
                                        HStack {
                                            Image(systemName: "magnifyingglass")
                                                .foregroundStyle(.black)
                                                .font(.system(size: 16))
                                                .fontWeight(.bold)
                                                .opacity(0.4)
                                            
                                            Text((postDish.selectedDish?.name.capitalized) ?? (postDish.newDishName.isEmpty ? "Search for a dish" : postDish.newDishName.capitalized))
                                                .foregroundStyle(.black)
                                                .font(.system(size: 12))
                                                .fontWeight(.medium)
                                                .opacity((postDish.selectedDish == nil && postDish.newDishName.isEmpty) ? 0.4 : 1)
                                                .lineLimit(1)
                                            
                                            Spacer()
                                        }
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 15)
                                        .background {
                                            RoundedRectangle(cornerRadius: 25)
                                                .foregroundStyle(.ashTastys)
                                                .opacity(0.7)
                                        }
                                    }
                                }
                                
                                VStack(alignment: .leading){
                                    Text("What type of dish is it?*")
                                        .foregroundStyle(isCategoryCorrect ? .black : .tastysRed)
                                        .font(.system(size: 16))
                                        .fontWeight(.medium)
                                    
                                    Button{
                                        showCategoryOptions.toggle()
                                    } label: {
                                        HStack{
                                            if !postDish.selectedCategory.isEmpty {
                                                Image(postDish.selectedCategory)
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: 40, height: 40)
                                                
                                                Text(postDish.selectedCategory.capitalized)
                                                    .foregroundStyle(.black)
                                                    .font(.system(size: 16))
                                                    .fontWeight(.medium)
                                                
                                                Spacer()
                                                
                                                Image(systemName: "chevron.down")
                                                    .foregroundStyle(.black)
                                                    .font(.system(size: 15))
                                                    .opacity(0.7)
                                            } else {
                                                Text("select category")
                                                    .foregroundStyle(.black)
                                                    .font(.system(size: 16))
                                                    .fontWeight(.medium)
                                                    .opacity(0.4)
                                                
                                                Spacer()
                                                
                                                Image(systemName: "chevron.down")
                                                    .foregroundStyle(.black)
                                                    .font(.system(size: 15))
                                                    .opacity(0.4)
                                            }
                                        }
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 15)
                                        .background{
                                            RoundedRectangle(cornerRadius: 25)
                                                .foregroundStyle(.ashTastys)
                                                .opacity(0.7)
                                        }
                                    }
                                    .onChange(of: postDish.selectedCategory) {
                                        if !$0.isEmpty {
                                            isCategoryCorrect = true
                                        }
                                    }
                                }
                                //                .padding(.vertical, 16)
                                
                                VStack(alignment: .leading){
                                    HStack {
                                        Text("How Tasty was it?*")
                                            .foregroundStyle(isratingCorrect ? .black : .tastysRed)
                                            .font(.system(size: 16))
                                            .fontWeight(.medium)
                                            .onChange(of: postDish.selectedRating) {
                                                if !$0.isEmpty {
                                                    isratingCorrect = true
                                                }
                                            }
                                        
                                    }
                                    
                                    HStack {
                                        //                        Spacer()
                                        ForEach(Array(ratings.enumerated()), id: \.element) { index, rating in
                                            VStack(spacing: 16) {
                                                ZStack {
                                                    Circle()
                                                        .foregroundStyle(postDish.selectedRating == rating ? .tastysRed.opacity(0.1) : .ashTastys)
                                                        .frame(width: 60, height: 60)
                                                    
                                                    if postDish.selectedRating == rating {
                                                        Circle()
                                                            .stroke(Color.tastysRed.opacity(0.1), lineWidth: 2)
                                                            .frame(width: 72, height: 70)
                                                            .padding(index == 0 ? 8 : 0)
                                                    }
                                                    
                                                    Image(ratingImage[rating] ?? "fireIcon")
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(width: 32, height: 32)
                                                        .scaleEffect(postDish.selectedRating == rating ? 1.3 : 1)
                                                        .animation(
                                                            postDish.selectedRating == rating
                                                            ? .easeInOut(duration: 1).repeatForever(autoreverses: true)
                                                            : .default,
                                                            value: postDish.selectedRating
                                                        )
                                                }
                                                .frame(width: 70, height: 70)
                                                
                                                Text(rating)
                                                    .foregroundStyle(.black)
                                                    .font(.system(size: 14))
                                                    .fontWeight(.medium)
                                            }
                                            //                            .padding(.horizontal, 10)
                                            .padding(.vertical, 8)
                                            .onTapGesture {
                                                postDish.selectedRating = rating
                                            }
                                            if rating != ratings.last {
                                                Spacer()
                                            }
                                        }
                                    }
                                    //                    .padding(.leading, 10)
                                    
                                }
                                
                                VStack {
                                    
                                    // MARK: Go to page 2
                                    Button {
                                        
                                        withAnimation(.easeInOut) {
                                            currentPage = 1
                                        }
                                        
                                    } label: {
                                        
                                        HStack(spacing: 0) {
                                            Image(systemName: "message")
                                                .foregroundStyle(.black)
                                                .font(.system(size: 16))
                                            
                                            Text("  Add more details ")
                                                .foregroundStyle(.black)
                                                .font(.system(size: 15))
                                                .fontWeight(.medium)
                                            
                                            Text("(optional)")
                                                .foregroundStyle(.black)
                                                .font(.system(size: 15))
                                                .fontWeight(.medium)
                                                .opacity(0.5)
                                        }
                                        .padding(.vertical, 14)
                                        .padding(.horizontal, 20)
                                        .background{
                                            ZStack{
                                                Color.ashTastys
                                                    .clipShape(RoundedRectangle(cornerRadius: 13))
                                                RoundedRectangle(cornerRadius: 15)
                                                    .stroke(lineWidth: 1)
                                                    .foregroundStyle(.gradTastys)
                                            }
                                        }
                                    }
                                    
                                    
                                }
                                .padding(.top, 24)
                            }
                        }
                        .tag(0)
                        
                        // MARK: PAGE 2
                        ScrollView (showsIndicators: false) {
                            VStack(spacing: 20) {
                                
                                
                                VStack(alignment: .leading) {
                                    HStack(spacing: 0) {
                                        Text("Add tags")
                                            .foregroundStyle(.black)
                                            .font(.system(size: 15))
                                            .fontWeight(.medium)
                                        
                                        Text(" (optional)")
                                            .foregroundStyle(.black)
                                            .font(.system(size: 15))
                                            .fontWeight(.medium)
                                            .opacity(0.5)
                                    }
                                    
                                    LazyVGrid(columns: columns, spacing: 12) {
                                        ForEach(tags.prefix(12), id: \.self) { tag in
                                            let isSelected = postDish.selectedTags.contains(tag)
                                            
                                            Button {
                                                if isSelected {
                                                    postDish.selectedTags.removeAll { $0 == tag }
                                                } else {
                                                    postDish.selectedTags.append(tag)
                                                }
                                            } label: {
                                                Text(tag)
                                                    .font(.system(size: 12, weight: .medium))
                                                    .foregroundStyle(isSelected ? .white : .black)
                                                    .multilineTextAlignment(.center)
                                                    .padding(.vertical, 10)
                                                    .frame(maxWidth: .infinity)
                                                    .background(
                                                        RoundedRectangle(cornerRadius: 14)
                                                            .fill(isSelected ? .black : .ashTastys)
                                                    )
                                            }
                                            .buttonStyle(.plain)
                                            .animation(.easeInOut(duration: 0.2), value: isSelected)
                                        }
                                    }
                                    .padding(.horizontal, 5)
                                }
                                
                                VStack(alignment: .leading) {
                                    HStack(spacing: 0) {
                                        Text("Dietary Filters")
                                            .foregroundStyle(.black)
                                            .font(.system(size: 15))
                                            .fontWeight(.medium)
                                        
                                        Text(" (optional)")
                                            .foregroundStyle(.black)
                                            .font(.system(size: 13))
                                            .fontWeight(.medium)
                                            .opacity(0.5)
                                    }
                                    
                                    LazyVGrid(columns: columns, spacing: 12) {
                                        ForEach(diets.prefix(12), id: \.self) { diet in
                                            let isSelected = postDish.selectedDiets.contains(diet)
                                            
                                            Button {
                                                if isSelected {
                                                    postDish.selectedDiets.removeAll { $0 == diet }
                                                } else {
                                                    postDish.selectedDiets.append(diet)
                                                }
                                            } label: {
                                                HStack {
                                                    Image(diet)
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(width: 20, height: 20)
                                                    
                                                    Text(diet)
                                                        .font(.system(size: 13, weight: .medium))
                                                        .foregroundStyle(isSelected ? .white : .black)
                                                }
                                                .padding(.vertical, 10)
                                                .frame(maxWidth: .infinity)
                                                .background(
                                                    RoundedRectangle(cornerRadius: 14)
                                                        .fill(isSelected ? .black : .ashTastys)
                                                )
                                            }
                                            .buttonStyle(.plain)
                                        }
                                    }
                                }
                                
                                VStack{
                                    HStack {
                                        
                                        Spacer()
                                        
                                        PhotosPicker(
                                            selection: $postDish.selectedItems,
                                            maxSelectionCount: 5,
                                            matching: .images
                                        ) {
                                            HStack(spacing: 4) {
                                                Image(systemName: "plus")
                                                    .foregroundStyle(.black)
                                                    .font(.system(size: 12))
                                                    .fontWeight(.semibold)
                                                
                                                Text("Upload image")
                                                    .foregroundStyle(.black)
                                                    .font(.system(size: 10))
                                                    .fontWeight(.medium)
                                            }
                                            .padding(.horizontal, 5)
                                            .padding(8)
                                            .background {
                                                RoundedRectangle(cornerRadius: 20)
                                                    .foregroundStyle(.rectTastys)
                                            }
                                        }
                                        .onChange(of: postDish.selectedItems) { newItems in
                                            Task {
                                                var images: [UIImage] = []
                                                
                                                for item in newItems {
                                                    if let data = try? await item.loadTransferable(type: Data.self),
                                                       let uiImage = UIImage(data: data) {
                                                        images.append(uiImage)
                                                    }
                                                }
                                                
                                                await MainActor.run {
                                                    postDish.selectedImages = images
                                                }
                                            }
                                        }
                                        
                                        Spacer()
                                    }
                                    
                                    
                                    if !postDish.selectedImages.isEmpty {
                                        
                                        HStack {
                                            ScrollView(.horizontal, showsIndicators: false) {
                                                HStack(spacing: 14) {
                                                    ForEach(Array(postDish.selectedImages.enumerated()), id: \.offset) { index, image in
                                                        ZStack(alignment: .topTrailing) {
                                                            Image(uiImage: image)
                                                                .resizable()
                                                                .scaledToFill()
                                                                .frame(width: 50, height: 50)
                                                                .cornerRadius(8)
                                                            
                                                            Button {
                                                                postDish.selectedImages.remove(at: index)
                                                                if index < postDish.selectedItems.count {
                                                                    postDish.selectedItems.remove(at: index)
                                                                }
                                                            } label: {
                                                                Image(systemName: "xmark.circle.fill")
                                                                    .foregroundStyle(.white)
                                                                    .font(.system(size: 20))
                                                                    .background{
                                                                        Circle()
                                                                            .foregroundStyle(.black)
                                                                            .padding(6)
                                                                    }
                                                            }
                                                        }
                                                    }
                                                }
                                                
                                            }
                                            .frame(height: 55)
                                            
                                            
                                        }
                                    }
                                    
                                    ZStack(alignment: .topLeading) {
                                        
                                        if commentText.isEmpty {
                                            Text("Leave a comment e.g too spicy")
                                                .font(.system(size: 13))
                                                .foregroundStyle(.black)
                                                .fontWeight(.medium)
                                                .padding(.horizontal, 18)
                                                .padding(.vertical, 20)
                                                .opacity(0.5)
                                        }
                                        
                                        TextEditor(text: $commentText)
                                            .padding(12)
                                            .frame(height: 100)
                                            .scrollContentBackground(.hidden)
                                            .background(Color.clear)
                                            .font(.system(size: 13))
                                            .foregroundStyle(.black)
                                            .fontWeight(.medium)
                                    }
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(Color.white)
                                    )
                                }
                                .padding(5)
                                .padding(.top, 15)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color.grayTastys.opacity(0.5))
                                )
                                
                            }
                        }
                        .tag(1)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    
                    Button {
                        
                        // validation
                        if selectedRestaurant == nil { isrestaurantCorrect = false }
                        viewModel.showError("select a restaurant")
                        if postDish.selectedDish == nil && postDish.newDishName.isEmpty { isDishCorrect = false }
                        viewModel.showError("select a dish")
                        if postDish.selectedCategory.isEmpty { isCategoryCorrect = false }
                        viewModel.showError("select a category for the dish")
                        if postDish.selectedRating.isEmpty { isratingCorrect = false }
                        viewModel.showError("Rate the dish")
                        
                        guard selectedRestaurant != nil,
                              (postDish.selectedDish != nil || !postDish.newDishName.isEmpty),
                              !postDish.selectedCategory.isEmpty,
                              !postDish.selectedRating.isEmpty else { return }
                        
                        isSubmitting = true
                        Task {
                            await submitReview()
                            isSubmitting = false
                        }
                        
                    } label: {
                        
                        HStack {
                            Spacer()
                            
                            if isSubmitting {
                                ProgressView().tint(.white)
                            } else {
                                Text("Add Rating")
                                    .foregroundStyle(.white)
                                    .font(.system(size: 16, weight: .medium))
                            }
                            
                            Spacer()
                        }
                        .padding(.vertical, 14)
                        .background {
                            RoundedRectangle(cornerRadius: 25)
                                .foregroundStyle(.tastysRed)
                        }
                        .padding(.horizontal, 10)
                    }
                    .disabled(isSubmitting)
                }
                .padding(20)
            }
        }
        .onAppear{
            Haptics.prepare()
            animateSelected = true
            
        }
        .onDisappear{
            viewModel.searchedRestaurants = []
        }
        .sheet(isPresented: $showRestaurantSheet) {
            RestaurantPickerSheet(selectedRestaurant: $selectedRestaurant)
                .presentationDetents([.medium])
                .presentationDragIndicator(.hidden)
        }
        .sheet(isPresented: $showDishSheet) {
            if let restaurant = selectedRestaurant {
                DishPickerSheet(selectedDish: $selectedDish, restaurantId: restaurant.id, newDishName: $newDishName)
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.hidden)
            } else {
                Text("Select a restaurant first")
                    .padding()
            }
        }
        .sheet(isPresented: $showCategoryOptions) {
            categoryOptionsView(isShowing: $showCategoryOptions, selectedCategory: $postDish.selectedCategory)
                .presentationDetents([.medium])
                .presentationDragIndicator(.hidden)
        }
        .onChange(of: selectedDish) { newValue in
            if let newValue {
                postDish.selectedDish = newValue
                postDish.newDishName = ""
                isDishCorrect = true
            }
        }
        .onChange(of: selectedRestaurant?.id) {
            selectedDish = nil
            postDish.selectedDish = nil
            postDish.newDishName = ""
            newDishName = ""
        }
        .onChange(of: newDishName) { newValue in
            if !newValue.isEmpty {
                postDish.newDishName = newValue
                postDish.selectedDish = nil
                newDishName = ""
                isDishCorrect = true
            }
        }
    }
}

#Preview {
    PostSheetView(isShowing: .constant(true))
        .environmentObject(HomeViewModel())
    
//    SuccessSubmittedView(isShowing: .constant(true), onAddAnother: {})
}


struct categoryOptionsView: View {
    @Binding var isShowing: Bool
    @State private var categoryOptions = ["Burgers", "Sushi", "Pizza", "Ramen", "Indian", "Dessert", "Steak", "Coffee", "Thai", "Chinese", "French", "Mexican", "Italian", "Breakfast", "Barbeque", "Seafood", "Vietnamese", "Mediterranean", "Japanese", "Korean", "Greek", "Spanish", "American"]
    
    @Binding var selectedCategory: String
    var body: some View {
        ZStack {
            VStack {
                RoundedRectangle(cornerRadius: 44)
                    .foregroundStyle(.grayTastys)
                    .opacity(0.6)
                    .frame(width: 50, height: 4)
                
                ZStack{
                    Text("What type of dish is it? ")
                        .foregroundStyle(.black)
                        .font(.system(size: 20))
                        .fontWeight(.semibold)
                    
                    HStack{
                        Button{
                           isShowing = false
                        } label: {
                            Image(systemName: "xmark")
                                .foregroundStyle(.black)
                                .font(.system(size: 18))
                                .fontWeight(.bold)
                                .background{
                                    Circle()
                                        .foregroundStyle(.grayTastys)
                                        .opacity(0.6)
                                        .frame(width: 40, height: 40)
                                }
                                .frame(width: 44, height: 40)
                        }
                        
                        Spacer()
                    }
                }
                ScrollView {
                    VStack{
                        ForEach(categoryOptions, id: \.self) { option in
                            Button{
                               selectedCategory = option
                                isShowing.toggle()
                            } label: {
                                HStack(spacing: 10){
                                    Image(option)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 40, height: 40)
                                    
                                    VStack(alignment: .leading) {
                                        Text(option)
                                            .font(.system(size: 15))
                                            .fontWeight(.medium)
                                            .foregroundStyle(.black)
                                        
                                        Text("200+ restaurants")
                                            .font(.system(size: 12))
                                            .fontWeight(.medium)
                                            .foregroundStyle(.black)
                                            .opacity(0.5)
                                    }
                                    Spacer()
                                    
                                    
                                    if selectedCategory == option {
                                        ZStack {
                                            Circle()
                                                .stroke(lineWidth: 1)
                                                .foregroundStyle(.black)
                                                .frame(height: 23)
                                            
                                            Circle()
                                                .foregroundStyle(.black)
                                                .frame(height: 17)
                                        }
                                    }
                                }
                            }
                            
                        }
                    }
                }
            }
            .padding(20)
        }
    }
}



struct SuccessSubmittedView: View {
    @Binding var isShowing: Bool
    let onAddAnother: () -> Void   // ← NEW: this will reset the form
    
    @State private var scaleNumber: CGFloat = 1.0
    @State private var rotation: CGFloat = 0.0
    
    var body: some View {
        VStack(spacing: 15) {
            RoundedRectangle(cornerRadius: 40)
                .foregroundStyle(.grayTastys)
                .opacity(0.6)
                .frame(width: 50, height: 4)
            
            // MARK: Header
            ZStack {
                HStack {
                    Button {
                        isShowing = false
                        onAddAnother()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundStyle(.black)
                            .font(.system(size: 18))
                            .fontWeight(.bold)
                            .background {
                                Circle()
                                    .foregroundStyle(.grayTastys)
                                    .opacity(0.6)
                                    .frame(width: 40, height: 40)
                            }
                            .frame(width: 40, height: 40)
                    }
                    Spacer()
                }
            }
            
            Spacer()
            
            ZStack {
                ZStack {
                    ForEach(0..<25, id: \.self) { _ in
                        Circle()
                            .frame(width: 4, height: 4)
                            .foregroundStyle(.plusShadow)
                            .offset(
                                x: CGFloat.random(in: -100...100),
                                y: CGFloat.random(in: -100...100)
                            )
                    }
                }
                .frame(width: 204, height: 200)
                .clipped()
                .rotationEffect(Angle(degrees: rotation))
                
                Image("star4Icon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                    .scaleEffect(scaleNumber)
                
                Image(systemName: "checkmark")
                    .foregroundStyle(.white)
                    .font(.system(size: 46))
                    .fontWeight(.bold)
                    .scaleEffect(scaleNumber)
            }
            
            Text("Thanks")
                .font(.system(size: 20))
                .foregroundStyle(.plusShadow)
                .fontWeight(.semibold)
            
            Text("Your review is live! ")
                .font(.system(size: 15))
                .foregroundStyle(.black)
                .fontWeight(.medium)
                .opacity(0.5)
            
            Spacer()
            
            VStack {
                Button {
                    onAddAnother()          // ← calls reset in PostSheetView
                } label: {
                    Text("Add another Dish")
                        .font(.system(size: 16))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                        .background(RoundedRectangle(cornerRadius: 25).foregroundStyle(.tastysRed))
                }
                .padding(.horizontal, 20)
                
                Button {
                    isShowing = false
                    onAddAnother()
                } label: {
                    Text("Done")
                        .font(.system(size: 20))
                        .foregroundStyle(.black)
                }
            }
        }
        .padding()
        .onAppear {
            scaleNumber = 1.0
            rotation = 0.0
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                scaleNumber = 1.1
            }
            withAnimation(.linear(duration: 100).repeatForever(autoreverses: false)) {
                rotation = 360.0
            }
        }
    }
}
