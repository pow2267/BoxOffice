//
//  CollectionViewController.swift
//  BoxOffice
//
//  Created by kwon on 2021/09/08.
//

import UIKit

class CollectionViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!

    var tabBar: TabBarController?
    let collectionViewCellIdentifier: String = "collectionViewCell"
    
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
        self.collectionView.refreshControl = self.refreshControl
        
        let width = UIScreen.main.bounds.width
        let height = UIScreen.main.bounds.height
        var length: CGFloat = floor(width / 2.0)
        
        // 가로 모드일 때
        if width > height {
            length = floor(height / 2.0)
        }
        
        let flowLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 5
        flowLayout.itemSize = CGSize(width: length, height: length * 2)
        
        self.collectionView.collectionViewLayout = flowLayout

        NotificationCenter.default.addObserver(self, selector: #selector(self.didReceiveMoviesNotification(_:)), name: DidReceiveMoviesNotification, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
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
        
        guard let selectedCell: CollectionViewCell = sender as? CollectionViewCell, let index = self.collectionView.indexPath(for: selectedCell) else {
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
            self.collectionView.reloadData()
            self.setNavigationTitle(orderBy: tabBar.orderBy)
            
            if self.refreshControl.isRefreshing {
                self.refreshControl.endRefreshing()
            }
        }
    }
    
    @IBAction func touchUpSettingIcon() {
        self.showAlertController(style: UIAlertController.Style.actionSheet)
    }
    
    func showAlertController(style: UIAlertController.Style) {
        let alertController: UIAlertController = UIAlertController(title: "정렬 방식 선택", message: "영화를 어떤 순서로 정렬할까요?", preferredStyle: style)
        
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
                    return "예매율"
                case .curation:
                    return "큐레이션"
                case .openDate:
                    return "개봉일"
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
        
        let cancelAction: UIAlertAction = UIAlertAction(title: "취소", style: UIAlertAction.Style.cancel, handler: nil)
        
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
        guard let tabBar = self.tabBar else {
            return
        }
        
        requestMovies(tabBar.orderBy)
    }
}

extension CollectionViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let tabBar = self.tabBar else {
            preconditionFailure("탭바 정보를 찾을 수 없음")
        }
        
        return tabBar.movies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell: CollectionViewCell = self.collectionView.dequeueReusableCell(withReuseIdentifier: collectionViewCellIdentifier, for: indexPath) as? CollectionViewCell else {
            preconditionFailure("커스텀 콜렉션 뷰 셀 오류")
        }
        
        guard let movie: Movie = self.tabBar?.movies[indexPath.row] else {
            preconditionFailure("데이터 조회 오류")
        }
        
        cell.movieLabel.text = movie.title
        cell.detailLabel.text = movie.detailForCollectionView
        cell.releaseDateLabel.text = movie.releaseDateForCollectionView
        
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
                for visibleCell in collectionView.visibleCells {
                    if collectionView.indexPath(for: visibleCell) != nil {
                        cell.posterView.image = UIImage(data: imageData)
                        cell.setNeedsLayout()
                    }
                }
            }
        }
        
        return cell
    }
}
