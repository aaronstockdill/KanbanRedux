//
//  KanbanObjects.swift
//  Kanban Redux
//
//  Created by Aaron Stockdill on 25/10/15.
//  Copyright © 2015 Aaron Stockdill. All rights reserved.
//

import Foundation

// A useful little string multiplier
func * (left: String, right: Int) -> String {
    var result = ""
    for _ in 0..<right {
        result += left
    }
    return result
}

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
        xml += "<tasktitle>\(self.title)</tasktitle>"
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
        xml += "<collectiontitle>\(self.title)</collectiontitle>"
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
        xml += "<boardtitle>\(self.title)</boardtitle>"
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
 * An XML parser that converts the files into Kanban Boards.
 */
class KanbanParser: NSObject, NSXMLParserDelegate {
    
    var boards: [Board] = []
    var currentBoard: Board? = nil
    var currentCollection: Collection? = nil
    var currentTask: Task? = nil
    var expectingString: Bool = false
    var lastString = ""
    
    // Handle opening tags by creating the new objects.
    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        if elementName == "board" {
            currentBoard = Board(withId: Int((attributeDict["id"]! as String))!, withTitle: "placeholder")
        } else if elementName == "collection" {
            currentCollection = Collection(withId: Int((attributeDict["id"]! as String))!, withTitle: "placeholder", inBoard: currentBoard!)
        } else if elementName == "task" {
            currentTask = Task(withId: Int((attributeDict["id"]! as String))!, withTitle: "placeholder", withDescription: "placeholder", inCollection: currentCollection!)
        }
    }
    
    // Manage closing tags by tidying the objects.
    func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "board" {
            self.boards.append(currentBoard!)
            currentBoard = nil
        } else if elementName == "collection" {
            self.currentBoard!.collections.append(currentCollection!)
            currentCollection = nil
        } else if elementName == "task" {
            self.currentCollection!.tasks.append(currentTask!)
            currentTask = nil
        } else if elementName == "boardtitle" {
            self.currentBoard!.title = lastString
        } else if elementName == "collectiontitle" {
            self.currentCollection!.title = lastString
        } else if elementName == "tasktitle" {
            self.currentTask!.title = lastString
        } else if elementName == "description" {
            self.currentTask!.description = lastString
        }  else if elementName == "tag" {
            self.currentTask!.tags.append(lastString)
        }
    }
    
    // Store parsed strings for later use.
    func parser(parser: NSXMLParser, foundCharacters string: String) {
        lastString = string
    }
}

/*
 * Manage all the state of the Application's Kanban Boards
 */
class KanbanStateController: NSObject {
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
        let kb_parser = KanbanParser()
        let parser = NSXMLParser(data: xml.dataUsingEncoding(NSUTF8StringEncoding)!)
        parser.delegate = kb_parser
        parser.parse()
        self.boards = kb_parser.boards
        print(self.xml())
    }
    
}
