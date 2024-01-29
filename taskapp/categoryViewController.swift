//
//  categoryViewController.swift
//  taskapp
//
//  Created by MTBS049 on 2024/01/18.
//

import UIKit
import RealmSwift

class categoryViewController: UIViewController {

    let realm = try! Realm()
   
    @IBOutlet weak var Setcategory: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
        
    
    @IBAction func Addcategorybutton(_ sender: Any) {
        
        let category = Category()
        
        category.categorydata = self.Setcategory.text!
       
        try! realm.write {
            self.realm.add(category)
        }
        let results = realm.objects(Category.self)
        print(results)
        
    }
    @objc func Add(){
        
    }
    
    }



