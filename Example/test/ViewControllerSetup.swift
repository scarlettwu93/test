//
//  ViewControllerSetup.swift
//  test
//
//  Created by Zhixuan Lai on 5/1/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit
import ZLSwipeableViewSwift

import Cartography
import NVActivityIndicatorView

extension ViewController {
    // Mark: - Setup

    func setupContainers() {
        view.backgroundColor = backgroundColor

        view.addSubview(topContainer)
        view.addSubview(middleContainer)
        view.addSubview(bottomContainer)


        topContainer.topAnchor.constraintEqualToAnchor(topLayoutGuide.bottomAnchor, constant: 0).active = true
        topContainer.heightAnchor.constraintEqualToConstant(topContainerHeight).active = true

        middleContainer.topAnchor.constraintEqualToAnchor(topContainer.bottomAnchor, constant: 0).active = true
        middleContainer.heightAnchor.constraintEqualToConstant(view.bounds.width).active = true

        bottomContainer.topAnchor.constraintEqualToAnchor(middleContainer.bottomAnchor, constant: 0).active = true
        bottomContainer.heightAnchor.constraintGreaterThanOrEqualToConstant(bottomContainerHeight).active = true
        bottomContainer.bottomAnchor.constraintEqualToAnchor(bottomLayoutGuide.topAnchor, constant: 0).active = true

        [topContainer, middleContainer, bottomContainer].forEach {subview in
            subview.translatesAutoresizingMaskIntoConstraints = false
            subview.widthAnchor.constraintEqualToAnchor(view.widthAnchor, multiplier: 1).active = true
            subview.leftAnchor.constraintEqualToAnchor(view.leftAnchor, constant: 0).active = true
        }
    }

    func setupTimerAndCounters() {

        timerLabel.text = keyword
        likeCounterLabel.text = "0"
        unlikeCounterLabel.text = "0"


        timerLabel.onTap = {
            let alertController = UIAlertController(title: "Change Keyword", message: "eg. Brunch, BBQ, Thai, Tacos", preferredStyle: .Alert)

            alertController.addTextFieldWithConfigurationHandler({ (textfield) in
                textfield.text = self.keyword
            })
            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in

            }
            alertController.addAction(cancelAction)

            let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
                self.keyword = alertController.textFields![0].text!
            }
            alertController.addAction(OKAction)

            self.presentViewController(alertController, animated: true, completion: nil)

        }

        topContainer.addSubview(timerLabel)
        topContainer.addSubview(likeCounterLabel)
        topContainer.addSubview(unlikeCounterLabel)
        constrain(unlikeCounterLabel, likeCounterLabel, timerLabel, topContainer) { view1, view2, view3, topContainer in

            [view1, view2, view3].forEach { view in
                view.top == topContainer.centerY * 0.5
                view.height == labelHeight
            }

            view1.left == topContainer.left + 20
            view2.left == view1.right + 20
            view3.right == topContainer.right - 20
        }

    }

    func setupSwipeableView() {

        let indicatorViewWidth = CGFloat(150)
        let indicatorView = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: indicatorViewWidth, height: indicatorViewWidth), type: .BallScaleMultiple, color: UIColor.flatPumpkinColor())
        middleContainer.addSubview(indicatorView)
        constrain(indicatorView, middleContainer) { indicatorView, view in
            indicatorView.center == view.center
            indicatorView.width == indicatorViewWidth
            indicatorView.height == indicatorViewWidth
        }
        indicatorView.startAnimation()

        swipeableView = ZLSwipeableView(frame: view.bounds)
        middleContainer.addSubview(swipeableView)
        let horizontalMargin = CGFloat(10)
        constrain(swipeableView, middleContainer) { swipeableView, view in
            swipeableView.center == view.center
            swipeableView.height == view.height - horizontalMargin * 2
            swipeableView.left == view.left + horizontalMargin
            swipeableView.right == view.right - horizontalMargin
        }

        func scaleAndTranslateView(view: UIView, scale: CGFloat, translation: CGPoint, duration: NSTimeInterval, offsetFromCenter offset: CGPoint, swipeableView: ZLSwipeableView) {
            let block = {
                view.center = swipeableView.convertPoint(swipeableView.center, fromView: swipeableView.superview)
                var transform = CGAffineTransformMakeTranslation(offset.x, offset.y)
                transform = CGAffineTransformScale(transform, scale, scale)
                transform = CGAffineTransformTranslate(transform, -offset.x, -offset.y)
                transform = CGAffineTransformTranslate(transform, translation.x, translation.y)
                view.transform = transform
            }
            if duration == 0 {
                block()
                return
            }
            UIView.animateWithDuration(duration, delay: 0, options: .AllowUserInteraction, animations: block, completion: nil)
        }
        swipeableView.numberOfActiveView = 3
        swipeableView.animateView = {(view: UIView, index: Int, views: [UIView], swipeableView: ZLSwipeableView) in
            let scale = 1.0 - 0.05 * CGFloat(index)
            let offset = CGPointZero//CGPoint(x: 0, y: CGRectGetHeight(swipeableView.bounds) * 0.3)
            let translation = CGPoint(x: 0, y: CGFloat(index * -18))
            let duration = views.count > 1 && index == views.count - 1 ? 0 : 0.4
            scaleAndTranslateView(view, scale: scale, translation: translation, duration: duration, offsetFromCenter: offset, swipeableView: swipeableView)
        }

        swipeableView.nextView = self.nextView
        swipeableView.numberOfHistoryItem = 1// UInt.max

        swipeableView.didStart = {view, location in
            self.likeButton.selected = false
            self.unlikeButton.selected = false
            self.bottomButtonContainer.userInteractionEnabled = false
        }

        swipeableView.swiping = {view, location, translation in
            if translation.x > 0 {
                self.likeButton.selected = true
                self.unlikeButton.selected = false
            } else if translation.x < 0 {
                self.likeButton.selected = false
                self.unlikeButton.selected = true
            }
        }
        swipeableView.didEnd = {view, location in
            self.likeButton.selected = false
            self.unlikeButton.selected = false
            self.bottomButtonContainer.userInteractionEnabled = true
        }

        swipeableView.didSwipe = {view, direction, vector in
            guard let foodImageView = view as? FoodImageView else {return}
            if direction == .Left {
                self.handleDislike(foodImageView.foodImage)
            } else {
                self.handleLike(foodImageView.foodImage)
            }
        }
    }

    func setupBottonButtoms() {

        likeButton.onTap = {button in
            self.swipeableView.swipeTopView(inDirection: .Right)
        }
        unlikeButton.onTap = {button in
            self.swipeableView.swipeTopView(inDirection: .Left)
        }
        undoButton.onTap = {button in
            self.swipeableView.rewind()
            self.handleRewind()
        }
        pauseButton.onTap = {button in
            self.showResults()
        }

        bottomContainer.addSubview(likeButton)
        bottomContainer.addSubview(undoButton)
        bottomContainer.addSubview(unlikeButton)
        bottomContainer.addSubview(pauseButton)
        constrain(undoButton, unlikeButton, likeButton, pauseButton, bottomContainer) { view1, view2, view3, view4, bottomContainer in

            var i = 1
            [view1, view2, view3, view4].forEach { view in
                view.centerY == bottomContainer.centerY * 0.8
                view.right == (bottomContainer.right - 20) * (CGFloat(i) / 4)
                view.height == buttonHeight
                view.width == view.height
                i += 1
            }
            
        }
    }
    
}
