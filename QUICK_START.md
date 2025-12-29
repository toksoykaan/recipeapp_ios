# 🚀 RecipeVault - Quick Start Guide

**Your Xcode project is ready!** Follow these steps to add all the RecipeVault features.

---

## ✅ What's Already Done

- ✅ Xcode project created at `/Users/kaantoksoy/Desktop/RecipeApp`
- ✅ `ContentView.swift` updated with tabs and FAB
- ✅ `Constants.swift`, `Theme.swift`, `Extensions.swift` created
- ✅ `RecipeApp.swift` created with splash + onboarding

---

## 📋 Step-by-Step Setup (15 minutes)

### Step 1: Add Models to Xcode

1. **Open Xcode** (if not already open)
   ```
   File → Open → Select /Users/kaantoksoy/Desktop/RecipeApp/RecipeApp.xcodeproj
   ```

2. **Create Models folder**
   - Right-click on `RecipeApp` (blue folder icon) in left sidebar
   - Select `New Group`
   - Name it `Models`

3. **Add Model files** (one by one)
   - Right-click on `Models` folder → `New File` → `Swift File`
   - Name: `Recipe.swift`
   - Copy code from `ALL_SOURCE_CODE.md` (Recipe.swift section)
   - Paste into the new file

4. **Repeat for all models:**
   - `Ingredient.swift`
   - `Instruction.swift`
   - `NutritionInfo.swift`
   - `GroceryItem.swift`
   - `MealPlan.swift`

---

### Step 2: Update RecipeApp.swift

1. **Find and open** `RecipeApp.swift` in Xcode
2. **Delete** the old Item.swift file if it exists
3. **Replace** RecipeApp.swift content with version from `ALL_SOURCE_CODE.md`

---

### Step 3: Create ViewModels

Create folder and files:
- RecipeViewModel.swift
- RecipeFormViewModel.swift
- GroceryListViewModel.swift

(Code provided in ALL_SOURCE_CODE.md)

---

### Step 4: Create Services

Create folder and files:
- RecipeRepository.swift
- OCRService.swift
- RecipeParserService.swift
- ImageGenerationService.swift
- GroceryCategorizer.swift

---

### Step 5: Create Simple Views (for testing)

Create `Views` folder with these subfolders:
- **Splash/** → SplashView.swift
- **Onboarding/** → OnboardingView.swift
- **Home/** → HomeView.swift (simple version)
- **Profile/** → ProfileView.swift (simple version)
- **Components/** → EmptyStateView.swift

---

### Step 6: Build & Test

1. **Clean Build Folder**
   ```
   Shift + Cmd + K
   ```

2. **Build**
   ```
   Cmd + B
   ```

3. **Run**
   ```
   Cmd + R
   ```

---

## 🎯 Minimum Working Version (10 Minutes)

To get a working app ASAP, here's the absolute minimum:

### Required Files:
1. **Utils** (Already done ✅)
   - Constants.swift
   - Theme.swift
   - Extensions.swift

2. **Models** (6 files)
   - All from ALL_SOURCE_CODE.md

3. **One Simple View**
   - Create `SplashView.swift`:
   ```swift
   import SwiftUI

   struct SplashView: View {
       var body: some View {
           ZStack {
               LinearGradient(
                   colors: [.orange, .green],
                   startPoint: .topLeading,
                   endPoint: .bottomTrailing
               )
               .ignoresSafeArea()

               VStack {
                   Image(systemName: "fork.knife.circle.fill")
                       .font(.system(size: 100))
                       .foregroundColor(.white)

                   Text("RecipeVault")
                       .font(.system(size: 42, weight: .bold))
                       .foregroundColor(.white)
               }
           }
       }
   }
   ```

4. **Temporary ContentView** - Replace with simple version:
   ```swift
   import SwiftUI
   import SwiftData

   struct ContentView: View {
       @Query private var recipes: [Recipe]

       var body: some View {
           NavigationStack {
               VStack {
                   Text("RecipeVault")
                       .font(.largeTitle.bold())

                   Text("\(recipes.count) recipes")
                       .foregroundColor(.secondary)

                   Spacer()

                   Text("🍳")
                       .font(.system(size: 100))

                   Text("Ready to cook!")
                       .font(.title2)

                   Spacer()
               }
               .navigationTitle("Home")
           }
       }
   }
   ```

5. **Update RecipeApp.swift** - Simplified version:
   ```swift
   import SwiftUI
   import SwiftData

   @main
   struct RecipeApp: App {
       var sharedModelContainer: ModelContainer = {
           let schema = Schema([
               Recipe.self,
               Ingredient.self,
               Instruction.self,
               GroceryItem.self,
               MealPlan.self
           ])
           let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

           do {
               return try ModelContainer(for: schema, configurations: [modelConfiguration])
           } catch {
               fatalError("Could not create ModelContainer: \(error)")
           }
       }()

       var body: some Scene {
           WindowGroup {
               ContentView()
           }
           .modelContainer(sharedModelContainer)
       }
   }
   ```

---

## ✨ Next Steps (After Basic Version Works)

Once you have the basic app running:

1. **Add full Views** from the complete source code
2. **Add ViewModels** for state management
3. **Add Services** for OCR and features
4. **Test all features** one by one

---

## 🐛 Troubleshooting

### "Cannot find 'Recipe' in scope"
- Make sure all Model files are added to the target
- Click file → Right sidebar → Target Membership → Check `RecipeApp`

### "Cannot find 'AppIcon' in scope"
- Make sure `Constants.swift` is added to project

### "Cannot find '.primaryOrange' in scope"
- Make sure `Theme.swift` is added to project

### Build succeeds but crashes on launch
- Check `RecipeApp.swift` has correct ModelContainer setup
- All 5 models must be in Schema array

---

## 📦 Complete Source Available

All complete source code is in:
- `ALL_SOURCE_CODE.md` - All models, views, services
- Check `/Users/kaantoksoy/Desktop/recipe_app_swiftui/` for original files

---

## 🎉 You're Ready!

Once you complete Step 1-2 (Models + RecipeApp.swift), you'll have a working foundation.
Then gradually add more features!

**Happy Coding! 👨‍🍳**
