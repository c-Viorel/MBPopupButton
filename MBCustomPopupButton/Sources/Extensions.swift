//
//  Extensions.swift
//  MBTagsControl
//
//  Created by Viorel Porumbescu on 11/07/2018.
//  Copyright © 2018 Viorel Porumbescu. All rights reserved.
//

import Cocoa

// MARK: - Extend NSBezierPath  to be able to convert selt into a CGPath

internal extension NSBezierPath {
    var cgPath: CGPath {
        let path = CGMutablePath()
        var points = [CGPoint](repeating: .zero, count: 3)
        for i in 0 ..< self.elementCount {
            let type = self.element(at: i, associatedPoints: &points)
            switch type {
            case .moveTo: path.move(to: CGPoint(x: points[0].x, y: points[0].y))
            case .lineTo: path.addLine(to: CGPoint(x: points[0].x, y: points[0].y))
            case .curveTo: path.addCurve(to: CGPoint(x: points[2].x, y: points[2].y),
                                         control1: CGPoint(x: points[0].x, y: points[0].y),
                                         control2: CGPoint(x: points[1].x, y: points[1].y))
            case .closePath: path.closeSubpath()
            @unknown default:
                fatalError("An unknown case was added in the meantime: \(type). Please check, and hanle it properly")
            }
        }
        return path
    }
}

internal extension NSTextField {
    func bestWidth() -> CGFloat {
        self.stringValue = self.stringValue
        let getnumber = self.cell!.cellSize(forBounds: NSMakeRect(CGFloat(0.0), CGFloat(0.0), CGFloat(Float.greatestFiniteMagnitude), 25)).width
        return getnumber
    }
}

extension String {
    static var dummyTextField: NSTextField {
        return NSTextField(frame: NSRect.zero)
    }

    func bestWidh(forFontSize size: CGFloat = 13.0, font: NSFont = NSFont.systemFont(ofSize: 13)) -> CGFloat {
        String.dummyTextField.font = font

        if let newfont = NSFont(descriptor: font.fontDescriptor, size: size) {
            String.dummyTextField.font = newfont
        }
        String.dummyTextField.stringValue = self

        return String.dummyTextField.bestWidth()
    }
}

// MARK: - Extend Array to support removing a specific element.

internal extension Array where Element: Equatable {
    mutating func delete(element: Iterator.Element) {
        self = self.filter { $0 != element }
    }

    mutating func remove(element: Iterator.Element) {
        self = self.filter { $0 != element }
    }
}

// MARK: - Extend NSImage to support recolor an image with specific color.

internal extension NSImage {
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
            let d: Int = numericCast(arc4random_uniform(numericCast(unshuffledCount)))
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

    func random(numberOfElements: Int) -> [Element] {
        var array = Array(self)
        if numberOfElements == 0 {
            return []
        }
        if numberOfElements >= array.count {
            return array
        }
        array.shuffle()
        var newArray: [Element] = []
        for i in 0 ... numberOfElements - 1 {
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


extension NSImage {

    /// Returns the height of the current image.
    var height: CGFloat {
        return self.size.height
    }

    /// Returns the width of the current image.
    var width: CGFloat {
        return self.size.width
    }

    /// Returns a png representation of the current image.
    var PNGRepresentation: Data? {
        if let tiff = self.tiffRepresentation, let tiffData = NSBitmapImageRep(data: tiff) {
            return tiffData.representation(using: .png, properties: [:])
        }

        return nil
    }

    ///  Copies the current image and resizes it to the given size.
    ///
    ///  - parameter size: The size of the new image.
    ///
    ///  - returns: The resized copy of the given image.
    func copy(size: NSSize) -> NSImage? {
        // Create a new rect with given width and height
        let frame = NSMakeRect(0, 0, size.width, size.height)

        // Get the best representation for the given size.
        guard let rep = self.bestRepresentation(for: frame, context: nil, hints: nil) else {
            return nil
        }

        // Create an empty image with the given size.
        let img = NSImage(size: size)

        // Set the drawing context and make sure to remove the focus before returning.
        img.lockFocus()
        defer { img.unlockFocus() }

        // Draw the new image
        if rep.draw(in: frame) {
            return img
        }

        // Return nil in case something went wrong.
        return nil
    }

    ///  Copies the current image and resizes it to the size of the given NSSize, while
    ///  maintaining the aspect ratio of the original image.
    ///
    ///  - parameter size: The size of the new image.
    ///
    ///  - returns: The resized copy of the given image.
    func resizeWhileMaintainingAspectRatioToSize(size: NSSize) -> NSImage? {
        let newSize: NSSize

        let widthRatio  = size.width / self.width
        let heightRatio = size.height / self.height

        if widthRatio > heightRatio {
            newSize = NSSize(width: floor(self.width * widthRatio), height: floor(self.height * widthRatio))
        } else {
            newSize = NSSize(width: floor(self.width * heightRatio), height: floor(self.height * heightRatio))
        }

        return self.copy(size: newSize)
    }

    ///  Copies and crops an image to the supplied size.
    ///
    ///  - parameter size: The size of the new image.
    ///
    ///  - returns: The cropped copy of the given image.
    func crop(size: NSSize) -> NSImage? {
        // Resize the current image, while preserving the aspect ratio.
        guard let resized = self.resizeWhileMaintainingAspectRatioToSize(size: size) else {
            return nil
        }
        // Get some points to center the cropping area.
        let x = floor((resized.width - size.width) / 2)
        let y = floor((resized.height - size.height) / 2)

        // Create the cropping frame.
        let frame = NSMakeRect(x, y, size.width, size.height)

        // Get the best representation of the image for the given cropping frame.
        guard let rep = resized.bestRepresentation(for: frame, context: nil, hints: nil) else {
            return nil
        }

        // Create a new image with the new size
        let img = NSImage(size: size)

        img.lockFocus()
        defer { img.unlockFocus() }

        if rep.draw(in: NSMakeRect(0, 0, size.width, size.height),
                    from: frame,
                    operation: NSCompositingOperation.copy,
                    fraction: 1.0,
                    respectFlipped: false,
                    hints: [:]) {
            // Return the cropped image.
            return img
        }

        // Return nil in case anything fails.
        return nil
    }

    ///  Saves the PNG representation of the current image to the HD.
    ///
    /// - parameter url: The location url to which to write the png file.
    func savePNGRepresentationToURL(url: URL) throws {
        if let png = self.PNGRepresentation {
            try png.write(to: url, options: .atomicWrite)
        }
    }
}
