//
//  MBTagPopoverController.swift
//  MBTagsControl
//
//  Created by Viorel Porumbescu on 12/07/2018.
//  Copyright © 2018 Viorel Porumbescu. All rights reserved.
//

import Cocoa
import Foundation


public class MBPopupListController: NSViewController, NSTableViewDelegate, NSTableViewDataSource, NSSearchFieldDelegate {

    var minPopoverWidth:CGFloat = 170

    @IBOutlet private var tableWithTags: NSTableView!
    @IBOutlet var searchField: NSSearchField!
    

    private var matches:[MBPopupItem] = []
    private var maxCellWidth:CGFloat = 0
    
    weak var popover:NSPopover?
    var newTagInserted:((MBTagView)->Void)? // o be removed
    
    var items:[MBPopupItem] = [] {
        didSet{
            if tableWithTags != nil {
                tableWithTags.reloadData()
            }
        }
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        tableWithTags.delegate     = self
        tableWithTags.dataSource   = self
        searchField.delegate       = self
        tableWithTags.target       = self
    }

    public override func viewWillAppear() {
        super.viewWillAppear()
        tableWithTags.reloadData()
    }

    /// Start search: Called on enter key
    @IBAction func startSearch(_ sender: Any) {
        //just reload data to see new results
        self.tableWithTags.reloadData()
    }
    
    /// Detect some important actions
    /// like arrow up/down, enter
    /// Override them  in order to provide
    public func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
        let row:Int        = self.tableWithTags.selectedRow
        var isSearchFocused = false
        
        if let responder   = NSApp.keyWindow?.firstResponder {
            if responder.isKind(of: NSTextView.self) {
                isSearchFocused = true
            }
        }
        switch commandSelector {
            /// Key up
        case #selector(moveUp):
            if isSearchFocused && row != -1 && matches.count > 0{
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
            if isSearchFocused && row != -1 && matches.count > 0{
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
            /// call designated action
            return true
        default:
            return false
        }
    }
    
    //MARK:- Tags table dataSource
    public func numberOfRows(in tableView: NSTableView) -> Int {
        matches = items
        
        if self.searchField.stringValue.count > 0 {
            matches = items.filter({$0.isIncluded(forString: searchField.stringValue )})
        }
            
        let height = tableWithTags.rowHeight
        if matches.count < 8 {
            adjustPopoverContentTo(newSize: NSMakeSize(minPopoverWidth > maxCellWidth ? minPopoverWidth : maxCellWidth, height * CGFloat(matches.count)))
        } else {
            adjustPopoverContentTo(newSize: NSMakeSize(minPopoverWidth > maxCellWidth ? minPopoverWidth : maxCellWidth, height * 8))
        }

        return  matches.count
    }



    public func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        let currentItem = matches[row]
        switch currentItem {
            case currentItem where currentItem.isKind(of: MBPopupSeparatorItem.self):
                return tableView.makeCellView(of: MBSeparatorCell.self) { (cell) in
                    cell.configureCell(with: currentItem as! MBPopupSeparatorItem)
            }
            case currentItem where currentItem.isKind(of: MBPopupIconAndTextItem.self):
                return tableView.makeCellView(of: MBTextAndImageCell.self) { (cell) in
                    cell.configureCell(with: currentItem as! MBPopupIconAndTextItem)
            }
            case currentItem where currentItem.isKind(of: MBPopupTextItem.self):
                return tableView.makeCellView(of: MBTextCell.self) { (cell) in
                    cell.configureCell(with: currentItem as! MBPopupTextItem)
            }
            default:
                break
        }
        
        return nil
        
    }
    public func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
            return AutoCompleteTableRowView()
        }
    
    private func adjustPopoverContentTo(newSize:NSSize) {
        self.popover?.contentSize = NSMakeSize(newSize.width, newSize.height + 30)
 
    }
    
}


class AutoCompleteTableRowView:NSTableRowView {
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


//MARK:- MBTagSearchField
/// override default NSSearchField to avoid drawing of the  focus ring mask.
public class MBSearchField:NSSearchField {
    public override func drawFocusRingMask() { return }
}
