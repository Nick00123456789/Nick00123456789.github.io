// Initialize Parse with Back4App credentials
Parse.initialize("ghA7Q0akZW8vJPeNE8mTyrqkxXTGmfAiDQQ4qMhu", "QodnHUHSxdzOje3AbwuDyCUSPKIJLq4KX4GXvUZu"); // Replace with your Back4App keys
Parse.serverURL = "https://parseapi.back4app.com/";

document.addEventListener("DOMContentLoaded", function() {
    // DOM Elements
    const authPanel = document.getElementById("auth");
    const chatPanel = document.getElementById("chat");
    const messagesDiv = document.getElementById("messages");
    const status = document.getElementById("status");

    // Status message function
    function showStatus(message, success = false) {
        status.textContent = message;
        status.style.color = success ? "#00ff00" : "#ff4444";
    }

    // Register a new user
    window.handleRegister = async function() {
        const username = document.getElementById("username").value.trim();
        const password = document.getElementById("password").value;

        if (!username || !password) {
            showStatus("Username and password are required.");
            return;
        }

        const user = new Parse.User();
        user.set("username", username);
        user.set("password", password);
        user.set("email", `${username}@chatsphere.com`); // Optional email for Parse compatibility

        try {
            await user.signUp();
            showStatus("Registered! Please log in.", true);
        } catch (error) {
            showStatus("Error registering: " + error.message);
        }
    };

    // Log in an existing user
    window.handleLogin = async function() {
        const username = document.getElementById("username").value.trim();
        const password = document.getElementById("password").value;

        if (!username || !password) {
            showStatus("Username and password are required.");
            return;
        }

        try {
            const user = await Parse.User.logIn(username, password);
            sessionStorage.setItem("chatSphereUser", username);
            authPanel.classList.add("hidden");
            chatPanel.classList.remove("hidden");
            loadMessages();
        } catch (error) {
            showStatus("Invalid username or password.");
        }
    };

    // Send a message
    window.handleSendMessage = async function(event) {
        event.preventDefault();
        const username = sessionStorage.getItem("chatSphereUser");
        const content = document.getElementById("chat-input").value.trim();

        if (!content || !username) return;

        const Message = Parse.Object.extend("Messages");
        const message = new Message();
        message.set("sender", username);
        message.set("content", content);
        message.set("timestamp", new Date());

        try {
            await message.save();
            document.getElementById("chat-input").value = "";
        } catch (error) {
            showStatus("Error sending message: " + error.message);
        }
    };

    // Append a message to the chat
    function appendMessage(data) {
        const div = document.createElement("div");
        div.classList.add("message");
        const time = new Date(data.get("timestamp")).toLocaleTimeString([], { hour: "2-digit", minute: "2-digit" });
        div.innerHTML = `<span class="user">${data.get("sender")}</span> <span class="time">[${time}]</span>: ${data.get("content")}`;
        messagesDiv.appendChild(div);
        messagesDiv.scrollTop = messagesDiv.scrollHeight;
    }

    // Load messages and set up real-time listener
    function loadMessages() {
        messagesDiv.innerHTML = "";
        const Message = Parse.Object.extend("Messages");
        const query = new Parse.Query(Message);
        query.ascending("timestamp");

        // Initial load of existing messages
        query.find().then(results => {
            results.forEach(appendMessage);
        }).catch(error => {
            showStatus("Error loading messages: " + error.message);
        });

        // Real-time updates with Live Query
        const subscription = Parse.LiveQuery.subscribe(query);
        subscription.on("create", appendMessage);
    }

    // Clear all messages
    window.clearChat = async function() {
        const Message = Parse.Object.extend("Messages");
        const query = new Parse.Query(Message);
        try {
            const messages = await query.find();
            await Parse.Object.destroyAll(messages);
            messagesDiv.innerHTML = "";
        } catch (error) {
            showStatus("Error clearing chat: " + error.message);
        }
    };

    // Log out
    window.handleLogout = function() {
        Parse.User.logOut();
        sessionStorage.removeItem("chatSphereUser");
        chatPanel.classList.add("hidden");
        authPanel.classList.remove("hidden");
        showStatus("");
    };

    // Check if already logged in
    if (sessionStorage.getItem("chatSphereUser")) {
        authPanel.classList.add("hidden");
        chatPanel.classList.remove("hidden");
        loadMessages();
    }
});