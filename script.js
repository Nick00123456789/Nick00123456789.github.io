// DOM Elements
const authScreen = document.getElementById("auth-screen");
const chatScreen = document.getElementById("chat-screen");
const chatBox = document.getElementById("chat-box");
const messageInput = document.getElementById("message");
const authMessage = document.getElementById("auth-message");

// Simulated local storage for users and messages
const users = JSON.parse(localStorage.getItem("users")) || {};
const messages = JSON.parse(localStorage.getItem("messages")) || [];

function saveToLocalStorage() {
    localStorage.setItem("users", JSON.stringify(users));
    localStorage.setItem("messages", JSON.stringify(messages));
}

async function register() {
    const username = document.getElementById("auth-username").value.trim();
    const password = document.getElementById("auth-password").value;

    if (!username || !password) {
        authMessage.textContent = "Please enter a username and password.";
        return;
    }

    if (users[username]) {
        authMessage.textContent = "Username already exists!";
        return;
    }

    users[username] = { password, email: `${username}@chatapp.com` };
    saveToLocalStorage();
    authMessage.textContent = "Registration successful! Please log in.";
    authMessage.style.color = "#00ff00";
}

async function login() {
    const username = document.getElementById("auth-username").value.trim();
    const password = document.getElementById("auth-password").value;

    if (!username || !password) {
        authMessage.textContent = "Please enter both username and password.";
        return;
    }

    if (!users[username] || users[username].password !== password) {
        authMessage.textContent = "Invalid username or password.";
        return;
    }

    sessionStorage.setItem("username", username);
    authScreen.classList.add("hidden");
    chatScreen.classList.remove("hidden");
    loadMessages();
}

async function sendMessage() {
    const username = sessionStorage.getItem("username");
    const message = messageInput.value.trim();

    if (!message || !username) return;

    const newMessage = { username, message, timestamp: new Date().toISOString() };
    messages.push(newMessage);
    saveToLocalStorage();
    displayMessage(username, message);
    messageInput.value = "";
}

function displayMessage(username, msg) {
    const messageElement = document.createElement("div");
    messageElement.classList.add("message");
    messageElement.innerHTML = `<span class="username">${username}</span>: ${msg}`;
    chatBox.appendChild(messageElement);
    chatBox.scrollTop = chatBox.scrollHeight;
}

function loadMessages() {
    chatBox.innerHTML = "";
    messages.forEach(msg => displayMessage(msg.username, msg.message));
}

function logout() {
    sessionStorage.removeItem("username");
    authScreen.classList.remove("hidden");
    chatScreen.classList.add("hidden");
    authMessage.textContent = "";
}

// Initial load
if (sessionStorage.getItem("username")) {
    authScreen.classList.add("hidden");
    chatScreen.classList.remove("hidden");
    loadMessages();
}