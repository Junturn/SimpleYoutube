//
//  InfoViewModel.swift
//  SimpleYoutube
//
//  Created by Junteng on 2023/4/26.
//

import Foundation
import UIKit

class InfoViewModel {
    private var infoModel: InfoModel?
    
    var nextPageToken: String?
    var isSearch:Bool = false
    
    // MARK -- closure Action
    var reloadTableView: (()->())?
    var showError: ((String)->())?
    var updateUI:(()->())?
    var showIndicator:(()->())?
    
    init() {
        Path().createImageFolder()
        fetchData(with: 30)
    }
    
    // MARK -- Access to the Model
    var contentInfoArray: [InfoModel] = []
    var tempContentInfoArray: [InfoModel] = []
    
    // MARK -- Intent(s)
    
}

extension InfoViewModel {
    func checkDataCount(with row:Int) {
        if !isSearch {
            let distance = contentInfoArray.count - row
            if distance < 10 {
                fetchYoutubeData(20)
            }
        }
    }
    
    func fetchData(with count:Int) {
        fetchChannelData()
        fetchYoutubeData(30)
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
                    self.showError?(error.localizedDescription)
            }
            
        })
    }
    
    func fetchYoutubeData(_ count:Int) {
        if count == 20 {
            self.showIndicator?()
        }
        
        YoutubeAPI().fetchYoutubeData(count, nextPageToken: nextPageToken, completion: { result in
            switch result {
                case .success(let (token, listArray)):
                    self.nextPageToken = token
                    for item in listArray {
                        self.contentInfoArray.append(item)
                    }
                    self.downloadImage()
                    
                
                case .failure(let error):
                    print(error)
                    self.showError?(error.localizedDescription)
            }
        })
    }
    
    private func downloadImage() {
        let dispatchGroup = DispatchGroup()
    
        dispatchGroup.enter()
        DispatchQueue.global().async {
            for info in self.contentInfoArray {
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
                self.updateUI?()
            }
        }
    }
    
    private func getImageFromURL(_ imgURL:String, _ path: String) {
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
}

// MARK -- SearchBar Action
extension InfoViewModel {
    func didPresetSearchBar() {
        isSearch = true
        tempContentInfoArray.append(contentsOf: contentInfoArray)
        print("")
    }
    
    func finishedSearchBar(){
        isSearch = false
        contentInfoArray.removeAll()
        contentInfoArray.append(contentsOf: tempContentInfoArray)
        tempContentInfoArray.removeAll()
        self.reloadTableView?()
        print("")
    }
    
    func showSearchResult(searchKey keyWord: String) {
        contentInfoArray.removeAll()
        for info in tempContentInfoArray {
            if info.title.contains(keyWord) {
                contentInfoArray.append(info)
            }
        }
        self.reloadTableView?()
    }
}
