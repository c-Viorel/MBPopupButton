//
//  MBTagCloseButton.swift
//  iQuizCreator
//
//  Created by Viorel Porumbescu on 10/07/2018.
//  Copyright © 2018 Minglebit. All rights reserved.
//

import Cocoa

@objc public protocol MBTagCloseButtonCustomizationDelegate
: class {
    @objc optional func backgroundColor() -> NSColor
    @objc optional func hoverBackgroundColor() -> NSColor
    @objc optional func activeBackgroundColor() -> NSColor

    @objc optional func closeColor() -> NSColor
    @objc optional func hoverCloseColor() -> NSColor
    @objc optional func activeCloseColor() -> NSColor
}

open class MBTagCloseButton: NSControl {
    private var bgColor: NSColor          { if delegate != nil { return delegate!.backgroundColor!() }       else { return NSColor(red: 0.921, green: 0.921, blue: 0.921, alpha: 1) } }
    private var hoverBGColor: NSColor     { if delegate != nil { return delegate!.hoverBackgroundColor!() }  else { return NSColor(red: 1, green: 1, blue: 1, alpha: 1) } }    // white
    private var downBgColor: NSColor      { if delegate != nil { return delegate!.activeBackgroundColor!() } else { return NSColor(red: 0.851, green: 0.851, blue: 0.851, alpha: 1) } }  // light gray

    private var signColor: NSColor       { if delegate != nil { return delegate!.closeColor!() }       else { return NSColor(red: 0.831, green: 0.827, blue: 0.831, alpha: 1) } }  // almost white
    private var hoverSignColor: NSColor  { if delegate != nil { return delegate!.hoverCloseColor!() }  else { return NSColor(red: 0.816, green: 0.008, blue: 0.106, alpha: 1) } }  // some red
    private var downSignColor: NSColor   { if self.delegate != nil { return delegate!.activeCloseColor!() } else { return NSColor(red: 0.624, green: 0, blue: 0.078, alpha: 1) } }    // some dark red

    weak var delegate: MBTagCloseButtonCustomizationDelegate?

    private enum State: Int {
        case normal
        case hover
        case down
    }

    private var layers: [String: Any] = [:]
    private var currentState: State = .normal {
        didSet {
            updateColors()
        }
    }

    /// Add/Update tracking Area
    var trackingArea: NSTrackingArea!
    override open func updateTrackingAreas() {
        if trackingArea != nil {
            removeTrackingArea(trackingArea)
        }
        trackingArea               = NSTrackingArea(rect: bounds, options: [NSTrackingArea.Options.mouseEnteredAndExited, NSTrackingArea.Options.enabledDuringMouseDrag, NSTrackingArea.Options.activeAlways], owner: self, userInfo: nil)
        addTrackingArea(trackingArea)
        // handle mouse position, in case the current control is inside a table view.
        let mouseLocation = window?.mouseLocationOutsideOfEventStream
        if mouseLocation != nil {
            let loc = convert(mouseLocation!, from: nil)
            if NSPointInRect(loc, bounds) {
                mouseEntered(with: NSEvent())
            } else {
                mouseExited(with: NSEvent())
            }
        }
    }

    // MARK: - Init

    /// Init a new tag view without parameters
    ///
    /// - Parameter frameRect: The frame of the tag. This paramater is not important because the frame will be resized on compile time.
    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupLayers()
    }

    public required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        setupLayers()
    }

    // MARK: - Under the hood

    private func setupLayers() {
        wantsLayer = true

        let closeSign: CAShapeLayer = CAShapeLayer()
        closeSign.path = xSignPAth().cgPath
        closeSign.lineCap = CAShapeLayerLineCap.round
        closeSign.lineWidth = 0.5

        let bgLayer = CAShapeLayer()
        bgLayer.path = NSBezierPath(ovalIn: NSMakeRect(0, 0, 10, 10)).cgPath

        layer?.addSublayer(bgLayer)
        bgLayer.addSublayer(closeSign)
        layers["closeSign"] = closeSign
        layers["bgLayer"] = bgLayer
        resetLayersProperties()
    }

    private func resetLayersProperties() {
        if let sign = layers["closeSign"] as? CAShapeLayer {
            sign.strokeColor = signColor.cgColor
        }
        if let bg = layers["bgLayer"] as? CAShapeLayer {
            bg.fillColor = bgColor.cgColor
            bg.frame = NSMakeRect(7, 7, 10, 10)
        }
    }

    // MARK: - Mouse events

    override open func mouseEntered(with _: NSEvent) {
        currentState = .hover
    }

    override open func mouseDown(with _: NSEvent) {
        currentState = .down
    }

    override open func mouseUp(with event: NSEvent) {
        let point = event.locationInWindow
        if bounds.contains(convert(point, from: nil)) {
            currentState = .hover
            if let act = self.action {
                if let targ = self.target  {
                    NSApp.sendAction(act, to: targ, from: self)
                }
            }
        } else {
            currentState = .normal
        }
    }

    override open func mouseExited(with _: NSEvent) {
        currentState = .normal
    }

    private func updateColors() {
        var sColor = NSColor.white
        var bgCol = NSColor.white
        switch currentState {
        case .normal:
            sColor = signColor
            bgCol  = bgColor
        case .hover:
            sColor = hoverSignColor
            bgCol  = hoverBGColor
        case .down:
            sColor = downSignColor
            bgCol  = downBgColor
        }
        if let sign = layers["closeSign"] as? CAShapeLayer {
            sign.strokeColor = sColor.cgColor
        }
        if let bg = layers["bgLayer"] as? CAShapeLayer {
            bg.fillColor = bgCol.cgColor
        }
    }

    private func xSignPAth() -> NSBezierPath {
        let bezier3Path = NSBezierPath()
        bezier3Path.move(to: NSPoint(x: 2.87, y: 7.11))
        bezier3Path.line(to: NSPoint(x: 7.11, y: 2.87))
        bezier3Path.line(to: NSPoint(x: 2.87, y: 7.11))
        bezier3Path.close()
        bezier3Path.move(to: NSPoint(x: 2.87, y: 2.87))
        bezier3Path.line(to: NSPoint(x: 7.11, y: 7.11))
        bezier3Path.line(to: NSPoint(x: 2.87, y: 2.87))
        bezier3Path.close()

        return bezier3Path
    }
}
