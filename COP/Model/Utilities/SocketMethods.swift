import Foundation
import SocketIO
import CoreLocation
import UIKit

public class SocketMethods: NSObject, CLLocationManagerDelegate {
    
    private var socketClient: SocketIOClient
    private var locationManager: CLLocationManager
    private var isUpdatingLocation = false
    static let shared = SocketMethods()
    
    override init() {
        let manager = SocketManager(socketURL: URL(string: "\(ApiKeys.baseURL)/")!, config: [.log(true), .compress])
        self.socketClient = manager.defaultSocket
        self.locationManager = CLLocationManager()
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 0
        setupSocketHandlers()
    }

    private func setupSocketHandlers() {
        socketClient.on(clientEvent: .connect) { data, ack in
            self.startLocationUpdates()
        }
        
        socketClient.on(clientEvent: .disconnect) { data, ack in
            print("Socket disconnected.")
            self.stopLocationUpdates()
        }
        
        socketClient.on(clientEvent: .error) { data, ack in
            print("Socket error: \(data)")
        }
    }
    
    func connectSocket() {
        if socketClient.status == .connected || socketClient.status == .connecting {
            print("Socket is already connected or connecting. Skipping connect call.")
            return
        }
        
        print("Attempting to connect socket...")
        socketClient.connect()
    }
    
    func disconnectSocket() {
        if socketClient.status == .connected {
            socketClient.disconnect()
            print("Socket disconnected.")
        } else {
            print("Socket is not connected. Current status: \(socketClient.status)")
        }
    }
    
    func startLocationUpdates() {
        guard CLLocationManager.locationServicesEnabled() else {
            print("Location services are disabled.")
            return
        }
        print("Requesting location authorization...")
        locationManager.requestWhenInUseAuthorization()
    }

    public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            if !isUpdatingLocation {
                locationManager.startUpdatingLocation()
                isUpdatingLocation = true
                print("Location updates started.")
            }
        case .denied:
            print("Location authorization denied.")
        case .restricted:
            print("Location authorization restricted.")
        case .notDetermined:
            print("Location authorization not determined.")
        @unknown default:
            print("Unknown location authorization status.")
        }
    }

    func stopLocationUpdates() {
        if isUpdatingLocation {
            locationManager.stopUpdatingLocation()
            isUpdatingLocation = false
            print("Location updates stopped.")
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        print("Location updated: Latitude \(location.coordinate.latitude), Longitude \(location.coordinate.longitude)")
        
        let userId = UserDefaults.standard.string(forKey: Ud.userId)
        let phoneNumber = UserDefaults.standard.string(forKey: Ud.pn) ?? UserDefaults.standard.string(forKey: Ud.userPn)
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        
        if socketClient.status == .connected {
            print("Emitting location data to server...")
            socketClient.emit("sendLocation", ["userId": userId ?? "No userId", "phoneNumber": phoneNumber ?? "No phone Number", "lat": latitude, "long": longitude])
        } else {
            print("Socket not connected. Unable to emit location data. Current status: \(socketClient.status)")
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location update error: \(error.localizedDescription)")
    }
}
