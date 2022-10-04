//
//  DetailViewController.swift
//  Countries
//
//  Created by admin on 30.09.2022.
//

import UIKit

class DetailViewController: UIViewController {
        
    private lazy var code: String = String()
    
    private lazy var countryDetails: CountryDetailViewModel = CountryDetailViewModel(capital: "", code: "", callingCode: "", flagImageUri: "", name: "", numRegions: nil, wikiDataId: "")
    
    private let flagImageView: UIImageView = {
        let imageView = UIImageView()
        // imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let countryCodeLabel: UILabel = {
        let label = UILabel()
        label.text = "Country Code:"
        label.textColor = .label
        label.font = .systemFont(ofSize: 14, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let countryCodePlaceHolderLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.textColor = .label
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let moreInformationButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("For More Information ➡", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 10, weight: .regular)
        button.tintColor = .systemBackground
        button.backgroundColor = .systemBlue
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        // Do any additional setup after loading the view.
        
        view.addSubview(flagImageView)
        view.addSubview(countryCodeLabel)
        view.addSubview(countryCodePlaceHolderLabel)
        view.addSubview(moreInformationButton)
        
        
        configureConstraints()
    }
    
    private func configureNavigationBar(with name: String) {
        let countryNameLabel = UILabel()
        countryNameLabel.text = "Turkey"
        countryNameLabel.font = .systemFont(ofSize: 14  , weight: .bold)
        countryNameLabel.sizeToFit()
        
        let middleView = UIView()
        middleView.addSubview(countryNameLabel)
        
        countryNameLabel.text = name
        
        // constraints for navigationbar label
        let countryNameLabelConstraints = [
            countryNameLabel.centerXAnchor.constraint(equalTo: middleView.centerXAnchor),
            countryNameLabel.centerYAnchor.constraint(equalTo: middleView.centerYAnchor)
        ]
        
        NSLayoutConstraint.activate(countryNameLabelConstraints)
        
        navigationItem.titleView = countryNameLabel
        
        guard let safeCode = self.countryDetails.code else { return }
        
        CoreDataManager.shared.checkOnDatabase(code: safeCode) { [weak self] result in
            switch result {
            case .success(let success):
                if success {
                    guard let image = UIImage(systemName: "star.fill") else { return }
                    self?.setFavoriteButtonImage(with: image)
                    
                } else {
                    guard let image = UIImage(systemName: "star") else { return }
                    self?.setFavoriteButtonImage(with: image)
                }
            case .failure(let failure):
                print(failure.localizedDescription)
            }
        }
    }
    
    private func setFavoriteButtonImage(with image: UIImage) {
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(addOrRemoveFromDatabase))
    }
    
    private func getCountryDetails() {
        NetworkManager.shared.getCountryDetails(with: self.code) { [weak self] result in
            switch result {
            case .success(let countryDetails):
                self?.setCountryDetailsToUI(with:
                                        CountryDetailViewModel(
                                            capital: countryDetails.capital,
                                            code: countryDetails.code,
                                            callingCode: countryDetails.callingCode,
                                            flagImageUri: countryDetails.flagImageUri,
                                            name: countryDetails.name,
                                            numRegions: countryDetails.numRegions,
                                            wikiDataId: countryDetails.wikiDataId))
            case .failure(let failure):
                print(failure.localizedDescription)
            }
        }
    }
    
    private func setCountryDetailsToUI(with model: CountryDetailViewModel) {
        self.countryDetails = model
        
        guard let safeString = self.countryDetails.flagImageUri else { return }

        guard let safeUrl = URL(string: safeString) else { return }
                
        flagImageView.downloadedsvg(from: safeUrl)

        guard let safeName = model.name else { return }
                
        guard let safeCode = model.code else { return }
        
        DispatchQueue.main.async { [weak self] in
            self?.countryCodePlaceHolderLabel.text = safeCode
            
            self?.configureNavigationBar(with: safeName)
        }
    }
    
    private func configureButtons() {
        moreInformationButton.addTarget(self, action: #selector(moreInformation), for: .touchUpInside)
    }
    
    @objc private func moreInformation() {
        
        guard let safeWikiDataId = countryDetails.wikiDataId else { return }
        
        let wikiLink = "https://www.wikidata.org/wiki/\(safeWikiDataId)"
        
        guard let url = URL(string: wikiLink) else { return }
            UIApplication.shared.open(url)
    }
    
    @objc private func addOrRemoveFromDatabase() {
        if( navigationItem.rightBarButtonItem?.image == UIImage(systemName: "star")) {
            navigationItem.rightBarButtonItem?.image = UIImage(systemName: "star.fill")
            saveCountry()
        } else {
            navigationItem.rightBarButtonItem?.image = UIImage(systemName: "star")
            removeCountryFromDatabase()
        }
    }
    
    private func saveCountry() {
        
        CoreDataManager.shared.saveCountryWith(model:
                                                Country(name: countryDetails.name,
                                                        code: countryDetails.code,
                                                        wikiDataId: countryDetails.wikiDataId))
        { result in
            switch result {
            case .success():
                print("Saved to the database")
                NotificationCenter.default.post(name: NSNotification.Name("saved"), object: nil)
            case . failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    private func removeCountryFromDatabase() {
        CoreDataManager.shared.deleteTitleWith(model:
                                                Country(name: countryDetails.name,
                                                        code: countryDetails.code,
                                                        wikiDataId: countryDetails.wikiDataId))
        { result in
            switch result {
            case .success():
                NotificationCenter.default.post(name: NSNotification.Name("removed"), object: nil)
            case . failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    
    private func configureConstraints() {
        let flagImageViewConstraints = [
            flagImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            flagImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            flagImageView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            flagImageView.heightAnchor.constraint(equalToConstant: view.bounds.width)
        ]
        
        let countryCodeLabelConstraints = [
            countryCodeLabel.topAnchor.constraint(equalTo: flagImageView.bottomAnchor, constant: 20),
            countryCodeLabel.leadingAnchor.constraint(equalTo: flagImageView.leadingAnchor, constant: 20),
        ]
        
        let countryCodePlaceHolderLabelConstraints = [
            countryCodePlaceHolderLabel.centerYAnchor.constraint(equalTo: countryCodeLabel.centerYAnchor),
            countryCodePlaceHolderLabel.leadingAnchor.constraint(equalTo: countryCodeLabel.trailingAnchor, constant: 5)
        ]
        
        let moreInformationButtonConstraints = [
            moreInformationButton.widthAnchor.constraint(equalToConstant: 180),
            moreInformationButton.heightAnchor.constraint(equalToConstant: 40),
            moreInformationButton.topAnchor.constraint(equalTo: countryCodeLabel.bottomAnchor, constant: 20),
            moreInformationButton.leadingAnchor.constraint(equalTo: countryCodeLabel.leadingAnchor),
            
        ]
        
        NSLayoutConstraint.activate(flagImageViewConstraints)
        NSLayoutConstraint.activate(countryCodeLabelConstraints)
        NSLayoutConstraint.activate(countryCodePlaceHolderLabelConstraints)
        NSLayoutConstraint.activate(moreInformationButtonConstraints)
    }
    
    
    public func configure(with code: String) {
        self.code = code
        
        configureButtons()
        
        getCountryDetails()
    }
}
