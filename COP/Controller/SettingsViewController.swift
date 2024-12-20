//
//  SettingsViewController.swift
//  ConstableOnPatrol
//
//  Created by Mac on 12/07/24.
//
import UIKit

class SettingsViewController: UIViewController{
    
    @IBOutlet weak var logOutOutlet: UIButton!
    
    let authService = AuthService()
    var phoneNumber: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backButtonTitle = "Back"
        setupLogout()
    }
    
    func setupLogout() {
        logOutOutlet.layer.borderColor = UIColor.black.cgColor
        logOutOutlet.layer.borderWidth = 2.0
        logOutOutlet.layer.cornerRadius = 10
        logOutOutlet.layer.masksToBounds = true
        
        logOutOutlet.backgroundColor = UIColor.systemRed
        logOutOutlet.setTitleColor(.white, for: .normal)
        logOutOutlet.layer.shadowColor = UIColor.black.cgColor
        logOutOutlet.layer.shadowOffset = CGSize(width: 0, height: 4)
        logOutOutlet.layer.shadowRadius = 4
        logOutOutlet.layer.shadowOpacity = 0.3
        logOutOutlet.layer.masksToBounds = false
        logOutOutlet.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        
    }


    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    @IBAction func logoutPressed(_ sender: UIButton) {
        phoneNumber = UserDefaults.standard.string(forKey: Ud.userPn) ?? UserDefaults.standard.string(forKey: Ud.signupPn)
        authService.logOut(phoneNumber: phoneNumber!, context: self)
    }
}
