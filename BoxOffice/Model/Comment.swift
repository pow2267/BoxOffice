//
//  Comment.swift
//  BoxOffice
//
//  Created by kwon on 2021/09/17.
//

import Foundation

struct CommentsResponse: Codable {
    let movieId: String
    let comments: [Comment]
    
    enum CodingKeys: String, CodingKey {
        case comments
        case movieId = "movie_id"
    }
}

struct Comment: Codable {
    let id: String
    let rating: Double
    let timestamp: Double
    let writer: String
    let movieId: String
    let contents: String
    
    enum CodingKeys: String, CodingKey {
        case id, rating, timestamp, writer, contents
        case movieId = "movie_id"
    }
}
