
package iaLib;

import jason.asSyntax.NumberTerm;
import jason.asSyntax.NumberTermImpl;
import jason.asSyntax.Term;
import jason.asSemantics.Unifier;
import jason.asSemantics.TransitionSystem;
import jason.asSemantics.DefaultInternalAction;

public class get_position extends DefaultInternalAction
{
    public Object execute(final TransitionSystem ts, final Unifier un, final Term[] args) throws Exception {
        
        /* gets the current position of the agent */
        
        int[] coords = Handler.getInstance(ts.getUserAgArch().getAgName()).get_position();

        final NumberTerm xVal = (NumberTerm)new NumberTermImpl((double)coords[0]);
        final NumberTerm yVal = (NumberTerm)new NumberTermImpl((double)coords[1]);
        return un.unifies((Term)xVal, args[0]) && un.unifies((Term)yVal, args[1]);
    }
}