//
//  NetworkFetching.swift
//  ImageSwipeNeoSoftSwitUI
//
//  Created by RudreshUppin on 25/04/25.
//

import Foundation
import Combine

protocol NetworkFetching {
    func fetchImageDataPublisher() -> AnyPublisher<[CarouselItems], Error>
}
