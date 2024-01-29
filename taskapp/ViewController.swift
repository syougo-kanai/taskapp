//
//  ViewController.swift
//  taskapp
//
//  Created by MTBS049 on 2024/01/15.
//

import UIKit
import RealmSwift

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    
    var pluscount:Bool = true
    var cheaknewlogin = true
    
    @IBAction func taskPlus(_ sender: Any) {
       
    }
    @IBAction func categoryPuls(_ sender: Any) {
       
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
          
        let nextVC =  storyboard.instantiateViewController(withIdentifier: "Categoryboard") as! categoryViewController
        
        navigationController?.pushViewController(nextVC, animated: true)
        //nextVC.category = Category()
    }
    
    
    // Realmインスタンスを取得する
       let realm = try! Realm()  // ←追加
       let category = Category()
       // DB内のタスクが格納されるリスト。
       // 日付の近い順でソート：昇順
       // 以降内容をアップデートするとリスト内は自動的に更新される。
       var taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: true)  // ←追加
   
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        
      //  if pluscount == true {
            let inputViewController:InputViewController = segue.destination as! InputViewController
            
            if segue.identifier == "cellSegue" {
                let indexPath = self.tableView.indexPathForSelectedRow
                inputViewController.task = taskArray[indexPath!.row]
                
            } else {
                inputViewController.task = Task()
            }
       // }
    }
    

    
    // 入力画面から戻ってきた時に TableView を更新させる
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            tableView.reloadData()

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
                
                // チュートリアルを出す
                if cheaknewlogin {
                    try! realm.write{
                        self.category.categorydata = "未設定"
                        self.realm.add(category)
                    }
                    print(category)
                    print("OK")
                    
                    self.cheaknewlogin = false
                    UserDefaults.standard.set(self.cheaknewlogin, forKey: "cheaknewlogin")
                }else{
                    print("already login")
                }
        
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
            //     let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            
            let task = taskArray[indexPath.row]
           
            cell.titleLabel?.text = task.title
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm"
            
            let dateString:String = formatter.string(from: task.date)
            cell.dateLabel?.text = dateString
            
         print(taskArray)
            
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
}
