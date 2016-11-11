//
//  BBTypealiasDefine.swift
//  SGNetworking
//
//  Created by SG on 16/11/1.
//  Copyright © 2016年 SG. All rights reserved.
//

import UIKit

typealias ntSuccessClosure = (_ responseObject:JSON) -> Void;
typealias ntFailedClosure = (_ code:Int, _ description:String) -> Void;
typealias progressClosure = (_ progressValue:CGFloat) -> Void;
typealias ntUpdateClosure = (_ isNeedUpdate:Bool, _ newVersion:String, _ releaseNote:String) -> Void;
typealias descriptionClosure = (_ description:String) -> Void;

