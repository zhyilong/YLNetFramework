//
//  YL+UIImageView.swift
//  YLNetFramework
//
//  Created by zhangyilong on 16/1/4.
//  Copyright © 2016年 zhangyilong. All rights reserved.
//

import Foundation
import UIKit
import ObjectiveC

private let cacheName = "Image";

class YLImageView: UIImageView
{
    var url:String?;
    var catchName:String?;
    var isCache:Bool = true;
    
    /**
     获得图片缓存目录
     
     - returns: 缓存目录
     */
    class func cachePath() -> String
    {
        var paths:[String] = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true);
        return paths[0] + "/" + cacheName;
    }
    
    /**
     创建图片缓存目录
     */
    class func createCachePath()
    {
        let filemanager = NSFileManager.defaultManager();
        var isDir = ObjCBool(false)
        
        if !filemanager.fileExistsAtPath(YLImageView.cachePath(), isDirectory:&isDir)
        {
            do
            {
                try filemanager.createDirectoryAtPath(YLImageView.cachePath(), withIntermediateDirectories: true, attributes: nil);
            }
            catch
            {
                print("创建图片缓存目录失败!!!");
            }
        }
    }
    
    /**
     删除图片缓存目录
     */
    class func removeCachePath()
    {
        let filemanager = NSFileManager.defaultManager();
        
        do
        {
            try filemanager.removeItemAtPath(YLImageView.cachePath());
        }
        catch
        {
            print("删除图片缓存失败!!!");
        }
    }
    
    /**
     图片保存到缓存中
     
     - parameter data: 数据
     */
    class func saveData(data:NSData?, cachename:String?)
    {
        if nil != data && nil != cachename
        {
            let path:String = YLImageView.cachePath() + "/" + cachename!;
            
            if !data!.writeToFile(path, atomically: true)
            {
                print("图片保存到缓存失败!!!");
            }
        }
    }
    
    /**
     下载图片
     
     - parameter url:       网络地址
     - parameter cachename: 本地缓存文件名称包括扩展名
     - parameter iscache:   是否从缓存读取
     */
    func download(url:String?, cachename:String?, iscache:Bool)
    {
        ///取消之前的下载任务，若之前的下载任务存在
        cancelDownload();
        
        self.url = url;
        self.catchName = cachename;
        self.isCache = iscache;
        
        if nil != cachename && iscache
        {
            let path = YLImageView.cachePath() + "/" + cachename!;
            let data:NSData? = NSData(contentsOfFile: path);
            
            if nil != data
            {
                self.image = UIImage(data: data!);
                
                return;
            }
        }
        
        if nil != url
        {
            loadFromNet(url!);
        }
    }
    
    /**
     下载图片
     
     - parameter url: 网络地址
     */
    private func loadFromNet(url:String)
    {
        YLNetFramework.ShareYLNetFramework().addDownloadRequest(url, owner: self, callback: { (session, data, error) -> Void in
            
            if nil == error && nil != data
            {
                self.image = UIImage(data: data!)!;
                
                //保存到缓存中
                YLImageView.saveData(data!, cachename: self.catchName);
            }
            
            }, timeout: 0);
    }
    
    /**
     取消下载
     */
    private func cancelDownload()
    {
        clearYLNetSession();
    }
    
    override init(frame: CGRect)
    {
        super.init(frame: frame);
    }
    
    override init(image: UIImage?)
    {
        super.init(image: image);
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder);
    }
    
    deinit
    {
        clearYLNetSession();
    }
}
