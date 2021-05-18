//
//  APICaller.swift
//  CryptoTracker
//
//  Created by Anthony Kim on 5/17/21.
//

import Foundation

final class APICaller {
    static let shared = APICaller()
    
    private struct Constants {
        static let apiKey = "2365EB53-C1D2-4765-A671-1111698437C0"
        static let assetsEndpoint = "https://rest-sandbox.coinapi.io/v1/assets/"
    }
    
    // privatize the initializer
    private init() {}
    
    // array that will hang on to the icons
    public var icons: [Icon] = []
    
    private var whenReadyBlock: ((Result<[Crypto], Error>) -> Void)?
    // MARK: - Public
    
    public func getAllCryptoData(completion: @escaping (Result<[Crypto], Error>) -> Void
    ) {
        // want to make sure we only return the actual crypto asset after the icons have been fetched
        guard !icons.isEmpty else {
            whenReadyBlock = completion
            return
        }
        
        guard let url = URL(string: Constants.assetsEndpoint + "?apikey=" + Constants.apiKey) else {
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                return
            }
            
            do {
                // decode response
                let cryptos = try JSONDecoder().decode([Crypto].self, from: data)
                
                completion(.success(cryptos.sorted { first, second -> Bool in
                    return first.price_usd ?? 0 > second.price_usd ?? 0
                }))
            } catch {
                completion(.failure(error))
            }
            
        }
        task.resume()
    }
    
    public func getAllIcons() {
        guard let url = URL(string: "https://rest-sandbox.coinapi.io/v1/assets/icons/55/?apikey=2365EB53-C1D2-4765-A671-1111698437C0")
        else {
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let data = data, error == nil else {
                return
            }
            
            do {
                self?.icons = try JSONDecoder().decode([Icon].self, from: data)
                if let completion = self?.whenReadyBlock {
                    self?.getAllCryptoData(completion: completion)
                }
                
            } catch {
                print("cockroach")
                print(error)
            }
            
        }
        task.resume()
    }
    
}
