//
//  MapVC.swift
//  Fid
//
//  Created by CROCODILE on 09.03.2021.
//

import UIKit
import GoogleMaps
import CoreLocation
import SearchTextField

class MapVC: BaseVC {

    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var searchTextField: SearchTextField!
    @IBOutlet weak var searchView: UIView!
        
    let locationManager = CLLocationManager()
    
    var bounds = GMSCoordinateBounds()
    var currentLocation: CLLocationCoordinate2D!
    var benefitList = [Place]()
    var filteredBenefitList = [Place]()
    var isFiltered = false
    
    var search_words = [String]()
    var search_txt_array = [String]()
    var searchCard: String!
    var searchquery: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initializeMapView()
        
        let search_words_string = defaults.string(forKey: "search_words")
        self.search_words = search_words_string!.components(separatedBy: ",")
        
        self.searchView.backgroundColor = UIColor(hexString: "#e7eff1")
        self.searchView.layer.cornerRadius = self.searchView.frame.size.height / 2
        self.searchView.layer.masksToBounds = true
        
        self.configureCustomSearchTextField()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.searchTextField.text = ""
        self.configureSettings()
        self.showAllBenefits()
    }
    
    func showAllBenefits() {
        
        if self.benefitList.count != 0 {
            self.mapView.clear()
            var benefits_bounds = GMSCoordinateBounds()
            for item in self.benefitList {
                let marker = GMSMarker()
                marker.position = CLLocationCoordinate2D(latitude: item.lat, longitude: item.lon)
                marker.title = item.name
                marker.icon = UIImage(named: "benefit_marker")
                marker.map = self.mapView
                benefits_bounds = benefits_bounds.includingCoordinate(marker.position)
            }
            
            let update = GMSCameraUpdate.fit(benefits_bounds, withPadding: 50)
            self.mapView.animate(with: update)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.viewEndEditing()
    }
    
    // MARK: - Private methods
    
    @objc func viewEndEditing() {
        self.view.endEditing(true)
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
    
    func configureSettings() {
        if let card = defaults.string(forKey: "selectedcarddef") {
            self.searchCard = card
        } else {
            self.searchCard = "I000I"
        }
    }
    
    // 2 - Configure a custom search text view
    fileprivate func configureCustomSearchTextField() {
        
        self.searchTextField.placeholder = "חפש הטבה"
        
        switch traitCollection.userInterfaceStyle {
            case .light, .unspecified:
                // light mode detected
                break
            case .dark:
                // dark mode detected
                searchTextField.textColor = .black
                break
            @unknown default:
                break
        }

        // Modify current theme properties
        searchTextField.theme.font = UIFont.systemFont(ofSize: 14)
        searchTextField.theme.bgColor = .white
        searchTextField.theme.borderColor = UIColor.lightGray.withAlphaComponent(0.5)
        searchTextField.theme.separatorColor = UIColor.lightGray.withAlphaComponent(1.0)
        searchTextField.theme.cellHeight = 50
        searchTextField.theme.placeholderColor = UIColor.lightGray
        
        // Max number of results - Default: No limit
        searchTextField.maxNumberOfResults = 150
        
        // Max results list height - Default: No limit
        searchTextField.maxResultsListHeight = 200
        
        // Set specific comparision options - Default: .caseInsensitive
        searchTextField.comparisonOptions = [.caseInsensitive]

        // You can force the results list to support RTL languages - Default: false
        searchTextField.forceRightToLeft = false

        // Customize highlight attributes - Default: Bold
        searchTextField.highlightAttributes = [NSAttributedString.Key.backgroundColor: UIColor.yellow, NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 12)]
        
        // Handle item selection - Default behaviour: item title set to the text field
        searchTextField.itemSelectionHandler = { filteredResults, itemPosition in
            // Just in case you need the item position
            let item = filteredResults[itemPosition]
            print("Item at position \(itemPosition): \(item.title)")
            
            // Do whatever you want with the picked item
            self.searchTextField.text = item.title
            
            self.mapView.clear()
            
            let searched = self.benefitList.filter { $0.name.lowercased().contains(item.title.lowercased())}
            
            var searchBounds = GMSCoordinateBounds()
            for item in searched {
                let marker = GMSMarker()
                marker.position = CLLocationCoordinate2D(latitude: item.lat, longitude: item.lon)
                marker.title = item.name
                marker.icon = UIImage(named: "benefit_marker")
                marker.map = self.mapView
                searchBounds = searchBounds.includingCoordinate(marker.position)
            }
            
            let update = GMSCameraUpdate.fit(searchBounds, withPadding: 50)
            self.mapView.animate(with: update)
        }
        
        // Update data source when the user stops typing
        searchTextField.userStoppedTypingHandler = {
            if let criteria = self.searchTextField.text {
                if criteria.count > 1 {
                    
                    // Show loading indicator
                    self.searchTextField.showLoadingIndicator()
                    
                    let filtered_words = self.search_txt_array.filter { $0.lowercased().contains(criteria.lowercased())}
                    
                    // Set new items to filter
                    self.searchTextField.filterStrings(filtered_words)
                    
                    // Stop loading indicator
                    self.searchTextField.stopLoadingIndicator()
                }
            }
        } as (() -> Void)
    }
    
    @IBAction func searchAction(_ sender: Any) {
        print("search Action")
        self.searchquery = self.searchTextField.text!
        performSegue(withIdentifier: "search_map", sender: self)
    }
    
    @IBAction func refreshAction(_ sender: Any) {
        
        self.showLoadingView()
        mapView.clear()        
        locationManager.startUpdatingLocation()
    }
    
    func downloadBenefitList(url: String, param: [String: String]) {
        print(param)
        APIHandler.afPostRequest_BenefitList(url: url, param: param) { list in
            self.hideLoadingView()
            if let list = list {
                self.benefitList = list
                self.search_txt_array.removeAll()
                for item in self.benefitList {
                    self.search_txt_array.append(item.name)
                    let marker = GMSMarker()
                    marker.position = CLLocationCoordinate2D(latitude: item.lat, longitude: item.lon)
                    marker.title = item.name
                    marker.icon = UIImage(named: "benefit_marker")
                    marker.map = self.mapView
                    self.bounds = self.bounds.includingCoordinate(marker.position)
                }
                
                let update = GMSCameraUpdate.fit(self.bounds, withPadding: 50)
                self.mapView.animate(with: update)
            }
        }
    }
    
    func loadBenefits(searchText: String = "") {
        var searchedData = [Place]()
        if searchText.count != 0 {
            searchedData = self.benefitList.filter { $0.name.lowercased().contains(searchText) }
        } else {
            searchedData = self.benefitList
        }
        
        self.mapView.clear()
        
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: self.currentLocation.latitude, longitude: self.currentLocation.longitude)
        marker.title = "My Location"
        marker.icon = UIImage(named: "my_marker")
        marker.map = mapView
        
        bounds = bounds.includingCoordinate(marker.position)
        
        for item in searchedData {
            let marker = GMSMarker()
            marker.position = CLLocationCoordinate2D(latitude: item.lat, longitude: item.lon)
            marker.title = item.name
            marker.icon = UIImage(named: "benefit_marker")
            marker.map = self.mapView
            self.bounds = self.bounds.includingCoordinate(marker.position)
        }
        
        let update = GMSCameraUpdate.fit(self.bounds, withPadding: 50)
        self.mapView.animate(with: update)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "search_map" {
            let destination = segue.destination as! ResultVC
            destination.searchquery = self.searchTextField.text!
            destination.searchcard = self.searchCard
            destination.searchcategory = "0"
            
        }
    }
}

// MARK: - CLLocationManagerDelegate
extension MapVC: CLLocationManagerDelegate {
    
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

        self.currentLocation = location.coordinate
        
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        marker.title = "My Location"
        marker.icon = UIImage(named: "my_marker")
        marker.map = mapView
        mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
        bounds = bounds.includingCoordinate(marker.position)
        let param = ["user_longitude": "\(location.coordinate.longitude)", "user_latitude": "\(location.coordinate.latitude)"]
        self.downloadBenefitList(url: ServerURL.benefitList, param: param)
        
        self.locationManager.stopUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}

// MARK: - Google map Delegate

extension MapVC: GMSMapViewDelegate {
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
      
    }
    
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
      
    }
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        
        print("tapped info window of marker title : \(marker.title!)")
        self.searchquery = marker.title!
        self.performSegue(withIdentifier: "search_map", sender: self)
    }
    
}

extension MapVC: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.searchquery = self.searchTextField.text!
        performSegue(withIdentifier: "search_map", sender: self)
        return true
    }
}
