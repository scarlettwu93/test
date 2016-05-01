//
//  Business.swift
//  Yelp
//
//  Created by Timothy Lee on 4/23/15.
//  Copyright (c) 2015 Timothy Lee. All rights reserved.
//

import UIKit

struct Business {
    let name: String
    let imageURL: NSURL
    let URL: NSURL
    let address: String
    let categories: [(String, String)]
    let distance: String
    let ratingImageURL: NSURL
    let reviewCount: NSNumber
    
    init?(dictionary: NSDictionary) {

        guard
            let name = dictionary["name"] as? String,
            imageURLString = dictionary["image_url"] as? String,
            imageURL = NSURL(string: imageURLString),
            URLString = dictionary["url"] as? String,
            URL = NSURL(string: URLString),
            location = dictionary["location"] as? NSDictionary,
            address = location["display_address"] as? String,
            categoriesArray = dictionary["categories"] as? [[String]],
            distanceMeters = dictionary["distance"] as? Double,
            ratingImageURLString = dictionary["rating_img_url_large"] as? String,
            ratingImageURL = NSURL(string: ratingImageURLString),
            reviewCount = dictionary["review_count"] as? Int

        else {
            return nil
        }

        self.name = name
        self.imageURL = imageURL
        self.URL = URL
        self.address = address
        self.ratingImageURL = ratingImageURL
        self.reviewCount = reviewCount

        categories = categoriesArray.map {pair in (pair[0], pair[1])}
        let milesPerMeter = 0.000621371
        distance = String(format: "%.2f mi", milesPerMeter * distanceMeters)
    }
    

    static func search(parameters: YelpSearchParameters) -> SearchResults {
        return SearchResults(parameters: parameters)
    }
    

//    func getFoodImages() -> [FoodImage] {
//
//    }
// ?tab=food

}

class SearchResults {

    let parameters: YelpSearchParameters
    let index = 0
    var results = [Business]()

    init(parameters: YelpSearchParameters) {
        self.parameters = parameters
    }

    func fetchNext() {
        YelpClient.sharedInstance.search(parameters) { (businesses, error) in
            guard let businesses = businesses where error == nil else { return }

        }

    }

}



