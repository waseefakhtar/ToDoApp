//
//  ViewController.swift
//  ToDoApp
//
//  Created by Waseef Akhtar on 7/27/17.
//  Copyright © 2017 Waseef Akhtar. All rights reserved.
//

import UIKit
import RealmSwift


class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var openTodos : Results<ToDoModel>!
    var currentCreateAction: UIAlertAction!
    
    var isEditingMode = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "ToDo"
        readTodosAndUpdateUI()
        
        // Locate Realm file in local directory.
        print(Realm.Configuration.defaultConfiguration.fileURL!)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        readTodosAndUpdateUI()

    }
    
    func readTodosAndUpdateUI(){
        
        openTodos = realm.objects(ToDoModel.self)
        self.tableView.setEditing(false, animated: true)
        
        self.tableView.reloadData()
    }
    
    @IBAction func didTapAdd(_ sender: Any) {
        
        displayAlertToAddTodo(nil)
    }
    
    func listNameFieldDidChange(_ textField:UITextField){
        self.currentCreateAction.isEnabled = (textField.text?.characters.count)! > 0
    }
    
    func displayAlertToAddTodo(_ updatedTodo: ToDoModel!){
        
        // Date format to String
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateString = formatter.string(from: Date())
        
        var title = "New Todo"
        var doneTitle = "Create"
        
        if updatedTodo != nil{
            title = "Update Todo"
            doneTitle = "Update"
        }
        
        let alertController = UIAlertController(title: title, message: "Enter your todo:", preferredStyle: UIAlertControllerStyle.alert)
        let createAction = UIAlertAction(title: doneTitle, style: UIAlertActionStyle.default) { (action) -> Void in
            
            let todoTitle = alertController.textFields?.first?.text
            let todoDetailText = alertController.textFields?[1].text
            let todoPriority = alertController.textFields?[2].text
            
            if updatedTodo != nil{
                // update mode
                try! realm.write{
                    updatedTodo.title = todoTitle!
                    updatedTodo.detailText = todoDetailText!
                    updatedTodo.timeStamp = dateString
                    updatedTodo.priority = todoPriority!
                    
                    self.readTodosAndUpdateUI()
                }
            }
            else{
                
                let newTodo = ToDoModel()
                newTodo.title = todoTitle!
                newTodo.detailText = todoDetailText!
                newTodo.timeStamp = dateString
                newTodo.priority = todoPriority!
                
                try! realm.write{
                    
                    self.openTodos.realm?.add(newTodo)
                    self.readTodosAndUpdateUI()
                }
            }
            
        }
        
        alertController.addAction(createAction)
        createAction.isEnabled = false
        self.currentCreateAction = createAction
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        
        alertController.addTextField { (textField) -> Void in
            textField.placeholder = "Title"
            textField.addTarget(self, action: #selector(ViewController.listNameFieldDidChange(_:)) , for: UIControlEvents.editingChanged)
            if updatedTodo != nil{
                textField.text = updatedTodo.title
            }
        }
        
        alertController.addTextField { (textField) -> Void in
            textField.placeholder = "Detail"
            textField.addTarget(self, action: #selector(ViewController.listNameFieldDidChange(_:)) , for: UIControlEvents.editingChanged)
            if updatedTodo != nil{
                textField.text = updatedTodo.detailText
            }
        }
        
        alertController.addTextField { (textField) -> Void in
            textField.placeholder = "Priority (0: Most Important, 2: Least Important)"
            textField.addTarget(self, action: #selector(ViewController.listNameFieldDidChange(_:)) , for: UIControlEvents.editingChanged)
            if updatedTodo != nil{
                textField.text = updatedTodo.priority
            }
        }
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func didTapEdit(_ sender: Any) {
        print("Edit Button Tapped.")
        
        isEditingMode = !isEditingMode
        self.tableView.setEditing(isEditingMode, animated: true)
    }
    
    @IBAction func sortTodos(_ sender: Any) {
        
        if (sender as AnyObject).selectedSegmentIndex == 0{
            
            // Sort by priority.
            self.openTodos = self.openTodos.sorted(byKeyPath: "priority")
            
            
        }
        else {
            // Sort by date.
            self.openTodos = self.openTodos.sorted(byKeyPath: "timeStamp", ascending:false)
        }
        self.tableView.reloadData()
    }
    
    
}

extension ViewController: UITableViewDelegate {

}

extension ViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return "TODOS"
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {            return openTodos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "cell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        
        var todo: ToDoModel!
    
        todo = openTodos[indexPath.row]
        
        
        cell.textLabel?.text = todo.title
        cell.detailTextLabel?.text = todo.detailText
        
        
        return cell
        
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let deleteAction = UITableViewRowAction(style: .default, title: "Delete") { (deleteAction, indexPath) -> Void in
            
            // Delete a Todo.
            var todoToBeDeleted: ToDoModel!

            todoToBeDeleted = self.openTodos[indexPath.row]
            
            try! realm.write{
                realm.delete(todoToBeDeleted)
                self.readTodosAndUpdateUI()
            }
        }
        let editAction = UITableViewRowAction(style: UITableViewRowActionStyle.normal, title: "Edit") { (editAction, indexPath) -> Void in
            
            // Edit a Todo.
            var todoToBeUpdated: ToDoModel!
            
            todoToBeUpdated = self.openTodos[indexPath.row]
            
            self.displayAlertToAddTodo(todoToBeUpdated)
            
        }
        
        return [deleteAction, editAction]
        
    }
    
    
}
