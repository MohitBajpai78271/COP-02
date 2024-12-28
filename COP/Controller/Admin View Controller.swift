//
//  Admin View Controller.swift
//  ConstableOnPatrol
//
//  Created by Mac on 11/07/24.

import UIKit
import Alamofire

class AdminViewController: UIViewController{
    
    @IBOutlet weak var tableView: CustomTableView!
    private var searchController =  UISearchController(searchResultsController: nil)
    var activeUsers: [ActiveUser] = []
    var filteredActiveUsers : [ActiveUser] = []
    let session = Alamofire.Session.default
    private var searchBar = UISearchBar()
    
    let emptyStateView = UIView()
    let messageLabel = UILabel()
    let reloadButton = UIButton(type: .system)

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Admin"
        navigationController?.navigationBar.prefersLargeTitles = true
        tableView.contentInsetAdjustmentBehavior = .automatic
        filteredActiveUsers = activeUsers
        setupReloadButton()
        setupTableView()
        setupEmptyStateView()
        configureSearchController()
        fetchActiveUsers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.prefersLargeTitles = true
//        navigationItem.largeTitleDisplayMode = .automatic
        // Ensure the search controller is configured each time the view appears
//        configureSearchController()
        
//        searchController.obscuresBackgroundDuringPresentation = false
//        searchController.hidesNavigationBarDuringPresentation = false // Keep the navigation bar visible
    }

    func setupEmptyStateView() {
        emptyStateView.frame = tableView.bounds
        emptyStateView.isHidden = true
        emptyStateView.backgroundColor = .systemBackground
        
        messageLabel.text = "No active users available at the moment."
        messageLabel.textAlignment = .center
        messageLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        emptyStateView.addSubview(messageLabel)
        NSLayoutConstraint.activate([
            messageLabel.centerYAnchor.constraint(equalTo: emptyStateView.centerYAnchor, constant: -20),
            messageLabel.leadingAnchor.constraint(equalTo: emptyStateView.leadingAnchor, constant: 20),
            messageLabel.trailingAnchor.constraint(equalTo: emptyStateView.trailingAnchor, constant: -20),
    ])
    
        view.addSubview(emptyStateView)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
    }

    
    private func setupReloadButton() {
        let reloadButton = UIButton(type: .system)
        reloadButton.setTitle("Reload", for: .normal)
        reloadButton.setTitleColor(.white, for: .normal)
        reloadButton.backgroundColor = UIColor.systemBlue
        reloadButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        reloadButton.layer.cornerRadius = 8
        reloadButton.clipsToBounds = true

        reloadButton.addTarget(self, action: #selector(reloadTableViewTapped), for: .touchUpInside)
        reloadButton.sizeToFit()
        reloadButton.frame.size.width += 20

        let barButtonItem = UIBarButtonItem(customView: reloadButton)
        self.navigationItem.rightBarButtonItem = barButtonItem
    }

       @objc private func reloadTableViewTapped() {
           fetchActiveUsers()
       }
    
    func setupTableView(){
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register( MessageCell.self ,forCellReuseIdentifier: K.messageCell )
        tableView.tableHeaderView = searchController.searchBar
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        tableView.allowsSelection = true
        tableView.delaysContentTouches = false
        tableView.bounces = false
        
    }
    private func configureSearchController() {
//        searchBar.delegate = self
//        searchBar.sizeToFit() // Make sure the search bar fits well
//        searchBar.placeholder = "Search for the userName"
//        tableView.tableHeaderView = searchBar
//        
//        // Add tap gesture recognizer to dismiss keyboard when tapping outside the search bar
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
//        tapGesture.cancelsTouchesInView = false // Allow touches to pass through to table view cells
//        tableView.addGestureRecognizer(tapGesture)
        
              searchController.searchResultsUpdater = self
              searchController.obscuresBackgroundDuringPresentation = false
              searchController.searchBar.placeholder = "Search users"
              definesPresentationContext = true
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true) // Dismiss the keyboard for any active text field
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // Resign the first responder (dismiss the keyboard) when the "Search" button is tapped
        searchBar.resignFirstResponder()
        
        // You can perform any additional actions here, like starting a search, even if the search bar is empty.
        print("Search button tapped")
    }

  //  MARK: - Fetch ActiveUsersData
    
    func fetchActiveUsers() {
        showLoadingView2(tableView: tableView)
        
        fetchActiveUserData { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let activeUsers):
                    print("Received active users data: \(activeUsers.count) users")
                    if self.activeUsers.count != activeUsers.count {
                        self.activeUsers = activeUsers
                        self.filteredActiveUsers = activeUsers
                        print("Updated active users count: \(self.activeUsers.count)")
                    }
                        self.emptyStateView.isHidden = !self.activeUsers.isEmpty
                        self.tableView.reloadData()
                        self.dismissLoadingView2()
                case .failure(let error):
                    self.dismissLoadingView()
                    print("Failed to fetch active users: \(error)")
                }
            }
        }
    }
    
    func fetchActiveUserData(completion: @escaping (Result<[ActiveUser], Error>) -> Void) {
        let url = "\(ApiKeys.baseURL2)/api/active-Users"
        let request = AF.request(url, method: .get)
        
        request.responseData { response in
            print("AF running")
//            if let data = response.data {
//                print("Raw response data: \(String(data: data, encoding: .utf8) ?? "Unable to convert data to string")")
//            }
            switch response.result {
            case .success(let data):
                do {
                    let activeUsers = try JSONDecoder().decode([ActiveUser].self, from: data)
                    print("JSON decoding succeeded, active users count: \(activeUsers.count)")
                    completion(.success(activeUsers))
                } catch {
                    print("JSON decoding failed: \(error)")
                    completion(.failure(error))
                }
                
            case .failure(let error):
                print("Request failed with error: \(error)")
                completion(.failure(error))
            }
        }
    }
}
    //MARK: - TableView

extension AdminViewController: UITableViewDataSource,UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("filteredActiveUsers count: \(filteredActiveUsers.count)")
        return filteredActiveUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: K.messageCell, for: indexPath) as? MessageCell else {
            return UITableViewCell()
        }
        cell.selectionStyle = .default
        let activeUser = filteredActiveUsers[indexPath.row]
        cell.nameLabel.text = activeUser.name
        cell.phoneNumberLabel.text = activeUser.mobileNumber
        cell.placeLabel.text = "Area: \(activeUser.areas.joined(separator: ", "))"
        if let startTime = activeUser.dutyStartTime,let endTime = activeUser.dutyEndTime{
            cell.startTimeLabel.text = "Start Time: \(String(describing: startTime))"
            cell.endTimeLabel.text = "End Time: \(String(describing: endTime))"
        }else{
            cell.startTimeLabel.text = "Start Time : null"
            cell.endTimeLabel.text = "End Time : null"
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(cellTapped(_:)))
        cell.addGestureRecognizer(tapGesture)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    @objc func cellTapped(_ gesture: UITapGestureRecognizer) {
        guard let cell = gesture.view as? MessageCell,
              let indexPath = tableView.indexPath(for: cell) else { return }
        
        let selectedUser  = filteredActiveUsers[indexPath.row]
        let phoneNumber = selectedUser.mobileNumber
        let userName = selectedUser.name
        let startTime = selectedUser.dutyStartTime ?? ""
        let endTime = selectedUser.dutyEndTime ?? ""
        
        fetchUserLocation(phoneNumber: phoneNumber,userName : userName,startTime : startTime,endTime : endTime) { [weak self] result in
            switch result {
            case .success(let locationData):
                DispatchQueue.main.async {
                    self?.performSegue(withIdentifier: K.segueToLocation, sender: locationData)
                }
            case .failure(let error):
                print("Error fetching location: \(error)")
            }
        }
    }
    
    func fetchUserLocation(phoneNumber: String,userName : String,startTime : String,endTime : String,completion: @escaping (Result<LocationOfUser, Error>) -> Void) {
        let url = "\(ApiKeys.locnUrl)"
        print(url)
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        let parameters: [String: Any] = ["phoneNumber": phoneNumber]
        
        session.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default).responseData { response in
            switch response.result {
            case .success(let data):
                do {
                    var locationData = try JSONDecoder().decode(LocationOfUser.self, from: data)
                    print("success")
                    print(locationData)
                    locationData.name = userName
                    locationData.startTime = startTime
                    locationData.endTime = endTime
                    
                    completion(.success(locationData))
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                self.showToast(message: "User location service is disabled", duration: 3)
                completion(.failure(error))
            }
        }
    }
    
    func showLocationOnMap(locationData: LocationOfUser) {
        print("Location data: \(locationData)")
        self.performSegue(withIdentifier: "segueToLocation", sender: locationData)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueToLocation" {
            if let destinationVC = segue.destination as? LocationViewController,
               let locationData = sender as? LocationOfUser {
                destinationVC.locationData = locationData
                destinationVC.phoneNumber = locationData.phoneNumber
                destinationVC.name = locationData.name
                destinationVC.startTime = locationData.startTime
                destinationVC.endTime = locationData.endTime
            }
        }
    }

}

    class CustomTableView: UITableView {
        override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
            if self.isDragging || self.isDecelerating {
                return nil
            }
            return super.hitTest(point, with: event)
        }
    }

//MARK: -  Filter Active Users

//extension AdminViewController: UISearchResultsUpdating, UISearchBarDelegate {
//    func updateSearchResults(for searchController: UISearchController) {
//        guard let filter = searchController.searchBar.text, !filter.isEmpty else {
//            filteredActiveUsers = activeUsers
//            tableView.reloadData()
//            return
//        }
//        filteredActiveUsers = activeUsers.filter { $0.name.lowercased().contains(filter.lowercased()) }
//        tableView.reloadData()
//    }
//
//    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
//        filteredActiveUsers = activeUsers
//        tableView.reloadData()
//    }
//}
extension AdminViewController: UISearchBarDelegate {
//    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
//        view.endEditing(true) // Dismiss keyboard when search button is clicked
//    }
//    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        filteredActiveUsers = activeUsers
        tableView.reloadData()
        view.endEditing(true) // Dismiss keyboard when cancel button is clicked
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard !searchText.isEmpty else {
            filteredActiveUsers = activeUsers
            tableView.reloadData()
            return
        }
        filteredActiveUsers = activeUsers.filter { $0.name.lowercased().contains(searchText.lowercased()) }
        tableView.reloadData()
    }
}

extension AdminViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchText = searchController.searchBar.text ?? ""
        
        if searchText.isEmpty {
            filteredActiveUsers = activeUsers
        } else {
            filteredActiveUsers = activeUsers.filter {
                $0.name.lowercased().contains(searchText.lowercased())
            }
        }
        tableView.reloadData()
    }
}
extension AdminViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        // Allow the gesture to work only when the touch is outside the search bar
        if touch.view is UISearchBar {
            return false
        }
        return true
    }
}
