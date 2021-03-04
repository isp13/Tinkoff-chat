//
//  ProfileViewController.swift
//  TinkoffChat
//
//  Created by Никита Казанцев on 22.02.2021.
//

import UIKit

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    
    @IBOutlet weak private var avatarContainerView: UIView!
    @IBOutlet weak private var avatarImageView: UIImageView!
    
    @IBOutlet weak private var editButton: UIButton!
    
    private var imagePicker = UIImagePickerController()
    
    
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
    }
    
    private func setupAvatarImageView() {
        avatarImageView.isUserInteractionEnabled = true
        avatarImageView.contentMode = .scaleToFill
        avatarImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(editAvatarButtonTapped(_:))))
    }
    
    private func setupImagePicker() {
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
    }
    
    private func setupEditButton() {
        editButton.layer.cornerRadius = 14
        avatarImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(editAvatarButtonTapped(_:))))
    }
    
    
    
    @objc func editAvatarButtonTapped(_ sender: Any) {
        showAvatarChangeActionSheet()
    }
    
    /**
     Simple Action Sheet
     - Show action sheet with title and alert message and actions
     */
    func showAvatarChangeActionSheet() {
        let alert = UIAlertController(title: "Загрузить фото", message: "Выберите способ загрузки фотографии", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Установить из галереи", style: .default, handler: { [self] (_) in
            
            if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
                imagePicker.sourceType = .savedPhotosAlbum
                present(imagePicker, animated: true, completion: nil)
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Сделать фото", style: .default, handler: { (_) in
            
            if UIImagePickerController.isSourceTypeAvailable(.camera){
                self.imagePicker.sourceType = .camera
                self.present(self.imagePicker, animated: true, completion: nil)
            }
            
        }))
        
        alert.addAction(UIAlertAction(title: "Отменить", style: .cancel))
        
        self.present(alert, animated: true)
    }
    

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let image = info[.originalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        avatarImageView.image = image
    }
    
}
