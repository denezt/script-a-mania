#!/bin/bash

map(){
	f=$1
	shift
	for x
	do
		$f $x
	done
}

export -f map

reduce(){
    acc=$1
    f=$2
    shift
    shift
    for curr
    do
        acc=$($f $acc $curr)
    done
    echo $acc
}

export -f reduce
