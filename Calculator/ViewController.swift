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
    let fontSizeResultLarge: CGFloat = 100
    let fontSizeResultMedium: CGFloat = 85
    let fontSizeResultSmall: CGFloat = 75
    
    @IBOutlet var appMainView: UIView!
    
    var firstNumber = 0
    var resultNumber = 0 {
        didSet {
            updateResultLabel()
        }
    }
    var currentOperations: Operation?
    
    enum Operation {
        case add, subtract, multiply, divide
    }
    
    private var resultLabel: UILabel = {
        let label = UILabel()
        label.text = "0"
        label.textColor = .white
        label.textAlignment = .right
        label.font = UIFont(name: "Helvetica", size: 100)
        return label
    }()
    
    private func updateResultLabel() {
        var text = "\(resultNumber)"
        var length = text.count
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        var drawView = UIView()

        //Setup Constraints for `drawView`
//        drawView.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            drawView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 25),
//            drawView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -25),
//            drawView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 15),
//            drawView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -15)
//        ])
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        setupNumberPad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //setupNumberPad()
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
    
    var resultLabelHeight: CGFloat = 100
    var buttonCellWidth: CGFloat = 0
    var buttonWidth: CGFloat = 0
    var buttonHeight: CGFloat = 0
    var buttonCellHeight: CGFloat = 0
    var buttonVerticalShift: CGFloat = 0
    var buttonHorizontalShift: CGFloat = 0
    var buttonsVerticalPadding: CGFloat = 0
    var buttonsHorizontalPadding: CGFloat = 0
    var appMainViewHeight: CGFloat = 0
    var appMainViewWidth: CGFloat = 0
    //var buttonsTopPadding: CGFloat = 0
    
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
            tag: nil,
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
                tag: x + 1,
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
    
//    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
//        super.willTransition(to: newCollection, with: coordinator)
//
//        coordinator.animate(alongsideTransition: { (context) in
//            guard let windowInterfaceOrientation = self.windowInterfaceOrientation else { return }
//
//            if windowInterfaceOrientation.isLandscape {
//                // activate landscape changes
//            } else {
//                // activate portrait changes
//            }
//        })
//    }
//
//    private var windowInterfaceOrientation: UIInterfaceOrientation? {
//        return UIApplication.shared.windows.first?.windowScene?.interfaceOrientation
//    }
    
    @objc func clearResult() {
        resultNumber = 0
        firstNumber = 0
        
        currentOperations = nil
    }
    
    @objc func zeroPressed() {
        if resultNumber != 0 {
            resultNumber = resultNumber * 10
        }
    }
    
    
    @objc func numberPressed(_ sender: UIButton) {
        let tag = sender.tag - 1
        
        if resultNumber == 0 {
            resultNumber = tag
        } else {
            resultNumber = resultNumber * 10 + tag
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
