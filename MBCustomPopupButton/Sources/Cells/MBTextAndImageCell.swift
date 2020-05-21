//
//  MBTextAndImageCell.swift
//  MBCustomPopupButton
//
//  Created by Viorel Porumbescu on 21/05/2020.
//  Copyright © 2020 Minglebit. All rights reserved.
//

import Cocoa

internal class MBTextAndImageCell: NSTableCellView {

    @IBOutlet var selectionImage:NSImageView!
    @IBOutlet var titleFiled:NSTextField!
    @IBOutlet var itemImage:NSImageView!

    private var textItem:MBPopupTextItem!


    internal func configureCell(with item:MBPopupIconAndTextItem) {
        textItem = item
        selectionImage.animator().isHidden = !item.isSelected
        titleFiled.stringValue = item.title
        itemImage.image = item.icon.resizeWhileMaintainingAspectRatioToSize(size: itemImage.frame.size)
    }
}
