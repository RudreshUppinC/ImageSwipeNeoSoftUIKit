//
//  CarouselTableViewCell.swift
//  ImageSwipeNeoSoftUIKit
//
//  Created by RudreshUppin on 26/04/25.
//

import UIKit
import Combine

class CarouselTableViewCell: UITableViewCell {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!

    // MARK: - Properties
    private var items: [CarouselItems] = []
    private var viewModel: ContentViewModel?
    private var cancellables = Set<AnyCancellable>()
    var onPageChanged: ((Int) -> Void)? 

    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setupCollectionView()
        setupPageControl()
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
        items = []
        collectionView.reloadData()
        viewModel = nil
        onPageChanged = nil
        
        pageControl.currentPage = 0
        pageControl.numberOfPages = 0
    }

    deinit {
        cancellables.forEach { $0.cancel() }
    }

    // MARK: - Setup
    private func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        let nib = UINib(nibName: NeoSoftStrings.ImageCollectionViewCell.rawValue, bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: NeoSoftStrings.ImageCollectionViewCell.rawValue)

        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
            layout.minimumLineSpacing = 0
            layout.minimumInteritemSpacing = 0
        }
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear
    }

    private func setupPageControl() {
        pageControl.hidesForSinglePage = true
        pageControl.pageIndicatorTintColor = NeoSoftAppColors.grayColorWithOpacity
        pageControl.currentPageIndicatorTintColor = NeoSoftAppColors.blueColor
        pageControl.isUserInteractionEnabled = false
    }

    // MARK: - Configuration
    func configure(with viewModel: ContentViewModel) {
        self.viewModel = viewModel
        bindViewModel()

        self.items = viewModel.carouselItems
        self.pageControl.numberOfPages = items.count
        self.pageControl.currentPage = viewModel.selectedCarouselIndex
        self.collectionView.reloadData()

        DispatchQueue.main.async {
            if !self.items.isEmpty && self.items.count > viewModel.selectedCarouselIndex {
                let initialIndexPath = IndexPath(item: viewModel.selectedCarouselIndex, section: 0)
                self.collectionView.scrollToItem(at: initialIndexPath, at: .centeredHorizontally, animated: false)
            }
        }
    }

    // MARK: - Combine Bindings (within the Cell)
    private func bindViewModel() {
        guard let viewModel = viewModel else { return }

        viewModel.$carouselItems
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newItems in
                guard let self = self else { return }
                self.items = newItems
                self.pageControl.numberOfPages = newItems.count
                self.collectionView.reloadData()
                if viewModel.selectedCarouselIndex >= newItems.count {
                     viewModel.selectedCarouselIndex = max(0, newItems.count - 1)
                }

                self.pageControl.currentPage = viewModel.selectedCarouselIndex
            }
            .store(in: &cancellables)

        viewModel.$selectedCarouselIndex
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newIndex in
                 guard let self = self,
                       self.pageControl.currentPage != newIndex,
                       newIndex < self.items.count,
                       newIndex >= 0 else { return }

                 self.pageControl.currentPage = newIndex
                 let indexPath = IndexPath(item: newIndex, section: 0)

                  if !self.collectionView.isTracking && !self.collectionView.isDecelerating {
                       self.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
                  }
            }
            .store(in: &cancellables)
    }
}

// MARK: - UICollectionView DataSource, Delegate, FlowLayout
extension CarouselTableViewCell: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count

    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NeoSoftStrings.ImageCollectionViewCell.rawValue, for: indexPath) as? ImageCollectionViewCell else {
            fatalError("Unable to dequeue ImageCollectionViewCell")
        }
        let item = items[indexPath.item]
        cell.configure(with: item.download_url)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.bounds.size
    }

    // MARK: - UIScrollViewDelegate (for PageControl update)
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        updatePageControlFromScroll(scrollView)
    }


    private func updatePageControlFromScroll(_ scrollView: UIScrollView) {
         let pageIndex = Int(round(scrollView.contentOffset.x / scrollView.frame.width))
         if pageIndex >= 0 && pageIndex < items.count && pageControl.currentPage != pageIndex {
             pageControl.currentPage = pageIndex
             onPageChanged?(pageIndex)
         }
    }
}
