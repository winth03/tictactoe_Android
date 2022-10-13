Board board;
Button[] buttons;
Button save, load, clear, hint;
boolean saved = false;

// Main method

void setup() {
    // For PC
    size(500, 1000);
    // For Android
    //fullScreen();
    textAlign(CENTER, CENTER);
    rectMode(CENTER);
    board = new Board(height / 2 - width / 2);
    save = new Button("Save", width / 4, height - (height / 10 + ((height - width) / 8 + 20) / 2), width / 2 - 50,(height - width) / 8 + 20, width/20,() -> Save());
    load = new Button("Load", 3 * width / 4, height - (height / 10 + ((height - width) / 8 + 20) / 2), width / 2 - 50,(height - width) / 8 + 20, width/20,() -> Load());
    clear = new Button("Clear", width / 4, height - (height / 100 + ((height - width) / 8 + 20) / 2), width / 2 - 50,(height - width) / 8 + 20, width/20,() -> Clear());
    hint = new Button("Hint", 3 * width / 4, height - (height / 100 + ((height - width) / 8 + 20) / 2), width / 2 - 50,(height - width) / 8 + 20, width/20, color(201, 141, 91), color(231, 171, 121), true,() -> Hint());
    buttons = new Button[] {save, load, clear, hint};
    
    // Try to load last save
    try {
        Load();
    }
    catch(NullPointerException e) {
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
    
    // Show status
    textSize(width / 20);
    text("Save : " + (saved ? "OK" : "N/A") + " Hint : " + (board.hint ? "ON" : "OFF"), width / 2, board.posY + width + (height - width) / 50 + 10);
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

// Classes

class Button {
    float posX, posY, rectWidth, rectHeight, radius;
    String text;
    color col, col1, col2;
    boolean toggle;
    Runnable func;
    
    Button(String text, float x, float y, float rectWidth, float rectHeight, float radius, Runnable func) {
        this.text = text;
        this.posX = x;
        this.posY = y;
        this.rectWidth = rectWidth;
        this.rectHeight = rectHeight;
        this.radius = radius;
        this.col1 = color(43, 53, 102);
        this.col2 = color(13, 23, 72);
        this.col = this.col1;
        this.func = func;
        this.toggle = false;
    }
    
    Button(String text, float x, float y, float rectWidth, float rectHeight, float radius, color col1, color col2, boolean toggle, Runnable func) {
        this.text = text;
        this.posX = x;
        this.posY = y;
        this.rectWidth = rectWidth;
        this.rectHeight = rectHeight;
        this.radius = radius;
        this.col1 = col1;
        this.col2 = col2;
        this.col = this.col1;
        this.func = func;
        this.toggle = toggle;
    }
    
    void show() {
        stroke(225);
        strokeWeight(width/100);
        fill(this.col);
        rect(this.posX, this.posY, this.rectWidth, this.rectHeight, this.radius);
        textSize((height - width) / 8);
        fill(225);
        text(this.text, this.posX, this.posY, this.rectWidth, this.rectHeight);
    }
    
    void pressedEvent() {
        this.func.run();
        if (this.toggle) {
            this.col = this.col == this.col1 ? hint.col2 : hint.col1;
        }
    }
    
    boolean overButton() {
        if (mouseX >= this.posX - this.rectWidth / 2 && mouseX <= this.posX + this.rectWidth / 2 && mouseY >= this.posY - this.rectHeight / 2 && mouseY <= this.posY + this.rectHeight / 2) {
            return true;
        }
        return false;
    }
}

class Board {
    int[][] grid = new int[3][3];
    int[] newSymbol = {-1, -1};
    float posY, size = 1;
    String winner;
    int turn = 1, alpha = 255;
    boolean hint = false;

    Board(float y) {
        this.posY = y;
    }

    private void O(int x, int y, int alpha) {
        stroke(225, alpha);
        noFill();
        if (x == this.newSymbol[0] && y == this.newSymbol[1]) { // Check if symbol is new then play animation
            circle((width/3) * x + (width/3) / 2, this.posY + (width/3) * y + (width/3) / 2, ((width/3) - (width/3) * 0.2) * this.size);
        } else {
            circle((width/3) * x + (width/3) / 2, this.posY + (width/3) * y + (width/3) / 2, (width/3) - (width/3) * 0.2);
        }
    }

    private void X(int x, int y, int alpha) {
        stroke(225, alpha);
        noFill();
        if (x == this.newSymbol[0] && y == this.newSymbol[1]) { // Check if symbol is new then play animation
            line((width/3) * x + (width/3) * (0.5 - 0.3 * this.size), this.posY + (width/3) * y + (width/3) * (0.5 - 0.3 * this.size), (width/3) * x + (width/3) * (0.5 + 0.3 * this.size), this.posY + (width/3) * y + (width/3) * (0.5 + 0.3 * this.size));
            line((width/3) * x + (width/3) * (0.5 + 0.3 * this.size), this.posY + (width/3) * y + (width/3) * (0.5 - 0.3 * this.size), (width/3) * x + (width/3) * (0.5 - 0.3 * this.size), this.posY + (width/3) * y + (width/3) * (0.5 + 0.3 * this.size));
        } else {
            line((width/3) * x + (width/3) * 0.2, this.posY + (width/3) * y + (width/3) * 0.2, (width/3) * x + (width/3) * 0.8, this.posY + (width/3) * y + (width/3) * 0.8);
            line((width/3) * x + (width/3) * 0.8, this.posY + (width/3) * y + (width/3) * 0.2, (width/3) * x + (width/3) * 0.2, this.posY + (width/3) * y + (width/3) * 0.8);
        }
    }

    void show() {
        stroke(225, this.alpha);
        strokeWeight(10);
        for (int i = 1; i < 3; i++) {
            // Vertical
            line((width/3) * i, this.posY + 25, (width/3) * i, this.posY + width - 25);
            // Horizontal
            line(25, this.posY + (width/3) * i, width - 25, this.posY + (width/3) * i);
        }

        // Draw symbols in each cell
        for (int i = 0; i < 3; i++) {
            for (int j = 0; j < 3; j++) {
                strokeWeight(20);
                // 1 -> O
                if (this.grid[i][j] == 1) O(j, i, this.alpha);
                // -1 -> X
                else if (this.grid[i][j] == -1) X(j, i, this.alpha);
            }
        }
    }

    void updateBoard() {
        // Restart game
        if (this.winner != null) {
            this.grid = new int[3][3];
            this.winner = null;
            this.turn = 1;
            this.alpha = 255;
            return;
        }

        // Update grid
        int x, y;
        x = floor(mouseX / (width/3));
        y = floor((mouseY - this.posY) / (width/3));

        if (x < 0 || x > 2 || y < 0 || y > 2) return; // Check if index is out of range
        if (this.grid[y][x] != 0 || this.size < 1) return; // Check if cell is empty or animation is finished

        this.grid[y][x] = this.turn;
        this.newSymbol[0] = x;
        this.newSymbol[1] = y;

        if (this.turn == 1) this.turn = -1;
        else this.turn = 1;

        this.size = 0;
    }

    void checkWin() {
        strokeWeight(20);
        float halfCell = width/6;
        int[] hintCell;

        // Horizontal
        int count, sum;
        for (int i = 0; i < 3; i++) {
            sum = 0;
            count = 0;
            hintCell = new int[] {-1, -1};
            for (int j = 0; j < 3; j++) {
                sum += this.grid[i][j];
                if (this.grid[i][j] == this.turn) count++;
                else if (this.grid[i][j] == 0) hintCell = new int[] {j, i};
            }
            // Win
            if (sum == 3 || sum == -3) {
                stroke(252, 74, 113, this.alpha);
                line(0, this.posY + (width/3) * i + halfCell, width, this.posY + (width/3) * i + halfCell);
                if (sum == 3) this.winner = "O";
                else this.winner = "X";
            }
            // Hint
            if (count == 2 && hintCell != new int[] {-1, -1} && this.winner == null && this.hint) {
                if (this.turn == 1) O(hintCell[0], hintCell[1], 50);
                else X(hintCell[0], hintCell[1], 50);
            }
        }

        //Vertical
        for (int i = 0; i < 3; i++) {
            sum = 0;
            count = 0;
            hintCell = new int[] {-1, -1};
            for (int j = 0; j < 3; j++) {
                sum += this.grid[j][i];
                if (this.grid[j][i] == this.turn) count++;
                else if (this.grid[j][i] == 0) hintCell = new int[] {i, j};
            }
            // Win
            if (sum == 3 || sum == -3) {
                stroke(252, 74, 113, this.alpha);
                line((width/3) * i + halfCell, this.posY, (width/3) * i + halfCell, this.posY + width);
                if (sum == 3) this.winner = "O";
                else this.winner = "X";
            }
            // Hint
            if (count == 2 && hintCell != new int[] {-1, -1} && this.winner == null && this.hint) {
                if (this.turn == 1) O(hintCell[0], hintCell[1], 50);
                else X(hintCell[0], hintCell[1], 50);
            }
        }

        //Left - Right Diagonal
        hintCell = new int[] {-1, -1};
        sum = 0;
        count = 0;
        for (int i = 0; i < 3; i++) {
            sum += this.grid[i][i];
            if (this.grid[i][i] == this.turn) count++;
            else if (this.grid[i][i] == 0) hintCell = new int[] {i, i};
        }
        // Win
        if (sum == 3 || sum == -3) {
            stroke(252, 74, 113, this.alpha);
            line(0, this.posY, width, this.posY + width);
            if (sum == 3) this.winner = "O";
            else this.winner = "X";
        }
        // Hint
        if (count == 2 && hintCell != new int[] {-1, -1} && this.winner == null && this.hint) {
            if (this.turn == 1) O(hintCell[0], hintCell[1], 50);
            else X(hintCell[0], hintCell[1], 50);
        }

        // Right - Left Diagonal
        hintCell = new int[] {-1, -1};
        sum = 0;
        count = 0;
        for (int i = 0; i < 3; i++) {
            sum += this.grid[i][2 - i];
            if (this.grid[i][2 - i] == this.turn) count++;
            else if (this.grid[i][2 - i] == 0) hintCell = new int[] {2 - i, i};
        }
        // Win
        if (sum == 3 || sum == -3) {
            stroke(252, 74, 113, this.alpha);
            line(width, this.posY, 0, this.posY + width);
            if (sum == 3) this.winner = "O";
            else this.winner = "X";
        }
        // Hint
        if (count == 2 && hintCell != new int[] {-1, -1} && this.winner == null && this.hint) {
            if (this.turn == 1) O(hintCell[0], hintCell[1], 50);
            else X(hintCell[0], hintCell[1], 50);
        }

        // Check for draw
        boolean draw = true;
        for (int i = 0; i < 3; i++) {
            for (int j = 0; j < 3; j++) {
                if (this.grid[i][j] == 0) {
                    draw = false;
                    break;
                }
            }
            if (!draw) break;
        }
        if (draw && this.winner == null) this.winner = "";
    }
}
