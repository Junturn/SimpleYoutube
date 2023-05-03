//
//  VideoPlayerViewModel.swift
//  SimpleYoutube
//
//  Created by Junteng on 2023/5/3.
//

import Foundation
import WebKit

class VideoPlayerViewModel {
    private var infoModel: InfoModel!
    private var nextPageToken: String?
    private var htmlDataString: String = ""
    private var commentInfo: [CommetInfo] = []
    private var withoutData: Bool = false
    var alreadyInit: Bool = false
    
    // MARK -- closure Action
    var reloadTableView: (()->())?
    var updateDescriptionView: ((String)->())?
    var updateWebView: (()->())?
    
    func initData(model: InfoModel) {
        infoModel = InfoModel(title: model.title,
                              imgURL: model.imgURL,
                              ownerName: model.ownerName,
                              uploadTime: model.uploadTime,
                              videoID: model.videoID)
        fetchDescription()
        fetchComments(count: 50)
        setupHTMLData()
    }
    
    func setupHTMLData() {
        htmlDataString = String.init(format: htmlString, 600, 975, infoModel?.videoID ?? "")
        self.updateWebView?()
    }
    
    func getCommentInfoCount() -> Int {
        return commentInfo.count
    }
    
    func getCommentInfoData(row: Int) -> CommetInfo {
        return commentInfo[row]
    }
    
    func getHTMLString() -> String {
        return htmlDataString
    }
}

extension VideoPlayerViewModel {
    private func fetchDescription() {
        YoutubeAPI().fetchDescription(videoID: infoModel.videoID, completion: { result in
            switch result {
            case .success(let(desc)):
                self.updateDescriptionView?(desc)
                
            case .failure(let error):
                print(error)
            }
        })
    }
    
    func fetchComments(count: Int) {
        if withoutData {
            NSLog("已經沒有其他留言了", "")
            return
        }
        YoutubeAPI().fetchComments(count, videoID: infoModel?.videoID, token: nextPageToken, completion: {result in
            switch result {
            case .success(let(token, infoArray, anyData)):
                DispatchQueue.main.async {
                    self.withoutData = anyData
                    self.nextPageToken = token
                    self.commentInfo += infoArray
                    self.reloadTableView?()
                }
                
            case .failure(let error):
                print(error)
            }
        })
    }
}

extension VideoPlayerViewModel {
    func checkComment(row:Int) {
        let distance = commentInfo.count - row
        if distance < 10 {
            fetchComments(count: 50)
        }
    }
    
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
