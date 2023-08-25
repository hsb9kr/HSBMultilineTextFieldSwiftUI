//
//  MultilineTextField.swift
//  MultilineTextField
//
//  Created by Red on 2023/08/22.
//

import SwiftUI
import Combine
import SwiftUIIntrospect

public struct HSBMultilineTextField<Content>: View where Content: CustomizableToolbarContent {
    
    private let minHeight: CGFloat
    private let background: Color
	private let toolBarContent: (HSBMultilineTextFieldViewModel) -> Content
    @StateObject private var viewModel: HSBMultilineTextFieldViewModel
    
    public init(
		placeholder: String = "",
		data: [HSBMultilineTextData]? = nil,
		fontSizeList: [CGFloat] = [15, 18],
		minHeight: CGFloat = 10,
		background: Color,
		focused: Bool = true,
		onChanged: @escaping ([HSBMultilineTextData]) -> Void,
		@ToolbarContentBuilder toolBar content: @escaping (HSBMultilineTextFieldViewModel) -> Content
	) {
        self.minHeight = minHeight
        self.background = background
		self.toolBarContent = content
        let viewModel: HSBMultilineTextFieldViewModel = .init(
			placeholder: placeholder,
			data: data,
			fontSizeList: fontSizeList,
			focused: focused,
			onChanged: onChanged
		)
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
							addNewLine()
                        }
                }
            }
            Rectangle()
                .foregroundColor(background)
                .frame(height: minHeight)
                .onTapGesture {
                    addNewLine()
                }
        }
        .background(background)
        .onReceive(viewModel.$focused) { focused in
			viewModel.bold = focused?.bold
			viewModel.fontSize = focused?.fontSize
        }
        .environmentObject(viewModel)
        .toolbar(id: "editingTools") {
            toolBarContent(viewModel)
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
									view.backgroundColor = .clear
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
	
	fileprivate func addNewLine() {
		guard let last = viewModel.viewModels.last, !last.text.isEmpty else {
			viewModel.viewModels.last?.focused = true
			return
		}
		let itemViewModel: HSBMultilineTextFieldItemViewModel = .init(font: viewModel.fontSizeList.first!, onRemove: { viewModel in
			self.viewModel.onRemove(viewModel: viewModel)
		})
		viewModel.viewModels.append(itemViewModel)
		itemViewModel.focused = true
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
