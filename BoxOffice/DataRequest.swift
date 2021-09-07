//
//  DataRequest.swift
//  BoxOffice
//
//  Created by kwon on 2021/09/07.
//

import Foundation

let DidReceiveMoviesNofitication: Notification.Name = Notification.Name("DidReceiveMovies")

func requestMovies(_ orderType: Int) {
    guard let url: URL = URL(string: "https://connect-boxoffice.run.goorm.io/movies?order_type=\(orderType)") else {
        return
    }
    
    let session: URLSession = URLSession(configuration: .default)
    
    let dataTask: URLSessionDataTask = session.dataTask(with: url, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) in
        if let error = error {
            print(error.localizedDescription)
            return
        }

        guard let data = data else {
            return
        }
        
        do {
            // 여기서 APIResponse는 Movie파일 안에 내가 만들어준 것
            let apiResponse: APIResponse = try JSONDecoder().decode(APIResponse.self, from: data)
            
            NotificationCenter.default.post(name: DidReceiveMoviesNofitication, object: nil, userInfo: ["movies": apiResponse.movies])
        } catch (let err) {
            print(err.localizedDescription)
        }
    })
    
    dataTask.resume()
}
