//
//  MBTextCell.swift
//  MBCustomPopupButton
//
//  Created by Viorel Porumbescu on 21/05/2020.
//  Copyright © 2020 Minglebit. All rights reserved.
//

import Cocoa

internal class MBTextCell: NSTableCellView {

    @IBOutlet var selectionImage:NSImageView!
    @IBOutlet var titleFiled:NSTextField!

    private var textItem:MBPopupTextItem!


    internal func configureCell(with item:MBPopupTextItem) {
        textItem = item
        selectionImage.animator().isHidden = !item.isSelected
        titleFiled.stringValue = item.title
    }
}
