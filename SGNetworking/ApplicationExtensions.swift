//
//  ApplicationExtensions.swift
//  SGNetworking
//
//  Created by SG on 16/11/1.
//  Copyright © 2016年 SG. All rights reserved.
//

import UIKit
import Foundation

extension UIApplication
{
    class func dLog<T>(_ message: T, file: String = #file, method: String = #function, line: Int = #line)
    {
        #if DEBUG
            print("/*\(Date())*/ \((file as NSString).lastPathComponent)[\(line), \(method)]:\(message)")
        #endif
    }
}
