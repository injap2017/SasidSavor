//
//  YelpX.swift
//  Savor
//
//  Created by Edgar Sia on 3/23/20.
//  Copyright © 2020 Edgar Sia. All rights reserved.
//

import Foundation
import CDYelpFusionKit

extension CDYelpBusiness {
    
    func detailAddress() -> String {
        var detailAddress = ""
        if let location = self.location {
            if let city = location.city {
                detailAddress += city
            }
            if let addressOne = location.addressOne {
                detailAddress += " " + addressOne
            }
            if let addressTwo = location.addressTwo {
                detailAddress += " " + addressTwo
            }
            if let addressThree = location.addressThree {
                detailAddress += " " + addressThree
            }
        }
        return detailAddress
    }
}
