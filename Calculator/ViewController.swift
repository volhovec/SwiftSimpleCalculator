//
//  ViewController.swift
//  Calculator
//
//  Created by Leonid Stefanenko on 01.01.2021.
//

import UIKit

class ViewController: UIViewController {
    
    let colorNumPad = UIColor.darkGray
    let colorButtonsFont = UIColor.white
    let colorActions = UIColor.orange
    let colorCancelButton = UIColor.lightGray
    
    let fontSize:CGFloat = 35
    
    @IBOutlet var holder: UIView!
    
    var firstNumber = 0
    var resultNumber = 0
    var currentOperations: Operation?
    
    var buttonSizePadding: CGFloat = 0
    
    enum Operation {
        case add, subtract, multiply, divide
    }
    
    
    
    private var resultLabel: UILabel = {
        let label = UILabel()
        label.text = "0"
        label.textColor = .white
        label.textAlignment = .right
        label.font = UIFont(name: "Helvetica", size: 80)
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        setupNumberPad()
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
                button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: buttonSizePadding / 2, right: 0)
            default:
                button.addTarget(self, action: #selector(numberPressed(_:)), for: .touchUpInside)
        }
        
        return button
    }
    
    private func setupNumberPad() {
        
        let buttonSize: CGFloat = view.frame.size.width / 4
        let buttonShift: CGFloat = buttonSizePadding / 2
        let buttonsTopPadding: CGFloat = holder.frame.size.height - buttonSizePadding
        
        buttonSizePadding = buttonSize * 0.1
        
        var button: UIButton
        //add button zero
        button = createButton(
            x: buttonShift,
            y: buttonsTopPadding - buttonSize,
            width: buttonSize * 3 - buttonSizePadding,
            height: buttonSize - buttonSizePadding,
            title: "0",
            tag: 1,
            backgroundColor: colorNumPad,
            fontColor: colorButtonsFont,
            action: "zero"
        )
        holder.addSubview(button)
        //add numeric buttons
        for i in 1...3 {
            for j in 1...3 {
                let num = i + 3 * (j - 1)
                button = createButton(
                    x: buttonSize * CGFloat(i - 1) + buttonShift,
                    y: buttonsTopPadding - (buttonSize * CGFloat(j + 1)),
                    width: buttonSize * 0.9,
                    height: buttonSize * 0.9,
                    title: "\(num)",
                    tag: num + 1,
                    backgroundColor: colorNumPad,
                    fontColor: colorButtonsFont,
                    action: "number"
                )
                holder.addSubview(button)
                
            }
        }
        //add clear button
        button = createButton(
            x: buttonShift,
            y: buttonsTopPadding - (buttonSize * 5),
            width: buttonSize * 3 - buttonSizePadding,
            height: buttonSize - buttonSizePadding,
            title: "Clear",
            tag: nil,
            backgroundColor: colorCancelButton,
            fontColor: colorButtonsFont,
            action: "clear"
        )
        holder.addSubview(button)
        //add operations buttons
        let operations = ["=","+", "-", "x", "÷"]
        for x in 0 ..< operations.count {
            button = createButton(
                x: buttonSize * 3 + buttonShift,
                y: buttonsTopPadding - (buttonSize * CGFloat(x+1)),
                width: buttonSize - buttonSizePadding,
                height: buttonSize - buttonSizePadding,
                title: operations[x],
                tag: x + 1,
                backgroundColor: colorActions,
                fontColor: colorButtonsFont,
                action: "operation"
            )
            holder.addSubview(button)
        }
        //set result frame
        resultLabel.frame = CGRect(
            x: buttonSizePadding,
            y: buttonsTopPadding - (buttonSize * 5) - 110.0,
            width: view.frame.size.width - buttonSizePadding * 2,
            height: 100
        )
        holder.addSubview(resultLabel)
      
    }
    
    @objc func clearResult() {
        resultLabel.text = "0"
        currentOperations = nil
        firstNumber = 0
    }
    
    @objc func zeroPressed() {
        if resultLabel.text != "0" {
            if let text = resultLabel.text {
                resultLabel.text = "\(text)\(0)"
            }
        }
    }
    
    
    @objc func numberPressed(_ sender: UIButton) {
        let tag = sender.tag - 1
        
        if resultLabel.text == "0" {
            resultLabel.text = "\(tag)"
        }
        else if let text = resultLabel.text {
            resultLabel.text = "\(text)\(tag)"
        }
    }
    
    @objc func operationPressed(_ sender: UIButton) {
        let tag = sender.tag
        
        if let text = resultLabel.text, let value = Int(text), firstNumber == 0 {
            firstNumber = value
            resultLabel.text = "0"
        }
        
        if tag == 1 {
            if let operation = currentOperations {
                var secondNumber = 0
                if let text = resultLabel.text, let value = Int(text) {
                    secondNumber = value
                }
                
                switch operation {
                case .add:
                    
                    firstNumber = firstNumber + secondNumber
                    secondNumber = 0
                    resultLabel.text = "\(firstNumber)"
                    currentOperations = nil
                    firstNumber = 0
                    
                    break
                    
                case .subtract:
                    firstNumber = firstNumber - secondNumber
                    secondNumber = 0
                    resultLabel.text = "\(firstNumber)"
                    currentOperations = nil
                    firstNumber = 0
                    
                    break
                    
                case .multiply:
                    firstNumber = firstNumber * secondNumber
                    secondNumber = 0
                    resultLabel.text = "\(firstNumber)"
                    currentOperations = nil
                    firstNumber = 0
                    
                    break
                    
                case .divide:
                    firstNumber = firstNumber / secondNumber
                    secondNumber = 0
                    resultLabel.text = "\(firstNumber)"
                    currentOperations = nil
                    firstNumber = 0
                    break
                }
            }
        }
        else if tag == 2 {
            currentOperations = .add
        }
        else if tag == 3 {
            currentOperations = .subtract
        }
        else if tag == 4 {
            currentOperations = .multiply
        }
        else if tag == 5 {
            currentOperations = .divide
        }
        
    }
    
}
