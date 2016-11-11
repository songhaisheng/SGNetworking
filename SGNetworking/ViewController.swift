//
//  ViewController.swift
//  SGNetworking
//
//  Created by SG on 16/10/31.
//  Copyright © 2016年 SG. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
 
    fileprivate lazy var tableView: UITableView = {
        let tableView: UITableView = UITableView(frame: UIScreen.main.bounds)
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()
    
    fileprivate var titles: [String]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.red
        
        view.addSubview(tableView)
        request()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func request()
    {
        SGNetworking.sharedInstance.requestPic({[weak self] (responseObject: JSON) in
            if responseObject["data"]["activity_list"].exists() {
                if let strongSelf = self {
                    if let items = responseObject["data"]["activity_list"].array {
                        strongSelf.titles = [String]()
                        for item in items
                        {
                            let activity: ActivityEntity = ActivityEntity(data: item)
                            strongSelf.titles?.append(activity.activityTitle ?? "")
                        }
                    }
                    
                    DispatchQueue.main.async {
                        strongSelf.tableView.reloadData()
                    }
                }
            }
        }) { (code :Int, descrption: String) in
            
        }
    }
}

extension ViewController: UITableViewDelegate
{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}

extension ViewController: UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let texts: [String] = titles {
            return texts.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "cell")
        if let texts: [String] = titles {
            cell.textLabel?.text = texts[indexPath.row]
        }
        return cell
    }
}
