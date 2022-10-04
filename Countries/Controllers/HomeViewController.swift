//
//  HomViewController.swift
//  Countries
//
//  Created by admin on 30.09.2022.
//

import UIKit

class HomeViewController: UIViewController {
    
    private lazy var responseData: CountriesResponse = CountriesResponse(links: [], data: [])
    
    private lazy var isPageRefreshing: Bool = false
    
    private let countriesCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let width = UIScreen.main.bounds.width - 50
        layout.itemSize = CGSize(width: width, height: 50)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 20
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(CountryCollectionViewCell.self, forCellWithReuseIdentifier: CountryCollectionViewCell.identifier)
        return collectionView
    }()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        view.addSubview(countriesCollectionView)
        
        countriesCollectionView.delegate = self
        countriesCollectionView.dataSource = self
        
        configureNavigationBar()
        
        getCountries()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        countriesCollectionView.frame = view.frame
    }
    
    // MARK: Pagination
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if(self.countriesCollectionView.contentOffset.y >= (self.countriesCollectionView.contentSize.height - self.countriesCollectionView.bounds.size.height)) {
            if !isPageRefreshing {
                isPageRefreshing = true
                getNextPage()
            }
        }
    }
    
    private func getCountries() {
        
        NetworkManager.shared.getCountries { result in
            switch result {
            case .success(let success):
                self.responseData = success
                // to prevent memory leaks we have to bind self as weak
                // so this way this closure can be deleted by ARC
                DispatchQueue.main.async { [weak self] in
                    self?.countriesCollectionView.reloadData()
                    self?.isPageRefreshing = false
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    private func getNextPage() {
        guard let nextPageUrl = responseData.links.first(where: {$0.rel == "next"})?.href else { return }
        NetworkManager.shared.getNextPage(with: nextPageUrl) { [weak self] result in
            switch result {
            case .success(let success):
                self?.combineResponsesWithCurrentResponse(success)
            case .failure(let failure):
                print(failure.localizedDescription)
            }
        }
    }
    
    private func combineResponsesWithCurrentResponse(_ response: CountriesResponse) {
        let newResponse = CountriesResponse(links: response.links, data: responseData.data + response.data)
        
        responseData = newResponse
        DispatchQueue.main.async { [weak self] in
            self?.countriesCollectionView.reloadData()
            self?.isPageRefreshing = false
        }
    }
    
    private func configureNavigationBar() {
        
        let countriesLabel = UILabel()
        countriesLabel.text = "Countries"
        countriesLabel.font = .systemFont(ofSize: 16, weight: .bold)
        countriesLabel.sizeToFit()
        
        let middleView = UIView()
        middleView.addSubview(countriesLabel)
        
        // constraints for navigationbar label
        let countriesLabelConstraints = [
            countriesLabel.centerXAnchor.constraint(equalTo: middleView.centerXAnchor),
            countriesLabel.centerYAnchor.constraint(equalTo: middleView.centerYAnchor)
        ]
        
        NSLayoutConstraint.activate(countriesLabelConstraints)
        
        navigationItem.titleView = middleView
        
    }
}

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return responseData.data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = countriesCollectionView.dequeueReusableCell(withReuseIdentifier: CountryCollectionViewCell.identifier, for: indexPath) as? CountryCollectionViewCell else { return UICollectionViewCell() }
        
        cell.delegate = self
        
        let countryInfo = responseData.data[indexPath.row]
        
        cell.configureCell(with: CountryViewModel(name: countryInfo.name, code: countryInfo.code, wikiDataId: countryInfo.wikiDataId))
        
        cell.checkOnDatabaseAndSetButton()
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let safeCode = responseData.data[indexPath.row].code else { return }
        
        DispatchQueue.main.async { [weak self] in
            let vc = DetailViewController()
            vc.navigationController?.navigationBar.tintColor = .white
            vc.configure(with: safeCode)
            self?.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension HomeViewController: CountryCollectionViewCellDelegate {
    func CountryCollectionViewCellDidTapFavorite() {
        print("SAVED")
    }
}
