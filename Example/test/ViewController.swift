//
//  ViewController.swift
//  test
//
//  Created by Siyu Wu on 04/27/2016.
//  Copyright (c) 2016 Siyu Wu. All rights reserved.
//

import UIKit
import ZLSwipeableViewSwift

import UIColor_FlatColors
import SwiftLocation

let backgroundColor = UIColor(red: 0.949, green: 0.949, blue: 0.949, alpha: 1.000)


// TODO: handle Location failure

@available(iOS 9.0, *)
class ViewController: UIViewController {

    // Mark: Data
    var parameters = YelpSearchParameters()
    var searchResults: SearchResults! {
        didSet {
            swipeableView.discardViews()
            swipedFoodImages = [(FoodImage, Bool)]()
            likeImageCount = 0
            unlikeImageCount = 0

            searchResults.didChange = {
                self.swipeableView.loadViews()
            }
        }
    }

    // top
    let topContainer = UIView()
    let topContainerHeight = CGFloat(90)
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


    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBarHidden = true

        setupContainers()
        setupTimerAndCounters()
        setupSwipeableView()
        setupBottonButtoms()

        startListeningLocation()
    }

    var keyword = "restaurants" {
        didSet {
            timerLabel.text = keyword
            parameters.term = keyword
            searchForFoodImages()
        }
    }

    func startListeningLocation() {
        try! SwiftLocation.shared.currentLocation(.Neighborhood, timeout: 10, onSuccess: { location in
            if let location = location {
                self.parameters.location = location
            }
            self.searchForFoodImages()
        }) { error in
            print(error)
            self.searchForFoodImages()
        }
    }

    func searchForFoodImages() {
        searchResults = Business.search(parameters)
    }

    var swipedFoodImages = [(FoodImage, Bool)]()
    var likeImageCount = 0 {
        didSet {
            likeCounterLabel.text = ("\(likeImageCount)")
        }
    }
    var unlikeImageCount = 0 {
        didSet {
            unlikeCounterLabel.text = ("\(unlikeImageCount)")
        }
    }

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
        } else {
            unlikeImageCount -= 1
        }
    }

    func nextView() -> UIView? {
        guard let searchResults = searchResults, foodImage = searchResults.nextFoodImage() else { return nil }

        let frame = CGRect(x: 0, y: 0, width: swipeableView.frame.width, height: swipeableView.frame.height)
        let imageView = FoodImageView(frame: frame, foodImage: foodImage)
        imageView.backgroundColor = backgroundColor
        imageView.center = swipeableView.convertPoint(swipeableView.center, fromView: swipeableView.superview)
        return imageView
    }

    func showResults() {
        let resultTableViewController = ResultTableViewController(style: .Grouped)
        resultTableViewController.businesses = searchResults.busniesses
        resultTableViewController.swipedFoodImages = swipedFoodImages

        presentViewController(UINavigationController(rootViewController: resultTableViewController), animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

