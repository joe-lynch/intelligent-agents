
package iaLib;

import jason.asSyntax.NumberTerm;
import jason.asSyntax.NumberTermImpl;
import jason.asSyntax.Term;
import jason.asSemantics.Unifier;
import jason.asSemantics.TransitionSystem;
import jason.asSemantics.DefaultInternalAction;
import java.lang.*;
import java.util.*;

public class update_current_position extends DefaultInternalAction
{

    public Object execute(final TransitionSystem ts, final Unifier un, final Term[] args) throws Exception {
        try {           
            
            /* updates the current position of the agent */
            
            int x = (int)((NumberTerm)args[0]).solve();
            int y = (int)((NumberTerm)args[1]).solve();
            int val = (int)((NumberTerm)args[2]).solve();
            Handler.getInstance(ts.getUserAgArch().getAgName()).update_current_position(x, y, val);
        }
        catch (Throwable t) {
            t.printStackTrace();
            return false;
        }
        return true;
    }
  
}