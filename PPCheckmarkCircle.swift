//
//  PPCheckmarkCircle.swift
//  ToDo
//
//  Created by David Pirih on 16.07.15.
//  Copyright © 2015 Piri-Piri. All rights reserved.
//

import UIKit

class PPCheckmarkCircle {
    
    static func checkCircle(checked: Bool, radius: CGFloat, lineWidth: CGFloat = 4.0, checkedBackgroundColor: UIColor = KColorGreen, uncheckedBackgroundColor: UIColor = KColorRed, strokeColor: UIColor = UIColor.lightGrayColor()) -> UIImage {
        
        let center = CGPointMake(radius, radius)
        let size = CGSizeMake(2 * radius, 2 * radius)

        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        
        let strokeCirclePath = UIBezierPath(arcCenter: center, radius: radius - lineWidth, startAngle: CGFloat(0), endAngle: CGFloat(2 * M_PI), clockwise: true)
        strokeColor.setStroke()
        strokeCirclePath.lineWidth = 6.0
        strokeCirclePath.stroke()
        
        let circlePath = UIBezierPath(arcCenter: center, radius: radius - lineWidth, startAngle: CGFloat(0), endAngle: CGFloat(2 * M_PI), clockwise: true)
        circlePath.lineWidth = lineWidth
        
        (checked ? checkedBackgroundColor : uncheckedBackgroundColor).setStroke()
        circlePath.stroke()

        if checked {
            let checkmark = "✔︎"
            let fontAtributes = [
                NSFontAttributeName : UIFont.boldSystemFontOfSize(radius * 2.2),
                NSForegroundColorAttributeName : UIColor.darkGrayColor()
            ]
            checkmark.drawAtPoint(CGPointMake(radius / 2.5, -radius / 2), withAttributes: fontAtributes)
        }
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return image
    }
    
}
