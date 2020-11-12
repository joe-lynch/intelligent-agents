package iaLib;

import java.util.*;

class Handler
{
    private static HashMap<String, Handler> instances;
    private int curr_row, curr_col;
    protected Deque<int[]> st;
    private int xcounter, ycounter, x, y;
    
    private boolean flag = false;
    private a_star AstarObj;
    
    /* borrowed technique from the decompiled rover code in order to handle the instances of agents */
    public synchronized static Handler getInstance(final String ag) {
        if (Handler.instances == null) {
            (Handler.instances = new HashMap<String, Handler>()).put(ag, new Handler());
        }
        if (Handler.instances.get(ag) == null) {     
            Handler.instances.put(ag, new Handler());
        }
        return Handler.instances.get(ag);
    }
    
    /* initialises the fields for the instance of each agent */
    public Handler() {
        AstarObj = new a_star();
        st = new ArrayDeque<int[]>();
        xcounter=0;
        ycounter=0;
        x=0;
        y=0;
    }
    
    /* updates the current position, stores positions in a Deque, only holding three at a time */
    public void update_current_position(final int x, final int y, final int val) {
        int row_index=0, col_index=0;
        //normally update the current position
        if(val == 0) {
            row_index = mod(curr_row+y,mapIA.height);
            col_index = mod(curr_col+x,mapIA.width);
            st.addFirst(new int[]{col_index, row_index});
            if(st.size()>3)
                st.pollLast();
         }
        //pop the position that was added last
         else if (val == 1 && st.size() > 1) {
            int[] popped = st.removeFirst();
            row_index = st.peekFirst()[1];
            col_index = st.peekFirst()[0];      
        }
        curr_row = row_index;
        curr_col = col_index;
    }
    
    /* get the current position from the Deque */
    public int[] get_position() {
        return new int[]{improve_x(st.peekFirst()[0]), improve_y(st.peekFirst()[1])};
    }
    
    /* initialises the astar object, gets the map and returns the route */
    public List<int[]> find_route(int xstart, int ystart, int xgoal, int ygoal) {
        AstarObj.init();
        //map does not get changed at all in the astar class - it is only checked in an if statement
        int[][] map = mapIA.get_map();
        return AstarObj.get_route(map, xstart, ystart, xgoal, ygoal);
    }
    
    /* add the obstacle position to the map, as -1, then update the map*/
    public void add_obstacle(int x, int y, int quantity) {
        int[][] map = mapIA.get_map();
        map[mod(y,mapIA.height)][mod(x,mapIA.width)] = -1;
        mapIA.update_map(map);
        return;
    }
     
    public int mod(int x, int y){
        int result = x % y;
        return result < 0? result + y : result;
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

    static {
       Handler.instances = null;
    }
}

