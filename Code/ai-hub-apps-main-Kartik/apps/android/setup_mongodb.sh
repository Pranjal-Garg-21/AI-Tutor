#!/bin/bash

# MongoDB Integration Setup Script for ChatApp
# This script creates all necessary files for MongoDB Realm integration

echo "=========================================="
echo "MongoDB Realm Integration Setup"
echo "=========================================="
echo ""

# Get the script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CHATAPP_DIR="$SCRIPT_DIR/ChatApp"
SRC_DIR="$CHATAPP_DIR/src/main/java/com/quicinc/chatapp"
DB_DIR="$SRC_DIR/database"
MODELS_DIR="$DB_DIR/models"

# Create directories
echo "Creating directory structure..."
mkdir -p "$MODELS_DIR"

# Create UserModel.java
echo "Creating UserModel.java..."
cat > "$MODELS_DIR/UserModel.java" << 'EOF'
package com.quicinc.chatapp.database.models;

import io.realm.RealmList;
import io.realm.RealmObject;
import io.realm.annotations.PrimaryKey;
import io.realm.annotations.Required;
import java.util.Date;

public class UserModel extends RealmObject {
    @PrimaryKey
    private String userId;
    
    @Required
    private String email;
    
    @Required
    private String password;
    
    private String username;
    private Date registrationDate;
    private Date lastLoginDate;
    
    private RealmList<ChatSessionModel> chatSessions;
    private RealmList<QuizResultModel> quizResults;
    private RealmList<FlashcardSetModel> flashcardSets;
    private RealmList<GemModel> gems;
    
    // Getters and setters
    public String getUserId() { return userId; }
    public void setUserId(String userId) { this.userId = userId; }
    
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    
    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }
    
    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }
    
    public Date getRegistrationDate() { return registrationDate; }
    public void setRegistrationDate(Date registrationDate) { this.registrationDate = registrationDate; }
    
    public Date getLastLoginDate() { return lastLoginDate; }
    public void setLastLoginDate(Date lastLoginDate) { this.lastLoginDate = lastLoginDate; }
    
    public RealmList<ChatSessionModel> getChatSessions() { return chatSessions; }
    public void setChatSessions(RealmList<ChatSessionModel> chatSessions) { this.chatSessions = chatSessions; }
    
    public RealmList<QuizResultModel> getQuizResults() { return quizResults; }
    public void setQuizResults(RealmList<QuizResultModel> quizResults) { this.quizResults = quizResults; }
    
    public RealmList<FlashcardSetModel> getFlashcardSets() { return flashcardSets; }
    public void setFlashcardSets(RealmList<FlashcardSetModel> flashcardSets) { this.flashcardSets = flashcardSets; }
    
    public RealmList<GemModel> getGems() { return gems; }
    public void setGems(RealmList<GemModel> gems) { this.gems = gems; }
}
EOF

# Create ChatSessionModel.java
echo "Creating ChatSessionModel.java..."
cat > "$MODELS_DIR/ChatSessionModel.java" << 'EOF'
package com.quicinc.chatapp.database.models;

import io.realm.RealmList;
import io.realm.RealmObject;
import io.realm.annotations.PrimaryKey;
import io.realm.annotations.Required;
import java.util.Date;

public class ChatSessionModel extends RealmObject {
    @PrimaryKey
    private String sessionId;
    
    @Required
    private String userId;
    
    private String sessionTitle;
    private Date createdDate;
    private Date lastModifiedDate;
    
    private RealmList<ChatMessageModel> messages;
    
    // Getters and setters
    public String getSessionId() { return sessionId; }
    public void setSessionId(String sessionId) { this.sessionId = sessionId; }
    
    public String getUserId() { return userId; }
    public void setUserId(String userId) { this.userId = userId; }
    
    public String getSessionTitle() { return sessionTitle; }
    public void setSessionTitle(String sessionTitle) { this.sessionTitle = sessionTitle; }
    
    public Date getCreatedDate() { return createdDate; }
    public void setCreatedDate(Date createdDate) { this.createdDate = createdDate; }
    
    public Date getLastModifiedDate() { return lastModifiedDate; }
    public void setLastModifiedDate(Date lastModifiedDate) { this.lastModifiedDate = lastModifiedDate; }
    
    public RealmList<ChatMessageModel> getMessages() { return messages; }
    public void setMessages(RealmList<ChatMessageModel> messages) { this.messages = messages; }
}
EOF

# Create ChatMessageModel.java
echo "Creating ChatMessageModel.java..."
cat > "$MODELS_DIR/ChatMessageModel.java" << 'EOF'
package com.quicinc.chatapp.database.models;

import io.realm.RealmObject;
import io.realm.annotations.PrimaryKey;
import io.realm.annotations.Required;
import java.util.Date;

public class ChatMessageModel extends RealmObject {
    @PrimaryKey
    private String messageId;
    
    @Required
    private String sessionId;
    
    @Required
    private String content;
    
    private boolean isUser;
    private Date timestamp;
    
    // Getters and setters
    public String getMessageId() { return messageId; }
    public void setMessageId(String messageId) { this.messageId = messageId; }
    
    public String getSessionId() { return sessionId; }
    public void setSessionId(String sessionId) { this.sessionId = sessionId; }
    
    public String getContent() { return content; }
    public void setContent(String content) { this.content = content; }
    
    public boolean isUser() { return isUser; }
    public void setUser(boolean user) { isUser = user; }
    
    public Date getTimestamp() { return timestamp; }
    public void setTimestamp(Date timestamp) { this.timestamp = timestamp; }
}
EOF

echo ""
echo "=========================================="
echo "Setup Complete!"
echo "=========================================="
echo ""
echo "Next steps:"
echo "1. Read MONGODB_INTEGRATION_GUIDE.md for complete instructions"
echo "2. Update your build.gradle files with MongoDB dependencies"
echo "3. Create the remaining model classes (Quiz, Flashcard, Gem)"
echo "4. Create the DatabaseManager.java class"
echo "5. Create ChatApplication.java and update AndroidManifest.xml"
echo ""
echo "All files created in: $MODELS_DIR"
echo ""
