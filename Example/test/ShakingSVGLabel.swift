//
//  ShakingSVGLabel.swift
//  test
//
//  Created by Zhixuan Lai on 4/30/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit
import Cartography

class ShakingSVGLabel: UIView {

    let svgView : SVGView!
    let labelContainer = UIView()
    let label = UILabel()
    let button = UIButton()

    var onTap: SVGButtonViewOnTapHandler?

    var text = "" {
        didSet {
            label.text = text

            let width = max(self.label.intrinsicContentSize().width, 20) + 10

            constrain(labelContainer, self) { label, view in
                label.width == width
            }
        }
    }

    func setTextShaking(text: String) {
        self.text = text
        // animate label
        label.center = CGPointMake(label.center.x, label.center.y + 10)

        UIView.animateWithDuration(0.2, delay: 0, usingSpringWithDamping: 0.05, initialSpringVelocity: 0.5, options: [], animations: {
            self.label.center = self.labelContainer.convertPoint(self.labelContainer.center, fromView: self.labelContainer.superview)
            }) { (completed) in
                //
        }
    }

    init(frame: CGRect, SVGFileName: String, color: UIColor) {
        svgView = SVGView(frame: frame, SVGFileName: SVGFileName, color: color)

        super.init(frame: frame)

        label.textAlignment = .Right

        button.forControlEvents(.TouchUpInside) { (button) in
            if let onTap = self.onTap {
                onTap()
            }
        }

        addSubview(svgView)
        addSubview(labelContainer)
        addSubview(button)

        labelContainer.addSubview(label)

        constrain(svgView, labelContainer, button, self) { svgView, label, button, view in
            svgView.left == view.left
            svgView.top == view.top
            svgView.bottom == view.bottom
            svgView.width == svgView.height

            label.left == svgView.right
            label.top == view.top
            label.bottom == view.bottom
            label.right == view.right

            button.edges == view.edges
        }

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        label.frame = labelContainer.bounds
        self.label.center = self.labelContainer.convertPoint(self.labelContainer.center, fromView: self.labelContainer.superview)
    }

}
