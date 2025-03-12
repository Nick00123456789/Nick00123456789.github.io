// DOM Elements
const authPanel = document.getElementById("auth");
const chatPanel = document.getElementById("chat");
const messagesDiv = document.getElementById("messages");
const statusP = document.getElementById("status");
const messageForm = document.getElementById("message-form");

// Local storage data
const users = JSON.parse(localStorage.getItem("chatSphereUsers")) || {};
const messages = JSON.parse(localStorage.getItem("chatSphereMessages")) || [];

function saveData() {
    localStorage.setItem("chatSphereUsers", JSON.stringify(users));
    localStorage.setItem("chatSphereMessages", JSON.stringify(messages));
}

function showStatus(message, isSuccess = false) {
    statusP.textContent = message;
    statusP.style.color = isSuccess ? "#00ff00" : "#ff4444";
}

function handleRegister() {
    const username = document.getElementById("username").value.trim();
    const password = document.getElementById("password").value;

    if (!username || !password) {
        showStatus("Username and password are required.");
        return;
    }

    if (users[username]) {
        showStatus("Username taken. Try another.");
        return;
    }

    users[username] = { password };
    saveData();
    showStatus("Registered! Now log in.", true);
}

function handleLogin() {
    const username = document.getElementById("username").value.trim();
    const password = document.getElementById("password").value;

    if (!username || !password) {
        showStatus("Username and password are required.");
        return;
    }

    if (!users[username] || users[username].password !== password) {
        showStatus("Wrong username or password.");
        return;
    }

    sessionStorage.setItem("chatSphereUser", username);
    authPanel.classList.add("hidden");
    chatPanel.classList.remove("hidden");
    renderMessages();
}

function handleSendMessage(event) {
    event.preventDefault();
    const username = sessionStorage.getItem("chatSphereUser");
    const message = document.getElementById("chat-input").value.trim();

    if (!message || !username) return;

    const newMessage = { username, message, timestamp: Date.now() };
    messages.push(newMessage);
    saveData();
    appendMessage(newMessage);
    document.getElementById("chat-input").value = "";
}

function appendMessage({ username, message, timestamp }) {
    const msgDiv = document.createElement("div");
    msgDiv.classList.add("message");
    const time = new Date(timestamp).toLocaleTimeString([], { hour: "2-digit", minute: "2-digit" });
    msgDiv.innerHTML = `<span class="user">${username}</span> <span class="time">[${time}]</span>: ${message}`;
    messagesDiv.appendChild(msgDiv);
    messagesDiv.scrollTop = messagesDiv.scrollHeight;
}

function renderMessages() {
    messagesDiv.innerHTML = "";
    messages.forEach(appendMessage);
}

function clearChat() {
    messages.length = 0;
    saveData();
    renderMessages();
}

function handleLogout() {
    sessionStorage.removeItem("chatSphereUser");
    authPanel.classList.remove("hidden");
    chatPanel.classList.add("hidden");
    statusP.textContent = "";
}

// Check if already logged in
if (sessionStorage.getItem("chatSphereUser")) {
    authPanel.classList.add("hidden");
    chatPanel.classList.remove("hidden");
    renderMessages();
}