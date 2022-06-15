
include "../node_modules/circomlib/circuits/comparators.circom";

template Sudoku() {
    signal input unsolved[9][9];
    signal input solved[9][9];


    // Range check for solved 

    component LowerBound[9][9];
    component UpperBound[9][9];


    for (var i = 0; i < 9; i++) {
       for (var j = 0; j < 9; j++) {
           UpperBound[i][j] = LessEqThan(32);
           UpperBound[i][j].in[0] <== solved[i][j];
           UpperBound[i][j].in[1] <== 9;

           LowerBound[i][j] = GreaterEqThan(32);
           LowerBound[i][j].in[0] <== solved[i][j];
           LowerBound[i][j].in[1] <== 1;

           UpperBound[i][j].out ===  LowerBound[i][j].out;
        }
    }


    // if the unsolved board is not zero , solved[i][j] should be equal to unsolved[i][j] 
    // if the unsolved board is zero , solved[i][j] should be different 

    component equalBoard[9][9];
    component zeroBoard[9][9];

    for (var i = 0; i < 9; i++) {
       for (var j = 0; j < 9; j++) {
            equalBoard[i][j] = IsEqual();
            equalBoard[i][j].in[0] <== solved[i][j];
            equalBoard[i][j].in[1] <== unsolved[i][j];

            zeroBoard[i][j] = IsZero();
            zeroBoard[i][j].in <== unsolved[i][j];

            equalBoard[i][j].out === 1 - zeroBoard[i][j].out;
        }
    }


    // Check if each row in solved has all the numbers from 1 to 9, both included
    // For each element in solved, check that this element is not equal
    // to previous elements in the same row

    component ieRow[324];

    var indexRow = 0;


    for (var i = 0; i < 9; i++) {
       for (var j = 0; j < 9; j++) {
            for (var k = 0; k < j; k++) {
                ieRow[indexRow] = IsEqual();
                ieRow[indexRow].in[0] <== solved[i][k];
                ieRow[indexRow].in[1] <== solved[i][j];
                ieRow[indexRow].out === 0;
                indexRow ++;
            }
        }
    }


    // Check if each column in solved has all the numbers from 1 to 9, both included
    // For each element in solved, check that this element is not equal
    // to previous elements in the same column

    component ieCol[324];

    var indexCol = 0;


    for (var i = 0; i < 9; i++) {
       for (var j = 0; j < 9; j++) {
            for (var k = 0; k < i; k++) {
                ieCol[indexCol] = IsEqual();
                ieCol[indexCol].in[0] <== solved[k][j];
                ieCol[indexCol].in[1] <== solved[i][j];
                ieCol[indexCol].out === 0;
                indexCol ++;
            }
        }
    }


    // Check if each square in solved has all the numbers from 1 to 9, both included
    // For each square and for each element in each square, check that the
    // element is not equal to previous elements in the same square

    component ieSquare[324];

    var indexSquare = 0;

    for (var i = 0; i < 9; i+=3) {
       for (var j = 0; j < 9; j+=3) {
            for (var k = i; k < i+3; k++) {
                for (var l = j; l < j+3; l++) {
                    for (var m = i; m <= k; m++) {
                        for (var n = j; n < l; n++){
                            ieSquare[indexSquare] = IsEqual();
                            ieSquare[indexSquare].in[0] <== solved[m][n];
                            ieSquare[indexSquare].in[1] <== solved[k][l];
                            ieSquare[indexSquare].out === 0;
                            indexSquare ++;
                        }
                    }
                }
            }
        }
    }

}


component main {public [unsolved]} = Sudoku();