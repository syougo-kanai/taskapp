//
//  Task.swift
//  taskapp
//
//  Created by MTBS049 on 2024/01/16.
//

import Foundation
import RealmSwift

class Task: Object {
    
    //管理用　ID プライマーキー
    @Persisted(primaryKey: true) var id: ObjectId
    
    //タイトル
    @Persisted var title = ""
    
    //内容
    @Persisted var contents = ""
    
    //日時
    @Persisted var date = Date()
    
    @Persisted var type:Category?
    
}

class Category: Object{
    @Persisted(primaryKey: true) var iD: ObjectId
    
    @Persisted var categorydata = ""
    }



