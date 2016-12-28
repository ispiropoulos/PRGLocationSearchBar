//
//  ViewController.swift
//  PRGLocationSearchBar
//
//  Created by John Spiropoulos on 28/12/2016.
//  Copyright © 2016 Programize. All rights reserved.
//

import UIKit

class ViewController: UIViewController, PRGLocationSearchBarDelegate {
    @IBOutlet weak var coordinateLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!

    @IBOutlet weak var searchBar: PRGLocationSearchBar!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        searchBar.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Location Search Bar Delegate

    func locationSearchBar(searchBar: PRGLocationSearchBar, didTapLocationButton: UIButton) {
        print("Location Button Tapped")
    }
    
    func locationSearchBar(searchBar: PRGLocationSearchBar, didTapSearchButton: UIButton, withSearchString searchString: String) {
        print("Search Button Tapped")
    }
    
   
    func locationSearchBar(searchBar: PRGLocationSearchBar, didFindLocationWith lat: Double, lon: Double, address: Dictionary<AnyHashable, Any>?) {
        coordinateLabel.text = "COORDINATE\nLat: \(lat)\nLon:\(lon)"
        addressLabel.text = ""
        for key in address!.keys where address != nil {
            addressLabel.text!.append("\(key): \(address![key]!)\n")
        }
    }

    func locationSearchBar(searchBar: PRGLocationSearchBar, didEditSearchTextWith text: String) {
        print(text)
    }
    
    func locationSearchBar(searchBar: PRGLocationSearchBar, didStartEditingTextField textField: UITextField) {
        print("Started editing search field")
    }
    
    func locationSearchBar(searchBar: PRGLocationSearchBar, didFailToFindLocationWith error: Error) {
        print(error.localizedDescription)
    }
}

