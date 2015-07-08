//
// Iconset.swift
// Icns Composer
// https://github.com/behoernchen/IcnsComposer
//
// The MIT License (MIT)
//
// Copyright (c) 2015 Raphael Hanneken
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.


import Cocoa

class Iconset {
    
    /// Holds the necessary images to create an iconset that conforms iconutil
    var images: [String : NSImage] = [:]
    
    
    
    /// Adds an image to the images dictionary.
    ///
    /// :param: img  Image object to add to the array
    /// :param: size Size of the given image, e.g. 512x512@2x
    func addImage(img: NSImage, ofSize size: String) {
        self.images[size] = img
    }
    
    /// Saves an *.icns file with images from self.images
    ///
    /// :param: url Path to the directory, where to save the icns file.
    func saveIcnsToURL(url: NSURL?) {
        // Unwrap the given url.
        if let url = url {
            // Get the temporary directory for the current user and append the choosen iconset name + .iconset
            let tmpURL = NSURL(fileURLWithPath: NSTemporaryDirectory() + url.lastPathComponent! + ".iconset", isDirectory: true)
            
            // Build the iconset.
            if self.writeIconsetToURL(tmpURL) {
                // Create the *.icns file.
                self.runIconUtilWithInput(tmpURL, andOutputURL: url)
            }
            
            // Open the working directory.
            NSWorkspace.sharedWorkspace().openURL(url.URLByDeletingLastPathComponent!)
        }
    }
    
    
    /// Saves the resized images as *.iconset to the given URL.
    /// 
    /// :param: url Path to the directory, where to save the iconset.
    /// 
    /// :returns: True on success
    func writeIconsetToURL(url: NSURL?) -> Bool {
        // Unwrap the given url.
        if let url = url {
            // Create the iconset directory, if not already existent.
            NSFileManager.defaultManager().createDirectoryAtURL(url, withIntermediateDirectories: true, attributes: nil, error: nil)
            
            // For each image in the dictionary...
            for (size, image) in self.images {
                // ...append the appropriate file name to the given url,...
                let imgURL = url.URLByAppendingPathComponent("icon_\(size).png", isDirectory: false)
                
                // ...create a png representation and...
                let pngRep = image.PNGRepresentation()
                
                // ...write the png file to the HD.
                if let png = pngRep {
                    png.writeToURL(imgURL, atomically: true)
                }
            }
            
            return true
        }
        
        return false
    }
    
    
    /// Runs iconutil with the given url as input path.
    /// 
    /// :param: url Path to a convertable iconset directory.
    /// :param: url Path to the location, where to save the generated icns file.
    func runIconUtilWithInput(input: NSURL?, andOutputURL output: NSURL?) {
        // Unwrap the optional url.
        if let input = input, let output = output {
            // Create a new task.
            let iconUtil = NSTask()
            
            // Append the .icns file extension to the output path.
            let outputPath = output.URLByAppendingPathExtension("icns")
            
            // Configure the NSTask and fire it up.
            iconUtil.launchPath = "/usr/bin/iconutil"
            iconUtil.arguments  = ["-c", "icns", "-o", outputPath, input.path!]
            iconUtil.launch()
            iconUtil.waitUntilExit()
            
            // Delete the .iconset
            NSFileManager.defaultManager().removeItemAtURL(input, error: nil)
        }
    }
}
