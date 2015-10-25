//
//  ViewController.swift
//  Kanban Redux
//
//  Created by Aaron Stockdill on 25/10/15.
//  Copyright © 2015 Aaron Stockdill. All rights reserved.
//

import Cocoa

class KanbanViewController: NSViewController {
    var ad =  NSApplication.sharedApplication().delegate as! AppDelegate
}

class ViewController: KanbanViewController {
    
    @IBOutlet var textbox: NSTextFieldCell!
    
    @IBAction func showXML(sender: AnyObject) {
        let xml_output = ad.kb_controller.xml()
        textbox.title = xml_output
    }
    
    // ------- Board Creation ----------

    lazy var boardNameController: NSViewController = {
        return self.storyboard!.instantiateControllerWithIdentifier("BoardCreator")
            as! NSViewController
    }()
    
    @IBAction func new_board(sender: AnyObject) {
        self.presentViewControllerAsSheet(boardNameController)
    }

    // ------- Collection Creation ----------
    
    lazy var collectionNameController: NSViewController = {
        return self.storyboard!.instantiateControllerWithIdentifier("CollectionCreator")
            as! NSViewController
    }()
    
    @IBAction func new_collection(sender: AnyObject) {
        self.presentViewControllerAsSheet(collectionNameController)
    }
    
    // ------- Task Creation ----------
    
    lazy var taskNameController: NSViewController = {
        return self.storyboard!.instantiateControllerWithIdentifier("TaskCreator")
            as! NSViewController
    }()
    
    @IBAction func new_task(sender: AnyObject) {
        self.presentViewControllerAsSheet(taskNameController)
    }
    
}


class BoardSheetViewController: KanbanViewController {
    
    @IBOutlet weak var board_name_box: NSTextFieldCell!
    
    @IBAction func get_new_board_details(sender: AnyObject) {
        let board_name = board_name_box.title
        ad.kb_controller.new_board(withTitle: board_name)
        self.dismissController(self)
    }
}


class CollectionSheetViewController: KanbanViewController {
    
    @IBOutlet weak var collection_name_box: NSTextFieldCell!
    @IBOutlet weak var collection_board_selector: NSPopUpButton!
    
    override func viewDidLoad() {
        var i: Int = 0
        var items: [String] = []
        for board in ad.kb_controller.boards {
            items.append(board.title)
            i++
        }
        self.collection_board_selector.removeAllItems()
        self.collection_board_selector.addItemsWithTitles(items)
        self.collection_board_selector.selectItemAtIndex(0)
    }
    
    override func viewWillAppear() {
        self.viewDidLoad()
    }
    
    @IBAction func get_new_collection_details(sender: AnyObject) {
        let collection_name = collection_name_box.title
        let board_number = collection_board_selector.indexOfSelectedItem
        let board = ad.kb_controller.boards[board_number]
        ad.kb_controller.new_collection(withTitle: collection_name, onBoard: board)
        self.dismissController(self)
    }

}


class TaskSheetViewController: KanbanViewController {
    
    @IBOutlet weak var task_name_box: NSTextFieldCell!
    @IBOutlet weak var task_description_box: NSTextFieldCell!
    @IBOutlet weak var task_tags_box: NSTokenFieldCell!
    @IBOutlet weak var task_board_selector: NSPopUpButton!
    @IBOutlet weak var task_collection_selector: NSPopUpButton!
    
    override func viewDidLoad() {
        var i: Int = 0
        var board_names: [String] = []
        for board in ad.kb_controller.boards {
            board_names.append(board.title)
            i++
        }
        self.task_board_selector.removeAllItems()
        self.task_board_selector.addItemsWithTitles(board_names)
        self.task_board_selector.selectItemAtIndex(0)
        
        self.set_available_collections(self)
    }
    
    override func viewWillAppear() {
        self.viewDidLoad()
    }
    
    @IBAction func set_available_collections(sender: AnyObject) {
        let board_number = task_board_selector.indexOfSelectedItem
        var collection_names: [String] = []
        var i: Int = 0
        for collection in ad.kb_controller.boards[board_number].collections {
            collection_names.append(collection.title)
            i++
        }
        self.task_collection_selector.enabled = true
        self.task_collection_selector.removeAllItems()
        self.task_collection_selector.addItemsWithTitles(collection_names)
        self.task_collection_selector.selectItemAtIndex(0)
    }
    
    @IBAction func get_new_task_details(sender: AnyObject) {
        let task_name = task_name_box.title
        let task_description = task_description_box.title
        let task_tags: [String] = task_tags_box.title.componentsSeparatedByString(",").map{
            str in
            str.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        }
        
        let board_number = task_board_selector.indexOfSelectedItem
        let board = ad.kb_controller.boards[board_number]
        let collection_number = task_collection_selector.indexOfSelectedItem
        let collection = board.collections[collection_number]
        
        ad.kb_controller.new_task(withTitle: task_name, withDescription: task_description, inCollection: collection, withTags: task_tags)
        self.dismissController(self)
    }
    
}

