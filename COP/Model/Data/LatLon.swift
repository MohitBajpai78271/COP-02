import Foundation
struct LatLon {
    var latitude: Double
    var longitude: Double
    
    // If you have a custom initializer that takes an array of strings,
    // you might need to update it or remove it if not necessary.
    init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
}
