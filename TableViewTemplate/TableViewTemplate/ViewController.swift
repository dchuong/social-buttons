//
//  ViewController.swift
//  TableViewTemplate
//
//  Created by derrick on 9/23/14.
//  Copyright (c) 2014 derrick. All rights reserved.
//  connect the datasource, delegate to viewcontroller

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    let cellIdentifier = "cellIdentifier"
    var table:[String] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.table += ["Baking Powder", "Chocolate", "Butter", "Eggs", "Apple", "So Fresh"]
        println(table.count)
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.table.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as UITableViewCell
        cell.textLabel!.text = table[indexPath.row]
        println(table[indexPath.row])
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        println("Selected cell \(indexPath.row)")
        var detailViewController: DetailViewController = self.storyboard?.instantiateViewControllerWithIdentifier("DetailViewController") as DetailViewController
        
        self.presentViewController(detailViewController, animated: true, completion: nil)
    }
}

