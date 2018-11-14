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
 class CustomPhotoPickerViewController: TLPhotosPickerViewController,TLPhotosPickerViewControllerDelegate,TypedRowControllerType{
    
    /// The row that pushed or presented this controller
    public var row: RowOf<TLPHAsset>!
    //setting navigation controller delegate
    
    /// A closure to be called when the controller disappears.
    public var onDismissCallback : ((UIViewController) -> ())?
    
    override func makeUI() {
        super.makeUI()
        self.doneButton.isEnabled = self.selectedAssets.count > 0
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
    
    override  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        super.collectionView(collectionView, didSelectItemAt: indexPath)
        self.doneButton.isEnabled = self.selectedAssets.count > 0
    }
    func handleNoAlbumPermissions(picker: TLPhotosPickerViewController) {
        
    }
    
    func handleNoCameraPermissions(picker: TLPhotosPickerViewController) {
        
    }
    
     override func doneButtonTap() {
        print("done tapped")
        self.dismiss(animated: true) {
            (self.row as? _VideoRow)?.value = self.selectedAssets[0]
            print((self.row as? _VideoRow)?.value?.type as Any)
            self.onDismissCallback?(self)
            self.row.updateCell()
        }
    }
}
