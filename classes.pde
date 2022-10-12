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
        strokeWeight(10);
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
        if (mouseX >= this.posX && mouseX <= this.posX + this.rectWidth && mouseY >= this.posY && mouseY <= this.posY + this.rectHeight) {
            return true;
        }
        return false;
    }
}

class Board {
    int[][] grid = new int[3][3];
    int[] newSymbol = {-1, -1};
    float posY, size = 1, epsilon = 0;
    String winner;
    int turn = 1, alpha = 255;
    boolean hint = false, ai = false, clone = false;

    Board(float y) {
        this.posY = y;
    }

    Board(Board another) {
        this.posY = another.posY;
        this.grid = deepCopy(another.grid);
        this.newSymbol = another.newSymbol.clone();
        this.size = another.size;
        this.winner = another.winner;
        this.turn = another.turn;
        this.alpha = another.alpha;
        this.hint = another.hint;
        this.ai = another.ai;
        this.clone = true;
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
        if (!this.ai || (this.ai && this.turn==1)) {
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
        } else {
            int action;
            if (random(1) < this.epsilon) {
                List<Integer> pa = new ArrayList<Integer>();
                for (int i = 0; i < 3; i++) {
                    for (int j = 0; j < 3; j++) {
                        if (this.grid[i][j] == 0) {
                            pa.add(i*3+j);
                        }
                    }
                }
                action = pa.get(int(random(pa.size())));
            }
            else action = bestMove(this);

            int x = action % 3;
            int y = floor(action / 3);
            if (this.grid[y][x] != 0 || this.size < 1) return; // Check if cell is empty or animation is finished

            this.grid[y][x] = this.turn;
            this.newSymbol[0] = x;
            this.newSymbol[1] = y;

            if (this.turn == 1) this.turn = -1;
            else this.turn = 1;

            this.size = 0;
        }
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
                if (!this.clone) line(0, this.posY + (width/3) * i + halfCell, width, this.posY + (width/3) * i + halfCell);
                if (sum == 3) this.winner = "O";
                else this.winner = "X";
            }
            // Hint
            if (count == 2 && hintCell != new int[] {-1, -1} && this.winner == null && this.hint && !(this.ai && this.turn == -1)) {
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
                if (!this.clone) line((width/3) * i + halfCell, this.posY, (width/3) * i + halfCell, this.posY + width);
                if (sum == 3) this.winner = "O";
                else this.winner = "X";
            }
            // Hint
            if (count == 2 && hintCell != new int[] {-1, -1} && this.winner == null && this.hint && !(this.ai && this.turn == -1)) {
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
            if (!this.clone) line(0, this.posY, width, this.posY + width);
            if (sum == 3) this.winner = "O";
            else this.winner = "X";
        }
        // Hint
        if (count == 2 && hintCell != new int[] {-1, -1} && this.winner == null && this.hint && !(this.ai && this.turn == -1)) {
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
            if (!this.clone) line(width, this.posY, 0, this.posY + width);
            if (sum == 3) this.winner = "O";
            else this.winner = "X";
        }
        // Hint
        if (count == 2 && hintCell != new int[] {-1, -1} && this.winner == null && this.hint && !(this.ai && this.turn == -1)) {
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

int[][] deepCopy(int[][] original) {
    if (original == null) {
        return null;
    }

    final int[][] result = new int[original.length][];
    for (int i = 0; i < original.length; i++) {
        result[i] = Arrays.copyOf(original[i], original[i].length);
    }
    return result;
}
