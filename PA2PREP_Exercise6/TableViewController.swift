//
//  TableViewController.swift
//  PA2PREP_Exercise6
//
//  Created by Timothy M Shepard on 10/25/17.
//  Copyright © 2017 Timothy. All rights reserved.
//

import UIKit

struct Company: Codable {
    let logo_url: String
    let company: String
    let ceo: String
    let category: String
    let hq_latitude: Double
    let hq_longitude: Double
}

extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).uppercased() + dropFirst()
    }
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}

struct CompanySection {
    let section: String
    var companies: [Company]
    
    init(section: String) {
        self.section = section
        self.companies = []
    }
}

class TableViewController: UITableViewController {
    
    var companies: [Company] = []
    var selectedSection: Int = 0
    var selectedRow: Int = 0
    var companiesBySection: [CompanySection] = [CompanySection(section: "technology"), CompanySection(section: "news"), CompanySection(section: "Food & Drink"), CompanySection(section: "fashion")]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getJsonData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return companiesBySection.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("current number of rows, \(companiesBySection[section].companies.count)")
        return companiesBySection[section].companies.count
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return CGFloat(100)
    }
    
    func getJsonData() {
        let url = URL(string: "http://cpl.uh.edu/courses/ubicomp/fall2017/webservice/companies.json")
        getData(url: (url ?? URL(string: "")!))
    }
    
    func getData(url: URL) {
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let data = data {
                do {
                    // Convert the data to JSON
                    let jsonDecoder = JSONDecoder()
                    let companies = try jsonDecoder.decode(Array<Company>.self, from: data)
                    print(companies)
                    self.companies = companies
                    
                    for company in self.companies {
                        let category = company.category
                        switch category
                        {
                        case "technology":
                            self.companiesBySection[0].companies.append(company)
                        case "news":
                            self.companiesBySection[1].companies.append(company)
                        case "Food & Drink":
                            self.companiesBySection[2].companies.append(company)
                        case "fashion":
                            self.companiesBySection[3].companies.append(company)
                        default:
                            print("unknown section")
                        }
                    }
                    
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                    
                } catch {
                    print("Error trying to decode JSON object")
                }
                
            } else if let error = error {
                print(error.localizedDescription)
            }
        }
        task.resume()
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return companiesBySection[section].section
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "companyCell", for: indexPath) as! CompanyTableViewCell
        cell.companyLabel.text = companiesBySection[indexPath.section].companies[indexPath.row].company.capitalizingFirstLetter()
        cell.ceoLabel.text = companiesBySection[indexPath.section].companies[indexPath.row].ceo.capitalizingFirstLetter()

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedSection = indexPath.section
        selectedRow = indexPath.row
        performSegue(withIdentifier: "mapSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "mapSegue" {
            let dvc = segue.destination as! ViewController
            dvc.company = companiesBySection[selectedSection].companies[selectedRow]
        }
    }

}
