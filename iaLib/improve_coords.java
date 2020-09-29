package iaLib;

import jason.asSyntax.NumberTerm;
import jason.asSyntax.NumberTermImpl;
import jason.asSyntax.Term;
import jason.asSemantics.Unifier;
import jason.asSemantics.TransitionSystem;
import jason.asSemantics.DefaultInternalAction;

public class improve_coords extends DefaultInternalAction
{
    public Object execute(final TransitionSystem ts, final Unifier un, final Term[] args) throws Exception {
    	
    	/* improves the coordinates by making the route the shortest possible (wrapping around the map) */
    	
    	int x = improve_x((int)((NumberTerm)args[0]).solve());
        int y = improve_y((int)((NumberTerm)args[1]).solve());
    			
        final NumberTerm xVal = (NumberTerm)new NumberTermImpl((double)x);
        final NumberTerm yVal = (NumberTerm)new NumberTermImpl((double)y);
        return un.unifies((Term)xVal, args[2]) && un.unifies((Term)yVal, args[3]);
    }
    
    public int improve_x(int x) {
		return improve(x,mapIA.width);
	}
	    
    public int improve_y(int y) {
	    return improve(y,mapIA.height);
    }
    
    private int improve(int val, int dim) {
   	 if (val > Math.floor(dim/2))
	    	val = val - dim;
	    else if(val < - Math.floor(dim/2))
	    	val = dim + val;
	    return val;
   }
}