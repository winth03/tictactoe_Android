import java.util.*;

int bestMove(Board b) {
    // AI to make its turn
    Board bClone = new Board(b);
    int[][] board = bClone.grid;
    int bestScore = -999;
    int[] move = {0, 0};
    for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 3; j++) {
            // Is the spot available?
            if (board[i][j] == 0) {
                board[i][j] = -1;
                bClone.checkWin();
                int score = minimax(bClone, 0, false);
                board[i][j] = 0;
                if (score > bestScore) {
                    bestScore = score;
                    move = new int[]{ i, j };
                }
            }
        }
    }
    return move[0]*3 + move[1];
}

int minimax(Board b, int depth, boolean isMaximizing) {
    Map<String, Integer> scores = new HashMap();
    scores.put("X", 10);
    scores.put("O", -10);
    scores.put("", 0);

    Board bClone = new Board(b);
    int[][] board = bClone.grid;
    String result = bClone.winner;
    if (result != null) {
        return scores.get(result);
    }

    if (isMaximizing) {
        int bestScore = -999;
        for (int i = 0; i < 3; i++) {
            for (int j = 0; j < 3; j++) {
                // Is the spot available?
                if (board[i][j] == 0) {
                    board[i][j] = -1;
                    bClone.checkWin();
                    int score = minimax(bClone, depth + 1, false);
                    board[i][j] = 0;
                    bestScore = max(score, bestScore);
                }
            }
        }
        return bestScore;
    } else {
        int bestScore = 999;
        for (int i = 0; i < 3; i++) {
            for (int j = 0; j < 3; j++) {
                // Is the spot available?
                if (board[i][j] == 0) {
                    board[i][j] = 1;
                    bClone.checkWin();
                    int score = minimax(bClone, depth + 1, true);
                    board[i][j] = 0;
                    bestScore = min(score, bestScore);
                }
            }
        }
        return bestScore;
    }
}
