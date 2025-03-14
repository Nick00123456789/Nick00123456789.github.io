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
const messaging = firebase.messaging();

// DOM Elements
const authContainer = document.getElementById("auth");
const chatContainer = document.getElementById("chat");
const registerBtn = document.getElementById("registerBtn");
const loginBtn = document.getElementById("loginBtn");
const authStatus = document.getElementById("authStatus");
const searchBar = document.getElementById("searchBar");
const searchResults = document.getElementById("searchResults");
const messagesDiv = document.getElementById("messages");
const messageForm = document.getElementById("messageForm");
const messageInput = document.getElementById("messageInput");
const dmWindow = document.getElementById("dmWindow");
const dmRecipient = document.getElementById("dmRecipient");
const dmMessages = document.getElementById("dmMessages");
const dmForm = document.getElementById("dmForm");
const dmInput = document.getElementById("dmInput");
const closeDM = document.getElementById("closeDM");

let currentDMRecipient = null;

// Helper Functions
function showAuthStatus(message, isError = true) {
    authStatus.textContent = message;
    authStatus.style.color = isError ? "red" : "#28a745";
}

function showMessage(message, container, isSent = false) {
    const p = document.createElement("p");
    p.classList.add("message", isSent ? "sent" : "received");
    p.textContent = message;
    container.appendChild(p);
    container.scrollTop = container.scrollHeight;
}

// Registration
registerBtn.addEventListener("click", () => {
    const username = document.getElementById("username").value.trim();
    const email = document.getElementById("email").value.trim();
    const password = document.getElementById("password").value;

    if (!username || !email || !password) {
        showAuthStatus("Please fill in all fields.");
        return;
    }

    auth.createUserWithEmailAndPassword(email, password)
        .then((userCredential) => {
            const user = userCredential.user;
            db.ref("users/" + user.uid).set({
                username: username,
                email: email,
                createdAt: Date.now()
            });
            showAuthStatus("Welcome aboard!", false);
            authContainer.classList.add("hidden");
            chatContainer.classList.remove("hidden");
            setupPresence(user.uid);
        })
        .catch((error) => {
            showAuthStatus(error.message);
        });
});

// Login
loginBtn.addEventListener("click", () => {
    const email = document.getElementById("email").value.trim();
    const password = document.getElementById("password").value;

    if (!email || !password) {
        showAuthStatus("Email and password required.");
        return;
    }

    auth.signInWithEmailAndPassword(email, password)
        .then((userCredential) => {
            const user = userCredential.user;
            showAuthStatus("Logged in successfully!", false);
            authContainer.classList.add("hidden");
            chatContainer.classList.remove("hidden");
            setupPresence(user.uid);
        })
        .catch((error) => {
            showAuthStatus(error.message);
        });
});

// User Search with Debouncing
let searchTimeout;
searchBar.addEventListener("input", (e) => {
    clearTimeout(searchTimeout);
    searchTimeout = setTimeout(() => {
        const query = e.target.value.toLowerCase();
        searchResults.innerHTML = "";
        if (query.length > 0) {
            const usersRef = db.ref("users");
            usersRef.once("value", (snapshot) => {
                snapshot.forEach((childSnapshot) => {
                    const user = childSnapshot.val();
                    const uid = childSnapshot.key;
                    if (user.username.toLowerCase().includes(query) && uid !== auth.currentUser.uid) {
                        const li = document.createElement("li");
                        li.textContent = user.username;
                        li.classList.add(checkOnlineStatus(uid) ? "online" : "offline");
                        li.addEventListener("click", () => startDM({ ...user, uid }));
                        searchResults.appendChild(li);
                    }
                });
            });
        }
    }, 300); // Debounce delay
});

// Check Online Status
function checkOnlineStatus(uid) {
    let isOnline = false;
    db.ref("presence/" + uid).once("value", (snap) => {
        const data = snap.val();
        isOnline = data && data.status === "online";
    });
    return isOnline;
}

// Setup Presence
function setupPresence(uid) {
    const presenceRef = db.ref("presence/" + uid);
    const connectedRef = db.ref(".info/connected");

    connectedRef.on("value", (snap) => {
        if (snap.val() === true) {
            presenceRef.set({ status: "online", lastSeen: Date.now() });
            presenceRef.onDisconnect().set({ status: "offline", lastSeen: Date.now() });
        }
    });
}

// Start DM
function startDM(recipient) {
    currentDMRecipient = recipient;
    dmRecipient.textContent = recipient.username;
    dmWindow.classList.remove("hidden");
    dmMessages.innerHTML = "";
    loadDMs(recipient);
}

// Load DMs
function loadDMs(recipient) {
    const fromUid = auth.currentUser.uid;
    const convoId = [fromUid, recipient.uid].sort().join("_");
    const messagesRef = db.ref(`dms/${convoId}/messages`);
    messagesRef.on("child_added", (snapshot) => {
        const msg = snapshot.val();
        const isSent = msg.sender === fromUid;
        showMessage(`${isSent ? "You" : recipient.username}: ${msg.content}`, dmMessages, isSent);
    });
}

// Send DM
dmForm.addEventListener("submit", (e) => {
    e.preventDefault();
    const message = dmInput.value.trim();
    if (message && currentDMRecipient) {
        const fromUid = auth.currentUser.uid;
        const convoId = [fromUid, currentDMRecipient.uid].sort().join("_");
        const msgRef = db.ref(`dms/${convoId}/messages`).push();
        msgRef.set({
            sender: fromUid,
            content: message,
            timestamp: Date.now()
        });
        dmInput.value = "";
    }
});

// Close DM Window
closeDM.addEventListener("click", () => {
    dmWindow.classList.add("hidden");
    currentDMRecipient = null;
});

// Send Public Message
messageForm.addEventListener("submit", (e) => {
    e.preventDefault();
    const message = messageInput.value.trim();
    if (message) {
        const msgRef = db.ref("messages").push();
        msgRef.set({
            sender: auth.currentUser.uid,
            content: message,
            timestamp: Date.now()
        });
        messageInput.value = "";
    }
});

// Load Public Messages
db.ref("messages").on("child_added", (snapshot) => {
    const msg = snapshot.val();
    db.ref("users/" + msg.sender).once("value", (snap) => {
        const sender = snap.val().username;
        showMessage(`${sender}: ${msg.content}`, messagesDiv, msg.sender === auth.currentUser.uid);
    });
});

// Notifications Setup (Replace VAPID key)
messaging.getToken({ vapidKey: "YOUR_VAPID_KEY" }).then((token) => {
    if (auth.currentUser) {
        db.ref("users/" + auth.currentUser.uid + "/fcmToken").set(token);
    }
}).catch((err) => console.error("FCM Token Error:", err));

messaging.onMessage((payload) => {
    const notification = new Notification(payload.notification.title, {
        body: payload.notification.body,
        icon: "/icon.png"
    });
});