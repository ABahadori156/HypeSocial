//
//  FancyField.swift
//  HypeSocial
//
//  Created by Pasha Bahadori on 9/20/16.
//  Copyright © 2016 Pelican. All rights reserved.
//

import UIKit

class FancyField: UITextField {

    override func awakeFromNib() {
        super.awakeFromNib()
            
        layer.borderColor = UIColor(red: SHADOW_GRAY, green: SHADOW_GRAY, blue: SHADOW_GRAY, alpha: 0.2).cgColor
        layer.borderWidth = 1.0
        layer.cornerRadius = 2.0
        
    }
    
    
    //This makes the text go 10 in from the left so the text in the field isn't all the way to the left
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: 10, dy: 5)
    }
    
    //Makes the text WHILE WE'RE EDITING THE FIELD go 10 in from the left
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: 10, dy: 5)
    }

}
