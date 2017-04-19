
//
//  ViewController.swift
//  TouchbarFireworks
//
//  Created by Anthony Da Mota on 08/11/2016.
//  Copyright © 2016 Anthony Da Mota. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    @IBOutlet weak var scannerCheckbox: NSButton!
    @IBOutlet weak var kittCar: NSImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.wantsLayer = true
        
        kittCar.image = NSImage(named: "fireworks.png")
        kittCar.frame = CGRect(x: 0, y: 0, width: 400, height: 300)
        kittCar.animates = true
    }
    
    @IBAction func setScannerMusic(_ sender: Any) {
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    override func awakeFromNib() {
        if self.view.layer != nil {
            self.view.layer?.backgroundColor = NSColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1).cgColor
        }
    }
}

