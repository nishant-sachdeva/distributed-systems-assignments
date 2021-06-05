-module('2018111040_1').
-export([main_func/1, get_input/1, write_text/2, child_process/2]).


write_text(Write_string, Outputfile) ->
	% io:fwrite("reached the write function\n"), 

	{ok, File_handler} = file:open(Outputfile, [write]),


	file:write(File_handler , Write_string),
	file:close(File_handler).



main_func([Inputfile, Outputfile]) ->
	% so , we are inside the program now
	% here, we shall look to first get the args from input files
	
	[Number, Token] = get_input(Inputfile),
	% I expect the number of processes, and the token number back

	% Find a way to spawn processes and make the token go around in circles

	% io:fwrite("Number of processes ~p \n", [Number]),
	% io:fwrite("Token number is ~p \n", [Token]),

	%Write a blank character to the output file
	{ok, FileHandlerEmpty} = file:open(Outputfile, [write]),
	file:write(FileHandlerEmpty, ""),
	file:close(FileHandlerEmpty),
	% we should always close the file handlers that we spawn
	% btw, I could, in fact try aliasing processes, that would be fun

	Processes = [spawn(?MODULE, child_process, [Id,Outputfile]) || Id  <- lists:seq(0, Number-1)],
	
	ListofProcesses = lists:zip(Processes, tl(Processes) ++ [hd(Processes)]),
	
	%Making the message out
	[H|_] = ListofProcesses,
	
	{Pid , _ } = H,
	
	Pid ! {internal_messaging_process, Token, Number, ListofProcesses, -1},
	
	done.	

child_process(ID, Outputfile) ->
	{ok, FileHandler} = file:open(Outputfile, [append]),
	receive
		{last_process_message,Token, Id} ->
			file:write(FileHandler, io_lib:fwrite("Process ~p received token ~p from process ~p.~n",[ID, Token, Id]));

		{internal_messaging_process, Token, Count,  RArr, Id} ->
		     [H|Arr] = RArr,
		     {_,PidNext} = H,
		     if
		     Id /= -1 ->
			file:write(FileHandler,io_lib:fwrite("Process ~p received token ~p from process ~p.~n",[ID, Token, Id])),
				if
					% basically, if this is the last process, send the last_process_message, else send the normal one
					length(Arr) == 0 ->
					  PidNext ! {last_process_message, Token, ID};
					true ->
					  PidNext ! {internal_messaging_process, Token, Count - 1, Arr, ID}
				end;
			   true ->
				PidNext ! {internal_messaging_process, Token, Count-1, Arr, ID}
			end,
		child_process(ID, Outputfile)
	end,
	file:close(FileHandler).


get_input(Inputfile) ->
	%read strings from the inputfile
	{ok, Data} = file:read_file(Inputfile),
	
	StringData = string:lexemes(string:tokens(erlang:binary_to_list(Data), "\n") , " "),
    Numbers = [list_to_integer(Item) || Item <- StringData ],
    Numbers.
    % just writing to check here if I can get anything working
    % StringData.
    % this statement, since it has been made the last, will return the data
