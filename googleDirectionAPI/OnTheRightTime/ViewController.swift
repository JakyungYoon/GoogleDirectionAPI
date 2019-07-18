//
//  ViewController.swift
//  OnTheRightTime
//
//  Created by Jakyung Yoon on 7/16/19.
//  Copyright © 2019 Jakyung Yoon. All rights reserved.
//

import UIKit
import GoogleMaps
import Alamofire
import SwiftyJSON

enum Location {
    case startLocation
    case destinationLocation
}


class ViewController: UIViewController, GMSMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var googleMaps : GMSMapView!
//    @IBOutlet weak var startLocation : UITextField!
//    @IBOutlet weak var destinationLocation : UITextField!

    var locationManager = CLLocationManager()
    var locationSelected = Location.startLocation
    
    var locationStart = CLLocation()
    var locationEnd = CLLocation()
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        //locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startMonitoringSignificantLocationChanges()
        
        //Your map initiaion code
        //let camera = GMSCameraPosition.camera(withLatitude: , longitude: , zoom: 6)
        
        //googleMaps.camera = camera
        //googleMaps.animate(to: camera)
        googleMaps.delegate = self
        googleMaps?.isMyLocationEnabled = true
        googleMaps.settings.myLocationButton = true
        googleMaps.settings.compassButton = true
        googleMaps.settings.zoomGestures = true
        
//        let golfZone : CLLocation = CLLocation(latitude: 37.512444082346775, longitude: 127.10264328742164)
//        let lotteworldTower : CLLocation = CLLocation(latitude: 37.512444082346775, longitude: 127.10264328742164)
//        drawPath(startLocation: golfZone, endLocation: lotteworldTower)
    }
    
    //Mark : function for create a marker pin on map
    func createMarker(titleMarker : String , iconMarker : UIImage, latitude : CLLocationDegrees, longitude : CLLocationDegrees){
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2DMake(latitude, longitude)
        marker.title = titleMarker
        marker.icon = iconMarker
        marker.map = googleMaps
    }
    
    //Location Manager delegates
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error to get location : \(error)")
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        guard let coordinate = location?.coordinate else { return }
        let camera = GMSCameraPosition.camera(withLatitude: coordinate.latitude , longitude: coordinate.longitude, zoom: 13)
        
        googleMaps.animate(to: camera)
        let locationTujuan = CLLocation(latitude: 37.5126868 , longitude: 127.1026157)
        createMarker(titleMarker: "Lokasi Tujuan", iconMarker: GMSMarker.markerImage(with: .red), latitude: locationTujuan.coordinate.latitude, longitude: locationTujuan.coordinate.longitude)
        createMarker(titleMarker: "Lokasi Aku", iconMarker: GMSMarker.markerImage(with: .blue), latitude: ((location?.coordinate.latitude)!), longitude: ((location?.coordinate.longitude)!))
        
        drawPath(startLocation : location!, endLocation : locationTujuan)
        //self.locationManager.stopUpdatingLocation()
    }
    
    //Mark : GMSMapViewDelegate
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        googleMaps.isMyLocationEnabled = true
    }
    
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        googleMaps.isMyLocationEnabled = true
        if (gesture) {
            mapView.selectedMarker = nil
        }
    }
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        googleMaps.isMyLocationEnabled = true
        return false
    }
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        print("COORDINATE \(coordinate)") //when you tapped coordinate
    }
    func didTapMyLocationButton(for mapView: GMSMapView) -> Bool {
        googleMaps.isMyLocationEnabled = true
        googleMaps.selectedMarker = nil
        return false
    }
    
    func drawPath(startLocation : CLLocation, endLocation : CLLocation){
        let origin = "\(startLocation.coordinate.latitude),\(startLocation.coordinate.longitude)"
        let destination = "\(endLocation.coordinate.latitude),\(endLocation.coordinate.longitude)"
        
        guard let url = URL(string: "https://maps.googleapis.com/maps/api/directions/json") else { return }
        var parameter: Parameters = [:]
        parameter.updateValue(origin, forKey: "origin")
        parameter.updateValue(destination, forKey: "destination")
        parameter.updateValue("transit", forKey: "mode")
        parameter.updateValue("AIzaSyDYuKUjXAy9BpP-Ix4hKXBKbQunsoDxLzU", forKey: "key")
       // var header: HTTPHeaders = [:]
        //header.updateValue("AIzaSyA6ccOvK6eRamNh64OgfiKhSxSJAwMNwWw", forKey: "key")
        Alamofire.request(url, method: .get, parameters: parameter, encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
            switch response.result {
            case .success(let value) :
                var json = JSON(value)
                let routes = json["routes"].arrayValue
                
                for route in routes {
                    let routeOverviewPolyline = route["overview_polyline"].dictionary
                    let points = routeOverviewPolyline?["points"]?.stringValue
                    let path = GMSPath.init(fromEncodedPath: points!)
                    let polyline = GMSPolyline.init(path: path)
                    polyline.strokeWidth = 4
                    polyline.strokeColor = UIColor.red
                    polyline.map = self.googleMaps
                    
                }
                print("json : ", json)
            case .failure(let error) :
                print("error - ", error)
            }
        }
    }
    
//    @IBAction func showDirection(_ sender: UIButton) {
//        self.drawPath(startLocation: locationStart, endLocation: locationEnd)
//    }
//
   /* override func loadView() {
        // Create a GMSCameraPosition that tells the map to display the
        // coordinate -33.86,151.20 at zoom level 6.
        let camera = GMSCameraPosition.camera(withLatitude: -33.86, longitude: 151.20, zoom: 6.0)
        let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        view = mapView
        
        // Creates a marker in the center of the map.
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: -33.86, longitude: 151.20)
        marker.title = "Sydney"
        marker.snippet = "Australia"
        marker.map = mapView
    }
*/

}

