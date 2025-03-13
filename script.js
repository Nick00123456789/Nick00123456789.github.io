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
let allUsers = {};
let onlineUsers = {};

// Debounce function for search
function debounce(func, wait) {
    let timeout;
    return function(...args) {
        clearTimeout(timeout);
        timeout = setTimeout(() => func.apply(this, args), wait);
    };
}

document.addEventListener("DOMContentLoaded", function() {
    const authPanel = document.getElementById("auth");
    const chatPanel = document.getElementById("chat");
    const messagesDiv = document.getElementById("messages");
    const dmMessagesDiv = document.getElementById("dm-messages");
    const status = document.getElementById("status");

    function showStatus(message, success = false) {
        status.textContent = message;
        status.style.color = success ? "#00ff00" : "#ff4444";
    }

    function appendMessage(data, container, isDM = false) {
        const div = document.createElement("div");
        div.classList.add("message");
        const sender = data.val().sender;
        const time = new Date(data.val().timestamp).toLocaleTimeString([], { hour: "2-digit", minute: "2-digit" });
        const isOnline = onlineUsers[sender] ? 'online' : 'offline';
        div.innerHTML = `
            <span class="status-circle ${isOnline}"></span>
            <span class="user">${sender}</span>
            <span class="time">[${time}]</span>: ${data.val().content}
        `;
        container.appendChild(div);
        container.scrollTop = container.scrollHeight;
    }

    function loadMessages() {
        messagesDiv.innerHTML = "";
        db.ref("messages").orderByChild("timestamp").on("child_added", (snapshot) => {
            appendMessage(snapshot, messagesDiv);
        });
    }

    function loadDMs(recipient) {
        const uid = sessionStorage.getItem("uid");
        const dmPath = `dms/${uid < recipient.uid ? uid + "_" + recipient.uid : recipient.uid + "_" + uid}`;
        dmMessagesDiv.innerHTML = "";
        db.ref(dmPath).orderByChild("timestamp").on("child_added", (snapshot) => {
            appendMessage(snapshot, dmMessagesDiv, true);
        });
    }

    function updateOnlineStatus(isOnline) {
        const uid = sessionStorage.getItem("uid");
        if (uid) {
            db.ref("online/" + uid).set(isOnline ? true : null);
        }
    }

    function loadAllUsers() {
        db.ref("users").once("value", (snapshot) => {
            allUsers = snapshot.val() || {};
            searchUsers();
        });
    }

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
        });
    }

    window.searchUsers = debounce(function() {
        const searchInput = document.getElementById("search-input").value.toLowerCase();
        const userList = document.getElementById("user-list");
        userList.innerHTML = "";
        for (let uid in allUsers) {
            const username = allUsers[uid].username;
            if (username.toLowerCase().includes(searchInput) || searchInput === "") {
                const isOnline = onlineUsers[username] ? 'online' : 'offline';
                const div = document.createElement("div");
                div.classList.add("user-item");
                div.innerHTML = `
                    <span class="status-circle ${isOnline}"></span>
                    <span class="user">${username}</span>
                `;
                div.onclick = () => startDM({ uid, username });
                userList.appendChild(div);
            }
        }
    }, 300);

    window.startDM = function(recipient) {
        if (recipient.uid === sessionStorage.getItem("uid")) return;
        currentDMRecipient = recipient;
        document.getElementById("dm-recipient").textContent = recipient.username;
        document.getElementById("public-chat").classList.add("hidden");
        document.getElementById("dm-chat").classList.remove("hidden");
        loadDMs(recipient);
    };

    window.closeDM = function() {
        document.getElementById("public-chat").classList.remove("hidden");
        document.getElementById("dm-chat").classList.add("hidden");
        currentDMRecipient = null;
        dmMessagesDiv.innerHTML = "";
        db.ref("dms").off();
    };

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
            loadAllUsers();
            loadOnlineUsers();
            showStatus("Welcome, " + username + "!", true);
        } catch (error) {
            showStatus("Error registering: " + error.message);
        }
    };

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
            loadAllUsers();
            loadOnlineUsers();
        } catch (error) {
            showStatus("Invalid username or password: " + error.message);
        }
    };

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

    window.handleLogout = function() {
        updateOnlineStatus(false);
        auth.signOut().then(() => {
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
            if (currentDMRecipient) db.ref("dms").off();
            currentDMRecipient = null;
        }).catch(error => {
            showStatus("Error logging out: " + error.message);
        });
    };

    if (sessionStorage.getItem("chatSphereUser") && auth.currentUser) {
        authPanel.classList.add("hidden");
        chatPanel.classList.remove("hidden");
        updateOnlineStatus(true);
        loadMessages();
        loadAllUsers();
        loadOnlineUsers();
    } else {
        authPanel.classList.remove("hidden");
        chatPanel.classList.add("hidden");
    }
});