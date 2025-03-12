// Wait for DOM and Supabase to load
document.addEventListener("DOMContentLoaded", function() {
    // Check if Supabase is loaded
    if (typeof Supabase === "undefined") {
        console.error("Supabase library failed to load.");
        document.getElementById("status").textContent = "Error: Supabase not available. Check console.";
        return;
    }

    // Initialize Supabase Client
    const supabaseUrl = 'https://cwwjxeolppxftmiyfxjw.supabase.co'; // Replace with your Supabase Project URL
    const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImN3d2p4ZW9scHB4ZnRtaXlmeGp3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDE3OTkyMzIsImV4cCI6MjA1NzM3NTIzMn0.SxY84BSFT1uezMtXtbiEBF_Mrvm_HKT8rvwGMrvXZmc'; // Replace with your Supabase Anon Key
    const supabase = Supabase.createClient(supabaseUrl, supabaseKey);

    // DOM Elements
    const authPanel = document.getElementById("auth");
    const chatPanel = document.getElementById("chat");
    const messagesDiv = document.getElementById("messages");
    const statusP = document.getElementById("status");
    const messageForm = document.getElementById("message-form");

    // Show status messages
    function showStatus(message, isSuccess = false) {
        statusP.textContent = message;
        statusP.style.color = isSuccess ? "#00ff00" : "#ff4444";
    }

    // Register a new user
    async function handleRegister() {
        const username = document.getElementById("username").value.trim();
        const password = document.getElementById("password").value;

        if (!username || !password) {
            showStatus("Username and password are required.");
            return;
        }

        try {
            const { data, error } = await supabase
                .from("users")
                .select("username")
                .eq("username", username);

            if (error) throw error;
            if (data.length > 0) {
                showStatus("Username already taken.");
                return;
            }

            const { error: insertError } = await supabase
                .from("users")
                .insert([{ username, password }]);

            if (insertError) throw insertError;
            showStatus("Registered! Please log in.", true);
        } catch (error) {
            showStatus("Error registering: " + error.message);
        }
    }

    // Log in an existing user
    async function handleLogin() {
        const username = document.getElementById("username").value.trim();
        const password = document.getElementById("password").value;

        if (!username || !password) {
            showStatus("Username and password are required.");
            return;
        }

        try {
            const { data, error } = await supabase
                .from("users")
                .select("*")
                .eq("username", username)
                .single();

            if (error) throw error;
            if (!data || data.password !== password) {
                showStatus("Invalid username or password.");
                return;
            }

            sessionStorage.setItem("chatSphereUser", username);
            authPanel.classList.add("hidden");
            chatPanel.classList.remove("hidden");
            loadMessages();
        } catch (error) {
            showStatus("Error logging in: " + error.message);
        }
    }

    // Send a message
    async function handleSendMessage(event) {
        event.preventDefault();
        const username = sessionStorage.getItem("chatSphereUser");
        const message = document.getElementById("chat-input").value.trim();

        if (!message || !username) return;

        try {
            const { error } = await supabase
                .from("messages")
                .insert([{ username, message, timestamp: Date.now() }]);

            if (error) throw error;
            document.getElementById("chat-input").value = "";
        } catch (error) {
            showStatus("Error sending message: " + error.message);
        }
    }

    // Append a message to the chat
    function appendMessage({ username, message, timestamp }) {
        const msgDiv = document.createElement("div");
        msgDiv.classList.add("message");
        const time = new Date(timestamp).toLocaleTimeString([], { hour: "2-digit", minute: "2-digit" });
        msgDiv.innerHTML = `<span class="user">${username}</span> <span class="time">[${time}]</span>: ${message}`;
        messagesDiv.appendChild(msgDiv);
        messagesDiv.scrollTop = messagesDiv.scrollHeight;
    }

    // Load messages and set up real-time listener
    function loadMessages() {
        messagesDiv.innerHTML = "";
        supabase
            .from("messages")
            .select("*")
            .order("timestamp", { ascending: true })
            .then(({ data, error }) => {
                if (error) {
                    showStatus("Error loading messages: " + error.message);
                } else {
                    data.forEach(appendMessage);
                }
            });

        supabase
            .channel("public:messages")
            .on("postgres_changes", { event: "INSERT", schema: "public", table: "messages" }, payload => {
                appendMessage(payload.new);
            })
            .subscribe();
    }

    // Clear all messages
    async function clearChat() {
        try {
            const { error } = await supabase
                .from("messages")
                .delete()
                .gte("id", 0);

            if (error) throw error;
            messagesDiv.innerHTML = "";
        } catch (error) {
            showStatus("Error clearing chat: " + error.message);
        }
    }

    // Log out
    function handleLogout() {
        sessionStorage.removeItem("chatSphereUser");
        authPanel.classList.remove("hidden");
        chatPanel.classList.add("hidden");
        statusP.textContent = "";
        supabase.channel("public:messages").unsubscribe();
    }

    // Check if already logged in
    if (sessionStorage.getItem("chatSphereUser")) {
        authPanel.classList.add("hidden");
        chatPanel.classList.remove("hidden");
        loadMessages();
    }

    // Expose functions globally
    window.handleRegister = handleRegister;
    window.handleLogin = handleLogin;
    window.handleSendMessage = handleSendMessage;
    window.clearChat = clearChat;
    window.handleLogout = handleLogout;
});