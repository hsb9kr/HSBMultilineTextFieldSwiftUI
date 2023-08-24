//
//  MultilineTextField.swift
//  MultilineTextField
//
//  Created by Red on 2023/08/22.
//

import SwiftUI
import Combine
import SwiftUIIntrospect

public struct HSBMultilineTextField: View {
    
    private let regularFontSize: CGFloat
    private let mediumFontSize: CGFloat
    private let backgroundColor: Color = Color(uiColor: UIColor.systemBackground)
    private let padding: CGFloat = 4
    private let minHeight: CGFloat
    private let background: Color
    @State private var bold: Bool?
    @State private var fontSize: CGFloat?
    @StateObject private var viewModel: HSBMultilineTextFieldViewModel
    
    public init(placeholder: String = "", data: [HSBMultilineTextData]? = nil, regularFontSize: CGFloat = 15, mediumFontSize: CGFloat = 18, minHeight: CGFloat = 10, background: Color, focused: Bool = true, onChanged: @escaping ([HSBMultilineTextData]) -> Void) {
        self.regularFontSize = regularFontSize
        self.mediumFontSize = mediumFontSize
        self.minHeight = minHeight
        self.background = background
        let viewModel: HSBMultilineTextFieldViewModel = .init(data: data, font: regularFontSize, placeholder: placeholder, focused: focused, onChanged: onChanged)
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(0..<viewModel.viewModels.count, id: \.self) { index in
                        let viewModel = viewModel.viewModels[index]
                        ItemView(viewModel: viewModel)
                    }
                    Rectangle()
                        .foregroundColor(background)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .onTapGesture {
                            guard let last = viewModel.viewModels.last, !last.text.isEmpty else {
                                viewModel.viewModels.last?.focused = true
                                return
                            }
                            let itemViewModel: HSBMultilineTextFieldItemViewModel = .init(font: regularFontSize, onRemove: { viewModel in
                                self.viewModel.onRemove(viewModel: viewModel)
                            })
                            viewModel.viewModels.append(itemViewModel)
                            itemViewModel.focused = true
                        }
                }
            }
            Rectangle()
                .foregroundColor(background)
                .frame(height: minHeight)
                .onTapGesture {
                    guard let last = viewModel.viewModels.last, !last.text.isEmpty else {
                        viewModel.viewModels.last?.focused = true
                        return
                    }
                    let itemViewModel: HSBMultilineTextFieldItemViewModel = .init(font: regularFontSize, onRemove: { viewModel in
                        self.viewModel.onRemove(viewModel: viewModel)
                    })
                    viewModel.viewModels.append(itemViewModel)
                    itemViewModel.focused = true
                }
        }
        .background(background)
        .onReceive(viewModel.$focused) { focused in
            bold = focused?.bold
            fontSize = focused?.fontSize
        }
        .environmentObject(viewModel)
        .toolbar(id: "editingTools") {
            ToolbarItem(id: "bold", placement: .keyboard) {
                Button {
                    viewModel.focused?.bold.toggle()
                    bold = viewModel.focused?.bold
                } label: {
                    Image(systemName: "bold")
                        .padding(padding)
                        .background(bold == true ? backgroundColor.cornerRadius(4) : nil)
                }
            }
            ToolbarItem(id: "regular", placement: .keyboard) {
                Button {
                    viewModel.focused?.fontSize = regularFontSize
                    fontSize = viewModel.focused?.fontSize
                } label: {
                    Image(systemName: "textformat.size.smaller")
                        .padding(padding)
                        .background(fontSize == regularFontSize ? backgroundColor.cornerRadius(4) : nil)
                }
            }

            ToolbarItem(id: "medium", placement: .keyboard) {
                Button {
                    viewModel.focused?.fontSize = mediumFontSize
                    fontSize = viewModel.focused?.fontSize
                } label: {
                    Image(systemName: "textformat.size.larger")
                        .padding(padding)
                        .background(fontSize == mediumFontSize ? backgroundColor.cornerRadius(4) : nil)
                }
            }
            ToolbarItem(id: "space", placement: .keyboard) {
                Spacer()
            }
        }
        .onAppear {
            UITextView.appearance().backgroundColor = .clear
        }
        .onDisappear {
            UITextView.appearance().backgroundColor = nil
        }
    }
    
    public struct ItemView: View {
        
        @EnvironmentObject var parentViewModel: HSBMultilineTextFieldViewModel
        @ObservedObject public var viewModel: HSBMultilineTextFieldItemViewModel
        @FocusState private var focused: Bool
        
        public var body: some View {
            ZStack(alignment: .topLeading) {
                Text(viewModel.placeholder)
                    .foregroundColor(Color(uiColor: .placeholderText))
                    .font(viewModel.displayFont)
                    .opacity(viewModel.text.isEmpty ? 1 : 0)
                TextEditor(text: $viewModel.text)
                    .frame(height: viewModel.height)
                    .font(viewModel.displayFont)
                    .focused($focused)
                    .modify { content in
                        if #available(iOS 16.0, *) {
                            content
                                .introspect(.textEditor, on: .iOS(.v16)) { view in
                                    view.delegate = viewModel
                                    view.isScrollEnabled = false
                                    view.textContainer.lineFragmentPadding = 0
                                    view.textContainerInset = .zero
                                    view.contentInset = .zero
                                    viewModel.textView = view
                                }
                                .scrollContentBackground(.hidden)
                        } else {
                            content
                                .introspect(.textEditor, on: .iOS(.v15)) { view in
                                    view.delegate = viewModel
                                    view.isScrollEnabled = false
                                    view.textContainer.lineFragmentPadding = 0
                                    view.textContainerInset = .zero
                                    view.contentInset = .zero
                                    viewModel.textView = view
                                }
                        }
                    }
            }
            .onChange(of: focused) { focused in
                viewModel.focused = focused
                if focused {
                    parentViewModel.focused = viewModel
                }
            }
            .onReceive(viewModel.$focused) { value in
                if value && value != focused {
                    focused = true
                }
            }
        }
    }
}

extension View {
    /// Modifies the view based on a predicate.
    @ViewBuilder
    public func modify<T: View>(
        @ViewBuilder transform: (Self) -> T
    ) -> some View {
        transform(self)
    }
}
