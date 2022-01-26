//
//  GeofenceDatabase.swift
//  GeofenceTest
//
//  Created by Davi Chaves on 1/26/22.
//

import UIKit
import CoreLocation

class GeofenceDatabase: NSObject {
    
    struct GeofenceObject {
        var id: String
        var radius: Double
        var latitude: Double
        var longitude: Double
    }
    
    public var geofenceStarters: [GeofenceObject] = []

    override init() {
        geofenceStarters = [
            GeofenceObject(id: "1", radius: 1000, latitude: 37.335, longitude: -122.084058),
            GeofenceObject(id: "2", radius: 1000, latitude: 37.422, longitude: -122.011),
            GeofenceObject(id: "3", radius: 1000, latitude: 37.42882, longitude: -122.16991),
        ]
    }
}
