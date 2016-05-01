//
//  SVGButton.swift
//  test
//
//  Created by Zhixuan Lai on 4/29/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit
import ReactiveUI
import Cartography
import UIColor_FlatColors

typealias SVGButtonViewOnTapHandler = () -> Void

private let buttonBackgroundColor = UIColor(red: 0.910, green: 0.910, blue: 0.910, alpha: 1.000)
private let buttonBackgroundColorSelected = UIColor.flatSilverColor()

class SVGButtonView: UIView {

    let button = UIButton()

    var selected = false {
        didSet {
            UIView.animateWithDuration(0.2) {
                let color = self.selected ? buttonBackgroundColorSelected : buttonBackgroundColor
                self.layer.backgroundColor = color.CGColor
            }
        }
    }

    var onTap: SVGButtonViewOnTapHandler?

    init(frame: CGRect, SVGFileName: String, color: UIColor) {
        super.init(frame: frame)

        button.forControlEvents(.TouchDown) { (button) in
            self.selected = true
        }
        button.forControlEvents([.TouchUpInside, .TouchUpOutside, .TouchCancel]) { (button) in
            self.selected = false
        }
        button.forControlEvents(.TouchUpInside) { (button) in
            if let onTap = self.onTap {
                onTap()
            }
        }

        layer.backgroundColor = buttonBackgroundColor.CGColor
        layer.masksToBounds = true

        let svgView = SVGView(frame: frame, SVGFileName: SVGFileName, color: color)
        addSubview(svgView)
        let svgMargin = CGFloat(18)
        constrain(svgView, self) { view1, view2 in
            view1.edges == inset(view2.edges, svgMargin)
        }

        addSubview(button)
        constrain(button, self) { view1, view2 in
            view1.edges == view2.edges
        }

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = frame.width / 2
    }

}
