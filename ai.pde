import net.razorvine.pickle.*;
import net.razorvine.pickle.objects.*;
import java.io.*;
import java.util.*;

class AI {
    Map qtable = new HashMap();
    
    AI() throws IOException {
        this.LoadQ();
    }

    private void LoadQ() throws IOException {
        try (InputStream input = createInput("qtable.pkl")) {
            Unpickler up = new Unpickler();
            qtable = (Map)up.load(input);
        }
    }

    int getAction(Board b) {
        int[][] grid = b.grid.clone();
        Object[] state = new Object[9];
        Boolean[] pa = new Boolean[9];
        for (int x = 0; x < 3; x++) {
            state[x] = (Object)(grid[0][x] == 1 ? "O" : "X");
            state[x+3] = (Object)(grid[1][x] == 1 ? "O" : "X");
            state[x+6] = (Object)(grid[2][x] == 1 ? "O" : "X");
            pa[x] = (grid[0][x] == 0 ? true : false);
            pa[x+3] = (grid[1][x] == 0 ? true : false);
            pa[x+6] = (grid[2][x] == 0 ? true : false);
        }

        float[] rewards = new float[9];
        for (int i = 0; i < 9; i++) {
            Object[] k = {state, (Object)i};
            rewards[i] = (float)qtable.getOrDefault(k, 1.0);
        }
        printArray(rewards);

        for (int i = 0; i < 9; i++) {
            if (rewards[i] == max(rewards) && pa[i]) {
                return i;
            }
        }

        return -1;
    }
}
