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
open class MBPopupItem { public init() {} }

/// A
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
