//
//  ViewController.swift
//  PragmaticTweets
//
//  Created by Chris Adamson on 10/19/14.
//  Copyright (c) 2014 Pragmatic Programmers, LLC. All rights reserved.
//

import UIKit
import Social
import Accounts

public class RootViewController: UITableViewController, TwitterAPIRequestDelegate, UISplitViewControllerDelegate {

  var parsedTweets : Array <ParsedTweet> = []
  
  override public func viewDidLoad() {
    super.viewDidLoad()
    reloadTweets()
    var refresher = UIRefreshControl()
    refresher.addTarget(self,
      action: "handleRefresh:",
      forControlEvents: UIControlEvents.ValueChanged)
    self.refreshControl = refresher
  if self.splitViewController != nil {
  	self.splitViewController!.delegate = self
  }
  }

	func splitViewController(_splitViewController: UISplitViewController!,
    collapseSecondaryViewController secondaryViewController: UIViewController!,
    ontoPrimaryViewController primaryViewController: UIViewController!) -> Bool {
  	return true
	}


  override public func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  

 @IBAction func handleTweetButtonTapped(sender: AnyObject) {
    if SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter) {
      let tweetVC = SLComposeViewController (forServiceType: SLServiceTypeTwitter)
      let message = NSLocalizedString(
        "I just finished the first project in iOS 8 SDK Development. #pragsios8",
        comment:"")
        tweetVC.setInitialText(message)
      self.presentViewController(tweetVC, animated: true, completion: nil)
    } else {
      println ("Can't send tweet")
    }
  }
  
  func reloadTweets() {
    let twitterParams : Dictionary = ["count":"100"]
    let twitterAPIURL = NSURL(string: 
      "https://api.twitter.com/1.1/statuses/home_timeline.json")
    let request = TwitterAPIRequest()
    request.sendTwitterRequest(twitterAPIURL,
      params: twitterParams,
      delegate: self);
  }
  
  func handleTwitterData (data: NSData!,
    urlResponse: NSHTTPURLResponse!,
    error: NSError!,
    fromRequest: TwitterAPIRequest!) {
    if let dataValue = data {
      let jsonString = NSString (data: data, encoding:NSUTF8StringEncoding)
      var parseError : NSError? = nil
      let jsonObject : AnyObject? =
        NSJSONSerialization.JSONObjectWithData(dataValue,
        options: NSJSONReadingOptions(0),
        error: &parseError)
      if parseError != nil {
        return
      }
      if let jsonArray = jsonObject as? Array<Dictionary<String, AnyObject>> {
        self.parsedTweets.removeAll(keepCapacity: true)
        for tweetDict in jsonArray {
          let parsedTweet = ParsedTweet()
          parsedTweet.tweetText = tweetDict["text"]  as? NSString
          parsedTweet.createdAt = tweetDict["created_at"]  as? NSString
          let userDict = tweetDict["user"] as NSDictionary
          parsedTweet.userName = userDict["name"] as? NSString
          parsedTweet.userAvatarURL = NSURL (string:
          userDict ["profile_image_url"] as NSString!)
          parsedTweet.tweetIdString = tweetDict["id_str"] as? NSString
          self.parsedTweets.append(parsedTweet)
        }
        dispatch_async(dispatch_get_main_queue(),
          { () -> Void in
            self.tableView.reloadData()
          })
        }
      } else {
        println ("handleTwitterData received no data")
      }
    }

  override public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  override public func tableView(_tableView: UITableView,
    numberOfRowsInSection section: Int) -> Int {
      return parsedTweets.count
  }
 
  override public func tableView (_tableView: UITableView,
    cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
      let cell =
      tableView.dequeueReusableCellWithIdentifier("CustomTweetCell")
        as ParsedTweetCell
      let parsedTweet = parsedTweets[indexPath.row]
      cell.userNameLabel.text = parsedTweet.userName
      cell.tweetTextLabel.text = parsedTweet.tweetText
      cell.createdAtLabel.text = parsedTweet.createdAt
      if parsedTweet.userAvatarURL != nil {
        cell.avatarImageView.image = nil
        dispatch_async(dispatch_get_global_queue(
          DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
            {() -> Void in
              if let imageData = NSData (contentsOfURL:
                parsedTweet.userAvatarURL!) {
              let avatarImage = UIImage(data: imageData)
              dispatch_async(dispatch_get_main_queue(),
                {
                  if cell.userNameLabel.text == parsedTweet.userName {
                    cell.avatarImageView.image = avatarImage
                  } else {
                    println ("oops, wrong cell, never mind")
                  }
                })
              }
          })
      }
      return cell
  }

  override public func tableView(tableView: UITableView,
    didSelectRowAtIndexPath
    indexPath: NSIndexPath)  {
      let parsedTweet = parsedTweets[indexPath.row]
      if self.splitViewController != nil {
        if (self.splitViewController!.viewControllers.count > 1) {
          if let tweetDetailNav = self.splitViewController!.viewControllers[1]
            as? UINavigationController {
              if let tweetDetailVC = tweetDetailNav.viewControllers[0]
                as? TweetDetailViewController {
              tweetDetailVC.tweetIdString = parsedTweet.tweetIdString
              }
          }
    } else {
    	if let detailVC = 
      self.storyboard!.instantiateViewControllerWithIdentifier("TweetDetailVC")
      	as? TweetDetailViewController { 
        detailVC.tweetIdString = parsedTweet.tweetIdString 
        self.splitViewController!.showDetailViewController(detailVC, sender: self) 
    	}
    }
      }
      tableView.deselectRowAtIndexPath(indexPath, animated: false)
  }
	
  @IBAction func handleRefresh (sender : AnyObject?) {
    reloadTweets()
    refreshControl!.endRefreshing()
  }

  //MARK: storyboards
  override public func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "showTweetDetailsSegue" {
      if let tweetDetailVC = segue.destinationViewController
        as? TweetDetailViewController {
          let row = self.tableView!.indexPathForSelectedRow()!.row
          let parsedTweet = parsedTweets [row] as ParsedTweet
          tweetDetailVC.tweetIdString = parsedTweet.tweetIdString;
      }
    }
  }
  
}

