import SwiftUI

private var welcomeText = "Welcome to study with me!"
private var buttonText = "Get started"


struct WelcomeView: View {
    @State private var goToLogin = false;
    
    var body: some View {
        NavigationStack(){
            VStack {
                Text(welcomeText);
                Button("Get started"){
                    goToLogin = true;
                }
                .padding()
            }
            
            /*
             Go to login page when goToLogin button is pressed
             Boolean turns to true to navigate to view
             */
            .navigationDestination(isPresented: $goToLogin){
                LoginView();
            }
        }
    }
}

 #Preview {
     WelcomeView()
 }

