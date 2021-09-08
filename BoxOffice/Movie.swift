//
//  Movie.swift
//  BoxOffice
//
//  Created by kwon on 2021/09/07.
//

import Foundation

struct APIResponse: Codable {
    let orderType: Int
    let movies: [Movie]
    
    enum CodingKeys: String, CodingKey {
        case movies
        case orderType = "order_type"
    }
}

struct Movie: Codable {
    let grade: Int
    let thumb: String
    let reservationGrade: Int
    let title: String
    let reservationRate: Double
    let userRating: Double
    let date: String
    let id: String
    
    var detailForTableView: String {
        return "평점 : \(userRating) 예매 순위 : \(reservationGrade) 예매율 : \(reservationRate)"
    }
    
    var detailForCollectionView: String {
        return "\(reservationGrade)위 (\(userRating)) / \(reservationRate)%"
    }
    
    var releaseDateForTableView: String {
        return "개봉일 : \(date)"
    }
    
    var releaseDateForCollectionView: String {
        return "\(date)"
    }
    
    enum CodingKeys: String, CodingKey {
        case grade, thumb, title, date, id
        case reservationGrade = "reservation_grade"
        case reservationRate = "reservation_rate"
        case userRating = "user_rating"
    }
}


