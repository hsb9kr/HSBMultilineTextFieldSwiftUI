//
//  MultilineTextFieldViewModel.swift
//  HSBMultilineTextField
//
//  Created by Red on 2023/08/22.
//

import SwiftUI
import Combine

public class HSBMultilineTextFieldViewModel: ObservableObject {
    private var cancellables: Set<AnyCancellable> = []
    @Published public var viewModels: [HSBMultilineTextFieldItemViewModel] = []
    @Published public var focused: HSBMultilineTextFieldItemViewModel?
    
    public init(data: [HSBMultilineTextData]?, font size: CGFloat, placeholder: String, focused: Bool, onChanged: @escaping ([HSBMultilineTextData]) -> Void) {
        if let data = data {
            viewModels = data.enumerated().map { index, item in
                let placeholder: String = index == 0 ? placeholder : ""
                let itemViewModel: HSBMultilineTextFieldItemViewModel = .init(placeholder: placeholder, text: item.text, font: item.fontSize, bold: item.bold, onRemove: { viewModel in
                    self.onRemove(viewModel: viewModel)
                })
                return itemViewModel
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.viewModels.last?.focused = true
            }
        } else {
            let itemViewModel: HSBMultilineTextFieldItemViewModel = .init(placeholder: placeholder, font: size, onRemove: { viewModel in
                self.onRemove(viewModel: viewModel)
            })
            viewModels = [itemViewModel]
            itemViewModel.focused = focused
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
                let data: [HSBMultilineTextData] = self.viewModels.map { $0.data }
                onChanged(data)
            }
            .store(in: &cancellables)
    }
    
    public func onRemove(viewModel: HSBMultilineTextFieldItemViewModel) {
        guard let index = viewModels.firstIndex(of: viewModel), index > 0 else { return }
        viewModels.remove(at: index)
        let viewModel = viewModels[index - 1]
        viewModel.focused = true
    }
}
