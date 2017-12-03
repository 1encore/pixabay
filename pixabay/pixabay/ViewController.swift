//
//  ViewController.swift
//  pixabay
//
//  Created by Beisenbek Yerbolat on 12/1/17.
//  Copyright © 2017 Beisenbek Yerbolat. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var pictureUrl : [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        collectionView.delegate = self
        collectionView.dataSource = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func getPictures(query: String) {
        let query = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        let url = "https://pixabay.com/api/?key=7245386-4182d4a2c6f2da50af7ffcfc6&q=\(query!)&image_type=photo&pretty=true"
        print(url)
        
        URLSession.shared.dataTask(with: URL(string: url)!) { (data, response, error) in
            if (error != nil) {
                print(error?.localizedDescription)
            } else {
                let json = try! JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String: AnyObject]
                if let hits = json["hits"] as? [[String: AnyObject]] {
                    print("get pictures", hits)
                    
                    self.pictureUrl = []
                    
                    for picture in hits {
                        if let previewURL = picture["previewURL"] as? String {
                            self.pictureUrl.append(previewURL)
                        }
                    }
                    
                    print("picture links are", self.pictureUrl)
                    
                    
                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
                    }
                }
            }
        }.resume()
    }
}

extension ViewController : UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.pictureUrl.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! PhotoCollectionViewCell
        
        cell.imageView.imageFromUrl(urlString: self.pictureUrl[indexPath.row])
        
        return cell
    }
}

extension ViewController : UISearchBarDelegate
{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        var text = searchBar.text
        if text != nil {
            self.getPictures(query: text!)
        }
    }
}

extension UIImageView {
    public func imageFromUrl(urlString: String) {
        if let url = URL(string: urlString) {
            URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
                if (error != nil) {
                    print(error?.localizedDescription)
                } else {
                    if let image = UIImage(data: data!) {
                        DispatchQueue.main.async {
                            self.image = image
                        }
                    }
                }
            }).resume()
        }
    }
}
