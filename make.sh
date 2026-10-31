#!/bin/bash

as breakout.s -o breakout.o
as data.s -o data.o

ld data.o breakout.o -o breakout
./breakout
echo $?
