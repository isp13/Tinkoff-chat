//
//  ProfileViewController.swift
//  TinkoffChat
//
//  Created by Никита Казанцев on 22.02.2021.
//

import UIKit

protocol ControllerDelegate {
    func changeAvatarBarView(_ image: UIImage?)
}

class ProfileViewController: UIViewController, UINavigationControllerDelegate, ThemesPickerDelegate {

    var delegate: ControllerDelegate?
    
    private var theme: Theme = ThemeManager.current
    
    var existingImage: UIImage?
    
    @IBOutlet weak private var avatarContainerView: UIView!
    @IBOutlet weak private var avatarImageView: UIImageView!
    
    @IBOutlet weak private var editButton: UIButton!
    
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    private var imagePicker = UIImagePickerController()
    
    // MARK: Life cycle
    
    // This is also necessary when extending the superclass.
    required init?(coder aDecoder: NSCoder) {
        
        // ошибка потому что кнопка еще не инициализирована и имеет значение nil
        // print(editButton.frame.debugDescription)
        
        // можем это проверить
        // print(editButton)
        
        super.init(coder: aDecoder)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        Logger.log(#function)
        
        // Frame кнопки отличается т.к. в Main.storyboard выбран iPhone SE(2nd generation), а запускаемый симулятор - iPhone 11.
        // В методе viewDidLoad выводятся frame кнопки в iPhone SE(2nd generation), а в методе viewDidAppear frame в симуляторе iPhone 11.
        Logger.log(editButton.frame.debugDescription)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        avatarContainerView.layer.cornerRadius = avatarContainerView.frame.size.height / 2
        avatarContainerView.clipsToBounds = true
        
        Logger.log(#function)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Logger.log(#function)
        Logger.log(editButton.frame.debugDescription)
        
        setupAvatarImageView()
        
        setupEditButton()
        
        setupImagePicker()
        
        apply()
    }
    
    
    // MARK: UI Setup
    
    func themeDidChange(_ theme: Theme) {
    }
    
    func apply() {
        view.backgroundColor = theme.mainColors.primaryBackground
        editButton.backgroundColor = .gray
        editButton.titleLabel?.textColor = theme.mainColors.profile.text
        
        nameLabel.textColor = theme.mainColors.profile.text
        descriptionLabel.textColor = theme.mainColors.profile.text
    }
    
    private func setupImagePicker() {
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
    }
    
    private func setupAvatarImageView() {
        
        if existingImage != nil {
            avatarImageView.image = existingImage
        }
        avatarImageView.isUserInteractionEnabled = true
        avatarImageView.contentMode = .scaleToFill
        avatarImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(editAvatarButtonTapped(_:))))
    }
    
    private func setupEditButton() {
        editButton.layer.cornerRadius = 14
        editButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(saveButtonTapped(_:))))
    }
    
    
    // MARK: Private API
    /**
     Simple Action Sheet
     - Show action sheet with title and alert message and actions
     */
    private func showAvatarChangeActionSheet() {
        let alert = UIAlertController(title: "Загрузить фото", message: "Выберите способ загрузки фотографии", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Установить из галереи", style: .default, handler: { [self] (_) in
            
            if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
                imagePicker.sourceType = .savedPhotosAlbum
                present(imagePicker, animated: true, completion: nil)
            }
        }))
        
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            alert.addAction(UIAlertAction(title: "Сделать фото", style: .default, handler: { (_) in
                
                
                self.imagePicker.sourceType = .camera
                self.present(self.imagePicker, animated: true, completion: nil)
            }))
        }
        
        alert.addAction(UIAlertAction(title: "Отменить", style: .cancel))
        
        if #available(iOS 13.0, *) {
            alert.overrideUserInterfaceStyle = theme == Theme.Night ? .dark : .light
        }
        
        self.present(alert, animated: true)
    }
    
    @objc func editAvatarButtonTapped(_ sender: Any) {
        showAvatarChangeActionSheet()
    }
    
    @objc func saveButtonTapped(_ sender: Any) {
        if avatarImageView.image != nil {
            delegate!.changeAvatarBarView(avatarImageView.image)
        }
        
        self.dismiss(animated: true, completion: nil)
    }
}


// MARK: - UIImagePickerControllerDelegate

extension ProfileViewController: UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let image = info[.originalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        avatarImageView.image = image
    }
}
