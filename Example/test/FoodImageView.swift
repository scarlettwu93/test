//
//  FoodImageView.swift
//  test
//
//  Created by Zhixuan Lai on 4/28/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit
import Cartography

private let CornerRadius = CGFloat(8)
class FoodImageView : UIView {

    var foodImage: FoodImage

    let imageView = UIImageView(frame: CGRectZero)
    let label = UILabel()

    let contentView = UIView()

    init(frame: CGRect, foodImage: FoodImage) {
        self.foodImage = foodImage
        super.init(frame: frame)
        setup()

        contentView.layer.cornerRadius = CornerRadius
        contentView.layer.masksToBounds = true
        addSubview(contentView)
        backgroundColor = UIColor.whiteColor()

        imageView.setImageWithURL(foodImage.largeImageURL)
        imageView.contentMode = .ScaleAspectFill
        imageView.clipsToBounds = true
        label.text = foodImage.descirption
//        label.adjustsFontSizeToFitWidth = true
        label.numberOfLines = 1

        contentView.addSubview(imageView)
        contentView.addSubview(label)
        contentView.translatesAutoresizingMaskIntoConstraints = false

        let labelHorizontalMargin = CGFloat(10)

        constrain(contentView, self) { view1, view2 in
            view1.left == view2.left
            view1.top == view2.top
            view1.width == self.bounds.width
            view1.height == self.bounds.height
        }

        constrain(contentView, imageView, label) { (view, image, label) in
            image.left == view.left + labelHorizontalMargin
            image.right == view.right - labelHorizontalMargin
            image.top == view.top + labelHorizontalMargin
            image.bottom == label.top
            label.left == view.left + labelHorizontalMargin
            label.right == view.right - labelHorizontalMargin
            label.bottom == view.bottom

            image.height == view.height - 60
//            image.height == image.width + 60
        }

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }



    func setup() {
        // Shadow
        layer.shadowColor = UIColor.blackColor().CGColor
        layer.shadowOpacity = 0.1
        layer.shadowOffset = CGSizeMake(0, 1.5)
        layer.shadowRadius = 4.0
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.mainScreen().scale

        // Corner Radius
        layer.cornerRadius = CornerRadius;
    }

}
