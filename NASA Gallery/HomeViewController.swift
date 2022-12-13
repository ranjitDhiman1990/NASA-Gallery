//
//  ViewController.swift
//  NASA Gallery
//
//  Created by Dhiman Ranjit on 08/12/22.
//

import UIKit
import AlamofireImage

class HomeViewController: BaseCollectionViewController {
    var photos: [MediaModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loadJSON()
        self.collectionView.collectionViewLayout = collectionViewLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    private func collectionViewLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        layout.sectionHeadersPinToVisibleBounds = true
        layout.scrollDirection = .vertical
        
        let itemHeight: CGFloat = 100
        let minCellWidth :CGFloat = 100.0
        let minItemSpacing: CGFloat = 2
        let containerWidth: CGFloat = self.view.bounds.width
        let maxCellCountPerRow: CGFloat =  floor((containerWidth - minItemSpacing) / (minCellWidth+minItemSpacing ))
        
        let itemWidth: CGFloat = floor( ((containerWidth - (2 * minItemSpacing) - (maxCellCountPerRow-1) * minItemSpacing) / maxCellCountPerRow))
        let inset = max(minItemSpacing, floor( (containerWidth - (maxCellCountPerRow*itemWidth) - (maxCellCountPerRow-1)*minItemSpacing) / 2))
        
        layout.itemSize = CGSize(width: itemWidth, height: itemHeight)
        layout.minimumInteritemSpacing = min(minItemSpacing,inset)
        layout.minimumLineSpacing = minItemSpacing
        layout.sectionInset = UIEdgeInsets(top: minItemSpacing, left: inset, bottom: minItemSpacing, right: inset)
        
        return layout
    }
}

extension HomeViewController {
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.photos.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "\(GalleryCollectionViewCell.self)", for: indexPath) as! GalleryCollectionViewCell
        if let imgUrl = self.photos[indexPath.row].url, let url = URL(string: imgUrl) {
            cell.imageView.af_setImage(withURL: url, placeholderImage: UIImage(named: "placeholder"))
        } else {
            cell.imageView.image = UIImage(named: "imageNotFound")
        }
        cell.backgroundColor = .white
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = DetailsViewController()
        vc.index = indexPath.row
        vc.photos = photos
        self.present(vc, animated: true, completion: nil)
    }
    
}


extension HomeViewController {
    func loadJSON() {
        switch [MediaModel?].from(localJSON: "NASA") {
        case .success(let value):
            self.photos = value.compactMap({ $0 })
            self.collectionView.reloadData()
        case .failure(let error):
            print(error)
        }
    }
}

class BaseViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

class BaseCollectionViewController: UICollectionViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension UIView {
    func roundCorners(radius: CGFloat = 4, corners: UIRectCorner = .allCorners) {
        self.clipsToBounds = true
        self.layer.cornerRadius = radius
        if #available(iOS 11.0, *) {
            var arr: CACornerMask = []
            
            let allCorners: [UIRectCorner] = [.topLeft, .topRight, .bottomLeft, .bottomRight, .allCorners]
            
            for corn in allCorners {
                if(corners.contains(corn)){
                    switch corn {
                    case .topLeft:
                        arr.insert(.layerMinXMinYCorner)
                    case .topRight:
                        arr.insert(.layerMaxXMinYCorner)
                    case .bottomLeft:
                        arr.insert(.layerMinXMaxYCorner)
                    case .bottomRight:
                        arr.insert(.layerMaxXMaxYCorner)
                    case .allCorners:
                        arr.insert(.layerMinXMinYCorner)
                        arr.insert(.layerMaxXMinYCorner)
                        arr.insert(.layerMinXMaxYCorner)
                        arr.insert(.layerMaxXMaxYCorner)
                    default: break
                    }
                }
            }
            self.layer.maskedCorners = arr
        } else {
            self.roundCornersBezierPath(corners: corners, radius: radius)
        }
    }
    
    private func roundCornersBezierPath(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
}
