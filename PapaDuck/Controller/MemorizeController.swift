//
//  MemorizeController.swift
//  PapaDuck
//
//  Created by 전성진 on 8/13/24.
//

import UIKit

import SnapKit

class MemorizeController: UIViewController {
    var wordsBookId: UUID?
    var mode: buttonState = .allWords
    private var wordList: [WordsEntity] = []
    private var wordViews: [UIView] = []
    private var currentIndex: Int = 0
    private var memorizeView: MemorizeView!
    private let wordDataManager: WordsCoreDataManager = WordsCoreDataManager()
    private let userDataManager: UserCoreDataManager = UserCoreDataManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "단어장 외우기"
        memorizeView = MemorizeView()
        self.view = memorizeView
        
        getWordList()
        wordViews = configureViews()
        
        // 첫 번째 뷰를 초기 설정
        if let firstView = wordViews.first {
            firstView.frame = self.view.bounds
            memorizeView.borderView.addSubview(firstView)
            firstView.snp.makeConstraints {
                $0.edges.equalToSuperview().inset(40)
            }
        } else {
            emptyListAlert()
        }
        
        configureEvents()
    }
    
    private func configureEvents() {
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture(_:)))
        swipeLeft.direction = UISwipeGestureRecognizer.Direction.left
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture(_:)))
        swipeRight.direction = UISwipeGestureRecognizer.Direction.right
        memorizeView.borderView.addGestureRecognizer(swipeLeft)
        memorizeView.borderView.addGestureRecognizer(swipeRight)
    }
    
    @objc func respondToSwipeGesture(_ gesture: UISwipeGestureRecognizer) {
        let direction: UISwipeGestureRecognizer.Direction = gesture.direction
        let isSwipingLeft = direction == .left
        
        let currentWord: WordsEntity = wordList[currentIndex]
        
        if isSwipingLeft {
            memorizeView.backgroundColor = .subBlue3
            memorizeView.borderView.backgroundColor = .subBlue3
            wordDataManager.updateWords(entity: currentWord, newWords: currentWord.word!, newWordsMeaning: currentWord.meaning!, memorizationYn: true)
            userDataManager.updateExp(plus: 5)
            print("외웠다")
        } else {
            memorizeView.backgroundColor = .subRed
            memorizeView.borderView.backgroundColor = .subRed
            wordDataManager.updateWords(entity: currentWord, newWords: currentWord.word!, newWordsMeaning: currentWord.meaning!, memorizationYn: false)
            userDataManager.updateExp(plus: 2)
            print("못외웠다")
        }
        
        guard let currentView = wordViews.first else { return }
        
        // 다음 뷰 설정
        let translationX = isSwipingLeft ? -self.memorizeView.borderView.bounds.width : self.memorizeView.borderView.bounds.width
        
        // 애니메이션 적용
        UIView.animate(withDuration: 0.7, delay: 0, options: [.curveEaseInOut, .allowUserInteraction], animations: {
            // 현재 뷰를 화면 밖으로 이동
            currentView.transform = CGAffineTransform(translationX: translationX, y: 0)
        }, completion: { [weak self] _ in
            guard let self = self else { return }
            
            // 애니메이션 완료 후 이전 뷰를 제거
            currentView.removeFromSuperview()
            self.wordViews.removeFirst()
            
            // 다음 뷰가 있다면 추가
            if let nextView = self.wordViews.first {
                nextView.frame = self.memorizeView.borderView.bounds
                self.memorizeView.borderView.addSubview(nextView)
                nextView.snp.makeConstraints { make in
                    make.edges.equalToSuperview().inset(40)
                }
                currentIndex += 1
            } else {
                emptyListAlert()
            }
            
            UIView.animate(withDuration: 0.3) {
                self.memorizeView.backgroundColor = .white
                self.memorizeView.borderView.backgroundColor = .white
            }
        })
    }
    
    @objc func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard let wordLabel = gesture.view as? UILabel else { return }
        
        // view 내의 meaningLabel을 찾아서 처리
        if let meaningLabel = wordLabel.superview?.subviews.compactMap({ $0 as? UILabel }).last {
            switch gesture.state {
            case .began:
                // 터치가 시작되면 meaningLabel을 보이게 설정
                meaningLabel.isHidden = false
            case .ended, .cancelled:
                // 터치가 끝나면 meaningLabel을 숨김
                meaningLabel.isHidden = true
            default:
                break
            }
        }
    }
    
    private func emptyListAlert() {
        let alert = UIAlertController(title: "알림", message: "모든 단어를 확인하였습니다.", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "확인", style: .default) { (action) in
            self.navigationController?.popViewController(animated: true)
        }
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
    
    private func getWordList() {
        guard let id = wordsBookId else { return }
        let list = wordDataManager.retrieveWordsBookInfos(wordsBookId: id).shuffled()
        
        switch mode {
        case .allWords:
            wordList = list
        case .unmemorizedWords:
            wordList = list.filter { !$0.memorizationYn }
        }
    }
    
    private func configureViews() -> [UIView] {
        return wordList.map { word in
            let view = UIView()
            let wordLabel = UILabel()
            let meaningLabel = UILabel()
            
            view.backgroundColor = .subYellow
            view.layer.cornerRadius = 20
            view.layer.shadowColor = UIColor.black.cgColor
            view.layer.shadowOpacity = 0.2
            view.layer.shadowOffset = CGSize(width: 0, height: 2)
            view.layer.shadowRadius = 4
            view.layer.masksToBounds = false
            
            wordLabel.text = "\(word.word ?? "")"
            wordLabel.textColor = .black
            wordLabel.font = .boldSystemFont(ofSize: 30)
            
            meaningLabel.text = "\(word.meaning ?? "")"
            meaningLabel.textColor = .gray
            meaningLabel.font = .systemFont(ofSize: 15)
            meaningLabel.isHidden = true // 처음에는 숨김
            
            [wordLabel, meaningLabel].forEach {
                view.addSubview($0)
            }
            
            wordLabel.snp.makeConstraints {
                $0.center.equalToSuperview()
            }
            
            meaningLabel.snp.makeConstraints {
                $0.centerX.equalTo(wordLabel.snp.centerX)
                $0.top.equalTo(wordLabel.snp.bottom).offset(30)
            }
            
            // UILongPressGestureRecognizer 추가
            let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
            longPressGesture.minimumPressDuration = 0 // 즉시 반응하게 설정
            wordLabel.addGestureRecognizer(longPressGesture)
            wordLabel.isUserInteractionEnabled = true
            
            return view
        }
    }
}
