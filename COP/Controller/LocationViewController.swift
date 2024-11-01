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
    var polygonColors = [MKPolygon: UIColor]()
    var locationPolygons = [String: MKPolygon]()
    
    var coordinatesAlipur: [LatLon] = []
    var coordinatesBawana : [LatLon] = []
    var coordinatesBhalswa : [LatLon] = []
    var coordinatesNarela: [LatLon] = []
    var coordinatesNIA: [LatLon] = []
    var coordinatesSamaypur: [LatLon] = []
    var coordinatesSwaroop: [LatLon] = []
    var coordinatesShahbad: [LatLon] = []
    

    override func viewDidLoad() {
        super.viewDidLoad()
        print(phoneNumber ?? "no phone number in location, popat")
        print(locationData?.latitude ?? "000")
        print(locationData?.longitude ?? "000")
        MapView.delegate = self
        checkLocation()
        displayAllRegions()
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
    
    
    func displayAllRegions() {
        coordinatesAlipur = loadCSV(from: Places.crimesLocation[0])
        coordinatesNIA = loadCSV(from: Places.crimesLocation[4])
        coordinatesNarela = loadCSV(from: Places.crimesLocation[3])
        coordinatesShahbad = loadCSV(from: Places.crimesLocation[6])
        coordinatesSamaypur = loadCSV(from: Places.crimesLocation[5])
        coordinatesBhalswa = loadCSV(from: Places.crimesLocation[2])
        coordinatesBawana = loadCSV(from: Places.crimesLocation[1])
        coordinatesSwaroop = loadCSV(from: Places.crimesLocation[7])
        
        setMapViewBoundaries(for: coordinatesAlipur, color: UIColor.white)
        setMapViewBoundaries(for: coordinatesNIA, color: UIColor(red: 65/255, green: 105/255, blue: 225/255, alpha: 1.0))
        setMapViewBoundaries(for: coordinatesNarela, color: UIColor(red: 34/255, green: 139/255, blue: 34/255, alpha: 1.0))
        setMapViewBoundaries(for: coordinatesShahbad, color: UIColor(red: 255/255, green: 99/255, blue: 71/255, alpha: 1.0))
        setMapViewBoundaries(for: coordinatesSamaypur, color: UIColor(red: 128/255, green: 0/255, blue: 128/255, alpha: 1.0))
        setMapViewBoundaries(for: coordinatesBhalswa, color: UIColor(red: 60/255, green: 179/255, blue: 113/255, alpha: 1.0))
        setMapViewBoundaries(for: coordinatesBawana, color: UIColor(red: 218/255, green: 165/255, blue: 32/255, alpha: 1.0))
        setMapViewBoundaries(for: coordinatesSwaroop, color: UIColor(red: 255/255, green: 20/255, blue: 147/255, alpha: 1.0))

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
             
             let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
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
    
    func setMapViewBoundaries(for coordinates: [LatLon], color: UIColor) {
        guard !coordinates.isEmpty else {
            return
        }
        var coords = [CLLocationCoordinate2D]()
        var minLatitude = Double.greatestFiniteMagnitude
        var maxLatitude = Double.leastNormalMagnitude
        var minLongitude = Double.greatestFiniteMagnitude
        var maxLongitude = Double.leastNormalMagnitude

        for coord in coordinates {
            let lat = coord.latitude
            let lon = coord.longitude
            coords.append(CLLocationCoordinate2D(latitude: lat, longitude: lon))
            minLatitude = min(minLatitude, lat)
            maxLatitude = max(maxLatitude, lat)
            minLongitude = min(minLongitude, lon)
            maxLongitude = max(maxLongitude, lon)
        }
        let polygon = ColoredPolygon(coordinates: &coords, count: coords.count)
        polygon.color = color
        MapView.addOverlay(polygon)

        let centerLatitude = (minLatitude + maxLatitude) / 2
        let centerLongitude = (minLongitude + maxLongitude) / 2
        let spanLatitude = (maxLatitude - minLatitude) * 1.1
        let spanLongitude = (maxLongitude - minLongitude) * 1.1

        let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: centerLatitude, longitude: centerLongitude), span: MKCoordinateSpan(latitudeDelta: spanLatitude, longitudeDelta: spanLongitude))
        MapView.setRegion(region, animated: true)
    }
    
    func loadCSV(from csvName: String) -> [LatLon] {
        var csvToStruct = [LatLon]()
        
        guard let filePath = Bundle.main.path(forResource: csvName, ofType: "csv") else {
            return []
        }
        
        do {
            let data = try String(contentsOfFile: filePath)
            let rows = data.components(separatedBy: "\n")

            for row in rows {
                let csvColumns = row.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                if csvColumns.count == 2,
                   let lat = Double(csvColumns[0]),
                   let lon = Double(csvColumns[1]) {
                   let latLonStruct = LatLon(latitude: lat, longitude: lon)
                    csvToStruct.append(latLonStruct)
                }
            }
        } catch {
            print("Error reading CSV file: \(error)")
        }
        
        return csvToStruct
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polygonOverlay = overlay as? ColoredPolygon,
           let color = polygonOverlay.color {
            let renderer = MKPolygonRenderer(polygon: polygonOverlay)
            renderer.strokeColor = color
            renderer.lineWidth = 2
            renderer.fillColor = color.withAlphaComponent(0.2)
            return renderer
        } else {
            let renderer = MKPolygonRenderer(polygon: overlay as! MKPolygon)
            renderer.strokeColor = UIColor.black
            renderer.lineWidth = 2
            renderer.fillColor = UIColor.black.withAlphaComponent(0.2)
            return renderer
        }
    }
}
    

