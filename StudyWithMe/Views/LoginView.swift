import SwiftUI

struct LoginView: View {
    // Hardcoded values for now
    @State private var email: String = ""
    @State private var password: String = ""
    
    @State private var loggedIn: Bool = false;
    
    func validateLoginInformation() -> Bool {
        if email == "johndoe@gmail.com" && password == "apples123" {
            print("Login successful")
            return true;
        } else {
            print("Login failed")
            return false;
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(){
                Text("Login")
                
                TextField("Email", text: $email)
                    .textFieldStyle(.roundedBorder)
                    .textInputAutocapitalization(.never)
                
                
                SecureField("Password", text: $password)
                    .textFieldStyle(.roundedBorder)
                    .textInputAutocapitalization(.never)
                
                Button("Sign in") {
                    if validateLoginInformation() == true {
                        loggedIn = true
                        print("isLoggedin: " + String(loggedIn))
                    }
                    
                    
                }
                .navigationDestination(isPresented: $loggedIn){
                    HomeView();
                }
                
            }
        }
        // Hide the back button
        .navigationBarBackButtonHidden(true)
        
        
    }
    
}

#Preview {
    LoginView()
}
