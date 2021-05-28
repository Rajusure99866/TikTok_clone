//
//  CALayer+Extension.swift
//  Assignment_F
//
//  Created by Raju on 19/02/21.
//  Copyright © 2021 Raju. All rights reserved.
//

import Foundation
import Foundation
import UIKit

extension CALayer{
    func giveShadowToTableViewCell(layer:CALayer,Bounds:CGRect , cornerRadius:CFloat) {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = .zero
        layer.shadowRadius = 4.0
        layer.shadowOpacity = 0.8
        layer.masksToBounds = false
        layer.shadowPath = UIBezierPath(roundedRect: Bounds, cornerRadius: CGFloat(cornerRadius)).cgPath
    }
}

