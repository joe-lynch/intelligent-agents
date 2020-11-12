
package iaLib;

import jason.asSyntax.NumberTerm;
import jason.asSyntax.NumberTermImpl;
import jason.asSyntax.Term;
import jason.asSemantics.Unifier;
import jason.asSemantics.TransitionSystem;
import jason.asSemantics.DefaultInternalAction;
import java.util.*;

public class mapIA extends DefaultInternalAction
{
    private static int[][] int_map;
    protected static int width;
    protected static int height;
    private static boolean alreadyExecuted=false;
    
    public synchronized Object execute(final TransitionSystem ts, final Unifier un, final Term[] args) throws Exception {
        /* sets up the map for all agents from their perspective */
        try {
            width = (int)((NumberTerm)args[0]).solve();
            height = (int)((NumberTerm)args[1]).solve();
            
            if(!alreadyExecuted) {
                alreadyExecuted = true;
                int_map = new int[height][width];
                for(int i=0; i<height; i++)
                    for(int j=0; j<width; j++)
                        int_map[i][j] = 0;
            }
        }
        catch (Throwable t) {
            t.printStackTrace();
            return false;
        }
        return true;
    }
    
    /* updates the map with the pass parameter */
    protected synchronized static void update_map(int[][] new_map) {
        int_map = new_map;
    }

    /* returns a copy of the map */
    protected synchronized static int[][] get_map(){
        int[][] copy = Arrays.stream(int_map).map(int[]::clone).toArray(int[][]::new);
        return copy;
    }
    
}
