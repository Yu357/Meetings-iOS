//
//  ThreadRow.swift
//  Meetings
//
//  Created by Yu on 2022/07/21.
//

import SwiftUI

struct ThreadRow: View {
    
    // Thread to show
    let thread: Thread
    
    // States
    @State private var firstComment: Comment? = nil
    @State private var isLoadedFirstComment = false
    
    @State private var numberOfComment: Int? = nil
    @State private var isLoadedNumberOfComment = false
    
    @State private var isThreadDeleted = false
    
    // Dialogs, Navigations
    @State private var isShowDialog = false
    @State private var isShowCreateReportView = false
    
    var body: some View {
        
        Group {
            if !isThreadDeleted {
                HStack(alignment: .top) {
                    
                    // User Icon Column
                    UserIconButton(userId: thread.userId, iconSizeFamily: .medium)
                    
                    // Contents Column
                    VStack(alignment: .leading, spacing: 1) {
                        
                        // Header Row
                        HStack(alignment: .top) {
                            
                            // Title Column
                            Text(thread.title)
                                .fontWeight(.bold)
                                .multilineTextAlignment(.leading)
                            
                            Spacer()
                            
                            // Menu Column
                            Menu {
                                ThreadMenuButtonsGroup(thread: thread, isShowDialog: $isShowDialog, isShowCreateReportView: $isShowCreateReportView)
                            } label: {
                                Image(systemName: "ellipsis")
                                    .foregroundColor(.secondary)
                                    .padding(.vertical, 6)
                            }
                        }
                        
                        // First Comment Row
                        Group {
                            // Progress
                            if !isLoadedFirstComment {
                                Color.secondary
                                    .opacity(0.2)
                                    .frame(width: 120, height: 16)
                            }
                            
                            // No Content
                            if isLoadedFirstComment && firstComment == nil {
                                HStack {
                                    Image(systemName: "exclamationmark.triangle")
                                    Text("first_comment_reading_failed")
                                }
                                .foregroundColor(.secondary)
                            }
                            
                            // Done
                            if firstComment != nil {
                                Text(firstComment!.text)
                                    .foregroundColor(.secondary)
                                    .lineLimit(1)
                            }
                        }
                        
                        // Tags Row
                        HStack {
                            UserUserTagText(userId: thread.userId)
                            EditDate.howManyAgoText(from: thread.createdAt)
                                .foregroundColor(.secondary)
                            
                            ForEach(thread.tags, id: \.self) { tag in
                                Text(tag)
                            }
                        }
                        
                        // Number Of Comment Row
                        Group {
                            // Progress
                            if !isLoadedNumberOfComment {
                                Color.secondary
                                    .opacity(0.2)
                                    .frame(width: 20, height: 16)
                            }
                            
                            // Failed
                            if isLoadedNumberOfComment && numberOfComment == nil {
                                Image(systemName: "exclamationmark.triangle")
                            }
                            
                            // Done
                            if isLoadedNumberOfComment && numberOfComment != nil {
                                HStack {
                                    Image(systemName: "bubble.left")
                                        .font(.subheadline)
                                    Text("\(numberOfComment!)")
                                }
                                .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                .background(NavigationLink("", destination: ThreadView(threadId: thread.id, threadTitle: thread.title)).opacity(0))
            }
        }
        
        .contextMenu {
            ThreadMenuButtonsGroup(thread: thread, isShowDialog: $isShowDialog, isShowCreateReportView: $isShowCreateReportView)
        }
        
        .confirmationDialog("", isPresented: $isShowDialog, titleVisibility: .hidden) {
            Button("delete_thread", role: .destructive) {
                FireThread.deleteThread(threadId: thread.id) { _ in
                    isThreadDeleted = true
                }
            }
        } message: {
            Text("are_you_sure_you_want_to_delete_this_thread")
        }
        
        .sheet(isPresented: $isShowCreateReportView) {
            CreateReportView(targetId: thread.id, targetFamily: .thread)
        }
        
        .onAppear(perform: load)
    }
    
    private func load() {
        if !isLoadedFirstComment {
            loadFirstComment()
        }
        
        if !isLoadedNumberOfComment {
            loadNumberOfComment()
        }
    }
    
    private func loadFirstComment() {
        var timerCounter = 0
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            timerCounter += 1
            
            // 最初のコメントを読み取る
            if firstComment == nil {
                FireComment.readFirstComment(threadId: thread.id) { comment in
                    self.firstComment = comment
                }
            }
                        
            // 読み取り完了orタイムアウトでタイマー停止
            if firstComment != nil || timerCounter == 10 {
                timer.invalidate()
                self.isLoadedFirstComment = true
            }
        }
    }
    
    private func loadNumberOfComment() {
        var timerCounter = 0
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            timerCounter += 1
            
            // コメント数を読み取る
            if numberOfComment == nil {
                FireComment.readNumberOfCommentInThread(threadId: thread.id) { number in
                    self.numberOfComment = number
                }
            }
                        
            // 読み取り完了orタイムアウトでタイマー停止
            if numberOfComment != nil || timerCounter == 10 {
                timer.invalidate()
                self.isLoadedNumberOfComment = true
            }
        }
    }
}
