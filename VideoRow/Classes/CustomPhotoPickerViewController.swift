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
    
    override  open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        super.collectionView(collectionView, didSelectItemAt: indexPath)
        self.doneButton.isEnabled = self.selectedAssets.count > 0
    }
    
    public func didExceedMaximumNumberOfSelection(picker: TLPhotosPickerViewController) {
        self.showExceededMaximumAlert(vc: picker)
    }
    
    public func handleNoAlbumPermissions(picker: TLPhotosPickerViewController) {
        picker.dismiss(animated: true) {
            let alert = UIAlertController(title: "", message: "Denied albums permissions granted", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    public func handleNoCameraPermissions(picker: TLPhotosPickerViewController) {
        let alert = UIAlertController(title: "", message: "Denied camera permissions granted", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        picker.present(alert, animated: true, completion: nil)
    }
    
    
    func showExceededMaximumAlert(vc: UIViewController) {
        let alert = UIAlertController(title: "", message: "Exceed Maximum Number Of Selection", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        vc.present(alert, animated: true, completion: nil)
    }
    
    func showUnsatisifiedSizeAlert(vc: UIViewController) {
        let alert = UIAlertController(title: "Oups!", message: "The required size is: 300 x 300", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        vc.present(alert, animated: true, completion: nil)
    }
    
    open override func doneButtonTap() {
        print("done tapped")
        self.dismiss(animated: true) {
            (self.row as? _VideoRow)?.value = self.selectedAssets.first
            print((self.row as? _VideoRow)?.value?.type as Any)
            self.onDismissCallback?(self)
            self.row.updateCell()
        }
    }
}
