//
//  OnboardingDataPresenter.swift
//  DepositsOnboarding
//
//  Created by Kembene Nkem on 7/27/22.
//

import Foundation
import UIKit
import Core

class OnboardingDataPresenterSection{
    var sectionTitle: String?
    var inputedData: [SimpleDataItem] = []
    init(sectionTitle: String?, inputedData: [SimpleDataItem]){
        self.sectionTitle = sectionTitle
        self.inputedData = inputedData
    }
}

class OnboardingDataPresenterData {
    var sections: [OnboardingDataPresenterSection] = []
}

class OnboardingDataPresenter: UIView {
    
    let tableView = UITableView(frame: CGRect.zero, style: .grouped)
    var sections: [OnboardingDataPresenterSection] = []
    let cellIdentifier = "Cell"
    func preparePresenter() {
        self.addSubview(tableView)
        let verticalEdge = appConfig()?.verticalEdge ?? 0
        let horizontalEdge = appConfig()?.horizontalEdge ?? 0
        tableView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(horizontalEdge)
            make.top.equalTo(self.safeAreaLayoutGuide.snp.top).offset(verticalEdge)
            make.trailing.equalToSuperview().offset(0 - horizontalEdge)
            make.bottom.equalTo(self.safeAreaLayoutGuide.snp.bottom).offset(0 - verticalEdge)
        }
        tableView.backgroundColor = UIColor.clear
        tableView.allowsSelection = false
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
    }
    
    func renderData(data: OnboardingDataPresenterData){
        sections = data.sections
    }
}

extension OnboardingDataPresenter: UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].inputedData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        
        let data = sections[indexPath.section].inputedData[indexPath.row]
        
        let text = "\(data.getItemLabel())\n\(data.getItemDescription() ?? "")"
        cell.textLabel?.text = text
        cell.textLabel?.numberOfLines = 0
        cell.backgroundColor = UIColor.clear
        return cell
    }
}

extension OnboardingDataPresenter: UITableViewDelegate {
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].sectionTitle
    }
}
