//
//  ActivityEntity.swift
//  SGNetworking
//
//  Created by BoBo on 16/11/11.
//  Copyright © 2016年 SG. All rights reserved.
//

import UIKit

class ActivityEntity: NSObject {
    var activityTitle: String?
    
    override init()
    {
        super.init()
    }
    
    init(data: JSON) {
        super.init()
        activityTitle = data["title"].string
    }
}
