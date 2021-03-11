//
//  ThemesViewController.swift
//  TinkoffChat
//
//  Created by Никита Казанцев on 08.03.2021.
//


import UIKit

// retain cycle может появиться при сильных ссылках обоих классов друг на друга
// у нас он не мог возникнуть
// теоретически он возможен если бы мы обращались к self полям др класса в замыкании не по weak ссылке, а по strong
// - тогда объекты остаются захваченными в замыкании и не могут быть удалены

class ThemesViewController: UIViewController {
    
    @IBOutlet weak var classicView: UIView!
    
    @IBOutlet weak var dayView: UIView!
    
    @IBOutlet weak var nightView: UIView!
    
    @IBOutlet weak var defaultNameLabel: UILabel!
    @IBOutlet weak var dayNameLabel: UILabel!
    @IBOutlet weak var nightNameLabel: UILabel!
    
    
    weak var delegate: ThemesPickerDelegate?
    
    var closure: ((Theme) -> Void )?
    
    var selectedTheme = ThemeManager.current
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = ThemeManager.current.mainColors.primaryBackground
        
        
        setupThemeButtons()
    }
    
    private func setupThemeButtons() {
        selectedTheme = ThemeManager.current
        // Do any additional setup after loading the view.
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        
        let tap3 = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        
        classicView.addGestureRecognizer(tap)
        classicView.layer.borderWidth = selectedTheme.rawValue == 0 ? 2 : 0
        classicView.layer.borderColor = UIColor.blue.cgColor
        
        dayView.addGestureRecognizer(tap2)
        dayView.layer.borderWidth = selectedTheme.rawValue == 1 ? 2 : 0
        dayView.layer.borderColor = UIColor.blue.cgColor
        
        nightView.addGestureRecognizer(tap3)
        nightView.layer.borderWidth = selectedTheme.rawValue == 2 ? 2 : 0
        nightView.layer.borderColor = UIColor.blue.cgColor
        
        defaultNameLabel.textColor = selectedTheme.mainColors.profile.text
        dayNameLabel.textColor = selectedTheme.mainColors.profile.text
        nightNameLabel.textColor = selectedTheme.mainColors.profile.text
        
        self.view.backgroundColor =  selectedTheme.mainColors.primaryBackground
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        switch (sender?.view?.tag) {
        case 0: // classic
            classicView.layer.borderWidth = 2
            dayView.layer.borderWidth = 0
            nightView.layer.borderWidth = 0
            
            selectedTheme = .init(0)
            break
        case 1: // day
            classicView.layer.borderWidth = 0
            dayView.layer.borderWidth = 2
            nightView.layer.borderWidth = 0
            
            selectedTheme = .init(1)
            break
        case 2: // night
            classicView.layer.borderWidth = 0
            dayView.layer.borderWidth = 0
            nightView.layer.borderWidth = 2
            selectedTheme = .init(2)
            break
        default: // never happens
            break
        }
        
        ThemeManager.apply(selectedTheme) {
            DispatchQueue.main.async {
                //  self.delegate?.themeDidChange(self.selectedTheme)
                self.closure?(self.selectedTheme)
                self.updateThemeWithAnimation()
                self.navigationController?.isNavigationBarHidden = true
                self.navigationController?.isNavigationBarHidden = false
            }
        }
    }
    
    private func updateThemeWithAnimation() {
        UIView.animate(withDuration: 0.2) {
            self.view.backgroundColor = self.selectedTheme.mainColors.primaryBackground
            self.defaultNameLabel.textColor = self.selectedTheme.mainColors.profile.text
            self.dayNameLabel.textColor = self.selectedTheme.mainColors.profile.text
            self.nightNameLabel.textColor = self.selectedTheme.mainColors.profile.text
        }
    }
    
}
