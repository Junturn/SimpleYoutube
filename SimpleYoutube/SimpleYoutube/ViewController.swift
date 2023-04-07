//
//  ViewController.swift
//  SimpleYoutube
//
//  Created by Junteng on 2023/3/28.
//

import UIKit
import Alamofire
import SkeletonView

class ViewController: UIViewController {
    
    @IBOutlet var mainTableView: UITableView!
    @IBOutlet var IndicatorView: UIActivityIndicatorView!
    var playlistInfo:[VideoInfo] = []
    var tempListInfo:[VideoInfo] = []
    var nextPageToken: String?
    var isSearch: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let searchController = UISearchController()
        searchController.searchResultsUpdater = self
        searchController.delegate = self
        navigationItem.searchController = searchController
        
        Path().createImageFolder()
        fetchChannelData()
        fetchYoutubeData(30)
        mainTableView.register(UINib(nibName: "infoCell", bundle: nil), forCellReuseIdentifier: "infoCell")
        mainTableView.dataSource = self
        mainTableView.delegate = self
        
        mainTableView.isSkeletonable = true
        mainTableView.showAnimatedSkeleton()
    }
    
    func fetchChannelData() {
        if Path().checkImageExist("headImage.jpg") {
            return
        }
        
        YoutubeAPI().fetchChannelData(completion: {result in
            switch result {
                case .success(let (path, url)):
                    DispatchQueue.global().async {
                        self.getImageFromURL(url, path)
                    }
            
                case .failure(let error):
                    print(error)
                    self.showErrorMsg(error.localizedDescription)
            }
            
        })
    }
    
    func fetchYoutubeData(_ count:Int) {
        YoutubeAPI().fetchYoutubeData(count, nextPageToken: nextPageToken, completion: { result in
                switch result {
                    case .success(let (token, listArray)):
                        self.nextPageToken = token
                        self.playlistInfo += listArray
                        self.updateUI()
                
                    case .failure(let error):
                        print(error)
                        self.showErrorMsg(error.localizedDescription)
                }
        })
    }
    
    func updateUI() {
        let dispatchGroup = DispatchGroup()
    
        dispatchGroup.enter()
        DispatchQueue.global().async {
            for info in self.playlistInfo {
                let imageName = String.init(format: "%@.jpg", info.videoID)
                if Path().checkImageExist(imageName) {
                    continue
                }
                let path = Path().getFolderURL(imageName)
                self.getImageFromURL(info.imgURL, path)
            }
            dispatchGroup.leave()
        }
        
        dispatchGroup.notify(queue: DispatchQueue.global()) {
            DispatchQueue.main.async {
                self.mainTableView.reloadData()
                self.mainTableView.hideSkeleton()
                if !self.IndicatorView.isHidden {
                    self.IndicatorView.isHidden = true
                    self.IndicatorView.stopAnimating()
                }
            }
        }
    }
    
    func getImageFromURL(_ imgURL:String, _ path: String) {
        guard let url = URL(string: imgURL) else {
            return
        }
        do {
            let data = try Data(contentsOf: url)
            let image = UIImage(data: data)!
            guard let imageData = image.jpegData(compressionQuality: 1.0) else {
                print("convert to jpg error")
                return
            }
            do {
                try imageData.write(to: URL(fileURLWithPath: path), options: .atomic)
            } catch {
                print(error)
            }
            
        } catch {
            return
        }
    }
    
    func showErrorMsg(_ msg:String) {
        let alertController = UIAlertController(title: "Something Error", message: "Please check your network is available or \(msg)", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default) { (action: UIAlertAction!) -> Void in

        }
        alertController.addAction(action)

        self.present(alertController, animated:true, completion: nil)
    }

}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
      return 330
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if isSearch {
            return
        }
        let row = indexPath.row
        let distance = playlistInfo.count - row
        if distance < 10 {
            fetchYoutubeData(20)
            
            IndicatorView.isHidden = false
            IndicatorView.startAnimating()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      
    }
}

extension ViewController: SkeletonTableViewDataSource {
    func numSections(in collectionSkeletonView: UITableView) -> Int {
        return 1
    }
    
    func collectionSkeletonView(_ skeletonView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playlistInfo.count
    }
    
    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return "infoCell"
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playlistInfo.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "infoCell") as! infoCell
        let row = indexPath.row
        cell.infoViewTouchDelegate = self
        cell.ownerLabel.text = playlistInfo[row].ownerName
        cell.titleLabel.text = playlistInfo[row].title
        cell.uploadLabel.text = playlistInfo[row].uploadTime
        cell.coverImageView.image = Path().getImageFromFolder(playlistInfo[row].videoID)
        cell.headImageView.image = Path().getImageFromFolder("headImage")
        cell.row = row
        return cell
    }
    
}

extension ViewController: UISearchControllerDelegate {
    
    func didPresentSearchController(_ searchController: UISearchController) {
        tempListInfo = playlistInfo
        isSearch = true
    }
    
    func didDismissSearchController(_ searchController: UISearchController) {
        isSearch = false
        playlistInfo = tempListInfo
        tempListInfo.removeAll()
        DispatchQueue.main.async {
            self.mainTableView.reloadData()
        }
    }

}

extension ViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if !isSearch {
            return
        }
            
        if let searchWord = searchController.searchBar.text {
            playlistInfo.removeAll()
            for info in tempListInfo {
                if info.title.contains(searchWord) {
                    playlistInfo.append(info)
                }
            }
        }
        DispatchQueue.main.async {
            self.mainTableView.reloadData()
        }
    }
}

extension ViewController: InfoViewTouchDelegate {
    func nextPage(_ row: Int) {
        let videoPlayerVC = VideoPlayerViewController(nibName: "VideoPlayerViewController", bundle: nil)
        videoPlayerVC.videoInfo = playlistInfo[row]
        self.navigationController?.pushViewController(videoPlayerVC, animated: true)
    }
}
