//
//  SGNetworking.swift
//  SGNetworking
//
//  Created by SG on 16/11/1.
//  Copyright © 2016年 SG. All rights reserved.
//

import UIKit

class SGNetworking: NSObject {
    
    // MARK: - properties
    fileprivate lazy var manager: SessionManager = {
        let m: SessionManager = SessionManager()
        m.session.configuration.timeoutIntervalForRequest = 30
        return m
    }()
    
    fileprivate lazy var requestHeaders: [String: String]? = {
        if let appDic = Bundle.main.infoDictionary
        {
            var name: String = "SG"
            if let value: String = appDic["CFBundleExecutable"] as? String
            {
                name = value
            }
            var version: String = BBHelper.appVersion
            var userAgent: String = "\(name)/\(version)/ (\(UIDevice.current.model);iOS \(UIDevice.current.systemVersion))"
            return ["User-Agent": userAgent, "Version": version]
        }
        return nil
    }()
    
    // MARK: - life cycle
    static let sharedInstance: SGNetworking = SGNetworking()
    
    fileprivate override init()
    {
        super.init()
    }
    
    deinit {
        
    }
    
    // MARK: - public methods
    /**
     GET方式提交
     
     - parameter methodName: 接口方法名
     - parameter params:     接口参数
     - parameter success:    成功回调
     - parameter failure:    失败回调
     */
    internal func getRequest(_ methodName: String, params: [String: Any]?, success: @escaping ntSuccessClosure, failure: @escaping ntFailedClosure)
    {
        if (self.isNetworking(failure: failure))
        {
            let requestURLPath: String = "\(BBHelper.kHostName)\(methodName)"
            UIApplication.dLog("Request UrlPath:\(requestURLPath) Params: \(params)")
            self.manager.request(requestURLPath, method: .get, parameters: params, encoding: URLEncoding.default, headers: self.requestHeaders)
                .validate(contentType: ["application/json", "text/json", "text/javascript", "text/html", "image/png"])
                .validate(statusCode: 200..<300)
                .responseData(completionHandler: { [weak self](response: DataResponse<Data>) in
                if let strongSelf = self
                {
                    strongSelf.parseResponseData(response: response, success: success, failure: failure)
                }
            })
        }
    }
    
    /**
     POST方式提交
     
     - parameter methodName: 接口方法名
     - parameter params:     接口参数
     - parameter success:    成功回调
     - parameter failure:    失败回调
     */
    internal func postRequest(_ methodName:String, params:[String:Any]?, success: @escaping ntSuccessClosure, failure: @escaping ntFailedClosure)
    {
        if (self.isNetworking(failure: failure))
        {
            let requestURLPath:String = "\(BBHelper.kHostName)\(methodName)";
            UIApplication.dLog("Request UrlPath:\(requestURLPath) Params:\(params)");
            self.manager.request(requestURLPath, method: .post, parameters: params, encoding: URLEncoding.default, headers: self.requestHeaders)
                .validate(contentType: ["application/json", "text/json", "text/javascript", "text/html", "image/png"])
                .validate(statusCode: 200..<300)
                .responseData { [weak self](response:DataResponse<Data>) in
                    if let strongSelf = self
                    {
                        strongSelf.parseResponseData(response: response, success: success, failure: failure);
                    }
            }
        }
    }
    
    /**
     上传文件，可以上传各类文件，头像等
     
     - parameter methodName: 方法名
     - parameter params:     参数
     - parameter streamData: 文件流
     - parameter progress:   上传进度
     - parameter success:    成功回调
     - parameter failure:    失败回调
     */
    internal func postRequestStreamData(_ methodName:String, params:[String:Any]?, streamData:Data?, progress:@escaping progressClosure, success: @escaping ntSuccessClosure, failure: @escaping ntFailedClosure)
    {
        if (self.isNetworking(failure: failure))
        {
            let requestURLPath:String = "\(BBHelper.kHostName)\(methodName)";
            UIApplication.dLog("Request UrlPath:\(requestURLPath) Params:\(params)");
            self.manager.upload(multipartFormData: { (formData:MultipartFormData) in
                if let data = streamData
                {
                    formData.append(data, withName: "image", fileName: "imageName.jpg", mimeType: "image/jpg");
                }
                if let dic = params
                {
                    for (key, value) in dic
                    {
                        formData.append((value as! String).data(using: String.Encoding.utf8)!, withName: key);
                    }
                }
            }, to: requestURLPath) { (result:SessionManager.MultipartFormDataEncodingResult) in
                switch result
                {
                case .success(let uploadRequest, _, _):
                    uploadRequest.uploadProgress(closure: { (p:Progress) in
                        progress(CGFloat(p.fractionCompleted));
                    }).responseData(completionHandler: { [weak self](response:DataResponse<Data>) in
                        if let strongSelf = self
                        {
                            strongSelf.parseResponseData(response: response, success: success, failure: failure);
                        }
                    })
                case .failure(let error):
                    failure(0, error.localizedDescription);
                }
            }
        }
    }
    
    /**
     文件下载
     
     - parameter downloadUrlPath: 下载的文件远端路径
     - parameter progress:    下载进度
     - parameter success:     成功回调
     - parameter failure:     失败回调
     */
    internal func downloadFile(_ downloadUrlPath:String, progress: @escaping progressClosure, success: @escaping descriptionClosure, failure: @escaping descriptionClosure)
    {
        if [CoreNetWorkStatusNone, CoreNetWorkStatusUnkhow].contains(CoreStatus.currentNetWork())
        {
            failure("无网络，请检测网络");
            return;
        }
        
        //防止Cache目录下有同名的zip文件，先删除
        String.removeFiles(BBHelper.kAppCacheFilePath + "/\((downloadUrlPath as NSString).lastPathComponent)");
        
        var downloadedFilePath:URL?;
        download(downloadUrlPath, method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil) { (temporaryURL:URL, resp:HTTPURLResponse) -> (destinationURL: URL, options: DownloadRequest.DownloadOptions) in
            let directoryURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0];
            if let pathComponent = resp.suggestedFilename
            {
                downloadedFilePath = directoryURL.appendingPathComponent(pathComponent);
            }
            
            if let filePath = downloadedFilePath
            {
                return (filePath, [.removePreviousFile, .createIntermediateDirectories]);
            }
            else
            {
                return (URL(fileURLWithPath: ""), [.removePreviousFile, .createIntermediateDirectories]);
            }
            }.downloadProgress { (p:Progress) in
                progress(CGFloat(p.fractionCompleted));
            }.responseData { (response:DownloadResponse<Data>) in
                if response.result.isSuccess
                {
                    if let filePath = response.destinationURL?.path
                    {
                        success(filePath);
                    }
                    else
                    {
                        failure("无效文件路径，无法解压");
                    }
                }
                else
                {
                    failure("文件下载失败");
                }
        }
    }
    
    // MARK: - private methods
    fileprivate func isNetworking(failure: ntFailedClosure) -> Bool
    {
        if [CoreNetWorkStatusNone, CoreNetWorkStatusUnkhow].contains(CoreStatus.currentNetWork())
        {
            failure(0, "无网络, 请检测网络")
            return false
        }
        return true
    }
    
    fileprivate func paresJSONData(_ streamData: Data?, success: ntSuccessClosure, failure: ntFailedClosure)
    {
        if let sourceData = streamData
        {
            let json: JSON = JSON(data: sourceData)
            if (json.type == .null)
            {
                UIApplication.dLog("\(String(data: sourceData, encoding: String.Encoding.utf8))")
                failure(0, "无效数据，无法解析")
            }
            else
            {
                UIApplication.dLog("Response JsonData:\(json)")
                let code: Int = json[BBHelper.kSuccessField].intValue
                if (code == BBHelper.kSuccessCode)
                {
                    success(json)
                } else {
                    failure(code, json[BBHelper.kMsgField].stringValue)
                }
            }
        }
    }
    
    fileprivate func parseResponseData(response: DataResponse<Data>, success: @escaping ntSuccessClosure, failure: @escaping ntFailedClosure)
    {
        if (response.result.isSuccess)
        {
            self.paresJSONData(response.result.value, success: success, failure: failure)
        } else {
            if let error = response.result.error
            {
                failure(0, error.localizedDescription)
            }
        }
    }
    
    private func checkUpdate(update: @escaping ntUpdateClosure)
    {
        if let appDic = Bundle.main.infoDictionary, let version: String = appDic["CFBundleShortVersionString"] as? String
        {
            let requestURLPath: String = "https://itunes.apple.com/lookup?id=1120159714"
            self.manager.request(requestURLPath, method: .post, parameters: nil, encoding: URLEncoding.default, headers: nil)
            .validate(contentType: ["application/json", "text/json", "text/javascript", "text/html", "image/png"])
            .validate(statusCode: 200..<300)
                .responseData(completionHandler: { (response: DataResponse<Data>) in
                if let sourceData = response.result.value
                {
                    let json: JSON = JSON(data: sourceData)
                    if (json.type == .null)
                    {
                        UIApplication.dLog("\(String(data: sourceData, encoding: String.Encoding.utf8))")
                    } else {
                        UIApplication.dLog(json)
                        if let values = json["results"].array
                        {
                            if let item: JSON = values.last
                            {
                                if let releaseNote: String = item["releaseNotes"].string, let remoteVersion: String = item["version"].string, (remoteVersion.trim() != version)
                                {
                                    update(true, remoteVersion, releaseNote)
                                }
                            }
                        }
                    }
                }
                    update(false, "", "")
            })
        }
    }
    
    internal func appCheckUpdate(update: @escaping ntUpdateClosure)
    {
        self.getRequest(BBHelper.kHTTPUpdateSwitch, params: nil, success: { [weak self] (responseObject: JSON) in
            if (responseObject["data"]["value"].exists())
            {
                if let value: String = responseObject["data"]["value"].string, (value.trim() == "1")
                {
                    if let strongSelf = self
                    {
                        strongSelf.checkUpdate(update: update)
                    }
                }
            }
        }, failure: { (code: Int, description: String) in
            update(false, "", "")
        })
    }
}
