//
//  PlateItem.swift
//  ParkingLotManager
//
//  Created by Burak on 14.07.2021.
//

import Foundation

struct plateItem {
    var carID : UUID
    var carPlate : String
    
    init(id : UUID, plate : String) {
        carID = id
        carPlate = plate
    }
}
