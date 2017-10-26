//
//  ViewController.swift
//  PA2PREP_Exercise6
//
//  Created by Timothy M Shepard on 10/25/17.
//  Copyright © 2017 Timothy. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, UIGestureRecognizerDelegate {
    
    var company: Company?

    let manager = CLLocationManager()
    
    @IBOutlet weak var mapView: MKMapView!
    
    var userLocation: CLLocationCoordinate2D?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = company?.company ?? ""
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "gps"), style: .done, target: self, action: #selector(locateMe))
        
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        
        let span = MKCoordinateSpanMake(0.1, 0.1)
        let coord2d = CLLocationCoordinate2D(latitude: (company?.hq_latitude ?? 0.00) , longitude: (company?.hq_longitude ?? 0.00))
        let loc = CLLocation(latitude: (company?.hq_latitude ?? 0.00) , longitude: (company?.hq_longitude ?? 0.00))
        let region = MKCoordinateRegionMake(coord2d, span)
    
        mapView.delegate = self
        mapView.setRegion(region, animated: true)
        
        CLGeocoder().reverseGeocodeLocation(loc) { (placemark, err) in
            if let place = placemark?[0] {
                let annotation = MKPointAnnotation()
                annotation.coordinate = coord2d
                annotation.title = "CEO: \(self.company?.ceo ?? "DEFAULT")"
                annotation.subtitle = place.locality! + ", " + place.administrativeArea! + ", " + place.isoCountryCode!
                self.mapView.addAnnotation(annotation)
            }
        }
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPressed(longPressRecognizer:)))
        longPress.minimumPressDuration = 2.0
        longPress.delegate = self
        mapView.addGestureRecognizer(longPress)
    }

    @objc func locateMe() {
        let span = MKCoordinateSpanMake(0.1, 0.1)
        let region = MKCoordinateRegionMake(userLocation!, span)
        mapView.setRegion(region, animated: true)
        mapView.showsUserLocation = true
    }
    
    @objc func longPressed(longPressRecognizer: UILongPressGestureRecognizer) {
        let longPressLocation = longPressRecognizer.location(in: mapView)
        let coord2d: CLLocationCoordinate2D = mapView.convert(longPressLocation, toCoordinateFrom: mapView)
        let loc = CLLocation(latitude: coord2d.latitude, longitude: coord2d.longitude)
        CLGeocoder().reverseGeocodeLocation(loc) { (placemark, err) in
            if let place = placemark?[0] {
                let annotation = MKPointAnnotation()
                annotation.coordinate = coord2d
                annotation.title = "(\(coord2d.latitude), \(coord2d.longitude))"
                annotation.subtitle = place.locality! + ", " + place.administrativeArea! + ", " + place.isoCountryCode!
                self.mapView.addAnnotation(annotation)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[0]
        userLocation = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "Pin")
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "Pin")
        } else {
            annotationView?.annotation = annotation
        }
        if let title = annotation.title {
            if title != "My Location" {
                let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: (annotationView?.frame.height)!, height: (annotationView?.frame.height)!))
                imageView.downloadImage(url: URL(string: company?.logo_url ?? "" )!)
                imageView.contentMode = .scaleAspectFit
                annotationView?.leftCalloutAccessoryView = imageView
                annotationView?.canShowCallout = true
            }
        }
        return annotationView
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension UIImageView {
    
    func getDataFromUrl(url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            completion(data, response, error)
            }.resume()
    }
    
    func downloadImage(url: URL) {
        getDataFromUrl(url: url) { (data, response, error) in
            guard let data = data, error == nil else { return }
            DispatchQueue.main.async() {
                self.image = UIImage(data: data)
            }
        }
    }
}

