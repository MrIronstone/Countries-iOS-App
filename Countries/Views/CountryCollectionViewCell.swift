//
//  CountryTableViewCell.swift
//  Countries
//
//  Created by admin on 30.09.2022.
//

import UIKit

protocol CountryCollectionViewCellDelegate: AnyObject {
    func CountryCollectionViewCellDidTapFavorite()
}

class CountryCollectionViewCell: UICollectionViewCell {
    
    private var code: String?
    
    private var wikiDataId: String?
    
    static let identifier = "CountryCollectionViewCell"
    
    weak var delegate: CountryCollectionViewCellDelegate?
    
    private var countryNameLabel: UILabel = {
        let label = UILabel()
        label.text = "Hüsamettin Demirtaş"
        label.textColor = .label
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let favoriteButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "star"), for: .normal)
        button.tintColor = .label
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(countryNameLabel)
        contentView.addSubview(favoriteButton)

        configureConstraints()
        configureAppearance()
        configureButtons()
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name("removed"), object: nil, queue: nil) { _ in
            self.checkOnDatabaseAndSetButton()
        }
    }
    
    // MARK: This method will be used to configure each sell, that's why I made it public
    public func configureCell(with model: CountryViewModel) {
        
        // MARK: Since model is fetched by internet, infos would be missing so we need to guard it to prevent unexpected results
        guard let name = model.name,
              let wikiDataId = model.wikiDataId,
              let code = model.code
        else { return }
        
        DispatchQueue.main.async {
            self.countryNameLabel.text = name
        }
        self.wikiDataId = wikiDataId
        self.code = code
        
    }
    
    // MARK: This method configures constraints one by one
    private func configureConstraints() {
        let countryNameLabelConstraints = [
            countryNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 30),
            countryNameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ]
        
        let favoriteButtonConstraints = [
            favoriteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -30),
            favoriteButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ]
        
        NSLayoutConstraint.activate(countryNameLabelConstraints)
        NSLayoutConstraint.activate(favoriteButtonConstraints)
    }
    
    // MARK: This function configures the buttons, since there is only one button, it doesnt do much but if I add more buttons in the future, this function will help in advance
    private func configureButtons() {
        favoriteButton.addTarget(self, action: #selector(didTapFavorite), for: .touchUpInside)
    }
    
    
    // MARK: Objc handled button action function
    @objc private func didTapFavorite() {
        delegate?.CountryCollectionViewCellDidTapFavorite()
        if( favoriteButton.imageView?.image == UIImage(systemName: "star")) {
            favoriteButton.setImage(UIImage(systemName: "star.fill"), for: .normal)
            self.saveCountry()
        } else {
            favoriteButton.setImage(UIImage(systemName: "star"), for: .normal)
            self.removeCountryFromDatabase()
        }
    }
    
    private func saveCountry() {
        
        CoreDataManager.shared.saveCountryWith(model:
            Country(name: countryNameLabel.text, code: self.code, wikiDataId: self.wikiDataId)) { result in
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
            Country(name: countryNameLabel.text, code: self.code, wikiDataId: self.wikiDataId)) { result in
            switch result {
            case .success():
                NotificationCenter.default.post(name: NSNotification.Name("removed"), object: nil)
            case . failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    public func checkOnDatabaseAndSetButton() {
        guard let safeCode = self.code else { return }
        
        CoreDataManager.shared.checkOnDatabase(code: safeCode) { [weak self] result in
            switch result {
            case .success(let success):
                if success {
                    self?.favoriteButton.setImage(UIImage(systemName: "star.fill"), for: .normal)
                } else {
                    self?.favoriteButton.setImage(UIImage(systemName: "star"), for: .normal)
                }
            case .failure(let failure):
                print(failure.localizedDescription)
            }
        }
    }
    
    private func configureAppearance() {
        // add border and color
        self.backgroundColor = UIColor.systemBackground
        self.layer.borderColor = UIColor.label.cgColor
        self.layer.borderWidth = 2
        self.layer.cornerRadius = 10
        self.clipsToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
}
