const form = document.getElementById('loginForm');
const loginAreaLogin = document.getElementById('login_area');
const gameAreaLogin  = document.getElementById('game_area');

const loginToken = localStorage.getItem('token');

/* Αν υπάρχει token → κρύβουμε login */
if (loginToken) {
    loginAreaLogin.style.display = 'none';
    gameAreaLogin.style.display = 'block';
}

/* Login submit */
form.onsubmit = e => {
    e.preventDefault();

    const username  = form.username.value;
    const playerId = form.player_id.value; // P1 ή P2

    $.ajax({
        url: 'api/login.php',
        method: 'POST',
        contentType: 'application/json',
        dataType: 'json',
        data: JSON.stringify({
            username: username,
            player_id: playerId
        }),
        success: function (res) {
            if (res.error) {
                alert(res.error);
                return;
            }

            localStorage.setItem('token', res.token);
            location.reload();
        },
        error: function () {
            alert('Σφάλμα σύνδεσης με τον server');
        }
    });
};