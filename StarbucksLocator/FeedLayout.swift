//
//  FeedLayout.swift
//  Camp
//
//  Created by Asaph Yuan on 10/18/16.
//  Copyright © 2016 Intrepid Pursuits. All rights reserved.
//

import UIKit

final class FeedLayout: UICollectionViewFlowLayout {
    var collectionViewLayoutAttributes = [UICollectionViewLayoutAttributes]()
    private var yOffset = 0
    private var additionalYOffset = 0
    private var zIndexOffset = 1

    init(newYOffset: Int, newAdditionalYOffset: Int) {
        super.init()
        yOffset = newYOffset
        additionalYOffset = newAdditionalYOffset
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func prepare() {
        guard let collection = collectionView else { return }
        if collectionViewLayoutAttributes.isEmpty || collectionViewLayoutAttributes.count < collection.numberOfItems(inSection: 0) {
            collectionViewLayoutAttributes = []
            for item in 0 ..< collection.numberOfItems(inSection: 0) {
                let indexPath = IndexPath(item: item, section: 0)
                let width = Int(collection.bounds.size.width)
                let height = 324
                let frame = CGRect(x: 0, y: yOffset, width: width, height: height)
                let insetFrame = frame.insetBy(dx: 0 , dy: 0)
                let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                attributes.frame = insetFrame
                attributes.zIndex = zIndexOffset
                collectionViewLayoutAttributes.append(attributes)
                zIndexOffset -= 1
                yOffset += additionalYOffset
            }
        }
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var layoutAttributes = [UICollectionViewLayoutAttributes]()
        for attributes in collectionViewLayoutAttributes {
            if attributes.frame.intersects(rect) {
                layoutAttributes.append(attributes)
            }
        }
        return layoutAttributes
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return collectionViewLayoutAttributes[indexPath.row]
    }

    override var collectionViewContentSize: CGSize {
        guard let collection = collectionView else { return CGSize.zero }
        let width = Int(collection.bounds.size.width)
        let height =  yOffset
        return CGSize(width: width, height: height)
    }
}
