#include <stdio.h>
#include <string.h>
#include <stdbool.h>

// usage instructions
char * usage = "%s <Number of Dice> <Sides per die>\n";

//gets a positive int out of a string.
int parseInt(char * intString) 
{
	int len = strlen(intString);
	int base = 10;
	int start = 0;
	for (int i = 0; i < len; i++) 
	{
		start = start * base;
		if (intString[i] < '0' || intString[i] > '9') 
		{
			//then bad input detected
			return -1;
		}
		start *= base;
		start = start + (intString[i] - '0');
	}
	if (len == 0)
	{
		return -1;
	}

	return start;	
}

int main (int argc, char ** argv) 
{
	//Ensure the appropriate number of command line arguments
	if (argc != 3)
	{
		printf (usage, argv[0]);
		return 1;
	}
	
	int numDice = parseInt(argv[1]);
	int numSides = parseInt(argv[2]);
	if (numDice < 0 || numSides < 0) 
	{
		fprintf(stderr, "error parsing number of dice/sides.");
		return 1;
	}	
	
	printf("You have selected %d x D%d dice to roll\n", numDice, numSides);
	
	//prepare to get randomness
	int total = 0;	
	FILE * random = fopen("/dev/urandom", "rb");
	for (int i = 0; i < numDice; i++)
	{
		int current = 0;
		fread(&current, sizeof(current), 1, random);
		if (current < 0)	
		{
			current *= -1;
		}
		
		current = current % numSides + 1;
		total += current;
		printf("Die %d rolled: %d\n", i, current);
	}

	printf("The total is: %d\n", total);

	fclose(random);
	return 0;		
}
