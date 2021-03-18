//
//  ProfileViewController.swift
//  TinkoffChat
//
//  Created by Никита Казанцев on 22.02.2021.
//

import UIKit


class ProfileViewController: UIViewController, UINavigationControllerDelegate {
    
    var userDataStore: UserDataStore?
    
    private var profileModel: ProfileViewModel?
    
    
    private var theme: Theme = ThemeDataStore.shared.theme
    
    
    private var currentState: ProfileViewState = .base
    
    var onProfileChanged: ((ProfileViewModel) -> Void)?
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    var existingImage: UIImage?
    
    @IBOutlet weak private var avatarContainerView: UIView!
    @IBOutlet weak private var avatarImageView: UIImageView!
    
    @IBOutlet weak private var editButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var saveGCDButton: UIButton!
    @IBOutlet weak var saveOpeartionsButton: UIButton!
    
    @IBOutlet weak var saveButtonsStackView: UIStackView!
    
    @IBOutlet weak var nameLabel: UITextField!
    @IBOutlet weak var descriptionLabel: UITextView!
    
    private var imagePicker = UIImagePickerController()
    
    enum ProfileViewState: String {
        case base // в самом начале
        case view // просмотр без редактирования
        case editing // редактирование
        case hasChanges // есть изменения
        case saving // сохраняемся
    }
    
    
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
        
        setupBottomButtons()
        
        setupImagePicker()
        
        setupProfile()
        
        applyTheme()
        
        changeView(state: .view)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupKeyboard()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        scrollView.contentInset.bottom = 0
        (userDataStore?.profileManager as? OperationProfileDataManager)?.operationQueue.cancelAllOperations()
    }
    
    
    /// Надстройка, чтоб скролвью позволял скролиться при открытой клавиатуре
    private func setupKeyboard() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func keyboardWillShow(notification: NSNotification){
        guard let keyboardFrame = notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        scrollView.contentInset.bottom = view.convert(keyboardFrame.cgRectValue, from: nil).size.height
    }
    
    @objc private func keyboardWillHide(notification: NSNotification){
        scrollView.contentInset.bottom = 0
    }
    
    private func setupProfile() {
        if userDataStore?.profile?.avatar != nil {
            avatarImageView.image = userDataStore?.profile?.avatar
        }
        nameLabel.text = userDataStore?.profile?.name
        descriptionLabel.text = userDataStore?.profile?.description
        
        nameLabel.delegate = self
        nameLabel.addTarget(self, action: #selector(checkProfileDataForChanges), for: .editingChanged)
        descriptionLabel.delegate = self
    }
    
    /// изменяет доступность элементов в зависимости от стейта вью
    private func changeView(state: ProfileViewState, photoFirstChanged: Bool = false) {
        guard currentState != state else { return }
        
        Logger.log("Changing state to: \(state.rawValue)")
        currentState = state
        
        switch state {
        case .base:
            break
        case .view:
            activityIndicatorView.stopAnimating()
            // кнопка редактирования профиля
            editButton.isHidden = false
            
            // кнопки сохранений и отмены пока не отображаются
            cancelButton.isHidden = true
            saveButtonsStackView.isHidden = true
            
            // редактирование полей запрещено
            nameLabel.isEnabled = false
            descriptionLabel.isEditable = false
            descriptionLabel.isSelectable = false
            
        case .editing:
            
            // кнопка редактирования профиля пропадает, так как только что была нажата
            editButton.isHidden = true
            
            // появляется блок кнопок снизу для сохранений
            cancelButton.isHidden = false
            saveButtonsStackView.isHidden = false
            
            // но кнопки пока неактивны - не было никаких изменений
            saveGCDButton.isEnabled = false
            saveOpeartionsButton.isEnabled = false
            
            // редактирование полей разрешено
            nameLabel.isEnabled = true
            // перевод клавиатуры на редактирования первого поля
            if (!photoFirstChanged) {
                nameLabel.becomeFirstResponder()
            }
            
            descriptionLabel.isEditable = true
            descriptionLabel.isSelectable = true
            
        case .hasChanges:
            // найдены изменения, кнопки активировать
            saveGCDButton.isEnabled = true
            saveOpeartionsButton.isEnabled = true
        case .saving:
            activityIndicatorView.startAnimating()
            saveGCDButton.isEnabled = false
            saveOpeartionsButton.isEnabled = false
        }
        
    }
    
    // MARK: UI Setup
    
    /// применяем новую тему ко вью (изменяет цвета элементов вью)
    func applyTheme() {
        view.backgroundColor = theme.mainColors.primaryBackground
        
        editButton.titleLabel?.textColor = theme.mainColors.buttons.text
        editButton.backgroundColor = theme.mainColors.buttons.primaryButtonBackground
        
        cancelButton.titleLabel?.textColor = theme.mainColors.buttons.text
        cancelButton.backgroundColor = theme.mainColors.buttons.primaryButtonBackground
        
        saveGCDButton.titleLabel?.textColor = theme.mainColors.buttons.text
        saveGCDButton.backgroundColor = theme.mainColors.buttons.primaryButtonBackground
        
        saveOpeartionsButton.titleLabel?.textColor = theme.mainColors.buttons.text
        saveOpeartionsButton.backgroundColor = theme.mainColors.buttons.primaryButtonBackground
        
        nameLabel.textColor = theme.mainColors.profile.text
        descriptionLabel.textColor = theme.mainColors.profile.text
    }
    
    private func setupImagePicker() {
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        
        if #available(iOS 13.0, *) {
            imagePicker.overrideUserInterfaceStyle = theme == Theme.Night ? .dark : .light
        }
    }
    
    private func setupAvatarImageView() {
        avatarImageView.isUserInteractionEnabled = true
        avatarImageView.contentMode = .scaleToFill
        avatarImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(editAvatarButtonTapped(_:))))
    }
    
    private func setupBottomButtons() {
        editButton.layer.cornerRadius = 14
        
        cancelButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(cancelButtonTapped(_:))))
        editButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(editButtonTapped(_:))))
        
        saveGCDButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(GCDSaveTapped(_:))))
        saveOpeartionsButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(OperationsSaveTapped(_:))))
    }
    
    
    // MARK: Private API
    
    /// обновляет лейблы профиля на новые. Функция вызывается только если есть изменения
    private func updateData() {
        nameLabel.text = profileModel?.name ?? ""
        descriptionLabel.text = profileModel?.description ?? ""
        avatarImageView.image = profileModel?.avatar
    }
    
    /// проверка были ли совершены какие-то изменения в текстах лейблов пользователем
    @objc func checkProfileDataForChanges() {
        // изменились ли данные от первоначальных?
        // Т.е. было ли что-то отредактировано - проверяем, изображение проверяем по ссылке объекта
        var hasDataChanges = false
        
        // если что-то было изменено
        if  (profileModel?.name != nameLabel.text || profileModel?.description != descriptionLabel.text ||
                profileModel?.avatar !== avatarImageView.image) {
            hasDataChanges = true
        }
        
        changeView(state: hasDataChanges ? .hasChanges : .editing)
    }
    
    /// сохранение новой информации пользователя асинхронно
    private func saveProfileChanges() {
        Logger.log("Saving profile")
        changeView(state: .saving)
        let newProfile = ProfileViewModel(
            name: nameLabel.text ?? "",
            description: descriptionLabel.text ?? "",
            avatar: (avatarImageView.image ?? UIImage(named: "avatar2")) ?? UIImage())
        
        userDataStore?.saveProfile(profile: newProfile, completion: { [weak self] (success) in
            // успех в сохранении
            if success {
                DispatchQueue.main.async {
                    self?.onProfileChanged?(newProfile)
                    
                    self?.showAlert(title: "Success", message: "Data was saved!", closeAction: {
                        self?.changeView(state: .view)
                    })
                    
                }
            }
            else { // что-то пошло не так. Повторить?
                DispatchQueue.main.async {
                    self?.changeView(state: .view)
                    
                    self?.showAlert(title: "Error", message: "error while saving content. Retry?", retryAction:  {
                        self?.saveProfileChanges()
                    })
                }
            }
        })
    }
    
    
    /// показ alert с предложениями по загрузке фото (из галереи, сделать фото)
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
    
    /// показ алерта с данными параметрами
    private func showAlert(title: String, message: String, closeAction: (() -> Void)? = nil, retryAction: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.title = title
        alert.message = message
        
        if #available(iOS 13.0, *) {
            alert.overrideUserInterfaceStyle = theme == Theme.Night ? .dark : .light
        }
        
        if let closeAction = closeAction {
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
                closeAction()
            }))
        }
        else {
            alert.addAction(UIAlertAction(title: "OK", style: .default))
        }
        
        if let retryAction = retryAction {
            alert.addAction(UIAlertAction(title: "Retry", style: .default, handler: { (_) in
                retryAction()
            }))
        }
        
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Tap Actions
    
    @objc func editAvatarButtonTapped(_ sender: Any) {
        showAvatarChangeActionSheet()
    }
    
    @objc func editButtonTapped(_ sender: Any) {
        changeView(state: .editing)
    }
    
    @objc func cancelButtonTapped(_ sender: Any) {
        avatarImageView.image = userDataStore?.profile?.avatar
        nameLabel.text = userDataStore?.profile?.name
        descriptionLabel.text = userDataStore?.profile?.description
        
        changeView(state: .view)
    }
    
    @objc func GCDSaveTapped(_ sender: Any) {
        userDataStore = UserDataStore(profileManager: GCDProfileDataManager())
        saveButtonTapped()
    }
    
    @objc func OperationsSaveTapped(_ sender: Any) {
        userDataStore = UserDataStore(profileManager: OperationProfileDataManager())
        saveButtonTapped()
    }
    
    func saveButtonTapped() {
        switch currentState {
        case .base, .editing, .saving:
            break
        case .view:
            changeView(state: .editing)
        case .hasChanges:
            saveProfileChanges()
        }
    }
}


// MARK: - UIImagePickerControllerDelegate

extension ProfileViewController: UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let image = info[.originalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        
        changeView(state: .editing, photoFirstChanged: true)
        changeView(state: .hasChanges)
        
        avatarImageView.image = image
        
    }
}


// MARK: - UITextViewDelegate, UITextFieldDelegate

extension ProfileViewController: UITextViewDelegate, UITextFieldDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        if textView === descriptionLabel {
            checkProfileDataForChanges()
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        // чтобы убрать клавиатуру при тапе на done
        if (text == "\n") {
            textView.resignFirstResponder()
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        checkProfileDataForChanges()
        return false
    }
}
