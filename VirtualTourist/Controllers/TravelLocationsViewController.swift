//
//  TravelLocationsViewController.swift
//  VirtualTourist
//
//  Created by Noureddine Marigh on 12/05/17.
//  Copyright © 2017 NM. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class TravelLocationsViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var editPinsLabel: UILabel!
    
            var longPressGestureRecognizer: UILongPressGestureRecognizer!
            var mapPin: Pin!
            var editPins: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

            editPins = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(self.editPins(_:)))
            navigationItem.rightBarButtonItem = editPins
            editPinsLabel.isHidden = true
        
            // Loading Annotations
            annotations()
    }
    
    override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressRecognized(_:)))
            mapView.addGestureRecognizer(longPressGestureRecognizer)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
            mapView.removeGestureRecognizer(longPressGestureRecognizer)
    }
    
    
    // MARK: Long Press Recognizer for Pins
    @objc func longPressRecognized(_ longPress: UIGestureRecognizer) {
        
        if !isEditing && longPress.state == .began {
            let location = longPress.location(in: mapView)
            let coordinates = mapView.convert(location, toCoordinateFrom: mapView)
            let pin = Pin(latitude: coordinates.latitude, longitude: coordinates.longitude, context: CoreDataStackManager.sharedInstance().managedObjectContext)
            let annotateMap = PinAnnotation(objectID: pin.objectID, title: nil, subtitle: nil, coordinate: coordinates)
            mapView.addAnnotation(annotateMap)
        }
        
            CoreDataStackManager.sharedInstance().saveObjectContext()
    }
    
    
    // MARK: Adding Annotations
    func annotations() {
            let fetchRequest = NSFetchRequest<Pin>(entityName: "Pin")
        
            do {
        if let pins = try? CoreDataStackManager.sharedInstance().managedObjectContext.fetch(fetchRequest) {
            var annotateMap = [PinAnnotation]()
            for pin in pins {
                let latitude = CLLocationDegrees(truncating: pin.latitude!)
                let longitude = CLLocationDegrees(truncating: pin.longitude!)
            let coordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            annotateMap.append(PinAnnotation(objectID: pin.objectID, title: nil, subtitle: nil, coordinate: coordinates))
            }
            
            // Adding annotations
            mapView.addAnnotations(annotateMap)
            }
        }
    }
    
    // MARK: Managing Map View
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        mapView.deselectAnnotation(view.annotation, animated: false)
        
            do {
            let pinAnnotation = view.annotation as! PinAnnotation
            let fetchRequest = NSFetchRequest<Pin>(entityName: "Pin")
            let predicate = NSPredicate(format: "latitude == %@ AND longitude == %@", argumentArray: [pinAnnotation.coordinate.latitude, pinAnnotation.coordinate.longitude])
            fetchRequest.predicate = predicate
            let pins = try CoreDataStackManager.sharedInstance().managedObjectContext.fetch(fetchRequest)
            mapPin = pins[0]
            
            }
            catch let error as NSError {
            print("unable to obtain pins")
            print(error.localizedDescription)
            return
        }
        
        if isEditing {
            mapView.removeAnnotation(view.annotation!)
            CoreDataStackManager.sharedInstance().managedObjectContext.delete(mapPin)
            CoreDataStackManager.sharedInstance().saveObjectContext()
            return
        }
        else {
            performSegue(withIdentifier: Segue.segueToPhotos, sender: self)
        }
    }
    
    // MARK: Editing Pins
    @objc func editPins(_ sender: UIBarButtonItem) {
        if isEditing {
            editPins.title = "Edit"
            editPinsLabel.isHidden = true
            setEditing(false, animated: true)
        }
        else {
            editPins.title = "Done"
            editPinsLabel.isHidden = false
            setEditing(true, animated: true)
        }
    }
    
    // MARK: Segue to Photos
    fileprivate struct Segue {
        static let segueToPhotos = "segueToPhotos"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // Reachability
        if currentReachabilityStatus == .notReachable {
            noInternetAlert(title: "⚠️", message: "No Internet Connection")
        }
        else {
        if segue.identifier == Segue.segueToPhotos {
        if let photoAlbumViewController = segue.destination as? PhotosCollectionViewController {
            photoAlbumViewController.mapView = mapView
            photoAlbumViewController.pin = mapPin
        if let photos = mapPin!.photos?.allObjects as? [Photo] {
            photoAlbumViewController.photos = photos
            }
          }
        }
      }
   }
}
