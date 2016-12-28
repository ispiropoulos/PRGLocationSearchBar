//
//  PRGLocationSearchBar.swift
//  GRGiOS
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
    
    var view: UIView!
    
    @IBInspectable var cornerRadius: CGFloat = 0.0 {
        didSet {
            self.layer.cornerRadius = cornerRadius
        }
    }
    
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var searchField: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    
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
        // 1. setup any properties here
        
        // 2. call super.init(frame:)
        super.init(frame: frame)
        backgroundColor = .white

        // 3. Setup view from .xib file
        xibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        // 1. setup any properties here
        
        // 2. call super.init(coder:)
        super.init(coder: aDecoder)
        
        // 3. Setup view from .xib file
        xibSetup()
    }
    
    func xibSetup() {
        view = loadViewFromNib()
        
        // use bounds not frame or it'll be offset
        view.frame = bounds
        
        // Make the view stretch with containing view
        view.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
        searchField.returnKeyType = .search
        searchField.delegate = self
        
        // Adding custom subview on top of our view (over any custom drawing > see note below)
        addSubview(view)
        
    }
    
    func loadViewFromNib() -> UIView {
        
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "PRGLocationSearchBar", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        
        return view
    }
    
    // MARK: - Search Field Delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchButtonTapped(searchButton)
        
        return true
    }
    
    // MARK: - Tap Actions
    
    @IBAction func locationButtonTapped(_ sender: UIButton) {
        if areLocationPermissionsAvailable() {
            view.endEditing(true)
            if delegate != nil {
                delegate!.locationSearchBar?(searchBar: self, didTapLocationButton: sender)
            }
            locationManager?.requestLocation()
        }
    }
    
    @IBAction func searchButtonTapped(_ sender: UIButton) {
        if searchField.isFirstResponder {
            view.endEditing(true)
            delegate!.locationSearchBar?(searchBar: self, didTapSearchButton: sender, withSearchString: searchField.text!)
            
            if searchField.text != "" {
                geocode(withLocation: nil, withSearchString: searchField.text!)
            }
        } else {
            searchField.becomeFirstResponder()
        }
        
    }
    
    @IBAction func searchFieldBeganEditing(_ sender: UITextField) {
        if delegate != nil {
            delegate!.locationSearchBar?(searchBar: self, didStartEditingTextField: sender)
        }
    }
    
    @IBAction func searchFieldEdited(_ sender: UITextField) {
        if delegate != nil {
            delegate!.locationSearchBar?(searchBar: self, didEditSearchTextWith: sender.text!)
        }
    }
    
    // MARK: - Location Manager Delegates
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        geocode(withLocation: locations.last!, withSearchString: nil)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if delegate != nil {
            delegate!.locationSearchBar?(searchBar: self, didFailToFindLocationWith: error)
        }
    }
    
    // MARK: - Geocoder Functionality
    func geocode(withLocation location: CLLocation?, withSearchString searchString: String?){
        if location != nil {
            geoCoder.reverseGeocodeLocation(location!) { (placemarks, error) in
                if error == nil && placemarks != nil && !placemarks!.isEmpty && self.delegate != nil {
                    let placemark = placemarks!.first
                    self.delegate!.locationSearchBar?(searchBar: self, didFindLocationWith: location!.coordinate.latitude, lon: location!.coordinate.longitude, address: placemark!.addressDictionary)
                    
                } else {
                    self.delegate!.locationSearchBar?(searchBar: self, didFindLocationWith: location!.coordinate.latitude, lon: location!.coordinate.longitude, address: nil)
                }
            }
        }
        if searchString != nil {
            geoCoder.geocodeAddressString(searchString!, completionHandler: { (placemarks, error) in
                if error == nil && placemarks != nil && !placemarks!.isEmpty && self.delegate != nil {
                    let placemark = placemarks!.first
                    self.delegate!.locationSearchBar?(searchBar: self, didFindLocationWith: placemark!.location!.coordinate.latitude, lon: placemark!.location!.coordinate.longitude, address: placemark!.addressDictionary)
                    
                } else {
                    self.delegate!.locationSearchBar?(searchBar: self, didFailToFindLocationWith: error!)
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
