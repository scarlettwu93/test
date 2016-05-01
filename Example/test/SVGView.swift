//
//  SVGView.swift
//  test
//
//  Created by Zhixuan Lai on 4/30/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit
import SwiftSVG

class SVGView: UIView {
    let path: UIBezierPath
    let SVGLayer: CAShapeLayer

    init(frame: CGRect, SVGFileName: String, color: UIColor) {
        let svgURL = NSBundle.mainBundle().URLForResource(SVGFileName, withExtension: "svg")!
        SVGLayer = CAShapeLayer()

        path = UIBezierPath.pathWithSVGURL(svgURL)!

        SVGLayer.path = path.CGPath

        SVGLayer.fillColor = color.CGColor
        SVGLayer.strokeColor = color.CGColor

        super.init(frame: frame)

        layer.addSublayer(SVGLayer)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let SVGLayerFrame = bounds
        SVGLayer.frame = SVGLayerFrame

        let pathCopy = UIBezierPath(CGPath: path.CGPath)

        var transform = CGAffineTransformIdentity
        let scale = SVGLayerFrame.width / max(path.bounds.height, path.bounds.width)
        transform = CGAffineTransformScale(transform, scale, scale)
        pathCopy.applyTransform(transform)

        transform = CGAffineTransformIdentity
        transform = CGAffineTransformTranslate(transform, (SVGLayerFrame.width - pathCopy.bounds.width) / 2, (SVGLayerFrame.height - pathCopy.bounds.height) / 2)
        pathCopy.applyTransform(transform)
        
        SVGLayer.path = pathCopy.CGPath
    }


}
