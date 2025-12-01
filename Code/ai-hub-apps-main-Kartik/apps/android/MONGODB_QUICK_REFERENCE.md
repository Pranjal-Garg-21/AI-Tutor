# MongoDB Quick Reference - Common Operations

## Table of Contents
1. [User Authentication](#user-authentication)
2. [Chat Management](#chat-management)
3. [Quiz Operations](#quiz-operations)
4. [Flashcard Operations](#flashcard-operations)
5. [Gem Operations](#gem-operations)

---

## User Authentication

### Register New User
```java
// In RegisterActivity
DatabaseManager dbManager = DatabaseManager.getInstance();

String email = emailInput.getText().toString().trim();
String password = passwordInput.getText().toString().trim();
String username = usernameInput.getText().toString().trim();

// Check if email exists
if (dbManager.isEmailRegistered(email)) {
    Toast.makeText(this, "Email already registered", Toast.LENGTH_SHORT).show();
    return;
}

// Register user
UserModel user = dbManager.registerUser(email, password, username);

if (user != null) {
    Toast.makeText(this, "Registration successful!", Toast.LENGTH_SHORT).show();
    // Navigate to login
}
```

### Login User
```java
// In LoginActivity
DatabaseManager dbManager = DatabaseManager.getInstance();

String email = emailInput.getText().toString().trim();
String password = passwordInput.getText().toString().trim();

UserModel user = dbManager.loginUser(email, password);

if (user != null) {
    // Save user session
    SharedPreferences prefs = getSharedPreferences("ChatApp", MODE_PRIVATE);
    prefs.edit().putString("userId", user.getUserId()).apply();
    prefs.edit().putString("username", user.getUsername()).apply();
    
    // Navigate to home
    Intent intent = new Intent(this, HomeActivity.class);
    startActivity(intent);
    finish();
} else {
    Toast.makeText(this, "Invalid credentials", Toast.LENGTH_SHORT).show();
}
```

### Get Current User ID
```java
// Anywhere in the app
SharedPreferences prefs = getSharedPreferences("ChatApp", MODE_PRIVATE);
String userId = prefs.getString("userId", null);

if (userId == null) {
    // User not logged in, redirect to login
    Intent intent = new Intent(this, LoginActivity.class);
    startActivity(intent);
    finish();
}
```

### Logout User
```java
// In any activity
SharedPreferences prefs = getSharedPreferences("ChatApp", MODE_PRIVATE);
prefs.edit().clear().apply();

// Redirect to login
Intent intent = new Intent(this, LoginActivity.class);
intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TASK);
startActivity(intent);
finish();
```

---

## Chat Management

### Create New Chat Session
```java
// When user starts a new chat
DatabaseManager dbManager = DatabaseManager.getInstance();
String userId = getCurrentUserId();

ChatSessionModel session = dbManager.createChatSession(
    userId, 
    "Chat " + new SimpleDateFormat("MMM dd, HH:mm", Locale.getDefault()).format(new Date())
);

// Save session ID for current conversation
currentSessionId = session.getSessionId();
```

### Save Chat Messages
```java
// When user sends a message
DatabaseManager dbManager = DatabaseManager.getInstance();
String userMessage = messageInput.getText().toString().trim();

// Save user message
dbManager.saveChatMessage(currentSessionId, userMessage, true);

// Clear input
messageInput.setText("");

// Get bot response (your existing logic)
getBotResponse(userMessage, new ResponseCallback() {
    @Override
    public void onResponse(String botResponse) {
        // Save bot message
        dbManager.saveChatMessage(currentSessionId, botResponse, false);
        
        // Update UI
        runOnUiThread(() -> {
            addMessageToUI(new ChatMessage(botResponse, false));
        });
    }
});
```

### Load Chat History
```java
// When opening a chat session
DatabaseManager dbManager = DatabaseManager.getInstance();

RealmResults<ChatMessageModel> messages = dbManager.getSessionMessages(sessionId);

// Display messages
messageList.clear();
for (ChatMessageModel message : messages) {
    messageList.add(new ChatMessage(
        message.getContent(),
        message.isUser()
    ));
}
messageAdapter.notifyDataSetChanged();
scrollToBottom();
```

### Load All User Chat Sessions
```java
// In chat history activity or navigation drawer
DatabaseManager dbManager = DatabaseManager.getInstance();
String userId = getCurrentUserId();

RealmResults<ChatSessionModel> sessions = dbManager.getUserChatSessions(userId);

// Auto-update when data changes
sessions.addChangeListener(new RealmChangeListener<RealmResults<ChatSessionModel>>() {
    @Override
    public void onChange(RealmResults<ChatSessionModel> results) {
        sessionAdapter.notifyDataSetChanged();
    }
});

// Display in RecyclerView
chatSessionAdapter.updateData(sessions);
```

### Delete Chat Session
```java
// When user long-presses and selects delete
DatabaseManager dbManager = DatabaseManager.getInstance();

new AlertDialog.Builder(this)
    .setTitle("Delete Chat")
    .setMessage("Are you sure you want to delete this chat?")
    .setPositiveButton("Delete", (dialog, which) -> {
        dbManager.deleteChatSession(sessionId);
        Toast.makeText(this, "Chat deleted", Toast.LENGTH_SHORT).show();
        
        // Refresh list
        loadChatSessions();
    })
    .setNegativeButton("Cancel", null)
    .show();
```

---

## Quiz Operations

### Save Quiz Results
```java
// After quiz completion
DatabaseManager dbManager = DatabaseManager.getInstance();
String userId = getCurrentUserId();

// Create question results
Realm realm = dbManager.getRealm();
realm.beginTransaction();

RealmList<QuestionResultModel> questionResults = new RealmList<>();
for (int i = 0; i < quizQuestions.size(); i++) {
    QuestionResultModel qr = realm.createObject(QuestionResultModel.class);
    qr.setQuestion(quizQuestions.get(i).getQuestion());
    qr.setUserAnswer(userAnswers.get(i));
    qr.setCorrectAnswer(quizQuestions.get(i).getCorrectAnswer());
    qr.setCorrect(userAnswers.get(i).equals(quizQuestions.get(i).getCorrectAnswer()));
    questionResults.add(qr);
}

realm.commitTransaction();

// Save quiz result
QuizResultModel quizResult = dbManager.saveQuizResult(
    userId,
    quizTopic,
    quizQuestions.size(),
    correctAnswersCount,
    questionResults
);

// Navigate to results screen
Intent intent = new Intent(this, QuizDetailActivity.class);
intent.putExtra("quizId", quizResult.getQuizId());
startActivity(intent);
```

### Load Quiz History
```java
// In QuizHistoryActivity
DatabaseManager dbManager = DatabaseManager.getInstance();
String userId = getCurrentUserId();

RealmResults<QuizResultModel> quizResults = dbManager.getUserQuizResults(userId);

// Display in RecyclerView
quizHistoryAdapter.updateData(quizResults);
```

### Display Quiz Details
```java
// In QuizDetailActivity
DatabaseManager dbManager = DatabaseManager.getInstance();
String quizId = getIntent().getStringExtra("quizId");

QuizResultModel quiz = dbManager.getQuizById(quizId);

if (quiz != null) {
    // Display quiz information
    topicText.setText(quiz.getTopic());
    scoreText.setText(String.format("%.1f%%", quiz.getScore()));
    correctText.setText(quiz.getCorrectAnswers() + "/" + quiz.getTotalQuestions());
    
    // Display question results
    RealmList<QuestionResultModel> questions = quiz.getQuestionResults();
    for (QuestionResultModel q : questions) {
        // Add to UI
        addQuestionResult(q);
    }
}
```

### Analyze Weak Topics
```java
// Get all quiz results and analyze
DatabaseManager dbManager = DatabaseManager.getInstance();
String userId = getCurrentUserId();

RealmResults<QuizResultModel> quizResults = dbManager.getUserQuizResults(userId);

Map<String, List<Double>> topicScores = new HashMap<>();

for (QuizResultModel quiz : quizResults) {
    String topic = quiz.getTopic();
    if (!topicScores.containsKey(topic)) {
        topicScores.put(topic, new ArrayList<>());
    }
    topicScores.get(topic).add(quiz.getScore());
}

// Find topics with average score < 60%
List<String> weakTopics = new ArrayList<>();
for (Map.Entry<String, List<Double>> entry : topicScores.entrySet()) {
    double avg = entry.getValue().stream().mapToDouble(Double::doubleValue).average().orElse(0);
    if (avg < 60.0) {
        weakTopics.add(entry.getKey());
    }
}

// Display weak topics
displayWeakTopics(weakTopics);
```

---

## Flashcard Operations

### Create Flashcard Set
```java
// In CreateFlashcardSetActivity
DatabaseManager dbManager = DatabaseManager.getInstance();
String userId = getCurrentUserId();

String setTitle = titleInput.getText().toString().trim();

// Create flashcards
Realm realm = dbManager.getRealm();
realm.beginTransaction();

RealmList<FlashcardModel> flashcards = new RealmList<>();
for (FlashcardInput input : flashcardInputs) {
    FlashcardModel card = realm.createObject(FlashcardModel.class);
    card.setFront(input.getFront());
    card.setBack(input.getBack());
    flashcards.add(card);
}

realm.commitTransaction();

// Save flashcard set
FlashcardSetModel flashcardSet = dbManager.createFlashcardSet(
    userId,
    setTitle,
    flashcards
);

Toast.makeText(this, "Flashcard set created!", Toast.LENGTH_SHORT).show();
finish();
```

### Load Flashcard Sets
```java
// In FlashcardActivity
DatabaseManager dbManager = DatabaseManager.getInstance();
String userId = getCurrentUserId();

RealmResults<FlashcardSetModel> flashcardSets = dbManager.getUserFlashcardSets(userId);

// Display in RecyclerView
flashcardSetsAdapter.updateData(flashcardSets);
```

### Study Flashcards
```java
// In FlashcardStudyActivity
DatabaseManager dbManager = DatabaseManager.getInstance();
String setId = getIntent().getStringExtra("setId");

// Get flashcard set
RealmResults<FlashcardSetModel> results = dbManager.getRealm()
    .where(FlashcardSetModel.class)
    .equalTo("setId", setId)
    .findAll();

if (!results.isEmpty()) {
    FlashcardSetModel set = results.first();
    RealmList<FlashcardModel> flashcards = set.getFlashcards();
    
    // Set up flashcard viewer
    currentFlashcardIndex = 0;
    totalFlashcards = flashcards.size();
    
    displayFlashcard(flashcards.get(currentFlashcardIndex));
}
```

### Delete Flashcard Set
```java
// In FlashcardSetsAdapter
holder.deleteButton.setOnClickListener(v -> {
    new AlertDialog.Builder(context)
        .setTitle("Delete Flashcard Set")
        .setMessage("Are you sure?")
        .setPositiveButton("Delete", (dialog, which) -> {
            DatabaseManager dbManager = DatabaseManager.getInstance();
            dbManager.deleteFlashcardSet(flashcardSet.getSetId());
            Toast.makeText(context, "Flashcard set deleted", Toast.LENGTH_SHORT).show();
        })
        .setNegativeButton("Cancel", null)
        .show();
});
```

---

## Gem Operations

### Create Gem
```java
// In CreateGemActivity
DatabaseManager dbManager = DatabaseManager.getInstance();
String userId = getCurrentUserId();

String gemTitle = titleInput.getText().toString().trim();
String gemContent = contentInput.getText().toString().trim();

if (gemTitle.isEmpty() || gemContent.isEmpty()) {
    Toast.makeText(this, "Please fill all fields", Toast.LENGTH_SHORT).show();
    return;
}

GemModel gem = dbManager.createGem(userId, gemTitle, gemContent);

Toast.makeText(this, "Gem created!", Toast.LENGTH_SHORT).show();
finish();
```

### Load User Gems
```java
// In GemsActivity
DatabaseManager dbManager = DatabaseManager.getInstance();
String userId = getCurrentUserId();

RealmResults<GemModel> gems = dbManager.getUserGems(userId);

// Auto-update on changes
gems.addChangeListener(new RealmChangeListener<RealmResults<GemModel>>() {
    @Override
    public void onChange(RealmResults<GemModel> results) {
        gemsAdapter.notifyDataSetChanged();
    }
});

// Display in RecyclerView
gemsAdapter.updateData(gems);
```

### Display Gem Details
```java
// In GemViewActivity
DatabaseManager dbManager = DatabaseManager.getInstance();
String gemId = getIntent().getStringExtra("gemId");

GemModel gem = dbManager.getRealm()
    .where(GemModel.class)
    .equalTo("gemId", gemId)
    .findFirst();

if (gem != null) {
    titleText.setText(gem.getTitle());
    contentText.setText(gem.getContent());
    
    SimpleDateFormat sdf = new SimpleDateFormat("MMM dd, yyyy HH:mm", Locale.getDefault());
    dateText.setText("Created: " + sdf.format(gem.getCreatedDate()));
}
```

### Delete Gem
```java
// In GemsAdapter
holder.deleteButton.setOnClickListener(v -> {
    new AlertDialog.Builder(context)
        .setTitle("Delete Gem")
        .setMessage("Are you sure you want to delete this gem?")
        .setPositiveButton("Delete", (dialog, which) -> {
            DatabaseManager dbManager = DatabaseManager.getInstance();
            dbManager.deleteGem(gem.getGemId());
            Toast.makeText(context, "Gem deleted", Toast.LENGTH_SHORT).show();
        })
        .setNegativeButton("Cancel", null)
        .show();
});
```

---

## Utility Functions

### Get Current User ID
```java
private String getCurrentUserId() {
    SharedPreferences prefs = getSharedPreferences("ChatApp", MODE_PRIVATE);
    String userId = prefs.getString("userId", null);
    
    if (userId == null) {
        // Redirect to login
        Intent intent = new Intent(this, LoginActivity.class);
        intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TASK);
        startActivity(intent);
        finish();
        return null;
    }
    
    return userId;
}
```

### Generate Unique ID
```java
// MongoDB Realm handles this automatically for @PrimaryKey fields
// But if you need manual ID generation:
String uniqueId = UUID.randomUUID().toString();
```

### Format Date
```java
private String formatDate(Date date) {
    SimpleDateFormat sdf = new SimpleDateFormat("MMM dd, yyyy HH:mm", Locale.getDefault());
    return sdf.format(date);
}
```

### Check if User is Logged In
```java
private boolean isUserLoggedIn() {
    SharedPreferences prefs = getSharedPreferences("ChatApp", MODE_PRIVATE);
    return prefs.contains("userId");
}
```

---

## Best Practices

### 1. Always Close Realm Instances
```java
@Override
protected void onDestroy() {
    super.onDestroy();
    DatabaseManager.getInstance().closeRealm();
}
```

### 2. Use Try-Catch for Database Operations
```java
try {
    UserModel user = dbManager.registerUser(email, password, username);
    if (user != null) {
        // Success
    }
} catch (Exception e) {
    Log.e("RegisterActivity", "Error registering user", e);
    Toast.makeText(this, "Registration failed", Toast.LENGTH_SHORT).show();
}
```

### 3. Handle Realm Results Properly
```java
// RealmResults are live objects - they update automatically
RealmResults<ChatSessionModel> sessions = dbManager.getUserChatSessions(userId);

// Add change listener
sessions.addChangeListener(results -> {
    // UI update code
    adapter.notifyDataSetChanged();
});

// Don't forget to remove listener
@Override
protected void onDestroy() {
    super.onDestroy();
    if (sessions != null) {
        sessions.removeAllChangeListeners();
    }
}
```

### 4. Update UI on Main Thread
```java
// If database operation is on background thread
runOnUiThread(() -> {
    messageList.add(message);
    messageAdapter.notifyDataSetChanged();
});
```

---

## Common Errors & Solutions

### Error: "Realm accessed from incorrect thread"
**Solution:** Always access Realm from the same thread, or use `realm.copyFromRealm()` to get unmanaged copies

```java
// Wrong
new Thread(() -> {
    Realm realm = Realm.getDefaultInstance();
    // ...
}).start();

// Right
AsyncTask.execute(() -> {
    Realm realm = Realm.getDefaultInstance();
    try {
        // Database operations
    } finally {
        realm.close();
    }
});
```

### Error: "Illegal State: Cannot modify managed objects outside of a write transaction"
**Solution:** Wrap modifications in transactions

```java
Realm realm = dbManager.getRealm();
realm.beginTransaction();
// Modify objects here
realm.commitTransaction();
```

### Error: "Primary key already exists"
**Solution:** Use unique IDs or check existence before creating

```java
String userId = UUID.randomUUID().toString(); // Always unique
```

---

## Performance Tips

1. **Use indexes for frequently queried fields**
2. **Limit query results** - Don't load all data at once
3. **Use lazy loading** for large lists
4. **Close Realm instances** when done
5. **Use RealmResults** instead of copying to ArrayList

---

For more details, refer to `MONGODB_INTEGRATION_GUIDE.md`
