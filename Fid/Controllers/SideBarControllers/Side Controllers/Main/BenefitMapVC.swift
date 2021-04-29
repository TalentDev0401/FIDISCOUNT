//
//  BenefitMapVC.swift
//  Fid
//
//  Created by CROCODILE on 11.03.2021.
//

import UIKit
import GoogleMaps
import CoreLocation
import Alamofire
import SwiftyJSON
import GooglePlaces
import ProgressHUD

class BenefitMapVC: UIViewController {
    
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var backImg: UIImageView!
    @IBOutlet weak var distance_lbl: UILabel!
    
    let locationManager = CLLocationManager()
    
    var bounds = GMSCoordinateBounds()
    
    var benefitList = [Location]()
   
    override func viewDidLoad() {
        super.viewDidLoad()

        let back = UIImage(named: "back")
        backImg.image = back?.withRenderingMode(.alwaysTemplate)
        backImg.tintColor = UIColor(hexString: "#27bdb1")
        
        initializeMapView()

    }
    
    func initializeMapView() {
        
        locationManager.delegate = self
          
        if CLLocationManager.locationServicesEnabled() {
          locationManager.requestLocation()
          mapView.isMyLocationEnabled = true
          mapView.settings.myLocationButton = true
        } else {
          locationManager.requestWhenInUseAuthorization()
        }
        
        locationManager.startUpdatingLocation()
        mapView.delegate = self
    }
        
    func drawRoute(from source: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D) {
                   
        let headers: HTTPHeaders = [ "Accept": "application/json", "Content-Type": "application/json" ]
        
        var url = "https://maps.googleapis.com/maps/api/directions/json?origin= \(source.latitude),\(source.longitude)&destination=\(destination.latitude),\(destination.longitude)&mode=driving&key=\(GoogleMapKey.directionKey)"
        
        url = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        
        self.showLoadingView()
        
        print(url)
                
        AF.request(url, encoding: JSONEncoding.default, headers: headers).responseJSON { response in

            self.hideLoadingView()
            
            switch response.result {
                case .success(let value):
                    print("************")
                    print(JSON(value))
                    let jsonData = JSON(value)
                    let routes = jsonData["routes"].arrayValue
                    
                    if routes.count == 0 {
                        self.createMarker(source: source, destination: destination, route: false)
                        ProgressHUD.showError("It's unable to draw route between your location and benefit location.")
                        return
                    }
                    
                    self.createMarker(source: source, destination: destination, route: true)
                                                            
                    for route in routes {
                        let overview_polyline = route["overview_polyline"].dictionaryValue
                        let points = overview_polyline["points"]!.stringValue

                        self.drawPath(from: points)
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                    ProgressHUD.showError(error.localizedDescription)
            }
        }
    }
    
    func createMarker(source: CLLocationCoordinate2D, destination: CLLocationCoordinate2D, route: Bool) {
        
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: source.latitude, longitude: source.longitude)
        marker.title = "My Location"
        marker.icon = UIImage(named: "my_marker")
        marker.appearAnimation = .pop
        marker.map = self.mapView
        self.mapView.camera = GMSCameraPosition(target: source, zoom: 15, bearing: 0, viewingAngle: 0)
        self.bounds = self.bounds.includingCoordinate(marker.position)
        
        if route {
            let marker1 = GMSMarker()
            marker1.position = CLLocationCoordinate2D(latitude: destination.latitude, longitude: destination.longitude)
            marker1.title = "Destination"
            marker1.icon = UIImage(named: "benefit_marker")
            marker1.appearAnimation = .pop
            marker1.map = self.mapView
            self.bounds = self.bounds.includingCoordinate(marker1.position)
                    
            let update = GMSCameraUpdate.fit(self.bounds, withPadding: 100)
            self.mapView.animate(with: update)
        }
        
    }
       
    func drawPath(from polyStr: String){
        let path = GMSPath(fromEncodedPath: polyStr)
        let polyline = GMSPolyline(path: path)
        polyline.strokeWidth = 5.0
        polyline.strokeColor = UIColor.systemBlue
        polyline.map = mapView // Google MapView
        
    }
    
    func getShortestCoordinate(source: CLLocation) {
        
        var locations : [CLLocation] = []
        for item in self.benefitList {
            let location = CLLocation(latitude: item.lat, longitude: item.lon)
            locations.append(location)
        }
        
        if let closedLocation = self.closestLocation(locations: locations, closestToLocation: source) {
                                    
            // - Route on google map
            self.drawRoute(from: CLLocationCoordinate2D(latitude: source.coordinate.latitude, longitude: source.coordinate.longitude), to: CLLocationCoordinate2D(latitude: closedLocation.coordinate.latitude, longitude: closedLocation.coordinate.longitude))
        }
    }
    
    func closestLocation(locations: [CLLocation], closestToLocation location: CLLocation) -> CLLocation? {
        if let closestLocation = locations.min(by: { location.distance(from: $0) < location.distance(from: $1) }) {
            print("closest location: \(closestLocation), distance: \(location.distance(from: closestLocation))")
                        
            let distance = location.distance(from: closestLocation)
            
            if distance < 1000 {
                
                let doubleDistance = String(format: "%.2f", distance)
                self.distance_lbl.text = "Distance : \(doubleDistance) m"
            } else {
                let kmDistance = distance / 1000
                let doublekmDistance = String(format: "%.2f", kmDistance)
                
                self.distance_lbl.text = "Distance : \(doublekmDistance) km"
            }
                                    
            return closestLocation
        } else {
            print("coordinates is empty")
            ProgressHUD.showError("coordinates is empty")
            return nil
        }
    }
    
    @IBAction func goback(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

}

// MARK: - CLLocationManagerDelegate
extension BenefitMapVC: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    
        guard status == .authorizedWhenInUse else {
          return
        }
        
        locationManager.requestLocation()
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            return
        }
        
        self.mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
        
        self.locationManager.stopUpdatingLocation()
        
        self.getShortestCoordinate(source: location)
                
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}

// MARK: - Google map Delegate

extension BenefitMapVC: GMSMapViewDelegate {
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
      
    }
    
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
      
    }

}
