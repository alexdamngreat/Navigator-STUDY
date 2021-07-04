//
//  ViewController.swift
//  Navigator
//
//  Created by Александр Тимофеев on 04.07.2021.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController {
  
  let mapView: MKMapView = {
    
    let mapView = MKMapView()
    mapView.translatesAutoresizingMaskIntoConstraints = false
    return mapView
  }()
  
  let addAdressButton: UIButton = {
    
    let button = UIButton()
    button.setImage(#imageLiteral(resourceName: "adress"), for: .normal)
    button.translatesAutoresizingMaskIntoConstraints = false
    return button
  }()
  
  let routeButton: UIButton = {
    
    let button = UIButton()
    button.setTitle("Route", for: .normal)
    button.backgroundColor = .blue
    button.translatesAutoresizingMaskIntoConstraints = false
    button.isHidden = true
    return button
  }()
  
  let resetButton: UIButton = {
    
    let button = UIButton()
    button.setTitle("Reset", for: .normal)
    button.backgroundColor = .red
    button.translatesAutoresizingMaskIntoConstraints = false
    button.isHidden = true
    return button
  }()
  
  var annotationsArray: [MKPointAnnotation] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    mapView.delegate = self
    
    setConstraints()
    
    addAdressButton.addTarget(self, action: #selector(addAdressButtonTapped), for: .touchUpInside)
    routeButton.addTarget(self, action: #selector(routeButtonTapped), for: .touchUpInside)
    resetButton.addTarget(self, action: #selector(resetButtonTapped), for: .touchUpInside)
  }
  
  @objc func addAdressButtonTapped() {
    
    alertAddAdress(title: "Добавить", placeholder: "Введите город и адрес") { [self] (text) in
      setupPlacemark(adressPlace: text)
    }
  }
  
  @objc func routeButtonTapped() {
    
    for index in 0...annotationsArray.count - 2 {
      createDirectionRequest(startCordinate: annotationsArray[index].coordinate, destinationCordinate: annotationsArray[index + 1].coordinate)
    }
    mapView.showAnnotations(annotationsArray, animated: true)
  }
  
  @objc func resetButtonTapped() {
    mapView.removeOverlays(mapView.overlays)
    mapView.removeAnnotations(mapView.annotations)
    annotationsArray = [MKPointAnnotation]()
    resetButton.isHidden = true
    routeButton.isHidden = true
  }
  
  private func setupPlacemark(adressPlace: String) {
    
    let geocoder = CLGeocoder()
    geocoder.geocodeAddressString(adressPlace) { [self] (placemarks, error) in
      if let error = error {
        print(error)
        self.alertError(title: "Ошибка", message: "Проблемы сервера")
        return
      }
      
      guard let placemarks = placemarks else { return }
      let placemark = placemarks.first
      
      let annotation = MKPointAnnotation()
      annotation.title = "\(adressPlace)"
      
      guard let placemarkLocation = placemark?.location else { return }
      annotation.coordinate = placemarkLocation.coordinate
      
      annotationsArray.append(annotation)
      
      if annotationsArray.count > 2 {
        routeButton.isHidden = false
        resetButton.isHidden = false
      }
      
      mapView.showAnnotations(annotationsArray, animated: true)
    }
  }
  
  private func createDirectionRequest(startCordinate: CLLocationCoordinate2D, destinationCordinate: CLLocationCoordinate2D) {
    
    let startLocation = MKPlacemark(coordinate: startCordinate)
    let destinationLocation = MKPlacemark(coordinate: destinationCordinate)
    
    let request = MKDirections.Request()
    request.source = MKMapItem(placemark: startLocation)
    request.destination = MKMapItem(placemark: destinationLocation)
    request.transportType = .walking
    request.requestsAlternateRoutes = true
    
    let direction = MKDirections(request: request)
    direction.calculate { (response, error) in
      if let error = error {
        print(error)
        return
      }
      
      guard let response = response else {
        self.alertError(title: "Ошибка", message: "Маршрут недоступен")
        return
      }
      
      var minRoute = response.routes[0]
      for route in response.routes {
        minRoute = (route.distance < minRoute.distance) ? route : minRoute
      }
      
      self.mapView.addOverlay(minRoute.polyline)
    }
  }
}

extension ViewController: MKMapViewDelegate {
  
  func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
    let polyLine = MKPolylineRenderer(overlay: overlay as! MKPolyline)
    polyLine.strokeColor = .blue
    return polyLine
  }
}

extension ViewController {
  
  func setConstraints() {
    
    view.addSubview(mapView)
    NSLayoutConstraint.activate([
      mapView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
      mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0),
      mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
      mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0)
    ])
    
    mapView.addSubview(addAdressButton)
    NSLayoutConstraint.activate([
      addAdressButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 40),
      addAdressButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
      addAdressButton.heightAnchor.constraint(equalToConstant: 70),
      addAdressButton.widthAnchor.constraint(equalToConstant: 70)
    ])
    
    mapView.addSubview(routeButton)
    NSLayoutConstraint.activate([
      routeButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -30),
      routeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
      routeButton.heightAnchor.constraint(equalToConstant: 70),
      routeButton.widthAnchor.constraint(equalToConstant: 100)
    ])
    
    mapView.addSubview(resetButton)
    NSLayoutConstraint.activate([
      resetButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -30),
      resetButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
      resetButton.heightAnchor.constraint(equalToConstant: 70),
      resetButton.widthAnchor.constraint(equalToConstant: 100)
    ])
  }
}
    
