//
//  LocationViewController.swift
//  COP
//
//  Created by Mac on 25/07/24.
//

import UIKit
import MapKit
import Alamofire

class LocationViewController: UIViewController, MKMapViewDelegate{
    
    @IBOutlet weak var MapView: MKMapView!
    @IBOutlet weak var locationLabel: UILabel!
    
    var phoneNumber : String?
    var locationData: LocationOfUser?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(phoneNumber ?? "no phone number in location, popat")
        print(locationData?.latitude ?? "000")
        print(locationData?.longitude ?? "000")
        MapView.delegate = self
        checkLocation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    func checkLocation(){
        if let locationData = locationData {
            showLocationOnMap(locationData: locationData)
        }else{
            print("No Location data available!")
        }
    }
    
     
     func decodeLocationData(_ data: Data) {
         do {
             let location = try JSONDecoder().decode(LocationOfUser.self, from: data)
             self.showLocationOnMap(locationData: location)
         } catch {
             print("Failed to decode location data: \(error)")
         }
     }
     
     func showLocationOnMap(locationData: LocationOfUser) {
         let coordinate = CLLocationCoordinate2D(latitude: locationData.latitude!, longitude: locationData.longitude!)
         
         if CLLocationCoordinate2DIsValid(coordinate) {
             let annotation = MKPointAnnotation()
             annotation.coordinate = coordinate
             annotation.title = "User Location"
             MapView.addAnnotation(annotation)
             
             let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
             MapView.setRegion(region, animated: true)
         } else {
             print("Invalid coordinates: \(coordinate)")
         }
     }
     
     func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
         let identifier = K.locationIdentifier
         
         if annotation is MKPointAnnotation {
             var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
             
             if annotationView == nil {
                 annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                 annotationView?.canShowCallout = true
             } else {
                 annotationView?.annotation = annotation
             }
             
             return annotationView
         }
         
         return nil
     }
    
    }
    

