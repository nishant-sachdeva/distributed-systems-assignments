/* MPI Program Template */

#include <stdio.h>
#include <string.h>
#include "mpi.h"
#include <fstream>
#include <bits/stdc++.h>
using namespace std;
typedef long long int ll;

#define send_data_tag 2001
#define return_data_tag 2002


int get_input()
{
    // later replace this with ways to get inputs from files
    int ans = 0;
    cin >> ans;
    return ans;
}

void disp_output(float answer)
{
    cout << answer << endl;

    // later replace this with ways to disp output in specified files

}


int main( int argc, char **argv ) {

    std::cout << std::fixed;
    std::cout << std::setprecision(6);


    int rank, numprocs;

    MPI_Status status;

    /* start up MPI */
    MPI_Init( &argc, &argv );

    MPI_Comm_rank( MPI_COMM_WORLD, &rank );
    MPI_Comm_size( MPI_COMM_WORLD, &numprocs );
    
    /*synchronize all processes*/
    MPI_Barrier( MPI_COMM_WORLD );
    double tbeg = MPI_Wtime();

    /* write your code here */

    // depending on the rank, calculate the sum that is to be calculated here, 
    int n = 0;
    if (rank == 0)
    {
        if(argc == 3)
        {
            std::ifstream inFile(argv[1]);
            inFile >> n;            
        }
        else
            n = get_input();

        // here, we are gonna find a way to share this with all the processes 
        for (int i = 1 ; i<numprocs ; i++)
            int ierr = MPI_Send( &n, 1 , MPI_INT, i, send_data_tag, MPI_COMM_WORLD);



        int start = (n/numprocs)*rank + 1;
        int end  = (n/numprocs)*(rank+1);

        if (rank == numprocs - 1)
            end += n%numprocs;

        // cout << start << " " << end << " " << numprocs << endl;  
        double final_answer = 0;


        for(int i = start; i<= end ; i++)
        {
            float addend = 1/float(i*i);

            // cout << addend << endl;
            final_answer += addend ;
        }        
        // cout << "Final answer in rank 0" << endl;
        // cout << final_answer << endl;

        // and then wait for them to send their answers back
        for(int i = 1; i < numprocs; i++) {
            float partial_sum = 0;

            int ierr = MPI_Recv( &partial_sum, 1, MPI_FLOAT, MPI_ANY_SOURCE, return_data_tag, MPI_COMM_WORLD, &status);
  
            final_answer += partial_sum;
         }
        // cout << "Final answer in total" << endl;
        // cout << final_answer << endl;
        // once we get the answers back, sum them up and print the final answer
        if (argc == 3)
        {
            std::ofstream outFile(argv[2]);
            outFile << std::fixed << std::setprecision(6);
            outFile << final_answer;
        }
        else
            disp_output(final_answer);


    }
    else
    {
        int number = 0;
        // here, we receive n, calculate our final answer on the basis of that,
        int ierr = MPI_Recv( &number, 1, MPI_INT,  0, send_data_tag, MPI_COMM_WORLD, &status);

        /*
            code to collect N, and we are assuming that we have the value of the number of processes that we need
        */
        int start = (number/numprocs)*rank + 1;
        int end  = (number/numprocs)*(rank+1);

        if (rank == numprocs -1)
            end += number%numprocs;

        // cout << start << " " << end << " " << numprocs << endl;  


        float answer = 0;
        for(int i = start; i<= end ; i++)
        {
            // cout << answer << endl;
            float addend = 1/float(i*i);

            // cout << addend << endl;
            answer += addend;
        }        

        // and then send the thing back to our rank = 0 process
        ierr = MPI_Send( &answer, 1, MPI_FLOAT, 0, return_data_tag, MPI_COMM_WORLD);

        // cout << "Answer being sent is " << answer << endl;

    }

    MPI_Barrier( MPI_COMM_WORLD );
    double elapsedTime = MPI_Wtime() - tbeg;
    double maxTime;
    MPI_Reduce( &elapsedTime, &maxTime, 1, MPI_DOUBLE, MPI_MAX, 0, MPI_COMM_WORLD );

    if ( rank == 0 ) {
        printf( "Total time (s): %f\n", maxTime );
    }

    /* shut down MPI */
    MPI_Finalize();
    return 0;
}