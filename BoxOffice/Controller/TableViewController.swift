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
                let alert: UIAlertController = UIAlertController(title: "오류", message: "데이터를 불러오지 못했습니다.", preferredStyle: .alert)
                let cancelAction: UIAlertAction = UIAlertAction(title: "다시 시도하기", style: .cancel, handler: { (action: UIAlertAction) in
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
        let alertController: UIAlertController = UIAlertController(title: "정렬 방식 선택", message: "영화를 어떤 순서로 정렬할까요?", preferredStyle: style)
        
        guard let tabBar = self.tabBar else {
            return
        }
        
        let reservationRateAction: UIAlertAction = UIAlertAction(title: "예매율", style: .default, handler: { (action: UIAlertAction) in
            tabBar.orderBy = 0
            requestMovies(0)
        })
        
        let curationAction: UIAlertAction = UIAlertAction(title: "큐레이션", style: .default, handler: { (action: UIAlertAction) in
            tabBar.orderBy = 1
            requestMovies(1)
        })
        
        let releaseDateAction: UIAlertAction = UIAlertAction(title: "개봉일", style: .default, handler: { (action: UIAlertAction) in
            tabBar.orderBy = 2
            requestMovies(2)
        })
        
        let cancelAction: UIAlertAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        
        alertController.addAction(reservationRateAction)
        alertController.addAction(curationAction)
        alertController.addAction(releaseDateAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func setNavigationTitle(orderBy: Int) {
        switch orderBy {
        case 1:
            self.navigationItem.title = "큐레이션"
        case 2:
            self.navigationItem.title = "개봉일"
        default:
            self.navigationItem.title = "예매율"
        }
    }
    
    @objc func refresh() {
        requestMovies(self.tabBar?.orderBy ?? 0)
    }
}

extension TableViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let tabBar = self.tabBar else {
            preconditionFailure("탭바 정보를 찾을 수 없음")
        }
        
        return tabBar.movies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: TableViewCell = self.tableView.dequeueReusableCell(withIdentifier: self.tableViewCellIdentifier, for: indexPath) as? TableViewCell else {
            preconditionFailure("커스텀 테이블 뷰 셀 오류")
        }

        guard let movie: Movie = self.tabBar?.movies[indexPath.row] else {
            preconditionFailure("데이터 조회 오류")
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
        
        // nil처리를 해줘야 cell 재활용 할 때 다른 이미지가 잘못 들어가지 않음
        cell.posterView.image = nil
        
        DispatchQueue.global().async {
            // Data는 동기 메소드라서 이미지를 불러올 때까지 앱이 프리징되는 걸 막기 위해 백그라운드 큐에 넣어줌
            guard let imageUrl: URL = URL(string: movie.thumb), let imageData: Data = try? Data(contentsOf: imageUrl) else {
                return
            }
            
            DispatchQueue.main.async {
                // image를 셋팅하기 전에 사용자가 스크롤을 하면 화면에 보여지는 cell의 index가 달라질 수 있으므로 index 비교 후 이미지 삽입
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
        // 이전에 선택했던 cell이 계속 회색으로 표시되는 것 방지
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
}
