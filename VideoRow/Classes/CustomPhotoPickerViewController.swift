//
//  CustomPhotoPickerViewController.swift
//  VideoRow
//
//  Created by Shawn Miller on 11/9/18.
//

import TLPhotoPicker
import Eureka
import AVFoundation


//customizable photos picker viewcontroller
open class CustomPhotoPickerViewController: TLPhotosPickerViewController,TLPhotosPickerViewControllerDelegate,TypedRowControllerType{
    
    /// The row that pushed or presented this controller
    public var row: RowOf<TLPHAsset>!
    //setting navigation controller delegate
    
    /// A closure to be called when the controller disappears.
    public var onDismissCallback : ((UIViewController) -> ())?
    override open func makeUI() {
        super.makeUI()
        delegate = self
        var customConfig = TLPhotosPickerConfigure()
        customConfig.numberOfColumn = 3
        customConfig.singleSelectedMode = true
        customConfig.mediaType = .video
        self.configure = customConfig
        self.customNavItem.leftBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: .stop, target: nil, action: #selector(customAction))
    }
    @objc func customAction() {
        self.dismiss(animated: true) {
            self.onDismissCallback?(self)
        }
    }
    open override func doneButtonTap() {
        print("done tapped")
        self.dismiss(animated: true) {
            (self.row as? _VideoRow)?.value = self.selectedAssets[0]
            print((self.row as? _VideoRow)?.value?.type as Any)
            self.onDismissCallback?(self)
            self.row.updateCell()
        }
    }
}
