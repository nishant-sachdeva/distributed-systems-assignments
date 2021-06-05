/* MPI Program Template */

#include <stdio.h>
#include <string.h>
#include "mpi.h"
#include <fstream>
#include <bits/stdc++.h>
using namespace std;
typedef long long int ll;

/*int counts[2000000];
int displacements[2000000];
*/

int main( int argc, char **argv ) {
    int rank, numprocs;

    /* start up MPI */
    MPI_Init( &argc, &argv );

    MPI_Comm_rank( MPI_COMM_WORLD, &rank );
    MPI_Comm_size( MPI_COMM_WORLD, &numprocs );
    
    /*synchronize all processes*/
    MPI_Barrier( MPI_COMM_WORLD );
    double tbeg = MPI_Wtime();

    // taking input and doing the quicksort
    // make the inpute


    int n ;
    // int arr[1000000];
    int * arr = (int *)malloc(n * sizeof(int));

    if(argc == 3)
    {
        std::ifstream inFile(argv[1]);
        inFile >> n;

        for (int i = 0; i < n; ++i)
        {
            inFile >> arr[i] ;
        }

    }
    else
    {
        cin >> n;
        for (int i = 0; i < n; ++i)
        {
            cin >> arr[i] ;
        }
    }


    
    // we have n and the array of size n;
    int counts[20];
    int displacements[20];


    // make the counts  , make the displacements

    for (int i = 0; i < numprocs; ++i)
    {
        int c = n/numprocs ;
        if (i == n-1)
            c += n%numprocs ;

        counts[i] = c;    
    }

    displacements[0] = 0;
    for (int i = 1; i < numprocs; ++i) 
    {
        displacements[i] = displacements[i-1] + counts[i] ;
    }
    // so we have the counts and the displacements;




    if (rank == 0 )
    {
        int * my_value = (int *)malloc(counts[rank] * sizeof(int));
        MPI_Scatterv(arr, counts, displacements, MPI_INT, my_value, counts[rank], MPI_INT, rank, MPI_COMM_WORLD);
        cout << "rank is 0" << endl;
        for (int i = 0; i < counts[rank]; ++i)
        {
            cout << *(my_value+i) << " " ;
        }
        cout << endl;





        if (argc == 3)
        {
            std::ofstream outFile(argv[2]);
            outFile << std::fixed << std::setprecision(6);
            for (int i = 0; i < n; ++i)
            {
                outFile << arr[i] << " " ;
            }
            outFile << "\n" ;
        }
        else
        {
            cout << "ending" << endl;
            for (int i = 0; i < n; ++i)
            {
                cout << arr[i] << " ";
            }
            cout << endl;
        }
    }
    else
    {
        int *my_value = (int *)malloc(counts[rank] * sizeof(int));
        MPI_Scatterv(NULL, NULL, NULL, MPI_INT, my_value, counts[rank], MPI_INT, 0, MPI_COMM_WORLD);

        cout << "rank is " << rank << endl;
        for (int i = 0; i < counts[rank]; ++i)
        {
            cout << *(my_value+i) << " " ;
        }
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