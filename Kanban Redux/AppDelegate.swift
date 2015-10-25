//
//  AppDelegate.swift
//  Kanban Redux
//
//  Created by Aaron Stockdill on 25/10/15.
//  Copyright © 2015 Aaron Stockdill. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    var kb_controller = KanbanStateController()

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
    
    func applicationShouldHandleReopen(sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if (flag) {
            return false
        } else {
            sender.windows[0].makeKeyAndOrderFront(sender)
            return true
        }
    }


}

