//
//  YelpClient.swift
//  Yelp
//
//  Created by Timothy Lee on 9/19/14.
//  Copyright (c) 2014 Timothy Lee. All rights reserved.
//

import UIKit
import CoreLocation

import AFNetworking
import BDBOAuth1Manager

// You can register for Yelp API keys here: http://www.yelp.com/developers/manage_api_keys
let yelpConsumerKey = "Zt5KH9QFVfTSG6F23htZ1g"
let yelpConsumerSecret = "H5MZtL9n4csO7RD7PEc7_6GBQxc"
let yelpToken = "7ZFnGjWX1Qz5osa56K-aZZRJieTxDmrx"
let yelpTokenSecret = "1dATChTFG92fCQeaTfyvE5trqzU"

enum YelpSortMode: Int {
    case BestMatched = 0, Distance, HighestRated
}

let defaultCoordinateString = "37.785771,-122.406165"
let defaultLocation = CLLocation(latitude: 37.785771, longitude: -122.406165)

struct YelpSearchParameters {
    var term: String = "restaurants"
    var location: CLLocation = defaultLocation
    var limit: Int = 10
    var offset: Int = 0
    var sort: YelpSortMode = .BestMatched
    var categoryFilter: [String] = ["restaurants"]
    var radiusFilter: Double = 40000
    var dealsFilter: Bool = false

    var dictionary: [String : AnyObject] {
        get {
            var parameters = [String : AnyObject]()
            parameters["term"] = term
            parameters["ll"] = "\(location.coordinate.latitude),\(location.coordinate.longitude)"
            parameters["limit"] = limit
            parameters["offset"] = offset
            parameters["sort"] = sort.rawValue
            parameters["category_filter"] = categoryFilter.joinWithSeparator(",")
            parameters["radius_filter"] = radiusFilter
            parameters["deals_filter"] = dealsFilter
            return parameters
        }
    }
}

class YelpClient: BDBOAuth1RequestOperationManager {
    var accessToken: String!
    var accessSecret: String!
    
    class var sharedInstance : YelpClient {
        struct Static {
            static var token : dispatch_once_t = 0
            static var instance : YelpClient? = nil
        }
        
        dispatch_once(&Static.token) {
            Static.instance = YelpClient(consumerKey: yelpConsumerKey, consumerSecret: yelpConsumerSecret, accessToken: yelpToken, accessSecret: yelpTokenSecret)
        }
        return Static.instance!
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(consumerKey key: String!, consumerSecret secret: String!, accessToken: String!, accessSecret: String!) {
        self.accessToken = accessToken
        self.accessSecret = accessSecret
        let baseUrl = NSURL(string: "https://api.yelp.com/v2/")
        super.init(baseURL: baseUrl, consumerKey: key, consumerSecret: secret);
        
        let token = BDBOAuth1Credential(token: accessToken, secret: accessSecret, expiration: nil)
        self.requestSerializer.saveAccessToken(token)
    }

    func search(parameters: YelpSearchParameters, completion: ([Business]?, NSError?) -> Void) -> AFHTTPRequestOperation {
        // For additional parameters, see http://www.yelp.com/developers/documentation/v2/search_api

        return self.GET("search", parameters: parameters.dictionary, success: { (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
            guard let dictionaries = response["businesses"] as? [NSDictionary] else {
                return completion([], nil)
            }
            let businesses = dictionaries.flatMap({ (dictionary) -> Business? in
                return Business(dictionary: dictionary)
            })
            completion(businesses, nil)
            }, failure: { (operation: AFHTTPRequestOperation?, error: NSError!) -> Void in
                completion(nil, error)
        })!
    }
}
