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
let currentGroup = null;

// DOM Elements
const authPanel = document.getElementById("auth");
const chatPanel = document.getElementById("chat");
const registerBtn = document.getElementById("registerBtn");
const loginBtn = document.getElementById("loginBtn");
const logoutBtn = document.getElementById("logoutBtn");
const messageForm = document.getElementById("messageForm");
const dmForm = document.getElementById("dmForm");
const groupForm = document.getElementById("groupForm");
const searchBar = document.getElementById("searchBar");
const searchResults = document.getElementById("searchResults");
const createGroupBtn = document.getElementById("createGroupBtn");
const messagesDiv = document.getElementById("messages");
const dmMessagesDiv = document.getElementById("dmMessages");
const groupMessagesDiv = document.getElementById("groupMessages");
const dmWindow = document.getElementById("dmWindow");
const groupWindow = document.getElementById("groupWindow");
const dmRecipientSpan = document.getElementById("dmRecipient");
const groupNameSpan = document.getElementById("groupName");
const closeDMBtn = document.getElementById("closeDM");
const closeGroupBtn = document.getElementById("closeGroup");
const authStatus = document.getElementById("authStatus");

// Show status messages
function showStatus(message, success = false) {
    authStatus.textContent = message;
    authStatus.style.color = success ? "#0f0" : "#f00";
}

// Register user
registerBtn.onclick = async () => {
    const username = document.getElementById("username").value.trim();
    const password = document.getElementById("password").value;
    const fakeEmail = `${username.toLowerCase()}@chatsphere.com`;

    if (!username || !password) {
        showStatus("Username and password required.");
        return;
    }

    try {
        const userCredential = await auth.createUserWithEmailAndPassword(fakeEmail, password);
        const uid = userCredential.user.uid;
        await db.ref("users/" + uid).set({ username });
        sessionStorage.setItem("uid", uid);
        sessionStorage.setItem("username", username);
        authPanel.classList.add("hidden");
        chatPanel.classList.remove("hidden");
        loadMessages();
        setupSearch();
        showStatus("Registered successfully!", true);
    } catch (error) {
        showStatus("Error: " + error.message);
    }
};

// Login user
loginBtn.onclick = async () => {
    const username = document.getElementById("username").value.trim();
    const password = document.getElementById("password").value;
    const fakeEmail = `${username.toLowerCase()}@chatsphere.com`;

    if (!username || !password) {
        showStatus("Username and password required.");
        return;
    }

    try {
        const userCredential = await auth.signInWithEmailAndPassword(fakeEmail, password);
        const uid = userCredential.user.uid;
        sessionStorage.setItem("uid", uid);
        sessionStorage.setItem("username", username);
        authPanel.classList.add("hidden");
        chatPanel.classList.remove("hidden");
        loadMessages();
        setupSearch();
        showStatus("Logged in successfully!", true);
    } catch (error) {
        showStatus("Error: " + error.message);
    }
};

// Logout user
logoutBtn.onclick = () => {
    auth.signOut().then(() => {
        sessionStorage.clear();
        authPanel.classList.remove("hidden");
        chatPanel.classList.add("hidden");
        messagesDiv.innerHTML = "";
        dmMessagesDiv.innerHTML = "";
        groupMessagesDiv.innerHTML = "";
        dmWindow.classList.add("hidden");
        groupWindow.classList.add("hidden");
        showStatus("Logged out.", true);
    }).catch((error) => {
        showStatus("Logout error: " + error.message);
    });
};

// Load public messages
function loadMessages() {
    db.ref("messages").on("child_added", (snapshot) => {
        const data = snapshot.val();
        const div = document.createElement("div");
        div.className = `message ${data.sender === sessionStorage.getItem("username") ? "sent" : "received"}`;
        div.textContent = `${data.sender}: ${data.content}`;
        messagesDiv.appendChild(div);
        messagesDiv.scrollTop = messagesDiv.scrollHeight;
    });
}

// Send public message
messageForm.onsubmit = async (e) => {
    e.preventDefault();
    const content = document.getElementById("messageInput").value.trim();
    const username = sessionStorage.getItem("username");

    if (content) {
        await db.ref("messages").push({
            sender: username,
            content,
            timestamp: Date.now()
        });
        document.getElementById("messageInput").value = "";
    }
};

// Setup user search
function setupSearch() {
    db.ref("users").on("value", (snapshot) => {
        const users = snapshot.val() || {};
        searchBar.oninput = () => {
            const query = searchBar.value.trim().toLowerCase();
            searchResults.innerHTML = "";
            if (query) {
                for (let uid in users) {
                    const username = users[uid].username;
                    if (username.toLowerCase().includes(query) && uid !== sessionStorage.getItem("uid")) {
                        const li = document.createElement("li");
                        li.textContent = username;
                        li.onclick = () => startDM(uid, username);
                        searchResults.appendChild(li);
                    }
                }
            }
        };
    }, (error) => {
        console.error("Search error:", error);
        showStatus("Failed to load users.");
    });
}

// Start DM
function startDM(recipientUid, recipientUsername) {
    currentDMRecipient = { uid: recipientUid, username: recipientUsername };
    dmRecipientSpan.textContent = recipientUsername;
    dmWindow.classList.remove("hidden");
    groupWindow.classList.add("hidden"); // Ensure only one window is open
    dmMessagesDiv.innerHTML = "";
    const conversationId = [sessionStorage.getItem("uid"), recipientUid].sort().join("_");
    db.ref(`dms/${conversationId}`).on("child_added", (snapshot) => {
        const data = snapshot.val();
        const div = document.createElement("div");
        div.className = `message ${data.sender === sessionStorage.getItem("username") ? "sent" : "received"}`;
        div.textContent = `${data.sender}: ${data.content}`;
        dmMessagesDiv.appendChild(div);
        dmMessagesDiv.scrollTop = dmMessagesDiv.scrollHeight;
    });
}

// Send DM
dmForm.onsubmit = async (e) => {
    e.preventDefault();
    const content = document.getElementById("dmInput").value.trim();
    const username = sessionStorage.getItem("username");
    const uid = sessionStorage.getItem("uid");

    if (content && currentDMRecipient) {
        const conversationId = [uid, currentDMRecipient.uid].sort().join("_");
        await db.ref(`dms/${conversationId}`).push({
            sender: username,
            content,
            timestamp: Date.now()
        });
        document.getElementById("dmInput").value = "";
    }
};

// Close DM
closeDMBtn.onclick = () => {
    dmWindow.classList.add("hidden");
    currentDMRecipient = null;
    db.ref("dms").off();
};

// Create group chat
createGroupBtn.onclick = () => {
    const groupName = prompt("Enter group name:");
    if (groupName) {
        const uid = sessionStorage.getItem("uid");
        const groupId = db.ref("groups").push().key;
        const groupData = {
            name: groupName,
            members: { [uid]: true }
        };
        db.ref(`groups/${groupId}`).set(groupData).then(() => {
            startGroup(groupId, groupName);
        }).catch((error) => {
            showStatus("Error creating group: " + error.message);
        });
    }
};

// Start group chat
function startGroup(groupId, groupName) {
    currentGroup = { id: groupId, name: groupName };
    groupNameSpan.textContent = groupName;
    groupWindow.classList.remove("hidden");
    dmWindow.classList.add("hidden"); // Ensure only one window is open
    groupMessagesDiv.innerHTML = "";
    db.ref(`groups/${groupId}/messages`).on("child_added", (snapshot) => {
        const data = snapshot.val();
        const div = document.createElement("div");
        div.className = `message ${data.sender === sessionStorage.getItem("username") ? "sent" : "received"}`;
        div.textContent = `${data.sender}: ${data.content}`;
        groupMessagesDiv.appendChild(div);
        groupMessagesDiv.scrollTop = groupMessagesDiv.scrollHeight;
    });
}

// Send group message
groupForm.onsubmit = async (e) => {
    e.preventDefault();
    const content = document.getElementById("groupInput").value.trim();
    const username = sessionStorage.getItem("username");

    if (content && currentGroup) {
        await db.ref(`groups/${currentGroup.id}/messages`).push({
            sender: username,
            content,
            timestamp: Date.now()
        });
        document.getElementById("groupInput").value = "";
    }
};

// Close group chat
closeGroupBtn.onclick = () => {
    groupWindow.classList.add("hidden");
    currentGroup = null;
    db.ref("groups").off();
};

// Check login state
auth.onAuthStateChanged((user) => {
    if (user && sessionStorage.getItem("uid") === user.uid) {
        authPanel.classList.add("hidden");
        chatPanel.classList.remove("hidden");
        loadMessages();
        setupSearch();
    } else {
        authPanel.classList.remove("hidden");
        chatPanel.classList.add("hidden");
    }
});