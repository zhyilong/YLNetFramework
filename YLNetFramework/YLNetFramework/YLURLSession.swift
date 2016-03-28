//
//  YLURLSession.swift
//  YLNetFramework
//
//  Created by zhangyilong on 15/12/30.
//  Copyright © 2015年 zhangyilong. All rights reserved.
//

import Foundation

class YLURLSession: NSURLSession
{
    var session:NSURLSession?;
    var task:NSURLSessionTask?;
    var owner:NSObject?;
    
    deinit
    {
        print("YLURLSessin dealloc");
    }

    func cancel()
    {
        if nil != session
        {
            session?.invalidateAndCancel();
        }
    }
}
