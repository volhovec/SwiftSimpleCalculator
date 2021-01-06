//
//  ViewController.swift
//  Calculator
//
//  Created by Leonid Stefanenko on 01.01.2021.
//

import UIKit

class ViewController: UIViewController {
    
    // MARK: interface colors
    let colorNumPad = UIColor.darkGray
    let colorButtonsFont = UIColor.white
    let colorActions = UIColor.orange
    let colorCancelButton = UIColor.lightGray
    
    // MARK: fonts sizes
    let fontSize:CGFloat = 35
    let fontSizeResultLarge: CGFloat = 100
    let fontSizeResultMedium: CGFloat = 85
    let fontSizeResultSmall: CGFloat = 75
    
    // MARK: outlets
    @IBOutlet var appMainView: UIView!
    
    // MARK: calculator properties
    var currentOperations: Operation?
    var firstNumber: Double = 0
    var secondNumber: Double = 0
    var lastKeyTag = 0
    var resultNumber: Double = 0 {
        didSet {
            updateResultLabel()
        }
    }
    
    enum Operation {
        case add, subtract, multiply, divide
    }
    
    // MARK: interface stuff
    private var resultLabel: UILabel = {
        let label = UILabel()
        label.text = "0"
        label.textColor = .white
        label.textAlignment = .right
        label.font = UIFont(name: "Helvetica", size: 100)
        return label
    } ()
    
    // MARK: view size parameters
    var appMainViewHeight: CGFloat = 0
    var appMainViewWidth: CGFloat = 0
    
    var buttonCellWidth: CGFloat = 0
    var buttonWidth: CGFloat = 0
    var buttonHeight: CGFloat = 0
    var buttonCellHeight: CGFloat = 0
    var buttonVerticalShift: CGFloat = 0
    var buttonHorizontalShift: CGFloat = 0
    var buttonsVerticalPadding: CGFloat = 0
    var buttonsHorizontalPadding: CGFloat = 0
    
    var resultLabelHeight: CGFloat = 100
    
    //
    private func updateResultLabel() {
        let resultParts = modf(resultNumber)
        var text = "\(resultNumber)"
        var length = text.count
        if resultParts.1 == 0 {
            let numberComponent = text.components(separatedBy :".")
            text = "\(numberComponent[0])"
        }
        //
        
        //
        if resultNumber < 0 {
            length += 1
        }
        //
        if (length < 7) {
            resultLabel.font = UIFont(name: "Helvetica", size: fontSizeResultLarge)
        } else if (length == 7) {
            resultLabel.font = UIFont(name: "Helvetica", size: fontSizeResultMedium)
        } else {
            resultLabel.font = UIFont(name: "Helvetica", size: fontSizeResultSmall)
            if (resultNumber > 7) {
                if (length > 8) {
                    let num: Double = round(10000 * Double(resultNumber) / Double(pow(10.0, Double(length))))
                    text = "\(num / 1000)e\(length)"
                }
            }
        }
        resultLabel.text = text
    }
    
    private func createButton(
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
        let button = UIButton(frame: CGRect(x: x, y: y, width: width, height: height))
        
        button.setTitleColor(fontColor, for: .normal)
        button.backgroundColor = backgroundColor
        button.setTitle(title, for: .normal)
        button.layer.cornerRadius = button.frame.height / 2
        button.layer.masksToBounds = true
        button.titleLabel?.font = UIFont(name: "Helvetica", size: fontSize)
        if (tag != nil) {
            button.tag = tag ?? 50
        }
        switch action {
            case "zero":
                button.addTarget(self, action: #selector(zeroPressed), for: .touchUpInside)
            case "clear":
                button.addTarget(self, action: #selector(clearResult), for: .touchUpInside)
            case "operation":
                button.addTarget(self, action: #selector(operationPressed(_:)), for: .touchUpInside)
                button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: buttonsVerticalPadding / 2, right: 0)
            default:
                button.addTarget(self, action: #selector(numberPressed(_:)), for: .touchUpInside)
        }
        
        return button
    }
    
    private func calcViewParams(width: CGFloat, height: CGFloat) {
        buttonCellWidth = width / 4
        if (width > height) {
            //landscape layout
            buttonCellHeight = (height - resultLabelHeight) / 5
        } else {
            //portrait layout
            buttonCellHeight = buttonCellWidth
        }
        buttonsVerticalPadding = buttonCellHeight * 0.1
        buttonsHorizontalPadding = buttonCellWidth * 0.1
        //
        buttonHeight = buttonCellHeight - buttonsVerticalPadding
        buttonWidth = buttonCellWidth - buttonsHorizontalPadding
        //
        buttonVerticalShift = buttonsVerticalPadding / 2
        buttonHorizontalShift = buttonsHorizontalPadding / 2
        //buttonsTopPadding = height - buttonSizePadding
    }
    
    private func setupNumberPad() {
        for subView in appMainView.subviews {
            subView.removeFromSuperview()
        }
        
        appMainView.setNeedsDisplay()
        appMainViewHeight = appMainView.frame.size.height
        appMainViewWidth = appMainView.frame.size.width
        calcViewParams(
            width: appMainView.frame.size.width,
            height: appMainView.frame.size.height
        )
        
        var button: UIButton
        //add button zero
        button = createButton(
            x: buttonHorizontalShift,
            y: appMainViewHeight - buttonCellHeight,
            width: buttonCellWidth * 3 - buttonsHorizontalPadding,
            height: buttonCellHeight - buttonsVerticalPadding,
            title: "0",
            tag: 1,
            backgroundColor: colorNumPad,
            fontColor: colorButtonsFont,
            action: "zero"
        )
        button.setNeedsDisplay()
        appMainView.addSubview(button)
        //add numeric buttons
        for i in 1...3 {
            for j in 1...3 {
                let num = i + 3 * (j - 1)
                button = createButton(
                    x: buttonCellWidth * CGFloat(i - 1) + buttonHorizontalShift,
                    y: appMainViewHeight - (buttonCellHeight * CGFloat(j + 1)),
                    width: buttonWidth,
                    height: buttonHeight,
                    title: "\(num)",
                    tag: num + 1,
                    backgroundColor: colorNumPad,
                    fontColor: colorButtonsFont,
                    action: "number"
                )
                button.setNeedsDisplay()
                appMainView.addSubview(button)
                
            }
        }
        //add clear button
        button = createButton(
            x: buttonHorizontalShift,
            y: appMainViewHeight - (buttonCellHeight * 5),
            width: buttonCellWidth * 3 - buttonsHorizontalPadding,
            height: buttonHeight,
            title: "Clear",
            tag: 20,
            backgroundColor: colorCancelButton,
            fontColor: colorButtonsFont,
            action: "clear"
        )
        button.setNeedsDisplay()
        appMainView.addSubview(button)
        //add operations buttons
        let operations = ["=","+", "-", "x", "÷"]
        for x in 0 ..< operations.count {
            button = createButton(
                x: buttonCellWidth * 3 + buttonHorizontalShift,
                y: appMainViewHeight - (buttonCellHeight * CGFloat(x+1)),
                width: buttonWidth,
                height: buttonHeight,
                title: operations[x],
                tag: 21 + x,
                backgroundColor: colorActions,
                fontColor: colorButtonsFont,
                action: "operation"
            )
            button.setNeedsDisplay()
            appMainView.addSubview(button)
        }
        //set result frame
        resultLabel.frame = CGRect(
            x: buttonHorizontalShift,
            y: appMainViewHeight - (buttonCellHeight * 5) - resultLabelHeight,
            width: appMainViewWidth - buttonsHorizontalPadding,
            height: 100
        )
        resultLabel.setNeedsDisplay()
        appMainView.addSubview(resultLabel)
      
    }
    
    @objc func clearResult() {
        resultNumber = 0
        firstNumber  = 0
        secondNumber = 0
        
        currentOperations = nil
        
        lastKeyTag = 20
    }
    
    @objc func zeroPressed() {
        if resultNumber != 0 {
            resultNumber = resultNumber * 10
        }
        
        lastKeyTag = 0
    }
    
    @objc func numberPressed(_ sender: UIButton) {
        let tag = sender.tag - 1
        
        if resultNumber == 0 {
            resultNumber = Double(tag)
        } else {
            resultNumber = resultNumber * 10 + Double(tag)
        }
        
        lastKeyTag = sender.tag
    }
    
    @objc func operationPressed(_ sender: UIButton) {
        let tag = sender.tag
        //print("tag \(tag)")
        
        if let text = resultLabel.text,
           let value = Double(text),
           firstNumber == 0
        {
            firstNumber = Double(value)
            //resultNumber = 0
        }

        if tag == 21 {
            if lastKeyTag == 21 {
                resultNumber = secondNumber
            }
            //print("currentOperations - \(currentOperations)")
            //print("firstNumber - \(firstNumber)")
            //print("resultNumber - \(resultNumber)")
            if let operation = currentOperations {
                switch operation {
                    case .add:
                        firstNumber = firstNumber + resultNumber
                        break
                    case .subtract:
                        firstNumber = firstNumber - resultNumber
                        break
                    case .multiply:
                        firstNumber = firstNumber * resultNumber
                        break
                    case .divide:
                        firstNumber = firstNumber / resultNumber
                        break
                }
                secondNumber = resultNumber
                resultNumber = firstNumber
                firstNumber = 0
                
                //currentOperations = nil
            }
        } else {
            if tag == 22 {
                currentOperations = .add
            }
            else if tag == 23 {
                currentOperations = .subtract
            }
            else if tag == 24 {
                currentOperations = .multiply
            }
            else if tag == 25 {
                currentOperations = .divide
            }
            resultNumber = 0
            secondNumber = 0
        }
        
        lastKeyTag = tag
    }
    
    // MARK: overrides
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        setupNumberPad()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
}
