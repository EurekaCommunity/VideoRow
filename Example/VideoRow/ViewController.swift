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
//import Foundation
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
    
    @objc func grabValues(){
        //the dictionary of values that are returned from a Eureka row
        let valuesDictionary = form.values()
       //guard statement to assure proper handling of any potential nil TLPHAsset
        guard let promoVideo = valuesDictionary["eventPromoVideoTag"] as? TLPHAsset else {
            return
        }
        //must convert TLPHAsset to a regular phasset to make use of function
        //TLPHAsset already includes the ability to do this so all you have to do as access the property on whatever TLPHAsset you have
        guard let asset = promoVideo.phAsset else {
            return
        }
        //once you have the asset use the function below to convert it into a url to use later. In the event that you want to upload it to firebase or aws or whatever your backend is
        self.getUrlFromPHAsset(asset: asset) { (url) in
            //do some action with url here
        }
    }
    
    
    
    //use this to get url to submit to some backend service
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
