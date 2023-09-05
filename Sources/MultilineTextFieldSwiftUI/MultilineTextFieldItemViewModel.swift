//
//  MultilineTextFieldItemViewModel.swift
//  HSBMultilineTextField
//
//  Created by Red on 2023/08/22.
//

import SwiftUI
import Combine

public class MultilineTextFieldItemViewModel: NSObject, ObservableObject {
    
    private let onRemove: (MultilineTextFieldItemViewModel) -> Void
    private var cancellables: Set<AnyCancellable> = []
    private var isFirst: Bool = true
    public let placeholder: String
    @Published public var text: String
	@Published public var bold: Bool
	@Published public var italic: Bool
    @Published public var fontSize: CGFloat
    @Published public var focused: Bool = false
    @Published public var height: CGFloat = 17
    public var textView: UITextView?
    public var data: MultilineTextData {
        .init(bold: bold, italic: italic, fontSize: fontSize, text: text)
    }
    
    public var displayFont: Font {
        let font = Font.system(
           size: CGFloat(fontSize),
             weight: bold == true ? .bold : .regular)
		return italic ? font.italic() : font
    }
    
	public init(placeholder: String = "", text: String = "", font size: CGFloat, bold: Bool = false, italic: Bool = false, onRemove: @escaping (MultilineTextFieldItemViewModel) -> Void) {
        self.placeholder = placeholder
        self.text = text
        self.fontSize = size
        self.bold = bold
		self.italic = italic
        self.onRemove = onRemove
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
            DispatchQueue.main.async {
                self.height = newSize.height
            }
        }
    }
    
    public func textViewDidChange(_ textView: UITextView) {
        DispatchQueue.main.async {
            self.text = textView.text
        }
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
