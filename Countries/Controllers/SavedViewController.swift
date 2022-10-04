//
//  FavoritesViewController.swift
//  Countries
//
//  Created by admin on 30.09.2022.
//

import UIKit

class SavedViewController: UIViewController {
    
    public lazy var savedCountries: [CountryEntity] = [CountryEntity]()

    private let savedCountriesCollectionView: UICollectionView = {
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
    
    private let emptyCaseLabel: UILabel = {
        let label = UILabel()
        label.text = "There is no saved country"
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.sizeToFit()
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        
        view.addSubview(savedCountriesCollectionView)
        view.addSubview(emptyCaseLabel)
        
        savedCountriesCollectionView.delegate = self
        savedCountriesCollectionView.dataSource = self
                
        configureNavigationBar()
                
        fetchLocalStorageForSaved()
        
        configureConstraints()
        
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name("saved"), object: nil, queue: nil) { _ in
            self.fetchLocalStorageForSaved()
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name("removed"), object: nil, queue: nil) { _ in
            self.fetchLocalStorageForSaved()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        savedCountriesCollectionView.frame = view.frame
    }
    
    private func fetchLocalStorageForSaved() {
        CoreDataManager.shared.fetchingDataFromDB { [weak self] result in
            switch result {
            case .success(let success):
                self?.savedCountries = success
                DispatchQueue.main.async { [weak self] in
                    self?.savedCountriesCollectionView.reloadData()
                }
            case .failure(let failure):
                print(failure.localizedDescription)
            }
        }
    }

    private func configureConstraints() {
        let emptyCaseLabelConstraints = [
            emptyCaseLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyCaseLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ]
        
        NSLayoutConstraint.activate(emptyCaseLabelConstraints)
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

extension SavedViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (savedCountries.count == 0) {
            emptyCaseLabel.isHidden = false
            return savedCountries.count
        } else {
            emptyCaseLabel.isHidden = true
            return savedCountries.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = savedCountriesCollectionView.dequeueReusableCell(withReuseIdentifier: CountryCollectionViewCell.identifier, for: indexPath) as? CountryCollectionViewCell else { return UICollectionViewCell() }
        
        cell.delegate = self
        
        let countryInfo = savedCountries[indexPath.row]
        
        cell.configureCell(with: CountryViewModel(name: countryInfo.name, code: countryInfo.code, wikiDataId: countryInfo.wikiDataId))
        
        cell.checkOnDatabaseAndSetButton()
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let safeCode = savedCountries[indexPath.row].code else { return }
        
        DispatchQueue.main.async { [weak self] in
            let vc = DetailViewController()
            vc.navigationController?.navigationBar.tintColor = .white
            vc.configure(with: safeCode)
            self?.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension SavedViewController: CountryCollectionViewCellDelegate {
    func CountryCollectionViewCellDidTapFavorite() {
        print("REMOVED")
    }
}
