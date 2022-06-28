/*
Matthew Zaksek
CS 1325.001
12/1/18
This program will read a crossword from a file and allow the user
to input a word to be found, in any direction.
*/

#include <stdio.h>
#include <ctype.h>
#include <string.h>

//Structure for storing any matches, or cases where an entered word is found
struct enteredWordInfo
{
    char enteredWord[50];
    int foundX;
    int foundY;
};

struct enteredWordInfo N[50];

int main()
{
    struct enteredWordInfo enteredWordStruct[50];
    int i, j, k, l, p, m = 0, n = 0, flag = 0, letterCount = 0, foundCount = 0;
    char a, b, c, d, menuSelection;
    char fileLocationTemp[500], fileLocation[500], buffer[160], enteredWordTemp[50], enteredWord[50], loopWord[50];
    char crosswordArray[80][80] = {0};

    displayMenu:

    //Display the initial menu
    printf("Please choose an option from the below menu:\n");
    printf("a) Enter file location (full path)\nb) Display the crossword\nc) Find a word\nd) Exit");
    printf("\n\nEnter your choice: ");

    //Get user's menu choice
    scanf(" %c", &menuSelection);

    menuValidate:

    //Performs one of four tasks, depending on entered menu selection
    //Goto statements return user to menu after task is complete
    switch(menuSelection)
    {
        case 'a':
            //Ask user for path of crossword input file
            printf("Please enter the full path of the text file:\n");

            fgetc(stdin);
            fgets(fileLocationTemp, 500, stdin);

            //Remove the newline character from file path
            for (i = 0; fileLocationTemp[i] != '\n'; i++)
            {
                fileLocation[i] = fileLocationTemp[i];
            }

            //Add string terminator to the end of file location string
            fileLocation[i] = '\0';

            //Open the file
            char* filename = fileLocation;
            FILE *fp;
            fp = fopen(filename, "r");

            //If file open fails, print error message and return -1
            if (fp == NULL)
            {
                printf("Error while opening the file!\n\n");
                goto displayMenu;
            }

            while (!feof(fp))
            {
                fgets(buffer, 160, fp);
                
                m = 0;

                for (i = 0; buffer[i] != '\n'; i++)
                {
                    //Only put characters from A-Z in array
                    if (buffer[i] > '@' && buffer[i] < '[')
                    {
                        crosswordArray[n][m] = buffer[i];
                        m++;
                    }
                }

                n++;
            }

            n--;

            //Close the file before proceeding
            fclose(fp);
            
            printf("Success! The file was read successfully!\n\n\n");

            flag = 1;

            goto displayMenu;
        case 'b':
            //Print a message if user did not first provide a location for the input file
            if (flag != 1)
            {
                printf("You must have successfully read a crossword from a file, first!\n");
                printf("Please choose a different option.\n\n");
                goto displayMenu;
            }

            printf("\n");

            //Go through each coordinate of crossword array, and print the contents, followed by a space
            for (i = 0; i < m; i++)
            {
                for (j = 0; j < n; j++)
                {
                    printf("%c ", crosswordArray[i][j]);
                }

                printf("\n");
            }

            printf("\n\n");

            goto displayMenu;
        case 'c':

            //Print a message if user did not first provide a location for the input file
            if (flag != 1)
            {
                printf("You must have successfully read a crossword from a file, first!\n");
                printf("Please choose a different option.\n\n");
                goto displayMenu;
            }

            //Ensures the found counter and letter counter is replaced for each new word
            foundCount = 0;
            letterCount = 0;

            //Ask user for a word to find
            printf("\nPlease enter a word to find: ");

            fgetc(stdin);
            fgets(enteredWordTemp, 50, stdin);

            //Remove the newline character from entered word
            for (i = 0; enteredWordTemp[i] != '\n'; i++)
            {
                //Make entered word uppercase, to match that of word search file
                enteredWord[i] = toupper(enteredWordTemp[i]);
                letterCount++;
            }

            //Add string terminator at end of entered word string
            enteredWord[i] = '\0';

            //This increment is for moving down the rows, top to bottom
            for (i = 0; i < m; i++)
            {
                //This one is for moving across the rows, left to right
                for (j = 0; j < n; j++)
                {
                    //Increment in the x/horizontal direction
                    //This and the loop directly inside is for searching in each of the eight directions
                    for (k = -1; k <= 1; k++)
                    {
                        //Increment in the y/vertical direction
                        for (l = -1; l <= 1; l++)
                        {
                            //If the increment in both directions is zero, then no words are searched
                            //This if statement skips those situations
                            if (k == 0 && l == 0)
                            {
                                continue;
                            }

                            //The below loop fills a temporary string with characters from the input file
                            //The length of the temporary string matches that of the entered word,
                            //so it can be easily compared
                            for (p = 0; p < letterCount; p++)
                            {
                                //If curser moves outside bounds, continue to next iteration
                                if (i + p * k < 0 || i + p * k > n - 1)
                                {
                                    break;
                                }

                                if (j + p * l < 0 || j + p * l > m - 1)
                                {
                                    break;
                                }

                                loopWord[p] = crosswordArray[i + p * k][j + p * l];
                            }

                            //If temporary string matches that of entered word...
                            if (strncmp(loopWord, enteredWord, letterCount) == 0)
                            {
                                //Copy entered word to structure, along with its beginning coordinates
                                strcpy(N[foundCount].enteredWord, enteredWord);
                                N[foundCount].foundX = i;
                                N[foundCount].foundY = j;

                                //Print a message indicating that the word was found, where it was found, and increment the found counter
                                printf("%s was found at row %d, column %d, moving ", enteredWord, N[foundCount].foundX + 1, N[foundCount].foundY + 1);

                                //Print direction of movement to find word
                                if (k == 1)
                                {
                                    printf("down");
                                }

                                if (k == -1)
                                {
                                    printf("up");
                                }

                                if (l != 0 && k != 0)
                                {
                                    printf(" and to the ");
                                }

                                if (l == 1)
                                {
                                    printf("right");
                                }

                                if (l == -1)
                                {
                                    printf("left");
                                }

                                printf(" for a total of %d time", foundCount + 1);

                                if (foundCount > 0)
                                {
                                    printf("s");
                                }
                                
                                printf("!\n");
                                foundCount++;
                            }
                        }
                    }
                }
            }

            //Indicate that the word was not found if the found counter was never incremented
            if (foundCount == 0)
            {
                printf("%s was not found!", enteredWord);
            }

            printf("\n\n");

            goto displayMenu;

        case 'd':
            return 0;
        
        default:
            //Message to print if menu input doesn't match available options
            printf("Sorry, you must choose an option from the above menu!\nPlease try again: ");
            scanf(" %c", &menuSelection);
            goto menuValidate;
    }
}//End of main