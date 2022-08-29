//
//  APIClient.swift
//  KetoCalculator
//
//  Created by toaster on 2022/01/02.
//

import Foundation

enum WordPressError: Error {
    case error
}

final class APIClient {
    let myWordPress = "https://ytoaster.com//wp-json/wp/v2/posts?per_page=10"
    let myWordPressForPro = "https://ytoaster.com//wp-json/wp/v2/posts?categories=18&per_page=10"

    static let shared = APIClient()
    private init() { }

    var imageLink: [String] = .init()
    func fetchPost(for pro: AccountStatus,
                completion: (
                    ((Result<[WordPressContent], WordPressError>) -> Void)?
                )) {
        let urlString = {
            pro == .pro
            ? myWordPressForPro
            : myWordPress
        }()
        let url = URL(string: urlString)!
        let request = URLRequest(url: url)

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                completion?(.failure(.error))
                return
            }

            guard let wordpressResponse
                    = try? JSONDecoder().decode([ContentResposeModel].self,
                                                from: data)  else {
                completion?(.failure(.error))
                return
            }

            self.imageLink = wordpressResponse.compactMap { $0.links }
            var wordPressContents: [WordPressContent] = .init()
            for (response, imageLink) in zip(wordpressResponse, self.imageLink) {
                wordPressContents
                    .append(WordPressContent(content: response,
                                              captureImageLink: imageLink))
            }
            completion?(.success(wordPressContents))
        }
        task.resume()
    }
}

class ImageDownLoader {
    static let shared = ImageDownLoader()
    private init() { }

    var articles: [WordPressArticles] = .init()
    func downloadImage(contents: [WordPressContent],
                       completion: ((Result<[WordPressArticles], WordPressError>) -> Void)?) {
        for (count, content) in contents.enumerated() {
            guard let captureImageLink = content.captureImageLink,
                  let url = URL(string: captureImageLink) else {
                return
            }

            let request = URLRequest(url: url)
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data else { return }

                guard let wordPressImageResponse
                        = try? JSONDecoder().decode(ImageResponseModel.self, from: data) else {
                    completion?(.failure(WordPressError.error))
                    return
                }

                let imageURL = wordPressImageResponse.mediadetails
                guard let image = URL(string: imageURL) else {
                    fatalError()
                }

                guard let imageData = try? Data(contentsOf: image)  else {
                    fatalError()
                }

                let article = WordPressArticles(wordPressContent: content, wordPressImage: imageData)
                self.articles.append(article)
//                self.imageData.append(imageData)

                if count == (contents.count - 1) {
                    completion?(.success(self.articles))
                }
            }
            task.resume()
        }
    }
}
