//
//  ViewController.swift
//  VideoRow
//
//  Created by Smiller193 on 11/08/2018.
//  Copyright (c) 2018 Smiller193. All rights reserved.
//

import UIKit
import Eureka
import VideoRow
import TLPhotoPicker
import Foundation
import Photos


class ViewController: FormViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        form +++ Section()
            <<< _VideoRow("eventPromoVideoTag"){ row in
                row.title = "Select a Video"
                row.sourceTypes = [.PhotoLibrary]
                row.clearAction = .yes(style: UIAlertAction.Style.destructive)
                row.allowEditor = true
                row.add(rule: RuleRequired())
                }.cellUpdate({ (cell, row) in
                    cell.accessoryView?.layer.cornerRadius = 17
                    cell.accessoryView?.frame = CGRect(x: 0, y: 0, width: 34, height: 34)
                    print(row.value as Any)
                })
        
    }
    
    
    func getUrlFromPHAsset(asset: PHAsset, callBack: @escaping (_ url: URL?) -> Void)
    {
        asset.requestContentEditingInput(with: PHContentEditingInputRequestOptions(), completionHandler: { (contentEditingInput, dictInfo) in
            
            if let strURL = (contentEditingInput!.audiovisualAsset as? AVURLAsset)?.url.absoluteString
            {
                //                print("VIDEO URL: \(strURL)")
                callBack(URL.init(string: strURL))
            }
        })
    }
}
