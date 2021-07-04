//
//  AdressFormAllertController.swift
//  Navigator
//
//  Created by Александр Тимофеев on 04.07.2021.
//

import UIKit

extension UIViewController {
  
  func alertAddAdress(title: String, placeholder: String, completitionHandler: @escaping(String) -> Void) {
    
    let alertController = UIAlertController(title: title, message: nil, preferredStyle: .alert)
    
    let alertOkButton = UIAlertAction(title: "OK", style: .default) { (action) in
      let userText = alertController.textFields?.first
      guard let text = userText?.text else { return }
      completitionHandler(text)
    }
    
    let alertCancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
    
    alertController.addTextField { (textField) in
      textField.placeholder = placeholder
    }
    
    alertController.addAction(alertOkButton)
    alertController.addAction(alertCancelButton)
    
    present(alertController, animated: true, completion: nil)
  }
  
  func alertError(title: String, message: String) {
    
    let alertController = UIAlertController(title: "Ошибка", message: "Произошла ошибка, попробуйте еще раз", preferredStyle: .alert)
    let alertOkButton = UIAlertAction(title: "OK", style: .default, handler: nil)
    
    alertController.addAction(alertOkButton)
    
    present(alertController, animated: true, completion: nil)
  }
  
}


