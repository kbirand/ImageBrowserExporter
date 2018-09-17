//
//  Koray.swift
//  Koray Birand Archive
//
//  Created by Koray Birand on 11/02/16.
//  Copyright © 2016 rock. All rights reserved.
//

import Foundation
import Cocoa
import Quartz

extension NSOpenPanel {
    var selectUrlOpen: URL? {
        title = "Select Folder"
        allowsMultipleSelection = false
        canChooseDirectories = true
        canChooseFiles = false
        canCreateDirectories = true
        //allowedFileTypes = ["mov","mp4"]  // to allow only images, just comment out this line to allow any file type to be selected
        return runModal() == .OK ? urls.first : nil
    }
}

extension NSSavePanel {
    var selectUrlSave: URL? {
        title = "Select Folder and Name"
        nameFieldStringValue = "newname.jpg"
        canCreateDirectories = true
        return runModal() == .OK ? url : nil
    }
}

extension NSImage {
    
    public func write(to url: URL, fileType type: NSBitmapImageRep.FileType = .jpeg, compressionFactor: NSNumber = 1.0) {
        // https://stackoverflow.com/a/45042611/3882644
        guard let data = tiffRepresentation else { return }
        guard let imageRep = NSBitmapImageRep(data: data) else { return }
        
        guard let imageData = imageRep.representation(using: type, properties: [.compressionFactor: compressionFactor]) else { return }
        try? imageData.write(to: url)
    }
}

class koray {
    
    class func resizeImage(_ imagePath:URL, max: NSSize, targetPath:URL, compressionFactor: NSNumber) {
        
        let data = NSData(contentsOf: imagePath)
        let imageView = NSImage(data: data! as Data)
        let rep = NSBitmapImageRep(data: data! as Data)
        var newWidth : Float = 0.0
        var newHeight : Float = 0.0
        
        var ratio: Float = 0.0
        let imageWidth = Float((rep?.pixelsWide)!)
        let imageHeight = Float((rep?.pixelsHigh)!)
        let maxWidth = Float(max.width)
        let maxHeight = Float(max.height)
        
        print("func resizeImage //// maxWidth: \(maxWidth) maxheight: \(maxHeight) ")
        
        if imageWidth > imageHeight {
            ratio = imageWidth / imageHeight
        } else {
            ratio = imageHeight / imageWidth
        }
        
        
        if imageWidth > imageHeight {
            newWidth = maxHeight * ratio
            newHeight = maxHeight
        } else {
            newWidth = maxHeight / ratio
            newHeight = maxHeight
        }
        
        print("func resizeImage //// newWidth: \(newWidth) newHeight: \(newHeight) ")
        
        let newSize : NSSize = NSSize(width: Int(newWidth), height: Int(newHeight))
        
        let target = NSImage(size: newSize)
        let targetRect = NSMakeRect(0, 0, newSize.width, newSize.height)

        let sourceSize = imageView!.size
        let sourceRect = NSMakeRect(0,0,sourceSize.width,sourceSize.height)

        target.lockFocus()
        imageView!.draw(in: targetRect, from: sourceRect, operation: .copy, fraction: 1.0)
        target.unlockFocus()

        if let TIFFrepresentation = target.tiffRepresentation {

            let imageRepresentation = NSBitmapImageRep(data: TIFFrepresentation)
            let properties = [NSBitmapImageRep.PropertyKey.compressionFactor:NSNumber(value: compressionValue)]
            let imageRep2 = imageRepresentation?.converting(to: NSColorSpace.sRGB, renderingIntent: NSColorRenderingIntent.perceptual)

            let data = imageRep2!.representation(using: .jpeg, properties: properties)
            try? data!.write(to: URL(fileURLWithPath: targetPath.path), options:  NSData.WritingOptions.atomic)

        }
        
//        if let bitmapRep = NSBitmapImageRep(
//            bitmapDataPlanes: nil, pixelsWide: Int(newSize.width), pixelsHigh: Int(newSize.height),
//            bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
//            colorSpaceName: .calibratedRGB, bytesPerRow: 0, bitsPerPixel: 0
//            ) {
//            bitmapRep.size = newSize
//            NSGraphicsContext.saveGraphicsState()
//            NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: bitmapRep)
//            imageView?.draw(in: NSRect(x: 0, y: 0, width: newSize.width, height: newSize.height), from: .zero, operation: .copy, fraction: 1.0)
//            NSGraphicsContext.restoreGraphicsState()
//            let xFactor = NSScreen.main?.backingScaleFactor
//            print("backingScaleFactor:  \(xFactor ?? 0)")
//            let resizedImage = NSImage(size: newSize)
//            resizedImage.addRepresentation(bitmapRep)
//            resizedImage.write(to: targetPath, fileType: .jpeg, compressionFactor: NSNumber(value: compressionValue))
////            if let TIFFrepresentation = resizedImage.tiffRepresentation {
////                let properties = [NSBitmapImageRep.PropertyKey.compressionFactor:NSNumber(value: compressionValue)]
////                let imageRepresentation = NSBitmapImageRep(data: TIFFrepresentation)
////                let imageRep2 = imageRepresentation?.converting(to: NSColorSpace.sRGB, renderingIntent: NSColorRenderingIntent.perceptual)
////                let data = imageRep2!.representation(using: .jpeg, properties: properties)
////                try? data!.write(to: targetPath, options:  NSData.WritingOptions.atomic)
////
////            }
//        }
    }
    
    
    
    class func folderPanel() -> URL {
        var getURL : URL!
        if let url = NSOpenPanel().selectUrlOpen {
            getURL =  url
        }
        return getURL
    }
    
    class func saveToFolder () -> URL {
        
        var getURL : URL!
        if let url = NSSavePanel().selectUrlSave {
            getURL =  url
        }
        return getURL
        
    }
    
    
    
    class func leftString(_ theString: String, charToGet: Int) ->String{
        
        var indexCount = 0
        let strLen = theString.count
        
        if charToGet > strLen { indexCount = strLen } else { indexCount = charToGet }
        if charToGet < 0 { indexCount = 0 }
        
        let index: String.Index = theString.index(theString.startIndex, offsetBy: indexCount)
        let mySubstring:String = String(theString[..<index])
        return mySubstring }
    
    class func rightString(_ theString: String, charToGet: Int) ->String{
        
        var indexCount = 0
        let strLen = theString.count
        let charToSkip = strLen - charToGet
        
        if charToSkip > strLen { indexCount = strLen } else { indexCount = charToSkip }
        if charToSkip < 0 { indexCount = 0 }
        let index: String.Index = theString.index(theString.startIndex, offsetBy: indexCount)
        let mySubstring:String = String(theString[index...])
        
        
        return mySubstring
    }
    
    class func midString(_ theString: String, startPos: Int, charToGet: Int) ->String{
        
        let strLen = theString.count
        let rightCharCount = strLen - startPos
        var mySubstring = koray.rightString(theString, charToGet: rightCharCount)
        mySubstring = koray.leftString(mySubstring, charToGet: charToGet)
        return mySubstring
        
    }
    
    class func splitToArray ( theString: String) -> [[String]] {
        var newArray = [[String]]()
        let a = theString.components(separatedBy: "\n")
        for elements in a  {
            let c = elements.components(separatedBy: ",")
            newArray.append(c)
        }
        
        return newArray
        
    }
    
    
    
    class func listFolderFiltered (urlPath: URL, filterExt: String) -> [String] {
        var newArray = [String]()
        
        let fm = FileManager.default
        do {
            let items = try fm.contentsOfDirectory(at: urlPath, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
            
            
            for item in items {
                
                if item.pathExtension.lowercased() == filterExt  {
                    newArray.append(item.path)
                }
            }
        } catch {
            // failed to read directory – bad permissions, perhaps?
        }
        
        let ascending = newArray.sorted { (a, b) -> Bool in
            return b > a
        }
        
        
        return ascending
    }
    
    class func listFolderFilteredWithDate(urlPath: URL, filterExt: String) -> [[String]] {
        var newArray = [[String]]()
        var attribs = [FileAttributeKey : Any]()
        
        
        let fm = FileManager.default
        do {
            let items = try fm.contentsOfDirectory(at: urlPath, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
            
            
            for item in items {
                
                if item.pathExtension.lowercased() == filterExt  {
                    //print(item.path)
                    do {
                        attribs = try FileManager.default.attributesOfItem(atPath: item.path)
                        //                        print(attribs)
                    }
                    catch
                    {
                        print(error)
                    }
                    newArray.append([item.lastPathComponent,item.path,(attribs[FileAttributeKey.creationDate] as! NSDate).description])
                }
            }
        } catch {
            
        }
        
        let ascending = newArray.sorted { $0[0] < $1[0] }
        
        
        return ascending
    }
    
    
    
    class func getCsvContent(myPath: String) -> [[String]] {
        
        var array : [[String]]!
        
        do {
            let koko = try String(contentsOfFile: myPath)
            array = koray.splitToArray(theString: koko)
            
        }
        catch {}
        
        return array
        
    }
    
    class func changeDate(newDate: String, filePath: String) {
        
        let convertedDate = koray.convertDate(stringDate: newDate)
        print("convertedDate\(convertedDate)")
        
        let attributes = [FileAttributeKey.creationDate: convertedDate]
        let attributes2 = [FileAttributeKey.modificationDate: convertedDate]
        do {
            try FileManager.default.setAttributes(attributes as Any as! [FileAttributeKey : Any], ofItemAtPath: filePath)
        }
        catch
        {
            print(error)
        }
        
        do {
            try FileManager.default.setAttributes(attributes2 as Any as! [FileAttributeKey : Any], ofItemAtPath: filePath)
        }
        catch
        {
            print(error)
        }
        
        
    }
    
    class func convertDate (stringDate: String) -> Date {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss xx"
        guard let datem = dateFormatter.date(from: stringDate) else {
            fatalError("ERROR: Date conversion failed due to mismatched format.")
        }
        
        return datem
    }
    
    
    
    
    
}

