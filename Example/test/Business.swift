//
//  Business.swift
//  Yelp
//
//  Created by Timothy Lee on 4/23/15.
//  Copyright (c) 2015 Timothy Lee. All rights reserved.
//

import UIKit
import Alamofire
import Kanna

func ==(lhs: Business, rhs: Business) -> Bool {
    return lhs.id == rhs.id
}


struct Business : Hashable {

    var hashValue: Int {
        get {
            return id.hash
        }
    }

    let id: String
    let name: String
    let snippet: String
    let imageURL: NSURL
    let URL: NSURL
    let address: String
//    let categories: [(String, String)]
//    let distance: String
    let ratingImageURL: NSURL
    let reviewCount: NSNumber
    
    init?(dictionary: NSDictionary) {

        guard
            let id = dictionary["id"] as? String,
            name = dictionary["name"] as? String,
            imageURLString = dictionary["image_url"] as? String,
            imageURL = NSURL(string: imageURLString),
            URLString = dictionary["url"] as? String,
            URL = NSURL(string: URLString),
            location = dictionary["location"] as? NSDictionary,
            addressArray = location["display_address"] as? [String],
//            categoriesArray = dictionary["categories"] as? [[String]],
//            distanceMeters = dictionary["distance"] as? Double,
            ratingImageURLString = dictionary["rating_img_url_large"] as? String,
            ratingImageURL = NSURL(string: ratingImageURLString),
            reviewCount = dictionary["review_count"] as? Int,
            snippet = dictionary["snippet_text"] as? String
        else {
            print(dictionary)
            return nil
        }

        self.id = id
        self.name = name
        self.imageURL = imageURL
        self.URL = URL
        self.address = addressArray.joinWithSeparator(",")
        self.ratingImageURL = ratingImageURL
        self.reviewCount = reviewCount
        self.snippet = snippet

//        categories = categoriesArray.map {pair in (pair[0], pair[1])}
//        let milesPerMeter = 0.000621371
//        distance = String(format: "%.2f mi", milesPerMeter * distanceMeters)
    }
    

    static func search(parameters: YelpSearchParameters) -> SearchResults {
        return SearchResults(parameters: parameters)
    }
    

//    func getFoodImages() -> [FoodImage] {
//
//    }
// ?tab=food

}

extension CollectionType {
    /// Return a copy of `self` with its elements shuffled
    func shuffle() -> [Generator.Element] {
        var list = Array(self)
        list.shuffleInPlace()
        return list
    }
}

extension MutableCollectionType where Index == Int {
    /// Shuffle the elements of `self` in-place.
    mutating func shuffleInPlace() {
        // empty and single-element collections don't shuffle
        if count < 2 { return }

        for i in 0..<count - 1 {
            let j = Int(arc4random_uniform(UInt32(count - i))) + i
            guard i != j else { continue }
            swap(&self[i], &self[j])
        }
    }
}


// accsess business images
class SearchResults {

    var parameters: YelpSearchParameters

    var busniesses = [String: Business]()
    var foodImages = [FoodImage]()
    var foodImageIndex = 0

    var didChange = {}

    init(parameters: YelpSearchParameters) {
        self.parameters = parameters
        self.parameters.limit = 5
        fetchMoreBusniesses()
    }

    func nextFoodImage() -> FoodImage? {
        guard foodImageIndex < foodImages.count else {
            fetchMoreBusniesses()
            return nil
        }

        let foodImage = foodImages[foodImageIndex]
        foodImageIndex += 1

        if foodImageIndex > foodImages.count - 10 {
            fetchMoreBusniesses()
        }

        return foodImage
    }

    var hasMoreBusniesses = true
    var searchingForBusiness = false
    func fetchMoreBusniesses() {
        guard hasMoreBusniesses && !searchingForBusiness else { return }
        YelpClient.sharedInstance.search(parameters) { (businesses, error) in
            self.searchingForBusiness = false
            guard let businesses = businesses where error == nil else { return }
            businesses.forEach(self.addBusniess)
//            if self.busniesses.count < self.parameters.offset {
//                self.hasMoreBusniesses = false
//            }
            print(self.busniesses.count)
        }
        searchingForBusiness = true
        parameters.offset += parameters.limit
    }

    func addBusniess(business: Business) {
        busniesses[business.id] = business
        fetchFoodImagesForBusniess(business)
    }

    func addFoodImage(foodImage: FoodImage) {
        if foodImageIndex == foodImages.count {
            foodImages.append(foodImage)
            didChange()
            return
        }

        let range = foodImages.count - foodImageIndex
        let randomIndex = foodImageIndex + random() % range
        foodImages.insert(foodImage, atIndex: randomIndex)
        didChange()
    }

    func fetchFoodImagesForBusniess(business: Business) {
        // example: http://www.yelp.com/biz_photos/tutti-frutti-frozen-yogurt-la-crescenta-montrose?tab=food

        // the first image
        let first = FoodImage(busniessID: business.id, imageURL: business.imageURL, descirption: business.snippet)
        addFoodImage(first)

        // fetch more
        let urlString = "http://www.yelp.com/biz_photos/\(business.id)?tab=food"
        Alamofire.request(.GET, urlString).responseString { (response) in
            guard let html = response.result.value, doc = Kanna.HTML(html: html, encoding: NSUTF8StringEncoding) where response.result.isSuccess else {
                return
            }

            // Search for nodes by CSS
            // #super-container > div.container > div.media-landing.js-media-landing > div.media-landing_gallery.photos > ul > li:nth-child(1) > div > img
            for img in doc.css("div.container .photo-box-grid img").dropFirst() {
                if let alt = img["alt"], src = img["src"], url = NSURL(string: "http:"+src), endRange = alt.rangeOfString(". ") {
                    let range = alt.startIndex ..< endRange.endIndex
                    let descirption = alt.stringByReplacingCharactersInRange(range, withString: "")
                    let foodImage = FoodImage(busniessID: business.id, imageURL: url, descirption: descirption)
                    self.addFoodImage(foodImage)
                }
            }
        }

    }

}



