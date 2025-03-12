const SUPABASE_URL = "your-supabase-url";
const SUPABASE_ANON_KEY = "your-supabase-anon-key";
const supabase = supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

const loginScreen = document.getElementById("login-screen");
const chatScreen = document.getElementById("chat-screen");
const chatBox = document.getElementById("chat-box");
const messageInput = document.getElementById("message");

async function login() {
    const username = document.getElementById("login-username").value;
    const password = document.getElementById("login-password").value;

    if (!username || !password) {
        alert("Please enter both username and password.");
        return;
    }

    let { data: user, error } = await supabase.auth.signInWithPassword({
        email: `${username}@chatapp.com`,
        password: password
    });

    if (error) {
        alert("Invalid login. Please try again.");
    } else {
        sessionStorage.setItem("user", username);
        loginScreen.classList.add("hidden");
        chatScreen.classList.remove("hidden");
        loadMessages();
    }
}

async function sendMessage() {
    const username = sessionStorage.getItem("user");
    const message = messageInput.value.trim();
    if (!message) return;

    await supabase.from("messages").insert([{ user: username, message }]);
    messageInput.value = "";
}

supabase.channel("chat-room")
    .on("postgres_changes", { event: "INSERT", schema: "public", table: "messages" }, payload => {
        displayMessage(payload.new.user, payload.new.message);
    })
    .subscribe();

function displayMessage(user, msg) {
    const newMessage = document.createElement("p");
    newMessage.textContent = `${user}: ${msg}`;
    chatBox.appendChild(newMessage);
    chatBox.scrollTop = chatBox.scrollHeight;
}

async function loadMessages() {
    const { data } = await supabase.from("messages").select("*").order("timestamp", { ascending: true });
    data.forEach(msg => displayMessage(msg.user, msg.message));
}

function logout() {
    sessionStorage.removeItem("user");
    loginScreen.classList.remove("hidden");
    chatScreen.classList.add("hidden");
}