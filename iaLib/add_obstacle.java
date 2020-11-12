package iaLib;

import jason.asSyntax.NumberTerm;
import jason.asSyntax.NumberTermImpl;
import jason.asSyntax.*;

import jason.asSyntax.Term;
import jason.asSemantics.Unifier;
import jason.asSemantics.TransitionSystem;
import jason.asSemantics.DefaultInternalAction;

import java.awt.List;
import java.lang.String.*;
import java.util.*;

public class add_obstacle extends DefaultInternalAction
{

    public Object execute(final TransitionSystem ts, final Unifier un, final Term[] args) throws Exception {
        try {
            /* takes the coordinates, quantity and type of resource (will always be obstacle now)
             * and adds it to the map */
            int x = (int)((NumberTerm)args[0]).solve();
            int y = (int)((NumberTerm)args[1]).solve();
            int quantity = (int)((NumberTerm)args[2]).solve();
    
            Handler.getInstance(ts.getUserAgArch().getAgName()).add_obstacle(x, y, quantity);
        }
        catch(Throwable t) {
            t.printStackTrace();
            return false;
        }
        return true;
    }
    
}