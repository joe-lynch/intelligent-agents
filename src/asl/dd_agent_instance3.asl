!get_info.

// get info and set initial beliefs
+! get_info:  true <-
	rover.ia.get_config(C,R,S,P);
	rover.ia.get_energy(E);
	+ energy(E);
	+ capacity(C);
	+x(0);
	+y(0);
	+ amount_of_current_resource(0);
	+ amount_of_other_resource(0);
	+ amount_of_obstacle(0);
	+ assigned_type(P);
	if(P == "Gold"){
		+ other_resource("Diamond");
	}
	elif(P == "Diamond"){
		+ other_resource("Gold");
	}
	+ set_info(C,R,S);
	!setup_map.

//set up the map from the agents perspective using internal actions, and defines starting positions for agents
+! setup_map: assigned_type(P) <-
	rover.ia.get_map_size(W,H);
	+ width(W);
	+ height(H);
	iaLib.mapIA(W, H);
	iaLib.update_current_position(0,0,0);
	.my_name(NAME);
	if(P == "Diamond"){
		if(NAME == dd_agent_instance1 | NAME == dd_agent1){
			.wait(4000);
			iaLib.find_route(0,0,0,30,LIST);
			+ set_goal_position;
			! move_list(LIST, 1);
		}
		elif(NAME == dd_agent_instance2){
			iaLib.find_route(0,0,0,40,LIST);
			+ set_goal_position;
			! move_list(LIST, 1);
		}
		elif(NAME == dd_agent_instance3){
			iaLib.find_route(0,0,-15,-15,LIST);
			+ set_goal_position;
			! move_list(LIST, 1);
		}
	}
	elif(P == "Gold"){
		if(NAME == gold_agent_instance1 | NAME == gold_agent){
			! general_move;
		}
		elif(NAME == gold_agent_instance2){
			.wait(4000);
			iaLib.find_route(0,0,0,10,LIST);
			+ set_goal_position;
			! move_list(LIST, 1);
		}
		elif(NAME == gold_agent_instance3){
			iaLib.find_route(0,0,0,20,LIST);
			+ set_goal_position;
			! move_list(LIST, 1);
		}
	}.

//collect a resource if there is one waiting - instead of starting to move
+! general_move: current_resource(Xactual, Yactual, Q, T) <-
	iaLib.get_position(CX,CY);
	+ save_goal_position(CX, CY);
	!collect_resource.

//the main plan for moving - provides x and y values for systematic movement around the map
+! general_move : x(X) & y(Y) <-
		if(width(W) & X >= W){
			Xmove = 0;
			if(assigned_type(P) & P == "Diamond"){
				Ymove = 5;
			}
			elif(assigned_type(P) & P == "Gold"){
				Ymove = 5;
			}	
			- + x(Xmove);
			- + y(Y+Ymove);
		}
		else{
			Xmove = 5;
			Ymove = 0;
			- + x(X+Xmove);
		}	
		iaLib.get_position(CX, CY);
		iaLib.find_route(CX,CY,CX+Xmove,CY+Ymove,LIST);
		+ set_goal_position;
		- save_goal_position(Xgoal, Ygoal);	
		!move_list(LIST, 1).

//sets the goal position of the agent (the last coordinate in the list)
+! move_list(List, SPEED) : set_goal_position <- 
	.length(List, List_length);
	.nth(List_length-1, List, Last_elem);
	.nth(0,Last_elem,X);
 	.nth(1,Last_elem,Y);
	- + goal_position(X,Y);
	- set_goal_position;
	! move_list(List, SPEED).

//drops the goal of picking up a resource when moving to the resource
+! move_list([], SPEED) : moving_to_resource & drop_current(X,Y) <-
	- moving_to_resource;
	.abolish(drop_current(X,Y));
	.abolish(current_resource(X,Y,_,_));
	.abolish(actual_resource(X,Y,_,_));
	iaLib.get_position(CX, CY);
	if(save_goal_position(Xgoalsaved, Ygoalsaved)){
		iaLib.find_route(CX, CY, Xgoalsaved, Ygoalsaved, LIST);
		- save_goal_position(Xgoalsaved, Ygoalsaved);
		+ set_goal_position;
		! move_list(LIST, 1);
	} else{
		.print("should not happen");
	}.

//drops the goal of picking up a resource
+! move_list([], SPEED) : drop_current(X,Y) <-
	.abolish(drop_current(X,Y));
	.abolish(current_resource(X,Y,_,_));
	.abolish(actual_resource(X,Y,_,_));
	! move_list([], SPEED).

//after moving to the resource, pick up the resource
+! move_list([], SPEED) : moving_to_resource  <-
	!pickup_resource.

//after returning to the base, deposit the resource
+! move_list([], SPEED) : base_return  <-
	!deposit_resource.

//collect a resource if there is one waiting
+! move_list([], SPEED): current_resource(Xactual, Yactual, Q, T) <-
	iaLib.get_position(CX,CY);
	+ save_goal_position(CX, CY);
	!collect_resource.

//otherwise, scan
+! move_list([], SPEED) : goal_position(Xgoal, Ygoal)  <-
	- goal_position(Xgoal, Ygoal);
	scan(3).

//recursively processes the list of movements - applies optimisations to movement
+! move_list([Head|Tail], SPEED) : goal_position(Xgoal, Ygoal) <-
	.nth(0,Head,X);
	.nth(1,Head,Y);
	iaLib.get_position(CX, CY);
	iaLib.modd(X-CX, Y-CY, Xresult, Yresult);
	iaLib.update_current_position(Xresult, Yresult, 0);
	iaLib.improve_coords(Xresult, Yresult, Ximprove, Yimprove);
	move(Ximprove, Yimprove, 1);
	! move_list(Tail, SPEED).

//deal with plan failures
-! move_list(List, SPEED) : true <- true.

//adjust the current position in the internal actions, update the obstruction position, and scan
+ movement_obstructed(XT,YT,XR,YR) : true <-
	.abolish(action_completed(move)[source(percept)]);	
	.abolish(action_completed(move));
	iaLib.update_current_position(0, 0, 1);
	iaLib.update_current_position(XT, YT, 0);
	iaLib.get_position(Xcurr, Ycurr);
	if(XR > 0 & YR == 0){
		iaLib.add_obstacle(Xcurr+1, Ycurr, 1, "Obstacle");
	}
	elif(XR < 0 & YR == 0){
		iaLib.add_obstacle(Xcurr-1, Ycurr, 1, "Obstacle");
	}
	elif(XR > 0 & YR > 0){
		iaLib.add_obstacle(Xcurr+1, Ycurr+1, 1, "Obstacle");
	}
	elif(XR == 0 & YR > 0){
		iaLib.add_obstacle(Xcurr,   Ycurr+1, 1, "Obstacle");
	}
	elif(XR < 0 & YR > 0){
		iaLib.add_obstacle(Xcurr-1, Ycurr+1, 1, "Obstacle");
	}
	elif(XR > 0 & YR < 0){
		iaLib.add_obstacle(Xcurr+1, Ycurr-1, 1, "Obstacle");
	}
	elif(XR == 0 & YR < 0){
		iaLib.add_obstacle(Xcurr, Ycurr-1, 1, "Obstacle");
	}
	elif(XR < 0 & YR < 0){
		iaLib.add_obstacle(Xcurr-1, Ycurr-1, 1, "Obstacle");
	}
	scan(3).

//return to base (0,0) from the agents perspective	      
+! return_to_base : true <- 
	iaLib.get_position(CX,CY);
	iaLib.find_route(CX, CY, 0, 0, LIST);
	+ base_return;
	+ set_goal_position;
	! move_list(LIST, 1).

//pick up the resource, atomic so action_completed(collect) is not triggered until after intention
@ pickup_resource[atomic]					  					  
+! pickup_resource : set_info(C, _, _) & assigned_type(P) & actual_resource(X,Y,Q,P) <-
	.drop_all_events;
	if( Q >= C ){
		- + actual_resource(X, Y, Q-C, P);
		- + capacity(0);
		for ( .range(I,1,C) ) {
			collect(X);
		};
	}
	else{
		- + actual_resource(X, Y, 0, P);
		- + set_info(Q,_,_);
		- + capacity(0);
		for ( .range(I,1,Q) ) {
			collect(X);
		};
	}.

//pick up the resource, atomic so action_completed(deposit) is not triggered until after intention
@ deposit_resource[atomic]					  
+! deposit_resource: set_info(C, _, _) <-
	for ( .range(I,1,C) ) {
		deposit(X);
	}.	 

//after collecting, return to the base								 																																																																			
+ action_completed (collect) : true <-
	- moving_to_resource;
	! return_to_base.

//after depositing, adjust resource information and trigger collect_resource								
+ action_completed (deposit) : assigned_type(P) & actual_resource(X,Y,Q,P) <-
	- base_return;
	rover.ia.get_config(C,_,_,_);
	- + set_info(C,_,_);
	- + capacity(C);
	if(Q <= 0){
		- actual_resource(X,Y,Q,P);
		.abolish(current_resource(X,Y,_,P));
	}
	! collect_resource.

//deal with invalid actions - failsafes																		   
+ invalid_action (collect, R) : drop_current(X,Y) <-
	.abolish(drop_current(X,Y));
	.abolish(current_resource(X,Y,_,_));
	.abolish(actual_resource(X,Y,_,_));
	.abolish(moving_to_resource);
	if(save_goal_position(Xgoalsaved, Ygoalsaved)){
		iaLib.get_position(CX, CY);
		iaLib.find_route(CX, CY, Xgoalsaved, Ygoalsaved, LIST);
		- save_goal_position(Xgoalsaved, Ygoalsaved);
		+ set_goal_position;
		! move_list(LIST, 1);
	} else{
		!general_move;
	}.
	
+ invalid_action (collect, R) : true <-
	if(drop_current(X,Y)){
		.abolish(drop_current(X,Y));
	}
	.abolish(current_resource(X,Y,_,_));
	.abolish(actual_resource(X,Y,_,_));
	.abolish(moving_to_resource);
	if(save_goal_position(Xgoalsaved, Ygoalsaved)){
		iaLib.get_position(CX, CY);
		iaLib.find_route(CX, CY, Xgoalsaved, Ygoalsaved, LIST);
		- save_goal_position(Xgoalsaved, Ygoalsaved);
		+ set_goal_position;
		! move_list(LIST, 1);
	} else{
		!general_move;
	}.
	
+ invalid_action (deposit, R) : true <-
	.print("invalid deposit");
	if(save_goal_position(Xgoalsaved, Ygoalsaved)){
		iaLib.get_position(CX, CY);
		iaLib.find_route(CX, CY, Xgoalsaved, Ygoalsaved, LIST);
		- save_goal_position(Xgoalsaved, Ygoalsaved);
		+ set_goal_position;
		! move_list(LIST, 1);
	} else{
		!general_move;
	}.

+ invalid_action (move, R) : true <-
	.print("R: ",R).


//if a collision occurs and there is nothing scanned (collision with agent), continue on route																									
+ resource_not_found : goal_position(Xgoal, Ygoal) & assigned_type(P) <-
	if(P == "Diamond"){
		.wait(3000);
	}
	iaLib.get_position(Xcurr, Ycurr);
	iaLib.find_route(Xcurr, Ycurr, Xgoal, Ygoal, LIST);
	+ set_goal_position;
	! move_list(LIST,1).

//if a collision occurs and nothing in scan, continue to resource
+ resource_not_found : moving_to_resource <-
	! collect_resource.

//if a collision occurs and nothing in scan, continue to base
+ resource_not_found : base_return <-
	! return_to_base.

//if nothing is found when scanned, continue moving normally																													
+ resource_not_found : true <-
	.drop_all_intentions;
	! general_move.

//moves to the current resource that is being focused on by the agent
+! collect_resource : assigned_type(P) & actual_resource(GX,GY,Q,P) <-
	iaLib.get_position(CX, CY);
	iaLib.find_route(CX, CY, GX, GY, LIST);
	+ set_goal_position;
	+ moving_to_resource;
	!move_list(LIST, 1).
	
//sets the resource to be focused on by the agent, and starts collection
+! collect_resource : assigned_type(P) & current_resource(GX,GY,Q,P) <-
	+ actual_resource(GX, GY, Q, P);
    !collect_resource.

//if there are not more resources to be collected, then return to the saved goal position
+! collect_resource : assigned_type(P) & save_goal_position(Xgoalsaved, Ygoalsaved) <-
	iaLib.get_position(CX, CY);
	iaLib.find_route(CX, CY, Xgoalsaved, Ygoalsaved, LIST);
	- save_goal_position(Xgoalsaved, Ygoalsaved);
	+ set_goal_position;
	! move_list(LIST, 1).
	
//deals with scanned resources, atomic so the plan is executed synchronously
@resource_found (_, _, _, _) [atomic]
+ resource_found (T, Q, X, Y) : capacity(C) & amount_of_current_resource(ResAmount) & amount_of_other_resource(OtherAmount) & amount_of_obstacle(ObstacleAmount) & assigned_type(P) & other_resource(NP) <-
					.count(resource_found(_, _,_,_), N);
					iaLib.get_position(CX, CY);
					//if the scanned resource is the preferred resource of the client, tell collecting agent to drop goal
					if(T == P){
						- + amount_of_current_resource(ResAmount+1);
						.send(dd_agent_instance1, tell, drop_resource(CX+X,CY+Y));
						+ current_resource(CX+X, CY+Y, Q , T);
					}
					//if the scanned resource is an obstacle, add it to the map shared by agents
					elif(T == "Obstacle"){
						- + amount_of_obstacle(ObstacleAmount+1)
						iaLib.add_obstacle(CX+X, CY+Y, Q, T);
					}
					//if the scanned resource is the non-preferred resource, tell the other agent
					elif(T == NP){
						- + amount_of_other_resource(OtherAmount+1);
						if(P == "Diamond"){
							.send(gold_agent_instance1, tell, current_resource(CX+X, CY+Y, Q, NP));
						}
						elif(P == "Gold"){
							.send(dd_agent_instance1, tell, current_resource(CX+X, CY+Y, Q, NP));
						}
					}				
					//once all resources have been scanned, either collect the preferred resource, or continue on movement path
					if(amount_of_current_resource(R) & amount_of_other_resource(NR) & amount_of_obstacle(O) & R + NR + O == N){
						if(not base_return & not moving_to_resource & not save_goal_position(_,_) & goal_position(Xgoal, Ygoal)){
							+ save_goal_position(Xgoal, Ygoal);
						}
						- + amount_of_current_resource(0);
						- + amount_of_other_resource(0);
						- + amount_of_obstacle(0);
						if( R > 0 & C > 0 ){
							if(not goal_position(Xg, Yg)){
								- + save_goal_position(CX, CY);
							}
							! collect_resource;
						} elif(goal_position(Xg, Yg)){
								iaLib.find_route(CX, CY, Xg, Yg, LIST);
								+ set_goal_position;
								!move_list(LIST, 1);
						}else{
							- save_goal_position(CX, CY);
							! general_move;
						}	
					}.			  
							

				  				 