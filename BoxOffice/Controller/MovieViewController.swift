//
//  MovieViewController.swift
//  BoxOffice
//
//  Created by kwon on 2021/09/10.
//

import UIKit

class MovieViewController: UIViewController {
    
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var releaseDateLabel: UILabel!
    @IBOutlet weak var gerneLabel: UILabel!
    @IBOutlet weak var ratesImage: UIImageView!
    
    var movie: Movie?
    var movieInfo: MovieInfo?
    
    @objc func didReceiveMovieInfoNotification(_ noti: Notification) {
        guard let movieInfo: MovieInfo = noti.userInfo?["movie"] as? MovieInfo else {
            return
        }
        
        self.movieInfo = movieInfo
        
        DispatchQueue.main.async {
            self.titleLabel.text = movieInfo.title
            self.releaseDateLabel.text = movieInfo.releaseDate
            self.gerneLabel.text = movieInfo.genreAndDuration
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = movie?.title

        NotificationCenter.default.addObserver(self, selector: #selector(self.didReceiveMovieInfoNotification(_:)), name: DidReceiveMovieInfoNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let movie = self.movie else {
            return
        }
        
        requestMovieInfo(movie.id)
        
        switch movie.grade {
        case 12:
            self.ratesImage.image = UIImage(named: "ic_12")
        case 15:
            self.ratesImage.image = UIImage(named: "ic_15")
        case 19:
            self.ratesImage.image = UIImage(named: "ic_19")
        default:
            self.ratesImage.image = UIImage(named: "ic_allages")
        }
        
        DispatchQueue.global().async {
            // Data는 동기 메소드라서 이미지를 불러올 때까지 앱이 프리징되는 걸 막기 위해 백그라운드 큐에 넣어줌
            guard let imageUrl: URL = URL(string: movie.thumb), let imageData: Data = try? Data(contentsOf: imageUrl) else {
                return
            }
            
            DispatchQueue.main.async {
                self.posterImageView.image = UIImage(data: imageData)
            }
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
