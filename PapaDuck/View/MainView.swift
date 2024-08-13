//
//  MainView.swift
//  PapaDuck
//
//  Created by 이주희 on 8/12/24.
//

// 로고, 타이틀 뷰
// 단어장 있을때,
// 단어장 없을때, 파덕이미지뷰, 말풍선 이미지뷰
// 말풍선 이미지 뷰 액션 > 단어장 추가 뷰컨으로 이동

import UIKit
import SnapKit

class MainView: UIView, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout  {
        
    private let data = [String]()
    
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
        imageView.contentMode = .scaleAspectFill
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
    
    
    private let vocabularyCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        return collectionView
    }()
    
    private let addVocaButton: UIButton = {
        let button = UIButton()
        button.tintColor = UIColor.mainYellow
        return button
    }()
    
    private let dataStateView: UIView = {
        let view = UIView()
        return view
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupConstraints()
        setupCollectionView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    
    private func setupView() {
        [titleLabel, logoImageView, dataEmptyView, vocabularyCollectionView,dataStateView].forEach { addSubview($0)}
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
        
        dataEmptyView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.equalTo(300)
            $0.height.equalTo(500)
        }
        
        bubbleImageView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(dataEmptyView.snp.top).offset(300)
            $0.width.equalTo(200)
            $0.height.equalTo(100)
        }
        
        addLabel.snp.makeConstraints {
            $0.center.equalTo(bubbleImageView.snp.center)
        }
        
        paduckImageView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(bubbleImageView.snp.bottom).offset(20)
            $0.width.equalTo(300)
            $0.height.equalTo(200)
        }
        
        dataEmptyView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        vocabularyCollectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        addVocaButton.snp.makeConstraints {
            $0.top.equalTo(vocabularyCollectionView.snp.bottom).offset(20)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(150)
            $0.height.equalTo(50)
        }
    }
    
    private func setupCollectionView() {
        vocabularyCollectionView.dataSource = self
        vocabularyCollectionView.delegate = self
        vocabularyCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "mainViewCollectioncell")
    }
    
    func updateView(forDataAvailability hasData: Bool) {
        if hasData {
            dataEmptyView.isHidden = true
            vocabularyCollectionView.isHidden = false
        } else {
            dataEmptyView.isHidden = false
            vocabularyCollectionView.isHidden = true
        }
    }
    
    // MARK: - UICollectionViewDataSource
       func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
           return data.count
       }

       func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
           let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "mainViewCollectioncell", for: indexPath)
           cell.backgroundColor = .lightGray
           return cell
       }
       
       // MARK: - UICollectionViewDelegateFlowLayout
       func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
           return CGSize(width: collectionView.bounds.width - 20, height: 100)
       }
}

