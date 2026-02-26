import SwiftUI

@main
struct StudyWithMeApp: App {
    @StateObject private var authModel = AuthModel()
    
    var body: some Scene {
        WindowGroup {
            if authModel.isAuthenticated {
                HomeView()
                    .environmentObject(authModel)
            } else {
                LoginView()
                    .environmentObject(authModel)
            }
        }
    }
}

#Preview {
    
}
