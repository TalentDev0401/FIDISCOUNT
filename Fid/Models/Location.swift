//
//  Location.swift
//  Fid
//
//  Created by CROCODILE on 15.03.2021.
//

import Foundation
import UIKit
import CoreLocation

class Location {
    
    var lat: CLLocationDegrees!
    var lon: CLLocationDegrees!
    
    init(lat: Double, lon: Double) {
        self.lat = lat
        self.lon = lon
    }
}
