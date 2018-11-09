//  ImageRow.swift
//  ImageRow ( https://github.com/EurekaCommunity/VideoRow )
//
//  Copyright (c) 2016 Xmartlabs SRL ( http://xmartlabs.com )
//
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Foundation
import Eureka
import AVFoundation
import TLPhotoPicker
import Photos

public struct VideoRowSourceTypes : OptionSet {
    
    public let rawValue: Int
    public var imagePickerControllerSourceTypeRawValue: Int { return self.rawValue >> 1 }
    
    public init(rawValue: Int) { self.rawValue = rawValue }
    init(_ sourceType: UIImagePickerController.SourceType) { self.init(rawValue: 1 << sourceType.rawValue) }
    
    public static let PhotoLibrary = VideoRowSourceTypes(.photoLibrary)
    public static let All: VideoRowSourceTypes = [PhotoLibrary]
    
}

extension VideoRowSourceTypes {
    
    // MARK: Helpers
    
    var localizedString: String {
        switch self {
        case VideoRowSourceTypes.PhotoLibrary:
            return "Photo Library"
        default:
            return ""
        }
    }
}

public enum VideoClearAction {
    case no
    case yes(style: UIAlertAction.Style)
}



//MARK: Row

open class VideoRow<Cell: CellType>: OptionsRow<Cell>, PresenterRowType where Cell: BaseCell, Cell.Value == TLPHAsset {
    public typealias PresenterRow = CustomPhotoPickerViewController
    
    /// Defines how the view controller will be presented, pushed, etc.
    open var presentationMode: PresentationMode<PresenterRow>?
    
    /// Will be called before the presentation occurs.
    open var onPresentCallback: ((FormViewController, PresenterRow) -> Void)?
    
    open var sourceTypes: VideoRowSourceTypes = []
    open var allowEditor : Bool
    
    open internal(set) var videoURL: URL?
    open var clearAction = VideoClearAction.yes(style: .destructive)
    
    private var _sourceType = UIImagePickerController.SourceType.photoLibrary
    
    public required init(tag: String?) {
        sourceTypes = .All
        allowEditor = false
        
        super.init(tag: tag)
        
        
        
        presentationMode = .presentModally(controllerProvider: ControllerProvider.callback { return CustomPhotoPickerViewController() }, onDismiss: { [weak self] vc in
            self?.select()
            vc.dismiss(animated: true)
        })
        self.displayValueFor = nil
        
    }
    
    
    // copy over the existing logic from the SelectorRow
    func displayImagePickerController() {
        if let presentationMode = presentationMode, !isDisabled {
            if let controller = presentationMode.makeController(){
                controller.row = self
                onPresentCallback?(cell.formViewController()!, controller)
                presentationMode.present(controller, row: self, presentingController: cell.formViewController()!)
            }
            else{
                presentationMode.present(nil, row: self, presentingController: cell.formViewController()!)
            }
        }
    }
    
    
    /// Extends `didSelect` method
    /// Selecting the Image Row cell will open a popup to choose where to source the photo from,
    /// based on the `sourceTypes` configured and the available sources.
    open override func customDidSelect() {
        guard !isDisabled else {
            super.customDidSelect()
            return
        }
        deselect()
        
        var availableSources: VideoRowSourceTypes = []
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let _ = availableSources.insert(.PhotoLibrary)
        }
        
        sourceTypes.formIntersection(availableSources)
        
        if sourceTypes.isEmpty {
            super.customDidSelect()
            guard let presentationMode = presentationMode else { return }
            if let controller = presentationMode.makeController() {
                controller.row = self
                controller.title = selectorTitle ?? controller.title
                onPresentCallback?(cell.formViewController()!, controller)
                presentationMode.present(controller, row: self, presentingController: self.cell.formViewController()!)
            } else {
                presentationMode.present(nil, row: self, presentingController: self.cell.formViewController()!)
            }
            return
        }
        
        // Now that we know the number of sources aren't empty, let the user select the source
        let sourceActionSheet = UIAlertController(title: nil, message: selectorTitle, preferredStyle: .actionSheet)
        guard let tableView = cell.formViewController()?.tableView  else { fatalError() }
        if let popView = sourceActionSheet.popoverPresentationController {
            popView.sourceView = tableView
            popView.sourceRect = tableView.convert(cell.accessoryView?.frame ?? cell.contentView.frame, from: cell)
        }
        createOptionsForAlertController(sourceActionSheet)
        if case .yes(let style) = clearAction, value != nil {
            let clearPhotoOption = UIAlertAction(title: NSLocalizedString("Remove Video", comment: ""), style: style, handler: { [weak self] _ in
                self?.value = nil
                self?.videoURL = nil
                self?.cell.accessoryView = nil
                self?.updateCell()
            })
            sourceActionSheet.addAction(clearPhotoOption)
        }
        if sourceActionSheet.actions.count == 1 {
            displayImagePickerController()
        } else {
            let cancelOption = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler:nil)
            sourceActionSheet.addAction(cancelOption)
            if let presentingViewController = cell.formViewController() {
                presentingViewController.present(sourceActionSheet, animated: true)
            }
        }
    }
    
    
    /**
     Prepares the pushed row setting its title and completion callback.
     */
    open override func prepare(for segue: UIStoryboardSegue) {
        super.prepare(for: segue)
        guard let rowVC = segue.destination as? PresenterRow else { return }
        rowVC.title = selectorTitle ?? rowVC.title
        rowVC.onDismissCallback = presentationMode?.onDismissCallback ?? rowVC.onDismissCallback
        onPresentCallback?(cell.formViewController()!, rowVC)
        rowVC.row = self
    }
    
    
    open override func customUpdateCell() {
        super.customUpdateCell()
        
        cell.accessoryType = .none
        cell.editingAccessoryView = .none
        
        guard let value = self.value else {
            return
        }
        
        switch value.type {
        case .video:
            print("got video")
            guard let asset = value.phAsset else {
                return
            }
            
            self.getUrlFromPHAsset(asset: asset) { [weak self] (url) in
                guard let URL = url else {
                    return
                }
                self?.videoURL = URL
                if let image = self?.getThumbnailFrom(path: URL) {
                    let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
                    //will make it a circle
                    imageView.layer.cornerRadius = 22
                    imageView.contentMode = .scaleAspectFit
                    imageView.image = image
                    imageView.clipsToBounds = true
                    
                    self?.cell.accessoryView = imageView
                    self?.cell.editingAccessoryView = imageView
                } else {
                    self?.cell.accessoryView = nil
                    self?.cell.editingAccessoryView = nil
                }
                self?.deselect()
            }
        default:
            print("do nothing")
        }
    }
    
    
}

extension VideoRow {
    //MARK: Helpers
    
    func createOptionsForAlertController(_ alertController: UIAlertController) {
        self.displayImagePickerController()
    }
    
    func getThumbnailFrom(path: URL) -> UIImage? {
        
        do {
            
            let asset = AVURLAsset(url: path , options: nil)
            let imgGenerator = AVAssetImageGenerator(asset: asset)
            imgGenerator.appliesPreferredTrackTransform = true
            let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(value: 0, timescale: 1), actualTime: nil)
            let thumbnail = UIImage(cgImage: cgImage)
            
            return thumbnail
            
        } catch let error {
            
            print("*** Error generating thumbnail: \(error.localizedDescription)")
            return nil
            
        }
        
    }
    
    func getUrlFromPHAsset(asset: PHAsset, callBack: @escaping (_ url: URL?) -> Void)
    {
        asset.requestContentEditingInput(with: PHContentEditingInputRequestOptions(), completionHandler: { (contentEditingInput, dictInfo) in
            
            if let strURL = (contentEditingInput!.audiovisualAsset as? AVURLAsset)?.url.absoluteString
            {
                callBack(URL.init(string: strURL))
            }
        })
    }
}


/// A selector row where the user can pick a video
public final class _VideoRow : VideoRow<PushSelectorCell<TLPHAsset>>, RowType {
    public required init(tag: String?) {
        super.init(tag: tag)
    }
}
