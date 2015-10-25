//
//  KanbanObjects.swift
//  Kanban Redux
//
//  Created by Aaron Stockdill on 25/10/15.
//  Copyright © 2015 Aaron Stockdill. All rights reserved.
//

import Foundation

class Task {
    let id: Int
    var title: String
    var description: String
    var tags: [String]
    var collection: Collection
    
    init(withTitle title: String, withDescription description: String, inCollection collection: Collection, withTags tags: [String]) {
        self.title = title
        self.description = description
        self.collection = collection
        self.id = collection.new_id()
        self.tags = tags
    }
    
    convenience init(withTitle title: String, withDescription description: String, inCollection collection: Collection) {
        self.init(withTitle: title, withDescription: description, inCollection: collection, withTags: [])
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


class Collection {
    let id: Int
    var title: String
    var tasks: [Task]
    var board: Board
    
    init(withTitle title: String, inBoard board: Board, withTasks tasks: [Task]) {
        self.board = board
        self.title = title
        self.id = board.new_id()
        self.tasks = tasks
    }
    
    convenience init(withTitle title: String, inBoard board: Board) {
        self.init(withTitle: title, inBoard: board, withTasks: [])
    }
    
    func new_id() -> Int {
        return self.board.new_id()
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


class Board {
    let id: Int
    var title: String
    var collections: [Collection]
    var next_id: Int = 0
    
    init(withTitle title: String, withId id: Int, withCollections collections: [Collection]) {
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
    
    convenience init(withTitle title: String, withId id: Int) {
        self.init(withTitle: title, withId: id, withCollections: [])
    }
    
    func new_id() -> Int {
        self.next_id += 1
        return self.next_id - 1
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


class KanbanStateController {
    var boards: [Board] = []
    var next_id: Int = 0;
    
    func new_board(withTitle title: String) {
        let the_board = Board(withTitle: title, withId: self.next_id)
        self.boards.append(the_board)
        self.next_id++
    }
    
    func xml() -> String {
        var xml: String = "<?xml version='1.0'?><kanban>"
        for board in self.boards {
            xml += board.xml()
        }
        xml += "</kanban>"
        return xml
    }
    
    func new_collection(withTitle title: String, onBoard board: Board) {
        let new_collection = Collection(withTitle: title, inBoard: board)
        board.collections.append(new_collection)
    }
    
    func new_task(withTitle title: String, withDescription description: String, inCollection collection: Collection, withTags tags: [String]) {
        let new_task = Task(withTitle: title, withDescription: description, inCollection: collection, withTags: tags)
        collection.tasks.append(new_task)
    }
    
}
