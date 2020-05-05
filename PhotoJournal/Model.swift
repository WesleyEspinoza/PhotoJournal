//
//  Model.swift
//  PhotoJournal
//
//  Created by Erick Wesley Espinoza on 5/5/20.
//  Copyright © 2020 HazeStudio. All rights reserved.
//

import Foundation

struct Entry: Codable {
    let imagePath: String
    let textEntry: String
    let timeStamp: String
}
