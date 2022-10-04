//
//  CoreDataManager.swift
//  Countries
//
//  Created by admin on 3.10.2022.
//

import Foundation

import Foundation
import UIKit
import CoreData


class CoreDataManager {
    
    enum DBError: Error {
        case failedToSaveData
        case failedToFetchData
        case failedToDeleteData
        case failedToFind
        case duplicateRecord
    }
    
    static let shared = CoreDataManager()
    
    func saveCountryWith(model: Country, completion: @escaping (Result<Void, Error>) -> Void) {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let context = appDelegate.persistentContainer.viewContext
        
        let item = CountryEntity(context: context)
        
        item.name = model.name
        item.code = model.code
        item.wikiDataId = model.wikiDataId
        
        guard let safeCode = item.code else { return }
        
        /*
        checkOnDatabase(code: safeCode) { result in
            switch result {
            case .success(let success):
                if !success {
                    do {
                     try context.save()
                     // empty paranthesis means void data
                     completion(.success(()))
                     print("Succesfully saved the to the DB")
                    } catch {
                     completion(.failure(DBError.failedToSaveData))
                    }
                } else {
                    completion(.failure(DBError.duplicateRecord))
                }
            case .failure(_):
                completion(.failure(DBError.failedToSaveData))
            }
        }
        */
        do {
            try context.save()
            // empty paranthesis means void data
            completion(.success(()))
            print("Succesfully saved the to the DB")
        } catch {
            completion(.failure(DBError.failedToSaveData))
        }
    }
    
    func fetchingDataFromDB(completion: @escaping (Result<[CountryEntity], Error>) -> ()) {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let context = appDelegate.persistentContainer.viewContext
        
        let request: NSFetchRequest<CountryEntity>
        
        request = CountryEntity.fetchRequest()
        
        do {
            
            let countries = try context.fetch(request)
            completion(.success(countries))
            
            
        } catch {
            completion(.failure(DBError.failedToFetchData))
        }
        
    }
    
    
    func deleteTitleWith(model: Country, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let context = appDelegate.persistentContainer.viewContext
        
        fetchingDataFromDB { result in
            switch result {
            case .success(let countryEntities):
                guard let entity = countryEntities.first(where: {$0.code == model.code}) else { return }
                context.delete(entity)
                do {
                    try context.save()
                    completion(.success(()))
                    print("Successfully removed from database")
                } catch {
                    completion(.failure(DBError.failedToDeleteData))
                }
            case .failure(_):
                completion(.failure(DBError.failedToFind))
            }
        }
    }
    
    func checkOnDatabase(code : String, completion: @escaping (Result<Bool, Error>) -> Void) {
        fetchingDataFromDB { result in
            switch result {
            case .success(let countryEntities):
                print("Database record count is: \(countryEntities.count)")
                if countryEntities.contains(where: {$0.code == code}) {
                    completion(.success(true))
                } else {
                    completion(.success(false))
                }
            case .failure(_):
                completion(.failure(DBError.failedToFind))
            }
        }
    }
    
    func deleteAllRecords(entity : String) {

        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let context = appDelegate.persistentContainer.viewContext
        
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
        
        do {
            try context.execute(deleteRequest)
            try context.save()
        } catch {
            print ("There was an error")
        }
    }
}
