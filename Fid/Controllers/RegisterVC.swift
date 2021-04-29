//
//  RegisterVC.swift
//  Fid
//
//  Created by CROCODILE on 15.01.2021.
//

import UIKit
import Toaster
import Firebase
import GoogleSignIn
import CryptoKit
import AuthenticationServices
import ProgressHUD
import RealmSwift
import FBSDKLoginKit
import FBSDKCoreKit

class RegisterVC: UIViewController {

    @IBOutlet weak var loginProviderStackView: UIStackView!
    @IBOutlet weak var credentialBtn: UIButton!
    @IBOutlet weak var signupBtn: UIButton!
    @IBOutlet weak var skipBtn: UIButton!
    @IBOutlet weak var googleLogginView: UIView!
    @IBOutlet weak var facebookLoginView: UIView!
    @IBOutlet weak var backImg: UIImageView!
    @IBOutlet weak var backBtn: UIButton!
    
    // MARK: - Properties
    var currentNonce: String!
    var appleLogin = 0
    
    let fbLoginManager = LoginManager()
    
    private var person: Person!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        GIDSignIn.sharedInstance()?.presentingViewController = self
        self.setupProviderLoginView()
        
        self.loginProviderStackView.layer.cornerRadius = self.loginProviderStackView.frame.size.height / 2
        self.loginProviderStackView.layer.masksToBounds = true
        self.credentialBtn.layer.cornerRadius = self.credentialBtn.frame.size.height / 2
        self.credentialBtn.layer.masksToBounds = true
        self.signupBtn.layer.cornerRadius = self.signupBtn.frame.size.height / 2
        self.signupBtn.layer.masksToBounds = true
        self.skipBtn.layer.cornerRadius = self.skipBtn.frame.size.height / 2
        self.skipBtn.layer.masksToBounds = true
        self.googleLogginView.layer.cornerRadius = self.googleLogginView.frame.size.height / 2
        self.googleLogginView.layer.masksToBounds = true
        self.facebookLoginView.layer.cornerRadius = self.facebookLoginView.frame.size.height / 2
        self.facebookLoginView.layer.masksToBounds = true
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(gestureRecognizer)
        gestureRecognizer.cancelsTouchesInView = false
        
        self.loadPersonFromRealm()
    }
    
    func setupBackBtn() {
        
        if FidHelper.shared.goBackRegister {
            self.backImg.isHidden = false
            self.backBtn.isHidden = false
        } else {
            self.backBtn.isHidden = true
            self.backImg.isHidden = true
        }
        let back = UIImage(named: "back")
        backImg.image = back?.withRenderingMode(.alwaysTemplate)
        backImg.tintColor = UIColor(hexString: "#27bdb1")
    }
    
    //---------------------------------------------------------------------------------------------------------------------------------------------
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupBackBtn()
    }
    
    override func viewWillDisappear(_ animated: Bool) {

        super.viewWillDisappear(animated)
        self.appleLogin = 0
        dismissKeyboard()
        
        FidHelper.shared.goBackRegister = false
    }
    
    //---------------------------------------------------------------------------------------------------------------------------------------------
    func loadPersonFromRealm() {

        person = realm.object(ofType: Person.self, forPrimaryKey: AuthUser.userId())
    }

    //---------------------------------------------------------------------------------------------------------------------------------------------
    @objc func dismissKeyboard() {

        view.endEditing(true)
    }
            
    func setupProviderLoginView() {
        let authorizationButton = ASAuthorizationAppleIDButton()
        authorizationButton.addTarget(self, action: #selector(loginWithApple), for: .touchUpInside)
        self.loginProviderStackView.addArrangedSubview(authorizationButton)
    }
    
    // MARK: - IBActions
    
    @IBAction func goback(_ sender: Any) {
        self.performSegue(withIdentifier: "main", sender: self)
    }
    
    @IBAction func signupAction(_ sender: Any) {
        self.performSegue(withIdentifier: "create_profile", sender: self)
    }
    
    @IBAction func loginWithCredential(_ sender: Any) {
        
        let alert = UIAlertController(title: "צור/י חשבון", message: nil, preferredStyle: .alert)

        alert.addTextField { (textField) in
            textField.placeholder = "אימייל"
            textField.textAlignment = .right
        }
        alert.addTextField { (textField) in
            textField.placeholder = "סיסמה"
            textField.isSecureTextEntry = true
            textField.textAlignment = .right
        }
        
        alert.addAction(UIAlertAction(title: "ביטול", style: .default, handler: nil))

        alert.addAction(UIAlertAction(title: "אישור", style: .default, handler: { [weak alert] (_) in
            let username = alert?.textFields![0]
            let password = alert?.textFields![1]
            
            if username?.text?.count == 0 {
                Toast(text: "Please Enter Email").show()
                alert?.dismiss(animated: true, completion: nil)
                return
            } else if !(username?.text?.isValidEmail)! {
                Toast(text: "אימייל לא תקין").show()
                alert?.dismiss(animated: true, completion: nil)
                return
            }
            
            if password?.text?.count == 0 {
                Toast(text: "Please Enter Password").show()
                alert?.dismiss(animated: true, completion: nil)
                return
            }
                 
            let email = (username?.text)!
            let passwordtxt = (password?.text)!
            
            IJProgressView.shared.showProgressView()
            self.actionLogin(email: email, password: passwordtxt)
        }))
                
        self.present(alert, animated: true, completion: nil)
    }
    
    func updateUserInfoLogin() {
        
        Toast(text: "הרשמה בוצעה בהצלחה").show()
        if let _ = defaults.string(forKey: "firstStart") {
            self.performSegue(withIdentifier: "main", sender: self)
        } else {
            self.performSegue(withIdentifier: "select_card", sender: self)
        }
        defaults.setValue("true", forKey: "firstStart")
        defaults.setValue(false, forKey: "logout")
    }
    
    func updateUserInfoRegister(username: String, password: String) {
        
        defaults.setValue("true", forKey: "firstStart")
        defaults.setValue(username, forKey: "userName")
        defaults.setValue(password, forKey: "password")
        Toast(text: "הרשמה בוצעה בהצלחה").show()
        defaults.setValue(false, forKey: "logout")
                        
        self.performSegue(withIdentifier: "select_card", sender: self)
        
        self.loadUsername()
    }
    
    // MARK: - Create Person's info
    
    //---------------------------------------------------------------------------------------------------------------------------------------------
    func actionLogin(email: String, password: String) {
        
        AuthUser.signIn(email: email, password: password) { error in
            IJProgressView.shared.hideProgressView()
            if let error = error {
                ProgressHUD.showError(error.localizedDescription)
                return
            } else {
                self.loadPerson(email: email)
                self.updateUserInfoLogin()
            }
        }
    }
    
    //---------------------------------------------------------------------------------------------------------------------------------------------
    func actionRegister(email: String, password: String, firstname: String, lastname: String) {

        AuthUser.signUp(email: email, password: password) { error in
            IJProgressView.shared.hideProgressView()
            if let error = error {
                ProgressHUD.showError(error.localizedDescription)
            } else {
                self.createPerson(email: email, firstname: firstname, lastname: lastname, img: false)
                self.updateUserInfoRegister(username: email, password: password)
            }
        }
    }

    // MARK: -
    //---------------------------------------------------------------------------------------------------------------------------------------------
    
    func checkUserExist(email: String, completion: @escaping (_ exist: Bool) -> Void) {
        FireFetcher.checkPersonExist(email) { error in
                                    
            if (error != nil) {
                completion(false)
            } else {
                completion(true)
            }
        }
    }
    
    func loadPerson(email: String) {

        let userId = AuthUser.userId()
        FireFetcher.fetchPerson(userId) { error in
                                    
            if (error != nil) {
                return
            }
            
            Users.loggedIn()
        }
    }
    
    //---------------------------------------------------------------------------------------------------------------------------------------------
    func createPerson(email: String, firstname: String, lastname: String, img: Bool) {

        let userId = AuthUser.userId()
        Persons.create(userId, email: email, firstname: firstname, lastname: lastname, img: img)
        
        Users.loggedIn()
    }
    
    //---------------------------------------------------------------------------------------------------------------------------------------------
    func savePerson(firstname: String, lastname: String) {
                
        let country = "Israel"
        let location = "Moscow"
        let phone = "123456789"

        let realm = try! Realm()
        try! realm.safeWrite {
            person.firstname = firstname
            person.lastname    = lastname
            person.fullname    = "\(firstname) \(lastname)"
            person.country = country
            person.location    = location
            person.phone = phone
            person.syncRequired = true
            person.updatedAt = Date().timestamp()
        }
    }
    
    // MARK: - Google login
        
    @IBAction func loginWithGoogle(_ sender: Any) {
        
        FidHelper.shared.signedOut()
        GIDSignIn.sharedInstance().signIn()
    }
    
    // MARK: - Facebook login
    
    @IBAction func loginWithFacebook(_ sender: Any) {
        
        AuthUser.logOut()
        
        fbLoginManager.logOut()
        let cookies = HTTPCookieStorage.shared
        let facebookCookies = cookies.cookies(for: URL(string: "https://facebook.com/")!)
        for cookie in facebookCookies! {
            cookies.deleteCookie(cookie )
        }
        
        fbLoginManager.logIn(permissions: ["public_profile", "email"], from: self) { (result, error) in
            if let error = error {
                ProgressHUD.showError(error.localizedDescription)
            } else if (result?.isCancelled)! {
                debugPrint("FB Login cancelled")
            } else {
                let credential = FacebookAuthProvider.credential(withAccessToken: (AccessToken.current?.tokenString)!)
                
                self.firebaseLogin(credential, appleLoggedIn: false, googleLogin: false, faebookLogin: true, apple_credential: nil)
            }
        }
    }
    
    func getProfileInfoFromFB(completion: @escaping (_ status: Bool) -> Void) {
        // Facebook graph request to retrieve the user email & name
        let token = AccessToken.current?.tokenString
        let params = ["fields": "first_name, last_name, email"]
        let graphRequest = GraphRequest(graphPath: "me", parameters: params, tokenString: token, version: nil, httpMethod: .get)
        graphRequest.start { (connection, result, error) in

            if let err = error {
                print("Facebook graph request error: \(err)")
                completion(false)
            } else {
                print("Facebook graph request successful!")

                guard let json = result as? NSDictionary else { return }
                if let email = json["email"] as? String {
                    print("\(email)")
                    defaults.setValue(email, forKey: "social_email_facebook")
                }
                if let firstName = json["first_name"] as? String {
                    print("\(firstName)")
                    defaults.setValue(firstName, forKey: "social_firstname")
                }
                if let lastName = json["last_name"] as? String {
                    print("\(lastName)")
                    defaults.setValue(lastName, forKey: "social_lastname")
                }
                if let id = json["id"] as? String {
                    print("\(id)")
                }
                
                completion(true)
            }
        }
    }
    
    @objc func loginWithApple() {
        
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]

        // Generate nonce for validation after authentication successful
        self.currentNonce = randomNonceString()
        // Set the SHA256 hashed nonce to ASAuthorizationAppleIDRequest
        request.nonce = sha256(currentNonce!)

        // Present Apple authorization form
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    @IBAction func skipAction(_ sender: Any) {
                        
        if let _ = defaults.string(forKey: "firstStart") {
            defaults.setValue("true", forKey: "firstStart")
            defaults.setValue(false, forKey: "logout")
            performSegue(withIdentifier: "main", sender: self)
        } else {
            defaults.setValue("true", forKey: "firstStart")
            defaults.setValue(false, forKey: "logout")
            performSegue(withIdentifier: "select_card", sender: self)
        }
    }
    
    // MARK: - Private methods
    
    func loadUsername() {
        var username = "Not Registered"
        var password = ""
        if defaults.string(forKey: "userName") != nil {
            username = defaults.string(forKey: "userName")!
        }
        if defaults.string(forKey: "password") != nil {
            password = defaults.string(forKey: "password")!
        }
        
        let param = ["password": password, "username": username]
                
        APIHandler.AFPostRequest_LoadUserName(url: ServerURL.sever_url_insert, param: param)
    }
    
    func firebaseLogin(_ credential: AuthCredential, appleLoggedIn: Bool, googleLogin: Bool, faebookLogin: Bool, apple_credential: ASAuthorizationAppleIDCredential?) {

        IJProgressView.shared.showProgressView()
        Auth.auth().signIn(with: credential) { (user, error) in
            
            if let error = error {
                Toast(text: error.localizedDescription).show()
                IJProgressView.shared.hideProgressView()
                return
            } else {
                
                if appleLoggedIn {
                    
                    if let email = defaults.string(forKey: "social_email_apple") {
                        
                        self.checkUserExist(email: email) { exist in
                            IJProgressView.shared.hideProgressView()
                            if exist {
                                self.loadPerson(email: email)
                                self.updateUserInfoLogin()
                            } else {
                                guard let firstname = defaults.string(forKey: "social_firstname") else { return }
                                guard let lastname = defaults.string(forKey: "social_lastname") else { return }
                                self.createPerson(email: email, firstname: firstname, lastname: lastname, img: false)
                                self.updateUserInfoRegister(username: email, password: "apple")
                            }
                        }
                    } else {
                        IJProgressView.shared.hideProgressView()
                        ProgressHUD.showError("You have ever logged in with this account before. Please remove login info from phone in setting.")
                    }
                } else if googleLogin {
                    
                    if let gmail = defaults.string(forKey: "social_email_google") {
                        
                        self.checkUserExist(email: gmail) { exist in
                            IJProgressView.shared.hideProgressView()
                            if exist {
                                self.loadPerson(email: gmail)
                                self.updateUserInfoLogin()
                            } else {
                                guard let firstname = defaults.string(forKey: "social_firstname") else { return }
                                guard let lastname = defaults.string(forKey: "social_lastname") else { return }
                                
                                self.createPerson(email: gmail, firstname: firstname, lastname: lastname, img: false)
                                self.updateUserInfoRegister(username: gmail, password: "google")
                            }
                        }
                    } else {
                        IJProgressView.shared.hideProgressView()
                    }
                } else if faebookLogin {
                    self.getProfileInfoFromFB() { status in
                        if !status {
                            ProgressHUD.showError("You can't get user info now.")
                            IJProgressView.shared.hideProgressView()
                            return
                        }
                        
                        if let facebook = defaults.string(forKey: "social_email_facebook") {
                            
                            self.checkUserExist(email: facebook) { exist in
                                IJProgressView.shared.hideProgressView()
                                if exist {
                                    self.loadPerson(email: facebook)
                                    self.updateUserInfoLogin()
                                } else {
                                    guard let firstname = defaults.string(forKey: "social_firstname") else { return }
                                    guard let lastname = defaults.string(forKey: "social_lastname") else { return }
                                    
                                    self.createPerson(email: facebook, firstname: firstname, lastname: lastname, img: false)
                                    self.updateUserInfoRegister(username: facebook, password: "google")
                                }
                            }
                        } else {
                            IJProgressView.shared.hideProgressView()
                        }
                    }
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "main" {
            let _ = segue.destination as! SideBarVC
        }
    }

}

// MARK: - Apple login

extension RegisterVC: ASAuthorizationControllerDelegate {
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        
        print("apple login")
        
        Toast(text: "Welcome Apple login").show()
        
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            
            if defaults.string(forKey: "appleAuthorizedUserIdKey") == nil {
                defaults.set(appleIDCredential.user, forKey: "appleAuthorizedUserIdKey")
            }
                        
            if let email = appleIDCredential.email {
                Toast(text: "Successfully I got apple email.").show()
                defaults.setValue(email, forKey: "social_email_apple")
            } else {
                Toast(text: "We can't get apple email.").show()
            }
            
            if let firstname = appleIDCredential.fullName?.givenName {
                defaults.setValue(firstname, forKey: "social_firstname")
            }
            
            if let lastname = appleIDCredential.fullName?.familyName {
                defaults.setValue(lastname, forKey: "social_lastname")
            }
                                    
            // Retrieve the secure nonce generated during Apple sign in
            guard let nonce = self.currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }

            // Retrieve Apple identity token
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Failed to fetch identity token")
                return
            }

            // Convert Apple identity token to string
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Failed to decode identity token")
                return
            }

            // Initialize a Firebase credential using secure nonce and Apple identity token
            let firebaseCredential = OAuthProvider.credential(withProviderID: "apple.com",
                                                              idToken: idTokenString,
                                                              rawNonce: nonce)
           
            // Sign in with Firebase
            self.firebaseLogin(firebaseCredential, appleLoggedIn: true, googleLogin: false, faebookLogin: false, apple_credential: appleIDCredential)
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("apple login error is \(error.localizedDescription)")
        print("authorization error")
        guard let error = error as? ASAuthorizationError else {
            return
        }

        switch error.code {
        case .canceled:
            // user press "cancel" during the login prompt
            print("Canceled")
            Toast(text: "Apple login cancelled").show()
        case .unknown:
            // user didn't login their Apple ID on the device
            print("Unknown")
            Toast(text: "Apple login unknown").show()
        case .invalidResponse:
            // invalid response received from the login
            print("Invalid Respone")
            Toast(text: "Apple login invalid response").show()
        case .notHandled:
            // authorization request not handled, maybe internet failure during login
            print("Not handled")
            Toast(text: "Apple login handled").show()
        case .failed:
            // authorization failed
            print("Failed")
            Toast(text: "Apple login failed").show()
        @unknown default:
            print("Default")
        }
    }
}

extension RegisterVC: ASAuthorizationControllerPresentationContextProviding {
    /// - Tag: provide_presentation_anchor
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}

extension RegisterVC {
    
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: Array<Character> =
            Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        
        return result
    }

    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            return String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
}
