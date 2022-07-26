//
//  CommentMenu.swift
//  Meetings
//
//  Created by Yu on 2022/07/29.
//

import SwiftUI

struct CommentMenu: View {
    
    // Comment to show
    let comment: Comment
    @Binding var isCommentDeleted: Bool
    
    // Navigations
    @State private var isShowDialogDelete = false
    @State private var isShowCreateReportView = false
    
    var body: some View {
        Menu {
            CommentMenuButtonsGroup(comment: comment, isShowDialogDelete: $isShowDialogDelete, isShowCreateReportView: $isShowCreateReportView)
        } label: {
            Image(systemName: "ellipsis")
                .foregroundColor(.secondary)
                .padding(.vertical, 6)
        }
        
        .confirmationDialog("", isPresented: $isShowDialogDelete, titleVisibility: .hidden) {
            Button("delete_comment", role: .destructive) {
                FireComment.deleteComment(commentId: comment.id) { commentId in
                    // 成功
                    withAnimation {
                        isCommentDeleted = true
                    }
                }
            }
        } message: {
            Text("are_you_sure_you_want_to_delete_this_comment")
        }
        
        .sheet(isPresented: $isShowCreateReportView) {
            CreateReportView(targetId: comment.id, targetFamily: .comment)
        }
    }
}
