//
//  SSComment.swift
//  Savor
//
//  Created by Edgar Sia on 5/6/20.
//  Copyright © 2020 Edgar Sia. All rights reserved.
//

import Firebase

struct SSComment {
    var commentID: String
    var text: String
    var author: SSUser?
    var timestamp: Double
}
