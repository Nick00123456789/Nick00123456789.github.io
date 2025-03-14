// Replace with your Firebase config from Project Settings
const firebaseConfig = {
    apiKey: "AIzaSyCCKPEreMGbgpP1lmA9uDFADzuNC_0C9gk",
    authDomain: "nickproject.firebaseapp.com",
    databaseURL: "https://nickproject-66789-default-rtdb.europe-west1.firebasedatabase.app/",
    projectId: "nickproject-66789",
    storageBucket: "nickproject.appspot.com",
    messagingSenderId: "178516922595 ",
    appId: "1:178516922595:web:4ca9977e5809c31d0d35d6"

};

    // Initialize Firebase
    firebase.initializeApp(firebaseConfig);
    const auth = firebase.auth();
    const db = firebase.database();
    
    let currentDMRecipient = null;
    let allUsers = {};
    let onlineUsers = {};
    
    // Utility: Debounce function to limit search frequency
    function debounce(func, wait) {
        let timeout;
        return function (...args) {
            clearTimeout(timeout);
            timeout = setTimeout(() => func.apply(this, args), wait);
        };
    }
    
    // DOM Content Loaded Event Listener
    document.addEventListener("DOMContentLoaded", function () {
        const authPanel = document.getElementById("auth");
        const chatPanel = document.getElementById("chat");
        const messagesDiv = document.getElementById("messages");
        const dmMessagesDiv = document.getElementById("dm-messages");
        const status = document.getElementById("status");
    
        // Display status messages
        function showStatus(message, success = false) {
            status.textContent = message;
            status.style.color = success ? "#00ff00" : "#ff4444";
        }
    
        // Append a message to the specified container
        function appendMessage(data, container) {
            const div = document.createElement("div");
            div.classList.add("message");
            const sender = data.val().sender;
            const time = new Date(data.val().timestamp).toLocaleTimeString([], { hour: "2-digit", minute: "2-digit" });
            const isOnline = onlineUsers[sender] ? "online" : "offline";
            div.innerHTML = `
                <span class="status-circle ${isOnline}"></span>
                <span class="user">${sender}</span>
                <span class="time">[${time}]</span>: ${data.val().content}
            `;
            container.appendChild(div);
            container.scrollTop = container.scrollHeight;
        }
    
        // Load public messages with real-time updates
        function loadMessages() {
            messagesDiv.innerHTML = ""; // Clear existing messages
            db.ref("messages")
                .orderByChild("timestamp")
                .on("child_added", (snapshot) => {
                    appendMessage(snapshot, messagesDiv);
                }, (error) => {
                    console.error("Error loading messages:", error);
                    showStatus("Failed to load messages: " + error.message);
                });
        }
    
        // Load DMs for a specific conversation
        function loadDMs(recipient) {
            const uid = sessionStorage.getItem("uid");
            const dmPath = `dms/${uid < recipient.uid ? uid + "_" + recipient.uid : recipient.uid + "_" + uid}/messages`;
            dmMessagesDiv.innerHTML = ""; // Clear existing DMs
            db.ref(dmPath)
                .orderByChild("timestamp")
                .on("child_added", (snapshot) => {
                    appendMessage(snapshot, dmMessagesDiv);
                }, (error) => {
                    console.error("Error loading DMs:", error);
                    showStatus("Failed to load DMs: " + error.message);
                });
        }
    
        // Update user's online status
        function updateOnlineStatus(isOnline) {
            const uid = sessionStorage.getItem("uid");
            if (uid) {
                db.ref("online/" + uid)
                    .set(isOnline ? true : null)
                    .catch((error) => {
                        console.error("Error updating online status:", error);
                        showStatus("Error updating status: " + error.message);
                    });
            }
        }
    
        // Load all users for the search list
        function loadAllUsers() {
            db.ref("users").on("value", (snapshot) => {
                allUsers = snapshot.val() || {};
                searchUsers();
            }, (error) => {
                console.error("Error loading users:", error);
                showStatus("Failed to load users: " + error.message);
            });
        }
    
        // Load online users for status indicators
        function loadOnlineUsers() {
            db.ref("online").on("value", (snapshot) => {
                onlineUsers = {};
                snapshot.forEach((child) => {
                    const uid = child.key;
                    if (allUsers[uid]) {
                        onlineUsers[allUsers[uid].username] = true;
                    }
                });
                searchUsers();
            }, (error) => {
                console.error("Error loading online users:", error);
                showStatus("Failed to load online users: " + error.message);
            });
        }
    
        // Search and display users in the user list
        window.searchUsers = debounce(function () {
            const searchInput = document.getElementById("search-input").value.toLowerCase();
            const userList = document.getElementById("user-list");
            userList.innerHTML = "";
            for (let uid in allUsers) {
                const username = allUsers[uid].username;
                if (username && (username.toLowerCase().includes(searchInput) || searchInput === "")) {
                    const isOnline = onlineUsers[username] ? "online" : "offline";
                    const div = document.createElement("div");
                    div.classList.add("user-item");
                    div.innerHTML = `<span class="user">${username}</span>`;
                    div.onclick = () => startDM({ uid, username });
                    userList.appendChild(div);
                }
            }
        }, 300);
    
        // Start a DM conversation
        window.startDM = function (recipient) {
            if (recipient.uid === sessionStorage.getItem("uid")) return;
            currentDMRecipient = recipient;
            document.getElementById("dm-recipient").textContent = recipient.username;
            document.getElementById("public-chat").classList.add("hidden");
            document.getElementById("dm-chat").classList.remove("hidden");
            loadDMs(recipient);
        };
    
        // Close the DM window
        window.closeDM = function () {
            document.getElementById("public-chat").classList.remove("hidden");
            document.getElementById("dm-chat").classList.add("hidden");
            currentDMRecipient = null;
            dmMessagesDiv.innerHTML = "";
            db.ref("dms").off();
        };
    
        // Send a DM (fixed to prevent multiple sends)
        window.handleSendDM = async function (event) {
            event.preventDefault();
            const sendBtn = document.getElementById("dm-send-btn");
            if (sendBtn.disabled) return; // Prevent multiple clicks
            sendBtn.disabled = true;
    
            if (!currentDMRecipient) {
                showStatus("No recipient selected.");
                sendBtn.disabled = false;
                return;
            }
    
            const username = sessionStorage.getItem("chatSphereUser");
            const content = document.getElementById("dm-input").value.trim();
            const uid = sessionStorage.getItem("uid");
            const dmPath = `dms/${uid < currentDMRecipient.uid ? uid + "_" + currentDMRecipient.uid : currentDMRecipient.uid + "_" + uid}/messages`;
    
            if (!content || !username) {
                showStatus("Message or username missing.");
                sendBtn.disabled = false;
                return;
            }
    
            try {
                await db.ref(dmPath).push({
                    sender: username,
                    content: content,
                    timestamp: firebase.database.ServerValue.TIMESTAMP
                });
                document.getElementById("dm-input").value = "";
                showStatus("DM sent!", true);
            } catch (error) {
                console.error("Error sending DM:", error);
                showStatus("Error sending DM: " + error.message);
            } finally {
                sendBtn.disabled = false;
            }
        };
    
        // Register a new user
        window.handleRegister = async function () {
            const registerBtn = document.getElementById("register-btn");
            registerBtn.disabled = true;
    
            const username = document.getElementById("username").value.trim();
            const password = document.getElementById("password").value;
            const email = `${username.toLowerCase()}@chatsphere.com`;
    
            if (!username || !password) {
                showStatus("Username and password are required.");
                registerBtn.disabled = false;
                return;
            }
            if (password.length < 6) {
                showStatus("Password must be at least 6 characters.");
                registerBtn.disabled = false;
                return;
            }
    
            try {
                // Check if username is unique
                const usersSnapshot = await db.ref("users").orderByChild("username").equalTo(username).once("value");
                if (usersSnapshot.exists()) {
                    showStatus("Username is already taken.");
                    registerBtn.disabled = false;
                    return;
                }
    
                // Create user and wait for authentication
                const userCredential = await auth.createUserWithEmailAndPassword(email, password);
                const uid = userCredential.user.uid;
                await new Promise((resolve) => auth.onAuthStateChanged(resolve));
    
                // Save user data
                await db.ref("users/" + uid).set({
                    username: username,
                    lastLogin: Date.now()
                });
    
                sessionStorage.setItem("chatSphereUser", username);
                sessionStorage.setItem("uid", uid);
                authPanel.classList.add("hidden");
                chatPanel.classList.remove("hidden");
                updateOnlineStatus(true);
                loadMessages();
                loadAllUsers();
                loadOnlineUsers();
                showStatus("Welcome, " + username + "!", true);
            } catch (error) {
                console.error("Error registering:", error);
                showStatus("Error registering: " + error.message);
            } finally {
                registerBtn.disabled = false;
            }
        };
    
        // Log in an existing user
        window.handleLogin = async function () {
            const loginBtn = document.getElementById("login-btn");
            loginBtn.disabled = true;
    
            const username = document.getElementById("username").value.trim();
            const password = document.getElementById("password").value;
            const email = `${username.toLowerCase()}@chatsphere.com`;
    
            if (!username || !password) {
                showStatus("Username and password are required.");
                loginBtn.disabled = false;
                return;
            }
    
            try {
                const userCredential = await auth.signInWithEmailAndPassword(email, password);
                const uid = userCredential.user.uid;
                await db.ref("users/" + uid).update({ lastLogin: Date.now() });
    
                sessionStorage.setItem("chatSphereUser", username);
                sessionStorage.setItem("uid", uid);
                authPanel.classList.add("hidden");
                chatPanel.classList.remove("hidden");
                updateOnlineStatus(true);
                loadMessages();
                loadAllUsers();
                loadOnlineUsers();
                showStatus("Logged in as " + username + "!", true);
            } catch (error) {
                console.error("Error logging in:", error);
                showStatus("Invalid username or password.");
            } finally {
                loginBtn.disabled = false;
            }
        };
    
        // Send a public message
        window.handleSendMessage = async function (event) {
            event.preventDefault();
            const username = sessionStorage.getItem("chatSphereUser");
            const content = document.getElementById("chat-input").value.trim();
    
            if (!content || !username) {
                showStatus("Message or username missing.");
                return;
            }
    
            try {
                await db.ref("messages").push({
                    sender: username,
                    content: content,
                    timestamp: firebase.database.ServerValue.TIMESTAMP
                });
                document.getElementById("chat-input").value = "";
                showStatus("Message sent!", true);
            } catch (error) {
                console.error("Error sending message:", error);
                showStatus("Error sending message: " + error.message);
            }
        };
    
        // Log out the user
        window.handleLogout = function () {
            updateOnlineStatus(false);
            auth.signOut()
                .then(() => {
                    sessionStorage.clear();
                    chatPanel.classList.add("hidden");
                    authPanel.classList.remove("hidden");
                    messagesDiv.innerHTML = "";
                    dmMessagesDiv.innerHTML = "";
                    document.getElementById("dm-chat").classList.add("hidden");
                    document.getElementById("public-chat").classList.remove("hidden");
                    showStatus("Logged out successfully.", true);
                    db.ref("messages").off();
                    db.ref("online").off();
                    db.ref("users").off();
                    if (currentDMRecipient) db.ref("dms").off();
                })
                .catch((error) => {
                    console.error("Error logging out:", error);
                    showStatus("Error logging out: " + error.message);
                });
        };
    
        // Check if user is already logged in
        if (sessionStorage.getItem("chatSphereUser") && auth.currentUser) {
            const uid = sessionStorage.getItem("uid");
            db.ref("users/" + uid).once("value", (snapshot) => {
                if (snapshot.exists()) {
                    authPanel.classList.add("hidden");
                    chatPanel.classList.remove("hidden");
                    updateOnlineStatus(true);
                    loadMessages();
                    loadAllUsers();
                    loadOnlineUsers();
                } else {
                    auth.signOut();
                    sessionStorage.clear();
                }
            });
        } else {
            authPanel.classList.remove("hidden");
            chatPanel.classList.add("hidden");
        }
    });