//
//  YLNetFramework.swift
//  YLNetFramework
//
//  Created by zhangyilong on 15/12/30.
//  Copyright © 2015年 zhangyilong. All rights reserved.
//

import Foundation

typealias YLNetCallBack = (session:YLURLSession, data:NSData?, error:NSError?)->Void;

class YLNetFramework
{
    private static var g_instance:YLNetFramework = YLNetFramework();
    var sessions:Dictionary<Int, YLURLSession>;
    var operationQuene:NSOperationQueue;
    
    class func ShareYLNetFramework() -> YLNetFramework
    {
        return g_instance;
    }
    
    private init()
    {
        //获得cup的核心数量
        var corenum:Int = 0;
        var len:Int = sizeof(corenum.dynamicType);
        sysctlbyname("hw.ncpu", &corenum, &len, nil, 0);

        operationQuene = NSOperationQueue();
        operationQuene.maxConcurrentOperationCount = corenum;
        
        sessions = Dictionary<Int, YLURLSession>();
    }
    
    deinit
    {
        //
    }
    
    private func inserSession(session:YLURLSession) -> Void
    {
        let key:Int = session.hash;
        
        sessions[key] = session;
    }
    
    private func removeSession(session:YLURLSession) -> Void
    {
        let key:Int = session.hash;
        
        let tmp:YLURLSession? = sessions[key];
        
        if nil != tmp
        {
            sessions.removeValueForKey(key);
            
            tmp!.cancel();
        }
    }
    
    private func resetSysError(error:NSError?) -> NSError?
    {
        if nil != error
        {
            var description:String;
            
            switch error!.code
            {
                case NSURLErrorCannotFindHost:
                    description = "无法找到主机";
                    break;
                case NSURLErrorCannotConnectToHost:
                    description = "不能连接到服务器";
                    break;
                case NSURLErrorNotConnectedToInternet:
                    description = "不能访问互联网";
                    break;
                case NSURLErrorTimedOut:
                    description = "网络请求超时";
                    break;
                default:
                    description = "未知错误";
                    break;
            }
            
            let newerror = NSError(domain: description, code: error!.code, userInfo: nil);
            
            return newerror;
        }
        
        return nil;
    }
    
    private func resumeDataTask(owner:NSObject?, callback:YLNetCallBack?, request:NSMutableURLRequest) -> Void
    {
        let config:NSURLSessionConfiguration = NSURLSessionConfiguration.ephemeralSessionConfiguration();
        config.timeoutIntervalForRequest = request.timeoutInterval;
        config.requestCachePolicy = NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData;
        
        let ylsession = YLURLSession();
        let session:NSURLSession = NSURLSession(configuration: config, delegate: nil, delegateQueue: operationQuene);
        
        let task:NSURLSessionDataTask = session.dataTaskWithRequest(request, completionHandler: { (data:NSData?, response:NSURLResponse?, error:NSError?) -> Void in
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if nil != callback
                {
                    callback!(session:ylsession, data:data, error:self.resetSysError(error));
                }
            });
            
            if nil != ylsession.owner
            {
                ylsession.owner!.removeYLNetSession(ylsession);
            }
            
            self.removeSession(ylsession);
            
        });
        
        ylsession.session = session;
        ylsession.task = task;
        ylsession.owner = owner;
        
        if nil != owner
        {
            owner!.addNetSession(ylsession);
        }
        
        inserSession(ylsession);
        
        ylsession.task!.resume();
    }
    
    private func resumeDownloadTask(owner:NSObject?, callback:YLNetCallBack?, request:NSMutableURLRequest) -> Void
    {
        let config:NSURLSessionConfiguration = NSURLSessionConfiguration.ephemeralSessionConfiguration();
        config.timeoutIntervalForRequest = request.timeoutInterval;
        config.requestCachePolicy = NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData;
        
        let ylsession = YLURLSession();
        let session:NSURLSession = NSURLSession(configuration: config, delegate: nil, delegateQueue: operationQuene);
        
        let task:NSURLSessionDownloadTask = session.downloadTaskWithRequest(request) { (localtion:NSURL?, reponse:NSURLResponse?, error:NSError?) -> Void in

            var data:NSData?;
            if nil != localtion
            {
                data = NSData(contentsOfURL: localtion!);
            }
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if nil != callback
                {
                    callback!(session:ylsession, data:data, error:self.resetSysError(error));
                }
            });
            
            if nil != ylsession.owner
            {
                ylsession.owner!.removeYLNetSession(ylsession);
            }
            
            self.removeSession(ylsession);
        }
    
        ylsession.session = session;
        ylsession.task = task;
        ylsession.owner = owner;
        
        if nil != owner
        {
            owner!.addNetSession(ylsession);
        }
        
        inserSession(ylsession);
        
        ylsession.task!.resume();
    }

    func addPostDataRequest(url:String?, data:NSData?, owner:NSObject?, callback:YLNetCallBack?, timeout:UInt)
    {
        if nil != url && nil != data
        {
            let nsurl:NSURL = NSURL(string: url!)!;
            let request:NSMutableURLRequest = NSMutableURLRequest(URL: nsurl, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData, timeoutInterval: Double(timeout));
            
            request.HTTPMethod = "POST";
            request.HTTPBody = data!;
            
            resumeDataTask(owner, callback: callback, request: request);
        }
    }
    
    func addGetRequest(url:String?, owner:NSObject?, callback:YLNetCallBack?, timeout:UInt)
    {
        if nil != url
        {
            let nsurl:NSURL = NSURL(string: url!)!;
            let request:NSMutableURLRequest = NSMutableURLRequest(URL: nsurl, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData, timeoutInterval: Double(timeout));
            
            request.HTTPMethod = "GET";
            
            resumeDataTask(owner, callback: callback, request: request);
        }
    }
    
    func addDownloadRequest(url:String?, owner:NSObject?, callback:YLNetCallBack?, timeout:UInt)
    {
        if nil != url
        {
            let nsurl:NSURL = NSURL(string: url!)!;
            let request:NSMutableURLRequest = NSMutableURLRequest(URL: nsurl, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData, timeoutInterval: Double(timeout));
            
            request.HTTPMethod = "GET";
            
            resumeDownloadTask(owner, callback: callback, request: request);
        }
    }
}
