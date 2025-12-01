# MongoDB Integration Guide for ChatApp

This guide provides comprehensive steps to integrate MongoDB Realm into your Android ChatApp to persist user data, chat history, quizzes, flashcards, and gems.

## Table of Contents
1. [Setup MongoDB Realm](#setup-mongodb-realm)
2. [Add Dependencies](#add-dependencies)
3. [Data Models](#data-models)
4. [Database Manager](#database-manager)
5. [Integration Steps](#integration-steps)
6. [Usage Examples](#usage-examples)

## Setup MongoDB Realm

### Option 1: MongoDB Realm Cloud (Recommended for Production)
1. Go to [MongoDB Atlas](https://www.mongodb.com/cloud/atlas)
2. Create a free account and cluster
3. Create a Realm app
4. Note your App ID

### Option 2: Local MongoDB Realm (For Development)
Use the local Realm database without cloud sync (files provided work with this approach)

## Add Dependencies

### Step 1: Update Project-level `build.gradle`

Add the Realm classpath to your project-level `build.gradle`:

```gradle
buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath 'com.android.tools.build:gradle:8.1.0'
        classpath 'io.realm:realm-gradle-plugin:10.18.0'  // Add this line
    }
}
```

### Step 2: Update App-level `build.gradle`

In `ChatApp/build.gradle`, apply the Realm plugin and add dependencies:

```gradle
plugins {
    id 'com.android.application'
    id 'realm-android'  // Add this line
}

android {
    compileSdk 34
    
    defaultConfig {
        applicationId "com.quicinc.chatapp"
        minSdk 29
        targetSdk 34
        versionCode 1
        versionName "1.0"
    }
    
    compileOptions {
        sourceCompatibility JavaVersion.VERSION_1_8
        targetCompatibility JavaVersion.VERSION_1_8
    }
}

dependencies {
    implementation 'androidx.appcompat:appcompat:1.6.1'
    implementation 'com.google.android.material:material:1.11.0'
    implementation 'androidx.constraintlayout:constraintlayout:2.1.4'
    implementation 'androidx.recyclerview:recyclerview:1.3.2'
    implementation 'androidx.drawerlayout:drawerlayout:1.2.0'
    
    // MongoDB Realm
    implementation 'io.realm:realm-android-library:10.18.0'
    implementation 'io.realm:realm-android-kotlin-extensions:10.18.0'
    
    // For PDF generation
    implementation 'com.itextpdf:itext7-core:7.2.5'
    
    // Optional: For easier date handling
    implementation 'joda-time:joda-time:2.12.5'
}
```

## Data Models

Create the following Realm model classes in `src/main/java/com/quicinc/chatapp/database/models/`:

### 1. User Model (`UserModel.java`)
```java
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
    private String password; // Store hashed password in production
    
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
```

### 2. Chat Session Model (`ChatSessionModel.java`)
```java
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
```

### 3. Chat Message Model (`ChatMessageModel.java`)
```java
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
    
    private boolean isUser; // true for user, false for bot
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
```

### 4. Quiz Result Model (`QuizResultModel.java`)
```java
package com.quicinc.chatapp.database.models;

import io.realm.RealmList;
import io.realm.RealmObject;
import io.realm.annotations.PrimaryKey;
import io.realm.annotations.Required;
import java.util.Date;

public class QuizResultModel extends RealmObject {
    @PrimaryKey
    private String quizId;
    
    @Required
    private String userId;
    
    private String topic;
    private int totalQuestions;
    private int correctAnswers;
    private double score;
    private Date completedDate;
    
    private RealmList<QuestionResultModel> questionResults;
    
    // Getters and setters
    public String getQuizId() { return quizId; }
    public void setQuizId(String quizId) { this.quizId = quizId; }
    
    public String getUserId() { return userId; }
    public void setUserId(String userId) { this.userId = userId; }
    
    public String getTopic() { return topic; }
    public void setTopic(String topic) { this.topic = topic; }
    
    public int getTotalQuestions() { return totalQuestions; }
    public void setTotalQuestions(int totalQuestions) { this.totalQuestions = totalQuestions; }
    
    public int getCorrectAnswers() { return correctAnswers; }
    public void setCorrectAnswers(int correctAnswers) { this.correctAnswers = correctAnswers; }
    
    public double getScore() { return score; }
    public void setScore(double score) { this.score = score; }
    
    public Date getCompletedDate() { return completedDate; }
    public void setCompletedDate(Date completedDate) { this.completedDate = completedDate; }
    
    public RealmList<QuestionResultModel> getQuestionResults() { return questionResults; }
    public void setQuestionResults(RealmList<QuestionResultModel> questionResults) { 
        this.questionResults = questionResults; 
    }
}
```

### 5. Question Result Model (`QuestionResultModel.java`)
```java
package com.quicinc.chatapp.database.models;

import io.realm.RealmObject;

public class QuestionResultModel extends RealmObject {
    private String question;
    private String userAnswer;
    private String correctAnswer;
    private boolean isCorrect;
    
    // Getters and setters
    public String getQuestion() { return question; }
    public void setQuestion(String question) { this.question = question; }
    
    public String getUserAnswer() { return userAnswer; }
    public void setUserAnswer(String userAnswer) { this.userAnswer = userAnswer; }
    
    public String getCorrectAnswer() { return correctAnswer; }
    public void setCorrectAnswer(String correctAnswer) { this.correctAnswer = correctAnswer; }
    
    public boolean isCorrect() { return isCorrect; }
    public void setCorrect(boolean correct) { isCorrect = correct; }
}
```

### 6. Flashcard Set Model (`FlashcardSetModel.java`)
```java
package com.quicinc.chatapp.database.models;

import io.realm.RealmList;
import io.realm.RealmObject;
import io.realm.annotations.PrimaryKey;
import io.realm.annotations.Required;
import java.util.Date;

public class FlashcardSetModel extends RealmObject {
    @PrimaryKey
    private String setId;
    
    @Required
    private String userId;
    
    private String title;
    private Date createdDate;
    
    private RealmList<FlashcardModel> flashcards;
    
    // Getters and setters
    public String getSetId() { return setId; }
    public void setSetId(String setId) { this.setId = setId; }
    
    public String getUserId() { return userId; }
    public void setUserId(String userId) { this.userId = userId; }
    
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    
    public Date getCreatedDate() { return createdDate; }
    public void setCreatedDate(Date createdDate) { this.createdDate = createdDate; }
    
    public RealmList<FlashcardModel> getFlashcards() { return flashcards; }
    public void setFlashcards(RealmList<FlashcardModel> flashcards) { this.flashcards = flashcards; }
}
```

### 7. Flashcard Model (`FlashcardModel.java`)
```java
package com.quicinc.chatapp.database.models;

import io.realm.RealmObject;

public class FlashcardModel extends RealmObject {
    private String front;
    private String back;
    
    // Getters and setters
    public String getFront() { return front; }
    public void setFront(String front) { this.front = front; }
    
    public String getBack() { return back; }
    public void setBack(String back) { this.back = back; }
}
```

### 8. Gem Model (`GemModel.java`)
```java
package com.quicinc.chatapp.database.models;

import io.realm.RealmObject;
import io.realm.annotations.PrimaryKey;
import io.realm.annotations.Required;
import java.util.Date;

public class GemModel extends RealmObject {
    @PrimaryKey
    private String gemId;
    
    @Required
    private String userId;
    
    private String title;
    private String content;
    private Date createdDate;
    
    // Getters and setters
    public String getGemId() { return gemId; }
    public void setGemId(String gemId) { this.gemId = gemId; }
    
    public String getUserId() { return userId; }
    public void setUserId(String userId) { this.userId = userId; }
    
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    
    public String getContent() { return content; }
    public void setContent(String content) { this.content = content; }
    
    public Date getCreatedDate() { return createdDate; }
    public void setCreatedDate(Date createdDate) { this.createdDate = createdDate; }
}
```

## Database Manager

Create `DatabaseManager.java` in `src/main/java/com/quicinc/chatapp/database/`:

```java
package com.quicinc.chatapp.database;

import android.content.Context;
import com.quicinc.chatapp.database.models.*;
import io.realm.Realm;
import io.realm.RealmConfiguration;
import io.realm.RealmList;
import io.realm.RealmResults;
import java.util.Date;
import java.util.UUID;

public class DatabaseManager {
    private static DatabaseManager instance;
    private Realm realm;
    
    private DatabaseManager() {
        // Private constructor for singleton
    }
    
    public static synchronized DatabaseManager getInstance() {
        if (instance == null) {
            instance = new DatabaseManager();
        }
        return instance;
    }
    
    public void initialize(Context context) {
        Realm.init(context);
        
        RealmConfiguration config = new RealmConfiguration.Builder()
                .name("chatapp.realm")
                .schemaVersion(1)
                .deleteRealmIfMigrationNeeded() // Remove in production
                .build();
        
        Realm.setDefaultConfiguration(config);
        realm = Realm.getDefaultInstance();
    }
    
    public Realm getRealm() {
        if (realm == null || realm.isClosed()) {
            realm = Realm.getDefaultInstance();
        }
        return realm;
    }
    
    public void closeRealm() {
        if (realm != null && !realm.isClosed()) {
            realm.close();
        }
    }
    
    // ==================== USER OPERATIONS ====================
    
    public UserModel registerUser(String email, String password, String username) {
        Realm realm = getRealm();
        String userId = UUID.randomUUID().toString();
        
        realm.beginTransaction();
        UserModel user = realm.createObject(UserModel.class, userId);
        user.setEmail(email);
        user.setPassword(password); // Hash this in production!
        user.setUsername(username);
        user.setRegistrationDate(new Date());
        user.setLastLoginDate(new Date());
        user.setChatSessions(new RealmList<>());
        user.setQuizResults(new RealmList<>());
        user.setFlashcardSets(new RealmList<>());
        user.setGems(new RealmList<>());
        realm.commitTransaction();
        
        return user;
    }
    
    public UserModel loginUser(String email, String password) {
        Realm realm = getRealm();
        UserModel user = realm.where(UserModel.class)
                .equalTo("email", email)
                .equalTo("password", password)
                .findFirst();
        
        if (user != null) {
            realm.beginTransaction();
            user.setLastLoginDate(new Date());
            realm.commitTransaction();
        }
        
        return user;
    }
    
    public UserModel getUserById(String userId) {
        return getRealm().where(UserModel.class)
                .equalTo("userId", userId)
                .findFirst();
    }
    
    public boolean isEmailRegistered(String email) {
        return getRealm().where(UserModel.class)
                .equalTo("email", email)
                .count() > 0;
    }
    
    // ==================== CHAT OPERATIONS ====================
    
    public ChatSessionModel createChatSession(String userId, String title) {
        Realm realm = getRealm();
        String sessionId = UUID.randomUUID().toString();
        
        realm.beginTransaction();
        ChatSessionModel session = realm.createObject(ChatSessionModel.class, sessionId);
        session.setUserId(userId);
        session.setSessionTitle(title);
        session.setCreatedDate(new Date());
        session.setLastModifiedDate(new Date());
        session.setMessages(new RealmList<>());
        realm.commitTransaction();
        
        return session;
    }
    
    public void saveChatMessage(String sessionId, String content, boolean isUser) {
        Realm realm = getRealm();
        String messageId = UUID.randomUUID().toString();
        
        realm.beginTransaction();
        ChatMessageModel message = realm.createObject(ChatMessageModel.class, messageId);
        message.setSessionId(sessionId);
        message.setContent(content);
        message.setUser(isUser);
        message.setTimestamp(new Date());
        
        ChatSessionModel session = realm.where(ChatSessionModel.class)
                .equalTo("sessionId", sessionId)
                .findFirst();
        if (session != null) {
            session.getMessages().add(message);
            session.setLastModifiedDate(new Date());
        }
        realm.commitTransaction();
    }
    
    public RealmResults<ChatSessionModel> getUserChatSessions(String userId) {
        return getRealm().where(ChatSessionModel.class)
                .equalTo("userId", userId)
                .sort("lastModifiedDate")
                .findAll();
    }
    
    public RealmResults<ChatMessageModel> getSessionMessages(String sessionId) {
        return getRealm().where(ChatMessageModel.class)
                .equalTo("sessionId", sessionId)
                .sort("timestamp")
                .findAll();
    }
    
    public void deleteChatSession(String sessionId) {
        Realm realm = getRealm();
        realm.beginTransaction();
        
        // Delete all messages in the session
        RealmResults<ChatMessageModel> messages = realm.where(ChatMessageModel.class)
                .equalTo("sessionId", sessionId)
                .findAll();
        messages.deleteAllFromRealm();
        
        // Delete the session
        ChatSessionModel session = realm.where(ChatSessionModel.class)
                .equalTo("sessionId", sessionId)
                .findFirst();
        if (session != null) {
            session.deleteFromRealm();
        }
        
        realm.commitTransaction();
    }
    
    // ==================== QUIZ OPERATIONS ====================
    
    public QuizResultModel saveQuizResult(String userId, String topic, int totalQuestions, 
                                          int correctAnswers, RealmList<QuestionResultModel> questionResults) {
        Realm realm = getRealm();
        String quizId = UUID.randomUUID().toString();
        double score = (correctAnswers * 100.0) / totalQuestions;
        
        realm.beginTransaction();
        QuizResultModel quiz = realm.createObject(QuizResultModel.class, quizId);
        quiz.setUserId(userId);
        quiz.setTopic(topic);
        quiz.setTotalQuestions(totalQuestions);
        quiz.setCorrectAnswers(correctAnswers);
        quiz.setScore(score);
        quiz.setCompletedDate(new Date());
        quiz.setQuestionResults(questionResults);
        realm.commitTransaction();
        
        return quiz;
    }
    
    public RealmResults<QuizResultModel> getUserQuizResults(String userId) {
        return getRealm().where(QuizResultModel.class)
                .equalTo("userId", userId)
                .sort("completedDate")
                .findAll();
    }
    
    public QuizResultModel getQuizById(String quizId) {
        return getRealm().where(QuizResultModel.class)
                .equalTo("quizId", quizId)
                .findFirst();
    }
    
    // ==================== FLASHCARD OPERATIONS ====================
    
    public FlashcardSetModel createFlashcardSet(String userId, String title, 
                                                 RealmList<FlashcardModel> flashcards) {
        Realm realm = getRealm();
        String setId = UUID.randomUUID().toString();
        
        realm.beginTransaction();
        FlashcardSetModel flashcardSet = realm.createObject(FlashcardSetModel.class, setId);
        flashcardSet.setUserId(userId);
        flashcardSet.setTitle(title);
        flashcardSet.setCreatedDate(new Date());
        flashcardSet.setFlashcards(flashcards);
        realm.commitTransaction();
        
        return flashcardSet;
    }
    
    public RealmResults<FlashcardSetModel> getUserFlashcardSets(String userId) {
        return getRealm().where(FlashcardSetModel.class)
                .equalTo("userId", userId)
                .sort("createdDate")
                .findAll();
    }
    
    public void deleteFlashcardSet(String setId) {
        Realm realm = getRealm();
        realm.beginTransaction();
        
        FlashcardSetModel set = realm.where(FlashcardSetModel.class)
                .equalTo("setId", setId)
                .findFirst();
        if (set != null) {
            set.deleteFromRealm();
        }
        
        realm.commitTransaction();
    }
    
    // ==================== GEM OPERATIONS ====================
    
    public GemModel createGem(String userId, String title, String content) {
        Realm realm = getRealm();
        String gemId = UUID.randomUUID().toString();
        
        realm.beginTransaction();
        GemModel gem = realm.createObject(GemModel.class, gemId);
        gem.setUserId(userId);
        gem.setTitle(title);
        gem.setContent(content);
        gem.setCreatedDate(new Date());
        realm.commitTransaction();
        
        return gem;
    }
    
    public RealmResults<GemModel> getUserGems(String userId) {
        return getRealm().where(GemModel.class)
                .equalTo("userId", userId)
                .sort("createdDate")
                .findAll();
    }
    
    public void deleteGem(String gemId) {
        Realm realm = getRealm();
        realm.beginTransaction();
        
        GemModel gem = realm.where(GemModel.class)
                .equalTo("gemId", gemId)
                .findFirst();
        if (gem != null) {
            gem.deleteFromRealm();
        }
        
        realm.commitTransaction();
    }
}
```

## Integration Steps

### Step 1: Initialize MongoDB in Application Class

Create `ChatApplication.java` in the same package as your activities:

```java
package com.quicinc.chatapp;

import android.app.Application;
import com.quicinc.chatapp.database.DatabaseManager;

public class ChatApplication extends Application {
    @Override
    public void onCreate() {
        super.onCreate();
        
        // Initialize MongoDB Realm
        DatabaseManager.getInstance().initialize(this);
    }
}
```

Update `AndroidManifest.xml`:

```xml
<application
    android:name=".ChatApplication"
    android:allowBackup="true"
    ...>
```

### Step 2: Update LoginActivity

```java
public class LoginActivity extends AppCompatActivity {
    private EditText emailInput, passwordInput;
    private Button loginButton;
    private DatabaseManager dbManager;
    
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_login);
        
        dbManager = DatabaseManager.getInstance();
        
        emailInput = findViewById(R.id.email_input);
        passwordInput = findViewById(R.id.password_input);
        loginButton = findViewById(R.id.login_button);
        
        loginButton.setOnClickListener(v -> handleLogin());
    }
    
    private void handleLogin() {
        String email = emailInput.getText().toString().trim();
        String password = passwordInput.getText().toString().trim();
        
        if (email.isEmpty() || password.isEmpty()) {
            Toast.makeText(this, "Please fill all fields", Toast.LENGTH_SHORT).show();
            return;
        }
        
        UserModel user = dbManager.loginUser(email, password);
        
        if (user != null) {
            // Save user session
            SharedPreferences prefs = getSharedPreferences("ChatApp", MODE_PRIVATE);
            prefs.edit().putString("userId", user.getUserId()).apply();
            
            // Navigate to home
            Intent intent = new Intent(this, HomeActivity.class);
            startActivity(intent);
            finish();
        } else {
            Toast.makeText(this, "Invalid credentials", Toast.LENGTH_SHORT).show();
        }
    }
}
```

### Step 3: Update RegisterActivity

```java
public class RegisterActivity extends AppCompatActivity {
    private EditText usernameInput, emailInput, passwordInput;
    private Button registerButton;
    private DatabaseManager dbManager;
    
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_register);
        
        dbManager = DatabaseManager.getInstance();
        
        usernameInput = findViewById(R.id.username_input);
        emailInput = findViewById(R.id.email_input);
        passwordInput = findViewById(R.id.password_input);
        registerButton = findViewById(R.id.register_button);
        
        registerButton.setOnClickListener(v -> handleRegister());
    }
    
    private void handleRegister() {
        String username = usernameInput.getText().toString().trim();
        String email = emailInput.getText().toString().trim();
        String password = passwordInput.getText().toString().trim();
        
        if (username.isEmpty() || email.isEmpty() || password.isEmpty()) {
            Toast.makeText(this, "Please fill all fields", Toast.LENGTH_SHORT).show();
            return;
        }
        
        if (dbManager.isEmailRegistered(email)) {
            Toast.makeText(this, "Email already registered", Toast.LENGTH_SHORT).show();
            return;
        }
        
        UserModel user = dbManager.registerUser(email, password, username);
        Toast.makeText(this, "Registration successful!", Toast.LENGTH_SHORT).show();
        
        // Navigate to login
        Intent intent = new Intent(this, LoginActivity.class);
        startActivity(intent);
        finish();
    }
}
```

## Usage Examples

### Saving Chat Messages

```java
// In your chat activity
String sessionId = getCurrentSessionId();
String userMessage = messageInput.getText().toString();

// Save user message
dbManager.saveChatMessage(sessionId, userMessage, true);

// After getting bot response
String botResponse = getBotResponse(userMessage);
dbManager.saveChatMessage(sessionId, botResponse, false);
```

### Loading Chat History

```java
String userId = getCurrentUserId();
RealmResults<ChatSessionModel> sessions = dbManager.getUserChatSessions(userId);

for (ChatSessionModel session : sessions) {
    String title = session.getSessionTitle();
    RealmResults<ChatMessageModel> messages = dbManager.getSessionMessages(session.getSessionId());
    // Display in UI
}
```

### Saving Quiz Results

```java
// After quiz completion
RealmList<QuestionResultModel> questionResults = new RealmList<>();
// Add question results...

dbManager.saveQuizResult(
    userId,
    "Mathematics",
    10,
    8,
    questionResults
);
```

### Creating Flashcard Set

```java
RealmList<FlashcardModel> flashcards = new RealmList<>();

Realm realm = dbManager.getRealm();
realm.beginTransaction();
for (int i = 0; i < flashcardData.size(); i++) {
    FlashcardModel card = realm.createObject(FlashcardModel.class);
    card.setFront(flashcardData.get(i).front);
    card.setBack(flashcardData.get(i).back);
    flashcards.add(card);
}
realm.commitTransaction();

dbManager.createFlashcardSet(userId, "Biology Terms", flashcards);
```

## Important Notes

### Security
- **NEVER** store plain text passwords in production
- Use BCrypt or similar for password hashing
- Consider using MongoDB Realm's built-in authentication

### Data Persistence
- Data is automatically persisted locally
- Survives app uninstall only if using cloud sync
- For full data persistence across uninstalls, set up MongoDB Atlas sync

### Performance
- Use async operations for large queries
- Close Realm instances when not needed
- Use RealmResults for efficient querying

### Migration
When changing schema:
1. Increment `schemaVersion` in RealmConfiguration
2. Provide migration logic (don't use `deleteRealmIfMigrationNeeded` in production)

## Troubleshooting

### Common Issues

1. **App crashes on startup**
   - Ensure Realm is initialized in Application class
   - Check all model classes extend RealmObject

2. **Data not persisting**
   - Verify transactions are committed
   - Check Realm instance is not closed prematurely

3. **Build errors**
   - Clean and rebuild project
   - Verify all dependencies are added
   - Check Realm plugin is applied

## Next Steps

1. Implement password hashing (BCrypt)
2. Set up MongoDB Atlas for cloud sync
3. Add data encryption
4. Implement offline-first architecture
5. Add data export/import functionality

For more information, visit [MongoDB Realm Documentation](https://www.mongodb.com/docs/realm/)
