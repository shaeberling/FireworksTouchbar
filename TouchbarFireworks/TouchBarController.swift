//
//  ToucharBarController.swift
//  TouchbarFireworks
//
//  Created by Anthony Da Mota on 08/11/2016.
//  Copyright © 2016 Anthony Da Mota. All rights reserved.
//  Major modifications in accordance with license
//  Copyright © 2017 Sascha Haeberling.

import Cocoa

// TODO: Gotta rename the project
fileprivate extension NSTouchBarCustomizationIdentifier {
    static let fireworksTouchBar = NSTouchBarCustomizationIdentifier("com.s13g.TouchbarFireworks")
}

fileprivate extension NSTouchBarItemIdentifier {
    static let fireworks = NSTouchBarItemIdentifier("fireworks")
}

public extension Double {
    public static var random:Double {
        get {
            return Double(arc4random()) / 0xFFFFFFFF
        }
    }
    public static func random(from: Double, to: Double) -> Double {
        return Double.random * (to - from) + from
    }
}

class Spark {
    var x = Int.min
    var y = Int.min
    var vx = 0.0
    var vy = 0.0
}

class Bomb {
    static let SPARK_NUM = 20
    // Unit: m/(s*s)
    static let G_SPEED = -9.81
    // Unit: seconds.
    static let dT = 0.1
    // Unit: m/s.
    static let dV = dT * G_SPEED

    static let COLORS:[NSColor] = [NSColor(calibratedRed: 0.0, green: 0.0, blue: 1.0, alpha: 1.0),
                                   NSColor(calibratedRed: 0.0, green: 1.0, blue: 0.0, alpha: 1.0),
                                   NSColor(calibratedRed: 0.0, green: 1.0, blue: 1.0, alpha: 1.0),
                                   NSColor(calibratedRed: 1.0, green: 0.0, blue: 0.0, alpha: 1.0),
                                   NSColor(calibratedRed: 1.0, green: 0.0, blue: 1.0, alpha: 1.0),
                                   NSColor(calibratedRed: 1.0, green: 1.0, blue: 0.0, alpha: 1.0),
                                   NSColor(calibratedRed: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)]
    var sparks:[Spark] = []
    var color = NSColor.white

    init() {
        for _ in 0..<Bomb.SPARK_NUM {
            sparks.append(Spark())
        }
    }

    func reset(x:Int, y:Int) {
        for spark in sparks {
            spark.x = x;
            spark.y = y;
            spark.vx = Double.random(from: -40.0, to: 40.0)
            spark.vy = Double.random(from: -40.0, to: 40.0)

            if (abs(spark.vx) < 10) {
                spark.vx = 10 * ((spark.vx < 0) ? -1 : 1)
            }
            if (abs(spark.vy) < 10) {
                spark.vy = 10 * ((spark.vy < 0) ? -1 : 1)
            }
        }
        color = Bomb.COLORS[Int(arc4random_uniform(UInt32(Bomb.COLORS.count)))]
    }

    func calcNextStep() {
        var outsideSparkNum:Int = 0;
        for spark in sparks {
            // Note: NSView's y-axis goes bottom-up.
            if (spark.x < -1 || spark.x > 800 || spark.y < -1) {
                // The spark is gone and will never come back.
                outsideSparkNum += 1
            } else {
                spark.vy += Bomb.dV;
                spark.y += Int(Bomb.dT * spark.vy)
                spark.x += Int(Bomb.dT * spark.vx)
            }
        }
        
        // If all sparks are outside the bounds, reset the bomb.
        if (outsideSparkNum == Bomb.SPARK_NUM) {
            let new_X = Int(Double.random(from: 5, to: 755));
            let new_Y = Int(Double.random(from: 1, to: 39));
            // NSLog("Bomb with X/Y: %d/%d", new_X, new_Y)
            self.reset(x: new_X, y: new_Y)
        }
    }

    func draw() {
        color.setFill()
        for spark in sparks {
            NSRectFill(NSRect(x: spark.x, y: spark.y, width: 2, height: 2))
        }
    }
}


class FireworksView: NSView {
    let BOMB_NUM = 20
    let WIDTH = 800
    let HEIGHT = 40
    var flip = true
    var bombs:[Bomb] = [];

    override init(frame frameRect: NSRect) {
        super.init(frame:frameRect);
        startTimer();
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        startTimer();
    }

    func startTimer() {
        for _ in 0..<BOMB_NUM {
            bombs.append(Bomb());
        }
        Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(self.timerCallBack(timer:)), userInfo: nil, repeats: true)
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        NSColor.black.setFill();
        NSRectFill(dirtyRect)

        for bomb in bombs {
            bomb.calcNextStep()
            bomb.draw();
        }
    }

    func timerCallBack(timer: Timer) {
        setNeedsDisplay(NSRect(x:0, y: 0, width:WIDTH, height: HEIGHT));
    }
}

@available(OSX 10.12.1, *)
class TouchBarController: NSWindowController, NSTouchBarDelegate, CAAnimationDelegate {
    let theKnightView = NSView()

    override func windowDidLoad() {
        super.windowDidLoad()
    }
    
    @available(OSX 10.12.2, *)
    override func makeTouchBar() -> NSTouchBar? {
        let touchBar = NSTouchBar()
        touchBar.delegate = self
        touchBar.customizationIdentifier = NSTouchBarCustomizationIdentifier.fireworksTouchBar
        touchBar.defaultItemIdentifiers = [.fireworks]
        touchBar.customizationAllowedItemIdentifiers = [.fireworks]
        return touchBar
    }
    
    @available(OSX 10.12.2, *)
    func touchBar(_ touchBar: NSTouchBar, makeItemForIdentifier identifier: NSTouchBarItemIdentifier) -> NSTouchBarItem? {
        let wholeTouchBar = NSCustomTouchBarItem(identifier: identifier)
        switch identifier {
        case NSTouchBarItemIdentifier.fireworks:
            wholeTouchBar.view = FireworksView(frame: NSRect())
            return wholeTouchBar
        default:
            return nil
        }
    }
}

