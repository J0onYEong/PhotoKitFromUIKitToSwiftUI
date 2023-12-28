//
//  CJCollectionViewCell.swift
//  
//
//  Created by 최준영 on 2023/12/27.
//

import UIKit

class CJCollectionViewCell: UICollectionViewCell {
    
    static let reusableId: String = "CJCollectionViewCell"
    
    var thumbNailImageView = UIImageView()
    var livePhotoIconImageView = UIImageView()
    
    var representedAssetId: String!
    
    var thumbNailImage: UIImage! {
        didSet {
            thumbNailImageView.image = thumbNailImage
        }
    }
    
    
    var livePhotoIconImage: UIImage! {
        didSet {
            livePhotoIconImageView.image = livePhotoIconImage
        }
    }
    
    func setUp() {
        
        thumbNailImageView.contentMode = .scaleAspectFill
        thumbNailImageView.clipsToBounds = true
        
        livePhotoIconImageView.contentMode = .scaleAspectFit
        
        self.addSubview(thumbNailImageView)
        self.addSubview(livePhotoIconImageView)
        
        thumbNailImageView.translatesAutoresizingMaskIntoConstraints = false
        livePhotoIconImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            thumbNailImageView.topAnchor.constraint(equalTo: self.topAnchor),
            thumbNailImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            thumbNailImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            thumbNailImageView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            
            livePhotoIconImageView.topAnchor.constraint(equalTo: self.topAnchor),
            livePhotoIconImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            livePhotoIconImageView.widthAnchor.constraint(equalToConstant: 28.0),
            livePhotoIconImageView.heightAnchor.constraint(equalToConstant: 28.0),
            
        ])
        
    }
    
}

// MARK: - nib파일로 부터 타입이로드된 이후
extension CJCollectionViewCell {
    
    // Nib파일로 부터 로드된 이후 호출
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
}

extension CJCollectionViewCell {
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        thumbNailImageView.image = nil
        livePhotoIconImageView.image = nil
        
    }
    
}
