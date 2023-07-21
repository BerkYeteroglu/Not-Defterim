//
//  ViewController.swift
//  NotDefterimApp
//
//  Created by Berk Yeteroğlu on 16.07.2023.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    
    var baslikDizisi = [String]()
    var idDizisi = [UUID]()
    var secilenBaslik = ""
    var secilenId : UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonTapped))
        navigationItem.rightBarButtonItem = addButton
        
        tableView.dataSource = self
        tableView.delegate = self
        verileriAl()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(verileriAl), name: NSNotification.Name(rawValue: "veriGirildi"), object: nil)
    }
    
    @objc func addButtonTapped(){
        secilenBaslik = ""
        performSegue(withIdentifier: "toDetailsVC", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return baslikDizisi.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = baslikDizisi[indexPath.row]
        return cell
    }
    
    @objc func verileriAl(){
        
        baslikDizisi.removeAll(keepingCapacity: false)
        idDizisi.removeAll(keepingCapacity: false)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let fatchReq = NSFetchRequest<NSFetchRequestResult>(entityName: "Notlarim")
        
        fatchReq.returnsObjectsAsFaults = false
        
        do{
            let sonuclar = try context.fetch(fatchReq)
            if sonuclar.count > 0{
                for sonuc in sonuclar as! [NSManagedObject]{
                    if let baslik = sonuc.value(forKey: "baslik") as? String{
                        baslikDizisi.append(baslik)
                    }
                    if let id = sonuc.value(forKey: "id") as? UUID{
                        idDizisi.append(id)
                    }
                }
                tableView.reloadData()
            }
        }catch{
            fatalError("Hata")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetailsVC" {
            let destinationVC = segue.destination as! DetailsViewController
            destinationVC.secilenBaslik = secilenBaslik
            destinationVC.secilenId = secilenId
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        secilenBaslik = baslikDizisi[indexPath.row]
        secilenId = idDizisi[indexPath.row]
        performSegue(withIdentifier: "toDetailsVC", sender: nil)
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fecthReq = NSFetchRequest<NSFetchRequestResult>(entityName: "Notlarim")
            let uuidString = idDizisi[indexPath.row].uuidString
            
            fecthReq.predicate = NSPredicate(format: "id = %@", uuidString)
            fecthReq.returnsObjectsAsFaults = false
            
            do{
                let sonuclar = try context.fetch(fecthReq)
                if sonuclar.count > 0 {
                    for sonuc in sonuclar as! [NSManagedObject] {
                        if let id = sonuc.value(forKey: "id") as? UUID{
                            if id == idDizisi[indexPath.row]{
                                context.delete(sonuc)
                                baslikDizisi.remove(at: indexPath.row)
                                idDizisi.remove(at: indexPath.row)
                                
                                self.tableView.reloadData()
                                do {
                                    try context.save()
                                }catch{
                                    fatalError("güncelleme işlemi başarılı olunamadı")
                                }
                                break
                            }
                        }
                    }
                }
            }catch{
                
            }
        }
    }
}

