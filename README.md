# 📚 StudyWithMe

A social **iOS study collaboration app** that helps students organize study sessions, connect with friends, and study together.

Built with **SwiftUI**, **Supabase**, and **MVVM architecture**, StudyWithMe focuses on modern iOS development practices including asynchronous networking, reactive UI updates, and scalable architecture.

---

# 🎥 Demo Videos

### 📱 Application Demo


https://github.com/user-attachments/assets/995ccda7-3858-4aeb-a86c-2b1d743b7d6e

https://github.com/user-attachments/assets/b4bfb40d-1f01-448d-919c-64652d2395b5


https://github.com/user-attachments/assets/bc23ae54-0ac6-430c-ab5f-055076f6e9f0


https://github.com/user-attachments/assets/bbcce33f-8357-4af3-ac56-2d04f8ec8523




# ✨ Features

## 🧠 Study Sessions
- Create and manage study sessions
- Edit or delete sessions if you are the host
- Join or leave study sessions
- Real-time participant counts
- Track open vs closed sessions

## 👥 Friends System
- Discover and add friends
- View your friends list
- Connect with other students easily

## 💬 Messaging
- Direct messaging between users
- Automatic conversation creation
- Persistent chat history

## 👤 User Profiles
- Secure authentication using Supabase
- User profile information
- Avatar support with Supabase Storage

## 📅 Session Details
- Subject tagging
- Study session scheduling
- Location details
- Organized study session cards

---


---

# 📱 Application Screens

<p align="center">
<img width="260" src="https://github.com/user-attachments/assets/7cefd577-6144-4b78-948b-e23a759c34ff"/>
<img width="260" src="https://github.com/user-attachments/assets/764dcca5-42b8-48bf-bfe9-f3c77aad76fc"/>
<img width="260" src="https://github.com/user-attachments/assets/9f055b6e-0e47-4fd2-ade0-ebb3f039f122"/>
</p>
---
<p align="center">
<img width="260" src="https://github.com/user-attachments/assets/139a5d34-d44f-4c72-8737-0040885b7a02"/>
<img width="260" src="https://github.com/user-attachments/assets/25f5ca76-88e7-4981-ba2b-f3ee752c7312"/>
<img width="260" src="https://github.com/user-attachments/assets/1d9d8f54-b349-4dd3-9fed-73a4d9961e56"/>
</p>

---

<p align="center">
<img width="260" src="https://github.com/user-attachments/assets/c86e67aa-3a36-4cf6-8467-bc1da8f7af88"/>
<img width="260" src="https://github.com/user-attachments/assets/508a88b1-f009-47f2-9585-c24ab6682496"/>
<img width="260" src="https://github.com/user-attachments/assets/a0ccca2b-1daf-4ac2-b396-4ef5fd36b158"/>
</p>
---
<p align="center">
<img width="260" src="https://github.com/user-attachments/assets/d7f9b054-102a-47ce-b291-5f3585f2fe50"/>
<img width="260" src="https://github.com/user-attachments/assets/74678bdf-ffe6-4be2-9fac-3bd885e21347"/>
</p>
---
<p align="center">
<img width="260" src="https://github.com/user-attachments/assets/e75bb0d6-6ece-4f0b-b7a4-2227d5113a1d"/>
<img width="260" src="https://github.com/user-attachments/assets/fd66fa6b-e4d6-4639-99ed-08eda8326c4b"/>
<img width="260" src="https://github.com/user-attachments/assets/14b1a2ec-83b0-4b2a-8310-9ef54035c86c"/>
</p>
---
<p align="center">
<img width="260" src="https://github.com/user-attachments/assets/de15b38c-37e7-4fb0-8405-40cb416264b6"/>
<img width="260" src="https://github.com/user-attachments/assets/2055093f-7bd9-4c88-9335-54e8c68fb0e5"/>
<img width="260" src="https://github.com/user-attachments/assets/a63c37ad-8e87-4944-a360-2542e1434ad8"/>
</p>
---
<p align="center">
<img width="260" src="https://github.com/user-attachments/assets/7caafdca-733a-4157-a0e9-740ba01fa887"/>
<img width="260" src="https://github.com/user-attachments/assets/5af54f90-3d9c-4b79-bf17-d4c7e9a7c6da"/>
<img width="260" src="https://github.com/user-attachments/assets/babf0723-63c4-4a4e-b475-80cc2943f3aa"/>
</p>
---
<p align="center">
<img width="260" src="https://github.com/user-attachments/assets/2c000b8d-8222-4f7d-987f-1cffa04da052"/>
<img width="260" src="https://github.com/user-attachments/assets/ba2eb657-30eb-45f6-bb11-e9fccac6841f"/>
<img width="260" src="https://github.com/user-attachments/assets/f317be69-db84-4cf1-b6ea-1b085c3f1ad7"/>
<img width="260" src="https://github.com/user-attachments/assets/7d99ebc9-29c2-4e92-a267-758cb82e34d9"/>
</p>
---

# 🏗 Architecture

This project follows the **MVVM (Model-View-ViewModel)** architecture pattern.

```
Views
   ↓
ViewModels
   ↓
Services
   ↓
Supabase Backend
```

### Why MVVM?

✅ Separation of UI and business logic  
✅ Easier testing  
✅ Reactive UI updates with `@Published`  
✅ Scalable codebase for future features  

---

# 🛠 Tech Stack

## 📱 iOS
- Swift
- SwiftUI
- MVVM Architecture
- Combine
- Async / Await Concurrency

## ☁ Backend
- Supabase
- PostgreSQL
- Supabase Authentication
- Supabase Storage

## 🔧 Tools
- Xcode
- Git / GitHub
- XCTest

---

# 🧪 Testing

Basic **unit tests** are implemented using **XCTest** to validate ViewModel behavior.

Example components tested:

- Session loading
- State updates
- Error handling
- ViewModel initialization

---

# 🔮 Future Improvements

- 🔔 Push notifications
- 👥 Group study sessions
- 📅 Calendar integration
- 🔎 Search & filtering sessions
- 🧑‍🎓 Enhanced user profiles
- 📊 Study analytics

---

# 🎯 Learning Goals

This project was built to practice:

- Modern **SwiftUI architecture**
- **MVVM design patterns**
- **Backend integration with Supabase**
- **Async networking**
- Building scalable mobile applications

---
