//
//  MultilineTextFieldViewModel.swift
//  MultilineTextField
//
//  Created by Red on 2023/08/22.
//

import SwiftUI
import Combine

public class MultilineTextFieldViewModel: ObservableObject {
    private var cancellables: Set<AnyCancellable> = []
    @Published public var viewModels: [MultilineTextFieldItemViewModel] = []
    @Published public var focused: MultilineTextFieldItemViewModel?
    
    public init(font size: CGFloat, placeholder: String, focused: Bool, onChanged: @escaping ([MultilinTextData]) -> Void) {
        let itemViewModel: MultilineTextFieldItemViewModel = .init(placeholder: placeholder, font: size, onRemove: { viewModel in
            self.onRemove(viewModel: viewModel)
        })
        viewModels = [itemViewModel]
        itemViewModel.focused = focused
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
                let data: [MultilinTextData] = self.viewModels.map { $0.data }
                onChanged(data)
            }
            .store(in: &cancellables)
    }
    
    public func onRemove(viewModel: MultilineTextFieldItemViewModel) {
        guard let index = viewModels.firstIndex(of: viewModel), index > 0 else { return }
        viewModels.remove(at: index)
        let viewModel = viewModels[index - 1]
        viewModel.focused = true
    }
}
