//
//  settings.swift
//  nscollection_photo
//
//  Created by Koray Birand on 28.08.2018.
//  Copyright © 2018 Koray Birand. All rights reserved.
//

import Cocoa

class settings: NSViewController,NSTextFieldDelegate {
    @IBOutlet weak var maxWidthT: NSTextField!
    @IBOutlet weak var maxHeightT: NSTextField!
    @IBOutlet weak var compValueT: NSSlider!
    @IBOutlet weak var cropHeightT: NSTextField!
    
    
    
    
    @IBAction func saveSettings(_ sender: Any) {
        let mW = Int(maxWidthT.stringValue)
        let mH = Int(maxHeightT.stringValue)
        let compression : Double = compValueT.doubleValue / 10.0
        let cH = Int(cropHeightT.stringValue)
        UserDefaults.standard.set(mW, forKey: "maxWidth")
        UserDefaults.standard.set(mH, forKey: "maxHeight")
        UserDefaults.standard.set(compression, forKey: "compression")
         UserDefaults.standard.set(cH, forKey: "cropHeight")
        maxWidth = Int(maxWidthT.stringValue)
        maxHeight = Int(maxHeightT.stringValue)
        compressionValue = compValueT.doubleValue / 10.0
        cropHeight = Int(cropHeightT.stringValue)
        self.dismiss(self)
    }
    
    override func controlTextDidChange(_ obj: Notification) {
        let characterSet: NSCharacterSet = NSCharacterSet(charactersIn: "0123456789").inverted as NSCharacterSet
        maxHeightT.stringValue =  (maxHeightT.stringValue.components(separatedBy: characterSet as CharacterSet) as NSArray).componentsJoined(by: "")
        maxWidthT.stringValue =  (maxWidthT.stringValue.components(separatedBy: characterSet as CharacterSet) as NSArray).componentsJoined(by: "")
        cropHeightT.stringValue = (cropHeightT.stringValue.components(separatedBy: characterSet as CharacterSet) as NSArray).componentsJoined(by: "")
    }
    
    override func viewDidAppear() {
        // any additional code
        view.window!.styleMask.remove(.resizable)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        maxHeightT.stringValue = String(UserDefaults.standard.integer(forKey: "maxHeight"))
        maxWidthT.stringValue = String(UserDefaults.standard.integer(forKey: "maxWidth"))
        compValueT.doubleValue = UserDefaults.standard.double(forKey: "compression") * 10.0
        cropHeightT.stringValue = String(UserDefaults.standard.integer(forKey: "cropHeight"))
        print(UserDefaults.standard.double(forKey: "compression"))
        
        
        maxHeightT.delegate = self
        maxHeightT.delegate = self
        cropHeightT.delegate = self
        // Do view setup here.
    }
    
}
