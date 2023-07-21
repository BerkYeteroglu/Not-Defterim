//
//  DetailsViewController.swift
//  NotDefterimApp
//
//  Created by Berk Yeteroğlu on 16.07.2023.
//

import UIKit
import CoreData

class DetailsViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {

    @IBOutlet weak var baslik: UITextField!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var notlar: UITextView!
    @IBOutlet weak var kaydetButton: UIButton!
    var secilenBaslik = ""
    var secilenId : UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if secilenBaslik != ""{
            kaydetButton.isHidden = true
            if let uuidString = secilenId?.uuidString{
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                let context = appDelegate.persistentContainer.viewContext
                
                let fetchReq = NSFetchRequest<NSFetchRequestResult>(entityName: "Notlarim")
                fetchReq.predicate = NSPredicate(format: "id = %@", uuidString)
                fetchReq.returnsObjectsAsFaults = false
                
                do{
                    let sonuclar = try context.fetch(fetchReq)
                    
                    if sonuclar.count > 0 {
                        for sonuc in sonuclar as! [NSManagedObject]{
                            if let basligim = sonuc.value(forKey: "baslik") as? String{
                                baslik.text = basligim
                            }
                            if let notum = sonuc.value(forKey: "not") as? String{
                                notlar.text = notum
                            }
                            if let gorselData = sonuc.value(forKey: "image") as? Data{
                                let imagem = UIImage(data: gorselData)
                                image.image = imagem
                            }
                        }
                    }
                }catch{
                    fatalError("Error")
                }
            }
        }else{
            kaydetButton.isHidden = false
            kaydetButton.isEnabled = false
            baslik.text = ""
            notlar.text = "Notunuzu Girin:"
        }
        
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        
        let imageGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        image.addGestureRecognizer(imageGesture)
        image.isUserInteractionEnabled = true
    }
    
    @objc func imageTapped() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }

    
    @objc func dismissKeyboard(){
        view.endEditing(true)
    }
    
    @IBAction func katdetButton(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let notDefterim = NSEntityDescription.insertNewObject(forEntityName: "Notlarim", into: context)
        
        notDefterim.setValue(baslik.text!, forKey: "baslik")
        notDefterim.setValue(notlar.text!, forKey: "not")
        notDefterim.setValue(UUID(), forKey: "id")
        
        let data = image.image?.jpegData(compressionQuality: 0.5)
        notDefterim.setValue(data, forKey: "image")
        do{
            try context.save()
            print("Kayıt işlemi tamam")
        }catch{
            fatalError("Sıkıntı")
        }
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "veriGirildi"), object: nil)
        self.navigationController?.popViewController(animated: true)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        image.image = info[.originalImage] as? UIImage
        kaydetButton.isEnabled = true
        
        dismiss(animated: true, completion: nil)
    }
}

