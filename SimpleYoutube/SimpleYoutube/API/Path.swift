//
//  Path.swift
//  SimpleYoutube
//
//  Created by Junteng on 2023/3/31.
//

import UIKit

class Path: NSObject {
    func createImageFolder() {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = path[0]
        let docURL = URL(string: documentsDirectory)!
        let dataPath = docURL.appendingPathComponent("Image")
        if !FileManager.default.fileExists(atPath: dataPath.path) {
            do {
                try FileManager.default.createDirectory(atPath: dataPath.path, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func getFolderURL(_ fileName: String) -> String {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = path[0].appending("/Image/")
        let fileURL = documentsDirectory.appending(fileName)
        return fileURL
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
    
    func checkImageExist(_ fileName: String) -> Bool {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = path[0].appending("/Image/")
        let fileURL = documentsDirectory.appending(fileName)
        
        if FileManager.default.fileExists(atPath: fileURL) {
            return true
        } else {
          return false
        }
    }
}
