//
//  ResultTableViewController.swift
//  test
//
//  Created by Zhixuan Lai on 5/1/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit
import ReactiveUI
import SafariServices

public extension SequenceType {

    /// Categorises elements of self into a dictionary, with the keys given by keyFunc

    func categorise<U : Hashable>(@noescape keyFunc: Generator.Element -> U) -> [U:[Generator.Element]] {
        var dict: [U:[Generator.Element]] = [:]
        for el in self {
            let key = keyFunc(el)
            if case nil = dict[key]?.append(el) { dict[key] = [el] }
        }
        return dict
    }
}

class ResultTableViewController: UITableViewController {

    var businesses = [String: Business]()
    
    var swipedFoodImages = [(FoodImage, Bool)]() {
        didSet {
            let likedImages = swipedFoodImages.filter { (foodImage, liked) -> Bool in
                liked
                }.map { (foodImage, liked) in foodImage }
            let dict = likedImages.categorise {$0.busniessID}
            var newDict = [Business: [FoodImage]]()
            for (key, value) in dict {
                if let business = businesses[key] {
                    newDict[business] = value
                }
            }
            likedFoodImages = Array(newDict.keys).map {
                key in (key, newDict[key]!)}
                .sort {$0.1.count > $1.1.count
            }
        }
    }

    var likedFoodImages = [(Business, [FoodImage])]() {
        didSet {
            tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Results"
        tableView.reloadData()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
         self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Continue", style: .Done, action: { (item) in
            self.dismissViewControllerAnimated(true, completion: nil)
         })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return likedFoodImages.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
//        return likedFoodImages[section].1.count
        return 1
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "reuseIdentifier"
        var cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier")

        if cell == nil {
            cell = UITableViewCell(style: .Subtitle, reuseIdentifier: cellIdentifier)
        }

        let (business, images) = likedFoodImages[indexPath.section]
        cell?.textLabel?.text = "\(business.name)"
//        cell?.textLabel?.numberOfLines = 3
        cell?.detailTextLabel?.text = "Likes: \(images.count)"

        cell?.accessoryType = .DisclosureIndicator

        return cell!
    }

//    func attributedStringForIndexPath(indexPath: NSIndexPath) {
//        let (business, images) = likedFoodImages[indexPath.section]
//
//    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let (business, _) = likedFoodImages[indexPath.section]

        let safariController = SFSafariViewController(URL: business.URL)
//        navigationController?.pushViewController(safariController, animated: true)
        self.presentViewController(safariController, animated: true, completion: nil)

    }

}
