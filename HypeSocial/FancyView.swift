//
//  FancyView.swift
//  HypeSocial
//
//  Created by Pasha Bahadori on 9/20/16.
//  Copyright © 2016 Pelican. All rights reserved.
//

import UIKit

class FancyView: UIView {

    //Set up the shadows
    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.shadowColor = UIColor(red: SHADOW_GRAY, green: SHADOW_GRAY, blue: SHADOW_GRAY, alpha: SHADOW_GRAY).cgColor
        layer.shadowOpacity = 0.8
        layer.shadowRadius = 5.0    //The radius is how far the shadow blurs out
        layer.shadowOffset = CGSize(width: 1.0, height: 1.0)    //This is the bounds of the view
        layer.cornerRadius = 2.0
    }

}
