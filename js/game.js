let currentTurn = null;
let gameInterval = null;
let lastShownEvent = null;
let gameEndedShown = false;

const CARD_IMG_PATH = 'images/';
const token = localStorage.getItem('token');

const loginArea  = document.getElementById('login_area');
const gameArea   = document.getElementById('game_area');
const waitingMsg = document.getElementById('waiting_msg');

/*  Init */
if (!token) {
    console.warn('No token – waiting for login');
} else {
    loginArea.style.display = 'none';
    gameArea.style.display  = 'block';
    startPolling();
}


/* Polling control */
function startPolling() {
    loadGame();
    if (gameInterval) clearInterval(gameInterval);
    gameInterval = setInterval(loadGame, 1500);
}

function stopPolling() {
    if (gameInterval) {
        clearInterval(gameInterval);
        gameInterval = null;
    }
}

/*  Load game */
function loadGame() {
    $.ajax({
        url: 'api/game.php',
        method: 'GET',
        dataType: 'json',
        headers: { 'X-TOKEN': token },
        success: function (data) {

            if (data.error) {
                console.error(data.error);
                return;
            }

        if (data.idle !== null) {
            console.log('IDLE (sec):', data.idle);
        }
         // εμφάνιση παίκτη στη σελίδα
        document.getElementById('current_player').innerText = data.me;
 
        /* WAITING FOR PLAYER */
         if (data.status === 'not active') {
            waitingMsg.style.display = 'block';
            document.getElementById('status').innerText = 'not active';
                updateTable([]);
                updateHand([], data);
                updateCaptured([]);
                return;
        }

            waitingMsg.style.display = 'none';

            updateGameInfo(data);
            handleLastEvent(data.last_event);
            updateScore(data);
            updateTable(data.table);
            updateHand(data.hand, data);
            updateCaptured(data.captured);
            handleGameEnd(data);
        },
        error: function (err) {
            console.error('Game load failed:', err);
        }
    });
}


// Game info (turn, status, messages)
function updateGameInfo(data) {
    currentTurn = data.p_turn;

    document.getElementById('turn').innerText = data.p_turn ?? '-';

    if (data.status === 'started') {
            gameEndedShown = false;
            document.getElementById('restart_btn')?.remove();
            document.getElementById('message').innerText = '';
            document.getElementById("p1_score");
            document.getElementById("p2_score");
        }
    

    document.getElementById('status').innerText =
        data.status === 'aborted' ? 'ABORTED' : data.status;

         // ΑΝ ΞΕΚΙΝΗΣΕ ΠΑΙΧΝΙΔΙ → σβήσε restart
    if (data.status === 'started') {
        gameEndedShown = false;
        document.getElementById('restart_btn')?.remove();
    }
}


// Score
function updateScore(data) {
    document.getElementById('p1_score').innerText = data.p1_score ?? 0;
    document.getElementById('p2_score').innerText = data.p2_score ?? 0;
}

/* Card image */
function createCardImg(card) {
    const img = document.createElement('img');
    img.src = `${CARD_IMG_PATH}${card.value}${card.suit}.png`;
    img.className = 'card-img';
    return img;
}

/*  Table */
function updateTable(cards = []) {
    const div = document.getElementById('table_cards');
    div.innerHTML = '';

    if (cards.length > 0) {
        div.appendChild(createCardImg(cards[cards.length - 1]));
    }
}

/*  Hand */
function updateHand(cards = [], data) {
    const div = document.getElementById('hand_cards');
    div.innerHTML = '';

    if (cards.length === 0) {
        div.innerHTML = '<em>Δεν έχεις φύλλα!</em>';
        return;
    }

    cards.forEach(card => {
        const btn = document.createElement('button');
        btn.appendChild(createCardImg(card));

        btn.onclick = () => {
            if (data.status !== 'started') return;

            if (currentTurn !== data.me) {
                showMessage('Δεν είναι η σειρά σου!');
                return;
            }

            playCard(card.card_id);
        };

        div.appendChild(btn);
    });
}


// Player captured cards
function updateCaptured(cards = []) {
    const div = document.getElementById('captured_cards');
    div.innerHTML = '';

    cards.forEach(card => {
        div.appendChild(createCardImg(card));
    });
}


// Play card
function playCard(card_id) {
    $.ajax({
        url: 'api/play_card.php',
        method: 'POST',
        headers: { 'X-TOKEN': token },
        data: { card_id: card_id },
        success: function () {
            loadGame();
        },
        error: function () {
            alert('Σφάλμα στην κίνηση');
        }
    });
}

// Message helper (3 sec)
let messageTimeout = null;

function showMessage(text) {
    const msg = document.getElementById('message');
    msg.innerText = text;

    clearTimeout(messageTimeout);
    messageTimeout = setTimeout(() => {
        msg.innerText = '';
    }, 3500);
}

/* Game end */
function handleGameEnd(data) {
    if (!['ended', 'aborted'].includes(data.status)) return;
    if (gameEndedShown) return;

    gameEndedShown = true;

    const msgDiv = document.getElementById('message');

    // ABORTED , ΧΩΡΙΣ RESTART
    if (data.status === 'aborted') {

        const winner = data.result;
        const loser  = winner === 'P1' ? 'P2' : 'P1';

        msgDiv.innerText = `${loser} aborted ! Νικητής: ${winner}`;
        return; 
    }

    //  ENDED  + RESTART
    if (data.result === 'P1') {
        msgDiv.innerText = 'ΝΙΚΗΤΗΣ : P1';
    } else if (data.result === 'P2') {
        msgDiv.innerText = 'ΝΙΚΗΤΗΣ : P2';
    } else {
        msgDiv.innerText = 'ΙΣΟΠΑΛΙΑ';
    }

    showRestartButton();
}

/* Restart  */
function showRestartButton() {
     // αν υπάρχει ήδη, ΜΗΝ ξαναδημιουργήσεις
     if (document.getElementById('restart_btn')) return;

     const div = document.getElementById('message');
 
     const btn = document.createElement('button');
     btn.id = 'restart_btn';
     btn.className = 'game-btn restart-btn';
     btn.innerHTML = 'Νέο Παιχνίδι';
     btn.onclick = restartGame;
 
     div.appendChild(document.createElement('br'));
     div.appendChild(btn);
}

function restartGame() {
    const btn = document.getElementById('restart_btn');
    if (btn) btn.disabled = true;

    $.ajax({
        url: 'api/restart_game.php',
        method: 'POST',
        headers: { 'X-TOKEN': token },
        success: function () {
            lastShownEvent = null;
            gameEndedShown = false;
            startPolling();
        }
    });
}

/*  Handle last event */
function handleLastEvent(event) {
    if (!event) return;
    if (event === lastShownEvent) return;

    lastShownEvent = event;

    /*  ΝΕΟ ΠΑΙΧΝΙΔΙ */
    if (event.startsWith('NEW_GAME')) {
        showMessage('Νέο παιχνίδι ξεκίνησε !');
        gameEndedShown = false;
        return;
    }


    const player = event.startsWith('P1') ? 'P1' : 'P2';

    if (event.includes('_XERI_J')) {
        showMessage(` ${player} ΞΕΡΗ ΜΕ ΒΑΛΕ ! (+20)`);
    } else if (event.includes('_XERI')) {
        showMessage(` ${player} ΞΕΡΗ ! (+10)`);
    }
}


/* Logout */
const logoutBtn = document.getElementById('logout_btn');

if (logoutBtn) {
    logoutBtn.addEventListener('click', () => {

        $.ajax({
            url: 'api/logout.php',
            method: 'POST',
            headers: { 'X-TOKEN': token },
            success: function () {
                stopPolling();
                localStorage.removeItem('token');

                gameArea.style.display  = 'none';
                loginArea.style.display = 'block';

                document.getElementById('message').innerText = '';
                document.getElementById('status').innerText  = '-';
            }
        });
    });
}