//
//  KanbanObjects.swift
//  Kanban Redux
//
//  Created by Aaron Stockdill on 25/10/15.
//  Copyright © 2015 Aaron Stockdill. All rights reserved.
//

import Foundation

/*
 * Task is the model of what a task is, inside a given collection.
 */
class Task {
    let id: Int
    var title: String
    var description: String
    var tags: [String]
    var collection: Collection
    
    init(withId id: Int, withTitle title: String, withDescription description: String, inCollection collection: Collection, withTags tags: [String]) {
        self.title = title
        self.description = description
        self.collection = collection
        self.id = id
        self.tags = tags
    }
    
    convenience init(withId id: Int, withTitle title: String, withDescription description: String, inCollection collection: Collection) {
        self.init(withId: id, withTitle: title, withDescription: description, inCollection: collection, withTags: [])
    }
    
    func xml() -> String {
        var xml: String = "<task id='\(self.id)'>"
        xml += "<title>\(self.title)</title>"
        xml += "<description>\(self.description)</description>"
        xml += "<taglist>"
        for tag in self.tags {
            xml += "<tag>\(tag)</tag>"
        }
        xml += "</taglist>"
        xml += "</task>"
        return xml
    }
}

/*
 * Collection holds some tasks on a certain board.
 */
class Collection {
    let id: Int
    var title: String
    var tasks: [Task]
    var board: Board
    
    init(withId id: Int, withTitle title: String, inBoard board: Board, withTasks tasks: [Task]) {
        self.board = board
        self.title = title
        self.id = id
        self.tasks = tasks
    }
    
    convenience init(withId id: Int, withTitle title: String, inBoard board: Board) {
        self.init(withId: id, withTitle: title, inBoard: board, withTasks: [])
    }
    
    func xml() -> String {
        var xml: String = "<collection id='\(self.id)'>"
        xml += "<title>\(self.title)</title>"
        xml += "<tasklist>"
        for task in self.tasks {
            xml += task.xml()
        }
        xml += "</tasklist>"
        xml += "</collection>"
        return xml
    }
}

/*
 * A board contains some collections which have some tasks.
 */
class Board {
    let id: Int
    var title: String
    var collections: [Collection]
    var next_id: Int = 0
    
    init(withId id: Int, withTitle title: String, withCollections collections: [Collection]) {
        self.title = title
        self.collections = []
        self.collections = collections
        for collection in collections {
            self.next_id = max(self.next_id, collection.id)
            for task in collection.tasks {
                self.next_id = max(self.next_id, task.id)
            }
        }
        self.id = id
    }
    
    convenience init(withId id: Int, withTitle title: String) {
        self.init(withId: id, withTitle: title, withCollections: [])
    }
    
    func xml() -> String {
        var xml: String = "<board id='\(self.id)'>"
        xml += "<title>\(self.title)</title>"
        xml += "<collectionlist>"
        for collection in self.collections {
            xml += collection.xml()
        }
        xml += "</collectionlist>"
        xml += "</board>"
        return xml
    }
}

/*
 * Manage all the state of the Application's Kanban Boards
 */
class KanbanStateController {
    var boards: [Board] = []
    var next_id: Int = 0;
    
    func new_id() -> Int {
        let id = next_id
        next_id++
        return id
    }
    
    func new_board(withTitle title: String) {
        let the_board = Board(withId: self.new_id(), withTitle: title)
        self.boards.append(the_board)
    }
    
    func new_collection(withTitle title: String, onBoard board: Board) {
        let new_collection = Collection(withId: self.new_id(), withTitle: title, inBoard: board)
        board.collections.append(new_collection)
    }
    
    func new_task(withTitle title: String, withDescription description: String, inCollection collection: Collection, withTags tags: [String]) {
        let new_task = Task(withId: self.new_id(), withTitle: title, withDescription: description, inCollection: collection, withTags: tags)
        collection.tasks.append(new_task)
    }
    
    func xml() -> String {
        var xml: String = "<?xml version='1.0'?><kanban>"
        for board in self.boards {
            xml += board.xml()
        }
        xml += "</kanban>"
        return xml
    }
    
    func create_from_xml(xml: String) {
        
    }
    
    func _parse_board(xml: String) {
        
    }
    
    func _parse_collection(xml: String, board: Board) {
        
    }
    
    func _parse_task(xml: String, collection: Collection) {
        
    }
    
    func _parse_tags(xml: String, task: Task) {
        
    }
    
}
