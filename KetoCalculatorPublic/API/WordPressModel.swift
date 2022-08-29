//
//  WordPressModel.swift
//  KetoCalculator
//
//  Created by toaster on 2022/01/02.
//

import Foundation

struct WordPressArticles {
    let wordPressContent: WordPressContent
    let wordPressImage: Data
}

struct WordPressContent: Decodable {
    let content: ContentResposeModel?
    let captureImageLink: String?
}

struct ContentResposeModel {
    var postURL: String
    var title: String
    var excerpt: String
    var links: String

    enum CodingKeys: String, CodingKey {
        case postURL = "link"
        case title
        case excerpt
        case links = "_links"
    }

    enum CustomCodingKeys: String, CodingKey {
        case rendered
        case featuredmedia = "wp:featuredmedia"
        case href
    }
}

extension ContentResposeModel: Decodable {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let postURL
            = try container
            .decode(String.self, forKey: .postURL)

        let excerpt
            = try container
            .nestedContainer(keyedBy: CustomCodingKeys.self, forKey: .excerpt)
            .decode(String.self, forKey: .rendered)

        let title
            = try container
            .nestedContainer(keyedBy: CustomCodingKeys.self, forKey: .title)
            .decode(String.self, forKey: .rendered)

        var linkNestedContainer
            = try container
            .nestedContainer(keyedBy: CustomCodingKeys.self, forKey: .links)
            .nestedUnkeyedContainer(forKey: .featuredmedia)

        var link = String()
        while !linkNestedContainer.isAtEnd {
            link = try linkNestedContainer
                .nestedContainer(keyedBy: CustomCodingKeys.self)
                .decode(String.self, forKey: .href)
        }

        self.init(postURL: postURL,
                  title: title,
                  excerpt: excerpt,
                  links: link)
    }
}

// imageのための構造体
struct ImageResponseModel {
    var mediadetails: String

    enum CodingKeys: String, CodingKey {
        case mediadetails = "media_details"
    }

    enum CustomCodingKeys: String, CodingKey {
        case sizes
        case medium
        case sourceurl = "source_url"
    }
}

extension ImageResponseModel: Decodable {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let source
            = try container
            .nestedContainer(keyedBy: CustomCodingKeys.self,
                             forKey: .mediadetails)
            .nestedContainer(keyedBy: CustomCodingKeys.self,
                             forKey: .sizes)
            .nestedContainer(keyedBy: CustomCodingKeys.self,
                             forKey: .medium)
            .decode(String.self, forKey: .sourceurl)

        self.init(mediadetails: source)
    }
}
