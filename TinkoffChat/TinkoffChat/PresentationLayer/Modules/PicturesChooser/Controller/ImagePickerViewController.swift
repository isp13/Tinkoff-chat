import UIKit

protocol ImagePickerViewControllerDelegate: AnyObject {
    func imagePicker(_ viewController: ImagePickerViewController, didSelectedImage image: UIImage?)
}

class ImagePickerViewController: UIViewController {
    
    var avatarService: AvatarServiceProtocol?
    var theme: Theme?
    var images: [AvatarViewModel] = []
    
    private let itemPerRow: CGFloat = 3
    private let itemSpacing: CGFloat = 10
    
    weak var delegate: ImagePickerViewControllerDelegate?
    
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setupTheme()
        loadAvatarList()
    }
    
    private func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.register(UINib(nibName: "\(AvatarItemCollectionViewCell.self)", bundle: nil),
                                forCellWithReuseIdentifier: "\(AvatarItemCollectionViewCell.self)")
    }
    
    private func setupTheme() {
        collectionView.backgroundColor = theme?.mainColors.primaryBackground
        view.backgroundColor = theme?.mainColors.primaryBackground
    }
    
    private func loadAvatarList() {
        activityIndicatorView.startAnimating()
        avatarService?.loadImageList(handler: { [weak self] (result) in
            DispatchQueue.main.async {
                self?.activityIndicatorView.stopAnimating()
            }
            switch result {
            case .success(let imageLinkList):
                let avatarModels = imageLinkList.map {
                    AvatarViewModel(image: nil, url: $0)
                }
                self?.update(with: avatarModels)
            case .failure(let error):
                self?.showErrorAlert(error.localizedDescription)
            }
        })
    }
    
    private func update(with avatars: [AvatarViewModel]) {
        DispatchQueue.main.async { [weak self] in
            self?.images = avatars
            self?.collectionView.reloadData()
        }
    }
    
    private func fetchImage(at index: Int, for model: AvatarViewModel) {
        var copyModel = model
        copyModel.isFetching = true
        images[index] = copyModel
        avatarService?.loadImage(urlPath: copyModel.url) { [weak self] (result) in
            switch result {
            case .success(let imageData):
                guard let image = UIImage(data: imageData) else {
                    return
                }
                copyModel.isFetching = false
                copyModel.image = image
                self?.updateCell(at: index, with: copyModel)
            case .failure(let error):
                self?.showErrorAlert(error.localizedDescription)
            }
        }
    }
    
    private func updateCell(at index: Int, with model: AvatarViewModel) {
        DispatchQueue.main.async { [weak self] in
            self?.images[index] = model
            self?.collectionView.reloadItems(at: [.init(item: index, section: 0)])
        }
    }
    
    private func showErrorAlert(_ message: String) {
        DispatchQueue.main.async { [weak self] in
            let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self?.present(alert, animated: true, completion: nil)
        }
    }
    
}

extension ImagePickerViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "\(AvatarItemCollectionViewCell.self)", for: indexPath) as? AvatarItemCollectionViewCell else {
            return UICollectionViewCell()
        }
        let imageModel = images[indexPath.item]
        cell.configure(with: imageModel)
        if imageModel.image == nil && !imageModel.isFetching {
            fetchImage(at: indexPath.item, for: imageModel)
        }
        return cell
    }
    
}

extension ImagePickerViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpace = itemSpacing * (itemPerRow + 1)
        let availableWidth = collectionView.bounds.width - paddingSpace
        let itemWidth = (availableWidth / itemPerRow).rounded(.down)
        return CGSize(width: itemWidth, height: itemWidth)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: itemSpacing, left: itemSpacing, bottom: 0, right: itemSpacing)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return itemSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return itemSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let imageModel = images[indexPath.item]
        guard let image = imageModel.image else {
            return
        }
        delegate?.imagePicker(self, didSelectedImage: image)
        
        self.dismiss(animated: true, completion: nil)
    }
    
}
