//
//  PostFeedCollectionViewCell.swift
//  KetoCalculator
//
//  Created by toaster on 2022/01/04.
//

import UIKit

final class PostFeedCollectionViewCell: UICollectionViewCell {
    @IBOutlet private weak var postImageView: UIImageView!
    @IBOutlet private weak var postTitleLabel: UILabel!
    @IBOutlet private weak var postTextView: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    // View
    private func setup() {
        postImageView.map {
            $0.layoutIfNeeded()
            $0.layer.cornerRadius = $0.bounds.height / 2
        }
    }

    func configure(article: WordPressArticles) {
        setup()

        postTitleLabel.text
            = article
            .wordPressContent
            .content?
            .title

        postTextView.text
            = article
            .wordPressContent
            .content?
            .excerpt
            .replacingOccurrences(of: "<.+?>|&.+?;",
                                  with: "",
                                  options: .regularExpression,
                                  range: nil)

        postImageView.image = UIImage(data: article.wordPressImage)
    }
}
