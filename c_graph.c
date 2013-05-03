/*Description: This C file plots the titlt angle sensed by the gyroscope and accelerometer sensors and 
displays it as function of time. The gnuplot utility has been used in order to plot the 
graph.
Authors: Smitha Sunil Kamat, Jay Khandhar
*/

/*Preprocessor directives*/
#include <stdio.h>
#include <stdlib.h>

void main()
{
	int i =0;

	/*Open the text file containing the titlt angles and time in read mode*/
	FILE *temp = fopen("angle_data.txt", "r");
	
	/*Character pointer to the data in the text file accessible to gnuplot*/
	char *commandsForGnuplot[] = {"set title \"Tilt angle measurement\"", "plot 'angle_data.txt'"};

	/*Create a pipe between gnuplot and the text file */
	FILE *gnuplotPipe = popen("gnuplot -persistent", "w");

	printf("Plotting the graph\n");

	/*Plot the graph, tilt angle along Y axis and time along X axis*/
	for (i =0; i<2;i++)
	{
		fprintf(gnuplotPipe, "%s \n", commandsForGnuplot[i]);
	}

	fclose(temp);

}
