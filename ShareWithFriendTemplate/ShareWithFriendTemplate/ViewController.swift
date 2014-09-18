//
//  ViewController.swift
//  ShareWithFriendTemplate
//
//  Created by derrick on 9/17/14.
//  Copyright (c) 2014 derrick. All rights reserved.
//

import UIKit
import Social

class ViewController: UIViewController {
                            
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    @IBAction func shareTweet(sender: AnyObject) {
        if (SLComposeViewController.isAvailableForServiceType(SLServiceTypeFacebook)) {
            // can improve by setting initial text to "catch the audience's attention by providing them link
            // add better button
            var tweetSheet:SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
            self.presentViewController(tweetSheet, animated: true, completion: nil)
        }
        else {
            
            var tweetAlert:UIAlertView! = UIAlertView(title: "Error!", message: "Check if you have setup a valid Twitter account or allow access to Twitter in the setting", delegate: nil, cancelButtonTitle: "Cancel" )
            tweetAlert.show()
        }
    }
    
    
    @IBAction func shareFacebook(sender: AnyObject) {
        if (SLComposeViewController.isAvailableForServiceType(SLServiceTypeFacebook)) {
            var faceSheet:SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
            self.presentViewController(faceSheet, animated: true, completion: nil)
        }
        else {
            
            var FaceBookAlert:UIAlertView! = UIAlertView(title: "Error!", message: "Check if you have setup a valid Facebook account or allow access to Facebook in the setting", delegate: nil, cancelButtonTitle: "Cancel" )
            FaceBookAlert.show()
        }
    }
}

