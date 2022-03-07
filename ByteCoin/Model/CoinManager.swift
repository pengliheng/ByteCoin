//
//  CoinManager.swift
//  ByteCoin
//
//  Created by Angela Yu on 11/09/2019.
//  Copyright © 2019 The App Brewery. All rights reserved.
//

import Foundation

protocol CoinManagerDelegate {
    func didUpdateCoin(_ coinManager: CoinManager, rate: Double)
    func didFailWithError(error: Error)
}

struct CoinManager {
    
    var delegate: CoinManagerDelegate?
    let baseURL = "https://rest.coinapi.io/v1/exchangerate/BTC"
    let apiKey = "484C8D97-CA86-48F1-B277-805474A0133C"
    let currencyArray = ["AUD", "BRL","CAD","CNY","EUR","GBP","HKD","IDR","ILS","INR","JPY","MXN","NOK","NZD","PLN","RON","RUB","SEK","SGD","USD","ZAR"]

    func getCoinPrice(for currency: String) {
        let finalURL = "\(baseURL)/\(currency)?apikey=\(apiKey)"
        performRequest(finalURL)
    }
    
    func performRequest(_ url: String) {
        if let urlObj = URL(string: url) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: urlObj) { data, response, error in
                if error != nil {
                    self.delegate?.didFailWithError(error: error!)
                    return
                }
                if let safeData = data {
                    if let rate = self.parseJSON(coinData: safeData) {
                        self.delegate?.didUpdateCoin(self, rate: rate)
                    }
                }
            }
            task.resume()
        }
    }
    
    func parseJSON(coinData: Data) -> Double? {
        let decoder = JSONDecoder()
        do {
            let decodeData = try decoder.decode(CoinData.self, from: coinData)
            return decodeData.rate
        } catch {
            delegate?.didFailWithError(error: error)
            return 0.0
        }
    }
}
