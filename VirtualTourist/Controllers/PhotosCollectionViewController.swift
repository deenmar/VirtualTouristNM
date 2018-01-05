//
//  PhotosCollectionViewController.swift
//  VirtualTourist
//
//  Created by Noureddine Marigh on 12/05/17.
//  Copyright © 2017 NM. All rights reserved.
//

import UIKit
import MapKit

class PhotosCollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
   
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var noImagesLabel: UILabel!
    @IBOutlet weak var newCollectionButton: UIBarButtonItem!
    
        var pin: Pin!
        var photos = [Photo]()
        var selectedIndexes = [IndexPath]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
            noImagesLabel.isHidden = true
            collectionView.dataSource = self
            collectionView.delegate = self
        
         if let mapView = mapView {
            let center = CLLocationCoordinate2D(latitude: CLLocationDegrees(truncating: pin.latitude!), longitude: CLLocationDegrees(truncating: pin.longitude!))
            let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
            let region = MKCoordinateRegionMake(center, span)
            
            mapView.setRegion(region, animated: true)
            mapView.isUserInteractionEnabled = false
            
            // Adding annotation
            let annotation = MKPointAnnotation()
            annotation.coordinate = center
            mapView.addAnnotation(annotation)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Checking for new Photos
        if photos.count == 0 {
            newCollectionButton.isEnabled = false
            newPhotosCollection()
        }
    }
    
    // New photo collection
    @IBAction func newCollectionButtonTapped(_ sender: UIBarButtonItem) {
        
        // Reachability
        if currentReachabilityStatus == .notReachable {
            noInternetAlert(title: "⚠️", message: "No Internet Connection")
        }
            
        else {
        if selectedIndexes.isEmpty {
            pin.removePhotos(CoreDataStackManager.sharedInstance().managedObjectContext)
            photos.removeAll(keepingCapacity: true)
                
            // Reloading collection view
            collectionView.reloadData()
                
            // New collection
            newPhotosCollection()
            }
        else {
            var selectedPhotos = [Photo]()
            collectionView.performBatchUpdates ({
                    
            let sortedIndexes = self.selectedIndexes.sorted {($0 as NSIndexPath).row > ($1 as NSIndexPath).row}
            for indexPath in sortedIndexes {
            let photoObject = self.photos[(indexPath as NSIndexPath).row]
            self.photos.remove(at: (indexPath as NSIndexPath).row)
            self.collectionView.deleteItems(at: [indexPath])
            selectedPhotos.append(photoObject)
              }
            }, completion: { (completed) in
                        
        if self.photos.count == 0 {
            DispatchQueue.main.async {
            self.noImagesLabel.text = "No Images Found :("
            self.noImagesLabel.isHidden = false
            CoreDataStackManager.sharedInstance().saveObjectContext()
             }
        }
          })
                
            for photo in selectedPhotos {
            CoreDataStackManager.sharedInstance().managedObjectContext.delete(photo)
            }
            CoreDataStackManager.sharedInstance().saveObjectContext()
            selectedIndexes = [IndexPath]()
            collectionView.reloadData()
            editNewCollectionbutton()
            }
        }
    }
    
    // MARK: Managing New Collection button
    fileprivate func editNewCollectionbutton() {
            newCollectionButton.title = selectedIndexes.count > 0 ? "Remove Selected Photos" : "New Collection"
            newCollectionButton.tintColor = newCollectionButton.title == "Remove Selected Photos" ? UIColor.red : UIColor(red: 0, green: 0.48, blue: 1, alpha: 1)
    }
    
    // MARK: Getting New Collection
    func newPhotosCollection() {
            FlickrClient().photosLocationsPinned(pin, context: CoreDataStackManager.sharedInstance().managedObjectContext) {
            (photos, error) in
            guard error == nil else {
                print(error as Any)
            return
            }
                
        if let photos = photos {
            for photo in photos {
            photo.pin = self.pin
            }
            DispatchQueue.main.async {
            self.photos = photos
            CoreDataStackManager.sharedInstance().saveObjectContext()
            }
            DispatchQueue.main.async {
        if self.photos.count == 0 {
            self.noImagesLabel.text = "No Images Found"
            self.noImagesLabel.isHidden = false
            }
        else {
            self.noImagesLabel.isHidden = true
            }
            self.collectionView.reloadData()
            self.newCollectionButton.isEnabled = true
            }
          }
        }
    }
    
    // MARK: CollectionView functions
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionPhotoCell", for: indexPath) as! PhotoCollectionCell
            let photo = photos[(indexPath as NSIndexPath).row]
        
        if let getImage = photo.getImage() {
            cell.photoImageView.image = getImage
        }
        else {
            // Photo Placeholder
            cell.photoImageView.image = UIImage(named: "imgPlaceholder.png")
            
            // Activity Indicator
            cell.activityIndicator.isHidden = false
            cell.activityIndicator.startAnimating()
            FlickrClient().imageData(photo) {
                (imageData, error) in
            guard error == nil else {
            return
            }
                
            DispatchQueue.main.async {
            cell.activityIndicator.isHidden = true
            cell.activityIndicator.stopAnimating()
            cell.photoImageView.image = UIImage(data: imageData!)
            }
          }
        }
        cell.photoImageView.alpha = 1.0
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            let cell = collectionView.cellForItem(at: indexPath) as! PhotoCollectionCell
        
        if let index = selectedIndexes.index(of: indexPath) {
            selectedIndexes.remove(at: index)
            cell.photoImageView.alpha = 1.0
        }
        else {
            selectedIndexes.append(indexPath)
            cell.photoImageView.alpha = 0.3
        }
            editNewCollectionbutton()
    }
}
