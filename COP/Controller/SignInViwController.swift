//
//  SignInViwController.swift
//  ConstableOnPatrol
//
//  Created by Mac on 10/07/24.
//

import UIKit

class SignInViwController: UIViewController{
    
    @IBOutlet weak var MoblineNoTextField: UITextField!
    @IBOutlet weak var GenerateOTPView: UIButton!
    private var isAlertPresented = false
    let alertHelper = AlertManager.shared
    
    var numberIsCorrect : Bool = false
    
    let authService = AuthService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTextField()
        GenerateOTPView.tintColor = UIColor.lightGray
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden = false
    }
    
    @IBAction func signUpButtonTapped(_ sender: UIButton) {
        if let navController = self.navigationController {
            let signupVC = storyboard?.instantiateViewController(withIdentifier: K.signupView) as! SignUpViewController
                navController.pushViewController(signupVC, animated: true)
            }
    }
    
    func setupTextField(){
        MoblineNoTextField.delegate = self
        MoblineNoTextField.autocorrectionType = .no
        MoblineNoTextField.keyboardType = .numberPad
    }
     
    @IBAction func GenerateOTPPressed(_ sender: UIButton) {
        guard let phoneNumber = MoblineNoTextField.text, !phoneNumber.isEmpty else {
            alertHelper.showAlert(on: self, message: "Phone number cannot be empty")
            return
        }
        
        let fullphoneNumber : String = "+91\(MoblineNoTextField.text!)"
        
        KeychainHelper.shared.save(phoneNumber, for: Ud.userPn)
        
        UserData.shared.isSignup = false
        AuthService.shared.getOTP(phoneNumber: fullphoneNumber) { response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.alertHelper.showAlert(on: self, message: "Failed to generate OTP: \(error.localizedDescription)")
                    return
                }
                
                if response != nil {
                    UserData.shared.isSignup = false
//                    self.alertHelper.showAlert(on: self, message: response.message)
//                    if response .message == "OTP sent successfully"  {
                        self.performSegue(withIdentifier: K.signinSegue, sender: fullphoneNumber)
//                    }  else {
//                        self.alertHelper.showAlert(on: self, message:  "No response received or data couldn't be decoded")
//                    }
                }
            }
            
        }
    }
    
    @objc func dismissKeyboard(){
        view.endEditing(true)
    }

}


extension SignInViwController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        let updatedText = (currentText as NSString).replacingCharacters(in: range, with: string)
        
        let textWithoutSpaces = updatedText.replacingOccurrences(of: " ", with: "")
        if textWithoutSpaces.count == 10 && textWithoutSpaces.rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil {
            GenerateOTPView.tintColor = UIColor.blue
            numberIsCorrect = true
        } else {
            GenerateOTPView.tintColor = UIColor.gray
        }
        
        return true
    }
}
