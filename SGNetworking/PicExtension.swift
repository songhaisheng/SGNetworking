//
//  PicExtension.swift
//  SGNetworking
//
//  Created by SG on 16/11/3.
//  Copyright © 2016年 SG. All rights reserved.
//

import UIKit

extension SGNetworking
{
    func requestPic(_ success: @escaping ntSuccessClosure, failure: @escaping ntFailedClosure)
    {
        SGNetworking.sharedInstance.getRequest(BBHelper.kPic, params: nil, success: { (responseObject: JSON) in
            success(responseObject)
        }) { (code: Int, description: String) in
            failure(0, description)
        }
    }
}
