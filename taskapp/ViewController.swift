//
//  ViewController.swift
//  taskapp
//
//  Created by MTBS049 on 2024/01/15.
//

import UIKit
import RealmSwift


class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var pluscount:Bool = true
    var cheaknewlogin = true
    var sorttask:Bool = false
    var pickerView: UIPickerView!
    
    
    var categoryArray:[Category] = []
    var list:[String] = []
    var duplicatelist:[String] = []
    var filteredItems: [String] = []
    var isPicker = ""
    var taskorder = 0
    
    @IBOutlet weak var sortPulldown: UITextField!
    @IBAction func sortButton(_ sender: Any) {
        if sortPulldown.text != ""{
            let sortArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: true).filter("type.categorydata == %@",isPicker)
            self.taskArray = sortArray
            print(sortArray)
        }else{
            let sortArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: true)
             self.taskArray = sortArray
        }
        sorttask = true
        tableView.reloadData()
        dismissKeyboard()
    }
    @IBAction func sortcancelButton(_ sender: Any) {
       let sortArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: true)
        self.taskArray = sortArray
        print(sortArray)
        sorttask = true
        tableView.reloadData()
        self.sortPulldown.text = ""
       dismissKeyboard()
    }
    
    @IBOutlet weak var updownButton: UIBarButtonItem!
    
    //登録した日付順　0:task完了日、1:昇順、2:降順
    @IBAction func updown(_ sender: Any) {
        
        if taskorder == 0{
         taskArray = self.taskArray.sorted(byKeyPath: "adddate", ascending: true)
           // taskArray = orderArray
            tableView.reloadData()
            taskorder = 1
        }else if taskorder == 1{
            let orderArray = self.taskArray.sorted(byKeyPath: "adddate", ascending: false)
            taskArray = orderArray
            tableView.reloadData()
            taskorder = 2
        }else if taskorder == 2{
            let orderArray = self.taskArray.sorted(byKeyPath: "date", ascending: true)
            taskArray = orderArray
            tableView.reloadData()
            taskorder = 0
        }
        
    }

    //inputViewに移動
    @IBAction func taskPlus(_ sender: Any) {
        dismissKeyboard()

    }

    //categoryViewに移動
    @IBAction func categoryPuls(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let nextVC =  storyboard.instantiateViewController(withIdentifier: "Categoryboard") as! categoryViewController
        nextVC.backedView = true
        navigationController?.pushViewController(nextVC, animated: true)
        dismissKeyboard()

    }

    // Realmインスタンスを取得する
       let realm = try! Realm()  // ←追加
       let category = Category()
       // DB内のタスクが格納されるリスト。
       // 日付の近い順でソート：昇順
       // 以降内容をアップデートするとリスト内は自動的に更新される。
     var taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: true)  // ←追加
   
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){

            if segue.identifier == "cellSegue" {
                let inputViewController:InputViewController = segue.destination as! InputViewController
                let indexPath = self.tableView.indexPathForSelectedRow
                inputViewController.task = taskArray[indexPath!.row]
                inputViewController.updataTask = true
                
            } else {
                let inputViewController:InputViewController = segue.destination as! InputViewController
                inputViewController.task = Task()
                
            }
        
        
    }
    
    
    
    // 入力画面から戻ってきた時に TableView を更新させる
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            tableView.reloadData()

              list = [""]
              
              let results = try! Realm().objects(Category.self)
              categoryArray = Array(results)
                      
              for category in categoryArray {
                  list.append(category.categorydata)
                      
           //       list = Array(Set(duplicatelist))
              }
            
              //カテゴリーリスト　プルダウン
              filteredItems = list
           //   print(filteredItems)
              sortPulldown.reloadInputViews()
            dismissKeyboard()
            self.taskorder = 0
                    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "TableViewCell", bundle: nil), forCellReuseIdentifier: "TableViewCell")
        
        // Do any additional setup after loading the view.
        tableView.fillerRowHeight = UITableView.automaticDimension
        tableView.delegate = self
        tableView.dataSource = self
        
        


        if UserDefaults.standard.object(forKey: "cheaknewlogin") != nil {
            self.cheaknewlogin = UserDefaults.standard.object(forKey: "cheaknewlogin") as! Bool
                }
                
                // 初期設定
                if cheaknewlogin {
                    try! realm.write{
                        self.category.categorydata = "未設定"
                        self.realm.add(category)
                    }
                    
                    self.cheaknewlogin = false
                    UserDefaults.standard.set(self.cheaknewlogin, forKey: "cheaknewlogin")
                }else{
                    print("already login")
                }
        
        //puldown sortbox
        let results = try! Realm().objects(Category.self)
        categoryArray = Array(results)
        
        for category in categoryArray {
             list.append(category.categorydata)
           // list = Array(Set(duplicatelist))
         
        }
        //カテゴリーリスト　プルダウン
        filteredItems = list
                pickerView = UIPickerView()
                pickerView.delegate = self
                pickerView.dataSource = self
        pickerView.reloadInputViews()
        textFieldChanged(sortPulldown)
        print()
    
        sortPulldown.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        
        self.sortPulldown.inputView = pickerView
        
        self.sortPulldown.layer.borderWidth = 1.0
        
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGesture)
        
    }
 
    @IBAction func unwind(_ segue: UIStoryboardSegue) {
      }
    

    // データの数（＝セルの数）を返すメソッド
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      
            return taskArray.count
    }

    // 各セルの内容を返すメソッド
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
       
        if let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell") as? TableViewCell {
            
            // 再利用可能な cell を得る
            
           
                let task = taskArray[indexPath.row]
                
                cell.titleLabel?.text = task.title
                
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd HH:mm"
                
                let dateString:String = formatter.string(from: task.date)
                cell.dateLabel?.text = dateString
                
                cell.categoryLabel?.text = task.type?.categorydata
                
            return cell }
        return UITableViewCell()
        
    }

    // 各セルを選択した時に実行されるメソッド
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "cellSegue", sender: nil)
    }

    // セルが削除が可能なことを伝えるメソッド
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath)-> UITableViewCell.EditingStyle {
        return .delete
    }

    // Delete ボタンが押された時に呼ばれるメソッド
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            
            let task = self.taskArray[indexPath.row]
            
            let center = UNUserNotificationCenter.current()
            center.removePendingNotificationRequests(withIdentifiers: [String(task.id.stringValue)])
            
            try! realm.write{
            self.realm.delete(self.taskArray[indexPath.row])
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            center.getPendingNotificationRequests { (requests: [UNNotificationRequest]) in
                for request in requests {
                    print("/---------------")
                    print(request)
                    print("---------------/")
                }
            }
            
        }
    }
    
    
    @objc func dismissKeyboard(){
               // キーボードを閉じる
               view.endEditing(true)
           }
    
    //プルダウン設定
    @objc func textFieldChanged(_ sortPulldown: UITextField) {
        self.sortPulldown.text = ""
        if sortPulldown.text == ""{
            filteredItems = list
            print("deforut")
            print(self.filteredItems)
        }
        else if let text = sortPulldown.text {
            filteredItems = list.filter { $0.lowercased().hasPrefix(text.lowercased())
                   }
            print("sort")
            print(self.filteredItems)
            
           }
        
       }
    
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        
        self.sortPulldown.text = ""
      self.sortPulldown.text = list[row]
        isPicker = sortPulldown.text!
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
    
}
