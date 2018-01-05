//
//  PhotoCollectionCell.swift
//  VirtualTourist
//
//  Created by Noureddine Marigh on 12/05/17.
//  Copyright © 2017 NM. All rights reserved.
//

import UIKit

class PhotoCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func awakeFromNib() {
        activityIndicator.color = UIColor.lightGray
    }
}
