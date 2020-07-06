//
//  Convert.swift
//  KurentoDemo
//
//  Created by Admin on 7/6/20.
//  Copyright © 2020 Din Vu Dinh. All rights reserved.
//

import Foundation
class Convert{
    class func dataToString(data:[String:Any])->String{
        if let JSONData = try? JSONSerialization.data(withJSONObject: data,options: []),
            let JSONText = String(data: JSONData,encoding: .utf8) {
                return JSONText
            }
        return ""
    }
}
