//
//  MBTagPopoverController.swift
//  MBTagsControl
//
//  Created by Viorel Porumbescu on 12/07/2018.
//  Copyright © 2018 Viorel Porumbescu. All rights reserved.
//

import Cocoa
import Foundation


public class MBTagPopoverController: NSViewController, NSTableViewDelegate, NSTableViewDataSource, NSSearchFieldDelegate {

    var minPopoverWidth:CGFloat = 170

    @IBOutlet weak var tableWithTags: NSTableView!
    @IBOutlet weak var searchField: NSSearchField!
    

    private var matches:[MBTagView] = []
    private var maxTagWidth:CGFloat = 0
    
    weak var popover:NSPopover?
    var newTagInserted:((MBTagView)->Void)?
    var suggestionTags:[MBTagView] = [] {
        didSet{
            maxTagWidth = 0
            suggestionTags.forEach { (tag) in
                if maxTagWidth < tag.frame.width {
                    maxTagWidth = tag.frame.width
                }
            }
            if tableWithTags != nil {
                tableWithTags.reloadData()
            }
        }
    }
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        tableWithTags.delegate     = self
        tableWithTags.dataSource   = self
        searchField.delegate       = self
        tableWithTags.target       = self
        tableWithTags.doubleAction = #selector(insert(_:))
    }
    

    override func viewWillAppear() {
        super.viewWillAppear()
        tableWithTags.reloadData()
    }
    
  
    /// Start search: Called on enter key
    @IBAction func startSearch(_ sender: Any) {
        //just reload data to see new results
        self.tableWithTags.reloadData()
    }
    
    /// Insert current selected tag, or create a new one if nothing is selected
    @objc func insert(_ sender:AnyObject) {
        if tableWithTags.selectedRow != -1 {
            let tag = MBTagView.init(with: matches[tableWithTags.selectedRow].title, color: matches[tableWithTags.selectedRow].tagColor, id: matches[tableWithTags.selectedRow].id)
            newTagInserted?(tag)
            return
        } else {
            if searchField.stringValue.count > 0 {
                
                if suggestionTags.contains(where: { (current) -> Bool in
                    return current.title.lowercased() == searchField.stringValue.lowercased()
                }) {
                    /// A tag with an identic name exist, but user dindn't selected from susgestions.
                    /// we don't create a new tag. We will use the one that already exist
                    let tags = suggestionTags.filter { (current) -> Bool in
                        return current.title.lowercased() == searchField.stringValue.lowercased()
                    }
                    if tags.count > 0 {
                        let tag = MBTagView.init(with: tags[0].title, color: tags[0].tagColor, id: tags[0].id)
                        newTagInserted?(tag)
                    }
                    
                } else {
                    // The tag does not exist. Create a new one and add it to the tag controller.
                    let tag            = MBTagView.init(with: searchField.stringValue, color: MBTagsColor.newRandomColor(alreadyUsed: suggestionTags))
                    newTagInserted?(tag)
                }
            }
        }
    }
    
    /// Detect some important actions, and override
    /// like arrow up/down, enter
    func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
        let row:Int        = self.tableWithTags.selectedRow
        var isSeachFosused = false
        
        if let responder   = NSApp.keyWindow?.firstResponder {
            if responder.isKind(of: NSTextView.self) {
                isSeachFosused = true
            }
        }
        
        switch commandSelector {
            /// Key up
        case #selector(moveUp):
            if isSeachFosused && row != -1 && matches.count > 0{
                self.tableWithTags.selectRowIndexes(IndexSet(integer: row - 1), byExtendingSelection: false)
                self.tableWithTags.scrollRowToVisible(self.tableWithTags.selectedRow)
            }
            if row == -1 && matches.count > 0 {
                self.tableWithTags.selectRowIndexes(IndexSet(integer: 0), byExtendingSelection: false)
                self.tableWithTags.scrollRowToVisible(self.tableWithTags.selectedRow)
            }
            searchField.currentEditor()?.selectedRange = NSMakeRange(searchField.stringValue.count, 0)
            return true
            /// key down
        case #selector(moveDown):
            if isSeachFosused && row != -1 && matches.count > 0{
                self.tableWithTags.selectRowIndexes(IndexSet(integer: row + 1), byExtendingSelection: false)
                self.tableWithTags.scrollRowToVisible(self.tableWithTags.selectedRow)
            }
            if row == -1 && matches.count > 0 {
                self.tableWithTags.selectRowIndexes(IndexSet(integer: 0), byExtendingSelection: false)
                self.tableWithTags.scrollRowToVisible(self.tableWithTags.selectedRow)
            }
            return true
            ///Enter key
        case #selector(insertNewline):
            self.insert(tableWithTags)
            return true
        default:
            return false
        }
    
    }
    
    //MARK:- Tags table dataSource
    func numberOfRows(in tableView: NSTableView) -> Int {
        matches = suggestionTags
        if self.searchField.stringValue.count > 0 {
            matches = suggestionTags.filter({ (tag) -> Bool in
                if tag.title.lowercased().contains(self.searchField.stringValue.lowercased()) {
                    return true
                }
                return false
            })
        }
        let height = tableWithTags.rowHeight
        if matches.count < 8 {
            adjustPopoverContentTo(newSize: NSMakeSize(minPopoverWidth > maxTagWidth ? minPopoverWidth : maxTagWidth, height * CGFloat(matches.count)))
        } else {
            adjustPopoverContentTo(newSize: NSMakeSize(minPopoverWidth > maxTagWidth ? minPopoverWidth : maxTagWidth, height * 8))
        }

        return  matches.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        var cellView = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "myCell"), owner: self) as? MBTagCellView
        if cellView == nil{
            cellView                  = MBTagCellView(frame: NSZeroRect)
            let textField             = NSTextField(frame: NSZeroRect)
            textField.isBezeled       = false
            textField.drawsBackground = false
            textField.isEditable      = false
            textField.isSelectable    = false
            textField.appearance      = NSAppearance.init(named: NSAppearance.Name.vibrantDark)
            cellView!.addSubview(textField)
            cellView!.textField       = textField
            cellView!.identifier      = NSUserInterfaceItemIdentifier(rawValue: "myCell")
        
            textField.setFrameOrigin(NSMakePoint(15, 2))
            
        }
        
        cellView!.tagColor = matches[row].tagColor
        cellView!.textField!.stringValue = matches[row].title
        
        
        return cellView
        
    }
        func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
            return AutoCompleteTableRowView()
        }
    
    private func adjustPopoverContentTo(newSize:NSSize) {
        self.popover?.contentSize = NSMakeSize(newSize.width, newSize.height + 30)
 
    }
    
}


class AutoCompleteTableRowView:NSTableRowView{
    override func drawSelection(in dirtyRect: NSRect) {
        if self.selectionHighlightStyle != .none{
            let selectionRect = self.bounds
            
            #colorLiteral(red: 0.9575719237, green: 0.9575719237, blue: 0.9575719237, alpha: 1).setFill()
            let selectionPath = NSBezierPath(roundedRect: selectionRect, xRadius: 0.0, yRadius: 0.0)
            selectionPath.fill()
            
            let  line = NSBezierPath() // .init(roundedRect: dirtyRect, xRadius: 0, yRadius: 0)
            line.move(to: NSMakePoint(1, 0))
            line.line(to: NSMakePoint(1, dirtyRect.height))
            line.lineWidth = 1
            #colorLiteral(red: 0.7378575206, green: 0.2320150733, blue: 0.1414205134, alpha: 1).setStroke()
            line.stroke()
        }
    }
    
    override var interiorBackgroundStyle:NSView.BackgroundStyle{
        get{
            if self.isSelected {
                return NSView.BackgroundStyle.dark
            }
            else{
                return NSView.BackgroundStyle.light
            }
        }
    }
}


//MARK:- MBTagCellView
class MBTagCellView:NSTableCellView {
    
    var tagColor:NSColor = NSColor.red {
        didSet {
            self.needsDisplay = true
        }
    }
    
    override var backgroundStyle: NSView.BackgroundStyle {
        didSet {
            if self.backgroundStyle == .light {
                self.textField?.textColor = #colorLiteral(red: 0.05882352963, green: 0.180392161, blue: 0.2470588237, alpha: 1) // Not selected
                self.textField?.font = NSFont.systemFont(ofSize: 12)
            } else if self.backgroundStyle == .dark {
                self.textField?.textColor = #colorLiteral(red: 0.05882352963, green: 0.180392161, blue: 0.2470588237, alpha: 1) // Selected
                self.textField?.font      = NSFont.boldSystemFont(ofSize: 12)
            }
        }
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        let bez = NSBezierPath.init(ovalIn: NSMakeRect(7, 8, 8, 8))
        tagColor.setFill()
        bez.fill()
    }
    
    
}


//MARK:- MBTagSearchField
class MBTagSearchField:NSSearchField {
    override func awakeFromNib() {
    }
    
    override func drawFocusRingMask() {
        return
    }
    
}






