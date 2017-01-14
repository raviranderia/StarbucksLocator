//
//  ViewController.swift
//  StarbucksLocator
//
//  Created by RAVI RANDERIA on 1/12/17.
//  Copyright © 2017 RAVI RANDERIA. All rights reserved.
//

import UIKit
import CoreLocation

final class MainViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, MainViewModelDelegate, UIGestureRecognizerDelegate {

    
    private var previousPoint = CGPoint.zero
    private var xOffset = CGFloat(0)
    private var transitionLayout: UICollectionViewTransitionLayout?
    private var transitionInProgress = false
    private var feedScrollLayout = false
    private var blurEffectView: UIVisualEffectView?
    private var animationDuration = 0.5
    private var frameOffset = 20

    @IBOutlet weak var starbucksCollectionView: UICollectionView!

    private var mainViewModel = MainViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mainViewModel.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let selector = #selector(panViewGesture)
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: selector)
        starbucksCollectionView.addGestureRecognizer(panGestureRecognizer)
        panGestureRecognizer.delegate = self
        transitionToStackFeed()
    }
    
    // MARK: CollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return mainViewModel.starbucksStoreInformation.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: mainViewModel.collectionViewCellIdentifier, for: indexPath) as! StarbucksInformationCollectionViewCell
        let starbucksCollectionCellViewModel = StarbucksInformationCellViewModel(starbucksStoreInformation: mainViewModel.starbucksStoreInformation[indexPath.row])
        cell.configureCell(starbucksInformationCellViewModel: starbucksCollectionCellViewModel)
        return cell
    }
    
    // MARK: CollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: mainViewModel.mapSegueIdentifer, sender: mainViewModel.starbucksStoreInformation[indexPath.row])
    }
    
    // MARK: MainViewModelDelegate
    func reloadCollectionViewData() {
        self.starbucksCollectionView.reloadData()
    }

    func performSegueWithIdentifier(identifier: String, error: FeedError?) {
        performSegue(withIdentifier: identifier, sender: error)
    }
    
    func dismissViewController() {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? MapViewController,
            let selectedStore = sender as? StarbucksStoreInformation{
            destinationVC.currentStarbucksStoreInfo = selectedStore
        } else if let destinationVC = segue.destination as? ErrorViewController,
            let feedError = sender as? FeedError {
            destinationVC.feedError = feedError
            destinationVC.delegate = mainViewModel
        }
    }
    
    @IBAction func refreshButtonPressed(_ sender: UIBarButtonItem) {
        mainViewModel.fetchFreshData()
    }
    
    func panViewGesture(sender: UIPanGestureRecognizer) {
        if mainViewModel.starbucksStoreInformation.count == 0 || transitionInProgress || feedScrollLayout {
            return
        }
        let translation = sender.translation(in: view)
        if sender.state == .began {
            if !transitionInProgress {
                moveFeedToFront()
                starbucksCollectionView.collectionViewLayout.invalidateLayout()
                transitionLayout = starbucksCollectionView.startInteractiveTransition(to: FeedLayout(newYOffset: 100, newAdditionalYOffset: 324)) { [weak self] (completed, finished) -> Void in
                    self?.transitionLayout = nil
                    self?.transitionInProgress = false
                    self?.starbucksCollectionView.reloadData()
                }
            }
        } else if sender.state == .changed && (transitionLayout != nil) {
            transitionLayout?.transitionProgress = -translation.y / 424
            guard let transitionLayout = transitionLayout else {return}
            if Double((transitionLayout
                .transitionProgress)) >= 1.0 {
                transitionInProgress = true
                starbucksCollectionView.finishInteractiveTransition()
                feedScrollLayout = true
            }
        } else if sender.state == .ended || sender.state == .cancelled {
            guard let transitionLayout = transitionLayout else {return}
            transitionInProgress = true
            if Double((transitionLayout
                .transitionProgress)) > 0.5 {
                starbucksCollectionView.finishInteractiveTransition()
                feedScrollLayout = true
            } else {
                starbucksCollectionView.cancelInteractiveTransition()
                moveFeedToBack()
            }
        }
    }
    
    private func transitionToStackFeed() {
        if transitionInProgress {
            return
        }
        transitionInProgress = true
        UIView.animate(withDuration: animationDuration) { () -> Void in
            self.starbucksCollectionView.collectionViewLayout.invalidateLayout()
            self.starbucksCollectionView.setCollectionViewLayout(FeedLayout(newYOffset: 100, newAdditionalYOffset: 20), animated: true, completion: { (true) -> Void in
                self.transitionInProgress = false
                self.feedScrollLayout = false
                self.moveFeedToBack()
                self.starbucksCollectionView.reloadData()
            })
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if transitionInProgress {
            return false
        }
        return feedScrollLayout
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if feedScrollLayout {
            previousPoint = scrollView.contentOffset
            
            if (scrollView.contentOffset.y <= -100) {
                transitionToStackFeed()
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.size.width, height:  view.frame.size.width);
    }
    
    private func moveFeedToFront() {
        view.bringSubview(toFront: starbucksCollectionView)
    }
    
    private func moveFeedToBack() {
        view.sendSubview(toBack: starbucksCollectionView)
    }
}

