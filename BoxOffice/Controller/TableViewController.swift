//
//  ViewController.swift
//  BoxOffice
//
//  Created by kwon on 2021/09/07.
//

import UIKit

class TableViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    let tableViewCellIdentifier: String = "tableViewCell"
    var tabBar: TabBarController?
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return refreshControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let tabBar = self.tabBarController as? TabBarController else {
            return
        }
        
        self.tabBar = tabBar
        self.setNavigationTitle(orderBy: tabBar.orderBy)
        self.tableView.refreshControl = self.refreshControl
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.didReceiveMoviesNotification(_:)), name: DidReceiveMoviesNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let tabBar = self.tabBar else {
            return
        }
        
        if tabBar.movies.count == 0 {
            requestMovies(tabBar.orderBy)
        }
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let tabBar = self.tabBar else {
            return
        }
        
        guard let movieViewController = segue.destination as? MovieViewController else {
            return
        }
        
        guard let selectedCell: UITableViewCell = sender as? UITableViewCell, let index = self.tableView.indexPath(for: selectedCell) else {
            return
        }
        
        movieViewController.movie = tabBar.movies[index.row]
    }
    
    @objc func didReceiveMoviesNotification(_ noti: Notification) {
        guard let movies: [Movie] = noti.userInfo?["movies"] as? [Movie] else {
            DispatchQueue.main.async {
                let alert: UIAlertController = UIAlertController(title: "??????", message: "???????????? ???????????? ???????????????.", preferredStyle: .alert)
                let cancelAction: UIAlertAction = UIAlertAction(title: "?????? ????????????", style: .cancel, handler: { (action: UIAlertAction) in
                    self.refresh()
                })
                
                alert.addAction(cancelAction)
                self.present(alert, animated: true, completion: nil)
            }
            
            return
        }
        
        guard let tabBar = self.tabBar else {
            return
        }
        
        tabBar.movies = movies
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.setNavigationTitle(orderBy: tabBar.orderBy)
            
            if self.refreshControl.isRefreshing {
                self.refreshControl.endRefreshing()
            }
        }
    }
    
    @IBAction func touchUpSettingIcon() {
        self.showAlertController(style: .actionSheet)
    }
    
    func showAlertController(style: UIAlertController.Style) {
        let alertController: UIAlertController = UIAlertController(title: "?????? ?????? ??????", message: "????????? ?????? ????????? ????????????????", preferredStyle: style)
        
        guard let tabBar = self.tabBar else {
            return
        }
        
        enum OrderType: Int, CaseIterable {
            case ticketingRate = 0
            case curation = 1
            case openDate = 2
            
            var title: String {
                switch self {
                case .ticketingRate :
                    return "?????????"
                case .curation:
                    return "????????????"
                case .openDate:
                    return "?????????"
                }
            }
        }
        
        OrderType.allCases.forEach({ order in
            let action = UIAlertAction(title: order.title, style: .default, handler: { (action: UIAlertAction) in
                tabBar.orderBy = order.rawValue
                requestMovies(order.rawValue)
            })
            
            alertController.addAction(action)
        })
        
        let cancelAction: UIAlertAction = UIAlertAction(title: "??????", style: .cancel, handler: nil)
        
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func setNavigationTitle(orderBy: Int) {
        switch orderBy {
        case 1:
            self.navigationItem.title = "????????????"
        case 2:
            self.navigationItem.title = "?????????"
        default:
            self.navigationItem.title = "?????????"
        }
    }
    
    @objc func refresh() {
        requestMovies(self.tabBar?.orderBy ?? 0)
    }
}

extension TableViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let tabBar = self.tabBar else {
            preconditionFailure("?????? ????????? ?????? ??? ??????")
        }
        
        return tabBar.movies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: TableViewCell = self.tableView.dequeueReusableCell(withIdentifier: self.tableViewCellIdentifier, for: indexPath) as? TableViewCell else {
            preconditionFailure("????????? ????????? ??? ??? ??????")
        }

        guard let movie: Movie = self.tabBar?.movies[indexPath.row] else {
            preconditionFailure("????????? ?????? ??????")
        }
        
        cell.movieLabel.text = movie.title
        cell.detailLabel.text = movie.detailForTableView
        cell.releaseDateLabel.text = movie.releaseDateForTableView
        
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
        
        // nil????????? ????????? cell ????????? ??? ??? ?????? ???????????? ?????? ???????????? ??????
        cell.posterView.image = nil
        
        DispatchQueue.global().async {
            // Data??? ?????? ??????????????? ???????????? ????????? ????????? ?????? ??????????????? ??? ?????? ?????? ??????????????? ?????? ?????????
            guard let imageUrl: URL = URL(string: movie.thumb), let imageData: Data = try? Data(contentsOf: imageUrl) else {
                return
            }
            
            DispatchQueue.main.async {
                // image??? ???????????? ?????? ???????????? ???????????? ?????? ????????? ???????????? cell??? index??? ????????? ??? ???????????? index ?????? ??? ????????? ??????
                if let index: IndexPath = tableView.indexPath(for: cell) {
                    if index.row == indexPath.row {
                        cell.posterView.image = UIImage(data: imageData)
                        cell.setNeedsLayout()
                    }
                }
            }
        }
        
        return cell
    }
}

extension TableViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // ????????? ???????????? cell??? ?????? ???????????? ???????????? ??? ??????
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
}
