//
//  CreateThreadView.swift
//  Meetings
//
//  Created by Yu on 2022/07/21.
//

import SwiftUI
import Introspect

struct CreateThreadView: View {
    
    // Environments
    @Environment(\.dismiss) private var dismiss
    
    // States
    @State private var threadTitle = ""
    @State private var threadTags: [String] = []
    @State private var commentText = ""
    @State private var commentImages: [UIImage] = []
    
    @State private var isLoading = false
    @State private var isShowDialogError = false
    
    @State private var isShowImagesPickerView = false
    @State private var isPickingImages = false
    
    // Values
    private let threadTitleMax = 100
    private let threadTagMax = 30
    private let threadTagsMax = 5
    private let commentTextMax = 300
    
    var body: some View {
        NavigationView {
            
            List {
                // TextField Row
                TextField("title", text: $threadTitle)
                    .introspectTextField { textField in
                        textField.becomeFirstResponder()
                    }
                    .disabled(isLoading)
                    .submitLabel(.done)
                    .listRowSeparator(.hidden)
                
                // Tags Row
                ForEach(0 ..< threadTags.count, id: \.self) { index in
                    HStack {
                        // Image Column
                        Image(systemName: "tag")
                            .foregroundColor(.secondary)
                        
                        // TextField Column
                        TextField("tag", text: $threadTags[index])
                            .submitLabel(.done)
                        
                        Spacer()
                        
                        // Delete Button Column
                        Button(action: {
                            threadTags.remove(at: index)
                        }) {
                            Image(systemName: "xmark")
                                .foregroundColor(.secondary)
                        }
                        .buttonStyle(.plain)
                    }
                    .listRowSeparator(.hidden)
                }
                
                // Add Tag Button Row
                Button(action: {
                    withAnimation {
                        threadTags.append("")
                    }
                }) {
                    HStack {
                        Image(systemName: "plus")
                        Text("add_tag")
                    }
                }
                .foregroundColor(.secondary)
                .buttonStyle(.plain)
                .disabled(threadTags.count >= threadTagsMax)
                .listRowSeparator(.hidden)
                
                // Comment Text Row
                GuidedTextEditor(hintText: Text("comment"), text: $commentText, isFocus: false)
                    .listRowSeparator(.hidden)
                
                // Comment Image Button Row
                Button(action: {
                    isShowImagesPickerView.toggle()
                }) {
                    Image(systemName: "plus")
                    Text("add_images")
                }
                .foregroundColor(.secondary)
                .buttonStyle(.plain)
                .listRowSeparator(.hidden)
                
                // Comment Images Row
                ScrollView(.horizontal) {
                    HStack(alignment: .top) {
                        ForEach(0 ..< commentImages.count, id: \.self) { index in
                            Image(uiImage: commentImages[index])
                                .resizable()
                                .scaledToFit()
                                .cornerRadius(8)
                                .frame(height: 120)
                        }
                    }
                }
                .listRowSeparator(.hidden)
            }
            .listStyle(.plain)
            
            .alert("failed", isPresented: $isShowDialogError) {
                Button("ok") {
                    isShowDialogError = false
                }
            } message: {
                Text("thread_creation_failed")
            }
            
            .sheet(isPresented: $isShowImagesPickerView) {
                ImagesPickerView(images: $commentImages, isPicking: $isPickingImages)
            }
            
            .navigationTitle("new_thread")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    // Create Button
                    if !isLoading {
                        Button(action: {
                            isLoading = true
                            
                            // スレッドを作成
                            FireThread.createThread(title: threadTitle, tags: threadTags) { threadId in
                                // 失敗
                                if threadId == nil {
                                    isLoading = false
                                    isShowDialogError = true
                                    return
                                }
                                
                                // 成功
                                // コメントの画像をアップロード
                                FireImage.uploadImages(images: commentImages, folderName: "images") { imageUrls in
                                    // 失敗
                                    if imageUrls == nil {
                                        isLoading = false
                                        isShowDialogError = true
                                        return
                                    }
                                    
                                    // 成功
                                    // コメントを作成
                                    FireComment.createComment(threadId: threadId!, text: commentText, imageUrls: imageUrls!) { commentId in
                                        // 失敗
                                        if commentId == nil {
                                            isLoading = false
                                            isShowDialogError = true
                                            return
                                        }
                                        
                                        // 成功
                                        dismiss()
                                    }
                                }
                            }
                        }) {
                            Text("create")
                                .fontWeight(.bold)
                        }
                        .disabled(threadTitle.isEmpty || threadTitle.count > threadTitleMax || threadTags.contains(where: {$0.count > threadTagMax}) || threadTags.contains(where: {$0.trimmingCharacters(in: .whitespaces).isEmpty}) || commentText.isEmpty || commentText.count > commentTextMax)
                    }
                    
                    // ProgressView
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(.circular)
                    }
                }
            }
        }
        .navigationViewStyle(.stack)
    }
}
