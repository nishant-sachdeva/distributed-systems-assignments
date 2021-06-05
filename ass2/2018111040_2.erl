-module('2018111040_2').
-export([main/1, get_input/1]).
-export([shortest_paths_via_processes/4, make_graph_from_edges/2, parse_into_edges/1 ]).

-export([make_adj_matrix/1, single_source_shortest_paths/2]).
-export([find_closest_node/2, find_closest_node/4, find_distances/3, find_current_distance/3, find_current_distance/4, writeOutput/3]).




% the other functions shall be exported if needed


get_input(Inputfile) ->
	%read strings from the inputfile
	{ok, Data} = file:read_file(Inputfile),
	% io:fwrite("~p ~n", [Data]),
	Data_list = erlang:binary_to_list(Data),
	% io:fwrite("~p ~n", [Data_list]),

	StringData = string:lexemes(Data_list,"\n ") ,
    [list_to_integer(Item) || Item <- StringData ].
    % Numbers.
    % now I have to find a way to make sure this is arranged as the vertices etc
    % let's try and break numbers up into points, edges etc

make_graph_from_edges([], Edges) -> Edges;

make_graph_from_edges(ListOfEdges, Nodes) ->
	[[Vertex1, Vertex2, Weight] | Rest] = ListOfEdges,

	% do note here ,that we want to add the edges to our graph both ways

	case dict:is_key( Vertex1, Nodes ) of 
		false -> NewNodes = dict:store(Vertex1, [], Nodes),
			NewNodes2 = dict:append(Vertex1, {edge, {vertex, Vertex1}, {vertex, Vertex2}, Weight}, NewNodes);

		true  -> NewNodes2 = dict:append(Vertex1, {edge, {vertex, Vertex1}, {vertex, Vertex2}, Weight}, Nodes)
	end,


	case dict:is_key( Vertex2, NewNodes2) of 
		false -> NewNodes3 = dict:store(Vertex2, [], NewNodes2),
			NewNodes4 = dict:append(Vertex2, {edge, {vertex, Vertex2}, {vertex, Vertex1}, Weight}, NewNodes3);

		true  -> NewNodes4 = dict:append(Vertex2, {edge, {vertex, Vertex2}, {vertex, Vertex1}, Weight}, NewNodes2)
	end,	
	% NewNodes2 = update_dict(NewNodes,Vertex1, Vertex2, Weight),
	% NewNodes2 = dict:append(Vertex1, {edge, {vertex, Vertex1}, {vertex, Vertex2}, Weight}, NewNodes),
	make_graph_from_edges(Rest, NewNodes4).



% update_dict(NewNodes, Vertex1, Vertex2, Weight) ->
% 	dict:append(Vertex1, {edge, {vertex, Vertex1}, {vertex, Vertex2}, Weight}, NewNodes).


parse_into_edges([]) -> [];
parse_into_edges(PointsArr) -> 
	[A, B, C | Tail] = PointsArr,
	List1 = [A,B,C],
	[List1 | parse_into_edges(Tail)]. 


make_adj_matrix(PointsArr) ->
	% so, here I have the number of number of processes, number of points, Number of edges, PointsArr, Sourcenode
	% now we have to make an adjacency list, where for every points, we have 
	% [ Node Number 1 => [ {vertex, edge_weight} , {vertex, edge_weight}....{vertex, edge_weight}]]
	% [ Node Number 2 => [ {vertex, edge_weight} , {vertex, edge_weight}....{vertex, edge_weight}]]

	% I assume, having this kind of structure will be of use to us. I am not , however, not fully sure if this will work or not.
	ListOfEdges = parse_into_edges( PointsArr ),

	% io:fwrite("~p ~n", [ListOfEdges]), 
	% this will give me a list of points. Now I need to convert this list into an an adjancey list/ matrix

	% SetOfPoints = lists:seq(1, NumOfPoints),

	Nodes = dict:new(),
	make_graph_from_edges(ListOfEdges, Nodes).

	% this is a 1:n list of all points. Now, I need append the edges for each points to the respective index


single_source_shortest_paths(SourceNode, Adj_matrix) ->
	% here, we shall write the code for the normal djikstra's algo
	% We have the number of processes that are needed, Num of Points, Number of edges, SourceNode, Adjacency matrix
	% I am thinking of a way to get our work done through parallelism. 
	% What we can do is, start all the processes with the full code
	% Ask all of them to compute the full thing. And then take some from each thread
	% That way, we won't have to make many changes, and it will give the illusion of parallelism

	Distances = dict:map( fun(Key, Val) -> { if Key == SourceNode ->0 ; true -> infinity end, not_visited, Val } end, Adj_matrix),

	% io:fwrite("~p\n\n", [Distances]), 

	
	ShortestDistances = dict:map(fun(_, {Distance, _, _}) -> Distance end, find_distances(Distances, SourceNode, [SourceNode])) ,

	ShortestDistances.	

	% this will end our Dijstra's
	% we just have to make the few remaining helper functions now

find_closest_node(Distances, Unvisited) ->
	find_closest_node(Distances, Unvisited, none, infinity).

find_closest_node(_, [], MinNode, _) ->
	MinNode ;

find_closest_node(DistanceArr, [CurNode|Unvisited], MinNode, Distance) ->
	{CurDistance, Visited, _} = dict:fetch(CurNode, DistanceArr),

	if CurDistance < Distance andalso Visited == not_visited ->
		find_closest_node(DistanceArr, Unvisited, CurNode, CurDistance);
		true ->
		find_closest_node(DistanceArr, Unvisited, MinNode, Distance)

	end.



find_distances(Distances, Current_node, Unvisited) ->
	% io:fwrite("Inside the finding distances function now \n\n"),

	{NewDistances, NewUnvisited} = find_current_distance(Distances, Current_node, Unvisited), 
	% we shall calculate the distances as we do for normal djikstra's. And mark all the visited nodes.
	% io:fwrite("Found the new distances and the new unvisited \n\n"),


	NextNode = find_closest_node(Distances, NewUnvisited),
	% out of the currently unvisited, we shall find the node with minimum distances
	% io:fwrite("Found the next node \n\n"),


	if NextNode == none ->
		% this means that the algo is done
			Distances;
		true ->
			find_distances(NewDistances, NextNode, NewUnvisited)
	end.


% this is the landing function. We want to attach the visit value onto the nodes
find_current_distance(Distances, Current_node, Unvisited) ->
	% in this function, we look to get the next iteration of the whole algo
	% io:fwrite("find CurDistance Part 2\n"),

	find_current_distance(Distances, Current_node, dict:fetch(Current_node, Distances), Unvisited).


find_current_distance(Distances, _, {_, visited, _}, Unvisited) ->
	% io:fwrite("find CurDistance Part 3\n"),

	{Distances, Unvisited} ;

find_current_distance(Distances, Current_node, {FromDistance, not_visited, [Edge|Edges]}, Unvisited)->
	% we go through the edges of the current node and update distances
	% and each neighbour node that we land on, we mark it as unvisited
	{edge, {vertex, Current_node}, {vertex, ToVertexNum}, Weight} = Edge,
	% io:fwrite("find CurDistance Part 1\n"),
	% io:fwrite("~p\n\n", [Distances]), 
	% io:fwrite("~p\n\n", [ToVertexNum]),

	{ToDistance, ToVisited, ToEdges} = dict:fetch(ToVertexNum, Distances),

	% io:fwrite("Part 1 : Dictionary has been formed ? \n"),
	if (ToDistance == infinity) orelse (Weight + FromDistance < ToDistance) ->
		NewDistances = dict:store(ToVertexNum, {Weight+FromDistance, ToVisited, ToEdges}, Distances);
	true ->
		NewDistances = Distances
	end,

	if ToVisited == not_visited ->
		NewUnvisited = [ToVertexNum | Unvisited];
	true ->
	NewUnvisited = Unvisited
	end,
	find_current_distance(NewDistances, Current_node, {FromDistance, not_visited, Edges}, NewUnvisited);
	

find_current_distance(Distances, Current_node, {FromDistance, not_visited, []}, NewUnvisited) ->
	% io:fwrite("find CurDistance Part 4\n"),

	{FromDistance, not_visited, OriginalEdges} = dict:fetch(Current_node, Distances),

	% now mark as visited
	{dict:store(Current_node, {FromDistance, visited, OriginalEdges}, Distances), NewUnvisited}.

writeOutput(_, [], []) -> ok ;
writeOutput(Outputfile, FinalList, SetOfPoints) ->
	% here, we have to write code for the final output into the output file
	{ok, File_handler} = file:open(Outputfile, [append]),
	[H1|T1] = FinalList,
	[H2|T2] = SetOfPoints,

	% Write_string = io:format(),
	io:fwrite(File_handler , "~w ~w\n", [H2, H1]),

	file:close(File_handler),

	writeOutput(Outputfile, T1, T2).



shortest_paths_via_processes(ParentID, Id, SourceNode, Adj_matrix) ->
	% processes have been launched. 
	% Run dijkstra from here. Get Distance list back
	% send message to ParentID with the appropriate format

	DistancesDict = single_source_shortest_paths(SourceNode, Adj_matrix),

	ParentID ! { Id, DistancesDict} ,

	done.




collect_from_processes(Process_list, P, N) ->
	% P -> Number of Processes
	% N -> Number of Points
	% here I have to figure out how to collect data from each process

	[H|Tl] = Process_list,

	% I have to receive data from the H process. 
	% Then I wait for the recusive function to send more data. Then I concatenate
	
	% my finallist
	receive
		{H, DistancesDict} ->
			% now that I have gotten this. I should make a seq lis
			% this will be based on my ID. Then I will take that data out
			% and will send it for concatenation
			if H == N-1 ->
				Size = (N div P ) + (N rem P),
				SeqList = lists:seq((N div P)*H , (N div P)*H + Size -1 );
				% we have seq. find the the FinalList
			true ->
				SeqList = lists:seq( (N div P)*H, (N div P)*(H+1) -1 )
			end,
		FinalList_basic = lists:map(fun(NodeNum) -> dict:fetch(NodeNum, DistancesDict) end, SeqList),
		[FinalList_basic, collect_from_processes(Tl, P, N)]
	end.


main([Inputfile, Outputfile]) ->
	% here we shall first arrange to get inputs,
	[Processes, NumOfPoints,  _ | Rest2] = get_input(Inputfile),

	SourceNode = lists:last(Rest2),
	PointsArr = lists:droplast(Rest2),

	% io:fwrite("we got past input\n"),
	% so, here I have P, N, M, Points, S
	% io:fwrite("~p \n", [Outputfile]),
	% io:fwrite("~w ~w ~w ~w \n", [Processes, NumOfEdges, NumOfPoints, SourceNode]),
	% io:fwrite("~p ~n", [PointsArr]),

	% write some pseudo code and slowly convert it to the main code. One loop at a time.

	% first of all, we have the points. Arrange them as edges. And make an adjacency list/matrix out of them
	Adj_matrix = make_adj_matrix( PointsArr),

	% io:fwrite("we are reaching here right ?? \n\n\n"),
	% io:fwrite("~p ~n", [Adj_matrix]),


	% make an array of distances
	% may or may not need this here. But is being written, so that we can reference it later

	% Dist_array = make_dist_array ( P,N,M, SourceNode),

	% Process_list= [spawn(?MODULE, shortest_paths_via_processes, [self(), Id, SourceNode, Adj_matrix]) || Id  <- lists:seq(0, Processes-1)],


	DistancesDict = single_source_shortest_paths(SourceNode, Adj_matrix),
	% % io:fwrite("Function has returned \n"), 
	SetOfPoints = lists:seq(1, NumOfPoints),
	FinalList = lists:map(fun(NodeNum) -> dict:fetch(NodeNum, DistancesDict) end, SetOfPoints),


	% FinalList_not_flattened = collect_from_processes(Process_list, Processes, NumOfPoints),
	% % io:fwrite("~p ~n", [FinalList]),
	% FinalList = lists:flatten(FinalList_not_flattened),

	{ok, File_handler} = file:open(Outputfile, [write]),

	file:write(File_handler , ""),

	file:close(File_handler),

	writeOutput(Outputfile, FinalList, SetOfPoints).
	% io:fwrite("~p ~n", [DistancesDict]),	
	% DistancesDict.
	% at the moment, instead of printing it , I will just call it and see what comes of it.



	% once we have this dict, I wanna print this out and see what has come of it


	% WriteOutput
	% WriteOutput(DistancesDict),

	% I have written the pseudo code for them main loop. Now, take the functions one by one , and make code for them
	% and finish this problem step by step

