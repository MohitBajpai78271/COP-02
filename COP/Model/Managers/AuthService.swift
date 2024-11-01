import UIKit
import Alamofire

class AuthService{
    
    static let shared = AuthService()
    private let session = URLSession.shared
    private let storage = UserDefaults.standard
    
     public let userDefaults = UserDefaults.standard
    public let signedInKey = K.isSignedIn
    
     public init() {}
     
     var isSignedIn: Bool {
         get {
             return userDefaults.bool(forKey: signedInKey)
         }
         set {
             userDefaults.set(newValue, forKey: signedInKey)
         }
     }
    
    //MARK: - Get OTP
    
    func getOTP(phoneNumber: String,completion: @escaping(OTPResponse?, Error?)->Void){
        let urlString = "\(ApiKeys.baseURL)/api/send-otp"
        let parameters: [String: Any] = ["phoneNumber": phoneNumber]
        
        AF.request(urlString, method: .post, parameters: parameters, encoding: JSONEncoding.default)
            .responseDecodable(of: OTPResponse.self) { response in
                if let data = response.data {
                    print("Raw Response Data: \(String(data: data, encoding: .utf8) ?? "No Data")")
                    do {
                        let otpResponse = try JSONDecoder().decode(OTPResponse.self, from: data)
                        completion(otpResponse, nil)
                    } catch let decodeError {
                        completion(nil, decodeError)
                    }
                } else {
                    completion(nil, NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data in response"]))
                }
            }
    }
  
    //MARK: - Verify OTP
    
    func verifyOtp(phoneNumber: String, otp: String, isSignUp: Bool,context : UIViewController,showLogoutAlert : (() -> Void)? = nil , completion: @escaping (Result<Void, Error>) -> Void) {
               let endpoint = isSignUp ? "/api/verify-otp" : "/api/verify-otp-signIn"
               guard let url = URL(string: "\(ApiKeys.baseURL)\(endpoint)") else {
               completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
               return
    }
          
          var request = URLRequest(url: url)
          request.httpMethod = "POST"
          request.addValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")
          
          let body = ["phoneNumber": phoneNumber, "otp": otp]
          request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
          
          let task = session.dataTask(with: request) { data, response, error in
              if let error = error {
                  completion(.failure(error))
                  return
              }
              
              guard let response = response as? HTTPURLResponse else {
                  completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid Response"])))
                  return
              }
              
              if let data = data {
                         // Print raw response data for debugging
                         print("Response data: \(String(describing: String(data: data, encoding: .utf8)))")
                         
                         do {
                             if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                                 
                                 if let success = jsonResponse["success"] as? Bool, !success,
                                                   let msg = jsonResponse["msg"] as? String, msg == "User already logged in" {
                                                    DispatchQueue.main.async {
                                                        showLogoutAlert?()
                                            }
                                                    return
                                    }
                                 
                                 if let userRole = jsonResponse["userRole"] as? String {
                                     UserDefaults.standard.set(userRole, forKey: Ud.userRole)
                                 }
                                 if let token = jsonResponse["token"] as? String {
                                     UserDefaults.standard.set(token, forKey: Ud.token)
                                 }
                                 if let userName = jsonResponse["userName"] as? String {
                                     UserDefaults.standard.set(userName, forKey: Ud.userName)
                                 }
                                 if let dateOfBirth = jsonResponse["dateOfBirth"] as? String {
                                     UserDefaults.standard.set(dateOfBirth, forKey: Ud.dob)
                                 }
                                 if let address = jsonResponse["address"] as? String {
                                     UserDefaults.standard.set(address, forKey: Ud.address)
                                 }
                                 if let phoneNumber = jsonResponse["phoneNumber"] as? String{
                                     UserDefaults.standard.set(phoneNumber, forKey: Ud.pn)
                                 }
                                 
                             }
                         } catch {
                             print("Failed to parse response data: \(error.localizedDescription)")
                         }
                     }
                     
              switch response.statusCode {
              case 200:
                  completion(.success(()))
              case 401:
                  let error = NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "Invalid OTP or unauthorized"])
                  completion(.failure(error))
              case 409:
                       let error = NSError(domain: "", code: 409, userInfo: [NSLocalizedDescriptionKey: "User already exists. Try logging in h."])
                       completion(.failure(error))
              default:
                  let error = NSError(domain: "", code: response.statusCode, userInfo: [NSLocalizedDescriptionKey: "Unexpected server response"])
                  completion(.failure(error))
              }
          }
          task.resume()
     }    
    
    func existingUser(phoneNumber: String, otp: String, completion: @escaping (OTPResponse?, Error?) -> Void) {
        let url = URL(string: "\(ApiKeys.baseURL)/api/verify-otp-signIn")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let parameters: [String: String] = ["phoneNumber": phoneNumber, "otp": otp]
        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let data = data else {
                completion(nil, NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data in response"]))
                return
            }
            
            do {
                let otpResponse = try JSONDecoder().decode(OTPResponse.self, from: data)
                completion(otpResponse, nil)
            } catch {
                completion(nil, error)
            }
        }
        
        task.resume()
    }
    
    //MARK: - LogOut
    
    func logOut(phoneNumber: String, context: UIViewController) {
        let alertController = UIAlertController(title: "Logout", message: "Are you sure you want to logout?", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            print(phoneNumber)
            guard let url = URL(string: "\(ApiKeys.baseURL)/api/logout") else {
                return
            }
            
            var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10)
            request.httpMethod = "POST"
            
            do {
                request.httpBody = try JSONEncoder().encode(["phoneNumber": phoneNumber])
            } catch {
                print("Failed to encode phone number: \(error)")
                return
            }
            
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            if let token = UserDefaults.standard.string(forKey: Ud.token) {
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    DispatchQueue.main.async {
                        self.showSnackBar(context: context, message: "Failed to log out: \(error.localizedDescription)")
                    }
                    return
                }
                
                if let response = response as? HTTPURLResponse {
                    print("Response Status Code: \(response.statusCode)")
                    print("Response Headers: \(response.allHeaderFields)")
                    if let data = data, let responseBody = String(data: data, encoding: .utf8) {
                        print("Response Body: \(responseBody)")
                    }
                    if response.statusCode == 200 {
                        UserDefaults.standard.removeObject(forKey: Ud.token)
                        UserDefaults.standard.removeObject(forKey: Ud.userPn)
                        UserDefaults.standard.removeObject(forKey: Ud.userRole)
                        UserDefaults.standard.removeObject(forKey: Ud.signupPn)
                        UserDefaults.standard.removeObject(forKey: Ud.userName)
                        UserDefaults.standard.removeObject(forKey: Ud.dob)
                        UserDefaults.standard.removeObject(forKey: Ud.address)
                        UserDefaults.standard.removeObject(forKey: Ud.pn)
                        UserDefaults.standard.set(false, forKey: Ud.isLoggedIn)
                        UserDefaults.standard.synchronize()
                        
                        DispatchQueue.main.async {
                             let storyboard = UIStoryboard(name: "Main", bundle: nil)
                             let signInVC = storyboard.instantiateViewController(withIdentifier: K.signinView)
                             let navController = UINavigationController(rootViewController: signInVC)
                             navController.modalPresentationStyle = .fullScreen
                             context.present(navController, animated: true, completion: nil)
                            self.showSnackBar(context: context, message: "User logged out successfully")
                         }                    }else {
                        DispatchQueue.main.async {
                            self.showSnackBar(context: context, message: "Failed to log out: Server responded with status code \(response.statusCode)")
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        self.showSnackBar(context: context, message: "Failed to log out: Invalid server response")
                    }
                }
            }.resume()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        context.present(alertController, animated: true, completion: nil)
    }

    //MARK: - ShowSnackBar
    
      func showSnackBar(context: UIViewController, message: String) {
            let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            alertController.view.backgroundColor = .black
            alertController.view.alpha = 0.5
            alertController.view.layer.cornerRadius = 15
            
            context.present(alertController, animated: true) {
                DispatchQueue.main.asyncAfter(deadline:.now() + 2) {
                    alertController.dismiss(animated: true, completion: nil)
                }
            }
        }
    
    //MARK: - Create User
    
    func createUser(context: UIViewController, userName: String, phoneNumber: String, dateOfBirth: String, gender: String, address: String, completion: @escaping () -> Void) {
        
        let url = URL(string: "\(ApiKeys.baseURL)/users/user-token")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")
        
        // Creating the user dictionary
        let user: [String: Any] = [
            "userRole": "",
            "id": "",
            "token": "",    
            "userName": userName,
            "phoneNumber": phoneNumber,
            "gender": gender,
            "address": address,
            "dateOfBirth": dateOfBirth
        ]
        
        // Convert the dictionary to JSON data
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: user, options: [])
        } catch {
            DispatchQueue.main.async {
                self.showSnackBar(context: context, message: "Failed to create user request body")
            }
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // Check for network errors
            if let error = error {
                DispatchQueue.main.async {
                    self.showSnackBar(context: context, message: "Network error: \(error.localizedDescription)")
                }
                return
            }
            
            // Check for valid response
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                DispatchQueue.main.async {
                    self.showSnackBar(context: context, message: "Failed to create user. Status code: \((response as? HTTPURLResponse)?.statusCode ?? -1)")
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    self.showSnackBar(context: context, message: "No data received from server")
                }
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    if let token = json["token"] as? String, let userRole = json["userRole"] as? String  {
                        

                        UserDefaults.standard.set(token, forKey: Ud.token)
                        UserDefaults.standard.set(userRole, forKey: Ud.userRole)
                        
                        DispatchQueue.main.async {
                            self.showSnackBar(context: context, message: "User created successfully")
                            completion()
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.showSnackBar(context: context, message: "Token not found in response")
                        }
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.showSnackBar(context: context, message: "Failed to parse create user response: \(error.localizedDescription)")
                }
            }
        }
        
        task.resume()
        }
    //MARK: - UpdateData
    
    func updateUser(context: UIViewController, phoneNumber: String, userName: String, address: String, dateOfBirth: String, completion: @escaping (Result<Void, Error>) -> Void) {
        
        guard let token = UserDefaults.standard.string(forKey: Ud.token) else {
            showSnackBar(context: context, message: "No token found")
            return
        }

        let url = URL(string: "\(ApiKeys.baseURL)/update-userdata")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")
        request.setValue(token, forHTTPHeaderField: Ud.token)

        let updateData: [String: Any] = [
            "phoneNumber": phoneNumber,
            "userName": userName,
            "address": address,
            "dateOfBirth": dateOfBirth
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: updateData, options: [])
        } catch {
            completion(.failure(error))
            return
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "", code: -1, userInfo: nil)))
                }
                return
            }

            if httpResponse.statusCode == 200 {
                print("done successfully")
            } else {
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "", code: httpResponse.statusCode, userInfo: nil)))
                }
            }
        }

        task.resume()
    }

    }


extension Dictionary {
    func toJsonData() -> Data? {
        return try? JSONSerialization.data(withJSONObject: self, options: [])
    }
}
