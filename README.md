# Prestigo

Prestigo is a smart travel planning application that generates personalized vacation plans based on the user’s budget.

Users enter how much they want to spend, and Prestigo creates a complete travel plan including flights, accommodation, and activities — all optimized to fit the given budget.

---

## ✨ Features

- 💰 Budget-based travel planning  
- ✈️ Flight suggestions within budget  
- 🏨 Hotel recommendations based on preferences  
- 🗺️ Activity and sightseeing suggestions  
- 🤖 Smart logic / AI-assisted recommendations (optional)  
- 📱 Clean and intuitive mobile user experience  

---

## 🧠 How It Works

1. User enters their total travel budget  
2. User selects basic preferences (destination, dates, travel style, etc.)  
3. Prestigo:
   - Allocates budget across flights, hotels, and activities
   - Generates a balanced and realistic travel plan
4. The user receives a full vacation overview in one place

---

## 🛠 Tech Stack

- **SwiftUI**
- **Swift Concurrency (async/await)**
- **MVVM-style architecture**
- **Firebase** (optional: authentication, analytics, data storage)
- **AI-powered logic** for itinerary and recommendation generation (optional)

---

## 🔐 Security & Configuration

This repository follows real-world security best practices.

Sensitive configuration files are intentionally **excluded from version control**, including:

- `GoogleService-Info.plist`
- API keys and environment-specific configuration files

Secrets are managed locally and are never committed to the repository.

---

## 🔥 Firebase Setup (Optional)

Firebase can be used for features such as user accounts, saved trips, or analytics.

To enable Firebase:

1. Create a Firebase project
2. Register an iOS app with your bundle identifier
3. Download `GoogleService-Info.plist`
4. Add it to the Xcode project
5. Ensure the file is **not committed to Git**

---

## ▶️ Running the App

1. Clone the repository
2. Open the project in Xcode
3. Add required local configuration files (if needed)
4. Run on Simulator or physical device

The app is designed to run even if optional services are not configured.

---

## 📌 Notes

- Prestigo focuses on user-centric travel planning rather than raw search results
- The goal is to simplify vacation decisions into a single, budget-aware flow
- The project is designed with scalability and future feature expansion in mind

---

## 📄 License

This project is developed for educational, portfolio, and experimental purposes.
