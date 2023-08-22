//
//  MultilineTextFieldItemViewModel.swift
//  MultilineTextField
//
//  Created by Red on 2023/08/22.
//

import SwiftUI
import Combine

public class MultilineTextFieldItemViewModel: NSObject, ObservableObject {
    
    private let onRemove: (MultilineTextFieldItemViewModel) -> Void
    private var cancellables: Set<AnyCancellable> = []
    @Published public var text: String = ""
    @Published public var bold = false
    @Published public var fontSize: CGFloat
    @Published public var focused: Bool = false
    @Published public var height: CGFloat = 17
    public var textView: UITextView?
    public var data: MultilinTextData {
        .init(bold: bold, fontSize: fontSize, text: text)
    }
    
    public var displayFont: Font {
        let font = Font.system(
           size: CGFloat(fontSize),
             weight: bold == true ? .bold : .regular)
        return font
    }
    
    public init(font size: CGFloat, onRemove: @escaping (MultilineTextFieldItemViewModel) -> Void) {
        self.onRemove = onRemove
        self.fontSize = size
        super.init()
        $bold
            .combineLatest($fontSize)
            .sink { [weak self] _ in
                guard let `self` = self else { return }
                guard let textView = self.textView else {
                    return
                }
                self.sizeToFit(textView: textView)
            }
            .store(in: &cancellables)
    }
}

extension MultilineTextFieldItemViewModel: UITextViewDelegate {
    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard textView.text.isEmpty, let char = text.cString(using: String.Encoding.utf8) else {
            return true
        }
        let isBackSpace = strcmp(char, "\\b")
        if (isBackSpace == -92) {
            onRemove(self)
        }
        return true
    }
    
    public func sizeToFit(textView: UITextView) {
        let fixedWidth = textView.frame.size.width
        let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        if height != newSize.height {
            height = newSize.height
        }
    }
    
    public func textViewDidChange(_ textView: UITextView) {
        text = textView.text
        sizeToFit(textView: textView)
    }
    
    public func textViewDidBeginEditing(_ textView: UITextView) {
        sizeToFit(textView: textView)
    }
    
    public func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        sizeToFit(textView: textView)
        return true
    }
}
