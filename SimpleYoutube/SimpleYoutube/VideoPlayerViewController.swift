//
//  VideoPlayerViewController.swift
//  SimpleYoutube
//
//  Created by Junteng on 2023/3/30.
//

import UIKit
import WebKit
import Alamofire

class VideoPlayerViewController: UIViewController {
    var videoInfo: VideoInfo?
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var ownerLabel: UILabel!
    @IBOutlet var uploadLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var commandTableView: UITableView!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var headImageView: UIImageView!
    @IBOutlet var wkWebView: WKWebView!
    var nextPageToken: String?
    var htmlDataString = ""
    
    var commentInfo:[CommetInfo] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        fetchHTMLData()
        initUI()
        fetchDescription()
        fetchComments(50)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Size of the webView is used to size the YT player frame in the JS code
        // and the size of the webView is only known in `viewDidLayoutSubviews`,
        // however, this function is called again once the HTML is loaded, so need
        // to store a bool indicating whether the HTML has already been loaded once
        let baseURL = URL(string: "https://www.youtube.com/")
        wkWebView.loadHTMLString(htmlDataString, baseURL: baseURL)
    }
    
    func initUI() {
        titleLabel.text = videoInfo?.title
        ownerLabel.text = videoInfo?.ownerName
        uploadLabel.text = videoInfo?.uploadTime
        headImageView.layer.cornerRadius = headImageView.frame.height / 2
        headImageView.image = getImageFromFolder("headImage")
        
        descriptionLabel.isHidden = true
        commandTableView.isHidden = true
        scrollView.isHidden = true
        commandTableView.delegate = self
        commandTableView.dataSource = self
    }
    
    func fetchHTMLData() {
        htmlDataString = String.init(format: htmlString, 600, 975, videoInfo?.videoID ?? "")
    }
    
    func fetchDescription() {
        YoutubeAPI().fetchDescription(videoID: videoInfo?.videoID, completion: { result in
            switch result {
            case .success(let(desc)):
                self.descriptionLabel.text = "Description:\n\(desc)"
                self.descriptionLabel.isHidden = false
                self.scrollView.isHidden = false
                self.descriptionLabel.sizeToFit()
                self.scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width,
                                                     height: self.descriptionLabel.bounds.height)
                
            case .failure(let error):
                print(error)
            }
        })
    }
    
    func fetchComments(_ count: Int) {
        YoutubeAPI().fetchComments(count, videoID: videoInfo?.videoID, token: nextPageToken, completion: {result in
            switch result {
            case .success(let(token, infoArray)):
                DispatchQueue.main.async {
                    self.nextPageToken = token
                    self.commentInfo += infoArray
                    self.commandTableView.isHidden = false
                    self.commandTableView.reloadData()
                }
                
            case .failure(let error):
                print(error)
            }
        })
    }

}

extension VideoPlayerViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let row = indexPath.row
        let distance = commentInfo.count - row
        if distance < 10 {
            fetchComments(50)
        }
    }
}

extension VideoPlayerViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commentInfo.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cellIdentifier")
        let row = indexPath.row
        
        cell.textLabel?.text = commentInfo[row].replies
        cell.detailTextLabel?.text = String.init(format: "%@" ,commentInfo[row].authorName)
        
        return cell
    }
}

extension VideoPlayerViewController {
    func getImageFromFolder(_ fileName: String) -> UIImage {
        let imageName: String = String(format: "%@.jpg", fileName)
        
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = path[0].appending("/Image/")
        let fileURL = documentsDirectory.appending(imageName)
        
        if FileManager.default.fileExists(atPath: fileURL) {
            return UIImage(contentsOfFile: fileURL)!
        } else {
          return UIImage()
        }
    }
}
