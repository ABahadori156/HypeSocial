//
//  FacebookButton.swift
//  HypeSocial
//
//  Created by Pasha Bahadori on 9/20/16.
//  Copyright © 2016 Pelican. All rights reserved.
//

import UIKit

class FacebookButton: UIButton {

 
    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.shadowColor = UIColor(red: SHADOW_GRAY, green: SHADOW_GRAY, blue: SHADOW_GRAY, alpha: SHADOW_GRAY).cgColor
        layer.shadowOpacity = 0.8
        layer.shadowRadius = 5.0
        layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        imageView?.contentMode = .scaleAspectFit
        
        
    }
    
    //Perfect Circle buttons
    override func layoutSubviews() {
        super.layoutSubviews()
        
        //The frame size has been laid out so we can use it in our calculation
        layer.cornerRadius = self.frame.width / 2
    }
    
}
