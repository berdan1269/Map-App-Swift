//
//  ViewController.swift
//  HaritalarUygulamasi
//
//  Created by Berdan on 19.04.2021.
//

import UIKit
import MapKit // map ayrı bir dünya oldugu için direkt connectlemek yetmiyor import edip classa eklemek gerekiyor
import CoreLocation // Kullanıcının konumunu alabilmek için gerekli kütüphane . Corelocation sınıfından oluşturulmuş objeler gerekiyor

import CoreData

class MapsViewController: UIViewController , MKMapViewDelegate,CLLocationManagerDelegate{ // MKMapViewDelegate yi ekledik
    
    
    @IBOutlet weak var isimTextField: UITextField!
    @IBOutlet weak var notTextField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    
    
    var locationManager = CLLocationManager() // Konum Yöneticisi Oluşturuyoruz.
    //enlem ve boylam için değişkenler oluşturuyoruz
    
    var secilenLatitude = Double()
    var secilenLongitude = Double()
    // bunları konum seç fonksiyonundan alıyoruz dokundugumuz noktanın oldugu kısım konumsec fonksiyonu
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
        mapView.delegate = self //Delegate,bir nesnenin programda karşılaştığı bir olay sonrasında gorevini farklı bir nesneye devredebilmesini sağlar.
        
        locationManager.delegate = self // konum yöneticisin,nden delegasyonunu view controllera veriyoruz .Hata veriyor classlara eklememiz gerekiyor delegasyonlarda genelde öyle
        
        locationManager.desiredAccuracy /*doğruluk ayarı */ = kCLLocationAccuracyBest
        // kullanıcıdan konumu kullanabilmek için izin almamız gerekiyor
        // locationManager.requestLocation() ->
        //                .requestAlwaysAthorization() ->Her zaman izin ver
        //                .requestWhenUseAthorization() ->Kullanılırken izin ver // genelde kullanılan.
        
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation() // konumu güncellemeye basla
        
        
        
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(konumSec(gestureRecognizer :))) // uzun basmak pin için gesturerecognizer oluşturduk.
        // oluşturduk bunu mapviewe eklmemiz gerekiyor
        
        gestureRecognizer.minimumPressDuration = 3   // kac saniye bastıgında algılasın
        mapView.addGestureRecognizer(gestureRecognizer)
        
    }
    
    @objc func konumSec(gestureRecognizer : UILongPressGestureRecognizer) {  //gestureRecongnizer için selector method , bu methodun içindede gestureRecognizere ulaşmak istiyoruz oyüzden paremetre veriyoruz
        
        if gestureRecognizer.state == .began{
            
            let dokunulanNokta = gestureRecognizer.location(in: mapView) // dokunulan npokta map viewa
            // şimdi dokunulan noktayı koordinata cevirmemiz gerekiyor
            
            let dokunulanKoordinat = mapView.convert(dokunulanNokta,toCoordinateFrom : mapView) // dokunulan noktayı koordinata ceviriyoruz
            
            // ve annotation a ekiyoruz buna annotation deniliyo artık bununla birlikte pin oluşuyor ve title subtitle bilgileri gözüküyor fakat burda default sekilde verdik .
            let annotation = MKPointAnnotation()
            annotation.coordinate = dokunulanKoordinat
            annotation.title = isimTextField.text
            annotation.subtitle = notTextField.text
            mapView.addAnnotation(annotation)
            
            
            
            // enlem ve boylamı alıcaz coredata için
            
            secilenLatitude = dokunulanKoordinat.latitude
            secilenLongitude = dokunulanKoordinat.longitude
            // şimdi geri dönebiliriz coradatanın oldugu kısıma
       
            
        }
        
        
        
        
        
    }
    
    
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // konum güncellendikten sonra konum alındı fonksiyonu ,   didUpdateLocations  locations adında bir dizi oluşturur ve odizinin içinde koordinat bilgileri bulunur. bizde bunu kullanarak koordinatlara erişebiliyoruz
        
        
        //print(locations[0].coordinate.latitude) // enlem ve boylamı bu şekilde alırız görebiliriz.
        //print(locations[0].coordinate.longitude)
        //print etmemiz gerekmiyor şimdi  konum oluşturalım
        let location = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude) // location oluşturduk bizden 2 paremetre istedi ve istedigi paremetreler briaz önce print ettigimiz paremetlereler latitude ve longitude istiyor onuda didUpdateLocations fonksiyonu sayesinde alıyoruz
        
        
        // konumu mapviewde açabilmek için setRegion fonksiyonunu kullanıyoruz ama bu bizden region istiyor oyüzden ilk once region oluşturuyoruz.
      
        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1) // sanırım zoomlamakla alaklı bir şey //öyleymiş ilk açılıştaki zoom seviyesini belirler .
        
        // oluşturdugumuz spanı regionda kullabiliriz artık
        
        let region = MKCoordinateRegion(center: location, span: span) // regionda bizden span istiyor span oluşturuyourz.yukarıda
        
        mapView.setRegion(region, animated: true)
        
        // şuan konum alınıyor ve ilgili konum açılıyor .
        
    }
    
    //ARTIK JESTLERİ KULLANARAK PİN OLUŞTURMA İŞLEMİNE GEÇEBİLİRİZ. (SECİLEN KONUMA PİN OLUŞTURMA) // OYÜZDEN YUKARDA GESTURE OLUŞTURUYPURZ
    
    


    @IBAction func kaydetButton(_ sender: Any) {
        
        // CoreData yı kullanarak veritabanımıza kaydeticez . Core Data için adımlarmız
        // ilk olarak contexte ulaşmaya çalışıyoruz
        let appDelegate  = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        //tabi coredata yı import etmeyi unutmuyoruz
        let yeniYer = NSEntityDescription.insertNewObject(forEntityName: "Yer", into: context) //oluşturdugumuz veri tabanının adı ve oluşturdugumuz contexti parametre olarak alıyor .
        //artık yeniyeri kullanmaya baslıyabiliriz. ve değerleri kaydedebiliriz.
        
        yeniYer.setValue(isimTextField.text, forKey: "isim")
        yeniYer.setValue(notTextField.text, forKey: "not")
        // şimdi enlemve boylamı eklememiz gerekiyor onun için yukarıda enlem ve boylamı değişken oluşturacagız
        yeniYer.setValue(secilenLatitude, forKey: "latitude")
        yeniYer.setValue(secilenLongitude, forKey: "longitude")
        yeniYer.setValue(UUID(), forKey: "id")
        
        // verileri yerleştirdik şimdi contexte save yapmamız gerekioyr
        
        do{
            
            try context.save()
            print("kayıt edildi")
            
        }catch {
            print("hata")
             
            
        }
        
        
        
        
    }
    
    
    
}

