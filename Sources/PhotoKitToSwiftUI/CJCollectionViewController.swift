//
//  CJCollectionViewController.swift
//
//
//  Created by 최준영 on 2023/12/27.
//

import UIKit
import Photos
import PhotosUI

public class CJCollectionViewController: UICollectionViewController {
    
    var fetchedAssets: PHFetchResult<PHAsset>!
    
    var availableWidth: CGFloat = 0.0
    
    let horizontalSpacingBetweenItems: CGFloat = 1.0
    let verticalSpacingBetweenItems: CGFloat = 1.0
    
    let itemCountForRow: Int = 3
    
    var thumbNailSize: CGSize!
    
    let imageManager = PHImageManager()
    
    let flowLayout = UICollectionViewFlowLayout()
    
    public init() {
        
        super.init(collectionViewLayout: self.flowLayout)
        
    }
    
    public required init?(coder: NSCoder) { 
        super.init(coder: coder)
    }
    
}



// MARK: - UIViewController 라이프 사이클
public extension CJCollectionViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.register(CJCollectionViewCell.self, forCellWithReuseIdentifier: String(describing: CJCollectionViewCell.self))
        collectionView?.register(CJCameraImageCell.self, forCellWithReuseIdentifier: String(describing: CJCameraImageCell.self))
        
        fetchPhotos()
    
    }
    
    // 레이아웃은 뷰컨트롤러 부터 서브 뷰로 차례로 설정된다.
    // viewWillLayoutSubviews는 호출하는 뷰의 bounds가 변경되어서 서뷰 뷰의 레이아웃을 업데이트하기 직전에 호출됨
    // 즉 현재 뷰컨트롤러의 레이아웃이 변동된 이후의 시점이다.
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
            
        let withOfThisViewController = view.bounds.inset(by: view.safeAreaInsets).width
        
        if availableWidth != withOfThisViewController {
            
            availableWidth = withOfThisViewController - horizontalSpacingBetweenItems * CGFloat(itemCountForRow-1)
            
            let itemWidth = availableWidth / CGFloat(itemCountForRow)
            let itemHeight = itemWidth * 1.5
            
            flowLayout.minimumInteritemSpacing = horizontalSpacingBetweenItems
            flowLayout.minimumLineSpacing = verticalSpacingBetweenItems
            flowLayout.itemSize = CGSize(width: itemWidth, height: itemHeight)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        // 화면 비율
        let scale = UIScreen.main.scale
        
        let cellSize = flowLayout.itemSize
        
        let tnWidth = cellSize.width * scale
        let tnHeight = cellSize.height * scale
        
        self.thumbNailSize = CGSize(width: tnWidth, height: tnHeight)
        
    }
    
}


// MARK: - Photos에서 에셋가져오기
extension CJCollectionViewController {
    
    private func fetchPhotos() {
        
        if self.fetchedAssets == nil {
            
            // 사진을 불러오는 옵션
            let fetchOptions = PHFetchOptions()
            
            // 정렬기준설정, ascending = "오름차순"
            fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
            
            self.fetchedAssets = PHAsset.fetchAssets(with: fetchOptions)
            
            
        }
        
    }
    
}
    
// MARK: - CollectionView관련
public extension CJCollectionViewController {
        
    // CollectionView에 표시되는 아이템의 수 번환
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return 1 + self.fetchedAssets.count
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // 카메라 버튼일 경우
        if indexPath.item == 0 {
            
            let cellIdentifier = String(describing: CJCameraImageCell.self)
            
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as? CJCameraImageCell else {
                
                preconditionFailure("Camera Image Cell을 생성할 수 없습니다.")
                
            }
            
            cell.setUp()
            
            return cell
            
        }
        
        
        // 일반 이미지 셀인 경우
        
        let asset = fetchedAssets.object(at: indexPath.item-1)
        
        let cellIdentifier = String(describing: CJCollectionViewCell.self)
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as? CJCollectionViewCell else {
            
            preconditionFailure("Iamge Cell을 생성할 수 없습니다.")
            
        }
        
        cell.representedAssetId = asset.localIdentifier
        
        imageManager.requestImage(for: asset, targetSize: thumbNailSize, contentMode: .aspectFill, options: nil) { image, _ in
            
            if cell.representedAssetId == asset.localIdentifier {
                
                cell.thumbNailImage = image
                
            }
            
        }
        
        if asset.mediaSubtypes.contains(.photoLive) {
            cell.livePhotoIconImage = PHLivePhotoView.livePhotoBadgeImage(options: .overContent)
        }
        
        cell.setUp()
        
        return cell
        
    }
    
}
