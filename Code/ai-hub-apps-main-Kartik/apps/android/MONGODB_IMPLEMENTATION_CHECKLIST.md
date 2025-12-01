# MongoDB Integration Checklist

## Prerequisites
- [ ] Android Studio installed
- [ ] ChatApp project opened
- [ ] Read MONGODB_INTEGRATION_GUIDE.md

## Phase 1: Dependencies & Configuration (30 minutes)

### 1.1 Update Project-level build.gradle
- [ ] Open `build.gradle` (Project level)
- [ ] Add Realm classpath: `classpath 'io.realm:realm-gradle-plugin:10.18.0'`
- [ ] Sync project

### 1.2 Update App-level build.gradle
- [ ] Open `ChatApp/build.gradle`
- [ ] Apply Realm plugin: `id 'realm-android'`
- [ ] Add Realm dependencies:
  ```gradle
  implementation 'io.realm:realm-android-library:10.18.0'
  implementation 'io.realm:realm-android-kotlin-extensions:10.18.0'
  ```
- [ ] Sync project
- [ ] Verify no build errors

### 1.3 Update AndroidManifest.xml
- [ ] Open `AndroidManifest.xml`
- [ ] Add application name: `android:name=".ChatApplication"`
- [ ] Verify INTERNET permission exists (for cloud sync if needed)

## Phase 2: Database Models (45 minutes)

### 2.1 Create Database Package Structure
- [ ] Create package: `com.quicinc.chatapp.database`
- [ ] Create package: `com.quicinc.chatapp.database.models`

### 2.2 Create Model Classes
- [ ] Create `UserModel.java` (includes: userId, email, password, username, dates, relationships)
- [ ] Create `ChatSessionModel.java` (includes: sessionId, userId, title, dates, messages)
- [ ] Create `ChatMessageModel.java` (includes: messageId, sessionId, content, isUser, timestamp)
- [ ] Create `QuizResultModel.java` (includes: quizId, userId, topic, scores, dates, questions)
- [ ] Create `QuestionResultModel.java` (includes: question, answers, isCorrect)
- [ ] Create `FlashcardSetModel.java` (includes: setId, userId, title, date, flashcards)
- [ ] Create `FlashcardModel.java` (includes: front, back)
- [ ] Create `GemModel.java` (includes: gemId, userId, title, content, date)

### 2.3 Verify Models
- [ ] Build project to check for compilation errors
- [ ] Verify all models extend `RealmObject`
- [ ] Verify @PrimaryKey annotations
- [ ] Verify @Required annotations on mandatory fields

## Phase 3: Database Manager (60 minutes)

### 3.1 Create DatabaseManager.java
- [ ] Create `DatabaseManager.java` in `database` package
- [ ] Implement singleton pattern
- [ ] Add `initialize(Context)` method
- [ ] Add `getRealm()` and `closeRealm()` methods

### 3.2 Implement User Operations
- [ ] Add `registerUser(email, password, username)` method
- [ ] Add `loginUser(email, password)` method
- [ ] Add `getUserById(userId)` method
- [ ] Add `isEmailRegistered(email)` method

### 3.3 Implement Chat Operations
- [ ] Add `createChatSession(userId, title)` method
- [ ] Add `saveChatMessage(sessionId, content, isUser)` method
- [ ] Add `getUserChatSessions(userId)` method
- [ ] Add `getSessionMessages(sessionId)` method
- [ ] Add `deleteChatSession(sessionId)` method

### 3.4 Implement Quiz Operations
- [ ] Add `saveQuizResult(...)` method
- [ ] Add `getUserQuizResults(userId)` method
- [ ] Add `getQuizById(quizId)` method

### 3.5 Implement Flashcard Operations
- [ ] Add `createFlashcardSet(...)` method
- [ ] Add `getUserFlashcardSets(userId)` method
- [ ] Add `deleteFlashcardSet(setId)` method

### 3.6 Implement Gem Operations
- [ ] Add `createGem(userId, title, content)` method
- [ ] Add `getUserGems(userId)` method
- [ ] Add `deleteGem(gemId)` method

## Phase 4: Application Initialization (15 minutes)

### 4.1 Create ChatApplication.java
- [ ] Create `ChatApplication.java` extending `Application`
- [ ] Override `onCreate()` method
- [ ] Initialize DatabaseManager in `onCreate()`
- [ ] Update AndroidManifest.xml with application name

### 4.2 Test Initialization
- [ ] Run app
- [ ] Check logcat for Realm initialization messages
- [ ] Verify no crashes on startup

## Phase 5: Activity Integration (90 minutes)

### 5.1 Update LoginActivity
- [ ] Add DatabaseManager instance
- [ ] Implement `handleLogin()` using `dbManager.loginUser()`
- [ ] Save userId to SharedPreferences on success
- [ ] Add error handling for invalid credentials
- [ ] Test login flow

### 5.2 Update RegisterActivity
- [ ] Add DatabaseManager instance
- [ ] Implement `handleRegister()` using `dbManager.registerUser()`
- [ ] Check if email already registered
- [ ] Add validation for all fields
- [ ] Test registration flow

### 5.3 Update MainActivity/Conversation
- [ ] Get userId from SharedPreferences
- [ ] Create chat session on first message
- [ ] Save each message using `dbManager.saveChatMessage()`
- [ ] Load chat history on activity start
- [ ] Update UI with loaded messages

### 5.4 Update Chat History Display
- [ ] Load all user sessions using `dbManager.getUserChatSessions()`
- [ ] Display in navigation drawer or separate activity
- [ ] Implement session selection to load specific chat
- [ ] Add delete session functionality

### 5.5 Update QuizActivity
- [ ] Save quiz results after completion
- [ ] Include all question results
- [ ] Calculate and save score

### 5.6 Update QuizHistoryActivity
- [ ] Load all quiz results using `dbManager.getUserQuizResults()`
- [ ] Display in RecyclerView
- [ ] Show details when item clicked
- [ ] Implement weak topics analysis from saved data

### 5.7 Update FlashcardActivity
- [ ] Save flashcard sets using `dbManager.createFlashcardSet()`
- [ ] Load user's flashcard sets
- [ ] Implement edit and delete functionality

### 5.8 Update GemsActivity
- [ ] Save gems using `dbManager.createGem()`
- [ ] Load and display user gems
- [ ] Implement delete functionality

## Phase 6: Testing (60 minutes)

### 6.1 User Authentication Testing
- [ ] Test user registration with valid data
- [ ] Test registration with duplicate email (should fail)
- [ ] Test login with correct credentials
- [ ] Test login with wrong credentials (should fail)
- [ ] Verify user data persists after app restart

### 6.2 Chat Functionality Testing
- [ ] Start a new chat session
- [ ] Send multiple messages
- [ ] Close and reopen app
- [ ] Verify chat history loads correctly
- [ ] Create multiple chat sessions
- [ ] Test session deletion
- [ ] Verify messages are in correct order (by timestamp)

### 6.3 Quiz Functionality Testing
- [ ] Complete a quiz
- [ ] Verify results are saved
- [ ] View quiz history
- [ ] Check score calculations
- [ ] Verify weak topics are identified

### 6.4 Flashcard Testing
- [ ] Create a flashcard set
- [ ] Add multiple flashcards
- [ ] Reload app and verify flashcards persist
- [ ] Edit flashcard set
- [ ] Delete flashcard set

### 6.5 Gems Testing
- [ ] Create multiple gems
- [ ] View gems list
- [ ] Delete gem
- [ ] Verify persistence

### 6.6 Data Persistence Testing
- [ ] Use app normally for 5 minutes
- [ ] Force stop app
- [ ] Reopen app
- [ ] Verify all data is intact
- [ ] Clear app data
- [ ] Verify fresh start
- [ ] **UNINSTALL and REINSTALL app**
- [ ] **Note: Data will NOT persist across uninstall without cloud sync**

## Phase 7: Data Persistence Across Uninstalls (Optional - Cloud Sync)

### 7.1 MongoDB Atlas Setup
- [ ] Create MongoDB Atlas account
- [ ] Create a cluster
- [ ] Create a Realm App
- [ ] Get App ID

### 7.2 Enable Sync
- [ ] Add Realm App ID to configuration
- [ ] Enable user authentication in Atlas
- [ ] Configure sync rules
- [ ] Update DatabaseManager to use sync

### 7.3 Test Cloud Sync
- [ ] Login and create data
- [ ] Uninstall app
- [ ] Reinstall app
- [ ] Login again
- [ ] Verify data is restored

## Phase 8: Security & Optimization (30 minutes)

### 8.1 Password Security
- [ ] Add BCrypt dependency
- [ ] Hash passwords before storing
- [ ] Update login to verify hashed passwords

### 8.2 Performance Optimization
- [ ] Add indexes to frequently queried fields
- [ ] Implement pagination for large lists
- [ ] Use async queries for heavy operations
- [ ] Close Realm instances properly

### 8.3 Error Handling
- [ ] Add try-catch blocks for all database operations
- [ ] Log errors appropriately
- [ ] Show user-friendly error messages

## Phase 9: Documentation & Cleanup (20 minutes)

### 9.1 Code Documentation
- [ ] Add JavaDoc comments to DatabaseManager methods
- [ ] Document model classes
- [ ] Add inline comments for complex logic

### 9.2 User Guide
- [ ] Create user guide for app features
- [ ] Document data persistence behavior
- [ ] Add troubleshooting section

### 9.3 Final Testing
- [ ] Complete end-to-end testing
- [ ] Test on different Android versions
- [ ] Test on different devices
- [ ] Fix any remaining bugs

## Troubleshooting Checklist

### Build Errors
- [ ] Clean project (Build → Clean Project)
- [ ] Rebuild project (Build → Rebuild Project)
- [ ] Invalidate caches (File → Invalidate Caches)
- [ ] Check Gradle sync
- [ ] Verify all dependencies are correct

### Runtime Errors
- [ ] Check logcat for stack traces
- [ ] Verify Realm is initialized
- [ ] Check model classes extend RealmObject
- [ ] Verify transactions are committed
- [ ] Check primary keys are unique

### Data Not Persisting
- [ ] Verify transactions are committed
- [ ] Check Realm instance is not closed prematurely
- [ ] Verify proper error handling
- [ ] Check file permissions

## Important Notes

⚠️ **Data Persistence Across Uninstalls:**
- Local Realm data is stored in app's private directory
- Uninstalling the app deletes this directory
- To persist data across uninstalls, you MUST set up MongoDB Atlas sync
- Without cloud sync, data will be lost on uninstall

✅ **What Persists WITHOUT Cloud Sync:**
- Data persists across app restarts
- Data persists across device reboots
- Data persists when clearing app cache
- Data survives app updates

❌ **What Does NOT Persist WITHOUT Cloud Sync:**
- Data does not survive app uninstall
- Data is not shared across devices
- No automatic backups

💡 **Recommended Approach:**
1. Implement local MongoDB Realm first (this checklist)
2. Test thoroughly
3. Add MongoDB Atlas sync for production
4. This gives you offline-first with cloud backup

## Estimated Total Time: 5-6 hours

Good luck with your implementation! 🚀
