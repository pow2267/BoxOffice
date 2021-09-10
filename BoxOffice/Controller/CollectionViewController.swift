//
//  CollectionViewController.swift
//  BoxOffice
//
//  Created by kwon on 2021/09/08.
//

import UIKit

class CollectionViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!

    let collectionViewCellIdentifier: String = "collectionViewCell"
    var tabBar: TabBarController?
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return refreshControl
    }()
    
    @objc func refresh() {
        requestMovies(self.tabBar?.orderBy ?? 0)
    }
    
    @IBAction func touchUpSettingIcon() {
        self.showAlertController(style: UIAlertController.Style.actionSheet)
    }
    
    func showAlertController(style: UIAlertController.Style) {
        let alertController: UIAlertController = UIAlertController(title: "정렬 방식 선택", message: "영화를 어떤 순서로 정렬할까요?", preferredStyle: style)
        
        let reservationRateAction: UIAlertAction = UIAlertAction(title: "예매율", style: UIAlertAction.Style.default, handler: { (action: UIAlertAction) in
            self.tabBar?.orderBy = 0
            requestMovies(0)
        })
        
        let curationAction: UIAlertAction = UIAlertAction(title: "큐레이션", style: UIAlertAction.Style.default, handler: { (action: UIAlertAction) in
            self.tabBar?.orderBy = 1
            requestMovies(1)
        })
        
        let releaseDateAction: UIAlertAction = UIAlertAction(title: "개봉일", style: UIAlertAction.Style.default, handler: { (action: UIAlertAction) in
            self.tabBar?.orderBy = 2
            requestMovies(2)
        })
        
        let cancelAction: UIAlertAction = UIAlertAction(title: "취소", style: UIAlertAction.Style.cancel, handler: nil)
        
        alertController.addAction(reservationRateAction)
        alertController.addAction(curationAction)
        alertController.addAction(releaseDateAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    @objc func didReceiveMoviesNotification(_ noti: Notification) {
        guard let tabBar = self.tabBar, let movies: [Movie] = noti.userInfo?["movies"] as? [Movie] else {
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

        NotificationCenter.default.addObserver(self, selector: #selector(self.didReceiveMoviesNotification(_:)), name: DidReceiveMoviesNofitication, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if self.tabBar?.movies.count == 0 {
            requestMovies(self.tabBar?.orderBy ?? 0)
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

extension CollectionViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.tabBar?.movies.count ?? 0
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
            // Data는 동기 메소드라서 이미지를 불러올 때까지 동작이 멈추게 됨. 그럼 불편하니까 백그라운드 큐에 넣어줌
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
