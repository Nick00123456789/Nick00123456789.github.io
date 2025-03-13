// Replace with your Firebase config from Project Settings
const firebaseConfig = {
    apiKey: "AIzaSyCCKPEreMGbgpP1lmA9uDFADzuNC_0C9gk",
    authDomain: "nickproject.firebaseapp.com",
    databaseURL: "https://nickproject-66789-default-rtdb.europe-west1.firebasedatabase.app/",
    projectId: "chatspherefirebase",
    storageBucket: "chatspherefirebase.appspot.com",
    messagingSenderId: "123456789",
    appId: "1:123456789:web:abcdef123456"
};
firebase.initializeApp(firebaseConfig);
const auth = firebase.auth();
const db = firebase.database();

document.addEventListener("DOMContentLoaded", function() {
    const authPanel = document.getElementById("auth");
    const chatPanel = document.getElementById("chat");
    const messagesDiv = document.getElementById("messages");
    const status = document.getElementById("status");

    function showStatus(message, success = false) {
        status.textContent = message;
        status.style.color = success ? "#00ff00" : "#ff4444";
    }

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
            console.log("User registered and saved:", username);
            showStatus("Registered! Please log in.", true);
            document.getElementById("username").value = "";
            document.getElementById("password").value = "";
        } catch (error) {
            console.error("Register error:", error);
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
        if (password.length < 6) {
            showStatus("Password must be at least 6 characters.");
            return;
        }

        try {
            const userCredential = await auth.signInWithEmailAndPassword(email, password);
            sessionStorage.setItem("chatSphereUser", username);
            sessionStorage.setItem("uid", userCredential.user.uid);
            authPanel.classList.add("hidden");
            chatPanel.classList.remove("hidden");
            loadMessages();
        } catch (error) {
            console.error("Login error:", error);
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
            console.log("Message sent:", content);
            document.getElementById("chat-input").value = "";
            showStatus("Message sent!", true);
        } catch (error) {
            console.error("Send error:", error);
            showStatus("Error sending message: " + error.message);
        }
    };

    function appendMessage(data) {
        const div = document.createElement("div");
        div.classList.add("message");
        const time = new Date(data.val().timestamp).toLocaleTimeString([], { hour: "2-digit", minute: "2-digit" });
        div.innerHTML = `<span class="user">${data.val().sender}</span> <span class="time">[${time}]</span>: ${data.val().content}`;
        messagesDiv.appendChild(div);
        messagesDiv.scrollTop = messagesDiv.scrollHeight;
    }

    function loadMessages() {
        messagesDiv.innerHTML = "";
        console.log("Loading messages...");
        db.ref("messages").orderByChild("timestamp").on("child_added", (snapshot) => {
            console.log("New message:", snapshot.val());
            appendMessage(snapshot);
        }, (error) => {
            console.error("Load error:", error);
            showStatus("Error loading messages: " + error.message);
        });
    }

    window.handleLogout = function() {
        auth.signOut().then(() => {
            sessionStorage.clear();
            chatPanel.classList.add("hidden");
            authPanel.classList.remove("hidden");
            messagesDiv.innerHTML = "";
            showStatus("Logged out successfully.", true);
            db.ref("messages").off();
        }).catch(error => {
            showStatus("Error logging out: " + error.message);
        });
    };

    if (sessionStorage.getItem("chatSphereUser") && auth.currentUser) {
        authPanel.classList.add("hidden");
        chatPanel.classList.remove("hidden");
        loadMessages();
    } else {
        authPanel.classList.remove("hidden");
        chatPanel.classList.add("hidden");
    }
});