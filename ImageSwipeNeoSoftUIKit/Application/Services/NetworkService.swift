//
//  NetworkService.swift
//  ImageSwipeNeoSoftSwitUI
//
//  Created by RudreshUppin on 25/04/25.
//

import Foundation
import Combine

class NetworkService: NetworkFetching {

   //MARK: -  variables
    private let errorDomain = "com.ImageSwipeNeoSoftSwitUI.NetworkServiceError"
    private var apiURLString: String =  "https://picsum.photos/v2/list?page=1&limit=20"

    //MARK: -  init
  
    init() {
       
    }

    //MARK: -  Public Functions
    func fetchImageDataPublisher() -> AnyPublisher<[CarouselItems], Error> {
        guard let url = URL(string: apiURLString) else {
            fatalError("Invalid URL string provided: \(apiURLString)")
        }
        return URLSession.shared.dataTaskPublisher(for: url)
            .mapError { urlError -> Error in
                print("Network Transport Error: \(urlError.localizedDescription)")
                return urlError
            }
            .flatMap { (data: Data, response: URLResponse) -> AnyPublisher<Data, Error> in
                guard let httpResponse = response as? HTTPURLResponse else {
                    let errorDescription = "Invalid Response Type: Expected HTTPURLResponse, got \(type(of: response))"
                    print("\(errorDescription)")
                    let error = NSError(domain: self.errorDomain, code: -1, userInfo: [NSLocalizedDescriptionKey: errorDescription])
                    return Fail(error: error).eraseToAnyPublisher()
                }

                guard (200...299).contains(httpResponse.statusCode) else {
                    let errorDescription = "Invalid Status Code: \(httpResponse.statusCode)"
                    print(" \(errorDescription)")
                    let error = NSError(domain: self.errorDomain, code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorDescription])
                    return Fail(error: error).eraseToAnyPublisher()
                }

                print("Received valid data (Status: \(httpResponse.statusCode))")
                return Just(data)
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            }
            .decode(type: [CarouselItems].self, decoder: JSONDecoder())
            .mapError { error -> Error in
                   print(" Unknown Processing Error: \(error.localizedDescription)")
                 return error
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
