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
    
    // Cell아이템 설정들
    var availableWidth: CGFloat = 0.0
    let horizontalSpacingBetweenItems: CGFloat = 1.0
    let verticalSpacingBetweenItems: CGFloat = 1.0
    let itemCountForRow: Int = 3
    var thumbNailSize: CGSize!
    
    // 레이아웃
    let flowLayout = UICollectionViewFlowLayout()
    
    // 캐싱및 이미지 불러오기
    var fetchedAssets: PHFetchResult<PHAsset>!
    let imageManager = PHCachingImageManager()
    var previousPreheatRect: CGRect = .zero
    
     
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
        
        // 재사용 Cell타입들을 등록
        collectionView?.register(CJCollectionViewCell.self, forCellWithReuseIdentifier: String(describing: CJCollectionViewCell.self))
        collectionView?.register(CJCameraImageCell.self, forCellWithReuseIdentifier: String(describing: CJCameraImageCell.self))
        
        // 캐싱 초기화
        resetCachedAssets()
        
        // 사진 불러오기
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // 뷰가 화면에 나타난 이후에 호출
        updateCachedAssets()
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


// MARK: - Caching
extension CJCollectionViewController {
    
    fileprivate func resetCachedAssets() {
        imageManager.stopCachingImagesForAllAssets()
        previousPreheatRect = .zero
    }
    
    fileprivate func updateCachedAssets() {
        // Update only if the view is visible.
        guard isViewLoaded && view.window != nil else { return }
        
        // 현재보이는 공간을 의미한다.
        let visibleRect = CGRect(origin: collectionView!.contentOffset, size: collectionView!.bounds.size)
        
        // 현재보이는 영역의 위아래 2배공간을 의미한다.
        let preheatRect = visibleRect.insetBy(dx: 0, dy: -0.5 * visibleRect.height)
        
        // 이전에 보였던 뷰와 현재 보이는 뷰의 Y값 변화량
        let delta = abs(preheatRect.midY - previousPreheatRect.midY)
        guard delta > view.bounds.height / 3 else { return }
        
        // 이전에 보였던 뷰와 현재뷰의 CGRect정보를 바탕으로 사라질 부분과 새롭게 생겨나는 부분을 CGRect로 계산한다.
        let (addedRects, removedRects) = differencesBetweenRects(previousPreheatRect, preheatRect)
        
        let addedAssets = addedRects
            .flatMap { rect in collectionView!.indexPathsForVisibleItems.filter { rect.contains(collectionView!.layoutAttributesForItem(at: $0)!.frame) } }
            .map { indexPath in fetchedAssets.object(at: indexPath.item) }

        let removedAssets = removedRects
            .flatMap { rect in collectionView!.indexPathsForVisibleItems.filter { rect.contains(collectionView!.layoutAttributesForItem(at: $0)!.frame) } }
            .map { indexPath in fetchedAssets.object(at: indexPath.item) }

        
        // PHCachingImageManager인스턴스가 캐싱하는 에셋을 업데이트 한다.
        imageManager.startCachingImages(for: addedAssets,
                                        targetSize: thumbNailSize, contentMode: .aspectFill, options: nil)
        imageManager.stopCachingImages(for: removedAssets,
                                       targetSize: thumbNailSize, contentMode: .aspectFill, options: nil)
        
        // 현재 가동중인 영역을 저장한다.
        previousPreheatRect = preheatRect
    }
    
    fileprivate func differencesBetweenRects(_ old: CGRect, _ new: CGRect) -> (added: [CGRect], removed: [CGRect]) {
        if old.intersects(new) {
            var added = [CGRect]()
            
            // 새로운 영역이 예전 영역보다 아래에 있는 경우
            if new.maxY > old.maxY {
                
                // origin은 Rectangle의 시작점 좌표로 좌측상단을 의미한다.
                added += [CGRect(x: new.origin.x, y: old.maxY,
                                 width: new.width, height: new.maxY - old.maxY)]
            }
            if old.minY > new.minY {
                added += [CGRect(x: new.origin.x, y: new.minY,
                                 width: new.width, height: old.minY - new.minY)]
            }
            var removed = [CGRect]()
            if new.maxY < old.maxY {
                removed += [CGRect(x: new.origin.x, y: new.maxY,
                                   width: new.width, height: old.maxY - new.maxY)]
            }
            if old.minY < new.minY {
                removed += [CGRect(x: new.origin.x, y: old.minY,
                                   width: new.width, height: new.minY - old.minY)]
            }
            return (added, removed)
        } else {
            return ([new], [old])
        }
    }
}


// MARK: - ScrollView
extension CJCollectionViewController {
    
    public override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        //스크롤을 할 때마다 캐싱 업데이트 여부를 확인한다.
        updateCachedAssets()
        
    }
    
}
