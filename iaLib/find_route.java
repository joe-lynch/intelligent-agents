package iaLib;

import jason.asSyntax.NumberTerm;
import jason.asSyntax.NumberTermImpl;
import jason.asSyntax.ListTerm;
import jason.asSyntax.ListTermImpl;
import jason.asSyntax.Term;
import jason.asSemantics.Unifier;
import jason.asSemantics.TransitionSystem;
import jason.asSemantics.DefaultInternalAction;
import java.util.*;

public class find_route extends DefaultInternalAction
{
    
    private final ListTerm listVal = (ListTerm)new ListTermImpl();
    private Iterator iterator;
    private List<int[]> returnCoords = new ArrayList<int[]>();
    public Object execute(final TransitionSystem ts, final Unifier un, final Term[] args) throws Exception {
        
        /* takes the current coordinates, and the goal coordinates, performs a star algorithm
         *  and returns a ListTerm to the agent */
        
        int x = (int)((NumberTerm)args[0]).solve();
        int y = (int)((NumberTerm)args[1]).solve();
        int goal_x = (int)((NumberTerm)args[2]).solve();
        int goal_y = (int)((NumberTerm)args[3]).solve();
        
        returnCoords.clear();
        listVal.clear();
        returnCoords = Handler.getInstance(ts.getUserAgArch().getAgName()).find_route(x, y, goal_x, goal_y);
        for( int[] coords : returnCoords ) {
            final NumberTerm xVal = (NumberTerm)new NumberTermImpl((double)coords[0]);
            final NumberTerm yVal = (NumberTerm)new NumberTermImpl((double)coords[1]);
            final ListTerm coordsVal = (ListTerm)new ListTermImpl();
            coordsVal.append(xVal);
            coordsVal.append(yVal);
            listVal.append(coordsVal);
        }   
        return un.unifies((ListTerm)listVal, args[4]);  
    }
}