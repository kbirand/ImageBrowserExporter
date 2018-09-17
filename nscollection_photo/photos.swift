//
//  photos.swift
//  nscollection_photo
//
//  Created by Koray Birand on 22.08.2018.
//  Copyright © 2018 Koray Birand. All rights reserved.
//

import Cocoa

class photos: NSCollectionViewItem {
    
    let selectedBorderThickness: CGFloat = 0
    let selectedBGColor : CGColor = NSColor(calibratedRed: 0, green: 0, blue: 0, alpha: 0.1).cgColor
    
    override var isSelected: Bool {
        didSet {
            
            if isSelected {
                view.layer?.borderWidth = selectedBorderThickness
                view.layer?.backgroundColor = selectedBGColor
                
            } else {
                view.layer?.borderWidth = 0
                view.layer?.backgroundColor = NSColor.white.cgColor
            }
        }
    }
    
    override var highlightState: NSCollectionViewItem.HighlightState
        {
        didSet {
            if highlightState == .forSelection {
                view.layer?.borderWidth = selectedBorderThickness
                
            } else {
                if !isSelected {
                    view.layer?.borderWidth = 0
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.wantsLayer = true
        view.layer?.borderColor = NSColor.black.cgColor
    }
    
    override func viewDidLayout() {
        super.viewDidLayout()
        view.layer?.cornerRadius = 20
    }
    
}
