//
//  MapVC.swift
//  RealEstateAgency
//
//  Created by Mediym on 3/15/19.
//  Copyright © 2019 NSMedium. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Firebase
import FirebaseFirestore
import FirebaseStorage
import Kingfisher

protocol HandleMapSearch {
    func dropPinZoomIn(placemark: MKPlacemark)
}

class MapVC: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var bottomSafeAreaBorder: UIView!
    var searchContoler: UISearchController!
    var filterCardVC: FilterCardVC!
    var selectedAnnotation: MKAnnotation?
    var lastTapPoint: CGPoint?
    
    var data: [Property] = []
    
    var locationManager: CLLocationManager!
    
    // MARK: - Firebase
    let housesRef = Firestore.firestore().collection("houses")
    let storageRef = Storage.storage().reference(withPath: "houses/")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMapView()
        setupLocationManager()
        setupAddition()
        showCurrentLocation()
        
        
        setupFilterCard()
        setupSearchContoller()
        
        self.navigationItem.hidesBackButton = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getData()
        setupNavigationContoller()
    }

    // MARK: - Setup
    func setupAddition() {
        let longTapRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(addMarker))
        mapView.addGestureRecognizer(longTapRecognizer)
    }
    
    func setupNavigationContoller() {
        navigationController?.isNavigationBarHidden = false
    }
    
    func setupSearchContoller() {
        let locationSearchTable = LocationSearchTable.instantiate()
        searchContoler = UISearchController(searchResultsController: locationSearchTable)
        searchContoler.searchResultsUpdater = locationSearchTable
        locationSearchTable.handleMapSearchDelegate = self
        locationSearchTable.mapView = mapView
        
        navigationItem.titleView = searchContoler.searchBar
        
        searchContoler.hidesNavigationBarDuringPresentation = false
        definesPresentationContext = true
    }
    
    func setupFilterCard() {
        filterCardVC = FilterCardVC.loadFromNib()
        filterCardVC.delegate = self
        self.addChild(filterCardVC)
        self.view.insertSubview(filterCardVC.view, belowSubview: bottomSafeAreaBorder)
    }
    
    func setupMapView() {
        mapView.delegate = self
        mapView.register(PropertyMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        mapView.register(ClusterAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultClusterAnnotationViewReuseIdentifier)
    }
    
    func setupLocationManager() {
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        
        if (CLLocationManager.locationServicesEnabled()) {
            locationManager.requestAlwaysAuthorization()
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func showCurrentLocation() {
        if let userLocation = locationManager.location?.coordinate {
            let viewRegion = MKCoordinateRegion(center: userLocation, latitudinalMeters: 500, longitudinalMeters: 500)
            mapView.setRegion(viewRegion, animated: false)
        }
    }
    
    func setupImage(for imageView: UIImageView, with key: String) {
        let cache = ImageCache.default
        
        cache.retrieveImage(forKey: key) { result in
            switch result {
            case .success(let value):
                if value.cacheType == .none {
                    self.loadImage(for: imageView, with: key)
                } else {
                    DispatchQueue.main.async {
                        imageView.image = value.image
                    }
                }
                
            case .failure(let error):
                print("Kingfisher error: \(error)")
            }
        }
    }
    
    func loadImage(for imageView: UIImageView, with key: String) {
        storageRef.child("\(key).jpg").downloadURL { url, err in
            guard let url = url else {
                print("Image Error: \(err?.localizedDescription ?? "Unknown")")
                imageView.image = #imageLiteral(resourceName: "NotFoundedHouse")
                return
            }
            
            let resource = ImageResource(downloadURL: url, cacheKey: key)
            imageView.kf.setImage(with: resource, placeholder: #imageLiteral(resourceName: "Placeholder"))
        }
    }
    
    // MARK: - Database
    func getData() {
        housesRef.getDocuments() { (querySnapshot, err) in
            guard let snapshot = querySnapshot else {
                print("Error getting documents: \(err?.localizedDescription ?? "Unknown")")
                return
            }
            
            self.data = snapshot.documents.compactMap(Property.init)
            self.refreshMapView()
        }
    }
    
    func refreshMapView(with filter: PropertyFilterItem? = nil) {
        var annotations = data
        if let filter = filter {
            annotations = annotations.filter(filter.validate)
        }
        
        let mapAnnotations = mapView.annotationsNoUserLocation.compactMap{ $0 as? Property }
        
        mapAnnotations.filter { mapItem in
            !annotations.contains(where: mapItem.isEqual)
        }.forEach(mapView.removeAnnotation)

        annotations.filter { item in
            !mapAnnotations.contains(where: item.isEqual)
        }.forEach(mapView.addAnnotation)
    }
    
    // MARK: - Selectors
    @objc func addMarker(_ recognizer: UILongPressGestureRecognizer) {
        let point = recognizer.location(in: mapView)
        guard point != lastTapPoint else { return }
        let coords = mapView.convert(point, toCoordinateFrom: mapView)
        lastTapPoint = point
        
        let alertVC = UIAlertController(title: "Add marker", message: "In coords: \(coords.longitude), \(coords.latitude)", preferredStyle: .actionSheet)
        alertVC.addAction(UIAlertAction(title: "Confirm", style: .default) { _ in
            let vc = AddingVC.instantiate()
            vc.coords = coords
            self.navigationController?.pushViewController(vc, animated: true)
        })
        alertVC.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alertVC, animated: true)
    }
}

extension MapVC: HandleMapSearch {
    func dropPinZoomIn(placemark: MKPlacemark) {
        if let annotation = selectedAnnotation {
            mapView.removeAnnotation(annotation)
        }
        
        let annotation = SearchAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.title = placemark.name
        if let city = placemark.locality, let state = placemark.administrativeArea {
            annotation.subtitle = "\(city) \(state)"
        }
        
        selectedAnnotation = annotation
        mapView.addAnnotation(annotation)
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: placemark.coordinate, span: span)
        mapView.setRegion(region, animated: true)
    }
}

extension MapVC: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if let annotation = annotation as? Property  {
            let annotationView = PropertyMarkerAnnotationView(annotation: annotation, reuseIdentifier: PropertyMarkerAnnotationView.identifier)
            
            return annotationView
        } else if annotation is SearchAnnotation {
            let identifier = "pin"
            var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView
            if pinView == nil {
                pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            }
            
            pinView?.pinTintColor = UIColor.orange
            pinView?.canShowCallout = true

            return pinView
        }
        
        return nil

    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let property = view.annotation as? Property else { return }
        
        let calloutView: HouseDetailView = .loadFromNib()
        calloutView.delegate = self
        calloutView.setup(annotation: property)
        setupImage(for: calloutView.houseImageView, with: property.id)
        
        calloutView.center = CGPoint(x: 3, y: -calloutView.frame.height)
        view.addSubview(calloutView)
        mapView.setCenter((view.annotation?.coordinate)!, animated: true)
    }

    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        if view.isKind(of: PropertyMarkerAnnotationView.self) {
            for subview in view.subviews where subview is HouseDetailView {
                subview.removeFromSuperview()
            }
        }
    }
    
}

extension MapVC : CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            print("location:: \(location)")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error:: \(error)")
    }

}

extension MapVC: HouseDetailViewDelegate {
    func showMoreButtonPressed(annotation: Property) {
        let vc = DetailedVC.instantiate()
        vc.property = annotation
        navigationController?.pushViewController(vc, animated: true)
    }
    
}

extension MapVC: FilterCardVCDelegate {
    func filterChangedValue(item: PropertyFilterItem) {
        refreshMapView(with: item)
    }
    
}
