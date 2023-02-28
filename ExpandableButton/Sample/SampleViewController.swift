//
//  SampleViewController.swift
//  ExpandableButton
//
//  Created by Giovanne Bressam on 27/02/23.
//

import UIKit

class SampleViewController: UIViewController {
    @IBOutlet weak var expandableButtonSample1: ExpandableButton!
    @IBOutlet weak var expandableButtonSample2: ExpandableButton!
    @IBOutlet weak var expandableButtonSample3: ExpandableButton!
    @IBOutlet weak var expandableButtonSample4: ExpandableButton!
    @IBOutlet weak var expandableButtonSample5: ExpandableButton!
    @IBOutlet weak var expandableButtonSample6: ExpandableButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        expandableButtonSample1.datasource = self
        expandableButtonSample1.delegate = self
        
        expandableButtonSample2.datasource = self
        expandableButtonSample2.delegate = self
        
        expandableButtonSample2.datasource = self
        expandableButtonSample2.delegate = self
        
        expandableButtonSample3.datasource = self
        expandableButtonSample3.delegate = self
        
        expandableButtonSample4.datasource = self
        expandableButtonSample4.delegate = self
        
        expandableButtonSample5.datasource = self
        expandableButtonSample5.delegate = self
        
        expandableButtonSample6.datasource = self
        expandableButtonSample6.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        expandableButtonSample1.layer.cornerRadius = expandableButtonSample1.frame.height / 2
        expandableButtonSample2.layer.cornerRadius = expandableButtonSample2.frame.height / 2
        expandableButtonSample3.layer.cornerRadius = expandableButtonSample3.frame.height / 2
        expandableButtonSample4.layer.cornerRadius = expandableButtonSample4.frame.height / 2
        expandableButtonSample5.layer.cornerRadius = expandableButtonSample5.frame.height / 2
        expandableButtonSample6.layer.cornerRadius = expandableButtonSample6.frame.height / 2
    }
}

extension SampleViewController: ExpandableButtonDataSource {
    func buttonsToPresent(for expandableButton: ExpandableButton) -> [UIButton] {
        // Setup any button with any style or action here
        var buttonConfig = UIButton.Configuration.filled()
        buttonConfig.imagePadding = 10
        buttonConfig.baseBackgroundColor = .systemIndigo
        var sampleButtons: [UIButton] = []

        let sampleButton1 = UIButton(type: .custom)
        sampleButton1.translatesAutoresizingMaskIntoConstraints = false
        sampleButton1.setImage(.init(systemName: "rectangle.and.pencil.and.ellipsis"), for: .normal)
        NSLayoutConstraint.activate([
            sampleButton1.heightAnchor.constraint(equalToConstant: 50),
            sampleButton1.widthAnchor.constraint(equalToConstant: 100)
        ])
        sampleButton1.configuration = buttonConfig
        sampleButton1.layer.cornerRadius = 25
        sampleButton1.clipsToBounds = true
        sampleButtons.append(sampleButton1)
        
        let sampleButton2 = UIButton(type: .custom)
        sampleButton2.translatesAutoresizingMaskIntoConstraints = false
        sampleButton2.setImage(.init(systemName: "pencil.tip"), for: .normal)
        NSLayoutConstraint.activate([
            sampleButton2.heightAnchor.constraint(equalToConstant: 50),
            sampleButton2.widthAnchor.constraint(equalToConstant: 100)
        ])
        sampleButton2.configuration = buttonConfig
        sampleButton2.layer.cornerRadius = 25
        sampleButton2.clipsToBounds = true
        sampleButton2.backgroundColor = .cyan
        sampleButtons.append(sampleButton2)

        let sampleButton3 = UIButton(type: .custom)
        sampleButton3.translatesAutoresizingMaskIntoConstraints = false
        sampleButton3.setImage(.init(systemName: "paperplane.circle.fill"), for: .normal)
        NSLayoutConstraint.activate([
            sampleButton3.heightAnchor.constraint(equalToConstant: 50),
            sampleButton3.widthAnchor.constraint(equalToConstant: 100)
        ])
        sampleButton3.configuration = buttonConfig
        sampleButton3.layer.cornerRadius = 25
        sampleButton3.clipsToBounds = true
        sampleButtons.append(sampleButton3)
    
        return sampleButtons
    }
    
    func expansionType(for expandableButton: ExpandableButton) -> ExpandableButtonDirection {
        if expandableButton == expandableButtonSample1 {
            return .rightUp
        } else if expandableButton == expandableButtonSample2 {
            return .rightDown
        } else if expandableButton == expandableButtonSample3 {
            return .top
        } else if expandableButton == expandableButtonSample4 {
            return .bottom
        } else if expandableButton == expandableButtonSample5 {
            return .leftUp
        } else if expandableButton == expandableButtonSample6 {
            return .leftDown
        }
        
        return .rightDown
    }
}

extension SampleViewController: ExpandableButtonDelegate {
    func shouldAddBlackLayer(for expandableButton: ExpandableButton) -> Bool {
        return true
    }
}
