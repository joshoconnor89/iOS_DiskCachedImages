//
//  ViewController.swift
//  DiskCachedImages
//
//  Created by Diego Navarro on 8/16/15.
//  Copyright © 2015 dGambit. All rights reserved.
//

import UIKit

class MainCollectionViewController: UICollectionViewController {
    var dictImages = [Int: UIImage]()
    var dictImagesFiles = [Int: String]()
    let totalImages = 150
    
    //var numberOfSections = 10
    //var numberOfImagesPerSection = 10
    
    enum CachedImageError {
        case NoImage
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createRandomImageDatasource()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: IMAGE DATASOURCE

    func createRandomImageDatasource() {
        for i in 0..<totalImages{
            dictImages[i] = buildRandomImage()
        }
    }
    
    func loadImageForIndexPath(indexPath: NSIndexPath, imageView: UIImageView) {
        if let image = dictImages[indexPath.row] {
            imageView.image = image
        }
        else {
            loadCachedImage(indexPath.row, imageView: imageView)
        }
    }
    
    func loadCachedImage(index: Int, imageView: UIImageView) -> UIImage? {
        if let imageUrl = dictImagesFiles[index] {
            print("loading cached Image \(index)")
            loadFromURL(NSURL(fileURLWithPath: imageUrl)!, imageView: imageView)
            dictImages[index] = UIImage(contentsOfFile: imageUrl)
            return dictImages[index]
        }
        else {
            return nil
        }
    }
    
    func saveImage(image: UIImage, index: Int) {
        let documents = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
        let imagePath = (documents as! NSString).stringByAppendingPathComponent("img-\(index).png")
        
        if (UIImagePNGRepresentation(image)!.writeToFile(imagePath, atomically: true) == true) {
            print("saved!")
            dictImagesFiles[index] = imagePath
        }
    }
    
    // MARK: HELPERS
    
    func buildRandomImage() -> UIImage {
        let rect = CGRectMake(0.0, 0.0, 50.0, 50.0)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        
        CGContextSetFillColorWithColor(context, getRandomColor())
        CGContextFillRect(context, rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
    func getRandomColor() -> CGColorRef {
        return UIColor(red: randomCGFloat(), green: randomCGFloat(), blue: randomCGFloat(), alpha: 1.0).CGColor
    }
    
    func randomCGFloat() -> CGFloat {
        return CGFloat(arc4random_uniform(255)) / 255.0
    }
    
    func loadFromURL(url: NSURL, imageView: UIImageView) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
            
            let imageData = NSData(contentsOfURL: url)
            if let data = imageData {
                imageView.image = UIImage(data: data)
            }
        })
    }
}

    // MARK: - UICollectionViewDataSource

extension MainCollectionViewController {
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return totalImages
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ColorImageCell", forIndexPath: indexPath)
        
        let imageView = UIImageView(frame: CGRect(origin: CGPointZero, size: CGSize(width: 500.0, height: 500.0)))
        
        cell.contentView.addSubview(imageView)
        loadImageForIndexPath(indexPath, imageView: imageView)
        
        return cell as! UICollectionViewCell
    }
    
    override func collectionView(collectionView: UICollectionView, didEndDisplayingCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        print("back up Image \(index)")
        saveImage(dictImages[indexPath.row]!, index: indexPath.row)
        print("deleting from memory Image \(indexPath.row)")
        dictImages[indexPath.row] = nil
    }
}
