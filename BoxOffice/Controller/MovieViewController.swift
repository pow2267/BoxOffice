//
//  MovieViewController.swift
//  BoxOffice
//
//  Created by kwon on 2021/09/10.
//

import UIKit

class MovieViewController: UIViewController {
    
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
