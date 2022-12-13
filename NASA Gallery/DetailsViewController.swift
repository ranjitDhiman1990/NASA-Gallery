//
//  DetailsViewController.swift
//  NASA Gallery
//
//  Created by Dhiman Ranjit on 10/12/22.
//

import UIKit
import AlamofireImage

class DetailsViewController: BaseViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    var gestureRecognizer: UITapGestureRecognizer?
    
    @IBOutlet weak var buttonShowDetails: UIButton!
    
    @IBOutlet weak var buttonOKInfo: UIButton!
    @IBOutlet weak var viewContainerInfo: UIView!
    @IBOutlet weak var viewInfo: UIStackView!
    
    
    var index: Int = 0
    var photos: [MediaModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate, !appDelegate.isConnectedToInternet {
            appDelegate.showInternetConnectionStatus(message: "No Internet Connection", success: false, autoHide: false)
        }
        
        self.scrollView.delegate = self
        // Do any additional setup after loading the view.
        self.imageView.isUserInteractionEnabled = true
        gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap))
        gestureRecognizer?.numberOfTapsRequired = 2
        self.imageView.addGestureRecognizer(gestureRecognizer!)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture))
        swipeLeft.direction = .left
        self.imageView.addGestureRecognizer(swipeLeft)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture))
        swipeRight.direction = .right
        self.imageView.addGestureRecognizer(swipeRight)
        
        self.buttonShowDetails.roundCorners(radius: 8, corners: .allCorners )
        self.buttonShowDetails.addTarget(self, action: #selector(presentModalController), for: .touchUpInside)
        
        self.buttonOKInfo.roundCorners(radius: 8, corners: .allCorners )
        self.buttonOKInfo.addTarget(self, action: #selector(hideInfoView), for: .touchUpInside)
        let defaults = UserDefaults.standard
        let isInfoShown = defaults.bool(forKey: "isInfoShown")
        if !isInfoShown {
            self.showInfoView()
            defaults.set(true, forKey: "isInfoShown")
            defaults.synchronize()
        } else {
            self.hideInfoView()
        }
        
        self.showImage()
    }
    
    @objc func hideInfoView() {
        self.viewContainerInfo.isHidden = true
        self.viewInfo.isHidden = true
        self.buttonOKInfo.isHidden = true
    }
    
    func showInfoView() {
        self.viewContainerInfo.isHidden = false
        self.viewInfo.isHidden = false
        self.buttonOKInfo.isHidden = false
    }
    
    @objc func presentModalController() {
        let vc = CustomModalViewController()
        vc.modalPresentationStyle = .overCurrentContext
        vc.photo = self.photos[self.index]
        self.present(vc, animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            
            switch swipeGesture.direction {
            case .right:
                print("Swiped right")
                self.getPreviousImage()
            case .down:
                print("Swiped down")
            case .left:
                print("Swiped left")
                self.getNextImage()
            case .up:
                print("Swiped up")
            default:
                break
            }
        }
    }
    
    @objc func handleDoubleTap() {
        if scrollView.zoomScale == 1 {
            self.scrollView.zoom(to: zoomRectForScale(self.scrollView.maximumZoomScale, center: self.gestureRecognizer?.location(in: self.gestureRecognizer?.view) ?? .zero), animated: true)
        } else {
            self.scrollView.setZoomScale(1, animated: true)
        }
    }
    
    // Calculates the zoom rectangle for the scale
    func zoomRectForScale(_ scale: CGFloat, center: CGPoint) -> CGRect {
        var zoomRect = CGRect.zero
        zoomRect.size.height = imageView.frame.size.height / scale
        zoomRect.size.width = imageView.frame.size.width / scale
        let newCenter = self.scrollView.convert(center, from: imageView)
        zoomRect.origin.x = newCenter.x - (zoomRect.size.width / 2.0)
        zoomRect.origin.y = newCenter.y - (zoomRect.size.height / 2.0)
        return zoomRect
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
    
    func showImage() {
        //cancel previous request
        self.imageView.af_cancelImageRequest()
        let source = self.photos[self.index]
        self.setImageWithBlurImage(with: URL(string: source.hdurl ?? ""), blurImageURL: URL(string: source.url ?? ""))
    }
    
    func setImageWithBlurImage(with originalImageURL: URL?, blurImageURL: URL?) {
        guard let url = originalImageURL else { return }
        guard let blurImageURL = blurImageURL else { return }
        
        self.imageView.af_setImage(withURL: blurImageURL, imageTransition: .noTransition) { [weak self] (response) in
            DispatchQueue.main.async {
                switch response.result {
                case .success(let image):
                    self?.imageView.image = image
                case .failure(_ ):
                    break
                }
                
                self?.imageView.af_setImage(withURL: url, imageTransition: .crossDissolve(0.1)) { [weak self] (response) in
                    DispatchQueue.main.async {
                        switch response.result {
                        case .success(let image):
                            self?.imageView.image = image
                        case .failure(_ ):
                            break
                        }
                    }
                }
            }
        }
        
    }
    
    func getNextImage() {
        let count = self.photos.count
        if self.index < count - 1 {
            self.index = self.index + 1
            self.showImage()
        }
    }
    
    func getPreviousImage() {
        if index != 0 {
            self.index = self.index - 1
            self.showImage()
        }
    }
}
