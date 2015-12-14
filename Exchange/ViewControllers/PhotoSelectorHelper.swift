//
//  PhotoSelectorHelper.swift
//  Exchange
//
//  Created by Kavin Subramanyam on 12/2/15.
//  Copyright © 2015 Kavin Subramanyam. All rights reserved.
//

import UIKit

typealias PhotoSelectorHelperCallback = UIImage? -> Void

class PhotoSelectorHelper: NSObject {
    
    weak var viewController: UIViewController!
    var callback: PhotoSelectorHelperCallback
    var imagePickerController: UIImagePickerController?
    
    init(viewController: UIViewController, callback: PhotoSelectorHelperCallback){
        self.viewController = viewController
        self.callback = callback
        
        super.init()
        
        showPhotoSourceSelection()
    }
    
    func showPhotoSourceSelection(){
        let alertController = UIAlertController(title: nil, message: "Where would you like to get your picture from?", preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        let photoLibraryAction = UIAlertAction(title: "Photo Library", style: UIAlertActionStyle.Default){ (action) in
            self.showImagePickerController(.PhotoLibrary)
        }
        alertController.addAction(photoLibraryAction)
        
        if(UIImagePickerController.isCameraDeviceAvailable(.Rear)){
            let cameraAction = UIAlertAction(title: "Take Picture", style: UIAlertActionStyle.Default){ (action) in
                self.showImagePickerController(.Camera)
            }
            alertController.addAction(cameraAction)
        }
        
        viewController.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func showImagePickerController(sourceType: UIImagePickerControllerSourceType){
        imagePickerController = UIImagePickerController()
        imagePickerController!.sourceType = sourceType
        imagePickerController!.delegate = self
        imagePickerController?.allowsEditing = true
        print("Image picker has been presented")
        viewController.presentViewController(imagePickerController!, animated: true, completion: nil)
    }
    
}

extension PhotoSelectorHelper: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        viewController.dismissViewControllerAnimated(false, completion: nil)
        //viewController.navigationController?.popViewControllerAnimated(true)
        print("Image has been picked")
        callback(image)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        print("Image picking cancelled")
        viewController.dismissViewControllerAnimated(true, completion: nil)
    }
}
