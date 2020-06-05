//
//  File.swift
//  TestJson
//
//  Created by Gavin Li on 5/28/20.
//  Copyright © 2020 Gavin Li. All rights reserved.
//

import Foundation

class NetworkService {

    static func loadData(from url: URL, completion: @escaping ([Author], Error?) -> Void) {
        let request = URLRequest(url: url)
//        guard let data = try? Data(contentsOf: url) else { return }
        let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
            if let error = error {
                print(error)
                completion([], error)
                return
            }

            if let data = data {
                let authors = self.parseJsonData(data: data)
                completion(authors, nil)
            }
        })

        task.resume()
    }

    private static func parseJsonData(data: Data) -> [Author] {
        var authors: [Author] = []

        do {
            let jsonResult = try JSONSerialization.jsonObject(with: data,
                options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary

            let jsonAuthors = jsonResult?["author"] as! [[String: Any]]
            for jsonAuthor in jsonAuthors {
                if let author: Author = parseJsonHelper(jsonAuthor) {
                    authors.append(author)
                }
            }
        } catch {
            print(error)
        }

        return authors
    }

    private static func parseJsonHelper<Model>(_ dictionary: [String: Any]) -> Model? {
        if Model.self == Book.self {
            if let title = dictionary["title"] as? String,
                let year = dictionary["year"] as? Int {
                return Book.init(title: title, year: year) as? Model
            }
        } else if Model.self == Author.self {
            if let name = dictionary["name"] as? String,
                let jsonBooks = dictionary["book"] as? [[String: Any]] {
                var books: [Book] = []
                for jsonBook in jsonBooks {
                    if let book: Book = parseJsonHelper(jsonBook) {
                        books.append(book)
                    }
                }
                return Author.init(name: name, book: books) as? Model
            }
        }
        return nil
    }

    
}

// Define protocol, move the parsing logic somewhere else,
// User Result for better syntex

struct Author {
    let name: String
    let book: [Book]

    init(name: String, book: [Book]) {
        self.name = name
        self.book = book
    }
}

struct Book {
    let title: String
    let year: Int

    init(title: String, year: Int) {
        self.title = title
        self.year = year
    }
}
