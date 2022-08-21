#!/bin/sh

b=1

for((a=1; a<=25; a++))
do 
	((b+=2))
	echo "$a","$b"
done


#1,3 / 2,5 이 순으로 진행