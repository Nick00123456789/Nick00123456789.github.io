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

        if (!username || !password) {
            showStatus("Username and password are required.");
            return;
        }

        // Map username to a fake email for Firebase
        const email = `${username.toLowerCase()}@chatsphere.com`;

        try {
            const userCredential = await auth.createUserWithEmailAndPassword(email, password);
            await db.ref("users/" + userCredential.user.uid).set({ username });
            showStatus("Registered! Please log in.", true);
            document.getElementById("username").value = "";
            document.getElementById("password").value = "";
        } catch (error) {
            showStatus("Error registering: " + error.message);
        }
    };

    window.handleLogin = async function() {
        const username = document.getElementById("username").value.trim();
        const password = document.getElementById("password").value;

        if (!username || !password) {
            showStatus("Username and password are required.");
            return;
        }

        // Map username to the same fake email
        const email = `${username.toLowerCase()}@chatsphere.com`;

        try {
            const userCredential = await auth.signInWithEmailAndPassword(email, password);
            sessionStorage.setItem("chatSphereUser", username);
            sessionStorage.setItem("uid", userCredential.user.uid);
            authPanel.classList.add("hidden");
            chatPanel.classList.remove("hidden");
            loadMessages();
        } catch (error) {
            showStatus("Invalid username or password: " + error.message);
        }
    };

    window.handleSendMessage = async function(event) {
        event.preventDefault();
        const username = sessionStorage.getItem("chatSphereUser");
        const content = document.getElementById("chat-input").value.trim();

        if (!content || !username) return;

        try {
            await db.ref("messages").push({
                sender: username,
                content: content,
                timestamp: firebase.database.ServerValue.TIMESTAMP
            });
            document.getElementById("chat-input").value = "";
        } catch (error) {
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
        db.ref("messages").orderByChild("timestamp").on("child_added", (snapshot) => {
            appendMessage(snapshot);
        }, (error) => {
            showStatus("Error loading messages: " + error.message);
        });
    }

    window.clearChat = async function() {
        try {
            await db.ref("messages").remove();
            messagesDiv.innerHTML = "";
        } catch (error) {
            showStatus("Error clearing chat: " + error.message);
        }
    };

    window.handleLogout = function() {
        auth.signOut().then(() => {
            sessionStorage.removeItem("chatSphereUser");
            sessionStorage.removeItem("uid");
            chatPanel.classList.add("hidden");
            authPanel.classList.remove("hidden");
            showStatus("");
        }).catch(error => {
            showStatus("Error logging out: " + error.message);
        });
    };

    if (sessionStorage.getItem("chatSphereUser")) {
        authPanel.classList.add("hidden");
        chatPanel.classList.remove("hidden");
        loadMessages();
    }
});