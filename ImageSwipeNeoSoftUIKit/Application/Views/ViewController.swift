//
//  ViewController.swift
//  ImageSwipeNeoSoftUIKit
//
//  Created by RudreshUppin on 26/04/25.
//

import UIKit
import Combine


class ViewController: UIViewController,MyCustomBottomSheetViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var floatingButton: UIButton!
    
    // MARK: - Properties
    private let viewModel = ContentViewModel()
    private var cancellables = Set<AnyCancellable>()
    
    private let searchController = UISearchController(searchResultsController: nil)
    
    private var bottomSheetView: MyCustomBottomSheetView?
    private let animationDuration: TimeInterval = 0.3
    
    private var isBottomSheetVisible = false
    
    lazy var imageSelectView: MyCustomBottomSheetView = {
        let sheet = MyCustomBottomSheetView()
        sheet.fpdelegate = self
        return sheet
    }()
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupSearchController()
        setupTableView()
        setupBindings()
    }
    
    // MARK: - Privatee functions
    
    private func setupUI() {
        self.title = "Content Feed"
        self.navigationItem.title = self.title
        self.view.backgroundColor = .systemGroupedBackground
        
        floatingButton.layer.cornerRadius = floatingButton.frame.width / 2
        floatingButton.clipsToBounds = true
        floatingButton.backgroundColor = NeoSoftAppColors.moreBtnBlueColor
    }
    
    private func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Authors"
        searchController.searchBar.delegate = self
        
        searchController.searchBar.searchBarStyle = .minimal
        searchController.searchBar.backgroundImage = UIImage()
        
        searchController.searchBar.backgroundColor = .systemGroupedBackground
        
        if let textField = searchController.searchBar.value(forKey: "searchField") as? UITextField {
            textField.backgroundColor = .secondarySystemBackground
            textField.layer.cornerRadius = 10
            textField.clipsToBounds = true
        }
        
        definesPresentationContext = true
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        self.view.backgroundColor = .systemGroupedBackground
        
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        
        tableView.contentInset = .zero
        tableView.contentInsetAdjustmentBehavior = .automatic
        tableView.scrollIndicatorInsets = .zero
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        
        // Register Cells
        let carouselNib = UINib(nibName: NeoSoftStrings.CarouselTableViewCell.rawValue, bundle: nil)
        tableView.register(carouselNib, forCellReuseIdentifier: NeoSoftStrings.CarouselTableViewCell.rawValue)
        let listItemNib = UINib(nibName: NeoSoftStrings.ListItemTableViewCell.rawValue, bundle: nil)
        tableView.register(listItemNib, forCellReuseIdentifier: NeoSoftStrings.ListItemTableViewCell.rawValue)
    }
    
    private func setupBindings() {
            viewModel.$filteredItems
                .receive(on: RunLoop.main)
                .sink { [weak self] _ in
                    guard let self = self else { return }
                    print("Filtered items changed, reloading section 1")
                    self.tableView.reloadSections(IndexSet(integer: 1), with: .automatic)
                }
                .store(in: &cancellables) 

            viewModel.$carouselItems
                .receive(on: RunLoop.main)
                .sink { [weak self] _ in
                    guard let self = self else { return }
                    print("Carousel items changed, reloading section 0")
                    self.tableView.reloadSections(IndexSet(integer: 0), with: .none)
                }
                .store(in: &cancellables)
        }
    
    deinit {
        cancellables.forEach {
            $0.cancel()
        }
        print("deinited")
    }
    
    @IBAction func foatingBtnAction(_ sender: UIButton) {
        animateBottomSheetView()
    }
    
    
    private func animateBottomSheetView() {
        let showSheet = !isBottomSheetVisible
        let animationDuration: TimeInterval = 0.3
        let sampleItems =  ["apple", "banana", "orange", "blueberry"]
        let sampleTitle = "List 1"
        imageSelectView.configure(items: sampleItems, listTitle: sampleTitle)

        
        if showSheet {
            imageSelectView.frame = CGRect(
                x: 0,
                y: viewHeight,
                width: viewWidth,
                height: viewHeight
            )
            imageSelectView.isHidden = false
            if imageSelectView.superview == nil {
                self.view.addSubview(imageSelectView)
            }
            
            self.view.bringSubviewToFront(imageSelectView)
            
            let finalYPosition = viewHeight - viewHeight
            
            // Animate UP
            UIView.animate(withDuration: animationDuration,
                           delay: 0,
                           options: [.curveEaseOut],
                           animations: {
                self.imageSelectView.frame.origin.y = finalYPosition
            }, completion: { [weak self] _ in
                guard let self = self else { return }
                if !self.isBottomSheetVisible {
                    self.isBottomSheetVisible = true
                    print("Sheet Shown")
                }
            })
            
        } else {
            let finalYPosition = viewHeight
            
            UIView.animate(withDuration: animationDuration,
                           delay: 0,
                           options: [.curveEaseIn],
                           animations: {
                self.imageSelectView.frame.origin.y = finalYPosition
            }, completion: { [weak self] _ in
                guard let self = self else { return }
                if self.isBottomSheetVisible {
                    self.isBottomSheetVisible = false
                    self.imageSelectView.removeFromSuperview()
                    print("Sheet Hidden")
                }
            })
        }
    }
    
    func removeBottomSheet() {
        if isBottomSheetVisible {
            animateBottomSheetView()
        }
    }
}

// MARK: - UITableView DataSource
extension ViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        // Section 0: Carousel
        // Section 1: List Items
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return viewModel.carouselItems.isEmpty ? 0 : 1
        case 1:
            return viewModel.filteredItems.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: NeoSoftStrings.CarouselTableViewCell.rawValue , for: indexPath) as? CarouselTableViewCell else {
                fatalError("Could not dequeue CarouselTableViewCell")
            }
            
            cell.configure(with: viewModel) // Pass items
            cell.onPageChanged = { [weak self] index in
                self?.viewModel.selectedCarouselIndex = index
            }
            
            return cell
            
        case 1: // List Item Cell (Now in Section 1)
            guard let cell = tableView.dequeueReusableCell(withIdentifier: NeoSoftStrings.ListItemTableViewCell.rawValue , for: indexPath) as? ListItemTableViewCell else {
                fatalError("Could not dequeue ListItemTableViewCell")
            }
            let item = viewModel.filteredItems[indexPath.row]
            cell.configure(with: item)
            
            return cell
            
        default:
            fatalError("Unexpected Section: \(indexPath.section)")
        }
    }
}

// MARK: - UITableView Delegate
extension ViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 1 {
            return searchController.searchBar
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 1 {
            return searchController.searchBar.intrinsicContentSize.height
        }
        return CGFloat.leastNonzeroMagnitude
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0: return 220
        case 1: return 85
        default: return UITableView.automaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNonzeroMagnitude
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
}

// MARK: - UISearchResultsUpdating
extension ViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        viewModel.searchText = searchController.searchBar.text ?? ""
        print("Search text updated to: \(viewModel.searchText)") // Debug print

    }
}

// MARK: - UISearchBarDelegate
extension ViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchController.dismiss(animated: true, completion: nil)
    }
    
}



