//
//  Admin View Controller.swift
//  ConstableOnPatrol
//
//  Created by Mac on 11/07/24.

import UIKit
import Alamofire

class AdminViewController: UIViewController{
    
    @IBOutlet weak var tableView: CustomTableView!
    
    var activeUsers: [ActiveUser] = []
    var filteredActiveUsers : [ActiveUser] = []
    let session = Alamofire.Session.default
    
    let emptyStateView = UIView()
    let messageLabel = UILabel()
    let reloadButton = UIButton(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Admin"
        
        self.navigationController?.navigationBar.prefersLargeTitles = true
        
        configureSearchController()
        filteredActiveUsers = activeUsers
        
        setupTableView()
        fetchActiveUsers()
//        setupConstraints()
        
        setupEmptyStateView()
    }
    
    func setupEmptyStateView() {
        // Configure empty state view
        emptyStateView.frame = tableView.bounds
        emptyStateView.isHidden = true
        emptyStateView.backgroundColor = .systemBackground
        
        // Configure message label
        messageLabel.text = "No active users available at the moment."
        messageLabel.textAlignment = .center
        messageLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Configure reload button
        reloadButton.setTitle("Reload", for: .normal)
        reloadButton.setTitleColor(.white, for: .normal)
        reloadButton.backgroundColor = .systemBlue
        reloadButton.layer.cornerRadius = 20
        reloadButton.layer.masksToBounds = true
        reloadButton.addTarget(self, action: #selector(reloadButtonTapped), for: .touchUpInside)
        reloadButton.translatesAutoresizingMaskIntoConstraints = false
        
        
        // Add label and button to the empty state view
        emptyStateView.addSubview(messageLabel)
        emptyStateView.addSubview(reloadButton)
        
        // Add constraints for label and button
        NSLayoutConstraint.activate([
            messageLabel.centerYAnchor.constraint(equalTo: emptyStateView.centerYAnchor, constant: -20),
            messageLabel.leadingAnchor.constraint(equalTo: emptyStateView.leadingAnchor, constant: 20),
            messageLabel.trailingAnchor.constraint(equalTo: emptyStateView.trailingAnchor, constant: -20),
            
            reloadButton.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),
            reloadButton.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 20),
            reloadButton.widthAnchor.constraint(equalToConstant: 150),
            reloadButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    
        view.addSubview(emptyStateView)
    }
    
    @objc func reloadButtonTapped() {
        fetchActiveUsers()
    }
    
    func setupTableView(){
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register( MessageCell.self ,forCellReuseIdentifier: K.messageCell )
        tableView.allowsSelection = true
        tableView.delaysContentTouches = false
        tableView.bounces = false
        
    }
    
    func configureSearchController() {
        let searchController = UISearchController()
        searchController.searchResultsUpdater = self
        searchController.searchBar.placeholder = "Search for a username"
        searchController.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController = searchController
    }
//    
    //MARK: - Constraints
    
    private func setupConstraints() {
        
    }
    
  //  MARK: - Fetch ActiveUsersData
    
        func fetchActiveUsers() {
    
            fetchActiveUserData { [weak self] result in
                guard let self = self else{return}
                DispatchQueue.main.async {
                    switch result {
                    case .success(let activeUsers):
                        print("Received active users data: \(activeUsers)")
                        self.activeUsers = activeUsers
                        self.filteredActiveUsers = activeUsers
                        print("Active users count: \(self.activeUsers.count)")
    
                        if self.activeUsers.isEmpty {
                            print("show  runs")
                            self.emptyStateView.isHidden = false
                            return
                            }
    
                        self.tableView.reloadData()
    
                    case .failure(let error):
                        print("Failed to fetch active users: \(error)")
                        // Handle error, show alert, etc.
                    }
                }
    
            }
        }

    func fetchActiveUserData(completion: @escaping (Result<[ActiveUser], Error>) -> Void) {
        let url =  "   "
    
        AF.request(url, method: .get).responseData{ response in
            if let data = response.data {
                print("Raw response data: \(String(data: data, encoding: .utf8) ?? "Unable to convert data to string")")
            }
    
            switch response.result {
            case .success(let data):
                do {
                    let activeUsers = try JSONDecoder().decode([ActiveUser].self, from: data)
                    completion(.success(activeUsers))
                } catch {
                    print("JSON decoding failed: \(error)")
                    completion(.failure(error))
                }
            case .failure(let error):
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
        cell.startTimeLabel.text = "Start Time: \(activeUser.dutyStartTime)"
        cell.endTimeLabel.text = "End Time: \(activeUser.dutyEndTime)"
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(cellTapped(_:)))
        cell.addGestureRecognizer(tapGesture)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    @objc func cellTapped(_ gesture: UITapGestureRecognizer) {
        let indexPath = tableView.indexPath(for: gesture.view as! MessageCell)!
        let selectedUser = activeUsers[indexPath.row]
        self.performSegue(withIdentifier: K.segueToLocation, sender: selectedUser.mobileNumber)
    }
    
    func fetchUserLocation(phoneNumber: String, completion: @escaping (Result<LocationOfUser, Error>) -> Void) {
        let url = "  "
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        let parameters: [String: Any] = ["phoneNumber": phoneNumber]
        
        session.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default).responseData { response in
            switch response.result {
            case .success(let data):
                do {
                    let locationData = try JSONDecoder().decode(LocationOfUser.self, from: data)
                    print("success")
                    completion(.success(locationData))
                } catch {
                    print("Error decoding location data: \(error)")
                    completion(.failure(error))
                }
            case .failure(let error):
                if (error as NSError).code == NSURLErrorTimedOut {
                                print("Request timed out. Please try again later.")
                            } else {
                                print("Failed to fetch location data: \(error)")
                            }
                            completion(.failure(error))
            }
        }
    }
    
    func showLocationOnMap(locationData: LocationOfUser) {
        print("Location data: \(locationData)")
        self.performSegue(withIdentifier: "segueToLocation", sender: locationData)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.segueToLocation {
            if let destinationVC = segue.destination as? LocationViewController,
               let phoneNumber = sender as? String {
                destinationVC.phoneNumber = phoneNumber
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

extension AdminViewController: UISearchResultsUpdating, UISearchBarDelegate{
   
    func updateSearchResults(for searchController: UISearchController) {
       guard let filter = searchController.searchBar.text,!filter.isEmpty else{
           filteredActiveUsers = activeUsers
           tableView.reloadData()
           return
       }
        filteredActiveUsers = activeUsers.filter{ $0.name.lowercased().contains(filter.lowercased())}
        tableView.reloadData()
     }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        filteredActiveUsers = activeUsers
        tableView.reloadData()
    }
    
}
