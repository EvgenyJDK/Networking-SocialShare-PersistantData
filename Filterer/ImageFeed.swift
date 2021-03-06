//
//  ImageFeed.swift
//  Filterer
//
//  Created by Administrator on 31.05.17.
//  Copyright © 2017 Administrator. All rights reserved.
//

import Foundation


class ImageFeed: NSObject, NSCoding {
    
    let items: [ImageFeedItem]
    let sourceURL: NSURL
    
    init(items newItems: [ImageFeedItem], sourceURL newURL: NSURL) {
        self.items = newItems
        self.sourceURL = newURL
        super.init()
    }

    
// MARK : Methods complying with NSCoding
    
/* Encode itself with all properties */
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.items, forKey: "feedItems")
        aCoder.encodeObject(self.sourceURL, forKey: "feedSourceURL")
    }
    
/* Decode ImageFeed from file */
    required convenience init?(coder aDecoder: NSCoder) {
        let storedItems = aDecoder.decodeObjectForKey("feedItems") as? [ImageFeedItem]
        let storedURL = aDecoder.decodeObjectForKey("feedSourceURL") as? NSURL
        
        guard storedItems != nil && storedURL != nil else {
            return nil
        }
        self.init(items: storedItems!, sourceURL: storedURL!)
    }

    
    
/* Transform JSONData (data: NSData) into SWIFT objects */
    convenience init? (data: NSData, sourceURL url: NSURL) {
        
        var newItems = [ImageFeedItem]()
        let fixedData = fixJsonData(data)
        var jsonObject: [String: AnyObject]?
        
        do {
            jsonObject = try NSJSONSerialization.JSONObjectWithData(fixedData, options: NSJSONReadingOptions(rawValue: 0)) as? [String: AnyObject]
        } catch {
            
        }
        
        guard let feedRoot = jsonObject else {
            return nil
        }
        guard let items = feedRoot["items"] as? [AnyObject]  else {
            return nil
        }
        
        
        for item in items {
            
            guard let itemDict = item as? [String: AnyObject] else {
                continue
            }
            guard let media = itemDict["media"] as? [String: AnyObject] else {
                continue
            }
            guard let urlString = media["m"] as? String else {
                continue
            }
            guard let url = NSURL(string: urlString) else {
                continue
            }
            
            let title = itemDict["title"] as? String
            newItems.append(ImageFeedItem(title: title ?? "(no title)", imageURL: url))
        }
        
        self.init(items: newItems, sourceURL: url)
    }


    
}




func fixJsonData (data: NSData) -> NSData {
    var dataString = String(data: data, encoding: NSUTF8StringEncoding)!
    dataString = dataString.stringByReplacingOccurrencesOfString("\\'", withString: "'")
    return dataString.dataUsingEncoding(NSUTF8StringEncoding)!
    
}

