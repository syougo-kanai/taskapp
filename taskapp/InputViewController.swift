//
//  InputViewController.swift
//  taskapp
//
//  Created by MTBS049 on 2024/01/15.
//

import UIKit
import RealmSwift
import UserNotifications

class InputViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
  

    var list:[String] = []
    var filteredItems: [String] = []
        
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentsTextView: UITextView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var categoryPickerfeild: UITextField!
    
    var isWorte:Bool = false
    var categorycount:Bool = true
    @IBAction func addcategory(_ sender: Any) {
        categorycount = false
    }
    @IBAction func addtask(_ sender: Any) {
        categorycount = true
    }
    let realm = try! Realm()    // 追加する
    var task: Task!
    var category: Category!
    var isPicker = ""
   
    
    var categoryArray:[Category] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let results = try! Realm().objects(Category.self)
        categoryArray = Array(results)
        
        print(categoryArray)
        
        for category in categoryArray {
            list.append(category.categorydata)
        }
        
        //カテゴリーリスト　プルダウン
        filteredItems = list
                let pickerView = UIPickerView()
                pickerView.delegate = self
                pickerView.dataSource = self
        
        categoryPickerfeild.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)

        self.categoryPickerfeild.inputView = pickerView
        titleTextField.layer.borderWidth = 1.0
        contentsTextView.layer.borderWidth = 1.0
      
        //背景をタップしたらdismissKeyboardメソッドを呼ぶように設定する
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)

        isPicker = categoryPickerfeild.text!
        print("pickup!\(isPicker)")
        titleTextField.text = task.title
        contentsTextView.text = task.contents
        datePicker.date = task.date
     //   categoryPickerfeild.text = category.categorydata
        
        
        // Do any additional setup after loading the view.
    }
    override func viewWillDisappear(_ animated: Bool) {
        
        if isWorte == true {
              //  let categorytask = realm.object(ofType:Category.self ,forPrimaryKey:isPicker)
            
         //       self.task.title = self.titleTextField.text!
        //    self.task.contents = self.contentsTextView.text!
         //   self.task.date = self.datePicker.date
            
         //   categorytask!.substance.append(self.task)
            
         //   print(categorytask!)
            print("cheak\(isPicker)")
            
            try! realm.write {

                
           self.task.title = self.titleTextField.text!
            self.task.contents = self.contentsTextView.text
            self.task.date = self.datePicker.date
                
                self.task.type?.categorydata = isPicker
                self.realm.add(self.task, update: .modified)
   
        }
        
        setNotification(task: task)
        
        super.viewWillDisappear(animated)
        
        func setNotification(task: Task){
            
            if categorycount == true {
                let content = UNMutableNotificationContent()
                
                if task.title == "" {
                    content.title = "(タイトルなし)"
                } else {
                    content.title = task.title
                }
                if task.contents == "" {
                    content.body = "(内容なし)"
                } else {
                    content.body = task.contents
                }
                content.sound = UNNotificationSound.default
                let calender = Calendar.current
                let dateComponents = calender.dateComponents([.year, .month, .day, .hour, .minute], from: task.date)
                let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
                
                let request = UNNotificationRequest(identifier: String(task.id.stringValue), content: content, trigger: trigger)
                
                let center = UNUserNotificationCenter.current()
                center.add(request){ (error) in
                    print(error ?? "ローカル通信登録　OK")
                }
                
                center.getPendingNotificationRequests{( requests: [UNNotificationRequest]) in
                    for request in requests {
                        print("/-----------")
                        print(request)
                        print("-----------/")
                    }
                }
                
            }
        }
    }
    }
    
    @IBAction func tourokuButton(_ sender: Any) {
        isWorte = true
    }
    @objc func dismissKeyboard(){
               // キーボードを閉じる
               view.endEditing(true)
           }
    //プルダウン設定
    @objc func textFieldChanged(_ categoryPickerfeild: UITextField) {
        if categoryPickerfeild.text == ""{
            filteredItems = list
        }
        else if let text = categoryPickerfeild.text {
               filteredItems = list.filter { $0.lowercased().contains(text.lowercased())
                   
               }
           }
  
       }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
      self.categoryPickerfeild.text = list[row]
    //   print(000)
    //    print(categoryPickerfeild.text!)
        isPicker = categoryPickerfeild.text!
        print("pickup!\(isPicker)")
    }
       func numberOfComponents(in pickerView: UIPickerView) -> Int {
           return 1
       }

       func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
           return filteredItems.count
       }

       func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
           return filteredItems[row]
       }
    //==================================================-
}
