//
//  MBTagsColor.swift
//  MBTagsControl
//
//  Created by Viorel Porumbescu on 30/11/2019.
//  Copyright © 2019 Viorel Porumbescu. All rights reserved.
//

class  MBTagsColor {
    
    static func newRandomColor() -> NSColor {
        if let color = availableColors.randomElement() {
            return color
        }
        return randomColor()
    }
    
    static func newRandomColor(alreadyUsed:[MBTagView]) -> NSColor {
        var randColor:NSColor = randomColor()
        if alreadyUsed.count >= availableColors.count { //Generate a random color
            return randColor
        }
        // Choose one color from available colors
        randColor = availableColors.randomElement() ?? randomColor()
        while  alreadyUsed.contains(where: { (current) -> Bool in
            return randColor == current.tagColor
        }) {
            randColor = availableColors.randomElement() ?? randomColor()
        }
        return randColor
    }
    
    private static func randomColor() -> NSColor {
        let red:CGFloat    = 100 / CGFloat(arc4random_uniform(900) + 100)
        let green:CGFloat  = 100 / CGFloat(arc4random_uniform(900) + 100)
        let blue:CGFloat   = 100 / CGFloat(arc4random_uniform(900) + 100)
        return  NSColor(red: red   , green:green , blue:blue, alpha:1)
    }
    
    /// Store all available colors for a tag. Keep in mind that, if a user will define more tags that current colors
    /// we will generate a new random color for it.
    /// This colors just assure us that the first x tags wll have this colors.
    private static var availableColors:[NSColor] = [
        NSColor(red: 0.725, green: 0.784, blue: 0.958, alpha: 1),
        NSColor(red: 0.604, green: 0.667, blue: 0.848, alpha: 1),
        NSColor(red: 0.238, green: 0.589, blue: 0.881, alpha: 1),
        NSColor(red: 0.191, green: 0.495, blue: 0.746, alpha: 1),
        NSColor(red: 0.318, green: 0.392, blue: 0.651, alpha: 1),
        NSColor(red: 0.227, green: 0.294, blue: 0.524, alpha: 1),
        NSColor(red: 0.449, green: 0.359, blue: 0.801, alpha: 1),
        NSColor(red: 0.351, green: 0.273, blue: 0.657, alpha: 1),
        NSColor(red: 0.599, green: 0.342, blue: 0.740, alpha: 1),
        NSColor(red: 0.941, green: 0.486, blue: 0.782, alpha: 1),
        NSColor(red: 0.815, green: 0.360, blue: 0.635, alpha: 1),
        NSColor(red: 0.921, green: 0.447, blue: 0.473, alpha: 1),
        NSColor(red: 0.835, green: 0.337, blue: 0.341, alpha: 1),
        NSColor(red: 0.890, green: 0.308, blue: 0.208, alpha: 1),
        NSColor(red: 0.737, green: 0.234, blue: 0.142, alpha: 1),
        NSColor(red: 0.811, green: 0.337, blue: 0.000, alpha: 1),
        NSColor(red: 0.889, green: 0.500, blue: 0.000, alpha: 1),
        NSColor(red: 0.987, green: 0.669, blue: 0.000, alpha: 1),
        NSColor(red: 0.993, green: 0.811, blue: 0.000, alpha: 1),
        NSColor(red: 0.993, green: 0.811, blue: 0.000, alpha: 1),
        NSColor(red: 0.656, green: 0.781, blue: 0.000, alpha: 1),
        NSColor(red: 0.566, green: 0.695, blue: 0.000, alpha: 1),
        NSColor(red: 0.262, green: 0.802, blue: 0.387, alpha: 1),
        NSColor(red: 0.222, green: 0.684, blue: 0.330, alpha: 1),
        NSColor(red: 0.203, green: 0.739, blue: 0.602, alpha: 1),
        NSColor(red: 0.170, green: 0.629, blue: 0.513, alpha: 1),
        NSColor(red: 0.240, green: 0.432, blue: 0.515, alpha: 1),
        NSColor(red: 0.221, green: 0.381, blue: 0.456, alpha: 1),
        NSColor(red: 0.207, green: 0.283, blue: 0.378, alpha: 1),
        NSColor(red: 0.176, green: 0.243, blue: 0.322, alpha: 1),
        NSColor(red: 0.169, green: 0.169, blue: 0.169, alpha: 1),
        NSColor(red: 0.149, green: 0.149, blue: 0.149, alpha: 1),
        NSColor(red: 0.310, green: 0.231, blue: 0.163, alpha: 1),
        NSColor(red: 0.365, green: 0.274, blue: 0.193, alpha: 1),
        NSColor(red: 0.554, green: 0.451, blue: 0.357, alpha: 1),
        NSColor(red: 0.832, green: 0.765, blue: 0.561, alpha: 1),
        NSColor(red: 0.938, green: 0.874, blue: 0.685, alpha: 1),
        NSColor(red: 0.501, green: 0.549, blue: 0.553, alpha: 1),
        NSColor(red: 0.465, green: 0.190, blue: 0.157, alpha: 1),
        NSColor(red: 0.394, green: 0.151, blue: 0.123, alpha: 1),
        NSColor(red: 0.217, green: 0.373, blue: 0.239, alpha: 1),
        NSColor(red: 0.186, green: 0.314, blue: 0.201, alpha: 1),
        NSColor(red: 0.362, green: 0.202, blue: 0.379, alpha: 1),
        NSColor(red: 0.303, green: 0.167, blue: 0.319, alpha: 1)
    ]
    
}
