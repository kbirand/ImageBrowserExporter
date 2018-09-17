//
//  MainWindowController.swift
//  nscollection_photo
//
//  Created by Koray Birand on 26.08.2018.
//  Copyright © 2018 Koray Birand. All rights reserved.
//

import Cocoa

class MainWindowController: NSWindowController {
    @IBAction func export(_ sender: Any) {
        let name = Notification.Name(rawValue: "exportImages")
        NotificationCenter.default.post(name: name, object: nil)
    }
    @IBAction func settings(_ sender: Any) {
        let name = Notification.Name(rawValue: "settings")
        NotificationCenter.default.post(name: name, object: nil)
    }
    
    @IBAction func exportCropped(_ sender: Any) {
        let name = Notification.Name(rawValue: "exportCropped")
        NotificationCenter.default.post(name: name, object: nil)
    }
    
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
        self.windowFrameAutosaveName = NSWindow.FrameAutosaveName.init(rawValue: "position")
    }
    
    override func awakeFromNib() {
        
        //window?.titleVisibility = .hidden
        //window?.titlebarAppearsTransparent = true
        window?.isMovableByWindowBackground = true
        
    }

}
