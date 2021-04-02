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

protocol ThemesPickerDelegate: AnyObject {
    func themeDidChange(_ theme: Theme)
}

class ThemesViewController: UIViewController {
    
    @IBOutlet weak var classicView: UIView!
    @IBOutlet weak var dayView: UIView!
    @IBOutlet weak var nightView: UIView!
    
    @IBOutlet weak var defaultNameLabel: UILabel!
    @IBOutlet weak var dayNameLabel: UILabel!
    @IBOutlet weak var nightNameLabel: UILabel!
    
    weak var delegate: ThemesPickerDelegate?
    
    var closure: ((Theme) -> Void )?
    
    var themeManager = ThemeDataStore.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = themeManager.theme.mainColors.primaryBackground
        
        setupThemeButtons()
    }
    
    private func setupThemeButtons() {
        
        // Do any additional setup after loading the view.
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        
        let tap3 = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        
        classicView.addGestureRecognizer(tap)
        classicView.layer.borderWidth = themeManager.theme.rawValue == 0 ? 2 : 0
        classicView.layer.borderColor = UIColor.blue.cgColor
        
        dayView.addGestureRecognizer(tap2)
        dayView.layer.borderWidth = themeManager.theme.rawValue == 1 ? 2 : 0
        dayView.layer.borderColor = UIColor.blue.cgColor
        
        nightView.addGestureRecognizer(tap3)
        nightView.layer.borderWidth = themeManager.theme.rawValue == 2 ? 2 : 0
        nightView.layer.borderColor = UIColor.blue.cgColor
        
        defaultNameLabel.textColor = themeManager.theme.mainColors.profile.text
        dayNameLabel.textColor = themeManager.theme.mainColors.profile.text
        nightNameLabel.textColor = themeManager.theme.mainColors.profile.text
        
        self.view.backgroundColor = themeManager.theme.mainColors.primaryBackground
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        if let themeId = sender?.view?.tag {
            
            themeManager.saveTheme(theme: Theme(themeId)) { [self] success in
                if success {
                    
                    DispatchQueue.main.async {
                        switch themeId {
                        case 0: // classic
                            classicView.layer.borderWidth = 2
                            dayView.layer.borderWidth = 0
                            nightView.layer.borderWidth = 0
                        case 1: // day
                            classicView.layer.borderWidth = 0
                            dayView.layer.borderWidth = 2
                            nightView.layer.borderWidth = 0
                        case 2: // night
                            classicView.layer.borderWidth = 0
                            dayView.layer.borderWidth = 0
                            nightView.layer.borderWidth = 2
                        default: // never happens
                            break
                        }
                        
                        self.delegate?.themeDidChange(themeManager.theme)
                        self.closure?(themeManager.theme)
                        self.updateThemeWithAnimation(theme: themeManager.theme)
                        self.navigationController?.isNavigationBarHidden = true
                        self.navigationController?.isNavigationBarHidden = false
                    }
                }
            }
        }
    }
    
    private func updateThemeWithAnimation(theme: Theme) {
        UIView.animate(withDuration: 0.2) {
            self.view.backgroundColor = theme.mainColors.primaryBackground
            self.defaultNameLabel.textColor = theme.mainColors.profile.text
            self.dayNameLabel.textColor = theme.mainColors.profile.text
            self.nightNameLabel.textColor = theme.mainColors.profile.text
        }
    }
    
}
