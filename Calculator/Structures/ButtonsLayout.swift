//
//  Buttons.swift
//  Calculator
//
//  Created by Leonid Stefanenko on 02.01.2021.
//

import UIKit

class ButtonsLayout {
    
    var layout: Array<Array<Button>> = []
    var row: Array<Button> = []
    var basePadding: CGFloat = 0.0
    var baseWidth: CGFloat = 0.0
    var baseHeight: CGFloat = 0.0
    var fontSize: CGFloat = 0.0
    
    
    func addButtonToRow(button: Button) {
        self.row.append(button)
    }
    
    func addLastRowToLayout() {
        self.layout.append(self.row)
        self.row = []
    }
    
    func setBase(basePadding: CGFloat, baseWidth: CGFloat, baseHeight: CGFloat) {
        self.basePadding = basePadding
        self.baseWidth = baseWidth
        self.baseHeight = baseHeight
    }
    
    func createButton(
        rowNum: Int, positionNum: Int,
        x: CGFloat,
        y: CGFloat,
        width: CGFloat,
        height: CGFloat,
        title: String,
        tag: Int?,
        backgroundColor: UIColor,
        fontColor: UIColor,
        action: String
    )-> UIButton {
        let b = layout[rowNum][positionNum]
        
        let button = UIButton(
            frame: CGRect(
                x: b.x,
                y: b.y,
                width: CGFloat(b.widthInPlaces) * self.baseWidth - self.basePadding * 2,
                height: CGFloat(b.heightInPlaces) * self.baseHeight - self.basePadding * 2
            )
        )
        
        button.setTitleColor(b.fontColor, for: .normal)
        button.backgroundColor = b.backgroundColor
        button.setTitle(b.title, for: .normal)
        button.layer.cornerRadius = button.frame.height / 2
        button.layer.masksToBounds = true
        button.titleLabel?.font = UIFont(name: "Helvetica", size: self.fontSize)
        if (tag != nil) {
            button.tag = b.tag
        }
//        switch b.action {
//            case "zero":
//                button.addTarget(self, action: #selector(zeroPressed), for: .touchUpInside)
//            case "clear":
//                button.addTarget(self, action: #selector(clearResult), for: .touchUpInside)
//            case "operation":
//                button.addTarget(self, action: #selector(operationPressed(_:)), for: .touchUpInside)
//                button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: buttonSizePadding / 2, right: 0)
//            default:
//                button.addTarget(self, action: #selector(numberPressed(_:)), for: .touchUpInside)
//        }
        
        return button
    }
}


