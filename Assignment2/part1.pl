:- op(300, xfx, <-).

% COMP3411 Assignment2 by Celine Lin z5311209

% Question 1.1: List Processing
% number is even
is_even(X) :- 
    X mod 2 =:= 0.

% number is odd
is_odd(X) :- 
    X mod 2 =:= 1.

% base
sumsq_even([], 0).

sumsq_even([First | Rest], Sum) :-
  is_odd(First),
  sumsq_even(Rest, Sum).

sumsq_even([First | Rest], Sum) :-
  is_even(First),
  sumsq_even(Rest, SumOfRest),
  Sum is SumOfRest + (First * First).



% Question 1.2: Planning
% State of the robot's world = state(RobotLocation, BasketLocation, RubbishLocation)
% action(Action, State, NewState): Action in State produces NewState
% We assume robot never drops rubbish on floor and never pushes rubbish around

newPositionC(cs, off).

newPositionC(off, lab).

newPositionC(lab, mr).

newPositionC(mr, cs).

newPositionCC(cs, mr).

newPositionCC(mr, lab).

newPositionCC(lab, off).

newPositionCC(off, cs).

% State of the robot's world = state(RobotLocation, BasketLocation, RubbishLocation)
% action(Action, State, NewState): Action in State produces NewState
% We assume robot never drops rubbish on floor and never pushes rubbish around

action( pickup,						% Pick up rubbish from floor
	state(Pos1, Pos2, floor(Pos1)),			% Before action, robot and rubbish both at Pos1
	state(Pos1, Pos2, held)).			% After action, rubbush held by robot

action( drop,						% Drop rubbish into basket
	state(Pos, Pos, held),				% Before action, robot and basket both at Pos
	state(Pos, Pos, in_basket)).			% After action, rubbish in basket

action( push(Pos, NewPos),			% Push basket from Pos to NewPos
	state(Pos, Pos, Loc),				% Before action, robot and basket both at Pos
	state(NewPos, NewPos, Loc)).			% After action, robot and basket at NewPos

action( go(Pos1, NewPos1),			% Go from Pos1 to NewPos1
	state(Pos1, Pos2, Loc),				% Before action, robot at Pos1
	state(NewPos1, Pos2, Loc)).			% After action, robot at Pos2

action( mc,							% Go clockwise
   	state(Pos, RHC, SWC, MW, RHM),		% Before action, robot at Pos
    state(NewPos, RHC, SWC, MW, RHM)) :-% After action, robot at newPos
        newPositionC(Pos, NewPos).
    
action( mcc,						% Go clockwise
    state(Pos, RHC, SWC, MW, RHM),		% Before action, robot at Pos
    state(NewPos, RHC, SWC, MW, RHM)) :-% After action, robot at newPos
        newPositionCC(Pos, NewPos).

action( puc,						% Rob pick up coffee
	state(cs, false, SWC, MW, RHM),		% Before action, robot is at coffee shop and not helding coffee
    state(cs, true, SWC, MW, RHM)).		% After action, robot is at coffee shop and helding coffee

action( dc,							% Rob deliver coffee
	state(off, true, _, MW, RHM),		% Before action, robot is carrying coffee and is at Sam’s office
	state(off, false, false, MW, RHM)).	% After action, robot is not carrying coffee and is at Sam’s office

action( pum,						% Rob pick up mail
	state(mr, RHC, SWC, true, false),	% Before action, robot is at the mail room and there is mail waiting there
	state(mr, RHC, SWC, false, true)).	% After action, robot is at the mail room and there is mail waiting there

action( dm,							% Rob deliver mail
	state(off, RHC, SWC, MW, true),		% Before action, robot is carrying mail and at Sam’s office
	state(off, RHC, SWC, MW, false)).	% After action, robot not is carrying mail and at Sam’s office

% plan(StartState, FinalState, Plan)

plan(State, State, []).				% To achieve State from State itself, do nothing

plan(State1, GoalState, [Action1 | RestofPlan]) :-
	action(Action1, State1, State2),		% Make first action resulting in State2
	plan(State2, GoalState, RestofPlan). 		% Find rest of plan

% Iterative deepening planner
% Backtracking to "append" generates lists of increasing length
% Forces "plan" to ceate fixed length plans

id_plan(Start, Goal, Plan) :-
    append(Plan, _, _),
    plan(Start, Goal, Plan).



% Question 1.3: Inductive Logic Programming
% Question 1.3 (a)
inter_construction(C1 <- B1, C2 <- B2, C1 <- ZB, C <- B11, C <- B12) :-
    C1 = C2, 
    intersection(B1, B2, B),
    gensym(z, C), 
    subtract(B1, B2, B11), 
    subtract(B2, B1, B12),
	append(B, [C], ZB).

% Question 1.3 (b)
absorption(C1 <- B1, C2 <- B2, C1 <- YB, C2 <- B2) :-
    C1 \= C2,
    intersection(B1, B2, B),
    B = B2,
    subtract(B1, B, B3),
	append([C2], B3, YB).

% Question 1.3 (c)
truncation(C1 <- B1, C2 <- B2, C1 <- B) :-
    C1 = C2, 
    intersection(B1, B2, B).
