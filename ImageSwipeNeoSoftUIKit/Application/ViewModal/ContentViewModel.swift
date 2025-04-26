//
//  ContentViewModel.swift
//  ImageSwipeNeoSoftSwitUI
//
//  Created by RudreshUppin on 25/04/25.
//


import Foundation
import Combine
import SwiftUI

class ContentViewModel: ObservableObject {
    
    //MARK: -  variables
    
    @Published var carouselItems: [CarouselItems] = []
    @Published var selectedCarouselIndex: Int = 0
    @Published var searchText: String = ""
    @Published var filteredItems: [CarouselItems] = []
    
    private var cancellables = Set<AnyCancellable>()
    private let networkService: NetworkFetching
    
    //MARK: -  init with dependency
    
    init(networkService: NetworkFetching = NetworkService()) {
        self.networkService = networkService
        fetchData()
        setupFiltering()
    }
    
    //MARK: -  Public Functions
    
    func fetchData() {
        
        networkService.fetchImageDataPublisher()
            .sink(receiveCompletion: { [weak self] completion in
                guard let self = self else { return }
                
                switch completion {
                case .finished:
                    print("Successfully fetched image data.")
                    if !self.carouselItems.isEmpty {
                        print("images Loaded")
                    } else {
                        print("No images")
                        self.carouselItems = [] 
                        self.filteredItems = []
                    }
                    
                case .failure(let error):
                    print("Error fetching image data: \(error.localizedDescription)")
                    self.carouselItems = []
                    self.filteredItems = []
                }
            }, receiveValue: { [weak self] imageInfos in
                guard let self = self else { return }
                self.carouselItems = imageInfos
                
            })
            .store(in: &cancellables)
    }
    
    
    
    func cancelFetch() {
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
    }

    private func setupFiltering() {
        print("Setting up filtering pipeline...")
        Publishers.CombineLatest($searchText, $carouselItems)
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .map { searchText, items -> [CarouselItems] in
                if searchText.isEmpty {
                    print("Search empty, showing all \(items.count) items")
                    return items
                } else {
                    let lowercasedQuery = searchText.lowercased()
                    let filtered = items.filter { item in
                        item.author.lowercased().contains(lowercasedQuery)
                    }
                    print("Searching for '\(searchText)', found \(filtered.count) items")
                    return filtered
                }
            }
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("Filtering pipeline error (unexpected): \(error)")
                }
            }, receiveValue: { [weak self] filteredResults in
                self?.filteredItems = filteredResults
            })
            .store(in: &cancellables)
    }
    
}
