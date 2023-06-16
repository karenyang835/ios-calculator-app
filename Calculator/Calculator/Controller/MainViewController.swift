//
//  Calculator - MainViewController.swift
//  Created by yagom. 
//  Copyright © yagom. All rights reserved.
//  last modified by karen, Mary.

import UIKit

final class MainViewController: UIViewController {
    private var expression = String()
    private var operandsValue = String()
    private var operatorValue = String()
    private var isResult = false
    @IBOutlet weak private var operandsLabel: UILabel!
    @IBOutlet weak private var operatorLabel: UILabel!
    @IBOutlet weak private var expressionStackView: UIStackView!
    @IBOutlet weak private var expressionScrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        clearAll()
    }

    private func clearAll() {
        clearOperands()
        clearOperator()
        clearExpression()
        clearStackView()
    }
    
    private func clearExpression() {
        expression = CalculatorNameSpace.empty
    }
    
    private func clearOperands(labelUpdate: Bool = true) {
        operandsValue = CalculatorNameSpace.empty
        if labelUpdate {
            operandsLabel.text = CalculatorNameSpace.zero
        }
    }
    
    private func clearOperator() {
        operatorValue = CalculatorNameSpace.empty
        operatorLabel.text = CalculatorNameSpace.empty
    }
    
    private func clearStackView() {
        guard expressionStackView.subviews.count > 0 else { return }
        
        expressionStackView.subviews.forEach { subview in
            subview.removeFromSuperview()
        }
    }
    
    @IBAction private func tapOperatorButton(_ sender: UIButton) {
        guard let `operator` = sender.currentTitle else { return }
        if isResult { isResult = false }
        if operandsValue.isEmpty == false {
            expression.append(operatorValue + operandsValue)
            insertStackView(with: operatorValue, operandsValue)
        }
        
        updateOperator(to: `operator`)
        clearOperands()
    }
    
    private func insertStackView(with strings: String...) {
        let labels = strings.map { createFormulaLabel(text: $0) }
        let subStackView = createSubStackView(with: labels)
        
        expressionStackView.addArrangedSubview(subStackView)
        expressionScrollView.layoutIfNeeded()
        expressionScrollView.scrollToBottom()
    }
    
    private func updateOperator(to `operator`: String) {
        operatorValue = `operator`
        operatorLabel.text = `operator`
    }
    
    @IBAction private func tapNumberButton(_ sender: UIButton) {
        if isResult {
            isResult = false
            clearAll()
        }
        guard let selectedNumber = sender.currentTitle else { return }
        
        switch (operandsValue, selectedNumber) {
        case (CalculatorNameSpace.zero, _),
             (CalculatorNameSpace.empty, _):
             updateOperands(to: selectedNumber)
        default:
             updateOperands(to: operandsValue + selectedNumber)
        }

        if let formattedNumber = Double(operandsValue)?.changeNumberFormat() {
            operandsLabel.text = formattedNumber
        }
    }
    
    @IBAction private func tapZeroButton(_ sender: UIButton) {
        if isResult {
            isResult = false
            clearAll()
        }

        switch operandsValue {
        case CalculatorNameSpace.zero,
            CalculatorNameSpace.empty where expression.isEmpty:
            return
        default:
            updateOperands(to: operandsValue + CalculatorNameSpace.zero)
        }
        
        if let formattedNumber = Double(operandsValue)?.changeNumberFormat() {
            operandsLabel.text = formattedNumber
        }
    }
    
    @IBAction private func tapDoubleZeroButton(_ sender: UIButton) {
        if isResult {
            isResult = false
            clearAll()
        }
        
        switch operandsValue {
        case CalculatorNameSpace.zero,
             CalculatorNameSpace.empty:
            return
        default:
             updateOperands(to: operandsValue + CalculatorNameSpace.doubleZero)
        }

        if let formattedNumber = Double(operandsValue)?.changeNumberFormat() {
            operandsLabel.text = formattedNumber
        }
    }
    
    @IBAction private func tapDotButton(_ sender: UIButton) {
        if isResult {
            isResult = false
            clearAll()
        }
        if operandsValue.contains(CalculatorNameSpace.dot) { return }
        
        switch operandsValue {
        case CalculatorNameSpace.empty:
             updateOperands(to: CalculatorNameSpace.zero + CalculatorNameSpace.dot)
        case CalculatorNameSpace.zero:
             updateOperands(to: CalculatorNameSpace.dot)
        default:
             updateOperands(to: operandsValue + CalculatorNameSpace.dot)
        }

        if let formattedNumber = Double(operandsValue)?.changeNumberFormat() {
            operandsLabel.text = formattedNumber
        }
    }
    
    private func updateOperands(to value: String, willUpdateLabel: Bool = true) {
        operandsValue = value
        if willUpdateLabel {
            operandsLabel.text = value
        }
    }
    
    @IBAction private func tapEqualsButton(_ sender: UIButton) {
        do {
            if operandsValue.isEmpty == false {
                expression.append(operatorValue + operandsValue)
                insertStackView(with: operatorValue, operandsValue)
            }
            
            var formula = ExpressionParser.parse(from: expression)
            let result = try formula.result()
            let formattedResult = result.changeNumberFormat() ?? CalculatorNameSpace.nan

            clearOperator()
            clearExpression()
            operandsLabel.text = formattedResult
            updateOperands(to: "\(result)", willUpdateLabel: false)
            isResult = true
        } catch {
            operandsLabel.text = CalculatorNameSpace.nan
            clearOperands(labelUpdate: false)
        }
    }
    
    @IBAction private func tapAllClearButton(_ sender: UIButton) {
        clearAll()
    }
    
    @IBAction private func tapClearEntryButton(_ sender: UIButton) {
        clearOperands()
    }
    
    @IBAction private func tapChangeSignButton(_ sender: UIButton) {
        guard operandsValue.isEmpty == false else { return }
        if operandsValue.hasPrefix(CalculatorNameSpace.minus) {
            updateOperands(to: String(operandsValue.dropFirst()))
        } else {
            updateOperands(to: CalculatorNameSpace.minus + operandsValue)
        }
    }
}

extension MainViewController {
    private func createFormulaLabel(text: String) -> UILabel {
        let label = UILabel()
        
        label.font = UIFont.preferredFont(forTextStyle: .title3)
        label.textColor = .white
        label.text = text
        
        return label
    }
    
    private func createSubStackView(with labels: [UILabel]) -> UIStackView {
        let stackView = UIStackView()
        
        stackView.spacing = 8
        labels.forEach {
            stackView.addArrangedSubview($0)
        }
        
        return stackView
    }
}

extension MainViewController {
    private enum CalculatorNameSpace {
        static let empty = ""
        static let zero = "0"
        static let dot = "."
        static let doubleZero = "00"
        static let minus = "-"
        static let nan = "NaN"
    }
}