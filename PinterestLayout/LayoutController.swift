//
//  LayoutController.swift
//  PinterestLayout
//
//  Created by Shrikar Archak on 12/21/14.
//  Copyright (c) 2014 Shrikar Archak. All rights reserved.
//

import UIKit

let reuseIdentifier = "collCell"

class LayoutController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    let sectionInsets = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
    let titles = ["Sand Harbor, Lake Tahoe - California","Beautiful View of Manhattan skyline.","Watcher in the Fog","Great Smoky Mountains National Park, Tennessee","Most beautiful place"]
    var videos = []
    var imageCache : NSDictionary = NSDictionary()
    
    override func viewDidLoad() {
        // http://stackoverflow.com/questions/13085662/pull-to-refresh-in-uicollectionviewcontroller
        self.loadItems()
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        NSLog("%@", "Received memory warning")
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        //#warning Incomplete method implementation -- Return the number of sections
        return 1
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //#warning Incomplete method implementation -- Return the number of items in the section
        return videos.count
    }


    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as CollectionViewCell
        NSLog("%@", "Rendering cell \(indexPath) ")
//        cell.title.text = self.titles[indexPath.row % 5]
//        let curr = indexPath.row % 5  + 1
//        let imgName = "pin\(curr).jpg"
//        cell.thumbnail?.image = UIImage(named: imgName)
        
        let idx = indexPath.row
        cell.title.text = self.videos[idx]["title"]! as? String
        let thumbnailPath = self.videos[idx]["snapshotUrl"]! as? String
        let image_url = NSURL(string: thumbnailPath!)
        if let uiImageInst: UIImage = self.imageCache.valueForKey("image\(idx)") as? UIImage {
            cell.thumbnail.image = uiImageInst
            return cell
        }
        
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
//            // do some task
            
            let image_data = NSData(contentsOfURL: image_url!)
            if ( image_data != nil ) {
                let uiImageInst = UIImage(data: image_data!)

                dispatch_async(dispatch_get_main_queue()) {
                    if ( cell.thumbnail != nil && image_data != nil ) {
                        cell.thumbnail.image = uiImageInst
                        let k = "image\(idx)"
                        self.imageCache.setValue(uiImageInst, forKey: k)
                    }
                }
            }
        }
        return cell
    }
    
    func loadItems() -> Bool {
        var url:String = "http://play.streamkit.tv/content/channel/sperantatv/albums/ABC-ul_Sanatatii.search.json"
        var request : NSMutableURLRequest = NSMutableURLRequest()
        request.URL = NSURL(string:url)
        request.HTTPMethod = "GET"
        
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue(), completionHandler:{ (response:NSURLResponse!, data:NSData!, error:NSError!) -> Void in
                var error: AutoreleasingUnsafeMutablePointer<NSError?> = nil
                let jsonResult: NSDictionary! = NSJSONSerialization.JSONObjectWithData(data, options:NSJSONReadingOptions.MutableContainers, error: error) as? NSDictionary
            
                if (jsonResult != nil) {
                    NSLog("%@", "...loaded")
                    
                    if let items = jsonResult["items"]! as? [[String:AnyObject]] {
                        let count : Int = items.count
                        NSLog("%@", "Loaded \(count) items ... ")
                        self.videos = items;
                        self.imageCache = NSMutableDictionary()
                    }
                    NSLog("%@", "About to reload  data ... ")
                    self.collectionView?.reloadData()
                    NSLog("%@", "Data reloaded ... ")
                    
                } else {
                    // couldn't load JSON, look at error
                }
            }

        )
        return false
    }
    


   
    func collectionView(collectionView: UICollectionView!,
        layout collectionViewLayout: UICollectionViewLayout!,
        sizeForItemAtIndexPath indexPath: NSIndexPath!) -> CGSize {
            return CGSize(width: 170, height: 300)
    }
    


    
    func collectionView(collectionView: UICollectionView!,
        layout collectionViewLayout: UICollectionViewLayout!,
        insetForSectionAtIndex section: Int) -> UIEdgeInsets {
            return sectionInsets
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        println(segue.identifier)
        println(sender)
        if(segue.identifier == "detail"){
            let cell = sender as CollectionViewCell
            let indexPath = collectionView?.indexPathForCell(cell)
            let vc = segue.destinationViewController as DetailViewController

            let curr = indexPath!.row % 5  + 1
            let imgName = "pin\(curr).jpg"
            
            println(vc)
            vc.currImage = UIImage(named: imgName)
            vc.textHeading = self.titles[indexPath!.row % 5]
//            
//            vc.heading.text = self.titles[0]
//            vc.imageView.image = UIImage(named: imgName)
        }
    }

    

}
