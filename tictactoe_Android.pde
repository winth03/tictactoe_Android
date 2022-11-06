Model model;
View view;
Controller controller;
Button[] buttons;
Button save, load, clear, hint;

// Main method

void setup() {
    // For PC
    size(500, 1000);
    // For Android
    //fullScreen();
    textAlign(CENTER, CENTER);
    rectMode(CENTER);

    // Create object for MVC
    model = new Model(3);
    view = new View(model);
    controller = new Controller(model, view);

    // Create object for buttons
    save = new Button("Save", width / 4, height - (height / 10 + ((height - width) / 8 + 20) / 2), width / 2 - 50, (height - width) / 8 + 20, width / 20);
    load = new Button("Load", 3 * width / 4, height - (height / 10 + ((height - width) / 8 + 20) / 2), width / 2 - 50, (height - width) / 8 + 20, width / 20);
    clear = new Button("Clear", width / 2, height - (height / 100 + ((height - width) / 8 + 20) / 2), width - 50, (height - width) / 8 + 20, width / 20);
    hint = new Button("Hint", width / 2, (height / 100 + ((height - width) / 8 + 20) / 2), width - 50, (height - width) / 8 + 20, width / 20, color(43, 53, 102), color(201, 141, 91), true);
    buttons = new Button[] {save, load, clear, hint};

    // Try to load last save
    try {
        controller.Load();
    }
    catch(Exception e) {}
}

void draw() {
    background(15, 21, 50);
    String winner = model.getWinner();
    float size = model.getSize();
    int alpha = model.getAlpha(), turn = model.getTurn();

    // Animation
    if (size < 1) { // New symbol animation
        model.increaseSize(0.1);
    }
    if (winner != null && size >= 1 && alpha > 0) { // Win animation
        model.fade(-2);
    }

    // Show game result
    if (winner != null && alpha <= 0) {
        fill(225);
        textSize(height / 15);
        if (winner != "") {
            text(winner + " WINS", width / 2, height / 2);
        } else if (winner == "") {
            text("TIE", width / 2, height / 2);
        }
        textSize(height / 30);
        text("Tap to restart", width / 2, height / 2 + height / 15);
    }
    // Draw UI
    fill(225, alpha);
    textSize((height - width) / 8);
    if (turn == 1) {
        text("Turn : O", width / 2, (height / 2 - width / 2) - ((height - width) / 8 + 20));
    } else {
        text("Turn : X", width / 2, (height / 2 - width / 2) - ((height - width) / 8 + 20));
    }
    for (int i = 0; i < buttons.length; i++) {
        if (!buttons[i].toggle) { // Button hover animation
            if (buttons[i].overButton() && !mousePressed) {
                buttons[i].col = buttons[i].col2;
            } else {
                if (buttons[i].overButton() && mousePressed) {
                    buttons[i].col = buttons[i].col3;
                } else {
                    buttons[i].col = buttons[i].col1;
                }
            }
        }
        buttons[i].show();
    }
    view.show();
    controller.checkWin();

    // Show status
    textSize(width / 20);
    text("Hint : " + str(model.getHint()).toUpperCase(), width / 2, (height / 2 - width / 2) + width + (height - width) / 50 + 10);
}

void mouseReleased() {
    // Button pressed
    if (save.overButton()) {
        controller.Save();
    }
    if (load.overButton()) {
        try {
            controller.Load();
        }
        catch(Exception e) {}
    }
    if (clear.overButton()) {
        model.resetBoard();
    }
    if (hint.overButton()) {
        model.toggleHint();
        if (model.getHint()) { // Toggle color
            hint.col = hint.col2;
        } else {
            hint.col = hint.col1;
        }
    }
    // Update XO
    controller.updateBoard();
}

// Classes

class Button {
    float posX, posY, rectWidth, rectHeight, radius;
    String text;
    color col, col1, col2, col3;
    boolean toggle;

    Button(String text, float x, float y, float rectWidth, float rectHeight, float radius) {
        this.text = text;
        this.posX = x;
        this.posY = y;
        this.rectWidth = rectWidth;
        this.rectHeight = rectHeight;
        this.radius = radius;
        this.col1 = color(43, 53, 102);
        this.col2 = color(13, 23, 72);
        this.col3 = color(0, 0, 42);
        this.col = this.col1;
        this.toggle = false;
    }

    Button(String text, float x, float y, float rectWidth, float rectHeight, float radius, color col1, color col2, boolean toggle) {
        this.text = text;
        this.posX = x;
        this.posY = y;
        this.rectWidth = rectWidth;
        this.rectHeight = rectHeight;
        this.radius = radius;
        this.col1 = col1;
        this.col2 = col2;
        this.col = this.col1;
        this.toggle = toggle;
    }

    void show() {
        stroke(225);
        strokeWeight(width / 100);
        fill(this.col);
        rect(this.posX, this.posY, this.rectWidth, this.rectHeight, this.radius);
        textSize((height - width) / 8);
        fill(225);
        text(this.text, this.posX, this.posY, this.rectWidth, this.rectHeight);
    }

    boolean overButton() {
        if (mouseX >= this.posX - this.rectWidth / 2 && mouseX <= this.posX + this.rectWidth / 2 && mouseY >= this.posY - this.rectHeight / 2 && mouseY <= this.posY + this.rectHeight / 2) {
            return true;
        }
        return false;
    }
}

class Model {
    int[][] grid;
    int[] newSymbol;
    float size;
    String winner;
    int turn, alpha, gridSize;
    boolean hint;

    Model(int gridSize) {
        this.gridSize = gridSize;
        this.grid = new int[gridSize][gridSize];
        this.newSymbol = new int[] { - 1, -1};
        this.size = 1;
        this.turn = 1;
        this.alpha = 255;
        this.hint = false;
    }

    int getGridSize() {
        return this.gridSize;
    }

    int getCell(int x, int y) {
        return this.grid[y][x];
    }

    void setCell(int x, int y, int symbol) {
        this.grid[y][x] = symbol;
    }

    int getTurn() {
        return this.turn;
    }

    void setTurn(int turn) {
        this.turn = turn;
    }

    int getAlpha() {
        return this.alpha;
    }

    void fade(int alpha) {
        this.alpha += alpha;
    }

    void switchTurn() {
        this.turn *= -1;
    }

    float getSize() {
        return this.size;
    }

    void increaseSize(float size) {
        this.size += size;
    }

    void setSize(float size) {
        this.size = size;
    }

    int getNewSymbol(int index) {
        return this.newSymbol[index];
    }

    void setNewSymbol(int x, int y) {
        this.newSymbol[0] = x;
        this.newSymbol[1] = y;
    }

    String getWinner() {
        return this.winner;
    }

    void setWinner(String winner) {
        this.winner = winner;
    }

    boolean getHint() {
        return this.hint;
    }

    void toggleHint() {
        this.hint = !this.hint;
    }

    void resetBoard() {
        this.grid = new int[this.gridSize][this.gridSize];
        this.newSymbol = new int[] { - 1, -1};
        this.size = 1;
        this.turn = 1;
        this.alpha = 255;
        this.winner = null;
    }
}

class View {
    Model model;
    float cellSize;

    View(Model model) {
        this.model = model;
        this.cellSize = width / this.model.getGridSize();
    }

    void O(int x, int y, color col) {
        stroke(col);
        noFill();
        strokeWeight(this.cellSize / 10);
        if (x == this.model.getNewSymbol(0) && y == this.model.getNewSymbol(1)) { // Check if symbol is new then play animation
            circle(this.cellSize * x + this.cellSize / 2, (height / 2 - width / 2) + this.cellSize * y + this.cellSize / 2, (this.cellSize - this.cellSize * 0.2) * this.model.getSize());
        } else {
            circle(this.cellSize * x + this.cellSize / 2, (height / 2 - width / 2) + this.cellSize * y + this.cellSize / 2, this.cellSize - this.cellSize * 0.2);
        }
    }

    void X(int x, int y, color col) {
        stroke(col);
        noFill();
        strokeWeight(this.cellSize / 10);
        if (x == this.model.getNewSymbol(0) && y == this.model.getNewSymbol(1)) { // Check if symbol is new then play animation
            line(this.cellSize * x + this.cellSize * (0.5 - 0.3 * this.model.getSize()), (height / 2 - width / 2) + this.cellSize * y + this.cellSize * (0.5 - 0.3 * this.model.getSize()), this.cellSize * x + this.cellSize * (0.5 + 0.3 * this.model.getSize()), (height / 2 - width / 2) + this.cellSize * y + this.cellSize * (0.5 + 0.3 * this.model.getSize()));
            line(this.cellSize * x + this.cellSize * (0.5 + 0.3 * this.model.getSize()), (height / 2 - width / 2) + this.cellSize * y + this.cellSize * (0.5 - 0.3 * this.model.getSize()), this.cellSize * x + this.cellSize * (0.5 - 0.3 * this.model.getSize()), (height / 2 - width / 2) + this.cellSize * y + this.cellSize * (0.5 + 0.3 * this.model.getSize()));
        } else {
            line(this.cellSize * x + this.cellSize * 0.2, (height / 2 - width / 2) + this.cellSize * y + this.cellSize * 0.2, this.cellSize * x + this.cellSize * 0.8, (height / 2 - width / 2) + this.cellSize * y + this.cellSize * 0.8);
            line(this.cellSize * x + this.cellSize * 0.8, (height / 2 - width / 2) + this.cellSize * y + this.cellSize * 0.2, this.cellSize * x + this.cellSize * 0.2, (height / 2 - width / 2) + this.cellSize * y + this.cellSize * 0.8);
        }
    }

    void hint(int countO, int countX, int[] hintCell) {
        if (hintCell[0] != -1) {
            if (countO == this.model.getGridSize() - 1) {
                if (this.model.getTurn() == 1) this.O(hintCell[0], hintCell[1], color(225, 50));
                else this.O(hintCell[0], hintCell[1], color(225, 0, 0, 50));
            } else if (countX == this.model.getGridSize() - 1) {
                if (this.model.getTurn() == -1) this.X(hintCell[0], hintCell[1], color(225, 50));
                else this.X(hintCell[0], hintCell[1], color(225, 0, 0, 50));
            }
        }
    }

    void winnerLine(float x1, float y1, float x2, float y2) {
        strokeWeight(this.cellSize / 10);
        stroke(225, 0, 0, this.model.getAlpha());
        line(x1, y1, x2, y2);
    }

    void show() {
        stroke(225, this.model.getAlpha());
        float gridWeight = this.cellSize / 50;
        strokeWeight(gridWeight);
        // Draw grid lines
        for (int i = 1; i < this.model.getGridSize(); i++) {
            // Vertical
            line(this.cellSize * i, (height / 2 - width / 2) + gridWeight, this.cellSize * i, (height / 2 - width / 2) + width - gridWeight);
            // Horizontal
            line(gridWeight, (height / 2 - width / 2) + this.cellSize * i, width - gridWeight, (height / 2 - width / 2) + this.cellSize * i);
        }

        // Draw symbols in each cell
        for (int i = 0; i < this.model.getGridSize(); i++) {
            for (int j = 0; j < this.model.getGridSize(); j++) {
                // 1 -> O
                if (this.model.getCell(j, i) == 1) this.O(j, i, color(225, this.model.getAlpha()));
                // -1 -> X
                else if (this.model.getCell(j, i) == -1) this.X(j, i, color(225, this.model.getAlpha()));
            }
        }
    }
}

class Controller {
    Model model;
    View view;
    float cellSize;

    Controller(Model model, View view) {
        this.model = model;
        this.view = view;
        this.cellSize = width / this.model.getGridSize();
    }

    void updateBoard() {
        // Restart game
        if (this.model.getWinner() != null) {
            this.model.resetBoard();
            return;
        }

        // Update grid
        int x, y;
        x = floor(mouseX / this.cellSize);
        y = floor((mouseY - (height / 2 - width / 2)) / this.cellSize);

        if (x < 0 || x >= this.model.getGridSize() || y < 0 || y >= this.model.getGridSize()) return; // Check if index is out of range
        if (this.model.getCell(x, y) != 0 || this.model.getSize() < 1) return; // Check if cell is empty or animation is finished

        this.model.setCell(x, y, model.getTurn());
        this.model.setNewSymbol(x, y);
        this.model.setSize(0);
        this.model.setTurn( -this.model.getTurn());
    }

    void checkWin() {
        float halfCell = (width / this.model.getGridSize()) / 2;
        boolean tie = true;
        int count_h = 0, count_v = 0, count_d1 = 0, count_d2 = 0;
        for (int i = 0; i < this.model.getGridSize(); i++) {
            for (int j = 0; j < this.model.getGridSize(); j++) {
                count_h += this.model.getCell(j, i);
                count_v += this.model.getCell(i, j);
                if (this.model.getCell(i, j) == 0) tie = false;
            }
            count_d1 += this.model.getCell(i, i);
            count_d2 += this.model.getCell(this.model.getGridSize() - i - 1, i);
            // Check horizontal
            if (count_h == this.model.getGridSize()) {
                this.model.setWinner("O");
                this.view.winnerLine(0, (height / 2 - width / 2) + this.cellSize * i + halfCell, width, (height / 2 - width / 2) + this.cellSize * i + halfCell);
            } else if (count_h == -this.model.getGridSize()) {
                this.model.setWinner("X");
                this.view.winnerLine(0, (height / 2 - width / 2) + this.cellSize * i + halfCell, width, (height / 2 - width / 2) + this.cellSize * i + halfCell);
            }
            count_h = 0;
            // Check vertical
            if (count_v == this.model.getGridSize()) {
                this.model.setWinner("O");
                this.view.winnerLine(this.cellSize * i + halfCell, (height / 2 - width / 2), this.cellSize * i + halfCell, (height / 2 - width / 2) + width);
            } else if (count_v == -this.model.getGridSize()) {
                this.model.setWinner("X");
                this.view.winnerLine(this.cellSize * i + halfCell, (height / 2 - width / 2), this.cellSize * i + halfCell, (height / 2 - width / 2) + width);
            }
            count_v = 0;
        }

        // Check diagonal
        if (count_d1 == this.model.getGridSize()) {
            this.model.setWinner("O");
            this.view.winnerLine(0, (height / 2 - width / 2), width, (height / 2 - width / 2) + width);
        } else if (count_d1 == -this.model.getGridSize()) {
            this.model.setWinner("X");
            this.view.winnerLine(0, (height / 2 - width / 2), width, (height / 2 - width / 2) + width);
        }
        if (count_d2 == this.model.getGridSize()) {
            this.model.setWinner("O");
            this.view.winnerLine(width, (height / 2 - width / 2), 0, (height / 2 - width / 2) + width);
        } else if (count_d2 == -this.model.getGridSize()) {
            this.model.setWinner("X");
            this.view.winnerLine(width, (height / 2 - width / 2), 0, (height / 2 - width / 2) + width);
        }
        // Check tie
        if (tie && this.model.getWinner() == null) {
            this.model.setWinner("");
        }
        if (this.model.getHint() && this.model.getWinner() == null) {
            this.checkHint();
        }
    }

    void checkHint() {
        int countX, countO;
        int[] hintCell;
        // Horizontal
        for (int i = 0; i < this.model.getGridSize(); i++) {
            countO = 0;
            countX = 0;
            hintCell = new int[] { - 1, -1};
            for (int j = 0; j < this.model.getGridSize(); j++) {
                if (this.model.getCell(j, i) == 1) {
                    countO++;
                } else if (this.model.getCell(j, i) == -1) {
                    countX++;
                } else {
                    hintCell = new int[] {j, i};
                }
            }
            this.view.hint(countO, countX, hintCell);
        }

        //Vertical
        for (int i = 0; i < this.model.getGridSize(); i++) {
            countO = 0;
            countX = 0;
            hintCell = new int[] { - 1, -1};
            for (int j = 0; j < this.model.getGridSize(); j++) {
                if (this.model.getCell(i, j) == 1) {
                    countO++;
                } else if (this.model.getCell(i, j) == -1) {
                    countX++;
                } else {
                    hintCell = new int[] {i, j};
                }
            }
            this.view.hint(countO, countX, hintCell);
        }

        //Left -Right Diagonal
        countO = 0;
        countX = 0;
        hintCell = new int[] { - 1, -1};
        for (int i = 0; i < this.model.getGridSize(); i++) {
            if (this.model.getCell(i, i) == 1) {
                countO++;
            } else if (this.model.getCell(i, i) == -1) {
                countX++;
            } else {
                hintCell = new int[] {i, i};
            }
        }
        this.view.hint(countO, countX, hintCell);

        // Right- Left Diagonal
        countO = 0;
        countX = 0;
        hintCell = new int[] { - 1, -1};
        for (int i = 0; i < this.model.getGridSize(); i++) {
            if (this.model.getCell(this.model.getGridSize() - i - 1, i) == 1) {
                countO++;
            } else if (this.model.getCell(this.model.getGridSize() - i - 1, i) == -1) {
                countX++;
            } else {
                hintCell = new int[] {this.model.getGridSize() - i - 1, i};
            }
        }
        this.view.hint(countO, countX, hintCell);
    }

    void Save() {
        // Save data
        Table data = new Table();
        for (int i = 0; i < this.model.getGridSize(); i++) {
            data.addColumn();
        }
        
        for (int i = 0; i < this.model.getGridSize(); i++) {
            TableRow row = data.addRow();
            for (int j = 0; j < this.model.getGridSize(); j++) {
                row.setInt(j, this.model.getCell(j, i));
            }
        }
        saveTable(data, "save.csv");
    }

    void Load() {
        // Load data
        Table data = loadTable("save.csv");
        int xCount = 0, oCount = 0, rowCount = data.getRowCount();
        if (rowCount == 0) {
            return;
        }
        for (int i = 0; i < rowCount; i++) {
            TableRow row = data.getRow(i);
            for (int j = 0; j < this.model.getGridSize(); j++) {
                int symbol = row.getInt(j);
                this.model.setCell(j, i, symbol);
                if (symbol == 1) {
                    oCount++;
                } else {
                    if (symbol == -1) {
                        xCount++;
                    }
                }
            }
        }
        if (oCount > xCount) {
            this.model.setTurn(-1);
        } else {
            this.model.setTurn(1);
        }
    }
}
