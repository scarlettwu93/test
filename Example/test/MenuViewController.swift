//
//  MenuViewController.swift
//  test
//
//  Created by Zhixuan Lai on 4/28/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit

class MenuViewController: UITableViewController {


    // TODO: food keywords auto complete
    // TODO: location auto complete

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Foodie"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "Hi there! Enter a keyword and location to get started." : nil
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 2
        case 1:
            return 1
        default:
            return 0
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = String(format: "s%li-r%li", indexPath.section, indexPath.row)
        var cell: UITableViewCell! = tableView.dequeueReusableCellWithIdentifier(cellIdentifier)
        if cell == nil {
            cell = UITableViewCell(style: .Default, reuseIdentifier: cellIdentifier)
        }

        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = "Keywords"
            case 1:
                cell.textLabel?.text = "Location"

            default:
                break
            }
        case 1:
            cell.textLabel?.text = "Start"
            cell.textLabel?.textAlignment = .Center
        default:
            break
        }

        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)

//        let title = titleForRowAtIndexPath(indexPath)
//        let vc = viewControllerForRowAtIndexPath(indexPath)
//        vc.title = title
//        navigationController?.pushViewController(vc, animated: true)
    }
}
