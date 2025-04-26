//
//  NeoSoftAppFonts.swift
//  ImageSwipeNeoSoftSwitUI
//
//  Created by RudreshUppin on 25/04/25.
//

import Foundation
import SwiftUI

struct NeoSoftAppFonts {
    
    static func fixedFont(_ size:CGFloat, weight:Font.Weight, deisgn:Font.Design = .default) -> Font {
        return Font.system(size: size,weight: weight,design: deisgn)
    }
    
}
