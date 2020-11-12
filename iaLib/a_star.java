package iaLib;
import java.util.List;
import java.util.ArrayList;
import java.util.Collections;
import jason.asSyntax.NumberTerm;
import jason.asSyntax.ListTerm;
import jason.asSyntax.ListTermImpl;
import jason.asSyntax.NumberTermImpl;
import java.util.Random;

import jason.asSyntax.Term;
import jason.asSemantics.Unifier;
import jason.asSemantics.TransitionSystem;
import jason.asSemantics.DefaultInternalAction;


public class a_star extends DefaultInternalAction{
    private List<Node> open, closed, path, remove, tmp;
    private int[][] map;
    private Node now, tmpNode;
    private int xstart, ystart;
    private int xend, yend;
    private List<int[]> returnCoords;
    
    //constructor
    public a_star() {
        this.open = new ArrayList<Node>();
        this.closed = new ArrayList<Node>();
        this.path = new ArrayList<Node>();
        this.remove = new ArrayList<Node>();
        this.tmp = new ArrayList<Node>();
        this.returnCoords = new ArrayList<int[]>();
        this.now = new Node(null, 0, 0, 0, 0);
        this.tmpNode = new Node(null, 0, 0, 0, 0);
    }
    
    //clear and reset all instance fields
    public void init() {
        this.open.clear();
        this.closed.clear();
        if(path!=null)
            this.path.clear();
        else
            this.path = new ArrayList<Node>();
        this.remove.clear();
        this.tmp.clear();
        this.returnCoords.clear();
        this.now.clear();
        this.tmpNode.clear();
    }
    
    
    public List<Node> findRoute(int xend, int yend) {
        this.xend = xend;
        this.yend = yend;
        //add current node to the closed list
        this.closed.add(this.now);
        //iterate through neighbours and add them to the open list
        addOpenList();
        while (this.now.x != this.xend || this.now.y != this.yend) {
            if (this.open.isEmpty()) {
                return null;
            }
            //get the node with the lowest f score (first node due to ordering)
            //remove that node, and add it to the closed list
            this.now = this.open.get(0);
            this.open.remove(0);
            this.closed.add(this.now);
            addOpenList();
        }
        this.path.add(0, this.now);
        while (this.now.x != this.xstart || this.now.y != this.ystart) {
            this.now = this.now.parent;
            this.path.add(0, this.now);
        }
        return this.path;
    }
    
    //checks if node is already in list or not
    private static boolean alreadyInList(List<Node> arr, Node node) {
        return arr.stream().anyMatch((item) -> (item.x == node.x && item.y == node.y));
    }
    
    //method to calculate f
    private double distance(int dx, int dy) {
        int xval = distMod(this.now.x + dx, this.xend, mapIA.width);
        int yval = distMod(this.now.y + dy, this.yend, mapIA.height);
        return xval + yval;
    }
    
    //makes the distance calculation work with the wrapping rover map
    private int distMod(int a, int b, int f){
        int diff = Math.abs( b - a );
        return ( diff < Math.floor(f/2) ) ? diff : f - diff;
    }
    
    //simple mod function
    public int mod(int x, int y){
        int result = x % y;
        return result < 0? result + y : result;
    }
    
    //add a node to the open list
    private void addOpenList() {
        for (int x = -1; x <= 1; x++) {
            for (int y = -1; y <= 1; y++) {
                //create potential node, if it is not current node, not an obstacle, not already done, then add to open list
                tmpNode.set(this.now, mod(this.now.x + x,mapIA.width), mod(this.now.y + y,mapIA.height), this.now.g, this.distance(x, y));
                if ((x != 0 || y != 0)
                    && this.map[mod(this.now.y + y,mapIA.height)][mod(this.now.x + x,mapIA.width)] != -1
                    && !alreadyInList(this.open, tmpNode) && !alreadyInList(this.closed, tmpNode)) {
                        tmpNode.g = tmpNode.parent.g + 1.;
                        this.open.add(tmpNode.clone());
                }
                tmpNode.clear();
            }
        }
        Collections.sort(this.open);
    }
    
    public List<int[]> get_route(int[][] map, int xstart, int ystart, int xgoal, int ygoal) {
        //initialise fields
        this.xstart = mod(xstart, mapIA.width);
        this.ystart =  mod(ystart, mapIA.height);
        this.map = map;
        this.now.x = this.xstart;
        this.now.y = this.ystart;
        
        //find the path to the goal position
        this.path = findRoute(mod(xgoal, mapIA.width), mod(ygoal, mapIA.height));
        
        //if the path is not valid then retry with offset x coordinate 
        if(path == null) {
            init();
            return get_route(map, xstart, ystart, xgoal+1, ygoal);
        }
       
       for(Node n : path)
           tmp.add(n);
       
       //this converts lists of individual coordinates into just one coordinate, if the agent can move in the same way
       //can definitely be implemented more optimally than this mess
       int c = 0;
       for(int op = 0; op<3; op++) {
            for (int j=0; j<path.size(); j++) {
                int k = j;
                if (remove.contains(path.get(k)))
                    continue;
                remove.clear();
                c=0;
         
                switch(op) {
                    case 0:
                        while( k<path.size() && path.get(j).y == path.get(k).y) {
                            if(!remove.contains(path.get(k)))
                                remove.add(path.get(k));
                            k += 1;
                        }
                        break;
                    case 1:
                        while( k<path.size() && path.get(j).x == path.get(k).x) {
                            if(!remove.contains(path.get(k)))
                                remove.add(path.get(k));
                            k += 1;
                        }
                        break;
                    case 2:
                        while( k<path.size() &&
                                (path.get(j).x+c == path.get(k).x && path.get(j).y+c == path.get(k).y
                                || path.get(j).x+c == path.get(k).x && path.get(j).y-c == path.get(k).y
                                || path.get(j).x-c == path.get(k).x && path.get(j).y+c == path.get(k).y
                                || path.get(j).x-c == path.get(k).x && path.get(j).y-c == path.get(k).y
                                || j==k)) {
                            if(!remove.contains(path.get(k)))
                                remove.add(path.get(k));
                            k += 1;
                            c += 1;
                        }
                }
                
                Node first = remove.get(0);
                Node last = remove.get(remove.size()-1);
                int index = tmp.indexOf(first);
                tmp.removeAll(remove);
                tmp.add(index, last);
                if(remove.size()>1)
                    tmp.add(index, first);
            }
            path.clear();
            for(Node n : tmp)
                path.add(n);
            remove.clear();
            tmp.clear();
            for(Node n : path)
                tmp.add(n);
        }

        //returns the coordinates that inform the agent how to move
        for( Node node : tmp) {
            int[] coords = {node.x, node.y};
            returnCoords.add(coords);
        }
        
        //remove the first coordinate as it is never needed
        if(returnCoords.size() > 1)
            returnCoords.remove(0);
        
        return returnCoords;
    }
}


class Node implements Comparable {
    public Node parent;
    public int x, y;
    public double g;
    public double h;
    
    Node(Node parent, int xpos, int ypos, double g, double h) {
        this.parent = parent;
        this.x = xpos;
        this.y = ypos;
        this.g = g;
        this.h = h;
   }
    
   public void clear() {
       parent = null;
       x = 0;
       y = 0;
       h = 0;
       g = 0;
   }
   
   public void set(Node parent, int xpos, int ypos, double g, double h) {
       this.parent = parent;
       this.x = xpos;
       this.y = ypos;
       this.g = g;
       this.h = h;
   }
   
   public void print() {
       System.out.println("parent: "+parent);
       System.out.println("x: "+x);
       System.out.println("y: "+y);
       System.out.println("g: "+g);
       System.out.println("h: "+h);
   }
   
   public Node clone() {
       return new Node(this.parent, this.x, this.y, this.g, this.h);
   }
    
   @Override
   public int compareTo(Object obj) {
       return (int)((this.g + this.h) - (((Node) obj).g + ((Node) obj).h));
   }
}
