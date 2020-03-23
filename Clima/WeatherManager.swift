//
//  WeatherManager.swift
//  Clima
//
//  Created by Jose Main on 21/02/2020.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import Foundation

protocol WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel)
    func didFailWithError(_ error: Error)
}

struct WeatherManager{
    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?appid=f9987fe691b5d1af25dca5be4174dcce&units=metric"
    
    var delegate: WeatherManagerDelegate?
    
    func fetchWeather(cityName: String){
        let urlString = "\(weatherURL)&q=\(cityName)"
        performRequest(with:urlString)
    }
    
    func fetchWeather(latitude: Double, longitude: Double){
        let urlString = "\(weatherURL)&lat=\(latitude)&lon=\(longitude)"
        performRequest(with:urlString)
    }
    
    func performRequest(with urlString: String){
        if let url = URL(string: urlString){
            let session  = URLSession(configuration: .default)
            let task = session.dataTask(with: url, completionHandler:handle(data: response: error:))
            task.resume()
            
        }
    }
    
    func handle(data:Data?, response:URLResponse?, error:Error?){
        if error != nil{
            self.delegate?.didFailWithError(error!)
            return
        }
        
        if let safeData = data{
            if let weather = self.parseJSON(safeData){
                self.delegate?.didUpdateWeather(self, weather: weather)
            }
        }
    }
    
    func parseJSON(_ weatherData: Data) -> WeatherModel?{
        let decoder = JSONDecoder()
        do{
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            print(decodedData)
            let id = decodedData.weather[0].id
            let temp = decodedData.main.temp
            let name = decodedData.name
            
            let weather = WeatherModel(conditionId: id, cityName: name, temperature: temp)
            
            return weather
        }catch{
            self.delegate?.didFailWithError(error)
            return nil
        }
    }
    
    
}
