//
//  MBButton.swift
//  Dynamic Wallpaper
//
//  Created by Viorel Porumbescu on 07/05/2019.
//  Copyright © 2019 Minglebit. All rights reserved.
//

import Cocoa

open class MBPopupButton: NSButton {
    /// When the control is disabled entire button will be drawn with current alpha value
    let disabledControlsAlphaValue: CGFloat = 0.7

    // MARK: -Inspectable properties

    /// The corner radius of the main button.
    @IBInspectable public var cornerRadius: CGFloat = 5 { didSet { resetLayersProperties() } }

    /// The color of main button background.
    @IBInspectable public var backgroundColor: NSColor = NSColor.clear { didSet { resetLayersProperties() } }

    /// The color of background on hover state
    @IBInspectable public var backgroundHoverColor: NSColor = NSColor.white

    /// The color of background on active state
    @IBInspectable open var backgroundActiveColor: NSColor = NSColor.lightGray

    // ----------

    /// The color of main button border.
    @IBInspectable var borderColor: NSColor = NSColor.white { didSet { resetLayersProperties() } }

    /// The color of main button border on hover state.
    @IBInspectable var borderHoverColor: NSColor = NSColor.white

    /// The color of main button border on active state.
    @IBInspectable var borderActiveColor: NSColor = NSColor.lightGray

    /// The width of the border
    @IBInspectable var borderWidth: CGFloat = 1 { didSet { resetLayersProperties() } }

    // ----------

    /// The color of main button title.
    @IBInspectable var titleColor: NSColor = NSColor.white { didSet { resetLayersProperties() } }

    /// The color of main button border on hover state.
    @IBInspectable var titleHoverColor: NSColor = NSColor.darkGray

    /// The color of main button border on active state.
    @IBInspectable var titleActiveColor: NSColor = NSColor.black

    /// In case that you want to fine adjust the y position of the title
    @IBInspectable var decaleYTitle: CGFloat = 0 { didSet { resetLayersProperties() } }

    //MARK: -open's vars
    /// The state of the control. If is not enable, all interaction are disabled.
    open override var isEnabled: Bool {
        get {
            _isOn
        }
        set {
            self._isOn = newValue
            resetLayersProperties()
        }
    }

    open override var frame: NSRect { didSet { self.resetLayersProperties(animated: false) } }

    open override var bounds: NSRect { didSet { self.resetLayersProperties(animated: false) } }

    open override var title: String { didSet { resetLayersProperties() } }
    
    open var items:[MBPopupItem] = [] 

    // MARK: - Private vars

    fileprivate var layers: [String: AnyObject] = [:]
    fileprivate var _isOn: Bool = true
    fileprivate var trackingArea: NSTrackingArea!

    // MARK: Init & config

    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupLayers()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayers()
        if let cellIsOk = self.cell?.isKind(of: MBPopupButtonCell.self), cellIsOk == false {
            assertionFailure("You forgot to set the button cell to MBPopupButtonCell. Please go to the storyboard where the button is placed and set the cell accordingly!")
        }
    }

    open override func awakeFromNib() {
        resetLayersProperties()
    }

    open override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        resetProperties()
    }

    open override func updateTrackingAreas() {
        if trackingArea != nil {
            removeTrackingArea(trackingArea)
        }
        trackingArea = NSTrackingArea(rect: bounds, options: [NSTrackingArea.Options.mouseEnteredAndExited, NSTrackingArea.Options.mouseMoved, NSTrackingArea.Options.activeInKeyWindow], owner: self, userInfo: nil)
        addTrackingArea(trackingArea)
    }

    // MARK: Handle mouse actions & events

    open override func mouseEntered(with _: NSEvent) {
        if isEnabled {
            CATransaction.begin()
            CATransaction.setAnimationDuration(0.2)

            (layers["bg"] as! CALayer).backgroundColor = backgroundHoverColor.cgColor
            (layers["bg"] as! CALayer).borderColor = borderHoverColor.cgColor
            (layers["title"] as! CATextLayer).foregroundColor = titleHoverColor.cgColor

            CATransaction.commit()
        }
    }

    open override func mouseExited(with _: NSEvent) {
        if isEnabled {
            CATransaction.begin()
            CATransaction.setAnimationDuration(0.2)

            (layers["bg"] as! CALayer).backgroundColor = backgroundColor.cgColor
            (layers["bg"] as! CALayer).borderColor = borderColor.cgColor
            (layers["title"] as! CATextLayer).foregroundColor = titleColor.cgColor

            CATransaction.commit()
        }
    }

    open override func mouseDown(with _: NSEvent) {
        if isEnabled {
            (layers["bg"] as? CALayer)?.borderColor = borderActiveColor.cgColor
            (layers["bg"] as? CALayer)?.backgroundColor = backgroundActiveColor.cgColor
            (layers["title"] as? CATextLayer)?.foregroundColor = titleActiveColor.cgColor

            openAddTagController(self)
        }
    }

    open override func mouseUp(with _: NSEvent) {
        if isEnabled {
            (layers["bg"] as? CALayer)?.borderColor = borderHoverColor.cgColor
            (layers["bg"] as? CALayer)?.backgroundColor = backgroundHoverColor.cgColor
            (layers["title"] as? CATextLayer)?.foregroundColor = titleHoverColor.cgColor
        }
    }

    private var popover:NSPopover?

    /// Open interface for adding a new tag
    @objc func openAddTagController(_ sender:NSView) {
        if popover == nil {
            let contentController = MBPopupListController.init(nibName: "MBTagPopoverController", bundle: nil)
            contentController.items = [ MBPopupTextItem.init(withTitle: "Viorel"),
                                        MBPopupTextItem.init(withTitle: "Viorel1"),
                                        MBPopupTextItem.init(withTitle: "Viorel2"),
                                        MBPopupTextItem.init(withTitle: "Viorel3"),
                                        MBPopupSeparatorItem(withColor: .lightGray, lineHeight: 4, paddingLeft: 20, paddingRight: 0),
                                        MBPopupTextItem.init(withTitle: "Viorel4", color: .red),
                                        ]

            let popover                     = NSPopover.init()
            popover.appearance              = NSAppearance.init(named: .aqua)
            popover.contentViewController   = contentController
            popover.behavior                = .semitransient
            contentController.popover       = popover
            popover.animates                = true
            //            popover.backgroundColor         =  #colorLiteral(red: 0.9599732757, green: 0.9599732757, blue: 0.9599732757, alpha: 1)
            self.popover                    = popover
        }
        popover?.show(relativeTo: sender.visibleRect, of: sender, preferredEdge: NSRectEdge.maxY)
    }

    private func resetProperties() {
        CATransaction.begin()
        CATransaction.setAnimationDuration(0.25)

        (layers["title"] as? CATextLayer)?.string = title

        CATransaction.commit()
    }

    // Reset all color and state of control to match with the new appearance
    private func resetLayersProperties(animated: Bool = false) {
        CATransaction.begin()
        if !animated {
            CATransaction.setAnimationDuration(0)
        }

        if let bgLayer = layers["bg"] as? CALayer {
            bgLayer.frame = CGRect(x: bounds.origin.x, y: bounds.origin.y, width: bounds.size.width, height: bounds.size.height)
            bgLayer.borderColor = isEnabled ? borderColor.cgColor : borderColor.withAlphaComponent(disabledControlsAlphaValue).cgColor
            bgLayer.backgroundColor = isEnabled ? backgroundColor.cgColor : backgroundColor.withAlphaComponent(disabledControlsAlphaValue).cgColor
            bgLayer.masksToBounds = true
            bgLayer.cornerRadius = cornerRadius
            bgLayer.borderColor = borderColor.cgColor
            bgLayer.borderWidth = borderWidth
        }

        if let titleLayer = layers["title"] as? CATextLayer {
            titleLayer.font = font
            titleLayer.fontSize = font?.fontDescriptor.fontAttributes[NSFontDescriptor.AttributeName.size] as? CGFloat ?? 12
            titleLayer.contentsScale = NSScreen.main!.backingScaleFactor * 2
            titleLayer.alignmentMode = CATextLayerAlignmentMode.center
            if alignment == .left {
                titleLayer.alignmentMode = CATextLayerAlignmentMode.left
            }
            if alignment == .right {
                titleLayer.alignmentMode = CATextLayerAlignmentMode.right
            }
            titleLayer.string = title

            titleLayer.foregroundColor = isEnabled ? titleColor.cgColor : titleColor.withAlphaComponent(disabledControlsAlphaValue).cgColor
            titleLayer.frame = CGRect(x: bounds.origin.x + 4, y: bounds.origin.y + 2.5 - decaleYTitle, width: bounds.size.width - 8, height: bounds.size.height)
        }

        CATransaction.commit()
    }

    private func setupLayers() {
        layers.removeAll()

        wantsLayer = true
        let bgLayer: CALayer = CALayer()
        bgLayer.frame = CGRect(x: bounds.origin.x, y: bounds.origin.y, width: bounds.size.width, height: bounds.size.height)
        bgLayer.backgroundColor = NSColor.clear.cgColor
        bgLayer.cornerRadius = cornerRadius
        bgLayer.borderWidth = 1.0
        bgLayer.borderColor = borderColor.cgColor
        bgLayer.backgroundColor = backgroundColor.cgColor
        layers["bg"] = bgLayer
        layer?.addSublayer(bgLayer)

        let titleLayer: CATextLayer = CATextLayer()
        titleLayer.font = font
        titleLayer.fontSize = font?.fontDescriptor.fontAttributes[NSFontDescriptor.AttributeName.size] as? CGFloat ?? 12
        titleLayer.contentsScale = NSScreen.main!.backingScaleFactor * 2
        titleLayer.alignmentMode = CATextLayerAlignmentMode.center
        if alignment == .left {
            titleLayer.alignmentMode = CATextLayerAlignmentMode.left
        }
        if alignment == .right {
            titleLayer.alignmentMode = CATextLayerAlignmentMode.right
        }
        titleLayer.string = title
        titleLayer.foregroundColor = NSColor.lightGray.cgColor
        layers["title"] = titleLayer
        layer?.addSublayer(titleLayer)

        resetLayersProperties()
    }
}

extension MBPopupButton {
    func applySystemColorSheme() {
//        loadCustomAppSpecificColors()
        backgroundColor = NSColor.controlAccentColor
        borderColor = NSColor.controlAccentColor

        backgroundHoverColor = NSColor.controlAccentColor.withSystemEffect(.rollover)
        borderHoverColor = NSColor.controlAccentColor.withSystemEffect(.rollover)

        backgroundActiveColor = NSColor.controlAccentColor.withSystemEffect(.deepPressed)
        borderActiveColor = NSColor.controlAccentColor.withSystemEffect(.rollover)

        titleColor = NSColor.white
        titleHoverColor = NSColor.white
        titleActiveColor = NSColor.white
    }

    /// This is a custom implementaion, that will fit only for current application
    private func loadCustomAppSpecificColors() {
//        switch currentAppearance {
//        case .light:
//            backgroundColor = UIColors.Light.boxBackground
//            borderColor = UIColors.Light.boxBackground
//            titleColor = UIColors.Light.labels
//        case .dark:
//            backgroundColor = UIColors.Dark.boxBackground
//            borderColor = UIColors.Dark.boxBackground
//            titleColor = UIColors.Dark.labels
//        }
//
//        backgroundHoverColor = NSColor.controlAccentColor
//        borderHoverColor = NSColor.controlAccentColor
//
//        backgroundActiveColor = NSColor.controlAccentColor.withSystemEffect(.rollover)
//        borderActiveColor = NSColor.controlAccentColor.withSystemEffect(.rollover)
//
//        titleHoverColor = NSColor.white
//        titleActiveColor = NSColor.white
    }
}
