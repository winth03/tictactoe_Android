Board board;
Button[] buttons;
Button save, load, clear, hint, ai, mode;
boolean saved = false;
int diff = 0;

void setup() {
    size(500, 1000);
    //fullScreen();
    textAlign(CENTER, CENTER);
    rectMode(CENTER);
    board = new Board(height / 2 - width / 2);
    save = new Button("Save", width / 4, height - (height / 10 + ((height - width) / 8 + 20) / 2), width / 2 - 50,(height - width) / 8 + 20, width/20,() -> Save());
    load = new Button("Load", 3 * width / 4, height - (height / 10 + ((height - width) / 8 + 20) / 2), width / 2 - 50,(height - width) / 8 + 20, width/20,() -> Load());
    clear = new Button("Clear", width / 4, height - (height / 100 + ((height - width) / 8 + 20) / 2), width / 2 - 50,(height - width) / 8 + 20, width/20,() -> Clear());
    hint = new Button("Hint", 3 * width / 4, height - (height / 100 + ((height - width) / 8 + 20) / 2), width / 2 - 50,(height - width) / 8 + 20, width/20, color(201, 141, 91), color(231, 171, 121), true,() -> Hint());
    ai = new Button("AI", width / 4, height / 100 + (((height - width) / 8 + 20) / 2), width / 2 - 50,(height - width) / 8 + 20, width/20, color(201, 141, 91), color(231, 171, 121), true,() -> AI());
    mode = new Button("Mode", 3 * width / 4, height / 100 + (((height - width) / 8 + 20) / 2), width / 2 - 50,(height - width) / 8 + 20, width/20,() -> Mode());
    buttons = new Button[] {save, load, clear, hint, ai, mode};
    
    // Try to load last save
    try {
        Load();
    }
    catch(NullPointerException e) {
        e.printStackTrace();
        Clear();
        Load();
    }
}

void draw() {
    background(15, 21, 50);
    
    // Animation
    if (board.size < 1) { // New symbol animation
        board.size += 0.1;
    }
    else if (board.ai && board.turn == -1 && board.winner == null) {
        board.updateBoard();
    }
    if (board.winner != null && board.size >= 1 && board.alpha > 0) { // Win animation
        board.alpha -= 2.5;
    }
    
    // Show game result
    if (board.winner != null && board.alpha <= 0) {
        fill(225);
        textSize(height / 15);
        if (board.winner != null && board.winner != "") {
            text(board.winner + " WINS", width / 2, height / 2);
        } else if (board.winner == "") {
            text("DRAW", width / 2, height / 2);
        }
        textSize(height / 30);
        text("Tap to restart", width / 2, height / 2 + height / 15);
    }
    // Draw UI
    fill(225, board.alpha);
    textSize((height - width) / 8);
    if (board.turn == 1) {
        text("Turn : O", width / 2, board.posY - ((height - width) / 8 + 20));
    } else {
        text("Turn : X", width / 2, board.posY - ((height - width) / 8 + 20));
    }
    for (Button btn : buttons) {
        if (!btn.toggle) { // Button hover
            btn.col = mousePressed && btn.overButton() ? btn.col2 : btn.col1;
        }
        btn.show();
    }
    board.show();
    board.checkWin();
    
    // Show ai status
    textSize(width / 20);
    text("Save : " + (saved ? "OK" : "N/A") + " Hint : " + (board.hint ? "ON" : "OFF") + "\nAI : " + (board.ai ? "ON" : "OFF") + " Mode : " + (diff != 0 ? (diff != 1 ? (diff != 2 ? "Easy" : "Normal") : "Hard") : "GOD"), width / 2, board.posY + width + (height - width) / 50 + 10);
}

void mouseReleased() {
    // Button pressed
    for (Button btn : buttons) {
        if (btn.overButton()) {
            btn.pressedEvent();
        }
    }
    // Update XO
    if (!(board.ai && board.turn == -1) || board.winner != null) board.updateBoard();
}

void Save() {
    // Save data
    Table data = new Table();
    data.addColumn();
    data.addColumn();
    data.addColumn();
    for (int i = 0; i < 3; i++) {
        TableRow row = data.addRow();
        for (int j = 0; j < 3; j++) {
            row.setInt(j, board.grid[i][j]);
        }
    }
    saveTable(data, "save.csv");
    saved = true;
}

void Load() {
    // Load data
    Table data = loadTable("save.csv");
    int xCount = 0, oCount = 0, rowCount = 0;
    for (TableRow row : data.rows()) {
        for (int i = 0; i < 3; i++) {
            int symbol = row.getInt(i);
            board.grid[rowCount][i] = symbol;
            if (symbol == 1) oCount++;
            else if (symbol == -1) xCount++;
        }
        rowCount++;
    }
    if (rowCount == 0) {
        saved = false;
        return;
    } 
    board.turn = oCount > xCount ? - 1 : 1;
    saved = true;
}

void Clear() {
    // Save empty file
    Table data = new Table();
    saveTable(data, "save.csv");
    saved = false;
}

void Hint() {
    board.hint = !board.hint;
}

void AI() {
    board.ai = !board.ai;
}

void Mode() {
    switch(diff) {
        case 0:
            diff = 1;
            board.epsilon = 0.1;
            break;
        case 1:
            diff = 2;
            board.epsilon = 0.25;
            break;
        case 2:
            diff = 3;
            board.epsilon = 0.5;
            break;
        case 3:
            diff = 0;
            board.epsilon = 0;
            break;
    }
}
