// Supabase Config
const SUPABASE_URL = "https://your-project.supabase.co";  // Replace with your Supabase URL
const SUPABASE_ANON_KEY = "your-anon-key";  // Replace with your Supabase Anon Key
const supabase = supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

const chatBox = document.getElementById("chat-box");
const usernameInput = document.getElementById("username");
const messageInput = document.getElementById("message");

// Function to Send Message
async function sendMessage() {
    const username = usernameInput.value.trim() || "Guest";
    const message = messageInput.value.trim();
    
    if (!message) return;

    await supabase.from("messages").insert([{ user: username, message }]);
    messageInput.value = "";
}

// Listen for New Messages in Real-Time
supabase.channel("chat-room")
    .on("postgres_changes", { event: "INSERT", schema: "public", table: "messages" }, payload => {
        displayMessage(payload.new.user, payload.new.message);
    })
    .subscribe();

// Function to Display Messages
function displayMessage(user, msg) {
    const newMessage = document.createElement("p");
    newMessage.textContent = `${user}: ${msg}`;
    chatBox.appendChild(newMessage);
    chatBox.scrollTop = chatBox.scrollHeight;
}

// Load Old Messages
async function loadMessages() {
    const { data } = await supabase.from("messages").select("*").order("timestamp", { ascending: true });
    data.forEach(msg => displayMessage(msg.user, msg.message));
}

// Log Visits
async function logVisit() {
    const username = prompt("Enter your name:") || "Guest";
    await supabase.from("logs").insert([{ user: username }]);
}

window.onload = () => {
    loadMessages();
    logVisit();
};
