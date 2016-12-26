//
//  DetailViewController.swift
//  CreditCardApp
//
//  Created by Victor Mendes on 24/12/16.
//  Copyright © 2016 Victor Mendes. All rights reserved.
//

import UIKit
import CoreData

class DetailViewController: UIViewController {
    
    @IBOutlet weak var nameOnCardLbl: UILabel!
    @IBOutlet weak var cardNumberLbl: UILabel!
    @IBOutlet weak var dayExpLbl: UILabel!
    @IBOutlet weak var yearExpLbl: UILabel!
    @IBOutlet weak var cvvLbl: UILabel!
    @IBOutlet weak var flagLbl: UILabel!
    @IBOutlet weak var amountLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        requestData()
        
        let url = URL(string: "https://private-3b2a0-creditcard7.apiary-mock.com/items")!
        let request = URLRequest(url: url)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let response = response, let _ = data {
                print(response)
            } else {
                print(error!)
            }
        }
        
        task.resume()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func requestData() {
        dayExpLbl.textAlignment = .right
        amountLbl.textAlignment = .right
        
        let appDelegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let context : NSManagedObjectContext = appDelegate.persistentContainer.viewContext
        
        //Retorna os dados
        let requestFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Payment")
        requestFetch.returnsObjectsAsFaults = false
        
        do {
            let results = try context.fetch(requestFetch)
            if results.count > 0 {
                for result in results as! [NSManagedObject] {
                    nameOnCardLbl.text = result.value(forKey: "nameOnCard") as! String?
                    cardNumberLbl.text = result.value(forKey: "cardNumber") as! String?
                    dayExpLbl.text = result.value(forKey: "dayExp") as! String?
                    yearExpLbl.text = result.value(forKey: "yearExp") as! String?
                    cvvLbl.text = result.value(forKey: "cvv") as! String?
                    flagLbl.text = result.value(forKey: "flag") as! String?
                    amountLbl.text = result.value(forKey: "amount") as! String?
                }
            }
        } catch {
            print("Erro ao retornar dados")
        }
    }

}
