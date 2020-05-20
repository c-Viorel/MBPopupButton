//
//  MBTagViewController.swift
//  iQuizCreator
//
//  Created by Viorel Porumbescu on 10/07/2018.
//  Copyright © 2018 Minglebit. All rights reserved.
//

import Cocoa
@objc protocol MBTagViewControllerDelegate:class {
    @objc optional func newTagInserted(controller:MBTagViewController, theTag:MBTagView)
    @objc optional func aTagHasBeenRemoved(controller:MBTagViewController, theTag:MBTagView)
}


class MBTagViewController: NSView {

    var allTags:[MBTagView] {
        get {
            return self.displayedTags
        }
    }
    
    override var bounds: NSRect {
        didSet {
            self.resetScrollerBounds()
        }
    }
    
    override var frame: NSRect {
        didSet{
            self.resetScrollerBounds()
        }
    }
    weak var delegate:MBTagViewControllerDelegate?
    weak var closeTagButtonCustomizationDelegate:MBTagCloseButtonCustomizationDelegate?
    private var popover:NSPopover?
    let addButton:MBTextButton = {
       let btn     = MBTextButton.init(frame: NSMakeRect(0, 0, 30, 28))
        btn.image  = #imageLiteral(resourceName: "circleAdd")
        btn.target = self as AnyObject
        btn.action = #selector(openAddTagController(_:))
        btn.title  = ""
        return btn
    }()
    
    private var displayedTags:[MBTagView] = [ MBTagView.init(with: "Animator",             color: NSColor(red:0.816, green:0.008, blue:0.106, alpha:1)),
                                              MBTagView.init(with: "Core data",            color: NSColor(red:0.961, green:0.651, blue:0.137, alpha:1)),
                                              MBTagView.init(with: "NSViewController",     color: NSColor(red:0, green:0.451, blue:0.753, alpha:1)),
                                              MBTagView.init(with: "My custom class",      color: NSColor(red:0.722, green:0.914, blue:0.525, alpha:1)),
                                              MBTagView.init(with: "Question",             color: NSColor(red:0.290, green:0.290, blue:0.290, alpha:1)),
                                              MBTagView.init(with: "Aswers",               color: NSColor(red:0.565, green:0.075, blue:0.996, alpha:1)),
                                              MBTagView.init(with: "Test",                 color: NSColor(red:0.667, green:0.008, blue:0.090, alpha:1)),
                                              MBTagView.init(with: "Another looong tag",   color: NSColor(red:0.255, green:0.459, blue:0.020, alpha:1))
        ].shuffled() {
        didSet {
            if displayedTags.count == 0 {
                self.noTagsInfoLabel.animator().isHidden = false
            } else {
                self.noTagsInfoLabel.animator().isHidden = true
            }
        }
    }

    private var viewWithTags:NSView          = NSView.init()
    private var scrollView:NSScrollView      = NSScrollView.init()
    private var noTagsInfoLabel:NSTextField  = NSTextField()

    //MARK:- Init
    
    /// Init a new tag view without parameters
    ///
    /// - Parameter frameRect: The frame of the tag. This paramater is not important because the frame will be resized on compile time.
    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.setupLayers()
    }
    
    required public init?(coder decoder: NSCoder) {
        super.init(coder:decoder)
        self.setupLayers()
    }
    
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        self.wantsLayer = true
//        self.layer?.cornerRadius = 3
//        self.layer?.borderWidth = 1
//        self.layer?.borderColor = NSColor.lightGray.withAlphaComponent(0.25).cgColor
    }
    
    func setupLayers() {
        scrollView.borderType               = .noBorder
        scrollView.allowsMagnification      = false
        scrollView.autohidesScrollers       = true
        scrollView.hasVerticalScroller      = false
        scrollView.hasHorizontalScroller    = false
        scrollView.documentView             = viewWithTags
        scrollView.drawsBackground          = false
        scrollView.verticalScrollElasticity = .none
        
        noTagsInfoLabel.drawsBackground = false
        noTagsInfoLabel.isSelectable    = false
        noTagsInfoLabel.isEditable      = false
        noTagsInfoLabel.isBordered      = false
        noTagsInfoLabel.isHidden        = true
        noTagsInfoLabel.font            = NSFont.systemFont(ofSize: 13)
        noTagsInfoLabel.textColor       = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        noTagsInfoLabel.frame           = NSMakeRect(30, 3, 200, 20)
        noTagsInfoLabel.stringValue     = "No tags..."
        self.addSubview(scrollView)
        self.addSubview(addButton)
        self.addSubview(noTagsInfoLabel)
        resetScrollerBounds()
        resetTagViewContent()
        
        addButton.target = self
        addButton.action = #selector(openAddTagController(_:))
    }

    
    private func resetTagViewContent() {
        var totalWidth:CGFloat = 0
        displayedTags.forEach { (tag) in
            totalWidth += tag.frame.width + 10
            tag.buttonDelegate = closeTagButtonCustomizationDelegate
        }
        for view in viewWithTags.subviews {
            view.removeFromSuperview()
        }
        viewWithTags.setFrameSize(NSMakeSize(totalWidth, self.bounds.height))
        var x:CGFloat = 5
        for tag in displayedTags {
            tag.setFrameOrigin(NSMakePoint(-tag.frame.width, 2))
            viewWithTags.addSubview(tag)
            tag.animator().setFrameOrigin(NSMakePoint(x, 2))
            x += tag.frame.width + 10
            
            tag.target = self
            tag.action = #selector(removeATag(_:))
        }
    }

    
    /// Insert an array of tags with default animation
    ///
    /// - Parameter theTags: An array with the tags that you want to insert
    func insert(tags theTags:[MBTagView]) {
        for item in theTags {
            self.insert(newTag: item)
        }
    }
    
    /// Insert a new tag with default animation
    func insert(newTag tag:MBTagView) {
        if displayedTags.contains(where: { (current) -> Bool in
            return current.title.lowercased() == tag.title.lowercased()
        }) {
            print("The tag canot be inserted. A tag with the same name already exist.")
            return
        }
        tag.setFrameOrigin(NSMakePoint(0 - 20 - tag.frame.width, 2))
        viewWithTags.addSubview(tag)
        displayedTags.insert(tag, at: 0)
        tag.target = self
        tag.action = #selector(removeATag(_:))
        resetTagViewsAfterRemoving()
        delegate?.newTagInserted?(controller: self, theTag: tag)
    }
    
    /// remove a tag with default animation
    @objc func removeATag(_ sender:MBTagView) {
        sender.removeFromSuperview()
        displayedTags.remove(element: sender)
        resetTagViewsAfterRemoving()
        delegate?.aTagHasBeenRemoved?(controller: self, theTag: sender)
    }
    
    /// Rearange  all tags after removing
    func resetTagViewsAfterRemoving() {
        var totalWidth:CGFloat = 0
        displayedTags.forEach { (tag) in
            totalWidth += tag.frame.width + 10
        }

        var x:CGFloat = 5
        for tag in displayedTags {
            tag.animator().setFrameOrigin(NSMakePoint(x, 2))
            x += tag.frame.width + 10
        }
        viewWithTags.animator().setFrameSize(NSMakeSize(totalWidth, self.bounds.height))
    }

    /// Open interface for adding a new tag
    @objc func openAddTagController(_ sender:MBTextButton) {
        if popover == nil {
            let contentController = MBTagPopoverController.init(nibName: "MBTagPopoverController", bundle: nil)
            
            contentController.suggestionTags = self.allTags
            contentController.newTagInserted = { (tag) in
                self.popover?.close()
                contentController.searchField.stringValue = ""
                self.insert(newTag: tag)
            }
            
            let popover                     = NSPopover.init()
            popover.appearance              = NSAppearance.init(named: .aqua)
            popover.contentViewController   = contentController
            popover.behavior                = .semitransient
            contentController.popover       = popover
            popover.animates                = true
            popover.backgroundColor         =  #colorLiteral(red: 0.9599732757, green: 0.9599732757, blue: 0.9599732757, alpha: 1)
            self.popover                    = popover
        }
        popover?.show(relativeTo: sender.visibleRect, of: sender, preferredEdge: NSRectEdge.maxY)
    }
    
    
    //MARK:- Private methods
    private func resetScrollerBounds() {
        scrollView.frame = NSMakeRect(30, 0, self.bounds.width - 30, self.bounds.height)
        addButton.frame  = NSMakeRect(0, 0, 30, self.bounds.height)
    }
    
}
