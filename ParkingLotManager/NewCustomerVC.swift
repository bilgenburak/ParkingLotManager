//
//  NewCustomerVC.swift
//  ParkingLotManager
//
//  Created by Burak on 6.07.2021.
//

import UIKit
import Vision
import CoreData

class NewCustomerVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var sourcePicker: UISegmentedControl!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var detectedValueLabel: UILabel!
    @IBOutlet weak var selectPhotoOutlet: UIButton!
    @IBOutlet weak var finishButtonOutlet: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "New Customer"
        navigationController?.navigationBar.prefersLargeTitles = true
        selectPhotoOutlet.layer.cornerRadius = 15
        finishButtonOutlet.layer.cornerRadius = 15
    }
    
    @IBAction func selectPhoto(_ sender: UIButton) {
        selectPhoto()
    }
    
    @objc func selectPhoto() {
        let picker = UIImagePickerController()
        picker.delegate = self
        if sourcePicker.selectedSegmentIndex == 0 {
            picker.sourceType = .camera
        } else {
            picker.sourceType = .photoLibrary
        }
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.editedImage] as? UIImage
        self.dismiss(animated: true, completion: nil)
        finishButtonOutlet.isUserInteractionEnabled = true
        finishButtonOutlet.backgroundColor = .systemGreen
        
        guard let cgImage = imageView.image?.cgImage else {
            return
        }
        
        let handler = VNImageRequestHandler(cgImage: cgImage , options: [:])
        let request = VNRecognizeTextRequest { request, error in
            guard let observations = request.results as? [VNRecognizedTextObservation],
                error == nil else {
                return
            }
            let text = observations.compactMap({
                $0.topCandidates(1).first?.string
            }).joined()
            DispatchQueue.main.async {
                self.detectedValueLabel.text = text
            }
        }
        do {
            try handler.perform([request])
        } catch {
            print(error)
        }
    }
    
    @IBAction func finishButton(_ sender: UIButton) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let save = NSEntityDescription.insertNewObject(forEntityName: "Customers", into: context)

        do {
            if detectedValueLabel.text != "" {
                save.setValue(detectedValueLabel.text, forKey: "plate")
                save.setValue(UUID(), forKey: "id")
                try context.save()
                displayAlert(title: "Success", message: "Item has added to the list.")
            } else {
                displayAlert(title: "Error", message: "Couldn't recognize the license plate, please try again.")
            }
        } catch {
            print(error)
        }
    }
    
    func displayAlert(title: String, message: String){
        DispatchQueue.main.async {
            let alert = UIAlertController(title: String.init(describing: title), message: String.init(describing: message), preferredStyle: UIAlertController.Style.actionSheet)
            if title == "Success" {
                let cancelAction = UIAlertAction(title: "OK", style: .default) { alert in
                    self.navigationController?.popViewController(animated: true)
                }
                alert.addAction(cancelAction)
            } else if title == "Error" {
                let cancelAction = UIAlertAction(title: "OK", style: .cancel) { alert in

                }
                alert.addAction(cancelAction)
            }
            self.present(alert, animated: true)
        }
    }
}
