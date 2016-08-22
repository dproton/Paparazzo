import UIKit

extension UIView {
    
    func setAnchorPointPreservingFrame(anchorPoint: CGPoint) {
        
        var newPoint = CGPoint(
            x: bounds.size.width * anchorPoint.x,
            y: bounds.size.height * anchorPoint.y
        )
        
        var oldPoint = CGPoint(
            x: bounds.size.width * layer.anchorPoint.x,
            y: bounds.size.height * layer.anchorPoint.y
        )
        
        newPoint = CGPointApplyAffineTransform(newPoint, transform)
        oldPoint = CGPointApplyAffineTransform(oldPoint, transform)
        
        layer.position = CGPoint(
            x: layer.position.x - oldPoint.x + newPoint.x,
            y: layer.position.y - oldPoint.y + newPoint.y
        )
        
        layer.anchorPoint = anchorPoint
    }
    
    func snapshot() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0)
        drawViewHierarchyInRect(bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}

extension UICollectionView {
    
    func performBatchUpdates(updates: () -> Void) {
        performBatchUpdates(updates, completion: nil)
    }
    
    func performNonAnimatedBatchUpdates(updates: (() -> Void), completion: (Bool -> ())? = nil) {
        UIView.animateWithDuration(0) { 
            self.performBatchUpdates(updates, completion: completion)
        }
    }
    
    func performBatchUpdates(animated animated: Bool, _ updates: (() -> Void), completion: (Bool -> ())? = nil) {
        let updateCollectionView = animated ? performBatchUpdates : performNonAnimatedBatchUpdates
        updateCollectionView(updates, completion: completion)
    }
    
    func insertItems(animated animated: Bool, _ updates: () -> [NSIndexPath]?) {
        performBatchUpdates(animated: animated, { [weak self] in
            if let indexPaths = updates() {
                self?.insertItemsAtIndexPaths(indexPaths)
            }
        })
    }
    
    func deleteItems(animated animated: Bool, _ updates: () -> [NSIndexPath]?) {
        performBatchUpdates(animated: animated, { [weak self] in
            if let indexPaths = updates() {
                self?.deleteItemsAtIndexPaths(indexPaths)
            }
        })
    }
}

extension UIImage {
    
    func resized(toFit size: CGSize) -> UIImage? {
        
        let image = UIKit.CIImage(image: self)
        let scale = min(size.width / self.size.width, size.height / self.size.height)
        
        guard let filter = CIFilter(name: "CILanczosScaleTransform") else { return nil }
        filter.setValue(image, forKey: kCIInputImageKey)
        filter.setValue(scale, forKey: kCIInputScaleKey)
        filter.setValue(1, forKey: kCIInputAspectRatioKey)
        
        guard let outputImage = filter.valueForKey(kCIOutputImageKey) as? UIKit.CIImage else { return nil }
        let cgImage = sharedGPUContext.createCGImage(outputImage, fromRect: outputImage.extent)
        
        return UIImage(CGImage: cgImage)
    }
}

// Операция создания CIContext дорогостоящая, поэтому рекомендуется хранить его
private let sharedGPUContext = CIContext(options: [kCIContextUseSoftwareRenderer: false])