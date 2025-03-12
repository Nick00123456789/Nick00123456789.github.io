       
        const supabase = createClient('https://kigbtbacxkfeevmyvioa.supabase.co', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtpZ2J0YmFjeGtmZWV2bXl2aW9hIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDE3MTgyNzQsImV4cCI6MjA1NzI5NDI3NH0.OqMLrZ2NzZ6CMNaZcKKHBA7V1PTQfy7g5MKv8XT1-N4');


        const authScreen = document.getElementById("auth-screen");
        const chatScreen = document.getElementById("chat-screen");
        const chatBox = document.getElementById("chat-box");
        const messageInput = document.getElementById("message");

        async function register() {
            const username = document.getElementById("auth-username").value;
            const password = document.getElementById("auth-password").value;

            if (!username || !password) {
                alert("Please enter a username and password.");
                return;
            }

            const { data, error } = await supabase.auth.signUp({
                email: `${username}@chatapp.com`,
                password: password
            });

            if (error) {
                alert("Registration failed: " + error.message);
            } else {
                alert("Registration successful! Please log in.");
            }
        }

        async function login() {
            const username = document.getElementById("auth-username").value;
            const password = document.getElementById("auth-password").value;

            if (!username || !password) {
                alert("Please enter both username and password.");
                return;
            }

            const { data, error } = await supabase.auth.signInWithPassword({
                email: `${username}@chatapp.com`,
                password: password
            });

            if (error) {
                alert("Invalid login. Please try again.");
            } else {
                sessionStorage.setItem("username", username);
                authScreen.classList.add("hidden");
                chatScreen.classList.remove("hidden");
                loadMessages();
            }
        }

        async function sendMessage() {
            const username = sessionStorage.getItem("username");
            const message = messageInput.value.trim();
            if (!message) return;

            await supabase.from("messages").insert([{ username, message }]);
            messageInput.value = "";
        }

        supabase.channel("chat-room")
            .on("postgres_changes", { event: "INSERT", schema: "public", table: "messages" }, payload => {
                displayMessage(payload.new.username, payload.new.message);
            })
            .subscribe();

        function displayMessage(username, msg) {
            const newMessage = document.createElement("p");
            newMessage.textContent = `${username}: ${msg}`;
            chatBox.appendChild(newMessage);
            chatBox.scrollTop = chatBox.scrollHeight;
        }

        async function loadMessages() {
            const { data } = await supabase.from("messages").select("*").order("timestamp", { ascending: true });
            data.forEach(msg => displayMessage(msg.username, msg.message));
        }

        function logout() {
            sessionStorage.removeItem("username");
            authScreen.classList.remove("hidden");
            chatScreen.classList.add("hidden");
        }
