//
//  ListItemTableViewCell.swift
//  ImageSwipeNeoSoftUIKit
//
//  Created by RudreshUppin on 26/04/25.
//

import UIKit
import Combine

class ListItemTableViewCell: UITableViewCell {
    
    @IBOutlet weak var authorImageView: UIImageView!
    @IBOutlet weak var authorTitle: UILabel!
    @IBOutlet weak var authorSubTitle: UILabel!
    @IBOutlet weak var viewBg: UIView!

    private var currentImageURLString: String?
    private var imageSubscription: AnyCancellable?


    override func awakeFromNib() {
        super.awakeFromNib()
        setupAppearance()
    }

    private func setupAppearance() {
        viewBg.layer.cornerRadius = 10.0
        viewBg.clipsToBounds = true

        authorImageView.layer.cornerRadius = 5.0
        authorImageView.clipsToBounds = true
        authorImageView.contentMode = .scaleAspectFill
        authorImageView.backgroundColor = .systemGray5

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func configure(with item: CarouselItems) {
        authorTitle.text = item.author
        authorSubTitle.text = "ID: \(item.id)"

        loadImage(from: item.download_url)
    }

    private func loadImage(from urlString: String?) {
        cancelImageLoad()
        self.currentImageURLString = urlString
        self.authorImageView.image =  UIImage(systemName:NeoSoftStrings.placeholderImage.rawValue)

        guard let urlString = urlString, let imageURL = URL(string: urlString) else { return }

        imageSubscription = URLSession.shared.dataTaskPublisher(for: imageURL)
            .map { $0.data }
            .compactMap { UIImage(data: $0) }
            .catch { error -> Just<UIImage> in
                print("Image Load Error for \(urlString): \(error.localizedDescription)")
                return Just(UIImage(systemName:NeoSoftStrings.placeholderImage.rawValue)!)
            }
            .replaceEmpty(with: UIImage(systemName:NeoSoftStrings.placeholderImage.rawValue)!)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] loadedImage in
                guard let self = self else { return }
                if self.currentImageURLString == urlString {
                    self.authorImageView.image = loadedImage
                }
            }
    }

    private func cancelImageLoad() {
        imageSubscription?.cancel()
        imageSubscription = nil
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        authorImageView.image = nil
        authorTitle.text = nil
        authorSubTitle.text = nil
        currentImageURLString = nil
        cancelImageLoad()
    }
}

