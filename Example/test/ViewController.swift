//
//  ViewController.swift
//  test
//
//  Created by Siyu Wu on 04/27/2016.
//  Copyright (c) 2016 Siyu Wu. All rights reserved.
//

import UIKit
import ZLSwipeableViewSwift

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let swipeableView = ZLSwipeableView(frame: view.bounds)
        view.addSubview(swipeableView)
        
        swipeableView.nextView = {
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
            label.center = swipeableView.center
            label.text = "alksdjflksjdfklsdjfj"
            return label
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

class FoodImageView : UIView {
    
    var foodImage: FoodImage
    
    let imageView = UIImageView()
    let label = UILabel()
    
    init(frame: CGRect, foodImage: FoodImage) {
        self.foodImage = foodImage
        super.init(frame: frame)
        
        
        addSubview(imageView)
        addSubview(label)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}

struct FoodImage {
    let image: UIImage
    let descirption: String
    
}
