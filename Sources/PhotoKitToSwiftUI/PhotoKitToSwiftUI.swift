// The Swift Programming Language
import SwiftUI

public struct CJCollectionVCRepresenter: UIViewControllerRepresentable {
    
    public init() { }
    
    public typealias UIViewControllerType = CJCollectionViewController
    
    public func makeUIViewController(context: Context) -> UIViewControllerType {
        
        let collectionViewController = CJCollectionViewController()
        
        return collectionViewController
        
    }
    
    public func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
           
    }
    
}
