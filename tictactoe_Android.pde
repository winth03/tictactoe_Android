Board board;
Button[] buttons;
Button save, load, clear, hint, ai;
boolean saved = false;

void setup() {
    //size(500, 1000);
    fullScreen();
    textAlign(CENTER, CENTER);
    board = new Board(height/2 - width/2);
    save = new Button("Save", 25, height - (height/10 + (height-width)/8+20), width/2 - 50, (height-width)/8+20, 50, new Runnable() {
        @Override void run() {
            Save();
        }
    }
    );
    load = new Button("Load", width/2 + 25, height - (height/10 + (height-width)/8+20), width/2 - 50, (height-width)/8+20, 50, new Runnable() {
        @Override void run() {
            Load();
        }
    }
    );
    clear = new Button("Clear", 25, height - (height/100 + (height-width)/8+20), width - 50, (height-width)/8+20, 50, new Runnable() {
        @Override void run() {
            Clear();
        }
    }
    );
    hint = new Button("Hint", 25, height/100, width/2 - 50, (height-width)/8+20, 50, color(201, 141, 91), color(231, 171, 121), true, new Runnable() {
        @Override void run() {
            Hint();
        }
    }
    );
    ai = new Button("AI", width/2 + 25, height/100, width/2 - 50, (height-width)/8+20, 50, color(201, 141, 91), color(231, 171, 121), true, new Runnable() {
        @Override void run() {
            AI();
        }
    }
    );
    buttons = new Button[] {save, load, clear, hint, ai};

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
        textSize(height/15);
        if (board.winner != null && board.winner != "") {
            text(board.winner + " WINS", width/2, height/2);
        } else if (board.winner == "") {
            text("DRAW", width/2, height/2);
        }
        textSize(height/30);
        text("Tap to restart", width/2, height/2 + height/15);
    }
    // Draw UI
    fill(225, board.alpha);
    textSize((height-width)/8);
    if (board.turn == 1) {
        text("Turn : O", width/2, board.posY - ((height-width)/8+20));
    } else {
        text("Turn : X", width/2, board.posY - ((height-width)/8+20));
    }
    for (Button btn : buttons) {
        if (!btn.toggle) btn.col = mousePressed && btn.overButton() ? btn.col2 : btn.col1; // Button hover
        btn.show();
    }
    board.show();
    board.checkWin();

    // Show ai status
    textSize(width/20);
    text("Save : " + (saved ? "OK" : "N/A"), width/2, board.posY + width + (height-width)/16+10);
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
    board.turn = oCount > xCount ? -1 : 1;
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
