//
//  CommentReactionRow.swift
//  Meetings
//
//  Created by Yu on 2022/07/29.
//

import SwiftUI

struct CommentReactionRow: View {
    
    // Comment to show
    let comment: Comment
    
    // States
    @State private var likedUserIds: [String]? = nil
    @State private var isLoadedLikedUserIds = false
    
    var body: some View {
        HStack {
            // Progress view
            if !isLoadedLikedUserIds {
                Color.secondary
                    .opacity(0.2)
                    .frame(width: 40)
            }
            
            // Reading failed view
            if isLoadedLikedUserIds && likedUserIds == nil {
                Image(systemName: "exclamationmark.triangle")
                    .foregroundColor(.secondary)
            }
            
            // Like button when not liked
            if isLoadedLikedUserIds && likedUserIds != nil && !likedUserIds!.contains(FireAuth.uid() ?? "") {
                Button(action: {
                    loadLikedUserIds()
                    FireUser.likeComment(commentId: comment.id) { userId in
                        if userId != nil {
                            loadLikedUserIds()
                        }
                    }
                }) {
                    HStack(spacing: 2) {
                        Image(systemName: "heart")
                        Text("\(likedUserIds!.count)")
                    }
                    .foregroundColor(.secondary)
                }
                .buttonStyle(.borderless)
                .disabled(!FireAuth.isSignedIn() || comment.userId == FireAuth.uid())
            }
            
            // Like button when liked
            if isLoadedLikedUserIds && likedUserIds != nil && likedUserIds!.contains(FireAuth.uid() ?? "") {
                Button(action: {
                    loadLikedUserIds()
                    FireUser.unlikeComment(commentId: comment.id) { userId in
                        if userId != nil {
                            loadLikedUserIds()
                        }
                    }
                }) {
                    HStack(spacing: 2) {
                        Image(systemName: "heart.fill")
                        Text("\(likedUserIds!.count)")
                    }
                    .foregroundColor(.red)
                }
                .buttonStyle(.borderless)
                .disabled(!FireAuth.isSignedIn() || comment.userId == FireAuth.uid())
            }
        }
        .frame(height: 16)
        .onAppear(perform: load)
    }
    
    private func load() {
        if !isLoadedLikedUserIds {
            loadLikedUserIds()
        }
    }
    
    private func loadLikedUserIds() {
        FireUser.readLikedUserIds(commentId: comment.id) { userIds in
            withAnimation {
                self.likedUserIds = userIds
                self.isLoadedLikedUserIds = true
            }
        }
    }
}
