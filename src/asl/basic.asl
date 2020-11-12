!get_info.
!setup_map.

+! get_info:  true <-
    rover.ia.get_config(C,R,S,P);
    rover.ia.get_energy(E);
    + capacity(C);
    + amount_of_gold(0);
    + x(0);
    + y(0);
    + gold_positions([]);
    + set_info(C,R,S).                 

+! setup_map: true <-
    rover.ia.get_map_size(W,H);
    + width(W);
    iaLib.mapIA(W, H);
    iaLib.update_current_position(0,0,0);
    ! move_randomly.

+! move_randomly : x(X) & y(Y) <- 
    if(width(W) & X == W){
        Xmove = 0;
        Ymove = 5;
        - + x(Xmove);
        - + y(Y+Ymove);
    }
    else{
        Xmove = 5;
        Ymove = 0;
        - + x(X+Xmove);
    }
    iaLib.update_current_position(Xmove,Ymove,0);
    move(Xmove, Ymove, 3).
                    
+! return_to_base : true <-
    + moving_to_base;
    iaLib.get_position(CX,CY);
    iaLib.update_current_position(-CX,-CY,0);
    iaLib.improve_coords(-CX, -CY, Ximprove, Yimprove);
    move(Ximprove, Yimprove, 3).
                                              
+! pickup_resource : focused_gold(X,Y,Q) & set_info(C,_,_) <-
    - + capacity(0);
    if ( Q >= C){
        - + focused_gold(X,Y,Q-C);
        for ( .range(I,1,C) ) {
            collect(X);
        };
    }
    else{
        - + focused_gold(X,Y,0);
        - + set_info(Q,_,_);
        for ( .range(I,1,Q) ) {
            collect(X);
        };
    }.
              
+! deposit_resource: set_info(C, _, _) <-
    for ( .range(I,1,C) ) {
        deposit(X);
    }.
    
+ action_completed (move) : moving_to_resource <-
    !pickup_resource.
    
+ action_completed (move) : moving_to_base <-
    !deposit_resource.

+ action_completed (move) : true <-
    scan(3).
                                                                                                                                                                                                                                                                                                                                            
+ action_completed (collect) : true <- 
    - moving_to_resource;
    ! return_to_base.
                                    
+ action_completed (deposit) : gold_positions(LIST) <- 
    - moving_to_base;
    rover.ia.get_config(C,_,_,_);
    - + set_info(C,_,_);
    - + capacity(C);
    ! collect_resource.
                                                                       
+ invalid_action (collect, R) : true <- .print("Can not collect anything!").

+ invalid_action (deposit, R) : true <- .print("Can not deposit anything!").

+ invalid_action (move, R) : true <- .print("R: ",R).
                                                                                                                
+ resource_not_found : moving_to_resource <-
    ! collect_resource.
    
+ resource_not_found : moving_to_base <-
    ! return_to_base.                                                                                                               
                                                                
+ resource_not_found : true <-
    .drop_all_intentions;
    ! move_randomly.                        

+! collect_resource : gold_positions([]) & curr(CXX,CYY) & focused_gold(_,_,0) & x(X) & y(Y) <-
    - focused_gold(_,_,0);
    if(width(W) & X == W){
        Xmove = 0;
        Ymove = 5;
        - + x(Xmove);
        - + y(Y+Ymove);
    }
    else{
        Xmove = 5;
        Ymove = 0;
        - + x(X+Xmove);
    }
    iaLib.update_current_position(CXX+Xmove,CYY+Ymove,0);
    iaLib.improve_coords(CXX+Xmove, CYY+Ymove, Ximprove, Yimprove);
    move(Ximprove, Yimprove, 3).

+! collect_resource : gold_positions([]) & curr(CXX,CYY) & focused_gold(FX,FY,FQ) <-
    + moving_to_resource;
    iaLib.update_current_position(CXX+FX,CYY+FY,0);
    iaLib.improve_coords(CXX+FX, CYY+FY, Ximprove, Yimprove);
    move(Ximprove, Yimprove, 3).
                                
+! collect_resource : gold_positions([Head|Tail]) & curr(CXX, CYY) <-
    .nth(0,Head,X);
    .nth(1,Head,Y);
    .nth(2,Head,Q);
    + moving_to_resource;
    if(focused_gold(FX,FY,FQ) & FQ > 0){
        iaLib.update_current_position(CXX+FX,CYY+FY,0);
        iaLib.improve_coords(CXX+FX, CYY+FY, Ximprove, Yimprove);
        move(Ximprove, Yimprove, 3);
    }
    else{
        - + gold_positions(Tail);
        - + focused_gold(X,Y,Q);
        if(first){
            - first;
            iaLib.update_current_position(X,Y,0);
            iaLib.improve_coords(X, Y, Ximprove, Yimprove)
            move(Ximprove, Yimprove, 1);
        }
        else{
            iaLib.update_current_position(CXX+X, CYY+Y, 0);
            iaLib.improve_coords(CXX+X, CYY+Y, Ximprove, Yimprove);
            move(Ximprove, Yimprove, 3);
        };
    }.

@resource_found (_, _, _, _) [atomic]
+ resource_found (T, Q, X, Y) : capacity(C) & amount_of_gold(Amount) & gold_positions(L) <-
                    .count(resource_found(_, _,_,_), N);
                    - + amount_of_gold(Amount+1);
                    iaLib.get_position(CX, CY);                 
                    if(.empty(L)){
                        - gold_positions(L);
                        + gold_positions([[X,Y,Q]]);
                    }
                    else{
                        .concat(L, [[X,Y,Q]], Concat);
                        - gold_positions(L);
                        + gold_positions(Concat);
                    }
                    if(amount_of_gold(A) & A == N){
                        iaLib.get_position(CXX, CYY);
                        - + curr(CXX, CYY);
                        + first;
                        - + amount_of_gold(0);
                        ! collect_resource; 
                    }.
                                                             