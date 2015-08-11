//
//  PPProgressCircle.swift
//  ToDo
//
//  Created by David Pirih on 20.07.15.
//  Copyright © 2015 Piri-Piri. All rights reserved.
//

import UIKit

class PPProgressCircle {
    
    static func progessCircleForPercent(percent: Double, radius: CGFloat, lineWidth: CGFloat = 4.0, backgroundColor: UIColor = KColorRed, completedColor: UIColor = KColorGreen, strokeColor: UIColor = UIColor.lightGrayColor()) -> UIImage {
        
        return progessCircleForValue(percent / 100, radius: radius, lineWidth: lineWidth, backgroundColor: backgroundColor, completedColor: completedColor, strokeColor: strokeColor)
    }
    
    static func progessCircleForValue(value: Double, radius: CGFloat, lineWidth: CGFloat = 4.0, backgroundColor: UIColor = KColorRed, completedColor: UIColor = KColorGreen, strokeColor: UIColor = UIColor.blackColor()) -> UIImage {
        let center = CGPointMake(radius, radius)
        let size = CGSizeMake(2 * radius, 2 * radius)
            
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        
        let strokeCirclePath = UIBezierPath(arcCenter: center, radius: radius - lineWidth, startAngle: CGFloat(0), endAngle: CGFloat(2 * M_PI), clockwise: true)
        strokeColor.setStroke()
        strokeCirclePath.lineWidth = 6.0
        strokeCirclePath.stroke()
        
        let circlePath = UIBezierPath(arcCenter: center, radius: radius - lineWidth, startAngle: CGFloat(0), endAngle: CGFloat(2 * M_PI), clockwise: true)
        circlePath.lineWidth = lineWidth
        backgroundColor.setStroke()
        circlePath.stroke()
        
        let startAngle = CGFloat(-M_PI_2) // start at 12
        let endAngle = startAngle + CGFloat(2 * M_PI * value)
        
        let completedPath = UIBezierPath(arcCenter: center, radius: radius - lineWidth, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        completedPath.lineCapStyle = CGLineCap.Round
        completedPath.lineWidth = lineWidth
        completedColor.setStroke()
        completedPath.stroke()
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
}
