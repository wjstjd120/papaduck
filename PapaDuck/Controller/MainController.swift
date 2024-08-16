//
//  ViewController.swift
//  PapaDuck
//
//  Created by 이주희 on 8/12/24.
//

import UIKit
import SnapKit

class MainController: UIViewController {
    
    private let mainView = MainView()
    private let coreData = WordsBookCoreDataManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        loadWordsBooks()
        printWordsBookInfos() 
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadWordsBooks()
    }
    
    // MARK: - Setup Methods
    
    private func setupView() {
        view = mainView
        mainView.delegate = self
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleLabelTap))
        mainView.addLabel.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Data Loading
    
    private func loadWordsBooks() {
        let wordsBookEntities = coreData.retrieveWordsBookInfos()
        mainView.setData(wordsBookEntities)
    }
    
    // 프린트문 - 삭제가능
    private func printWordsBookInfos() {
        let wordsBookEntities = coreData.retrieveWordsBookInfos()
        for entity in wordsBookEntities {
            print("ID: \(entity.objectID), Name: \(entity.wordsBookName ?? "Unknown"), Explanation: \(entity.wordsExplain ?? "Unknown")")
        }
    }
    
    // MARK: - Actions
    
    @objc private func handleLabelTap() {
        let createWordsController = CreateWordsController()
        navigationController?.pushViewController(createWordsController, animated: true)
    }
}

// MARK: - MainViewDelegate
extension MainController: MainViewDelegate {
    func mainView(_ mainView: MainView, didSelectBook book: WordsBookEntity) {
        let wordListViewController = WordListViewController()
        wordListViewController.selectedBook = book
        navigationController?.pushViewController(wordListViewController, animated: true)
    }
    
    func mainViewDidRequestAddWord(_ mainView: MainView) {
        let createWordsController = CreateWordsController()
        navigationController?.pushViewController(createWordsController, animated: true)
    }
}

// MARK: - VocaCollectionCellDelegate
extension MainController: VocaCollectionCellDelegate {
    func vocaCollectionCellDidTapEdit(_ cell: VocaCollectionCell) {
        print("편집 버튼 클릭됨")
        
        if let indexPath = mainView.vocabularyCollectionView.indexPath(for: cell) {
            let selectedBook = mainView.data[indexPath.row]
            
            // 선택한 단어장 정보 출력
            print("선택된 단어장 - ID: \(selectedBook.wordsBookId ?? UUID()), 이름: \(selectedBook.wordsBookName ?? "알 수 없음"), 설명: \(selectedBook.wordsExplain ?? "알 수 없음")")
            
            let createWordsController = CreateWordsController()
            createWordsController.bookEntity = selectedBook

//            if let bookUUID = selectedBook.wordsBookId {
//                createWordsController.setCreateWord(wordBookId: bookUUID, wordBookName: selectedBook.wordsBookName ?? "기본 이름")
//            }

            navigationController?.pushViewController(createWordsController, animated: true)
        } else {
            print("셀의 인덱스 경로를 찾을 수 없음")
        }
    }
}
