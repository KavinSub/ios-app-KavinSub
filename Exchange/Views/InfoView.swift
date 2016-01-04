//
//  InfoView.swift
//  Exchange
//
//  Created by Kavin Subramanyam on 1/3/16.
//  Copyright © 2016 Kavin Subramanyam. All rights reserved.
//

import UIKit
import Parse

class InfoView: UIView {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        modifyMainView()
        addSubviews()
    }
    
    // Modifies main view parameters
    func modifyMainView(){
        self.backgroundColor = UIColor(red: 255.0/255.0, green: 195.0/255.0, blue: 14.0/255.0, alpha: 1.0)
    }
    
    func addSubviews(){
        let testLabel = UILabel(frame: CGRectMake(10, 10, 280, 30))
        testLabel.text = "If this works I'm sleeping"
        
        self.addSubview(testLabel)
    }
    
}
