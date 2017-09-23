#!/bin/bash
git status -s;git add .;echo -n "→ ";read COMMITMSG;git commit -am "$COMMITMSG" -s;git push origin master -q;clear;exit