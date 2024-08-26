//
//  ViewController.swift
//  WeatherApp
//
//  Created by Sagar ganji on 22.08.2024.
//

import UIKit
import SwiftUI

class WeatherViewController: UIViewController {
    
    //MARK: - IBOutlet(s)
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblCity: UILabel?
    @IBOutlet weak var lblWeatherDescription: UILabel!
    @IBOutlet weak var imgWeatherStatusPic: UIImageView?
    @IBOutlet weak var btnForecastSegment: UISegmentedControl?
    @IBOutlet weak var weatherCollectionViewList: UICollectionView?
    @IBOutlet weak var btnTempSegment: UISegmentedControl!
    @IBOutlet weak var temperature: UILabel!
    
    
    // Lazy instantiation of the WeatherViewModel
    var service = NetworkService(cacheManager: CacheManager())
    lazy var viewModel = {
        WeatherViewModel(networkService: service)
    }()
    
    //MARK: - Life Cycle Method(s)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initViewModel()
        
        weatherCollectionViewList?.dataSource = self
        weatherCollectionViewList?.delegate = self
    }
    
    //MARK: - Action Method(s)
    
    // btnSegmentAction: Handles the segmented control for forecast selection
    @IBAction func btnSegmentAction(_ segment: UISegmentedControl) {
        viewModel.todayOrWeekelySegement = (segment.selectedSegmentIndex == 0)
        self.weatherCollectionViewList?.reloadData()
    }
    
    // btnTempSegmentAction: Handles the segmented control for temperature unit selection
    @IBAction func btnTempSegmentAction(_ segment: UISegmentedControl) {
        viewModel.tempBool = (segment.selectedSegmentIndex == 0)
        self.weatherCollectionViewList?.reloadData()
        self.temperature?.text = viewModel.getFormattedTemprature()
    }
    
    // onSearch: Displays an alert for city search
    @IBAction func onSearch(_ sender: Any) {
        // Create an alert controller
        let alertController = UIAlertController(title: "Search", message: "Enter a city name", preferredStyle: .alert)
        
        alertController.addTextField { (textField) in
            textField.placeholder = "City"
        }
        
        let searchAction = UIAlertAction(title: "Search", style: .default) { [weak self] (_) in
            if let textField = alertController.textFields?.first, let searchText = textField.text {
                if(!searchText.isEmpty) {
                    self?.viewModel.performSearch(with: searchText)
                }
            }
        }
        
        // Create the cancel action
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        // Add the actions to the alert controller
        alertController.addAction(searchAction)
        alertController.addAction(cancelAction)
        
        // Present the alert controller
        present(alertController, animated: true, completion: nil)
    }
}

//MARK: - UI update and ViewModel Initializer

extension WeatherViewController {
    
    func initViewModel() {
        
        // Callback to update the weather forecast list
        viewModel.reloadWeatherList = { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.weatherCollectionViewList?.reloadData()
            }
        }
        
        // Callback to show the current weather data
        viewModel.showWeatherData = { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.showCityWeatherData()
            }
        }
    }
    
    
    // showCityWeatherData: Updates the UI elements with the current weather data
    func showCityWeatherData() {
        self.lblDate?.text = viewModel.getFormattedDate()
        self.lblWeatherDescription?.text = viewModel.getDescription()
        self.lblCity?.text = viewModel.getCity()
        self.temperature?.text = viewModel.getFormattedTemprature()
        viewModel.getCurrentWeatherIcon {
            self.imgWeatherStatusPic?.image = UIImage(data: $0)
        }
    }
}

//MARK: - UICollectionViewDataSource Method(s)

extension WeatherViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.getCellCount()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WeatherForecastCell", for: indexPath) as! WeatherForecastCell
        
        let currentListArray = viewModel.getCurrentList()
        
        let data = currentListArray[indexPath.row]
        
        if let iconName = data.weather.first?.icon {
            viewModel.getImageIcon(iconName: iconName) {
                cell.imgWeatherStatusPic?.image = UIImage(data: $0)
            }
        }
        
        cell.lblTemprature?.text = self.viewModel.getTemp(for: data)
        cell.lblTime?.text = viewModel.getTimeinterval(for: data)
        
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let data = viewModel.getCurrentList()[indexPath.row]
        
        let weatherDetailView = WeatherDetailView(timeStamp: data.dt_txt
                    ,mainTemp: viewModel.getFormatterTemp(for: viewModel.cityWeatherData?.main.temp ?? 0.0)
                    , maxTemp: viewModel.getFormatterTemp(for: viewModel.cityWeatherData?.main.temp_max ?? 0.0)
                    , minTemp: viewModel.getFormatterTemp(for: viewModel.cityWeatherData?.main.temp_min ?? 0.0)
                    , humidity: "\(data.main.humidity)"
                    , description: viewModel.cityWeatherData?.weather.first?.description ?? "N/A")
        
        // Create a hosting controller with the SwiftUI view
        let hostingController = UIHostingController(rootView: weatherDetailView)
        
        // Push the hosting controller onto the navigation stack
        self.navigationController?.pushViewController(hostingController, animated: true)
    }
}
    
    
    //MARK: - //MARK: - UICollectionViewDataSource Method(s)
    
    extension WeatherViewController: UICollectionViewDelegateFlowLayout {
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            let colllectionViewHeight = collectionView.bounds.size.height
            let colllectionViewWidth = collectionView.bounds.size.width / 5
            return CGSize(width: colllectionViewWidth, height: colllectionViewHeight)
        }
    }

