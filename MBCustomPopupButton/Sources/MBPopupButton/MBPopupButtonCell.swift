//
//  MBButtonCell.swift
//  Dynamic Wallpaper
//
//  Created by Viorel Porumbescu on 07/05/2019.
//  Copyright © 2019 Minglebit. All rights reserved.
//

import Cocoa

open class MBPopupButtonCell: NSButtonCell {
    open override func awakeFromNib() {
        showsBorderOnlyWhileMouseInside = true
    }

    open override func drawBezel(withFrame _: NSRect, in _: NSView) {}

    open override func drawImage(_: NSImage, withFrame _: NSRect, in _: NSView) {}

    open override func drawTitle(_: NSAttributedString, withFrame frame: NSRect, in controlView: NSView) -> NSRect {
        super.drawTitle(NSAttributedString(string: ""), withFrame: frame, in: controlView)
    }
}
