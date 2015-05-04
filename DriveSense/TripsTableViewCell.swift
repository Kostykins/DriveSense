//
//  TripsTableViewCell.swift
//  DriveSense
//
//  Created by Matt Kostelecky on 5/3/15.
//  Copyright (c) 2015 Matt Kostelecky. All rights reserved.
//

import Foundation
import UIKit

class TripsTableViewCell: UITableViewCell {
  
  @IBOutlet weak var namelabel: UILabel!
  @IBOutlet weak var dateLabel: UILabel!
  @IBOutlet weak var distanceLabel: UILabel!
  @IBOutlet weak var durationLabel: UILabel!
  
  override func setSelected(selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
  }
}