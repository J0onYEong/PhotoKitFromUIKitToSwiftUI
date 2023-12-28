// The Swift Programming Language
import SwiftUI

public struct ImageInformation: Identifiable, Equatable {
    
    public var id: UUID { UUID() }
    
    public var image: UIImage
    
    public var orientation: CGImagePropertyOrientation
    
}

public struct CJSelectImageFromPhotoView: UIViewControllerRepresentable {
    
    @Binding var imageInformation: ImageInformation?
    
    public init(imageInformation: Binding<ImageInformation?>) {
        _imageInformation = imageInformation
    }
    
    public typealias UIViewControllerType = CJCollectionViewController
    
    public func makeUIViewController(context: Context) -> UIViewControllerType {
        
        let collectionViewController = CJCollectionViewController(imageInformation: $imageInformation)
        
        return collectionViewController
        
    }
    
    public func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
           
    }
    
}
