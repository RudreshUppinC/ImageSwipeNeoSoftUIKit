//
//  UIViewController.swift
//  ImageSwipeNeoSoftUIKit
//
//  Created by RudreshUppin on 26/04/25.
//

import Foundation
import UIKit


extension UIViewController {
    
    var viewWidth:CGFloat {
        return view.frame.width
    }

    var viewHeight:CGFloat {
        return view.frame.height
    }
    
    var mainHeight:CGFloat {
        return UIScreen.main.bounds.height
    }
    
    
    var safeAreaInsists:UIEdgeInsets {
        return view.safeAreaInsets
    }
    
  
}
