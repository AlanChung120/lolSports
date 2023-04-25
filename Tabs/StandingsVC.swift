//
//  StandingsVC.swift
//  lolSports
//
//  Created by Alan Chung on 2023-04-04.
//

import UIKit

class StandingsVC: UIViewController {
    
    @IBOutlet weak var rankingTableView: UITableView!
    @IBOutlet var leagueView: UILabel!
    
    var leagueIndex: Int = 0
    var followLeagues: [String] = []
    var rankings: [TeamRanking] = []
    var tournamentId: String = ""
    
    struct TeamRanking {
        var teamName: String = ""
        var teamRecord: String = ""
        var teamImage: String = ""
        var ranking: Int = 0
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let tab = tabBarController as! TabVC
        followLeagues = tab.followLeagues
        leagueIndex = 0
        leagueView.text = followLeagues[leagueIndex]
        fetch() { result in
            self.rankings = result
            DispatchQueue.main.async {
                self.rankingTableView.reloadData()
            }
        }
    }
    
    func getTournamentId(completion: @escaping (String) -> Void) {
        var leagueCode: String = ""
        if (followLeagues[leagueIndex] == "LCK") {
            leagueCode = "293"
        } else if (followLeagues[leagueIndex] == "LPL") {
            leagueCode = "294"
        } else if (followLeagues[leagueIndex] == "LEC") {
            leagueCode = "4197"
        } else if (followLeagues[leagueIndex] == "LCS") {
            leagueCode = "4198"
        } else if (followLeagues[leagueIndex] == "MSI") {
            leagueCode = "300"
        } else if (followLeagues[leagueIndex] == "Worlds") {
            leagueCode = "297"
        }
        let headers = [
          "accept": "application/json",
          "authorization": "Bearer 3c_9nXv0AMBnWO81RbPJvz_GlEc4KvEO8W3uxSetjeL3ntmGpYE"
        ]
        let request = NSMutableURLRequest(url: NSURL(string:   "https://api.pandascore.co/leagues/" + leagueCode + "/tournaments?filter[has_bracket]=false&sort=&page=1&per_page=1")! as URL,
                                                cachePolicy: .useProtocolCachePolicy,
                                            timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers

        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: {
            (data, response, error) in
            if (data != nil && error == nil) {
                let json = try? JSONSerialization.jsonObject(with: data!, options: [])
                let tournamentData = json as? [[String: Any]] ?? []
                let result: String = String(tournamentData[0]["id"] as! Int)
                completion(result)
            } else {
                print("Fetch Error")
            }
        })
        
        dataTask.resume()
    }
    
    func fetch(completion: @escaping ([TeamRanking]) -> Void) {
        getTournamentId() {
            result in self.tournamentId = result
            let headers = [
              "accept": "application/json",
              "authorization": "Bearer 3c_9nXv0AMBnWO81RbPJvz_GlEc4KvEO8W3uxSetjeL3ntmGpYE"
            ]
            let request = NSMutableURLRequest(url: NSURL(string:   "https://api.pandascore.co/tournaments/" + self.tournamentId + "/standings?sort&page=1&per_page=50")! as URL,
                                                    cachePolicy: .useProtocolCachePolicy,
                                                timeoutInterval: 10.0)
            request.httpMethod = "GET"
            request.allHTTPHeaderFields = headers

            let session = URLSession.shared
            let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) in
                if (data != nil && error == nil) {
                    let json = try? JSONSerialization.jsonObject(with: data!, options: [])
                    let rankingData = json as? [[String: Any]] ?? []
                    var rankings: [TeamRanking] = []
                    for i in 0..<rankingData.count {
                        var r = TeamRanking()
                        let teamData = rankingData[i]["team"] as! [String:Any]
                        r.ranking = rankingData[i]["rank"] as! Int
                        r.teamImage = teamData["image_url"] as! String
                        r.teamName = teamData["name"] as! String
                        let wins: String = String(rankingData[i]["wins"] as! Int)
                        let losses: String = String(rankingData[i]["losses"] as! Int)
                        r.teamRecord = wins + "W-" + losses + "L"
                        rankings.append(r)
                    }
                    completion(rankings)
                } else {
                    print("Fetch Error")
                }
            })

            dataTask.resume()
        }

    }

    @IBAction func backTapped(_ sender: UIButton) {
        if (leagueIndex == 0) {
            leagueIndex = followLeagues.count - 1
        } else {
            leagueIndex -= 1
        }
        leagueView.text = followLeagues[leagueIndex]
        getTournamentId() {
            result in self.tournamentId = result
        }
        fetch() { result in
            self.rankings = result
            DispatchQueue.main.async {
                self.rankingTableView.reloadData()
            }
        }
    }
    
    @IBAction func forwardTapped(_ sender: UIButton) {
        if (leagueIndex == followLeagues.count - 1) {
            leagueIndex = 0
        } else {
            leagueIndex += 1
        }
        leagueView.text = followLeagues[leagueIndex]
        getTournamentId() {
            result in self.tournamentId = result
        }
        fetch() { result in
            self.rankings = result
            DispatchQueue.main.async {
                self.rankingTableView.reloadData()
            }
        }
    }
}

extension StandingsVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rankings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RankingCell", for:indexPath) as! RankingTableVC
        cell.rankingView.text = String(rankings[indexPath.row].ranking)
        cell.teamNameView.text = rankings[indexPath.row].teamName
        cell.recordView.text = rankings[indexPath.row].teamRecord
        cell.teamImageView.load(url: NSURL(string: rankings[indexPath.row].teamImage)! as URL)
        cell.teamImageView.contentMode = .scaleAspectFit
        return cell
    } 
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
}
