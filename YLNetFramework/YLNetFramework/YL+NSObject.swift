//
//  YL+NSObject.swift
//  YLNetFramework
//
//  Created by zhangyilong on 15/12/30.
//  Copyright © 2015年 zhangyilong. All rights reserved.
//

import Foundation
import ObjectiveC

private var sessionKey = "YLNetSessins";

extension NSObject
{
    var sessions:Dictionary<Int, YLURLSession>?{
        set
        {
            //解除绑定
            if nil == newValue
            {
                objc_setAssociatedObject(self, &sessionKey, nil, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            }
            else
            {
                //是否已经添加过
                if nil == objc_getAssociatedObject(self, &sessionKey)
                {
                    objc_setAssociatedObject(self, &sessionKey, newValue as! AnyObject, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                }
            }
        }
        get
        {
            return (objc_getAssociatedObject(self, &sessionKey) as? Dictionary<Int, YLURLSession>);
        }
    }

    /**
     添加网络请求列表
     */
    private func setYLNetSessionSet() -> Dictionary<Int, YLURLSession>?
    {
        self.sessions = Dictionary<Int, YLURLSession>();
        
        return self.sessions;
    }
    
    /**
    获得网络请求列表
    
    - returns: 列表
    */
    private func getYLNetSessionSet() -> Dictionary<Int, YLURLSession>?
    {
        if nil == self.sessions
        {
            setYLNetSessionSet();
        }
        
        return self.sessions;
    }
    
    /**
     添加网络请求到网络列表中
     
     - parameter session: 无
     */
    func addNetSession(session:YLURLSession?)
    {
        if nil != session
        {
            let key:Int = session!.hash;
            
            getYLNetSessionSet();
            
            self.sessions![key] = session!;
        }
    }
    
    /**
     删除并取消置顶网络请求
     
     - parameter session: 无
     */
    func removeYLNetSession(session:YLURLSession?)
    {
        if nil != self.sessions && nil != session
        {
            let key:Int = session!.hash;
            if nil != self.sessions![key]
            {
                self.sessions!.removeValueForKey(key);
            }
        }
    }
    
    /**
     清空取消所有网络请求，务必在deinit中进行调用，确保该对象关联的网络请求去不取消，减少资源的浪费
     */
    func clearYLNetSession()
    {
        if nil != self.sessions
        {
            for session in self.sessions!.values
            {
                session.cancel();
            }
            
            self.sessions!.removeAll();
            
            self.sessions = nil;
        }
    }
}
