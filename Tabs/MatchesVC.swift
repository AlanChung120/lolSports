//
//  MatchesVC.swift
//  lolSports
//
//  Created by Alan Chung on 2023-04-04.
//

import UIKit

class MatchesVC: UIViewController {
    
    @IBOutlet var dateView: UILabel!
    @IBOutlet weak var matchesTableView: UITableView!
    let gmt: TimeZone = TimeZone(abbreviation: "GMT")!
    let phoneTimeZone: TimeZone = TimeZone.current
    
    var month: Int = 0
    var day: Int = 0
    var year: Int = 0
    var matches: [Match] = []
    var leagueIds: String = ""
    
    struct Match {
        var teamOneName: String = ""
        var teamTwoName: String = ""
        var teamOneImage: String = ""
        var teamTwoImage: String = ""
        var leagueName: String = ""
        var seriesType: String = ""
        var status: String = ""
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let date = Date()
        month = Calendar.current.component(.month, from: date)
        day = Calendar.current.component(.day, from: date)
        year = Calendar.current.component(.year, from: date)
        
        dateView.text = String(month) + "/" + String(day) + "/" + String(year)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        leagueIds = ""
        let tab = tabBarController as! TabVC
        for i in 0..<tab.followLeagues.count {
            if (tab.followLeagues[i] == "LCK") {
                leagueIds += "293"
            } else if (tab.followLeagues[i] == "LPL") {
                leagueIds += "294"
            } else if (tab.followLeagues[i] == "LEC") {
                leagueIds += "4197"
            } else if (tab.followLeagues[i] == "LCS") {
                leagueIds += "4198"
            } else if (tab.followLeagues[i] == "MSI") {
                leagueIds += "300"
            } else if (tab.followLeagues[i] == "Worlds") {
                leagueIds += "297"
            }
            if (i != tab.followLeagues.count - 1) {
                leagueIds += ","
            }
        }
        fetch() { result in
            self.matches = result
            DispatchQueue.main.async {
                self.matchesTableView.reloadData()
            }
        }
    }
    
    func getAdjustedTime(matchDate: String) -> String {
        let y: Int = Int(matchDate.substring(with: 0..<4))!
        let m: Int = Int(matchDate.substring(with: 5..<7))!
        let d: Int = Int(matchDate.substring(with: 8..<10))!
        let hour: Int = Int(matchDate.substring(with: 11..<13))!
        let minute: Int = Int(matchDate.substring(with: 14..<16))!
        let second: Int = Int(matchDate.substring(with: 17..<19))!
        var md: Date = Date(month: m, day: d, year: y, hour: hour, minute: minute, second: second, timezone: gmt)
        md = md.convert(from: gmt, to: phoneTimeZone)
        return md.ISO8601Format().substring(with: 11..<16)
    }
    
    func fetch(completion: @escaping ([Match]) -> Void) {
        let tab = tabBarController as! TabVC
        
        let startDate: Date = Date(month: month, day: day, year: year, hour: 0, minute: 0, second: 0, timezone: phoneTimeZone)
        let endDate: Date = Date(month: month, day: day, year: year, hour: 23, minute: 59, second: 59, timezone: phoneTimeZone)
        
        
        let headers = [
          "accept": "application/json",
          "authorization": "Bearer 3c_9nXv0AMBnWO81RbPJvz_GlEc4KvEO8W3uxSetjeL3ntmGpYE"
        ]
        let request = NSMutableURLRequest(url: NSURL(string:  "https://api.pandascore.co/lol/matches?filter[league_id]=" + leagueIds + "&sort=scheduled_at&range[scheduled_at]=" + startDate.ISO8601Format() + "," + endDate.ISO8601Format() + "&page=1&per_page=100")! as URL,
                                                cachePolicy: .useProtocolCachePolicy,
                                            timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers

        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) in
            if (data != nil && error == nil) {
                let json = try? JSONSerialization.jsonObject(with: data!, options: [])
                let matchData = json as? [[String: Any]] ?? []
                var result: [Match] = []
                for i in 0..<matchData.count {
                    var m = Match()
                    let teams = matchData[i]["opponents"] as! [[String:Any]]
                    let league = matchData[i]["league"] as! [String:Any]
                    m.leagueName = league["name"] as! String
                    m.seriesType = "Bo" + String(matchData[i]["number_of_games"] as! Int)
                    if (teams.count >= 1) {
                        let team1 = teams[0]["opponent"] as! [String:Any]
                        m.teamOneName = team1["name"] as! String
                        m.teamOneImage = team1["image_url"] as! String
                    } else {
                        m.teamOneName = "TBD"
                    }
                    if (teams.count == 2) {
                        let team2 = teams[1]["opponent"] as! [String:Any]
                        m.teamTwoName = team2["name"] as! String
                        m.teamTwoImage = team2["image_url"] as! String
                    } else {
                        m.teamTwoName = "TBD"
                    }
                    if (!tab.hideScore && matchData[i]["status"] as! String == "finished") {
                        let results = matchData[i]["results"] as! [[String:Int]]
                        m.status = String(results[0]["score"] ?? 0) + "-" + String(results[1]["score"] ?? 0)
                    } else {
                        let matchDate = matchData[i]["scheduled_at"] as! String
                        m.status = self.getAdjustedTime(matchDate: matchDate)
                    }
                    result.append(m)
                }
                completion(result)
            } else {
                print("Fetch Error")
            }
        })
        dataTask.resume()
        
    }
    
    // get last day of the month
    func getLastDay() -> Int {
        if (month == 1 || month == 3 || month == 5 || month == 7 || month == 8 ||
            month == 10 || month == 12) {
            return 31
        } else if (month == 4 || month == 6 || month == 9 || month == 11) {
            return 30
        } else if (month == 2 && year % 4 == 0 && (year % 100 != 0 || year % 400 == 0)) {
            return 29
        } else {
            return 28
        }
    }
    
    @IBAction func backMonthTapped(_ sender: UIButton) {
        if (month == 1 && year == 2000) {
            day = 1
        } else if (month == 1) {
            month = 12
            year -= 1
        } else {
            month -= 1
        }
        
        let lastDay = getLastDay()
        if (day > lastDay) {
            day = lastDay
        }
        
        dateView.text = String(month) + "/" + String(day) + "/" + String(year)
        fetch() { result in
            self.matches = result
            DispatchQueue.main.async {
                self.matchesTableView.reloadData()
            }
        }
        
    }
    
    @IBAction func backDayTapped(_ sender: UIButton) {
        if (month == 1 && day == 1 && year == 2000) {
            day = 1
        } else if (month == 1 && day == 1 && year != 2000) {
            month = 12
            year -= 1
            day = getLastDay()
        } else if (day == 1) {
            month -= 1
            day = getLastDay()
        } else {
            day -= 1
        }
        
        dateView.text = String(month) + "/" + String(day) + "/" + String(year)
        fetch() { result in
            self.matches = result
            DispatchQueue.main.async {
                self.matchesTableView.reloadData()
            }
        }
        
    }
    
    @IBAction func forwardDayTapped(_ sender: UIButton) {
        if (month == 12 && day == 31) {
            month = 1
            day = 1
            year += 1
        } else if (day == getLastDay()) {
            month += 1
            day = 1
        } else {
            day += 1
        }
        
        dateView.text = String(month) + "/" + String(day) + "/" + String(year)
        fetch() { result in
            self.matches = result
            DispatchQueue.main.async {
                self.matchesTableView.reloadData()
            }
        }
    }
    
    @IBAction func forwardMonthTapped(_ sender: UIButton) {
        if (month == 12) {
            month = 1
            year += 1
        } else {
            month += 1
        }
        
        let lastDay = getLastDay()
        if (day > lastDay) {
            day = lastDay
        }
        
        dateView.text = String(month) + "/" + String(day) + "/" + String(year)
        fetch() { result in
            self.matches = result
            DispatchQueue.main.async {
                self.matchesTableView.reloadData()
            }
        }
    }
    
}

extension MatchesVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matches.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MatchCell", for:indexPath) as! MatchTableVC
        cell.leagueView.text = matches[indexPath.row].leagueName
        cell.teamOneName.text = matches[indexPath.row].teamOneName
        cell.teamTwoName.text = matches[indexPath.row].teamTwoName
        if (matches[indexPath.row].teamOneImage != "") {
            cell.teamOneImage.isHidden = false
            cell.teamOneImage.load(url: NSURL(string:matches[indexPath.row].teamOneImage)! as URL)
            cell.teamOneImage.contentMode = .scaleAspectFit
        } else {
            cell.teamOneImage.isHidden = true
        }
        if (matches[indexPath.row].teamTwoImage != "") {
            cell.teamTwoImage.isHidden = false
            cell.teamTwoImage.load(url: NSURL(string:matches[indexPath.row].teamTwoImage)! as URL)
            cell.teamTwoImage.contentMode = .scaleAspectFit
        } else {
            cell.teamTwoImage.isHidden = true
        }
        cell.statusView.text = matches[indexPath.row].status
        cell.seriesView.text = matches[indexPath.row].seriesType
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 250
    }
    
}
