PRGLocationSearchBar
=========

Control used to show a search bar which can fetch your location as well as geocode a search string

## Installation
Just copy the PRGLocationSearchBar folder into your project
    
## Usage
- Drag a UIView using interface builder and set it’s class to PRGLocationSearchBar
- You can programmatically add the search bear by using init(frame:) method.

#### PRGLocationSearchBarDelegate (all methods are optional)

	func locationSearchBar(searchBar: PRGLocationSearchBar, didTapLocationButton: UIButton) {
        print("Location Button Tapped")
    }
    
    func locationSearchBar(searchBar: PRGLocationSearchBar, didTapSearchButton: UIButton, withSearchString searchString: String) {
        print("Search Button Tapped")
    }
    
   
    func locationSearchBar(searchBar: PRGLocationSearchBar, didFindLocationWith lat: Double, lon: Double, address: Dictionary<AnyHashable, Any>?) {
        print(“COORDINATE\nLat: \(lat)\nLon:\(lon)”)
       
        for key in address!.keys where address != nil {
            print(“\(key): \(address![key]!)\n")
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

Requirements
------------
iOS >= 9.x

Contact
-------
jspiropoulos@programize.com

License
------------
PRGLocationSearchBar is available under the MIT license.

