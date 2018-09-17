//
//  ViewController.swift
//  nscollection_photo
//
//  Created by Koray Birand on 22.08.2018.
//  Copyright © 2018 Koray Birand. All rights reserved.
//

import Cocoa
import Quartz

var maxHeight : Int!
var maxWidth : Int!
var cropHeight: Int!
var compressionValue : Double!

extension Array {
    
    mutating func moveItem(from: Int, to: Int) {
        
        let item = self[from]
        self.remove(at: from)
        
        if to <= from {
            self.insert(item, at: to)
        } else {
            self.insert(item, at: to - 1)
        }
    }
}

extension ViewController: QLPreviewPanelDataSource {
    
    func numberOfPreviewItems(in panel: QLPreviewPanel!) -> Int {
        return 1
    }
    
    override func beginPreviewPanelControl(_ panel: QLPreviewPanel!) {
        
        QLPreviewPanel.shared().dataSource = self
    }
    
    override func acceptsPreviewPanelControl(_ panel: QLPreviewPanel!) -> Bool {
        return true
    }
    
    override func endPreviewPanelControl(_ panel: QLPreviewPanel!) {
        panel.delegate = nil
        panel.dataSource = nil
    }
    
    func previewPanel(_ panel: QLPreviewPanel!, previewItemAt index: Int) -> QLPreviewItem! {
        print(index)
        return NSURL(fileURLWithPath: selected.path)
        
    }
}

extension ViewController : NSCollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: NSCollectionView,
                        layout collectionViewLayout: NSCollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> NSSize {
        return NSSize(width: CGFloat(mySliderCollectionViewItemSize.floatValue), height: CGFloat(mySliderCollectionViewItemSize.floatValue))
    }
}

class ViewController: NSViewController, NSCollectionViewDelegate, NSCollectionViewDataSource,ImageViewDelegate, NSSplitViewDelegate {
    
    func imageViewDidChangeImage(_ imageView: ImageView) {
        //print("\(Int(previewImage.image!.size.width)) x \(Int(previewImage.image!.size.height))")
        //print("fff")
    }
    
    func imageViewDidChangeSelection(_ imageView: ImageView) {
        
        if let selectionSize = previewImage.selectionSize() {
            
            print("\(Int(selectionSize.width)) x \(Int(selectionSize.height))")
            
            
        }
        
    }
    
    
    @IBOutlet weak var splitView: NSSplitView!
    @IBOutlet weak var previewImage: ImageView!
    @IBOutlet weak var mySliderCollectionViewItemSize: NSSlider!
    @IBOutlet weak var collectionView: NSCollectionView!
    
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    lazy var sheetViewController: NSViewController = {
        return self.storyboard!.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "settings"))
            as! NSViewController
    }()
    
    
    var previewPanel : QLPreviewPanel!
    var photos = [URL]()
    var itemsBeingDragged: Set<IndexPath>?
    var selected : URL!
    let kSpaceKeyCode:  UInt16  = 0x31
    let kDeleteKeyCode: UInt16  = 0x33
    
    
    lazy var photosDirectory: URL = {
        let fm = FileManager.default
        let paths = fm.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        let saveDirectory = documentsDirectory.appendingPathComponent("kb_nscollection")
        
        if !fm.fileExists(atPath: saveDirectory.path) {
            try? fm.createDirectory(at: saveDirectory, withIntermediateDirectories: true)
        }
        
        return saveDirectory
    }()
    
    
    @IBAction func resizeItems(_ sender: Any) {
        collectionView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createObservers()
        previewImage.delegate = self
        
        //print("func viewDidLoad //// newWidth: \(maxWidth) newHeight: \(maxHeight) ")
        
        if UserDefaults.standard.object(forKey: "maxWidth") == nil {
            UserDefaults.standard.set(15000, forKey: "maxWidth")
            print("mW Nil")
            maxWidth = 15000
        } else {
            maxWidth = UserDefaults.standard.integer(forKey: "maxWidth")
        }
        
        if UserDefaults.standard.object(forKey: "maxHeight") == nil {
            UserDefaults.standard.set(1500, forKey: "maxHeight")
            maxHeight = 1500
            print("mH Nil")
        } else {
            maxHeight = UserDefaults.standard.integer(forKey: "maxHeight")
        }
        
        if UserDefaults.standard.object(forKey: "compression") == nil {
            UserDefaults.standard.set(0.7, forKey: "compression")
            compressionValue = 0.7
            print("cP Nil")
        } else {
            compressionValue = UserDefaults.standard.double(forKey: "compression")
        }
        
        if UserDefaults.standard.object(forKey: "cropHeight") == nil {
            UserDefaults.standard.set(900, forKey: "cropHeight")
            cropHeight = 900
            print("cH Nil")
        } else {
            compressionValue = UserDefaults.standard.double(forKey: "compression")
        }
        
        //print("func viewDidLoad2 //// newWidth: \(maxWidth) newHeight: \(maxHeight) ")
        collectionView.registerForDraggedTypes([NSPasteboard.PasteboardType(rawValue: kUTTypeURL as String as String)])
        
        do {
            let fm = FileManager.default
            let files = try fm.contentsOfDirectory(at: photosDirectory, includingPropertiesForKeys: nil)
            
            for file in files {
                
                if file.pathExtension.lowercased() == "jpg" || file.pathExtension.lowercased() ==  "png" {
                    
                    photos.append(file)
                }
            }
        } catch {
            print("Set up error")
        }
        
        if photos.count != 0 {
            collectionView.selectItems(at: [IndexPath(item: 0, section: 0)], scrollPosition: NSCollectionView.ScrollPosition.top)
            previewImage.image = NSImage(contentsOf: photos[0])
            selected = photos[0]
            
        }
        
        NotificationCenter.default.addObserver(previewImage,
                                               selector: #selector(ImageView.windowWillResize),
                                               name: NSSplitView.willResizeSubviewsNotification,
                                               object: splitView)
        NotificationCenter.default.addObserver(previewImage,
                                               selector: #selector(ImageView.windowDidResize),
                                               name: NSSplitView.didResizeSubviewsNotification,
                                               object: splitView)
        
    }
    
    func createObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.exportImages), name: Notification.Name(rawValue: "exportImages"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.settings), name: Notification.Name(rawValue: "settings"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.exportCropped), name: Notification.Name(rawValue: "exportCropped"), object: nil)
        
    }
    
    @objc func settings() {
        self.presentViewControllerAsSheet(sheetViewController)
        
        
    }
    
    
    @objc func exportImages() {
        //let exporFolder = koray.folderPanel()
        let mainpath : URL = koray.saveToFolder()
        let finalPath = mainpath.deletingLastPathComponent()
        let newFileName = mainpath.deletingPathExtension().lastPathComponent
        
        var counter = 0
        
        //print("func exportImages //// newWidth: \(maxWidth) newHeight: \(maxHeight) ")
        
        for item in photos {
            
            counter = counter + 1
            let finalTarget = finalPath.path + "/" + newFileName + "_" + String(format: "%04d", counter) + ".jpg"
            let newtargetPath = URL(fileURLWithPath: finalTarget)
            print(newtargetPath.path)
            print(counter)
            //print("func exportImages //// newWidth: \(maxWidth!) newHeight: \(maxHeight!) ")
            koray.resizeImage(item, max: NSSize(width: maxWidth!, height: maxHeight!), targetPath: newtargetPath, compressionFactor: compressionValue! as NSNumber)
            //counter = counter + 1
        }
        
    }
    
    @objc func exportCropped() {
        //let coverfileT = tempFolder.stringByAppendingPathComponent("coverimage_t.jpg")
        if (previewImage.cropBox.size.height.isNaN) ||  (previewImage.cropBox.size.height == 0.0) {
            print("empty")
            return
        }
        
        let a = (previewImage.selectionSize()?.width)!
        let b = (previewImage.selectionSize()?.height)!
        
        let ratio = a / b
        
        let croppedSize = NSMakeSize(CGFloat(cropHeight), CGFloat(CGFloat(cropHeight)/ratio))
        
        let destinationFile = koray.saveToFolder()
        
        if let data = previewImage.croppedImageData(croppedSize, compression: Float(compressionValue)) {
            //print("saved file")
            try? data.write(to: URL(fileURLWithPath: destinationFile.path), options: NSData.WritingOptions.atomic)
        }
        
        
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let item = collectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "photos"), for: indexPath)
        guard let pictureItem = item as? photos else { return item }
        
        pictureItem.textField?.textColor = NSColor.black
        
        
        let imageMe = NSData(contentsOf: photos[indexPath.item])
        let bitmap: NSBitmapImageRep! = NSBitmapImageRep(data: imageMe! as Data)
        
        pictureItem.textField?.stringValue = "\(photos[indexPath.item].lastPathComponent)\n\(bitmap.pixelsWide) X \(bitmap.pixelsHigh)"
        
        let image = NSImage(data: imageMe! as Data)
        pictureItem.imageView?.image = image
        
        return pictureItem
    }
    
    func collectionView(_ collectionView: NSCollectionView, validateDrop draggingInfo: NSDraggingInfo, proposedIndexPath proposedDropIndexPath: AutoreleasingUnsafeMutablePointer<NSIndexPath>, dropOperation proposedDropOperation: UnsafeMutablePointer<NSCollectionView.DropOperation>) -> NSDragOperation {
        
        return .move
    }
    
    func collectionView(_ collectionView: NSCollectionView, draggingSession session: NSDraggingSession, willBeginAt screenPoint: NSPoint, forItemsAt indexPaths: Set<IndexPath>) {
        
        itemsBeingDragged = indexPaths
    }
    
    func collectionView(_ collectionView: NSCollectionView, draggingSession session: NSDraggingSession, endedAt screenPoint: NSPoint, dragOperation operation: NSDragOperation) {
        
        itemsBeingDragged = nil
    }
    
    func collectionView(_ collectionView: NSCollectionView, acceptDrop draggingInfo: NSDraggingInfo, indexPath: IndexPath, dropOperation: NSCollectionView.DropOperation) -> Bool {
        
        if let moveItems = itemsBeingDragged?.sorted() {
            
            //this is an internal drag
            performInternalDrag(with: moveItems, to: indexPath)
            
        } else {
            
            //this is an external drag
            let pasteboard = draggingInfo.draggingPasteboard()
            guard let items = pasteboard.pasteboardItems else { return true }
            
            performExternalDrag(with: items, at: indexPath)
        }
        
        return true
    }
    
    func collectionView(_ collectionView: NSCollectionView, pasteboardWriterForItemAt indexPath: IndexPath) -> NSPasteboardWriting? {
        
        return photos[indexPath.item] as NSPasteboardWriting?
    }
    
    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        previewImage.image = NSImage(contentsOf: photos[Array(indexPaths)[0][1]])
        selected = photos[Array(indexPaths)[0][1]]
        print(previewImage.calculateImageSize())
        
    }
    
    override func keyUp(with event: NSEvent) {
        
        //bail out if we dont have any selected items
        guard collectionView.selectionIndexPaths.count > 0 else { return }
        
        //convert the integer to a Unicode scalar, then to a string
        if event.charactersIgnoringModifiers == String(UnicodeScalar(NSDeleteCharacter)!) {
            
            let fm = FileManager.default
            
            //loop over the selected items in reverse sorted order
            for indexPath in collectionView.selectionIndexPaths.sorted().reversed() {
                
                do {
                    //move this item to the trash and remove it from the array
                    try fm.trashItem(at: photos[indexPath.item], resultingItemURL: nil)
                    photos.remove(at: indexPath.item)
                    previewImage.image = nil
                    
                } catch {
                    print("Failed to delete |(photos[indexPath.item])")
                }
            }
            //remove the items from the collection view
            collectionView.animator().deleteItems(at: collectionView.selectionIndexPaths)
            return
        }
        
        
        if (event.keyCode == 49){
            showQuickLookPreview(self)
            return
        }
        
    }
    
    func showQuickLookPreview(_ sender: AnyObject) {
        
        let panel = QLPreviewPanel.shared()
        
        if (QLPreviewPanel.sharedPreviewPanelExists() && (panel?.isVisible)!) {
            panel?.orderOut(self)
        } else {
            panel?.makeKeyAndOrderFront(self)
            panel?.reloadData()
        }
    }
    
    
    func performExternalDrag(with items: [NSPasteboardItem], at indexPath: IndexPath) {
        
        let fm = FileManager.default
        
        //1 - loop over every item on the drag and drop pasteboard
        for item in items {
            
            //2 - pull out the string containing the URL for this item
            guard let stringURL = item.string(forType: NSPasteboard.PasteboardType(rawValue: kUTTypeFileURL as String as String)) else { continue }
            
            //3 - attempt to convert the string into a real URL
            guard let sourceURL = URL(string: stringURL) else { continue }
            
            //4 - create a destination URL by combining photosDirectory with the last path component
            let destinationURL = photosDirectory.appendingPathComponent(sourceURL.lastPathComponent)
            
            do {
                //5 - attempt to copy the file to our app's folder
                try fm.copyItem(at: sourceURL, to: destinationURL)
                
            } catch {
                
                print("Could not copy \(sourceURL)")
            }
            
            //6 - update the array and collection view
            photos.insert(destinationURL, at: indexPath.item)
            collectionView.insertItems(at: [indexPath])
        }
    }
    
    
    func performInternalDrag(with items: [IndexPath], to indexPath: IndexPath) {
        
        //keep track of where we're moving to
        var targetIndex = indexPath.item
        
        for fromIndexPath in items {
            
            //figure out where we're moving from
            let fromItemIndex = fromIndexPath.item
            
            //this is a move towards the front of the array
            if (fromItemIndex > targetIndex) {
                
                //call our array extension to perform the move
                photos.moveItem(from: fromItemIndex, to: targetIndex)
                
                //move it in the collection view too
                collectionView.moveItem(at: IndexPath(item: fromItemIndex, section: 0), to: IndexPath(item: targetIndex, section: 0))
                
                //update our destination position
                targetIndex += 1
            }
        }
        //reset the target position - we want to move to the slot before the item the user chose
        targetIndex = indexPath.item - 1
        
        //loop backwards over our items
        for fromIndexPath in items.reversed() {
            let fromItemIndex = fromIndexPath.item
            
            //this is a move towards the back of the array
            if (fromItemIndex < targetIndex) {
                
                //call our array extension to perform the move
                photos.moveItem(from: fromItemIndex, to: targetIndex)
                
                //move it in the collection view too
                let targetIndexPath = IndexPath(item: targetIndex, section: 0)
                collectionView.moveItem(at: IndexPath(item: fromItemIndex, section: 0), to: targetIndexPath)
                
                //update our destination position
                targetIndex -= 1
            }
        }
    }
    
}

