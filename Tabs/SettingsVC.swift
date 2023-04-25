//
//  SettingsVC.swift
//  lolSports
//
//  Created by Alan Chung on 2023-04-04.
//

import UIKit

class SettingsVC: UIViewController {
    
    let settingsText: [String] = ["Hide Score", "Follow LCK", "Follow LPL", "Follow LEC", "Follow LCS", "Follow MSI", "Follow Worlds"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension SettingsVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingsText.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingCell", for:indexPath) as! SettingTableVC
        cell.settingName.text = settingsText[indexPath.row]
        cell.settingSwitch.tag = indexPath.row
        cell.settingSwitch.addTarget(self , action: #selector(didChangeSwitch(_:)), for: .valueChanged)
        return cell
    }
    
    @objc func didChangeSwitch(_ sender: UISwitch) {
        let tab = tabBarController as! TabVC
        let alert = UIAlertController(title: "Error", message: "You must follow at least one League.", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        switch settingsText[sender.tag] {
        case "Hide Score":
            tab.hideScore = sender.isOn
        case "Follow LCK":
            if (sender.isOn) {
                tab.followLeagues.append("LCK")
            } else {
                if (tab.followLeagues.count > 1) {
                    if let index = tab.followLeagues.firstIndex(of: "LCK") {
                        tab.followLeagues.remove(at: index)
                    }
                } else {
                    self.present(alert, animated: true, completion: nil)
                    sender.isOn = true
                }
            }
        case "Follow LPL":
            if (sender.isOn) {
                tab.followLeagues.append("LPL")
            } else {
                if (tab.followLeagues.count > 1) {
                    if let index = tab.followLeagues.firstIndex(of: "LPL") {
                        tab.followLeagues.remove(at: index)
                    }
                } else {
                    self.present(alert, animated: true, completion: nil)
                    sender.isOn = true
                }
            }
        case "Follow LEC":
            if (sender.isOn) {
                tab.followLeagues.append("LEC")
            } else {
                if (tab.followLeagues.count > 1) {
                    if let index = tab.followLeagues.firstIndex(of: "LEC") {
                        tab.followLeagues.remove(at: index)
                    }
                } else {
                    self.present(alert, animated: true, completion: nil)
                    sender.isOn = true
                }
            }
        case "Follow LCS":
            if (sender.isOn) {
                tab.followLeagues.append("LCS")
            } else {
                if (tab.followLeagues.count > 1) {
                    if let index = tab.followLeagues.firstIndex(of: "LCS") {
                        tab.followLeagues.remove(at: index)
                    }
                } else {
                    self.present(alert, animated: true, completion: nil)
                    sender.isOn = true
                }
            }
        case "Follow MSI":
            if (sender.isOn) {
                tab.followLeagues.append("MSI")
            } else {
                if (tab.followLeagues.count > 1) {
                    if let index = tab.followLeagues.firstIndex(of: "MSI") {
                        tab.followLeagues.remove(at: index)
                    }
                } else {
                    self.present(alert, animated: true, completion: nil)
                    sender.isOn = true
                }
            }
        case "Follow Worlds":
            if (sender.isOn) {
                tab.followLeagues.append("Worlds")
            } else {
                if (tab.followLeagues.count > 1) {
                    if let index = tab.followLeagues.firstIndex(of: "Worlds") {
                        tab.followLeagues.remove(at: index)
                    }
                } else {
                    self.present(alert, animated: true, completion: nil)
                    sender.isOn = true
                }
            }
        default:
            break
        }
    }
    
}
