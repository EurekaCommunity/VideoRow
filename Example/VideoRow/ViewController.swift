//
//  ViewController.swift
//  VideoRow
//
//  Created by Smiller193 on 11/08/2018.
//  Copyright (c) 2018 Smiller193. All rights reserved.
//

import UIKit
import VideoRow

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        let obj = VideoRow(pointlessParam: "doesn't really matter")
        obj.temp()
    }
}
