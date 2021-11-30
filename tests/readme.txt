Notes: 
 - All inputs are free of syntax / semantic errors.
 - The sample output (.s)files are provided for your reference. 
   You do NOT have to match the sample output exactly.
 - You should assemble the generated .s files using gcc to get
   an executable.  You can then run the executable to verify
   whether the translation result shows the expected behavior.
 - From the output/ folder, You can use "../s2exe.sh testX" 
   to generate an executable named testX from testX.s for testing. 

test0.tog: empty program that does nothing.

test1.tog: printstring with a string literal. 
           Expected: string printed out ("Hello World!\n")

test2.tog: printint with a constant. 
           Expected: number printed out. (440)
test3.tog: printint with an arithmetic expression with constants only.
           Expected: result printed out. (5*8 - 3*2 = 34)

test4.tog: getint saved in global variable, print and return.
           Expected: accept an integer input from user and print that input.
           (You can use "echo $?" right after running the executable to 
            verify the return (use a number within [0, 255].)

test5.tog: global variable, assignments, expression, print.
           Exprected: print out the value of variable. (34)
test6.tog: global variable used in expression, print.
           Expected: print out the value of variable. (10)

test7.tog: if, print.
           Expected: print out constant. (5)
test8.tog: if-else, getint, print.
           Expected: based on the input, print ">3" or "<=3".

test9.tog: loop, print.
           Expected: iteative factorial(5), print 120.

test10.tog: function call, no parameter, no return value, no local data.
            Expected: print out 0 and 1
            (sample output using static allocation)

test11.tog: sequence of function calls, no parameter, 
            no return value, no local data.
            Expected: print out 1 and 2
            (sample output using stack allocation)

test12.tog: function call w/ parameter, no return value, no local data.
            Expected: print out 440 and 360
            (sample output using static allocation)

test13.tog: function calls w/ parameter and return value, no local data.
            Expected: print out 440
            (sample output using stack allocation)
           
test14.tog: function w/ local variable
            Expected: print out 10
            (sample output using static allocation)

test15.tog: function w/ local variable, if-stmt inside function
            Expected: print out 5
            (sample output using stack allocation)

