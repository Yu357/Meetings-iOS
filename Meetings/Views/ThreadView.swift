//
//  ThreadView.swift
//  Meetings
//
//  Created by Yu on 2022/07/21.
//

import SwiftUI

struct ThreadView: View {
    
    // Thread to show
    private let threadId: String
    private let threadTitle: String
    
    // States
    @ObservedObject private var commentsViewModel: CommentsViewModel
    @ObservedObject private var signInStateViewModel = SignInStateViewModel()
    
    // Navigations
    @State private var isShowCreateCommentView = false
    
    init(threadId: String, threadTitle: String) {
        self.threadId = threadId
        self.threadTitle = threadTitle
        self.commentsViewModel = CommentsViewModel(threadId: threadId)
    }

    var body: some View {
        
        ZStack {
            // List Layer
            List {
                // Progress view
                if !commentsViewModel.isLoaded {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .listRowSeparator(.hidden)
                }
                
                // No content text
                if commentsViewModel.isLoaded && commentsViewModel.comments.count == 0 {
                    Text("no_comments")
                        .frame(maxWidth: .infinity, alignment: .center)
                        .foregroundColor(.secondary)
                        .listRowSeparator(.hidden)
                }
                
                // CommentRows
                ForEach(commentsViewModel.comments) { comment in
                    CommentRow(comment: comment, isAbleShowingProfileView: true, isShowThread: false)
                }
                .listRowSeparator(.hidden, edges: .top)
                .listRowSeparator(.visible, edges: .bottom)
            }
            .listStyle(.plain)
            
            // FAB Layer
            if signInStateViewModel.isSignedIn {
                FloatingActionButton(systemImage: "plus", action: {
                    isShowCreateCommentView.toggle()
                })
            }
        }
        
        .sheet(isPresented: $isShowCreateCommentView) {
            CreateCommentView(threadId: threadId)
        }
        
        .navigationTitle(threadTitle)
        .navigationBarTitleDisplayMode(.inline)
    }
}
