//
//  MBTagView.swift
//  iQuizCreator
//
//  Created by Viorel Porumbescu on 10/07/2018.
//  Copyright © 2018 Minglebit. All rights reserved.
//

import Cocoa

open class MBTagView: NSControl {
    // MARK: - Vars

    open var id: String             = "0000000000-000000-00000" { didSet { self.resetLayersProperties() } }
    open var title: String          = "Here will be the name of the tag" { didSet { self.resetLayersProperties() } }
    open var tagColor: NSColor      = NSColor(red: 0.290, green: 0.565, blue: 0.886, alpha: 1) { didSet { self.resetLayersProperties() } }

    open var textColor: NSColor            = #colorLiteral(red: 0.3229479194, green: 0.3229479194, blue: 0.3229479194, alpha: 1) { didSet { self.resetLayersProperties() } }
    open var backgroundColor: NSColor      = NSColor(red: 0.965, green: 0.965, blue: 0.965, alpha: 1) { didSet { resetLayersProperties() } }

    open weak var buttonDelegate: MBTagCloseButtonCustomizationDelegate?

    private var layers: [String: Any] = [:]
    private let defaultHeight: CGFloat = 24
    private var closeButton: MBTagCloseButton = MBTagCloseButton(frame: NSMakeRect(0, 0, 10, 10))

    private let titleField: NSTextField =  {
        let txt             = NSTextField(frame: NSMakeRect(0, 0, 60, 21))
        txt.isBezeled       = false
        txt.isBordered      = false
        txt.isEditable      = false
        txt.isSelectable    = false
        txt.backgroundColor = NSColor.clear
        txt.drawsBackground = true
        txt.font            = NSFont.systemFont(ofSize: 12, weight: NSFont.Weight.regular)

        return txt
    }()

    // MARK: - Init

    /// Init a new tag view without parameters
    ///
    /// - Parameter frameRect: The frame of the tag. This paramater is not important because the frame will be resized on compile time.
    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupLayers()
    }

    /// Init a new tag with a specific name
    ///
    /// - Parameter title: the name of the new tag
    init(with title: String) {
        super.init(frame: NSZeroRect)
        id       = UUID().uuidString
        self.title    = title
        tagColor = MBTagsColor.newRandomColor()
        setupLayers()
    }

    /// Init a new tag with a specific name and color
    ///
    /// - Parameters:
    ///   - title: the name of the new tag
    ///   - col: the color of the new tag
    init(with title: String, color col: NSColor) {
        super.init(frame: NSZeroRect)
        id       = UUID().uuidString
        self.title    = title
        tagColor = col
        setupLayers()
    }

    /// Init a tag  with a specific id, name and color
    ///
    /// - Parameters:
    ///   - title: the name of new tag
    ///   - col: the color of new tag
    ///   - uuid: the uuid of the tag
    init(with title: String, color col: NSColor, id uuid: String) {
        super.init(frame: NSZeroRect)
        id       = uuid
        self.title    = title
        tagColor = col
        setupLayers()
    }

    public required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        setupLayers()
    }

    // MARK: - Under the hood

    private func setupLayers() {
        let tagColorLayer       = CAShapeLayer()
        tagColorLayer.path      = NSBezierPath(ovalIn: NSMakeRect(0, 0, 12, 12)).cgPath
        tagColorLayer.fillColor = tagColor.cgColor

        wantsLayer = true
        layer?.addSublayer(tagColorLayer)
        layers["tagColorLayer"] = tagColorLayer

        addSubview(titleField)
        addSubview(closeButton)
        closeButton.delegate = buttonDelegate
        closeButton.target = self
        closeButton.action = #selector(removeAction(_:))

        resetLayersProperties()
    }

    func resetLayersProperties() {
        titleField.stringValue = title
        let titleWidth              = titleField.bestWidth()
        let totalWidth              = ceil(titleWidth + 48)
        titleField.frame       = NSMakeRect(24, 0, titleWidth, defaultHeight - 4)
        titleField.textColor   = textColor

        closeButton.frame      = NSMakeRect(totalWidth - 24, 0, defaultHeight, defaultHeight)
        if let col = layers["tagColorLayer"] as? CAShapeLayer {
            col.fillColor = tagColor.cgColor
            col.frame     = NSMakeRect(6, 6, 12, 12)
        }

        layer?.backgroundColor = backgroundColor.cgColor
        layer?.cornerRadius    = defaultHeight / 2

        animator().setFrameSize(NSMakeSize(totalWidth, defaultHeight))
    }

    // MARK: Handle actions

    @objc func removeAction(_: MBTagCloseButton) {
        if action != nil, target != nil {
            NSApp.sendAction(action!, to: target, from: self)
        }
    }
}
