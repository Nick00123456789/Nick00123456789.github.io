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
firebase.initializeApp(firebaseConfig);
const auth = firebase.auth();
const db = firebase.database();

let currentDMRecipient = null;

document.addEventListener("DOMContentLoaded", function() {
    const authPanel = document.getElementById("auth");
    const chatPanel = document.getElementById("chat");
    const messagesDiv = document.getElementById("messages");
    const dmMessagesDiv = document.getElementById("dm-messages");
    const status = document.getElementById("status");

    // Utility to show status messages
    function showStatus(message, success = false) {
        status.textContent = message;
        status.style.color = success ? "#00ff00" : "#ff4444";
    }

    // Generate a color based on username
    function stringToColor(str) {
        let hash = 0;
        for (let i = 0; i < str.length; i++) {
            hash = str.charCodeAt(i) + ((hash << 5) - hash);
        }
        const c = (hash & 0x00FFFFFF).toString(16).toUpperCase();
        return "#" + "00000".substring(0, 6 - c.length) + c;
    }

    // Append a message to the specified container
    function appendMessage(data, container) {
        const div = document.createElement("div");
        div.classList.add("message");
        const sender = data.val().sender;
        const time = new Date(data.val().timestamp).toLocaleTimeString([], { hour: "2-digit", minute: "2-digit" });
        const color = stringToColor(sender);
        div.innerHTML = `<span class="user" style="color: ${color}">${sender}</span> <span class="time">[${time}]</span>: ${data.val().content}`;
        container.appendChild(div);
        container.scrollTop = container.scrollHeight;
    }

    // Load public chat messages
    function loadMessages() {
        messagesDiv.innerHTML = "";
        db.ref("messages").orderByChild("timestamp").on("child_added", (snapshot) => {
            appendMessage(snapshot, messagesDiv);
        }, (error) => {
            showStatus("Error loading messages: " + error.message);
        });
    }

    // Load DM messages for the selected user
    function loadDMs(recipient) {
        const uid = sessionStorage.getItem("uid");
        const dmPath = `dms/${uid < recipient.uid ? uid + "_" + recipient.uid : recipient.uid + "_" + uid}`;
        dmMessagesDiv.innerHTML = "";
        db.ref(dmPath).orderByChild("timestamp").on("child_added", (snapshot) => {
            appendMessage(snapshot, dmMessagesDiv);
        }, (error) => {
            showStatus("Error loading DMs: " + error.message);
        });
    }

    // Update user's online status
    function updateOnlineStatus(isOnline) {
        const uid = sessionStorage.getItem("uid");
        if (uid) {
            db.ref("online/" + uid).set(isOnline ? true : null);
        }
    }

    // Display online users
    function loadOnlineUsers() {
        const onlineDiv = document.getElementById("online-users");
        db.ref("online").on("value", (snapshot) => {
            const onlineUsers = snapshot.val() || {};
            const userPromises = Object.keys(onlineUsers).map(uid =>
                db.ref("users/" + uid).once("value").then(userSnap => userSnap.val().username)
            );
            Promise.all(userPromises).then(users => {
                onlineDiv.innerHTML = "<strong>Online: </strong>" + (users.length ? users.join(", ") : "None");
            });
        });
    }

    // Search users and display results
    window.searchUsers = function() {
        const searchInput = document.getElementById("search-input").value.toLowerCase();
        const userList = document.getElementById("user-list");
        userList.innerHTML = "";
        db.ref("users").once("value", (snapshot) => {
            const users = snapshot.val() || {};
            db.ref("online").once("value", (onlineSnapshot) => {
                const online = onlineSnapshot.val() || {};
                for (let uid in users) {
                    const username = users[uid].username;
                    if (username.toLowerCase().includes(searchInput) || searchInput === "") {
                        const isOnline = online[uid] === true;
                        const div = document.createElement("div");
                        div.classList.add("user-item");
                        div.innerHTML = `
                            <span class="status-circle ${isOnline ? 'online' : 'offline'}"></span>
                            <span class="user" style="color: ${stringToColor(username)}">${username}</span>
                        `;
                        div.onclick = () => startDM({ uid, username });
                        userList.appendChild(div);
                    }
                }
            });
        });
    };

    // Start a DM session
    window.startDM = function(recipient) {
        if (recipient.uid === sessionStorage.getItem("uid")) return; // Prevent DMing yourself
        currentDMRecipient = recipient;
        document.getElementById("dm-recipient").textContent = recipient.username;
        document.getElementById("dm-modal").classList.remove("hidden");
        loadDMs(recipient);
    };

    // Close the DM modal
    window.closeDM = function() {
        document.getElementById("dm-modal").classList.add("hidden");
        currentDMRecipient = null;
        dmMessagesDiv.innerHTML = "";
        db.ref("dms").off(); // Stop listening to DM updates
    };

    // Send a DM
    window.handleSendDM = async function(event) {
        event.preventDefault();
        if (!currentDMRecipient) return;
        const username = sessionStorage.getItem("chatSphereUser");
        const content = document.getElementById("dm-input").value.trim();
        const uid = sessionStorage.getItem("uid");
        const dmPath = `dms/${uid < currentDMRecipient.uid ? uid + "_" + currentDMRecipient.uid : currentDMRecipient.uid + "_" + uid}`;

        if (!content || !username) {
            showStatus("Message or username missing.");
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
            showStatus("Error sending DM: " + error.message);
        }
    };

    // Register a new user
    window.handleRegister = async function() {
        const username = document.getElementById("username").value.trim();
        const password = document.getElementById("password").value;
        const email = `${username.toLowerCase()}@chatsphere.com`;

        if (!username || !password) {
            showStatus("Username and password are required.");
            return;
        }
        if (password.length < 6) {
            showStatus("Password must be at least 6 characters.");
            return;
        }

        try {
            const usersSnapshot = await db.ref("users").orderByChild("username").equalTo(username).once("value");
            if (usersSnapshot.exists()) {
                showStatus("Username is already taken.");
                return;
            }

            const userCredential = await auth.createUserWithEmailAndPassword(email, password);
            await db.ref("users/" + userCredential.user.uid).set({ username });
            sessionStorage.setItem("chatSphereUser", username);
            sessionStorage.setItem("uid", userCredential.user.uid);
            authPanel.classList.add("hidden");
            chatPanel.classList.remove("hidden");
            updateOnlineStatus(true);
            loadMessages();
            loadOnlineUsers();
            searchUsers();
            showStatus("Welcome, " + username + "!", true);
        } catch (error) {
            showStatus("Error registering: " + error.message);
        }
    };

    // Log in an existing user
    window.handleLogin = async function() {
        const username = document.getElementById("username").value.trim();
        const password = document.getElementById("password").value;
        const email = `${username.toLowerCase()}@chatsphere.com`;

        if (!username || !password) {
            showStatus("Username and password are required.");
            return;
        }

        try {
            const userCredential = await auth.signInWithEmailAndPassword(email, password);
            sessionStorage.setItem("chatSphereUser", username);
            sessionStorage.setItem("uid", userCredential.user.uid);
            authPanel.classList.add("hidden");
            chatPanel.classList.remove("hidden");
            updateOnlineStatus(true);
            loadMessages();
            loadOnlineUsers();
            searchUsers();
            showStatus("Logged in successfully!", true);
        } catch (error) {
            showStatus("Invalid username or password: " + error.message);
        }
    };

    // Send a public message
    window.handleSendMessage = async function(event) {
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
            showStatus("Error sending message: " + error.message);
        }
    };

    // Log out
    window.handleLogout = function() {
        updateOnlineStatus(false);
        auth.signOut().then(() => {
            sessionStorage.clear();
            chatPanel.classList.add("hidden");
            authPanel.classList.remove("hidden");
            messagesDiv.innerHTML = "";
            dmMessagesDiv.innerHTML = "";
            document.getElementById("dm-modal").classList.add("hidden");
            showStatus("Logged out successfully.", true);
            db.ref("messages").off();
            db.ref("online").off();
            if (currentDMRecipient) db.ref("dms").off();
            currentDMRecipient = null;
        }).catch(error => {
            showStatus("Error logging out: " + error.message);
        });
    };

    // Check if user is already logged in
    if (sessionStorage.getItem("chatSphereUser") && auth.currentUser) {
        authPanel.classList.add("hidden");
        chatPanel.classList.remove("hidden");
        updateOnlineStatus(true);
        loadMessages();
        loadOnlineUsers();
        searchUsers();
    } else {
        authPanel.classList.remove("hidden");
        chatPanel.classList.add("hidden");
    }
});