String lastSaved;
Board board;
Button[] buttons;
Button save, load, clear, hint, ai;
AI brain;

void setup() {
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
        brain = new AI();
    }
    catch(Exception e) {
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

    // Show last saved time
    textSize(width/20);
    if (lastSaved != null) {
        text("Last Saved : " + lastSaved + " Brain : " + (brain == null ? "N/A" : "OK"), width/2, board.posY + width + (height-width)/16+10);
    } else {
        text("Last Saved : N/A Brain : " + (brain == null ? "N/A" : "OK"), width/2, board.posY + width + (height-width)/16+10);
    }
}

void mouseReleased() {
    // Button pressed
    for (Button btn : buttons) {
        if (btn.overButton()) {
            btn.pressedEvent();
        }
    }
    // Update XO
    board.updateBoard();
}

void Save() {
    // Save data
    println("Saved");
    JSONArray jsonGrid = new JSONArray();
    JSONArray row;
    for (int i = 0; i < 3; i++) {
        row = new JSONArray();
        for (int j = 0; j < 3; j++) {
            row.setInt(j, board.grid[i][j]);
        }
        jsonGrid.setJSONArray(i, row);
    }
    JSONObject data = new JSONObject();
    data.setJSONArray("grid", jsonGrid);
    data.setInt("turn", board.turn);
    lastSaved = String.format("%02d/%02d/%d %02d:%02d:%02d", day(), month(), year(), hour(), minute(), second());
    data.setString("date", lastSaved);
    saveJSONObject(data, "save.json");
}

void Load() {
    // Load data
    JSONObject data= loadJSONObject("save.json");
    JSONArray jsonGrid = data.getJSONArray("grid");
    for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 3; j++) {
            board.grid[i][j] = jsonGrid.getJSONArray(i).getInt(j);
        }
    }
    board.turn = data.getInt("turn");
    lastSaved = data.getString("date");
}

void Clear() {
    // Set default data
    JSONArray jsonGrid = new JSONArray();
    JSONArray row;
    for (int i = 0; i < 3; i++) {
        row = new JSONArray();
        for (int j = 0; j < 3; j++) {
            row.setInt(j, 0);
        }
        jsonGrid.setJSONArray(i, row);
    }
    JSONObject data = new JSONObject();
    data.setJSONArray("grid", jsonGrid);
    data.setInt("turn", 1);
    lastSaved = null;
    saveJSONObject(data, "save.json");
}

void Hint() {
    board.hint = !board.hint;
}

void AI() {
    board.ai = !board.ai;
}
