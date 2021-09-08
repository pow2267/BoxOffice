//
//  ViewController.swift
//  BoxOffice
//
//  Created by kwon on 2021/09/07.
//

import UIKit

class TableViewController: UIViewController, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var movies: [Movie] = []
    let tableViewCellIdentifier: String = "tableViewCell"
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.movies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: TableViewCell = self.tableView.dequeueReusableCell(withIdentifier: self.tableViewCellIdentifier, for: indexPath) as? TableViewCell else {
            preconditionFailure("커스텀 테이블 뷰 셀 오류")
        }

        let movie: Movie = self.movies[indexPath.row]
        
        cell.movieLabel.text = movie.title
        cell.detailLabel.text = movie.detail
        cell.releaseDateLabel.text = movie.releaseDate
        
        switch movie.grade {
        case 12:
            cell.ratesImage.image = UIImage(named: "ic_12")
        case 15:
            cell.ratesImage.image = UIImage(named: "ic_15")
        case 19:
            cell.ratesImage.image = UIImage(named: "ic_19")
        default:
            cell.ratesImage.image = UIImage(named: "ic_allages")
        }
        
        return cell
    }
    
    @objc func didReceiveMoviesNotification(_ noti: Notification) {
        guard let movies: [Movie] = noti.userInfo?["movies"] as? [Movie] else {
            return
        }
        
        self.movies = movies
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.didReceiveMoviesNotification(_:)), name: DidReceiveMoviesNofitication, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Todo
        requestMovies(0)
    }
}

