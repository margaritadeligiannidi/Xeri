ΞΕΡΗ
Web API Υλοποίηση Παιχνιδιού Καρτών
Το παρόν project αποτελεί υλοποίηση του παιχνιδιού καρτών ΞΕΡΗ, στο πλαίσιο ακαδημαϊκής εργασίας για το μάθημα ΑΔΙΣΕ.
Το παιχνίδι υποστηρίζει δύο παίκτες (Human–Human) και βασίζεται σε αρχιτεκτονική Web API, χρησιμοποιώντας PHP, MySQL, JavaScript και AJAX.
Η λογική του παιχνιδιού υλοποιείται στο backend μέσω API endpoints, ενώ το γραφικό περιβάλλον λειτουργεί ως client του API.
---
Γραφικό Περιβάλλον
![Xeri Game](screenshots/game.png)
---
Τεχνολογίες
Backend
PHP
MySQL
Web API
JSON
Frontend
HTML5
CSS3
JavaScript
AJAX
---
Αρχιτεκτονική
```text
Browser / GUI
       │
       │ AJAX / JSON Requests
       ▼
    PHP Web API
       │
       ▼
 MySQL Database
```
Η λογική του παιχνιδιού και η κατάσταση του παιχνιδιού διαχειρίζονται από το backend και αποθηκεύονται στη βάση δεδομένων.
---
🎮 Ροή Παιχνιδιού
Ο πρώτος παίκτης συνδέεται στο παιχνίδι.
Ο δεύτερος παίκτης συνδέεται και το παιχνίδι ξεκινά.
Οι παίκτες παίζουν εναλλάξ σύμφωνα με τη σειρά (`p_turn`).
Το API ελέγχει την εγκυρότητα κάθε κίνησης.
Αναγνωρίζονται ειδικά γεγονότα όπως ΞΕΡΗ και ΞΕΡΗ με J.
Ενημερώνονται τα φύλλα και το σκορ των παικτών.
Το παιχνίδι ολοκληρώνεται όταν εξαντληθούν τα φύλλα ή κάποιος παίκτης αποχωρήσει.
Υποστηρίζεται επανεκκίνηση του παιχνιδιού.
---
API Endpoints
Endpoint	Method	Description
`/api/login.php`	POST	Σύνδεση παίκτη και δημιουργία token
`/api/game.php`	GET	Επιστροφή της τρέχουσας κατάστασης του παιχνιδιού
`/api/play_card.php`	POST	Παίξιμο κάρτας
`/api/restart_game.php`	POST	Επανεκκίνηση παιχνιδιού
`/api/logout.php`	POST	Αποσύνδεση παίκτη
Authentication
Όλα τα endpoints, εκτός από το login, απαιτούν token:
```text
X-TOKEN: <token>
```
---
Δομή Βάσης Δεδομένων
`cards`
Αποθηκεύει τα φύλλα της τράπουλας και την τρέχουσα θέση τους:
`deck`
`table`
`hand_P1`
`hand_P2`
`captured_P1`
`captured_P2`
`players`
Αποθηκεύει πληροφορίες για τους παίκτες:
Username
Token
Last action
Xeri statistics
`game_status`
Αποθηκεύει την κατάσταση του παιχνιδιού:
Game status
Current turn
Scores
Winner
Last event
---
⚙️ Εγκατάσταση
1. Clone του Repository
```bash
git clone https://github.com/margaritadeligiannidi/Xeri.git
cd Xeri
```
2. Δημιουργία Βάσης Δεδομένων
Δημιουργήστε τη βάση:
```sql
CREATE DATABASE xeri;
```
Στη συνέχεια κάντε import το αρχείο της βάσης:
```bash
mysql -u root -p xeri < xeri.sql
```
Εναλλακτικά, μπορείτε να χρησιμοποιήσετε phpMyAdmin.
---
3. Ρύθμιση `.env`
Δημιουργήστε αρχείο `.env` στον φάκελο `lib`, βασισμένο στο `.env.example`.
Παράδειγμα:
```ini
DB_HOST=localhost
DB_NAME=xeri
DB_USER=root
DB_PASS=
DB_SOCKET=
```
---
4. Εκτέλεση με XAMPP
Τοποθετήστε το project στον φάκελο:
```text
C:\xampp\htdocs\Xeri
```
Ανοίξτε το XAMPP Control Panel και ενεργοποιήστε:
Apache
MySQL
Στη συνέχεια ανοίξτε:
```text
http://localhost/Xeri/
```

---
🎓 Ακαδημαϊκή Εργασία
Το project υλοποιήθηκε στο πλαίσιο ακαδημαϊκής εργασίας για το μάθημα ΑΔΙΣΕ.
