# MatchMate

MatchMate is a simple iOS app built with Swift and SwiftUI.  
It pulls random user profiles from [RandomUser.me](https://randomuser.me) and lets you swipe through them like a mini dating app — accept or decline, and everything is saved locally. The app works offline and syncs up automatically when you’re back online.

---

## Features
- Fetches user profiles from the API with Combine
- Nice card layout showing profile photo, name, age, and location
- Accept / Decline actions with persistent status
- Infinite scroll with pagination + pull to refresh
- Works offline with Core Data cache and syncs automatically
- Clean SwiftUI interface
- Handles network and database errors gracefully

---

## Architecture
- **MVVM** for separating UI and logic  
- **Repository pattern** for managing data sources  
- **Combine** for reactive updates between layers  
- Dependency injection to keep things testable and flexible  

---

## Tech & Libraries
- `URLSession` for networking  
- `Combine` for publishers/subscribers  
- `AsyncImage` for image loading & caching  

---

## Getting Started
1. Open the project in **Xcode 14+**
2. Run it on a simulator or device
3. Scroll through profiles and try Accept/Decline to see offline persistence in action  

---
