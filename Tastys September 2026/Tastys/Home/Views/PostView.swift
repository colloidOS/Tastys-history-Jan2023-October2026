//
//  PostView.swift
//  Tastys
//
//  Created by Nnagoziem Collins Okegbe on 23/12/2025.
//

import SwiftUI
import PhotosUI
import Combine
import Auth
import Supabase

// Assuming HomeViewModel is defined as provided

struct PostDish: Identifiable {
    let id = UUID()
    var selectedDish: Dish?          // nil = new dish
    var newDishName: String = ""     // only used when selectedDish == nil
    var selectedRating: String = ""
    var selectedCategory: String = ""
    var selectedDiets: [String] = []
    var selectedTags: [String] = []   // the emoji tags (per dish)
    var selectedItems: [PhotosPickerItem] = []
    var selectedImages: [UIImage] = []
}

struct DishReviewView: View {
    @Binding var dish: PostDish
    let ratings: [String]
    let ratingColors: [Color]
    let showRemove: Bool
    let onRemove: () -> Void
    let restaurant: RestaurantDetails?
    
    @State private var showDishSheet = false
    @State private var showImagesPreview = false
    
    
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text((dish.selectedDish?.name.capitalized) ?? "What did you eat")
                    .foregroundStyle(.black)
                    .font(.system(size: 14))
                    .fontWeight(.semibold)
                    .opacity(((dish.selectedDish?.name.isEmpty) == nil) ? 0.5 : 1)
                
                Spacer()
                if showRemove {
                    Button(action: onRemove) {
                        Image(systemName: "xmark")
                            .foregroundStyle(.black)
                            .font(.system(size: 16))
                            .fontWeight(.medium)
                    }
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                if restaurant != nil {
                    showDishSheet = true
                }
            }
            
            Divider()
            
            VStack{
                Text("How Tasty was it")
                    .foregroundStyle(.black)
                    .font(.system(size: 13))
                    .fontWeight(.medium)
                
                HStack {
                    ForEach(Array(ratings.enumerated()), id: \.element) { index, rating in
                        VStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .foregroundStyle(ratingColors[index])
                                
                                if dish.selectedRating == rating {
                                    Circle()
                                        .stroke(Color.black, lineWidth: 2)
                                    
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(.black)
                                        .font(.system(size: 18, weight: .bold))
                                }
                            }
                            .frame(width: 47, height: 47)
                            
                            Text(rating)
                                .foregroundStyle(.black)
                                .font(.system(size: 14))
                                .fontWeight(.medium)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 8)
                        .onTapGesture {
                            dish.selectedRating = rating
                        }
                    }
                }
                .padding(.leading, 10)
            }
            
            
            Divider()
            
            HStack {
                
                Spacer()
                
                PhotosPicker(
                    selection: $dish.selectedItems,
                    maxSelectionCount: 5,
                    matching: .images
                ) {
                    HStack(spacing: 4) {
                        Image(systemName: "plus")
                            .foregroundStyle(.black)
                            .font(.system(size: 16))
                            .fontWeight(.semibold)
                        
                        Text("Upload image")
                            .foregroundStyle(.black)
                            .font(.system(size: 14))
                            .fontWeight(.medium)
                    }
                    .padding(.horizontal, 5)
                    .padding(8)
                    .background {
                        RoundedRectangle(cornerRadius: 20)
                            .foregroundStyle(.rectTastys)
                    }
                }
            }
            
            
            if !dish.selectedImages.isEmpty {
                if !showImagesPreview {
                    VStack {
                        Divider()
                        HStack{
                            Text("\(dish.selectedImages.count) photo\(dish.selectedImages.count > 1 ? "s" : "") added")
                                .foregroundStyle(.black)
                                .font(.system(size: 14))
                                .fontWeight(.medium)
                                .opacity(0.5)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.down")
                                .foregroundStyle(.black)
                                .font(.system(size: 15))
                                .fontWeight(.semibold)
                        }
                        .padding(.horizontal, 5)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            showImagesPreview.toggle()
                        }
                    }
                } else {
                    HStack {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(Array(dish.selectedImages.enumerated()), id: \.offset) { index, image in
                                    ZStack(alignment: .topTrailing) {
                                        Image(uiImage: image)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(height: 50)
                                            .cornerRadius(10)
                                        
                                        Button {
                                            dish.selectedImages.remove(at: index)
                                            if index < dish.selectedItems.count {
                                                dish.selectedItems.remove(at: index)
                                            }
                                        } label: {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundStyle(.white)
                                                .font(.system(size: 20))
                                        }
                                    }
                                }
                            }
                            
                        }
                        .frame(height: 55)
                        
                        Image(systemName: "chevron.up")
                            .foregroundStyle(.black)
                            .font(.system(size: 15))
                            .fontWeight(.semibold)
                            .padding(.horizontal, 5)
                            .onTapGesture {
                                showImagesPreview.toggle()
                            }
                    }
                }
            }
            
            
            
            
            
        }
        .padding(15)
        .background {
            RoundedRectangle(cornerRadius: 25.0)
                .foregroundStyle(.white)
        }
        .onChange(of: dish.selectedItems) { newItems in
            Task {
                dish.selectedImages = []
                for item in newItems {
                    if let data = try? await item.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data) {
                        dish.selectedImages.append(uiImage)
                    }
                }
            }
        }
        .sheet(isPresented: $showDishSheet) {
            DishPickerSheet(selectedDish: $dish.selectedDish, restaurantId: restaurant!.id, newDishName: .constant(""))
                .presentationDetents([.medium])
                .presentationDragIndicator(.hidden)
        }
    }
    
    
}

struct PostView: View {
    @Binding var isShowing: Bool
    @EnvironmentObject var viewModel: HomeViewModel
    @State private var dishes: [PostDish]
    @State private var commentText = ""
    @State private var selectedTags: [String] = []
    @State private var ratings = ["Meh", "It's Fine", "Worth It", "Chefs Kiss"]
    private let ratingColors: [Color] = [
        .rating50,
        .rating70,
        .rating80,
        .rating95
    ]
    @State private var showRestaurantSheet = false
    @State private var selectedRestaurant: RestaurantDetails?
    @State private var showTagsPreview = false
    @FocusState private var isTextFieldFocused: Bool
    @State private var dietTags = ["Halal", "Vegan", "Vegetarian", "Gluten-free", "Diary Free", "Keto", "Paleo"]
    
    @State private var dishTags = ["Burgers", "Sushi", "Pizza", "Ramen", "Indian", "Dessert", "Steak", "Coffee", "Thai", "Chinese", "French", "Mexican", "Italian", "Breakfast", "Barbeque", "Seafood", "Vietnamese", "Mediterranean", "Japanese", "Korean", "Greek", "Spanish", "American"]
    
    private let ratingMap: [String: Int] = [
        "Meh": 50,
        "It's Fine": 70,
        "Worth It": 80,
        "Chefs Kiss": 95
    ]
    
    init(isShowing: Binding<Bool>, prefillRestaurant: RestaurantDetails? = nil, prefillDishes: [Dish]? = nil) {
        _isShowing = isShowing
        _selectedRestaurant = State(initialValue: prefillRestaurant)
        _dishes = State(initialValue: prefillDishes?.map { PostDish(selectedDish: $0) } ?? [PostDish()])
    }
    
    @ViewBuilder
    private func contentVStack() -> some View {
        VStack {
            HStack {
                Text((selectedRestaurant?.name.capitalized) ?? "Type or select restaurant")
                    .foregroundStyle(.black)
                    .font(.system(size: 16))
                    .fontWeight(.semibold)
                
                Spacer()
                
                Image(systemName: "chevron.down")
                    .foregroundStyle(.black)
                    .font(.system(size: 16))
                    .fontWeight(.semibold)
            }
            .padding([.vertical, .horizontal], 18)
            .background {
                RoundedRectangle(cornerRadius: 15)
                    .foregroundStyle(.white)
            }
            .onTapGesture {
                showRestaurantSheet = true
            }
            
            ForEach(dishes.indices, id: \.self) { i in
                DishReviewView(
                    dish: $dishes[i],
                    ratings: ratings,
                    ratingColors: ratingColors,
                    showRemove: dishes.count > 1,
                    onRemove: { dishes.remove(at: i) },
                    restaurant: selectedRestaurant
                )
            }
            
            HStack {
                Text("Did you eat anything else")
                    .foregroundStyle(.black)
                    .opacity(0.5)
                    .font(.system(size: 14))
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button {
                    dishes.append(PostDish())
                } label: {
                    HStack(spacing: 3) {
                        Image("plus")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 23, height: 23)
                        
                        Text("Add")
                            .foregroundStyle(.white)
                            .font(.system(size: 14))
                            .fontWeight(.medium)
                    }
                    .padding(.horizontal, 5)
                    .padding(6)
                    .background {
                        RoundedRectangle(cornerRadius: 20)
                            .foregroundStyle(.barChart2)
                    }
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 10)
            .background {
                RoundedRectangle(cornerRadius: 20)
                    .foregroundStyle(.white)
            }
            
            
            
            
//            HStack {
//                Text("Add to my list")
//                    .foregroundStyle(.black)
//                    .opacity(0.5)
//                    .font(.system(size: 14))
//                    .fontWeight(.semibold)
//
//                Spacer()
//
//                Image(systemName: "chevron.down")
//                    .foregroundStyle(.black)
//                    .font(.system(size: 15))
//                    .fontWeight(.semibold)
//            }
//            .padding([.vertical, .horizontal], 18)
//            .background {
//                RoundedRectangle(cornerRadius: 15)
//                    .foregroundStyle(.white)
//            }
//            .onTapGesture {
//                // TODO: Integrate plate creation if needed
//            }
            
            
            HStack {
                
                Menu {
                    Section("Diet Tags") {
                        ForEach(dietTags, id: \.self) { tag in
                            Button {
                                toggleTag(tag)
                            } label: {
                                HStack {
                                    Text(tag)
                                    if selectedTags.contains(tag) {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    }
                    
                    Section("Dish Tags") {
                        ForEach(dishTags, id: \.self) { tag in
                            Button {
                                toggleTag(tag)
                            } label: {
                                HStack {
                                    Text(tag)
                                    if selectedTags.contains(tag) {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    }
                } label: {
                    Text("Add Tags")
                        .foregroundStyle(.black)
                        .font(.system(size: 14))
                        .fontWeight(.semibold)
                        .padding(.horizontal, 8)
                        .padding(8)
                        .background {
                            RoundedRectangle(cornerRadius: 20)
                                .foregroundStyle(.rectTastys)
                        }
                }
                
                Spacer()
                
                if !selectedTags.isEmpty {
                    if !showTagsPreview {
                        VStack {
//                            Divider()
                            HStack {
                                Text("\(selectedTags.count) tag\(selectedTags.count > 1 ? "s" : "") added")
                                    .foregroundStyle(.black)
                                    .font(.system(size: 14))
                                    .fontWeight(.medium)
                                    .opacity(0.5)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundStyle(.black)
                                    .font(.system(size: 15))
                                    .fontWeight(.semibold)
                            }
                            .padding(.horizontal, 5)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                showTagsPreview.toggle()
                            }
                        }
                    } else {
                        HStack {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(selectedTags, id: \.self) { tag in
                                        HStack(spacing: 4) {
                                            Text(tag)
                                                .foregroundStyle(.black)
                                                .font(.system(size: 12))
                                                .fontWeight(.medium)
                                            
                                            Button {
                                                if let index = selectedTags.firstIndex(of: tag) {
                                                    selectedTags.remove(at: index)
                                                }
                                            } label: {
                                                Image(systemName: "xmark")
                                                    .foregroundStyle(.black)
                                                    .font(.system(size: 12))
                                            }
                                        }
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background {
                                            Capsule()
                                                .foregroundStyle(Color.gray.opacity(0.2))
                                        }
                                    }
                                }
                            }
                            .scrollDismissesKeyboard(.interactively)
                            
                            Image(systemName: "chevron.left")
                                .foregroundStyle(.black)
                                .font(.system(size: 15))
                                .fontWeight(.semibold)
                                .padding(.horizontal, 5)
                                .onTapGesture {
                                    showTagsPreview.toggle()
                                }
                        }
                    }
                }
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 8)
            .background {
                RoundedRectangle(cornerRadius: 15)
                    .foregroundStyle(.white)
            }
            
            HStack {
//                RoundedRectangle(cornerRadius: 25.0)
//                    .foregroundStyle(.tastysRed)
//                    .frame(width: 1, height: 23)
                
                ZStack {
                    if commentText.isEmpty {
                        HStack{
                            Text("Leave a comment e.g too spicy")
                                .foregroundStyle(.black)
                                .opacity(0.4)
                                .font(.system(size: 14))
                                .fontWeight(.semibold)
                            
                            Spacer()
                        }
                    }
                    TextField("", text: $commentText)
                        .foregroundStyle(.black)
                        .font(.system(size: 14))
                        .fontWeight(.medium)
                        .focused($isTextFieldFocused)
                }
            }
            .padding([.vertical, .horizontal], 18)
            .background {
                RoundedRectangle(cornerRadius: 15)
                    .foregroundStyle(.white)
            }
            
            if isTextFieldFocused{
                Spacer()
                Spacer()
                Spacer()
            }
            
            Button {
                Haptics.slide()
                Task {
                    await submitReview()
                }
            } label: {
                HStack {
                    Spacer()
                    Text("Post Review")
                        .foregroundStyle(.white)
                        .font(.system(size: 17))
                        .fontWeight(.bold)
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.vertical, 11)
                .background {
                    RoundedRectangle(cornerRadius: 20)
                        .foregroundStyle(.tastysRed)
                }
            }
            .padding(.vertical)
            .disabled(viewModel.isLoading)
            
            if dishes.count > 1 {
                Color.clear
                    .frame(height: 200)
            }
        }
        .onTapGesture {
            isTextFieldFocused = false
        }
    }
    
    private func toggleTag(_ tag: String) {
        if let index = selectedTags.firstIndex(of: tag) {
            selectedTags.remove(at: index)
        } else {
            selectedTags.append(tag)
        }
    }
    
    private func submitReview() async {
        guard let userId = viewModel.session?.user.id else {
            // Handle no session
            return
        }
        guard let restaurantId = selectedRestaurant?.id else {
            // Handle no restaurant
            return
        }
        
        var dishRatings: [HomeViewModel.DishRatingInput] = []
        for postDish in dishes {
            guard let dishId = postDish.selectedDish?.id,
                  let ratingInt = ratingMap[postDish.selectedRating] else {
                continue
            }
            var imageData: [Data] = []
            for image in postDish.selectedImages {
                if let data = image.jpegData(compressionQuality: 0.8) {
                    imageData.append(data)
                }
            }
            dishRatings.append(
                HomeViewModel.DishRatingInput(
                    dishId: dishId.uuidString,
                    dishName: "",
                    description: "",
                    imageData: imageData,
                    rating: ratingInt,
                    categories: [],
                    diets: [],
                    tags: []
                )
            )
        }
        
        if dishRatings.isEmpty {
            // Handle no valid dishes
            return
        }
        
        viewModel.pendingUserId = userId
        viewModel.pendingRestaurantId = restaurantId.uuidString
        viewModel.pendingDishRatings = dishRatings
        viewModel.pendingComment = commentText.isEmpty ? nil : commentText
        
        isShowing = false
        
        await viewModel.createRatingPost(
            userId: userId,
            restaurantId: restaurantId.uuidString,
            dishRatings: dishRatings,
            comment: commentText.isEmpty ? nil : commentText,
            tags: selectedTags
        )
    }
    
    var body: some View {
        ZStack {
            Color.black
                .opacity(0.1)
                .ignoresSafeArea()
                .blur(radius: 10)
            
            VStack {
                Button {
                    isShowing = false
                } label: {
                    Image(systemName: "xmark")
                        .foregroundStyle(.white)
                        .font(.system(size: 20))
                        .fontWeight(.bold)
                        .padding(10)
                }
                
                if dishes.count > 1 {
                    ScrollView(showsIndicators: false) {
                        contentVStack()
                    }
                } else {
                    Spacer()
                    Spacer()
                    contentVStack()
                }
            }
            .padding(.horizontal)
        }
        .onAppear{
            Haptics.prepare()
        }
        .sheet(isPresented: $showRestaurantSheet) {
            RestaurantPickerSheet(selectedRestaurant: $selectedRestaurant)
                .presentationDetents([.medium])
                .presentationDragIndicator(.hidden)
        }
    }
}

#Preview {
//    PostView(isShowing: .constant(true))
//        .environmentObject(HomeViewModel())
    SuggestRestaurantView()
        .environmentObject(HomeViewModel())
}

struct RestaurantPickerSheet: View {
    @EnvironmentObject var viewModel: HomeViewModel
    @Environment(\.dismiss) var dismiss
    @Binding var selectedRestaurant: RestaurantDetails?
    @State private var searchText = ""
    @FocusState private var isTextFieldFocused: Bool
    @State private var showSuggestRestaurant = false
    var body: some View {
        VStack(spacing: 16) {
            dragKnob
            titleText
            searchField
            suggestRestaurant
            resultsScrollView
            Spacer()
        }
        .padding(.horizontal)
        .background(Color.white)
        .onChange(of: searchText) { newValue in
            Task {
                await viewModel.searchRestaurantsByName(searchTerm: newValue)
            }
        }
        .sheet(isPresented: $showSuggestRestaurant) {
            SuggestRestaurantView()
                .environmentObject(viewModel)
                .presentationDetents([.fraction(2/3)])
                .presentationDragIndicator(.visible)
        }
    }
    
    private var dragKnob: some View {
        RoundedRectangle(cornerRadius: 10)
            .frame(width: 40, height: 5)
            .foregroundStyle(.gray.opacity(0.4))
            .padding(.top, 8)
    }
    
    private var titleText: some View {
        Text("Select restaurant")
            .font(.system(size: 17, weight: .semibold))
            .foregroundStyle(.black)
    }
    
    private var searchField: some View {
        TextField("Search restaurant", text: $searchText)
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .foregroundStyle(.gray.opacity(0.1))
            )
            .focused($isTextFieldFocused)
    }
    
    private var suggestRestaurant: some View {
        Button{
            showSuggestRestaurant = true
        } label: {
            HStack{
                Image(systemName: "square.and.pencil")
                    .foregroundStyle(.tastysRed)
                    .font(.system(size: 16, weight: .semibold))
                    .padding(.trailing, 7)
                Text("can't find? suggest a restaurant")
                    .foregroundStyle(.tastysRed)
                    .font(Font.system(size: 15, weight: .semibold))
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundStyle(.tastysRed)
                    .font(.system(size: 16, weight: .semibold))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(
                Color.tastysRed
                    .opacity(0.15)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            
            )
            
        }
    }
    
    private var resultsScrollView: some View {
        ScrollView {
            VStack(spacing: 12) {
                ForEach(viewModel.searchedRestaurants) { restaurant in
                    HStack {
                        AsyncImage(url: URL(string: restaurant.image ?? "")) { phase in
                            if let image = phase.image {
                                image
                                    .resizable()
                                    .scaledToFill()
                            } else if phase.error != nil {
                                Color.red // Error placeholder
                                    .clipShape(RoundedRectangle(cornerRadius: 15))
                                    .frame(width: 40, height: 40)
//                                    .shimmering()
                            } else {
                                ZStack {
                                    Color.gray // Loading placeholder
                                        .clipShape(RoundedRectangle(cornerRadius: 15))
                                        .frame(width: 40, height: 40)
                                        .shimmering()
                                    
                                    Image("defaultFood")
                                        .resizable()
                                        .scaledToFit()
                                }
                            }
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                        .frame(width: 40, height: 40)
                        .clipped()
                        
                        
                        Text((restaurant.name).capitalized)
                            .foregroundStyle(.black)
                            .font(.system(size: 15, weight: .medium))
                        
                        Spacer()
                        
                        if selectedRestaurant?.id == restaurant.id {
                            Image(systemName: "checkmark")
                                .foregroundStyle(.white)
                                .padding(6)
                                .background {
                                    Circle()
                                        .foregroundStyle(.tastysRed)
                                }
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .foregroundStyle(.white)
                    )
                    .onTapGesture {
                        selectedRestaurant = restaurant
//                        selectedDish
                        dismiss()
                    }
                }
            }
        }
    }
}

struct DishPickerSheet: View {
    @EnvironmentObject var viewModel: HomeViewModel
    @Environment(\.dismiss) var dismiss
    @Binding var selectedDish: Dish?
    let restaurantId: UUID
    @State private var searchText = ""
    @Binding var newDishName: String
    @FocusState private var isTextFieldFocused: Bool
    var body: some View {
        VStack(spacing: 16) {
            dragKnob
            titleText
            searchField
            resultsScrollView
            Spacer()
        }
        .padding(.horizontal)
        .background(Color.white)
        .onChange(of: searchText) { newValue in
            Task {
                await viewModel.searchRestaurantDishes(restaurantId: restaurantId, query: newValue)
            }
        }
        .task {
            await viewModel.searchRestaurantDishes(restaurantId: restaurantId, query: "")
        }
    }
    
    private var dragKnob: some View {
        RoundedRectangle(cornerRadius: 10)
            .frame(width: 40, height: 5)
            .foregroundStyle(.gray.opacity(0.4))
            .padding(.top, 8)
    }
    
    private var titleText: some View {
        Text("Select dish")
            .font(.system(size: 17, weight: .semibold))
            .foregroundStyle(.black)
    }
    
    private var searchField: some View {
        TextField("Search dish", text: $searchText)
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .foregroundStyle(.gray.opacity(0.1))
            )
            .focused($isTextFieldFocused)
    }
    
    private var resultsScrollView: some View {
        ScrollView {
            VStack(spacing: 12) {
                
                ForEach(viewModel.searchedDishes) { dish in
                    HStack {
                        AsyncImage(url: URL(string: dish.image ?? "")) { phase in
                            if let image = phase.image {
                                image
                                    .resizable()
                                    .scaledToFill()
                            } else if phase.error != nil {
                                Color.red
                                    .clipShape(RoundedRectangle(cornerRadius: 15))
                                    .frame(width: 40, height: 40)
                            } else {
                                ZStack {
                                    Color.gray
                                        .clipShape(RoundedRectangle(cornerRadius: 15))
                                        .frame(width: 40, height: 40)
                                        .shimmering()
                                    
                                    Image("defaultFood")
                                        .resizable()
                                        .scaledToFit()
                                }
                            }
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                        .frame(width: 40, height: 40)
                        .clipped()
                        
                        Text(dish.name.capitalized)
                            .foregroundStyle(.black)
                            .font(.system(size: 15, weight: .medium))
                        
                        Spacer()
                        
                        if selectedDish?.id == dish.id {
                            Image(systemName: "checkmark")
                                .foregroundStyle(.white)
                                .padding(6)
                                .background {
                                    Circle()
                                        .foregroundStyle(.tastysRed)
                                }
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .foregroundStyle(.white)
                    )
                    .onTapGesture {
                        selectedDish = dish
                        dismiss()
                    }
                }
                
                // 🔥 ADD NEW DISH BUTTON
                if !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    
                    Button {
                        newDishName = searchText
                        selectedDish = nil
                        dismiss()
                        
                    } label: {
                        HStack {
//                            Image(systemName: "plus")
//                                .font(.system(size: 14, weight: .bold))
                            
                            Text("Add \"\(searchText)\" as a new dish")
                                .font(.system(size: 15, weight: .semibold))
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background {
                            RoundedRectangle(cornerRadius: 20)
                                .foregroundStyle(.tastysRed)
                        }
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 4)
                }
            }
        }
        .scrollDismissesKeyboard(.interactively)
    }
}



struct SuggestRestaurantView: View {
    @State private var restaurant = ""
    @State private var address = ""
    @State private var city = ""
    @StateObject private var addressVM = AddressSearchViewModel()
    @EnvironmentObject var restaurantVM: HomeViewModel
    @Environment(\.dismiss) var dismiss
    var body: some View {
        ScrollView {
//            ZStack{
//                Color.tastysRed
//                    .opacity(0.1)
//                    .ignoresSafeArea()
                VStack{
                    HStack(alignment: .top, spacing: 20){
                        ZStack {
                            Circle()
                                .foregroundStyle(.tastysRed)
                                .opacity(0.15)
                                .frame(width: 50, height: 40)
                            
                            Image(systemName: "storefront")
                                .foregroundStyle(.tastysRed)
                                .font(.system(size: 18))
                        }
                        
                        VStack(alignment: .leading, spacing: 6){
                            Text("Can't find it?")
                                .foregroundStyle(.black)
                                .font(.system(size: 16))
                                .fontWeight(.semibold)
                            
                            Text("Suggest a restaurant\n and we'll review it")
                                .foregroundStyle(.black)
                                .opacity(0.4)
                                .font(.system(size: 14))
                                .fontWeight(.medium)
                        }
                        
                        Spacer()
                        
                    }
                    .padding(.leading)
                    .padding(.vertical, 14)
                    
                    VStack (spacing: 15){
                        ReusableField(placeholder: "Restaurant Name", systemImage: "storefront", text: $restaurant)
                        
                        VStack(alignment: .leading, spacing: 0) {
                            
                            ReusableField(
                                placeholder: "Address",
                                systemImage: "location.circle",
                                text: Binding(
                                    get: { address },
                                    set: {
                                        address = $0
                                        addressVM.updateQuery($0)
                                    }
                                )
                            )
                            
                            if !addressVM.suggestions.isEmpty && !address.isEmpty {
                                
                                ScrollView {
                                    VStack(alignment: .leading, spacing: 0) {
                                        
                                        ForEach(addressVM.suggestions.indices, id: \.self) { index in
                                            let suggestion = addressVM.suggestions[index]
                                            
                                            Button {
                                                address = suggestion.title
                                                
                                                if !suggestion.subtitle.isEmpty {
                                                    city = suggestion.subtitle
                                                }
                                                
                                                addressVM.suggestions = []
                                            } label: {
                                                
                                                VStack(alignment: .leading, spacing: 4) {
                                                    Text(suggestion.title)
                                                        .foregroundStyle(.black)
                                                    
                                                    if !suggestion.subtitle.isEmpty {
                                                        Text(suggestion.subtitle)
                                                            .font(.caption)
                                                            .foregroundStyle(.black)
                                                            .opacity(0.4)
                                                    }
                                                }
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .padding(.horizontal, 12)
                                                .padding(.vertical, 10)
                                            }
                                            
                                            Divider()
                                        }
                                    }
                                }
                                .frame(maxHeight: 150)
                            }
                        }
                        
                        ReusableField(placeholder: "City", systemImage: "building.2", text: $city)
                    }
                    .padding(.horizontal)
                    
                    Button {
                        
                        guard !restaurant.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                            restaurantVM.showError("Please enter a restaurant name")
                            return
                        }
                        
                        guard !address.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                            restaurantVM.showError("Please enter an address")
                            return
                        }
                        
                        Task {
                            let success = await restaurantVM.suggestRestaurant(
                                name: restaurant,
                                address: address,
                                city: city
                            )
                            
                            if success {
                                restaurant = ""
                                address = ""
                                city = ""
                                addressVM.suggestions = []
                                dismiss()
                            }
                        }
                        
                    } label: {
                        HStack {
                            Spacer()
                            
                            if restaurantVM.isUpdateLoading {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text("Submit")
                                    .foregroundStyle(.white)
                                    .font(.system(size: 16))
                                    .fontWeight(.semibold)
                            }
                            
                            Spacer()
                        }
                        .padding(.vertical, 14)
                        .background(Color.tastysRed)
                        .cornerRadius(14)
                    }
                    .disabled(restaurantVM.isUpdateLoading)
                    .padding(.horizontal)
                    .padding(.top, 20)
                    
                    Text("we'll review and add to tastys")
                        .foregroundStyle(.black)
                        .opacity(0.5)
                        .font(.system(size: 13))
                        .padding(.bottom, 20)
                        .padding(.top, 5)
                    
                    
                }
//            }
            
            
//            .padding(.horizontal)
//            .padding(.vertical, 20)
        }
        .padding(.horizontal)
        .padding(.top, 20)
        .background{
            RoundedRectangle(cornerRadius: 15)
//                    .stroke(lineWidth: 1)
                .foregroundStyle(.white)
//                                .opacity(0.05)
            
            RoundedRectangle(cornerRadius: 15)
                .foregroundStyle(.tastysRed)
                .opacity(0.05)
            
        }
    }
    
}




struct ReusableField: View{
    var placeholder: String
    var systemImage: String
    @Binding var text: String
    var body: some View {
        HStack(spacing: 10){
            Image(systemName: systemImage)
                .foregroundStyle(.black)
                .font(.system(size: 15))
                .opacity(0.3)
            
            TextField(placeholder, text: $text)
                .foregroundStyle(.black)
                .font(.system(size: 14))
        }
        .padding(.horizontal)
        .padding(.vertical, 15)
        .background{
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .foregroundStyle(.white)
                
                RoundedRectangle(cornerRadius: 12)
                    .stroke(lineWidth: 1)
                    .foregroundStyle(.grayTastys)
                
            }
                
        }
    }
}
