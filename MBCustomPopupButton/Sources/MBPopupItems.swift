//
//  MBPopupItems.swift
//  MBCustomPopupButton
//
//  Created by Viorel Porumbescu on 21/05/2020.
//  Copyright © 2020 Minglebit. All rights reserved.
//

import Cocoa

/// The base class for all items accepted  by our popup control
/// DO NOT INIT objects  of this class.
open class MBPopupItem:NSObject { fileprivate override init() {} }
internal extension MBPopupItem {
    var isSeparator:Bool { isKind(of: MBPopupSeparatorItem.self)}
    func isIncluded(forString search:String) -> Bool {
        if isSeparator {return true}
        if let item = self as? MBPopupTextItem {
            return item.title.lowercased().contains(search.lowercased())
        }
        return false
    }
}


/// A class that describe the properties for a separator item
open class MBPopupSeparatorItem: MBPopupItem {
    open var lineColor: NSColor
    open var lineWidth: CGFloat
    open var paddingLeft: CGFloat
    open var paddingRight: CGFloat

    public override init() {
        lineColor = .lightGray
        lineWidth = 1
        paddingLeft = 0
        paddingRight = 0
        super.init()
    }

    public init(withColor color: NSColor) {
        lineColor = color
        lineWidth = 1
        paddingLeft = 0
        paddingRight = 0
        super.init()
    }

    public init(withColor color: NSColor, lineHeight height: CGFloat) {
        lineColor = color
        lineWidth = height
        paddingLeft = 0
        paddingRight = 0
        super.init()
    }

    public init(withColor color: NSColor, lineHeight height: CGFloat, paddingLeft left: CGFloat, paddingRight right: CGFloat = 0) {
        lineColor = color
        lineWidth = height
        paddingLeft = left
        paddingRight = right
        super.init()
    }
}

/// A class that describe the properties for an text  item
open class MBPopupTextItem: MBPopupItem {
    
    open var title:String
    open var titleColor: NSColor
    open var isSelected:Bool = false
    
    public init(withTitle title:String,  color: NSColor = .lightGray) {
        self.title = title
        titleColor = color
        super.init()
    }
}

/// A class that describe the properties for an item that along title, will also contain an icon.
open class MBPopupIconAndTextItem: MBPopupTextItem {
    
    open var icon:NSImage
    
    public init(withTitle title:String, image:NSImage,  color: NSColor = .lightGray) {
        icon = image
        super.init(withTitle: title, color: color)
    }
}
