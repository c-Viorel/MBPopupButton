//
//  MBSeparatorCell.swift
//  MBCustomPopupButton
//
//  Created by Viorel Porumbescu on 21/05/2020.
//  Copyright © 2020 Minglebit. All rights reserved.
//

import Cocoa


internal class MBSeparatorCell: NSTableCellView {

    private var separator:MBPopupSeparatorItem!

    override func draw(_ dirtyRect: NSRect) {
        guard let separator = separator else { return }
        let midY = dirtyRect.midY
        let bezier = NSBezierPath.init()
        bezier.move(to: NSMakePoint(separator.paddingLeft, midY))
        bezier.line(to: NSMakePoint(dirtyRect.width - separator.paddingRight, midY))
        bezier.lineWidth = separator.lineWidth
        separator.lineColor.setStroke()

        if separator.paddingRight > 0,
            separator.paddingLeft > 0 {
            bezier.lineCapStyle = .round
        }
        bezier.stroke()
    }

    internal func configureCell(with separator:MBPopupSeparatorItem) {
        self.separator = separator
        self.needsDisplay = true
    }
}
