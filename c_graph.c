#include <stdio.h>
#include <stdlib.h>

void main()
{
	int i =0;
	FILE *temp = fopen("angle_data.txt", "r");
	

	char *commandsForGnuplot[] = {"set title \"Tilt angle measurement\"", "plot 'angle_data.txt'"};
	FILE *gnuplotPipe = popen("gnuplot -persistent", "w");
	printf("PLotting\n");

	for (i =0; i<2;i++)
	{
		fprintf(gnuplotPipe, "%s \n", commandsForGnuplot[i]);
	}

	fclose(temp);

}
