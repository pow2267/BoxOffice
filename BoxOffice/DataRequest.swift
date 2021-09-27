//
//  DataRequest.swift
//  BoxOffice
//
//  Created by kwon on 2021/09/07.
//

import Foundation

let DidReceiveMoviesNotification: Notification.Name = Notification.Name("DidReceiveMovies")
let DidReceiveMovieInfoNotification: Notification.Name = Notification.Name("DidReceiveMovieInfo")
let DidReceiveCommentNotification: Notification.Name = Notification.Name("DidReceiveComment")

func requestMovies(_ orderType: Int) {
    guard let url: URL = URL(string: "https://connect-boxoffice.run.goorm.io/movies?order_type=\(orderType)") else {
        return
    }
    
    let session: URLSession = URLSession(configuration: .default)
    
    let dataTask: URLSessionDataTask = session.dataTask(with: url, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) in
        if let error = error {
            print("MovieList: \(error.localizedDescription)")
            return
        }

        guard let data = data else {
            return
        }
        
        do {
            // 여기서 APIResponse는 Movie파일 안에 내가 만들어준 것
            let apiResponse: APIResponse = try JSONDecoder().decode(APIResponse.self, from: data)
            
            NotificationCenter.default.post(name: DidReceiveMoviesNotification, object: nil, userInfo: ["movies": apiResponse.movies])
        } catch (let err) {
            print("MovieList: \(err.localizedDescription)")
            NotificationCenter.default.post(name: DidReceiveMoviesNotification, object: nil, userInfo: nil)
        }
    })
    
    dataTask.resume()
}

func requestMovieInfo(_ id: String) {
    guard let url: URL = URL(string: "https://connect-boxoffice.run.goorm.io/movie?id=\(id)") else {
        return
    }
    
    let session: URLSession = URLSession(configuration: .default)
    
    let dataTask: URLSessionDataTask = session.dataTask(with: url, completionHandler: {(data: Data?, response: URLResponse?, error: Error?) in
        if let error = error {
            print("Movie: \(error.localizedDescription)")
            return
        }
        
        guard let data = data else {
            return
        }
        
        do {
            let apiResponse: MovieInfo = try JSONDecoder().decode(MovieInfo.self, from: data)
            
            NotificationCenter.default.post(name: DidReceiveMovieInfoNotification, object: nil, userInfo: ["movie": apiResponse])
        } catch (let err) {
            print("Movie: \(err.localizedDescription)")
            NotificationCenter.default.post(name: DidReceiveMovieInfoNotification, object: nil, userInfo: nil)
        }
    })
    
    dataTask.resume()
}

func requestComments(_ id: String) {
    guard let url: URL = URL(string: "https://connect-boxoffice.run.goorm.io/comments?movie_id=\(id)") else {
        return
    }
    
    let session: URLSession = URLSession(configuration: .default)
    
    let dataTask: URLSessionDataTask = session.dataTask(with: url, completionHandler: {(data: Data?, response: URLResponse?, error: Error?) in
        if let error = error {
            print("Comment: \(error.localizedDescription)")
            return
        }
        
        guard let data = data else {
            return
        }
        
        do {
            let apiResponse: CommentsResponse = try JSONDecoder().decode(CommentsResponse.self, from: data)
            
            NotificationCenter.default.post(name: DidReceiveCommentNotification, object: nil, userInfo: ["comments": apiResponse.comments])
        } catch (let err) {
            print("Comment: \(err.localizedDescription)")
            NotificationCenter.default.post(name: DidReceiveCommentNotification, object: nil, userInfo: nil)
        }
    })
    
    dataTask.resume()
}
