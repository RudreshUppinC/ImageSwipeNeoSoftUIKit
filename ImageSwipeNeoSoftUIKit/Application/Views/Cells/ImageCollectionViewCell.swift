//
//  ImageCollectionViewCell.swift
//  ImageSwipeNeoSoftUIKit
//
//  Created by RudreshUppin on 26/04/25.
//

import UIKit
import Combine

class ImageCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imagView: UIImageView!

    private var currentImageURLString: String?
    private var imageSubscription: AnyCancellable?

    private let imageCornerRadius: CGFloat = 10.0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupImageView()
    }

    private func setupImageView() {
        imagView.contentMode = .scaleAspectFill
        imagView.backgroundColor = .systemGray5
        imagView.layer.cornerRadius = imageCornerRadius
        imagView.clipsToBounds = true
     
    }

    func configure(with urlString: String?) {
        cancelImageLoad()
        self.currentImageURLString = urlString

        guard let urlString = urlString, let imageURL = URL(string: urlString) else {
            self.imagView.image =   UIImage(systemName:NeoSoftStrings.placeholderImage.rawValue)

            return
        }

        self.imagView.image =    UIImage(systemName:NeoSoftStrings.placeholderImage.rawValue)


        imageSubscription = URLSession.shared.dataTaskPublisher(for: imageURL)
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    throw URLError(.badServerResponse)
                }
                return data
            }
            .map { UIImage(data: $0) }
            .catch { error -> Just<UIImage?> in
                print("Error loading image \(urlString): \(error.localizedDescription)")
                return Just(UIImage(systemName:NeoSoftStrings.placeholderImage.rawValue))

            }
            .replaceNil(with: UIImage(systemName:NeoSoftStrings.placeholderImage.rawValue)!)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] loadedImage in
                guard let self = self else { return }
                // **Crucial Check**: Only update if the cell is still waiting for this specific URL
                if self.currentImageURLString == urlString {
                    self.imagView.image = loadedImage
                } else {
                    print("Cell reused before image \(urlString) could be set.")
                }
            }
    }

    private func cancelImageLoad() {
        imageSubscription?.cancel()
        imageSubscription = nil
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        cancelImageLoad()
        imagView.image = nil
        currentImageURLString = nil
    }
}
