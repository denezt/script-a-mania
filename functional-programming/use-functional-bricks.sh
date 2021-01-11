#!/bin/bash

double(){
	expr $1 '*' 2
}

square(){
	expr $1 '*' $1
}

input=$(seq 1 6)
square_after_double_output=$(map "square" $(map "double" $input))
echo "square_after_double_output $square_after_double_output"

sum(){
	expr $1 '+' $2
}

sum=$(reduce 0 "sum" $input)
echo "The sum is $sum"
