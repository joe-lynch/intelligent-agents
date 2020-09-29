package iaLib;

import jason.asSyntax.NumberTerm;
import jason.asSyntax.NumberTermImpl;
import jason.asSyntax.Term;
import jason.asSemantics.Unifier;
import jason.asSemantics.TransitionSystem;
import jason.asSemantics.DefaultInternalAction;

public class modd extends DefaultInternalAction
{
    public Object execute(final TransitionSystem ts, final Unifier un, final Term[] args) throws Exception {
    	
    	/* simple internal action to find the mod of coordinates */
    	
    	int x = mod((int)((NumberTerm)args[0]).solve(), mapIA.width);
    	int y = mod((int)((NumberTerm)args[1]).solve(), mapIA.height);
    	
        final NumberTerm xVal = (NumberTerm)new NumberTermImpl((double)x);
        final NumberTerm yVal = (NumberTerm)new NumberTermImpl((double)y);
        
        return un.unifies((Term)xVal, args[2]) && un.unifies((Term)yVal, args[3]);
    }
    
    public int mod(int x, int y){
        int result = x % y;
        return result < 0? result + y : result;
    }
}