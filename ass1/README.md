Here, we analyse the algorithms that have been used in the questions above. 

Question 1:

Here, we run the very basic algorithm of dividing n amongst the various processes and summing them up parallely. Thence, when they arrive to the rank = 0 process in the end, they are all summed up to give the final answer. 



Question 2: 

The Algorithm is that we divide the array into n partitions. Numbers of the parititions are in order like they would be in a 2 way partition. Then to the n processes, we shall assign the numbers as it is. These n partitions will be sorted in the n processes using further quick sort and the we shall simply concatenate them while receiving them back from the processes using the GATHERV command. 


Question 3:

We shall convert the graph into it's line graph. Then we shall use parallel coloring algorithms to color the vertices. Thence, we shall convert it back to the original state. 
Coming to the line graph. We shall use the Kuhn Wattenfor color reduction algorithm. Basically we give all the nodes different colors. Then we divide them into bins of a certain min size ( min size being the highest degree in the graph + 1) 

Thereafter for each bin ,we run the naive reduction algorithm . We keep doing this till we get the total number of colors to be less than Del+1 ( Del = highest degree of a vertex )

Thus , we end with our main graph.
