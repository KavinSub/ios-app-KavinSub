//
//  PhotoDeleteHelper.swift
//  Exchange
//
//  Created by Kavin Subramanyam on 12/2/15.
//  Copyright © 2015 Kavin Subramanyam. All rights reserved.
//

import UIKit

typealias PhotoDeleteHelperCallback = Bool -> Void

class PhotoDeleteHelper: NSObject {
    
    var viewController: UIViewController
    var callback: PhotoDeleteHelperCallback
    
    init(viewController: UIViewController, callback: PhotoDeleteHelperCallback){
        self.viewController = viewController
        self.callback = callback
        
        super.init()
        
        showPhotoDeleteOption()
    }
    
    func showPhotoDeleteOption(){
        let alertController = UIAlertController(title: nil, message: "Are you sure you want to delete this photo?", preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel){(action: UIAlertAction) in
            self.callback(false)
        }
        alertController.addAction(cancelAction)
        
        let deleteAction = UIAlertAction(title: "Delete", style: UIAlertActionStyle.Destructive){(action: UIAlertAction) in
            self.callback(true)
        }
        alertController.addAction(deleteAction)
        
        viewController.presentViewController(alertController, animated: true, completion: nil)
    }
}
