//
//  infoCell.swift
//  SimpleYoutube
//
//  Created by Junteng on 2023/3/29.
//

import UIKit

protocol InfoViewTouchDelegate {
    func nextPage(_ row: Int)
}

class infoCell: UITableViewCell {
    @IBOutlet var coverImageView: UIImageView!
    @IBOutlet var headImageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var ownerLabel: UILabel!
    @IBOutlet var uploadLabel: UILabel!
    var infoViewTouchDelegate: InfoViewTouchDelegate?
    var row: Int?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        initSkeletonEnable()
        let gesture = UITapGestureRecognizer(target: self, action:#selector(checkAction(sender:)))
        coverImageView.isUserInteractionEnabled = true
        coverImageView.addGestureRecognizer(gesture)
        
        headImageView.layer.cornerRadius = headImageView.frame.height / 2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func initSkeletonEnable() {
        isSkeletonable = true
        coverImageView.isSkeletonable = true
        headImageView.isSkeletonable = true
        titleLabel.isSkeletonable = true
        ownerLabel.isSkeletonable = true
        uploadLabel.isSkeletonable = true
    }
    
    @objc func checkAction(sender : UITapGestureRecognizer) {
        infoViewTouchDelegate?.nextPage(row!)
    }
    
}
