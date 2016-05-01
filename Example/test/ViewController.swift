//
//  ViewController.swift
//  test
//
//  Created by Siyu Wu on 04/27/2016.
//  Copyright (c) 2016 Siyu Wu. All rights reserved.
//

import UIKit
import ZLSwipeableViewSwift
import Cartography
import UIColor_FlatColors
import SwiftLocation
import NVActivityIndicatorView

let backgroundColor = UIColor(red: 0.949, green: 0.949, blue: 0.949, alpha: 1.000)


// TODO: handle Location failure

@available(iOS 9.0, *)
class ViewController: UIViewController {

    // Mark: Data
    var foodImages = [FoodImage]() {
        didSet {
            nextImageIndex = 0
            print(foodImages.count)
        }
    }
    var nextImageIndex = 0

    let topContainer = UIView()
    let topContainerHeight = CGFloat(80)
    let labelHeight = CGFloat(20)
    let timerLabel = ShakingSVGLabel(frame: CGRectZero, SVGFileName: "search", color: UIColor.flatPeterRiverColor())
    let likeCounterLabel = ShakingSVGLabel(frame: CGRectZero, SVGFileName: "heart", color: UIColor.flatAlizarinColor())
    let unlikeCounterLabel = ShakingSVGLabel(frame: CGRectZero, SVGFileName: "cross", color: UIColor.flatConcreteColor())

    // middle
    let middleContainer = UIView()
    var swipeableView: ZLSwipeableView!

    // bottom
    let bottomContainer = UIView()
    let bottomButtonContainer = UIView()
    let bottomContainerHeight = CGFloat(120)
    let buttonHeight = CGFloat(70)
    let pauseButton = SVGButtonView(frame: CGRectZero, SVGFileName: "pause", color: UIColor.flatPeterRiverColor())
    let likeButton = SVGButtonView(frame: CGRectZero, SVGFileName: "heart", color: UIColor.flatAlizarinColor())
    let undoButton = SVGButtonView(frame: CGRectZero, SVGFileName: "reload", color: UIColor.flatEmeraldColor())
    let unlikeButton = SVGButtonView(frame: CGRectZero, SVGFileName: "cross", color: UIColor.flatConcreteColor())


    var keyword = "restaurants" {
        didSet {
            timerLabel.text = keyword
            searchForFoodImages()
        }
    }
    var coordinateString = defaultCoordinateString {
        didSet {
            searchForFoodImages()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBarHidden = true

        setupContainers()
        setupTimerAndCounters()
        setupSwipeableView()
        setupBottonButtoms()

        startListeningLocation()
    }

    func startListeningLocation() {
        try! SwiftLocation.shared.currentLocation(.Neighborhood, timeout: 10, onSuccess: { location in
            // location contain your CLLocation object
            if let coordinate = location?.coordinate {
                self.coordinateString = "\(coordinate.latitude),\(coordinate.longitude)"
            } else {
                self.coordinateString = defaultCoordinateString
            }

        }) { error in
            print(error)
            self.coordinateString = defaultCoordinateString
        }

    }

    func searchForFoodImages() {
        Business.searchWithTerm(keyword, location: coordinateString, completion: { (businesses: [Business]?, error: NSError!) in
            guard let businesses = businesses else {return}

            self.foodImages = businesses.flatMap {business in
                guard let imageURL = business.imageURL, name = business.name else {return nil}
                let fileName = imageURL.lastPathComponent!
                let largeImageURL = imageURL.URLByDeletingLastPathComponent!.URLByAppendingPathComponent(fileName.stringByReplacingOccurrencesOfString("ms", withString: "l"))
                return FoodImage(imageURL: largeImageURL, descirption: name)
            }

            self.swipeableView.discardViews()
            self.swipeableView.loadViews()

//            for business in businesses {
//                print(business.name!)
//                print(business.address!)
//            }
        })

    }

    var swipedFoodImages = [(FoodImage, Bool)]()
    var likeImageCount = 0
    var unlikeImageCount = 0

    func handleLike(foodImage: FoodImage) {
        swipedFoodImages.append((foodImage, true))
        likeImageCount += 1
        likeCounterLabel.setTextShaking("\(likeImageCount)")
    }

    func handleDislike(foodImage: FoodImage) {
        swipedFoodImages.append((foodImage, false))
        unlikeImageCount += 1
        unlikeCounterLabel.setTextShaking("\(unlikeImageCount)")
    }

    func handleRewind() {
        guard let (_, liked) = swipedFoodImages.popLast() else { return }
        if liked {
            likeImageCount -= 1
            likeCounterLabel.text = ("\(likeImageCount)")
        } else {
            unlikeImageCount -= 1
            unlikeCounterLabel.text = ("\(unlikeImageCount)")
        }

    }
    
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
        swipeableView.numberOfHistoryItem = UInt.max

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

    func nextView() -> UIView? {
        guard nextImageIndex < foodImages.count else { return nil }

        let foodImage = foodImages[nextImageIndex]
        nextImageIndex += 1

        let frame = CGRect(x: 0, y: 0, width: swipeableView.frame.width, height: swipeableView.frame.height)
        let imageView = FoodImageView(frame: frame, foodImage: foodImage)
        imageView.backgroundColor = backgroundColor
        imageView.center = swipeableView.convertPoint(swipeableView.center, fromView: swipeableView.superview)
        return imageView
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

