//
//  Extensions.swift
//  MBTagsControl
//
//  Created by Viorel Porumbescu on 11/07/2018.
//  Copyright © 2018 Viorel Porumbescu. All rights reserved.
//

import Cocoa




// MARK: - Extend NSBezierPath  to be able to convert selt into a CGPath
extension NSBezierPath {
    public var cgPath: CGPath {
        let path = CGMutablePath()
        var points = [CGPoint](repeating: .zero, count: 3)
        for i in 0 ..< self.elementCount {
            let type = self.element(at: i, associatedPoints: &points)
            switch type {
            case .moveTo: path.move(to: CGPoint(x: points[0].x, y: points[0].y) )
            case .lineTo: path.addLine(to: CGPoint(x: points[0].x, y: points[0].y) )
            case .curveTo: path.addCurve(to: CGPoint(x: points[2].x, y: points[2].y),
                                                          control1: CGPoint(x: points[0].x, y: points[0].y),
                                                          control2: CGPoint(x: points[1].x, y: points[1].y) )
            case .closePath: path.closeSubpath()
            }
        }
        return path
    }
}


extension NSTextField {
    
    func bestWidth() -> CGFloat {
        self.stringValue = self.stringValue
        let getnumber = self.cell!.cellSize(forBounds: NSMakeRect(CGFloat(0.0), CGFloat(0.0), CGFloat(Float.greatestFiniteMagnitude) , 25)).width
        return getnumber
    }
}

// MARK: - Extend Array to support removing a specific element.
extension Array where Element: Equatable  {
    mutating func delete(element: Iterator.Element) {
        self = self.filter{$0 != element }
    }
    mutating func remove(element: Iterator.Element) {
        self = self.filter{$0 != element }
    }
}


// MARK: - Extend NSImage to support recolor an image with specific color.
extension NSImage {
    func tinting(with tintColor: NSColor) -> NSImage {
        guard let cgImage = self.cgImage(forProposedRect: nil, context: nil, hints: nil) else { return self }
        
        return NSImage(size: size, flipped: false) { bounds in
            guard let context = NSGraphicsContext.current?.cgContext else { return false }
            
            tintColor.set()
            context.clip(to: bounds, mask: cgImage)
            context.fill(bounds)
            
            return true
        }
    }
}


/// Add posibility to shuffle any mutable collection
extension MutableCollection {
    /// Shuffles the contents of this collection.
    mutating func shuffle() {
        let c = count
        guard c > 1 else { return }
        for (firstUnshuffled, unshuffledCount) in zip(indices, stride(from: c, to: 1, by: -1)) {
            let d:Int = numericCast(arc4random_uniform(numericCast(unshuffledCount)))
            let i = index(firstUnshuffled, offsetBy: d)
            swapAt(firstUnshuffled, i)
        }
    }
}

extension Sequence {
    /// Returns an array with the contents of this sequence, shuffled.
    func shuffled() -> [Element] {
        var result = Array(self)
        result.shuffle()
        return result
    }
    
    func random(numberOfElements:Int) -> [Element] {
        var array = Array(self)
        if numberOfElements == 0 {
            return []
        }
        if numberOfElements >= array.count {
            return array
        }
        array.shuffle()
        var newArray:[Element] = []
        for i in 0...numberOfElements-1 {
            newArray.append(array[i])
        }
        return newArray
    }
    
    func randomElement() -> Element? {
        var array = Array(self)
        if array.count == 0 {
            return nil
        }
        array.shuffle()
        return array[0]
    }
}
