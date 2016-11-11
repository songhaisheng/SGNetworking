//
//  BBHelper.swift
//  SGNetworking
//
//  Created by SG on 16/11/1.
//  Copyright © 2016年 SG. All rights reserved.
//

import Foundation

struct BBHelper {
    static var appVersion:String {
        get {
            if let appDic = Bundle.main.infoDictionary
            {
                if let value:String = appDic["CFBundleShortVersionString"] as? String
                {
                    return value;
                }
            }
            
            return "1.3.0";
        }
    }
    static let kHostName:String = "http://bobo.yimwing.com"
    static let kAppCacheFilePath:String = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0];
    static let kHTTPUpdateSwitch:String = "/shop/config/get_iosupdate";
    static let kSuccessField:String = "code";
    static let kSuccessCode:Int = 1;
    static let kMsgField:String = "message";
    static let kPic: String = "/task/taskactivityapi/get_activity_list"
}
