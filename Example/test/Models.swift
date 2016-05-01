//
//  Models.swift
//  test
//
//  Created by Zhixuan Lai on 4/28/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit

struct FoodImage {

    let busniessID: String

    let imageURL: NSURL
    let descirption: String

    var largeImageURL: NSURL {
        get {
            let largeImageURL = imageURL.URLByDeletingLastPathComponent!.URLByAppendingPathComponent("l.jpg")
            return largeImageURL
        }
    }
    
}
