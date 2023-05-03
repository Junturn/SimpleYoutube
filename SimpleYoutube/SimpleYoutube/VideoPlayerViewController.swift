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
    var videoInfo: InfoModel!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var ownerLabel: UILabel!
    @IBOutlet var uploadLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var commandTableView: UITableView!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var headImageView: UIImageView!
    @IBOutlet var wkWebView: WKWebView!
    
    let videoPlayerVM = VideoPlayerViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        videoPlayerVM.initData(model: videoInfo)
        initUI()
        
        videoPlayerVM.updateDescriptionView = { description in
            DispatchQueue.main.async {
                self.descriptionLabel.text = "Description:\n\(description)"
                self.descriptionLabel.isHidden = false
                self.scrollView.isHidden = false
                self.descriptionLabel.sizeToFit()
                self.scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width,
                                                     height: self.descriptionLabel.bounds.height)
            }
        }
        
        videoPlayerVM.reloadTableView = {
            DispatchQueue.main.async {
                self.commandTableView.isHidden = false
                self.commandTableView.reloadData()
            }
        }
        
        videoPlayerVM.updateWebView = {
            self.view.setNeedsLayout()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Size of the webView is used to size the YT player frame in the JS code
        // and the size of the webView is only known in `viewDidLayoutSubviews`,
        // however, this function is called again once the HTML is loaded, so need
        // to store a bool indicating whether the HTML has already been loaded once
        
        let baseURL = URL(string: "https://www.youtube.com/")
        self.wkWebView.loadHTMLString(videoPlayerVM.getHTMLString(), baseURL: baseURL)

    }
    
    func initUI() {
        titleLabel.text = videoInfo.title
        ownerLabel.text = videoInfo.ownerName
        uploadLabel.text = videoInfo.uploadTime
        headImageView.layer.cornerRadius = headImageView.frame.height / 2
        headImageView.image = videoPlayerVM.getImageFromFolder("headImage")
        
        descriptionLabel.isHidden = true
        commandTableView.isHidden = true
        scrollView.isHidden = true
        commandTableView.delegate = self
        commandTableView.dataSource = self
    }
}

extension VideoPlayerViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let row = indexPath.row
        videoPlayerVM.checkComment(row:row)
    }
}

extension VideoPlayerViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return videoPlayerVM.getCommentInfoCount()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cellIdentifier")
        let row = indexPath.row
        let infoData = videoPlayerVM.getCommentInfoData(row: row)
        cell.textLabel?.text = infoData.replies
        cell.detailTextLabel?.text = String.init(format: "%@" ,infoData.authorName) 
        return cell
    }
}
