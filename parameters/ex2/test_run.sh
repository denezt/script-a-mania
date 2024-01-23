#!/bin/bash

for rng in {123..4..1};
do
	./storing_values.sh -n 90 -o '-' -p $((${rng}+${RANDOM}/4));
done
