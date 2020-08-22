PRGLocationSearchBar
=========

Control used to show a search bar which can fetch your location as well as geocode a search string
## Demo
![PRGLocationSearchBar](https://github.com/ispiropoulos/PRGLocationSearchBar/blob/master/Demo.gif?raw=true)

## Requirements
iOS >= 9.x
Swift 3.0

## Installation
Just copy the PRGLocationSearchBar folder into your project
    
## Usage
- Drag a UIView using interface builder and set it’s class to PRGLocationSearchBar
- You can programmatically add the search bar by using init(frame:) method.

#### PRGLocationSearchBarDelegate (all methods are optional)
```swift
func locationSearchBar(searchBar: PRGLocationSearchBar, didTapLocationButton: UIButton) {
	print("Location Button Tapped")
}
 ``` 
 ```swift
func locationSearchBar(searchBar: PRGLocationSearchBar, didTapSearchButton: UIButton, withSearchString searchString: String) {
    print("Search Button Tapped")
}
  ```
 ```swift
func locationSearchBar(searchBar: PRGLocationSearchBar, didFindLocationWith lat: Double, lon: Double, address: Dictionary<AnyHashable, Any>?) {
    print(“COORDINATE\nLat: \(lat)\nLon:\(lon)”)
    for key in address!.keys where address != nil {
        print(“\(key): \(address![key]!)\n")
    }
}
```
```swift
func locationSearchBar(searchBar: PRGLocationSearchBar, didEditSearchTextWith text: String) {
    print(text)
}
```
```swift
func locationSearchBar(searchBar: PRGLocationSearchBar, didStartEditingTextField textField: UITextField) {
    print("Started editing search field")
}
```
```swift
func locationSearchBar(searchBar: PRGLocationSearchBar, didFailToFindLocationWith error: Error) {
    print(error.localizedDescription)
}
```

License
------------
PRGLocationSearchBar is available under the MIT license.

