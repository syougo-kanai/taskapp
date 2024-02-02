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
    
    var backedView:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGesture)
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
        
        if backedView == false {
            self.navigationController?.popViewController(animated: true)
            
        }else {
            dismissKeyboard()
        }
    }
    
    @objc func dismissKeyboard(){
               // キーボードを閉じる
               view.endEditing(true)
           }
    
    @objc func Add(){
        
    }
    
    }



