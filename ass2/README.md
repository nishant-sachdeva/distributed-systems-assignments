Writer : Nishant Sachdeva
Roll Number : 2018111040


QUESTION 1 : 

1. Input and Output is taken care of by using the Args in the main_func functions, and the input is read through basic file handling operators. 

Once the strings are read, we it is split on the basis of the <spaces> and the <newline> characters. After removing the newlines, the string obtained is further converted to list of integers and given to the functions for further running.

2. First, we spawn N process, each one with the requisite ID as demanded by the question ( 0, 1, 2, ...etc) . These process begin with a function called "child_process" with the ID as the argument

3. For passing the tokens along the complete ring, an array of PIDs of hte N processes is created which is further transformed into pairs of PIds, where the first member is the sender of the token, and the second member is a receiver of the token.

4. To start this process, a function is called to initiate the message passing, and this sends the message to the first process. 

5. Once a token is received by the running process, it passes a new message to the next process in the ring ( unless it is the last process ) . The Count variable is decremented every time. This keep on happening till the count goes to 0.

6. Once the last process is reached, and the Count variable has become 0, the last message is printed, and the further passing of the token is stopped.


QUESTION 2 :
Djikstra's algorithm ( parallelized the score updation mechanism in the algo in erlang )


1. The input has to be parsed first. This is done using string functions from erlang library ( same as the process in the first part ).
2. Once the parsing has been done and the whole thing has been converted into a list , the list functions of erlang are brought to the fore and they are used to bring out the Number of Processes, Number of Edges, Number of vertices, the Source node, etc

3. Once this is done, we send the list of points ( at this moment, it is just a serial list)  to be further parsed ( we know that it is going to be in triplets) by the same list functions of erlang. 

4. We use this list of points to make an adjacency list. Very important to note here that in our original data, the edges are given only once. However, this being an undirected graph, and the erlang dictionaries having a tendency to crash the code if a value is not detected for a key, we should add any given edge in the name of both the Vertex 1 and Vertex 2. This would save us a lot of errors down the line.

5. Once we are done making the adjacency list , it is quite straightforward to make the further code for Dijkstra's algorithm. However , we must take care to include some form of parallelism. This will ensure that the minimum conditions are all being met by the code.

6. Further details about the implementation of parallelised Dijsktra's code will be added later.

7. Not just spawning. We have to make it so that the process is waiting for all the child processes to return their outputs. Once we can make that happen. We are but as good as done. Once we get our lists back from each process, we can simply send out ways to concatenate them. And that shall be the end of it.

AT THE MOMENT, THE CODE IS SERIALLY IMPLEMENTED.