//
//  MultilineTextFieldViewModel.swift
//  HSBMultilineTextField
//
//  Created by Red on 2023/08/22.
//

import SwiftUI
import Combine

public class MultilineTextFieldViewModel: ObservableObject {
    private var cancellables: Set<AnyCancellable> = []
	public let fontSizeList: [CGFloat]
	@Published public var italic: Bool?
	@Published public var bold: Bool?
	@Published public var fontSize: CGFloat?
    @Published public var viewModels: [MultilineTextFieldItemViewModel] = []
    @Published public var focused: MultilineTextFieldItemViewModel?
    
    public init(placeholder: String, data: [MultilineTextData]?, fontSizeList: [CGFloat], focused: Bool, onChanged: @escaping ([MultilineTextData]) -> Void) {
		guard !fontSizeList.isEmpty else {
			fatalError("font size is 0")
		}
		self.fontSizeList = fontSizeList
        initialize(placeholder: placeholder, data: data, focused: focused, onChanged: onChanged)
    }
    
    public func initialize(placeholder: String, data: [MultilineTextData]?, focused: Bool, onChanged: @escaping ([MultilineTextData]) -> Void) {
        if let data = data, !data.isEmpty {
            viewModels = self.transform(placeholder: placeholder, data: data)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.viewModels.last?.focused = true
            }
        } else {
			let itemViewModel: MultilineTextFieldItemViewModel = .init(placeholder: placeholder, font: fontSizeList.first!, onRemove: { viewModel in
                self.onRemove(viewModel: viewModel)
            })
            viewModels = [itemViewModel]
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                itemViewModel.focused = focused
            }
        }
        
        $viewModels
            .flatMap { viewModels in
                let textPublisher = Publishers
                    .MergeMany(viewModels
                        .compactMap { $0.$text })
                        .map { _ in () }
                let boldPublisher = Publishers
                    .MergeMany(viewModels
                        .compactMap { $0.$bold })
                        .map { _ in () }
                let fontSizePublisher = Publishers
                    .MergeMany(viewModels
                        .compactMap { $0.$fontSize })
                        .map { _ in () }
                return Publishers
                    .Merge3(textPublisher, boldPublisher, fontSizePublisher)
                    .dropFirst(3)
            }
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                guard let `self` = self else { return }
                let data: [MultilineTextData] = self.viewModels.map { $0.data }
                onChanged(data)
            }
            .store(in: &cancellables)
    }
    
    public func transform(placeholder: String, data: [MultilineTextData]) -> [MultilineTextFieldItemViewModel] {
        return data.enumerated().map { index, item in
            let placeholder: String = index == 0 ? placeholder : ""
            let itemViewModel: MultilineTextFieldItemViewModel = .init(placeholder: placeholder, text: item.text, font: item.fontSize, bold: item.bold, italic: item.italic, onRemove: { viewModel in
                self.onRemove(viewModel: viewModel)
            })
            return itemViewModel
        }
    }
    
    public func onRemove(viewModel: MultilineTextFieldItemViewModel) {
        guard let index = viewModels.firstIndex(of: viewModel), index > 0 else { return }
        viewModels.remove(at: index)
        let viewModel = viewModels[index - 1]
        viewModel.focused = true
    }
}
