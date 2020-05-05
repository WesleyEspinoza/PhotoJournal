//
//  UIColorExt.swift
//  PhotoJournal
//
//  Created by Erick Wesley Espinoza on 4/25/20.
//  Copyright © 2020 HazeStudio. All rights reserved.
//

import UIKit
import Foundation


extension UIColor {
    
    // NOTE: UIColor(hex: 0xE3E3E3) -> UIColor Desc: The function Takes in an Int (Replace # with 0x) ex. #FF5733 -> 0xFF5733 turns the hex value into an Int
    convenience init(hex: Int) {
        let components = (
            R: CGFloat((hex >> 16) & 0xff) / 255,
            G: CGFloat((hex >> 08) & 0xff) / 255,
            B: CGFloat((hex >> 00) & 0xff) / 255
        )
        self.init(red: components.R, green: components.G, blue: components.B, alpha: 1)
    }
    
    static func random(alpha: CGFloat) -> UIColor{
        return UIColor(red: .random(in: 55...255) / 255, green: .random(in: 55...255) / 255, blue: .random(in: 55...255) / 255, alpha: alpha)
    }

}
