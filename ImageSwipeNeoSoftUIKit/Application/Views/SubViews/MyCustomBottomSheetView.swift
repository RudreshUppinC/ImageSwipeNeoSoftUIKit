//
//  MyCustomBottomSheetView.swift
//  ImageSwipeNeoSoftUIKit
//
//  Created by RudreshUppin on 26/04/25.
//

import UIKit

import UIKit
import Foundation

protocol MyCustomBottomSheetViewDelegate: AnyObject {
    func removeBottomSheet()
}

class MyCustomBottomSheetView: UIView {

    @IBOutlet weak var listTitleLbl: UILabel!
    @IBOutlet weak var topCharTitleLbl: UILabel!
    @IBOutlet weak var charatterLbl1: UILabel!
    @IBOutlet weak var charatterLbl2: UILabel!
    @IBOutlet weak var charatterLbl3: UILabel!

    private var items: [String] = []
    private var customListTitle: String?

    weak var fpdelegate: MyCustomBottomSheetViewDelegate?
    var view: UIView!

    override init(frame: CGRect) {
        super.init(frame: frame)
        nibSetUp()
        initialUISetup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        nibSetUp()
        initialUISetup()
    }

    func configure(items: [String], listTitle: String? = nil) {
        self.items = items
        self.customListTitle = listTitle
        updateUI()
    }

    // --- Actions ---
    @IBAction func closeButtonTapped(_ sender: UIButton) {
        fpdelegate?.removeBottomSheet()
    }

    // MARK: ----------------- Private Methods ----------------

    private func initialUISetup() {
        listTitleLbl?.text = ""
        topCharTitleLbl?.isHidden = true
        charatterLbl1?.isHidden = true
        charatterLbl2?.isHidden = true
        charatterLbl3?.isHidden = true
        charatterLbl1?.text = ""
        charatterLbl2?.text = ""
        charatterLbl3?.text = ""
    }

    private func updateUI() {
        let itemCount = items.count

        let baseTitle = customListTitle ?? "Current List"
        let formattedListTitle = "\(baseTitle) (\(itemCount) item\(itemCount == 1 ? "" : "s"))"
        listTitleLbl?.text = formattedListTitle
        // Top Characters Calculation
        var frequencies: [Character: Int] = [:]
        for item in items {
            for character in item.lowercased() where character.isLetter {
                frequencies[character, default: 0] += 1
            }
        }
        let sortedFrequencies = frequencies.sorted { $0.value > $1.value }
        let topCharacters = Array(sortedFrequencies.prefix(3))

        topCharTitleLbl?.isHidden = true
        charatterLbl1?.isHidden = true
        charatterLbl2?.isHidden = true
        charatterLbl3?.isHidden = true

        if !topCharacters.isEmpty {
            topCharTitleLbl?.text = "Top Characters:"
            topCharTitleLbl?.isHidden = false

            if topCharacters.count >= 1 {
                let (char, count) = topCharacters[0]
                charatterLbl1?.text = "\(String(char).uppercased()) = \(count)"
                charatterLbl1?.isHidden = false
            }
            if topCharacters.count >= 2 {
                let (char, count) = topCharacters[1]
                charatterLbl2?.text = "\(String(char).uppercased()) = \(count)"
                charatterLbl2?.isHidden = false
            }
            if topCharacters.count >= 3 {
                let (char, count) = topCharacters[2]
                charatterLbl3?.text = "\(String(char).uppercased()) = \(count)"
                charatterLbl3?.isHidden = false
            }
        } else if !items.isEmpty {
             topCharTitleLbl?.text = "No alphabetic characters found."
             topCharTitleLbl?.isHidden = false
        }
    }

    private func nibSetUp() {
        view = viewFromNib()
        view.frame = self.bounds
        view.autoresizingMask  = [.flexibleWidth, .flexibleHeight]
        view.translatesAutoresizingMaskIntoConstraints = true
        addSubview(view)
    }

    private func viewFromNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: NeoSoftStrings.MyCustomBottomSheetView.rawValue, bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        return view
    }
}
