//
//  CustomerBillVC.swift
//  ParkingLotManager
//
//  Created by Burak on 14.07.2021.
//

import UIKit
import CoreData

class CustomerBillVC: UIViewController {

    @IBOutlet weak var elapsedTimeTXT: UITextField!
    @IBOutlet weak var totalValueLabel: UILabel!
    @IBOutlet weak var cancelButtonOutlet: UIButton!
    @IBOutlet weak var finishButtonOutlet: UIButton!
    @IBOutlet weak var carPlate: UILabel!
    
    var chosenCar : plateItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Customer Bill"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        carPlate.text = chosenCar?.carPlate
        
        cancelButtonOutlet.layer.cornerRadius = 15
        finishButtonOutlet.layer.cornerRadius = 15
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(closeKeyboard))
        view.addGestureRecognizer(gestureRecognizer)
    }
    
    @objc func closeKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func cancelButton(_ sender: UIButton) {
        let hour = elapsedTimeTXT.text! as String
        let totalValue = (hour as NSString).integerValue * 15
        if elapsedTimeTXT.text != "" && elapsedTimeTXT.text != "0" && elapsedTimeTXT.text?.isEmpty == false {
                totalValueLabel.text = "$" + String(totalValue)
                finishButtonOutlet.isUserInteractionEnabled = true
                finishButtonOutlet.backgroundColor = UIColor.systemGreen
            }
    }
    
    @IBAction func finishButton(_ sender: UIButton) {
        NotificationCenter.default.post(name: NSNotification.Name("remove"), object: nil)
        self.navigationController?.popViewController(animated: true)
    }
}
