//
//  StringExtension.swift
//  SGNetworking
//
//  Created by SG on 16/11/1.
//  Copyright © 2016年 SG. All rights reserved.
//

import UIKit

extension String
{
    /**
     递归方式删除指定目录的文件
     
     - parameter filePath: 文件目录
     */
    static func removeFiles(_ filePath:String?)
    {
        guard let _ = filePath else
        {
            return;
        }
        
        var isDir:ObjCBool = ObjCBool(true);
        let fm:FileManager = FileManager();
        if (fm.fileExists(atPath: filePath!, isDirectory: &isDir))
        {
            if (isDir.boolValue)
            {
                do
                {
                    let files:[String] = try fm.contentsOfDirectory(atPath: filePath!);
                    for file in files
                    {
                        String.removeFiles(String(format: "%@/%@", filePath!, file));
                    }
                }catch let error as NSError
                {
                    UIApplication.dLog(error);
                }
            }
            else
            {
                do
                {
                    try fm.removeItem(atPath: filePath!);
                }catch let error as NSError
                {
                    UIApplication.dLog(error);
                }
            }
        }
    }
    
    func trim() -> String
    {
        return self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines);
    }
}
