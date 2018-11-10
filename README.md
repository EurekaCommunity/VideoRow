# VideoRow

[![CI Status](https://img.shields.io/travis/Smiller193/VideoRow.svg?style=flat)](https://travis-ci.org/Smiller193/VideoRow)
[![Version](https://img.shields.io/cocoapods/v/VideoRow.svg?style=flat)](https://cocoapods.org/pods/VideoRow)
[![License](https://img.shields.io/cocoapods/l/VideoRow.svg?style=flat)](https://cocoapods.org/pods/VideoRow)
[![Platform](https://img.shields.io/cocoapods/p/VideoRow.svg?style=flat)](https://cocoapods.org/pods/VideoRow)



# Introduction

VideoRow is a Eureka custom row that allows us to take or choose a video fromt our media library.



![](https://media.giphy.com/media/1dWPHjBPfkLu3x87EC/giphy.gif)



## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements
iOS 9.0+

Xcode 9.0+

Eureka ~> 4.0

TLPhotoPicker
## Installation

VideoRow is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'VideoRow'
```
## Usage

Using this pod is pretty straightforward for the most part. First you have to create your Viewcontroller and subclass it is as a FormViewController similar to how you would with any Eureka Row.

    import Eureka
    class ViewController: FormViewController {
        override func viewDidLoad() {
            super.viewDidLoad()
           
        }
        
    }

After that you must import VideoRow similar to how you would import any Eureka Row and add it to your FormViewController with similar syntax to previous rows. I will include an example below any way.

    import Eureka
    import VideoRow
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
        
    }
    
The return value from the VideoRow is a TLPHAsset which is a variable type that comes with using the TLPhotoPicker which I make use of to make this work. By installing VideoRow you automatically have access to the TLPhotoPicker and all of its methods so all you have to do is import it similar to how you would import Eureka or VideoRow to handle the TLPHAsset.

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

A function like this can be used to grab the value from the Eureka row (a TLPHAsset) and convert it to a phAsset. The phAsset is automatically accessible via the TLPHAsset all you have to do is access it like seen in the example. Once you do that you need a function to take that phAsset and convert it to a URL for later use to upload to some backend or other service of your choosing. An example of a function like that can be seen below. **To make this function work you must also import Photos


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
        
 The final piece of code will look something like this if you want to properly use the row and gain access to the Video and URL.
 
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


        

## Author

Smiller193, shawn.miller@temple.edu

## License

VideoRow is available under the MIT license. See the LICENSE file for more info.
