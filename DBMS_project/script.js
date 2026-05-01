const API = "http://localhost:5000";

function register() {
  fetch(`${API}/users/register`, {
    method: "POST",
    headers: {"Content-Type": "application/json"},
    body: JSON.stringify({
      name: document.getElementById("name").value,
      email: document.getElementById("email").value,
      password: document.getElementById("password").value,
      role: document.getElementById("role").value
    })
  }).then(res => res.text()).then(alert);
}

function addProject() {
  fetch(`${API}/projects/add`, {
    method: "POST",
    headers: {"Content-Type": "application/json"},
    body: JSON.stringify({
      client_id: 1,
      title: document.getElementById("title").value,
      budget: document.getElementById("budget").value,
      deadline: document.getElementById("deadline").value
    })
  }).then(res => res.text()).then(alert);
}