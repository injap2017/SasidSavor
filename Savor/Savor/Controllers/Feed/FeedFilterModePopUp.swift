//
//  FeedFilterModePopUp.swift
//  Savor
//
//  Created by Edgar Sia on 6/5/20.
//  Copyright © 2020 Edgar Sia. All rights reserved.
//

import UIKit
import KUIPopOver
import SnapKit
import Cosmos

protocol FeedFilterModePopUpDelegate {
    func didSelectSource(_ source: FeedSource)
    func didSelectMinimumRating(_ minimumRating: Float)
    func didSelectAreaOfInterest(_ areaOfInterest: Double)
}

class FeedFilterModePopUp: UITableViewController, KUIPopOverUsable {
    
    // MARK: - KUIPopOverUsable
    var contentSize: CGSize {
        return CGSize(width: 256.0, height: 245.0)
    }
    
    // MARK: - Properties
    var areaOfInterestValueLabel: UILabel?
    var areaOfInterestSlider: UISlider?
    var minimumRatingValueView: CosmosView?
    var minimumRatingSlider: UISlider?
    var allPostsCell: UITableViewCell?
    var friendsCell: UITableViewCell?
    
    private var _source: FeedSource = .allPosts
    var source: FeedSource {
        get {
            return _source
        }
        set {
            switch _source {
            case .allPosts:
                allPostsCell?.accessoryType = .none
            default:
                friendsCell?.accessoryType = .none
            }
            
            switch newValue {
            case .allPosts:
                allPostsCell?.accessoryType = .checkmark
            default:
                friendsCell?.accessoryType = .checkmark
            }
            
            _source = newValue
        }
    }
    
    private var _minimumRating: Float = 3.0
    private var _minimumRatingValueChanged: Bool = false
    var minimumRating: Float {
        get {
            return _minimumRating
        }
        set {
            _minimumRating = newValue
            
            let step = Int(newValue + 0.5)
            
            minimumRatingSlider?.value = Float(step)
            minimumRatingValueView?.rating = Double(step)
        }
    }
    
    let areaOfInterestValues: [Double] = [0.1, 0.3, 0.5, 1, 2, 3, 4, 5, 10, 15, 20, 25, 50, 100, 150, 500, 1000, 3000, -1]
    
    private var _areaOfInterest: Double = -1
    private var _areaOfInterestValueChanged: Bool = false
    var areaOfInterest: Double {
        get {
            return _areaOfInterest
        }
        set {
            _areaOfInterest = newValue
            
            if newValue == -1 {
                areaOfInterestSlider?.value = Float(areaOfInterestValues.count - 1)
                areaOfInterestValueLabel?.text = "Unlimited"
                return
            }
            
            var step = 0
            for (i, value) in areaOfInterestValues.enumerated() {
                if i == areaOfInterestValues.count - 1 { break }
                if newValue >= value {
                    step = i
                    continue
                }
                break
            }
            
            areaOfInterestSlider?.value = Float(step)
            areaOfInterestValueLabel?.text = "\(areaOfInterestValues[step]) miles"
        }
    }
    
    var delegate: FeedFilterModePopUpDelegate?
}

// MARK: - Lifecycle
extension FeedFilterModePopUp {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initView()
    }
}

// MARK: - Functions
extension FeedFilterModePopUp {
    
    func initView() {
        // footer
        self.tableView.tableFooterView = UIView.init()
        
        // disable scrolling
        self.tableView.alwaysBounceVertical = false
    }
}

// MARK: - TableView
extension FeedFilterModePopUp {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return 1
        default:
            return 2
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = UITableViewCell.init()
            let slider = UISlider.init()
            slider.maximumValue = Float(areaOfInterestValues.count - 1)
            slider.minimumValue = 0
            slider.addTarget(self, action: #selector(self.areaOfInterestValueChanged), for: .valueChanged)
            cell.contentView.addSubview(slider)
            slider.snp.makeConstraints { (maker) in
                maker.top.equalToSuperview().offset(8)
                maker.bottom.equalToSuperview()
                maker.leading.equalToSuperview().offset(32)
                maker.trailing.equalToSuperview().offset(-32)
            }
            self.areaOfInterestSlider = slider
            self.areaOfInterest = _areaOfInterest
            return cell
        case 1:
            let cell = UITableViewCell.init()
            let slider = UISlider.init()
            slider.maximumValue = 5.0
            slider.minimumValue = 1.0
            slider.addTarget(self, action: #selector(self.minimumRatingValueChanged), for: .valueChanged)
            cell.contentView.addSubview(slider)
            slider.snp.makeConstraints { (maker) in
                maker.top.equalToSuperview().offset(8)
                maker.bottom.equalToSuperview()
                maker.leading.equalToSuperview().offset(32)
                maker.trailing.equalToSuperview().offset(-32)
            }
            self.minimumRatingSlider = slider
            self.minimumRating = _minimumRating
            return cell
        default:
            switch indexPath.row {
            case 0:
                let cell = UITableViewCell.init()
                cell.textLabel?.text = "All Posts"
                cell.textLabel?.font = UIFont.systemFont(ofSize: 15.0)
                cell.imageView?.image = UIImage.init(named: "web")?.withRenderingMode(.alwaysTemplate)
                cell.imageView?.tintColor = UIColor.black
                self.allPostsCell = cell
                self.source = _source
                return cell
            default:
                let cell = UITableViewCell.init()
                cell.textLabel?.text = "Friends"
                cell.textLabel?.font = UIFont.systemFont(ofSize: 15.0)
                cell.imageView?.image = UIImage.init(named: "account-group")?.withRenderingMode(.alwaysTemplate)
                cell.imageView?.tintColor = UIColor.black
                self.friendsCell = cell
                self.source = _source
                return cell
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 25
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch section {
        case 0:
            let header = UIView.init()
            let label = UILabel.init()
            label.text = "Area of Interest"
            label.font = UIFont.systemFont(ofSize: 15.0)
            header.addSubview(label)
            label.snp.makeConstraints { (maker) in
                maker.top.equalToSuperview().offset(8)
                maker.leading.equalToSuperview().offset(8)
            }
            let valueLabel = UILabel.init()
            valueLabel.font = UIFont.systemFont(ofSize: 15.0)
            header.addSubview(valueLabel)
            valueLabel.snp.makeConstraints { (maker) in
                maker.top.equalToSuperview().offset(8)
                maker.trailing.equalToSuperview().offset(-8)
            }
            self.areaOfInterestValueLabel = valueLabel
            self.areaOfInterest = _areaOfInterest
            return header
        case 1:
            let header = UIView.init()
            let label = UILabel.init()
            label.text = "Minimum Rating"
            label.font = UIFont.systemFont(ofSize: 15.0)
            header.addSubview(label)
            label.snp.makeConstraints { (maker) in
                maker.top.equalToSuperview().offset(8)
                maker.leading.equalToSuperview().offset(8)
            }
            let cosmosView = CosmosView.init()
            var cosmosSettings = CosmosSettings.init()
            cosmosSettings.starSize = 16.0
            cosmosSettings.starMargin = 0
            cosmosSettings.fillMode = .precise
            cosmosView.settings = cosmosSettings
            header.addSubview(cosmosView)
            cosmosView.snp.makeConstraints { (maker) in
                maker.top.equalToSuperview().offset(10)
                maker.trailing.equalToSuperview().offset(-8)
                maker.height.equalTo(16)
                maker.width.equalTo(80)
            }
            self.minimumRatingValueView = cosmosView
            self.minimumRating = _minimumRating
            return header
        default:
            let header = UIView.init()
            let label = UILabel.init()
            label.text = "Source"
            label.font = UIFont.systemFont(ofSize: 15.0)
            header.addSubview(label)
            label.snp.makeConstraints { (maker) in
                maker.top.equalToSuperview().offset(8)
                maker.leading.equalToSuperview().offset(8)
            }
            return header
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        var value: FeedSource
        switch indexPath.row {
        case 0:
            value = .allPosts
        default:
            value = .friends
        }
        if source == value {
            self.dismissPopover(animated: true)
            return
        }
        
        self.source = value
        
        self.dismissPopover(animated: true) {
            self.delegate?.didSelectSource(self.source)
        }
    }
}

// MARK: - Slider
extension FeedFilterModePopUp {
    
    @objc func minimumRatingValueChanged(_ sender: UISlider, event: UIEvent) {
        if let touchEvent = event.allTouches?.first,
            touchEvent.phase == .ended {
            self.dismissPopover(animated: true) {
                if self._minimumRatingValueChanged {
                    self.delegate?.didSelectMinimumRating(self.minimumRating)
                }
            }
        }
        
        let step = Int(sender.value + 0.5)
        sender.value = Float(step)
        
        let value = Float(step)
        if minimumRating == value {
            return
        }
        
        self.minimumRating = value
        self._minimumRatingValueChanged = true
    }
    
    @objc func areaOfInterestValueChanged(_ sender: UISlider, event: UIEvent) {
        if let touchEvent = event.allTouches?.first,
            touchEvent.phase == .ended {
            self.dismissPopover(animated: true) {
                if self._areaOfInterestValueChanged {
                    self.delegate?.didSelectAreaOfInterest(self.areaOfInterest)
                }
            }
        }
        
        let step = Int(sender.value + 0.5)
        sender.value = Float(step)
        
        let value = areaOfInterestValues[step]
        if areaOfInterest == value {
            return
        }
        
        self.areaOfInterest = value
        self._areaOfInterestValueChanged = true
    }
}
