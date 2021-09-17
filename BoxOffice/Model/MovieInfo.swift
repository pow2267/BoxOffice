//
//  MovieDetail.swift
//  BoxOffice
//
//  Created by kwon on 2021/09/10.
//

import Foundation

struct MovieInfo: Codable {
    let audience: Int
    let actor: String
    let duration: Int
    let director: String
    let synopsis: String
    let genre: String
    let grade: Int
    let image: String
    let reservationGrade: Int
    let title: String
    let reservationRate: Double
    let userRating: Double
    let date: String
    let id: String
    
    var releaseDate: String {
        return "\(date) 개봉"
    }
    
    var genreAndDuration: String {
        return "\(genre) / \(duration)분"
    }
    
    var reservation: String {
        return "\(reservationGrade)위 \(reservationRate)%"
    }
    
    enum CodingKeys: String, CodingKey {
        case audience, actor, duration, director, synopsis, genre, grade, image, title, date, id
        case reservationGrade = "reservation_grade"
        case reservationRate = "reservation_rate"
        case userRating = "user_rating"
    }
}
