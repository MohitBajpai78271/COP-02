//
//  ProfileViewController.swift
//  ConstableOnPatrol
//
//  Created by Mac on 12/07/24.
//

import UIKit
import Alamofire

class ProfileViewController: UIViewController, UITextFieldDelegate{
    
    @IBOutlet weak var UserName: UITextField!
    @IBOutlet weak var DateOfBirth: UITextField!
    @IBOutlet weak var MobileNo: UITextField!
    @IBOutlet weak var PoliceStation: UITextField!
    @IBOutlet weak var editView: UIButton!
    
    var buttonImageNames: [UIButton: String] = [:]
    let image1 = K.image1
    let image2 = K.image2
    let authService = AuthService()
    let doAlert = AlertManager.shared
    
    func setupButton() {
        let initialImage = UIImage(systemName: image1)
        editView.setImage(initialImage, for: .normal)
        buttonImageNames[editView] = image1

        editView.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.2)
        editView.layer.cornerRadius = 20
        editView.tintColor = .systemBlue
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        guard let currentImageName = buttonImageNames[editView] else {return}
        if currentImageName == image1{
            UserName.isUserInteractionEnabled = false
            DateOfBirth.isUserInteractionEnabled = false
            PoliceStation.isUserInteractionEnabled = false
            MobileNo.isUserInteractionEnabled = false
        }
        toggleButtonImage(to: image1, for: editView.self)
        UserName.isUserInteractionEnabled = false
        DateOfBirth.isUserInteractionEnabled = false
        PoliceStation.isUserInteractionEnabled = false 
        
    }
    
    let datePicker = UIDatePicker()
    let options = CrimesAndPoliceStations.policeStationPlace
    var pickerView : UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupInitialTexts()
        
        pickerView = UIPickerView()
        pickerView.delegate = self
        pickerView.dataSource = self
        MobileNo.keyboardType = .numberPad
        PoliceStation.inputView = pickerView
        
        setupButton()
        setupDatePicker()
      
        setupToolBar()
        setupImageViewBackground()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        
    }
    
    
    
    func setupImageViewBackground() {
        let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
        backgroundImage.image = UIImage(named: "MapView")
        backgroundImage.contentMode = .scaleAspectFill
        backgroundImage.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        backgroundImage.alpha = 0.2
        view.addSubview(backgroundImage)
        view.sendSubviewToBack(backgroundImage)
    }
    
    func setupToolBar(){
        let toolbar = UIToolbar()
               toolbar.sizeToFit()
               let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(donePressed))
               toolbar.setItems([doneButton], animated: true)
               PoliceStation.inputAccessoryView = toolbar
        
    }
    
    func setupInitialTexts(){
         UserName.addFloatingPlaceholder("Name Of Person")
         DateOfBirth.addFloatingPlaceholder("Date Of Birth")
         MobileNo.addFloatingPlaceholder("Mobile No")
         PoliceStation.addFloatingPlaceholder("Police Station")
         
         UserName.delegate = self
         DateOfBirth.delegate = self
         MobileNo.delegate = self
         PoliceStation.delegate = self
        
        
        if let userName = KeychainHelper.shared.retrieve(for: Ud.userName){
            UserName.text = userName
        }
        if let phoneNumberSignup = KeychainHelper.shared.retrieve(for: Ud.signupPn), !phoneNumberSignup.isEmpty{
            MobileNo.text = phoneNumberSignup
        }
        if let phoneNumber = KeychainHelper.shared.retrieve(for: Ud.pn), !phoneNumber.isEmpty {
            MobileNo.text = phoneNumber
        }
        if let dateOfBirth = KeychainHelper.shared.retrieve(for: Ud.dob){
            DateOfBirth.text = dateOfBirth
        }
        if let address = KeychainHelper.shared.retrieve(for: Ud.address){
            PoliceStation.text = address
        }
        
    
    }

    @IBAction func dropDownPressed(_ sender: UIButton) {
        PoliceStation.becomeFirstResponder()
    }
    
    @IBAction func editPressed(_ sender: UIButton) {
             guard let currentImageName = buttonImageNames[sender] else {return}
             
             if currentImageName == image1 {
                 toggleButtonImage(to: image2, for: sender)
                 enableTextFields(true)
                 showToast(message: "You can now edit the fields.", duration: 2.0)
             } else {
                 showAlertToSaveChanges()
                 toggleButtonImage(to: image1, for: sender)
                 enableTextFields(false)
             }
         }
    
    func setupDatePicker() {
         datePicker.datePickerMode = .date
         if #available(iOS 13.4, *) {
             datePicker.preferredDatePickerStyle = .wheels
         }
         DateOfBirth.inputView = datePicker
         DateOfBirth.inputAccessoryView = createToolbar()
     }

     
    func createToolbar() -> UIToolbar {
           let toolbar = UIToolbar()
           toolbar.sizeToFit()
           
           let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissPicker))
           let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
           toolbar.setItems([flexSpace, doneButton], animated: true)
           
           return toolbar
       }
    
    
    @objc func dismissPicker() {
          if DateOfBirth.isFirstResponder {
              let dateFormatter = DateFormatter()
              dateFormatter.dateFormat = "yyyy-MM-dd"
              DateOfBirth.text = dateFormatter.string(from: datePicker.date)
          }
          view.endEditing(true)
      }
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
           textField.resignFirstResponder()
           return true
       }
    @objc func donePressed() {
          PoliceStation.resignFirstResponder()
      }

      func numberOfComponents(in pickerView: UIPickerView) -> Int {
          return 1
      }

 
    func toggleButtonImage(to newImageName: String, for button: UIButton) {
          let newImage = UIImage(systemName: newImageName)
          button.setImage(newImage, for: .normal)
          buttonImageNames[button] = newImageName
      }

      func enableTextFields(_ enable: Bool) {
          UserName.isUserInteractionEnabled = enable
          DateOfBirth.isUserInteractionEnabled = enable
          MobileNo.isUserInteractionEnabled  = false
          PoliceStation.isUserInteractionEnabled = enable
      }

      func showAlertToSaveChanges() {
          let alert = UIAlertController(title: "Save Changes?", message: "Are you sure you want to save all changes?", preferredStyle: .alert)
          let okAction = UIAlertAction(title: "OK", style: .default) { _ in
              
              guard let phoneNumber = self.MobileNo.text, !phoneNumber.isEmpty,
                    let userName = self.UserName.text, !userName.isEmpty,
                    let address = self.PoliceStation.text, !address.isEmpty,
                    let dateOfBirth = self.DateOfBirth.text, !dateOfBirth.isEmpty else {
                  self.doAlert.showAlert(on: self, message: "Please fill in all fields")
                     return
                 }

              KeychainHelper.shared.save(phoneNumber, for: Ud.pn)
              KeychainHelper.shared.save(userName, for: Ud.userName)
              KeychainHelper.shared.save(address, for: Ud.address)
              KeychainHelper.shared.save(dateOfBirth, for: Ud.dob)
              
              self.authService.updateUser(context: self, phoneNumber: phoneNumber, userName: userName, address: address, dateOfBirth: dateOfBirth) { result in
                  DispatchQueue.main.async{
                  switch result {
                  case .success:
                      self.enableTextFields(false)
                  case .failure(let error):
                      print("Its a failure : \(error.localizedDescription)")
                  }
              }
              }
    }
          
          let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
              self.toggleButtonImage(to: self.image1, for: self.editView)
              self.enableTextFields(false)
          }

          alert.addAction(okAction)
          alert.addAction(cancelAction)

          present(alert, animated: true, completion: nil)
      }
    
}


extension ProfileViewController: UIPickerViewDelegate,UIPickerViewDataSource{
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return options.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return options[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        PoliceStation.text = options[row]
    }
}

extension UITextField {
    func addFloatingPlaceholder(_ placeholder: String) {
        let placeholderLabel = UILabel()
        placeholderLabel.text = placeholder
        placeholderLabel.font = UIFont.systemFont(ofSize: 16)
        placeholderLabel.textColor = .lightGray
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(placeholderLabel)

        NSLayoutConstraint.activate([
            placeholderLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            placeholderLabel.topAnchor.constraint(equalTo: topAnchor, constant: 0)
        ])

        if traitCollection.userInterfaceStyle == .dark {
            textColor = .white
        } else {
            textColor = .black
        }
        layer.borderWidth = 1
        layer.borderColor = UIColor.lightGray.cgColor
        backgroundColor = .systemBackground
        layer.cornerRadius = 16 
        layer.masksToBounds = true

        self.placeholder = ""

        addTarget(self, action: #selector(editingDidBegin), for: .editingDidBegin)
        addTarget(self, action: #selector(editingDidEnd), for: .editingDidEnd)
    }

    @objc private func editingDidBegin() {
        guard let placeholderLabel = subviews.compactMap({ $0 as? UILabel }).first else { return }
        UIView.animate(withDuration: 0.3) {
            placeholderLabel.textColor = .systemBlue
            self.layer.borderColor = UIColor.systemBlue.cgColor
        }
    }

    @objc private func editingDidEnd() {
        guard let placeholderLabel = subviews.compactMap({ $0 as? UILabel }).first else { return }
        UIView.animate(withDuration: 0.3) {
            placeholderLabel.textColor = .lightGray
            self.layer.borderColor = UIColor.lightGray.cgColor
        }
    }
}

