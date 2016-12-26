//
//  ViewController.swift
//  CreditCardApp
//
//  Created by Victor Mendes on 24/12/16.
//  Copyright © 2016 Victor Mendes. All rights reserved.
//

import UIKit
import CoreData

class MainViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var nameOnCard: UITextField!
    @IBOutlet weak var cardNumber: UITextField!
    @IBOutlet weak var dayExp: UITextField!
    @IBOutlet weak var yearExp: UITextField!
    @IBOutlet weak var cvv: UITextField!
    @IBOutlet weak var flag: UITextField!
    
    @IBOutlet weak var amount: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        nameOnCard.delegate = self
        nameOnCard.textAlignment = .right
        
        cardNumber.delegate = self
        cardNumber.textAlignment = .right
        
        dayExp.delegate = self
        dayExp.textAlignment = .right
        
        yearExp.delegate = self
        yearExp.textAlignment = .right
        
        cvv.delegate = self
        cvv.textAlignment = .right
        
        flag.delegate = self
        flag.textAlignment = .right
        
        amount.delegate = self
        amount.textAlignment = .right
        amount.addTarget(self, action: #selector(textField), for: .editingChanged)
        
        self.hideKeyboardWhenTappedAround()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        // Limita o numero de digitos dentro dos TextFields
        let newLength = (textField.text?.characters.count)! + string.characters.count - range.length
        
        if textField == cvv {
            return newLength <= 3
        } else if textField == dayExp {
            return newLength <= 2
        } else if textField == yearExp {
            return newLength <= 2
        }
        
        // Formata a entrada de dados para o textfield com o valor da transação
        if textField == amount {
            if let amountString = textField.text?.currencyInputFormatting() {
                amount.text = amountString
                
            }
        }
        
        // Formata a entrada de dados para o textfield com o numero do cartão
        if textField == cardNumber {
            let replacementStringIsLegal = string.rangeOfCharacter(from: NSCharacterSet(charactersIn: "0123456789").inverted) == nil
            
            if !replacementStringIsLegal {
                return false
            }
            
            let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
            let components = newString.components(separatedBy: NSCharacterSet(charactersIn: "0123456789").inverted)
            
            let decimalString = components.joined(separator: "") as NSString
            let length = decimalString.length
            let hasLeadingOne = length > 0 && decimalString.character(at: 0) == (1 as unichar)
            
            if length == 0 || (length > 16 && !hasLeadingOne) || length > 19 {
                let newLength = (textField.text! as NSString).length + (string as NSString).length - range.length as Int
                
                return (newLength > 16) ? false : true
            }
            
            var index = 0 as Int
            
            let formattedString = NSMutableString()
            
            if hasLeadingOne {
                formattedString.append("1 ")
                index += 1
            }
            
            if length - index > 4 {
                let prefix = decimalString.substring(with: NSMakeRange(index, 4))
                formattedString.appendFormat("%@ ", prefix)
                index += 4
            }
            
            if length - index > 4 {
                let prefix = decimalString.substring(with: NSMakeRange(index, 4))
                formattedString.appendFormat("%@ ", prefix)
                index += 4
            }
            
            if length - index > 4 {
                let prefix = decimalString.substring(with: NSMakeRange(index, 4))
                formattedString.appendFormat("%@ ", prefix)
                index += 4
            }
            
            let remainder = decimalString.substring(from: index)
            formattedString.append(remainder)
            textField.text = formattedString as String
            
            return false
        } else {
            return true
        }
        
    }
    
    // Função que esconde o keyboard
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(MainViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    // Função chamada quando um tap é reconhecido
    func dismissKeyboard() {
        view.endEditing(true)
    }


    @IBAction func payment(_ sender: UIButton) {
        
        let url = URL(string: "https://private-3b2a0-creditcard7.apiary-mock.com/items")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        request.httpBody = "{\n  \"items\": [\n    \"nameOnCard\",\n    \"cardNumber\",\n    \"dayExp\",\n    \"yearExp\",\n    \"cvv\",\n    \"flag\",\n    \"amount\"\n  ]\n}".data(using: .utf8)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let _ = response, let data = data {
                
                let appDelegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
                let context : NSManagedObjectContext = appDelegate.persistentContainer.viewContext
                
                let payment = NSEntityDescription.insertNewObject(forEntityName: "Payment", into: context)
                
                payment.setValue(self.nameOnCard.text, forKey: "nameOnCard")
                payment.setValue(self.cardNumber.text, forKey: "cardNumber")
                payment.setValue(self.dayExp.text, forKey: "dayExp")
                payment.setValue(self.yearExp.text, forKey: "yearExp")
                payment.setValue(self.cvv.text, forKey: "cvv")
                payment.setValue(self.flag.text, forKey: "flag")
                payment.setValue(self.amount.text, forKey: "amount")
                
                //Salva os dados
                do {
                    try context.save()
                } catch {
                    print("Erro ao salvar dados")
                }
                
                print(String(data: data, encoding: .utf8)!)
            } else {
                print(error!)
            }
        }
        
        task.resume()
    }

}

extension String {
    
    // formatting text for currency textField
    func currencyInputFormatting() -> String {
        
        var number: NSNumber!
        let formatter = NumberFormatter()
        formatter.numberStyle = .currencyAccounting
        formatter.currencySymbol = "R$ "
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        formatter.maximumIntegerDigits = 12
        
        var amountWithPrefix = self
        
        // remove from String: "$", ".", ","
        let regex = try! NSRegularExpression(pattern: "[^0-9]", options: .caseInsensitive)
        amountWithPrefix = regex.stringByReplacingMatches(in: amountWithPrefix, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, self.characters.count), withTemplate: "")
        
        let double = (amountWithPrefix as NSString).doubleValue
        number = NSNumber(value: (double / 100))
        
        // if first number is 0 or all numbers were deleted
        guard number != 0 as NSNumber else {
            return ""
        }
        
        return formatter.string(from: number)!
    }
}
