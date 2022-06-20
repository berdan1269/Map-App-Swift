//
//  ListViewController.swift
//  HaritalarUygulamasi
//
//  Created by Berdan on 20.04.2021.
//

import UIKit
import CoreData  // verileri cekebilmek için core data kullanıcaz ve fetchrequest yaratıcaz


class ListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var isimDizisi = [String]()
    var idDizisi = [UUID]()
    
    var secilenYerIsmi = ""
    var secilenYerId : UUID? //TABLE VİEW İÇİN

    

    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    
        tableView.delegate = self
        tableView.dataSource = self
        
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(artiButtonuTiklandı)) //en üste + butonu yapmak icin
        
        veriAl()
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(veriAl), name: NSNotification.Name("yeniYerOlusturuldu"), object: nil)
    }
    
    
    @objc func veriAl(){
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Yer")
        request.returnsObjectsAsFaults = false // performans avantajı
        
        do{ // context.fetch bize sonucların oldugu bir dizi veriyordu,bu dizi içerisinde any dizisi veriyordu bizde onu nsmanaged object haline getirmeye calısıyoruduk
            let sonuclar  = try context.fetch(request)
            
            if sonuclar.count > 0 {
                
                
                isimDizisi.removeAll(keepingCapacity: false)
                idDizisi.removeAll(keepingCapacity: false)
                
                
                for sonuc in sonuclar  as! [NSManagedObject] {
                    // artık sonuc.value diyerek istedigim veriyi cekebilirim
                    
                    if let isim = sonuc.value(forKey: "isim") as? String {// buda bize bir any veriyor cünkü nsmanagedobject bir any veriyor
                        
                        isimDizisi.append(isim)
                        
                    }
                    
                    if let id = sonuc.value(forKey: "id") as? UUID{
                        
                        idDizisi.append(id)
                        
                        
                    }
                    
                    
                }
                
                tableView.reloadData() // tableviewi yeniliyoruz.
                
            }
            
             
            
        } catch {
            print("hata")
        }
        
        
        
    }
    
    
    
    
    
    
    
    @objc func artiButtonuTiklandı() {
        secilenYerIsmi = "" // secilenyer ismi boş kalsın ki artıya basıldıgında diğer tarafta elseye girsin yani veri eklenecegi anlasılısın .
        performSegue(withIdentifier: "toMapsVC", sender: nil)
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        return isimDizisi.count
        
        
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
    
        let cell = UITableViewCell()
        
        cell.textLabel?.text = isimDizisi[indexPath.row]
        
        return cell
        
    
    }
    
    
    // diğer vc ye verileri göndermek için
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            
        secilenYerIsmi = isimDizisi[indexPath.row]
        secilenYerId = idDizisi[indexPath.row]
        
        
        performSegue(withIdentifier: "toMapsVC", sender: nil)
    
    
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "toMapsVC" {
            
            let destinationVC = segue.destination as!  MapsViewController
            destinationVC.secilenIsim = secilenYerIsmi
            destinationVC.secilenId = secilenYerId
            
            
        }
        
        
    }
    
    
    
    
    

    

}
