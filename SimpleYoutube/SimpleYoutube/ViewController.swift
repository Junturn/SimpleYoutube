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
    
    let infoVM = InfoViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupView()
        
        infoVM.updateUI = {
            self.updateUI()
        }
        
        infoVM.showError = { error in
            let alertController = UIAlertController(title: "Something Error", message: "Please check your network is available or \(error)", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default) { (action: UIAlertAction!) -> Void in
                
            }
            alertController.addAction(action)
            
            self.present(alertController, animated:true, completion: nil)
        }
        
        infoVM.showIndicator = {
            self.IndicatorView.isHidden = false
            self.IndicatorView.startAnimating()
        }
        
        infoVM.reloadTableView = {
            DispatchQueue.main.async {
                self.mainTableView.reloadData()
            }
        }
    }
    
    func setupView() {
        let searchController = UISearchController()
        searchController.searchResultsUpdater = self
        searchController.delegate = self
        navigationItem.searchController = searchController
        
        mainTableView.register(UINib(nibName: "infoCell", bundle: nil), forCellReuseIdentifier: "infoCell")
        mainTableView.dataSource = self
        mainTableView.delegate = self
        mainTableView.isSkeletonable = true
        mainTableView.showAnimatedSkeleton()
    }
    
    func updateUI() {
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

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
      return 330
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let row = indexPath.row
        infoVM.checkDataCount(with: row)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      
    }
}

extension ViewController: SkeletonTableViewDataSource {
    func numSections(in collectionSkeletonView: UITableView) -> Int {
        return 1
    }
    
    func collectionSkeletonView(_ skeletonView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return infoVM.contentInfoArray.count
    }
    
    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return "infoCell"
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return infoVM.contentInfoArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "infoCell") as! infoCell
        let row = indexPath.row
        cell.infoViewTouchDelegate = self
        cell.setup(infoVM.contentInfoArray[row] ,row: row)
        return cell
    }
    
}

extension ViewController: UISearchControllerDelegate {
    
    func didPresentSearchController(_ searchController: UISearchController) {
        infoVM.didPresetSearchBar()
    }
    
    func didDismissSearchController(_ searchController: UISearchController) {
        infoVM.finishedSearchBar()   
    }

}

extension ViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if infoVM.isSearch, let searchWord = searchController.searchBar.text {
            infoVM.showSearchResult(searchKey: searchWord)
        }
    }
}

extension ViewController: InfoViewTouchDelegate {
    func nextPage(_ row: Int) {
        let videoPlayerVC = VideoPlayerViewController(nibName: "VideoPlayerViewController", bundle: nil)
        videoPlayerVC.videoInfo = infoVM.contentInfoArray[row]
        self.navigationController?.pushViewController(videoPlayerVC, animated: true)
    }
}
