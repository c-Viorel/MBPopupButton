//
//  ReuseIdentifying.swift
//  Tour3Systems
//
//  Created by Viorel Porumbescu on 08/12/2018.
//  Copyright © 2018 Viorel Porumbescu. All rights reserved.
//

import Foundation
import Cocoa

protocol ReuseIdentifying {
    static var reuseIdentifier: NSUserInterfaceItemIdentifier { get }
}

extension ReuseIdentifying {
    static var reuseIdentifier: NSUserInterfaceItemIdentifier {
        let cellId = String(describing: self)
        return NSUserInterfaceItemIdentifier.init(cellId)
    }
}

extension NSTableCellView: ReuseIdentifying {}


extension NSTableView {
    func makeCellView<CellClass: NSTableCellView>(of  cellType: CellClass.Type,
                                                         for indexPath: IndexPath,
                                                         configure: ((CellClass) -> Void) = { _ in }) -> NSTableCellView {

        let cell = makeView(withIdentifier: cellType.reuseIdentifier, owner: self)
        if let typedCell = cell as? CellClass {
            configure(typedCell)
            return typedCell
        }

        return NSTableCellView()
    }
}
