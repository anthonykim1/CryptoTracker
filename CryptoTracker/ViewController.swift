//
//  ViewController.swift
//  CryptoTracker
//
//  Created by Anthony Kim on 5/17/21.
//

import UIKit
// API Caller class -> get it from coinapi.io (free crypto api) 
// UI to show different crypto currency and their prices
// proper MVVM pattern
class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
   
    

    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.register(CryptoTableViewCell.self,
                           forCellReuseIdentifier: CryptoTableViewCell.identifier)
        return tableView
    }()
    
    private var viewModels = [CryptoTableViewCellViewModel]()
    
    static let numberFormatter: NumberFormatter = {
       let formatter = NumberFormatter()
        formatter.locale = .current
        formatter.allowsFloats = true
        formatter.numberStyle = .currency
        formatter.formatterBehavior = .default
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Crypto Tracker"
        view.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
        
        APICaller.shared.getAllCryptoData { [weak self] result in // this is where we get our models
            switch result {
            case .success(let models):
                self?.viewModels = models.compactMap({ model in// create view models from each of the models
                    // NumberFormatter
                    // we have the price as the float
                    let price = model.price_usd ?? 0
                    let formatter = ViewController.numberFormatter
                    let priceString = formatter.string(from: NSNumber(value: price))
                    
                    let iconUrl = URL(string: APICaller.shared.icons.filter({ icon in
                        icon.asset_id == model.asset_id
                    }).first?.url ?? "")
                    
                    return CryptoTableViewCellViewModel(name: model.name ?? "N/A",
                                                 symbol: model.asset_id,
                                                 price: priceString ?? "N/A",
                                                 iconUrl: iconUrl
                    )
                })
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
                
                
            case .failure(let error):
                print("error: \(error)")
            }
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    //Tableview
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CryptoTableViewCell.identifier,
                                                 for: indexPath
        ) as? CryptoTableViewCell else {
            fatalError()
        }
        cell.configure(with: viewModels[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { //things are bit taller now
        70
    }
}

