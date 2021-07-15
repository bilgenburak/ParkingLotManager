//
//  MainVC.swift
//  ParkingLotManager
//
//  Created by Burak on 14.07.2021.
//

import UIKit
import CoreData

class MainVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var chosenIndex = Int()
    var chosenPlate : plateItem?
    
    var plates = [plateItem]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Parking Lot"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(createBill))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getData()
        NotificationCenter.default.addObserver(self, selector: #selector(removedItem), name: NSNotification.Name(rawValue: "remove"), object: nil)
    }
    
    func getData() {
        plates.removeAll(keepingCapacity: false)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Customers")
        fetchRequest.returnsObjectsAsFaults = false
        
        do {
            let results = try context.fetch(fetchRequest)
            if results.count > 0 {
                for result in results as! [NSManagedObject] {
                    if let plateStr = result.value(forKey: "plate") as? String {
                        if let plateID = result.value(forKey: "id") as? UUID {
                            self.plates.append(plateItem.init(id: plateID, plate: plateStr))
                        }
                    }
                    self.collectionView.reloadData()
                }
            }
        } catch {
            print(error)
        }
        
        if plates.count == 0 {
            plates.append(plateItem.init(id: UUID(), plate: "Park is empty!"))
            self.collectionView.reloadData()
        }
    }
    
    @objc func removedItem() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Customers")
        let removedID = chosenPlate?.carID
        
        fetchRequest.predicate = NSPredicate(format: "id = %@", removedID! as CVarArg)
        fetchRequest.returnsObjectsAsFaults = false
        
        do {
            let results = try context.fetch(fetchRequest)
            for result in results as! [NSManagedObject] {
                if let plateStr = result.value(forKey: "plate") {
                    if let plateID = result.value(forKey: "id") {
                        if chosenPlate?.carID == plateID as? UUID && chosenPlate?.carPlate == plateStr as? String {
                            context.delete(result)
                            plates.remove(at: chosenIndex)
                            self.collectionView.reloadData()
                            do {
                                try context.save()
                            } catch {
                                print(error)
                            }
                            break
                        }
                    }
                }
            }
        } catch {
        print(error)
        }
        displayAlert(title: "Success", message: "Item has removed from list.")
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return plates.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let plate = plates[indexPath.row]
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "plateCell", for: indexPath) as? ItemCollectionVC {
            cell.cellLabel.text = plate.carPlate
            return cell
        } else {
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        chosenPlate = plates[indexPath.row]
        chosenIndex = indexPath.row
        setBill()
    }
    
    @objc func setBill() {
        performSegue(withIdentifier: "toCustomerBill", sender: nil)
    }
    
    @objc func createBill() {
        performSegue(withIdentifier: "toNewCustomer", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toCustomerBill" {
            let destinationVC = segue.destination as! CustomerBillVC
            destinationVC.chosenCar = chosenPlate
        }
    }
    
    func displayAlert(title: String, message: String){
        DispatchQueue.main.async {
            let alert = UIAlertController(title: String.init(describing: title), message: String.init(describing: message), preferredStyle: UIAlertController.Style.actionSheet)
            let cancelAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
}
