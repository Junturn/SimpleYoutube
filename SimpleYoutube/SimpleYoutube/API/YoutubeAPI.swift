//
//  YoutubeAPI.swift
//  SimpleYoutube
//
//  Created by Junteng on 2023/3/31.
//

import UIKit
import Alamofire

class YoutubeAPI: NSObject {
    public static let shared = YoutubeAPI()
    
    func fetchChannelData(completion: ((Result<(path:String, url:String), Error>) -> Void)?) {
        let urlString = "https://youtube.googleapis.com/youtube/v3/channels?part=snippet&id=\(channelID)&key=\(apiKey)"
        AF.request(urlString).response { (response: AFDataResponse) in
            switch response.result {
            case .success(let JSON):
                do {
                    var url = ""
                    let decoder = JSONDecoder()
                    let channelInfo = try decoder.decode(ChannelInfo.self, from: JSON ?? Data())
                    for data in channelInfo.items {
                        url = data.snippet.thumbnails.medium.url
                    }
                    let imageName = "headImage.jpg"
                    let path = Path().getFolderURL(imageName)
                    completion?(.success((path, url)))
                    

                } catch {
                    completion?(.failure(error))
                }

            case .failure(let error):
                completion?(.failure(error))
            }
        }
    }

    func fetchYoutubeData(_ count:Int, nextPageToken: String?, completion: ((Result<(token:String, listArray:[InfoModel], withoutData: Bool), Error>) -> Void)?) {
        var urlString = "https://youtube.googleapis.com/youtube/v3/playlistItems?part=snippet,contentDetails,status&playlistId=\(playListID)&key=\(apiKey)&maxResults=\(count)"
        if nextPageToken != nil {
            urlString = String.init(format: "%@&pageToken=%@", urlString, nextPageToken!)
        }
        
        AF.request(urlString).response { (response:AFDataResponse) in
                        switch response.result {
                            case .success(let JSON):
                            do {
                                let decoder = JSONDecoder()
                                let playListItem = try decoder.decode(PlayList.self, from: JSON ?? Data())
                                var dataArray:[InfoModel] = []
                                for item in playListItem.items {
                                    let time = item.snippet.publishedAt.replacingOccurrences(of: "T", with: " ").replacingOccurrences(of: "Z", with: " ")
                                    let info = InfoModel(title: item.snippet.title,
                                                          imgURL: item.snippet.thumbnails.standard.url,
                                                          ownerName: item.snippet.videoOwnerChannelTitle,
                                                          uploadTime: time,
                                                          videoID: item.snippet.resourceId.videoId)
                                    dataArray.append(info)
                                }
                                completion?(.success((playListItem.nextPageToken ?? "", dataArray, playListItem.nextPageToken == nil)))
                                
                            } catch {
                                completion?(.failure(error))
                            }
                                
                            case .failure(let error):
                                completion?(.failure(error))
                            }
                    }
    }

    func fetchDescription(videoID: String?, completion: ((Result<(String), Error>) -> Void)?) {
        let urlString = "https://youtube.googleapis.com/youtube/v3/videos?part=snippet&id=\(videoID ?? "")&key=\(apiKey)"
        
        AF.request(urlString).response { (response:AFDataResponse) in
                        switch response.result {
                            case .success(let JSON):
                            do {
                                let decoder = JSONDecoder()
                                let description = try decoder.decode(Description.self, from: JSON ?? Data())
                                for data in description.items {
                                    completion?(.success(data.snippet.description))
                                }
                            } catch {
                                completion?(.failure(error))
                            }

                            case .failure(let error):
                                completion?(.failure(error))
                            }
                    }
    }
    
    func fetchComments(_ count: Int, videoID: String?, token: String?, completion:((Result<(token:String, infoArray:[CommetInfo], withoutData: Bool), Error>) -> Void)?) {
        var urlString = "https://youtube.googleapis.com/youtube/v3/commentThreads?part=snippet,replies&videoId=\(videoID ?? "")&key=\(apiKey)&maxResults=\(count)"
        
        if token != nil {
            urlString = String.init(format: "%@&pageToken=%@", urlString, token!)
        }

        AF.request(urlString).response { (response:AFDataResponse) in
                        switch response.result {
                            case .success(let JSON):
                            do {
                                let decoder = JSONDecoder()
                                let comment = try decoder.decode(Comment.self, from: JSON ?? Data())
                                var dataArray: [CommetInfo] = []
                                for data in comment.items {
                                    
                                    let replie = data.snippet.topLevelComment.snippet
                                    let info = CommetInfo(authorName: replie.authorDisplayName,
                                                          authorImage: replie.authorProfileImageUrl,
                                                          replies: replie.textDisplay)
                                    dataArray.append(info)
                                    
                                }
                                completion?(.success((comment.nextPageToken ?? "", dataArray, comment.nextPageToken == nil)))
                                
                            } catch {
                                completion?(.failure(error))
                            }

                            case .failure(let error):
                                completion?(.failure(error))
                            }
                    }
    }
}
