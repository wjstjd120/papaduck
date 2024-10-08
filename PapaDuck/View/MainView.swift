//
//  MainView.swift
//  PapaDuck
//
//  Created by 이주희 on 8/12/24.
//

import UIKit
import SnapKit

protocol MainViewDelegate: AnyObject {
    func mainView(_ mainView: MainView, didSelectBook book: WordsBookEntity)
    func mainViewDidRequestAddWord(_ mainView: MainView)
}

class MainView: UIView {
    weak var delegate: MainViewDelegate?
    var data = [WordsBookEntity]()
    
    // MARK: - UI Components
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "PAPADUCK"
        label.font = FontNames.mainFont.font()
        label.textColor = UIColor.subBlue
        label.textAlignment = .center
        return label
    }()

    private let logoImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "Logo"))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let bubbleImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "bubble"))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    let addLabel: UILabel = {
        let label = UILabel()
        label.text = "단어장을 만들으세요..."
        label.font = FontNames.main2Font2.font()
        label.textColor = UIColor.black
        label.isUserInteractionEnabled = true
        return label
    }()

    private let paduckImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "papaduck"))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let dataEmptyView: UIView = {
        let view = UIView()
        return view
    }()

    let vocabularyCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        return collectionView
    }()

    private lazy var addVocaButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor.mainYellow
        button.setTitle("단어장 추가", for: .normal)
        button.setTitleColor(.subBlack, for: .normal)
        button.titleLabel?.font = FontNames.subFont2.font()
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(didTapAddVocaButton), for: .touchUpInside)
        return button
    }()

    private let dataStateView: UIView = {
        let view = UIView()
        return view
    }()
    
    // MARK: - 초기화
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupConstraints()
        setupCollectionView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    
    // MARK: - Setup
    private func setupView() {
        
        [titleLabel, logoImageView, dataEmptyView, dataStateView].forEach { addSubview($0)}
        [bubbleImageView, paduckImageView, addLabel].forEach { dataEmptyView.addSubview($0)}
        [vocabularyCollectionView, addVocaButton].forEach { dataStateView.addSubview($0)}
    }
    
    private func setupConstraints() {
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(80)
            $0.leading.equalTo(logoImageView.snp.trailing).offset(20)
        }
        
        logoImageView.snp.makeConstraints {
            $0.centerY.equalTo(titleLabel)
            $0.leading.equalToSuperview().offset(40)
            $0.width.height.equalTo(50)
        }
        
        dataStateView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(20)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.bottom.equalToSuperview().offset(-83)
        }
        
        vocabularyCollectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        dataEmptyView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        bubbleImageView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(300)
            $0.width.equalTo(200)
            $0.height.equalTo(100)
        }
        
        addLabel.snp.makeConstraints {
            $0.center.equalTo(bubbleImageView.snp.center)
        }
        
        paduckImageView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(bubbleImageView.snp.bottom)
            $0.width.equalTo(300)
            $0.height.equalTo(200)
        }
    }
    
    private func setupCollectionView() {
        vocabularyCollectionView.dataSource = self
        vocabularyCollectionView.delegate = self
        vocabularyCollectionView.register(VocaCollectionCell.self, forCellWithReuseIdentifier: "mainViewCollectioncell")
        vocabularyCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "addVocaCell")
    }
    
    // MARK: - Public Methods
    func updateView(forDataAvailability hasData: Bool) {
        dataEmptyView.isHidden = hasData
        dataStateView.isHidden = !hasData
    }
    
    func setData(_ data: [WordsBookEntity]) {
        self.data = data
        updateView(forDataAvailability: !data.isEmpty)
        vocabularyCollectionView.reloadData()
    }
    
    // MARK: - Actions
    @objc private func didTapAddVocaButton() {
        delegate?.mainViewDidRequestAddWord(self)
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
extension MainView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // 셀의 개수를 반환합니다. 마지막에 추가 버튼을 위한 셀을 포함합니다.
        return data.count + 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == data.count {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "addVocaCell", for: indexPath)
            cell.contentView.addSubview(addVocaButton)
            addVocaButton.snp.makeConstraints {
                $0.edges.equalToSuperview()
                $0.height.equalTo(50)
            }
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "mainViewCollectioncell", for: indexPath) as! VocaCollectionCell
            let model = data[indexPath.row]
            cell.configure(with: model)
            cell.delegate = delegate as? VocaCollectionCellDelegate  // Delegate 설정
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height: CGFloat = indexPath.row == data.count ? 50 : 100
        return CGSize(width: collectionView.bounds.width - 32, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == data.count {
            delegate?.mainViewDidRequestAddWord(self)
        } else {
            let selectedBook = data[indexPath.row]
            delegate?.mainView(self, didSelectBook: selectedBook)
        }
    }
}
