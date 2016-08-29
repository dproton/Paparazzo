import UIKit

final class PhotoPreviewCell: PhotoCollectionViewCell {
    
    private let progressIndicator = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        imageView.contentMode = .ScaleAspectFit
        
        progressIndicator.hidesWhenStopped = true
        progressIndicator.color = UIColor(red: 162.0 / 255, green: 162.0 / 255, blue: 162.0 / 255, alpha: 1)
        
        addSubview(progressIndicator)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        progressIndicator.center = bounds.center
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        setProgressVisible(false)
    }
    
    override func adjustImageRequestOptions(inout options: ImageRequestOptions) {
        super.adjustImageRequestOptions(&options)
        
        options.onDownloadStart = { [weak self, superOptions = options] requestId in
            superOptions.onDownloadStart?(requestId)
            self?.imageRequestId = requestId
            self?.setProgressVisible(true)
        }
        
        options.onDownloadFinish = { [weak self, superOptions = options] requestId in
            superOptions.onDownloadFinish?(requestId)
            if requestId == self?.imageRequestId {
                self?.setProgressVisible(false)
            }
        }
    }
    
    // MARK: - Customizable
    
    func customizeWithItem(item: MediaPickerItem) {
        imageSource = item.image
    }
    
    // MARK: - Private
    
    private var imageRequestId: ImageRequestId?
    
    private func setProgressVisible(visible: Bool) {
        if visible {
            progressIndicator.startAnimating()
        } else {
            progressIndicator.stopAnimating()
        }
    }
}
