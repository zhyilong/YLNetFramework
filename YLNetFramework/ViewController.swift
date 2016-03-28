//
//  ViewController.swift
//  YLNetFramework
//
//  Created by zhangyilong on 15/12/30.
//  Copyright © 2015年 zhangyilong. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var button: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func OnButtonDown(sender:UIButton)
    {
        YLNetFramework.ShareYLNetFramework().addDownloadRequest("http://www.41443.com/8x8.jpg", owner: self, callback: { (session, data, error) -> Void in
            
            if nil != data
            {
                let imageview:UIImageView = UIImageView(frame: CGRectMake(0, 0, 100, 100));
                self.view.addSubview(imageview);
                
                imageview.image = UIImage(data: data!);
                print("下载成功");
            }
            
            }, timeout: 10);
        
        let imageview:YLImageView = YLImageView(frame:CGRect(x: 0, y: 0, width: 200, height: 200));
        self.view.addSubview(imageview);
        
        imageview.download("http://cc.cocimg.com/api/uploads/20160107/1452138697965963.jpg", cachename: "1452138697965963.jpg", iscache: true);
    }
}

