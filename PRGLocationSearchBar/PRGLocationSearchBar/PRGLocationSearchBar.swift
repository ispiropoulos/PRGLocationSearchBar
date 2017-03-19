//
//  PRGLocationSearchBar.swift
//  
//
//  Created by John Spiropoulos on 28/12/2016.
//  Copyright © 2016 Programize. All rights reserved.
//

import UIKit
import CoreLocation

@objc protocol PRGLocationSearchBarDelegate: class {
    @objc optional func locationSearchBar(searchBar: PRGLocationSearchBar, didTapLocationButton: UIButton)
    @objc optional func locationSearchBar(searchBar: PRGLocationSearchBar, didFindLocationWith lat: Double, lon: Double, address: Dictionary<AnyHashable,Any>?)
    @objc optional func locationSearchBar(searchBar: PRGLocationSearchBar, didFailToFindLocationWith error: Error)
    @objc optional func locationSearchBar(searchBar: PRGLocationSearchBar, didTapSearchButton: UIButton, withSearchString searchString: String)
    @objc optional func locationSearchBar(searchBar: PRGLocationSearchBar, didEditSearchTextWith text: String)
    @objc optional func locationSearchBar(searchBar: PRGLocationSearchBar, didStartEditingTextField textField: UITextField)
}

@IBDesignable
class PRGLocationSearchBar: UIView, UITextFieldDelegate, CLLocationManagerDelegate {
    
    
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
        }
    }
    
    @IBInspectable var textFont: String = "HelveticaNeue-Regular*20" {
        didSet {
            if textFont.components(separatedBy: "*").count == 2 {
               let fontAttrs = textFont.components(separatedBy: ",")
                if let size = Int(fontAttrs[1]), let font = UIFont(name: fontAttrs[0], size: CGFloat(size)) {
                    searchField.font = font
                }
            }
        }
    }
   
    var locationButton: UIButton!
    var searchField: UITextField!
    var searchButton: UIButton!
    
    lazy var geoCoder = CLGeocoder()
    
    lazy var locationManager: CLLocationManager? = {
        if Bundle.main.object(forInfoDictionaryKey: "NSLocationWhenInUseUsageDescription") != nil {
            var _locationManager = CLLocationManager()
            _locationManager.delegate = self
            _locationManager.requestWhenInUseAuthorization()
            return _locationManager
        } else {
            print("PRGLocationSearchBar Error: Location Services cannot be initialized. The app's Info.plist must contain an NSLocationWhenInUseUsageDescription key with a string value explaining to the user how the app uses this data")
            return nil
        }
    }()
    
    weak var delegate: PRGLocationSearchBarDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        customInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        customInit()
    }
    
    
    func customInit(){
        autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
        backgroundColor = .white
        
        // Location Button
        locationButton = UIButton()


        let locationArrowImage = UIImage(named: "LocationArrow", in: Bundle(for: type(of: self)), compatibleWith: nil)
        locationButton.setImage(locationArrowImage, for: .normal)
        locationButton.addTarget(self, action: #selector(locationButtonTapped(_:)), for: .touchUpInside)
        addSubview(locationButton)
        
        locationButton.translatesAutoresizingMaskIntoConstraints = false
        
        
        // Search Field
        searchField = UITextField()
        
        searchField.borderStyle = .none
        addSubview(searchField)
        
        searchField.translatesAutoresizingMaskIntoConstraints = false
        searchField.addTarget(self, action: #selector(searchFieldEdited(_:)), for: .editingChanged)
        searchField.addTarget(self, action: #selector(searchFieldBeganEditing(_:)), for: .editingDidBegin)
        searchField.returnKeyType = .search
        searchField.delegate = self

        
        // Search Button
        searchButton = UIButton()

        let searchImage = UIImage(named: "Search", in: Bundle(for: type(of: self)), compatibleWith: nil)

        searchButton.setImage(searchImage, for: .normal)
        searchButton.addTarget(self, action: #selector(searchButtonTapped(_:)), for: .touchUpInside)
        addSubview(searchButton)
        searchButton.translatesAutoresizingMaskIntoConstraints = false
        
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        locationButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8).isActive = true
        locationButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        locationButton.widthAnchor.constraint(equalToConstant: 29).isActive = true
        locationButton.heightAnchor.constraint(equalToConstant: 29).isActive = true
        
        searchField.leadingAnchor.constraint(equalTo: locationButton.trailingAnchor, constant: 8).isActive = true
        searchField.topAnchor.constraint(equalTo: topAnchor, constant: 4).isActive = true
        searchField.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4).isActive = true

        searchButton.leftAnchor.constraint(equalTo: searchField.rightAnchor, constant: 8).isActive = true
        searchButton.rightAnchor.constraint(equalTo: rightAnchor, constant: -8).isActive = true
        searchButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        searchButton.widthAnchor.constraint(equalToConstant: 29).isActive = true
        searchButton.heightAnchor.constraint(equalToConstant: 29).isActive = true

    }
    
    // MARK: - Search Field Delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchButtonTapped(searchButton)
        
        return true
    }
    
    // MARK: - Tap Actions
    
   func locationButtonTapped(_ sender: UIButton) {
        if areLocationPermissionsAvailable() {
            endEditing(true)
            delegate?.locationSearchBar?(searchBar: self, didTapLocationButton: sender)
            locationManager?.requestLocation()
        }
    }
    
    func searchButtonTapped(_ sender: UIButton) {
        if searchField.isFirstResponder {
            endEditing(true)
            delegate?.locationSearchBar?(searchBar: self, didTapSearchButton: sender, withSearchString: searchField.text!)
            
            if searchField.text != "" {
                geocode(withLocation: nil, withSearchString: searchField.text!)
            }
        } else {
            searchField.becomeFirstResponder()
        }
        
    }
    
    func searchFieldBeganEditing(_ sender: UITextField) {
            delegate?.locationSearchBar?(searchBar: self, didStartEditingTextField: sender)
    }
    
    func searchFieldEdited(_ sender: UITextField) {
            delegate?.locationSearchBar?(searchBar: self, didEditSearchTextWith: sender.text!)
    }
    
    // MARK: - Location Manager Delegates
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        geocode(withLocation: locations.last!, withSearchString: nil)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
            delegate?.locationSearchBar?(searchBar: self, didFailToFindLocationWith: error)
    }
    
    // MARK: - Geocoder Functionality
    func geocode(withLocation location: CLLocation?, withSearchString searchString: String?){
        if location != nil {
            geoCoder.reverseGeocodeLocation(location!) { (placemarks, error) in
                if error == nil && placemarks != nil && !placemarks!.isEmpty && self.delegate != nil {
                    let placemark = placemarks!.first
                    self.delegate?.locationSearchBar?(searchBar: self, didFindLocationWith: location!.coordinate.latitude, lon: location!.coordinate.longitude, address: placemark!.addressDictionary)
                    
                } else {
                    self.delegate?.locationSearchBar?(searchBar: self, didFindLocationWith: location!.coordinate.latitude, lon: location!.coordinate.longitude, address: nil)
                }
            }
        }
        if searchString != nil {
            geoCoder.geocodeAddressString(searchString!, completionHandler: { (placemarks, error) in
                if error == nil && placemarks != nil && !placemarks!.isEmpty && self.delegate != nil {
                    let placemark = placemarks!.first
                    self.delegate?.locationSearchBar?(searchBar: self, didFindLocationWith: placemark!.location!.coordinate.latitude, lon: placemark!.location!.coordinate.longitude, address: placemark!.addressDictionary)
                    
                } else {
                    self.delegate?.locationSearchBar?(searchBar: self, didFailToFindLocationWith: error!)
                }
                
            })
        }
    }
    
    // MARK: - Check for location permissions
    func areLocationPermissionsAvailable() -> Bool {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            return true
        case .notDetermined:
            locationManager?.requestWhenInUseAuthorization()
            return false
        case .restricted, .denied:
            
            let alertController = UIAlertController(
                title: "Location Access Disabled",
                message: "In order for us to be able to get your location, please open this app's settings and set location access to 'When in use'.",
                preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alertController.addAction(cancelAction)
            
            let openAction = UIAlertAction(title: "Open Settings", style: .default) { (action) in
                if let url = URL(string:UIApplicationOpenSettingsURLString) {
                    UIApplication.shared.open(url , options: [:], completionHandler: nil)
                }
            }
            alertController.addAction(openAction)
            
            (UIApplication.shared.delegate as! AppDelegate).window!.rootViewController?.present(alertController, animated: true, completion: nil)
            return false
        case .authorizedAlways:
            return true
        }
    }
    
    
}
