echo "run test on ./best"
./best > test1/1.out
./best 20 > test1/2.out
./best xyz >  test1/3.out
DIFF=$(diff test1/1.out test1/1.exp) 
if [ "$DIFF" != "" ] 
then
    echo "wrong answer on case 1"
else
    echo "pass test 1"
fi
DIFF=$(diff test1/2.out test1/2.exp) 
if [ "$DIFF" != "" ] 
then
    echo "wrong answer on case 2"
else
    echo "pass test 2"
fi
DIFF=$(diff test1/3.out test1/3.exp) 
if [ "$DIFF" != "" ] 
then
    echo "wrong answer on case 3"
else
    echo "pass test 3"
fi


echo "run test on ./rels"
./rels > test2/1.out
./rels xyzzy > test2/2.out
./rels ocean > test2/3.out
./rels "Ocean's Eleven" > test2/4.out
./rels 'Lemonade Joe' > test2/5.out
./rels 'Ne Zha' > test2/6.out
DIFF=$(diff test2/1.out test2/1.exp) 
if [ "$DIFF" != "" ] 
then
    echo "wrong answer on case 1"
else
    echo "pass test 1"
fi
DIFF=$(diff test2/2.out test2/2.exp) 
if [ "$DIFF" != "" ] 
then
    echo "wrong answer on case 2"
else
    echo "pass test 2"
fi
DIFF=$(diff test2/3.out test2/3.exp) 
if [ "$DIFF" != "" ] 
then
    echo "wrong answer on case 3"
else
    echo "pass test 3"
fi
DIFF=$(diff test2/4.out test2/4.exp) 
if [ "$DIFF" != "" ] 
then
    echo "wrong answer on case 4"
else
    echo "pass test 4"
fi
DIFF=$(diff test2/5.out test2/5.exp) 
if [ "$DIFF" != "" ] 
then
    echo "wrong answer on case 5"
else
    echo "pass test 5"
fi
DIFF=$(diff test2/6.out test2/6.exp) 
if [ "$DIFF" != "" ] 
then
    echo "wrong answer on case 6"
else
    echo "pass test 6"
fi


echo "run test on ./minfo"
./minfo xyzzy > test3/1.out
./minfo 'Avatar' > test3/2.out
./minfo 'The Ring' > test3/3.out
./minfo '^The Ring$' 2002 > test3/4.out
./minfo 'return of the king' > test3/5.out
./minfo 'strangelove' 1964 > test3/6.out
./minfo 'stars' xyzzy > test3/7.out
./minfo 'return of the king' 1234 > test3/8.out
./minfo ring 2002 > test3/9.out

DIFF=$(diff test3/1.out test3/1.exp) 
if [ "$DIFF" != "" ] 
then
    echo "wrong answer on case 1"
else
    echo "pass test 1"
fi

DIFF=$(diff test3/2.out test3/2.exp) 
if [ "$DIFF" != "" ] 
then
    echo "wrong answer on case 2"
else
    echo "pass test 2"
fi

DIFF=$(diff test3/3.out test3/3.exp) 
if [ "$DIFF" != "" ] 
then
    echo "wrong answer on case 3"
else
    echo "pass test 3"
fi


DIFF=$(diff test3/4.out test3/4.exp) 
if [ "$DIFF" != "" ] 
then
    echo "wrong answer on case 4"
else
    echo "pass test 4"
fi


DIFF=$(diff test3/5.out test3/5.exp) 
if [ "$DIFF" != "" ] 
then
    echo "wrong answer on case 5"
else
    echo "pass test 5"
fi


DIFF=$(diff test3/6.out test3/6.exp) 
if [ "$DIFF" != "" ] 
then
    echo "wrong answer on case 6"
else
    echo "pass test 6"
fi


DIFF=$(diff test3/7.out test3/7.exp) 
if [ "$DIFF" != "" ] 
then
    echo "wrong answer on case 7"
else
    echo "pass test 7"
fi


DIFF=$(diff test3/8.out test3/8.exp) 
if [ "$DIFF" != "" ] 
then
    echo "wrong answer on case 8"
else
    echo "pass test 8"
fi


DIFF=$(diff test3/9.out test3/9.exp) 
if [ "$DIFF" != "" ] 
then
    echo "wrong answer on case 9"
else
    echo "pass test 9"
fi


echo "run test on ./bio"
./bio > test4/1.out
./bio xyzzy > test4/2.out
./bio 'Kyle MacLachlan' > test4/3.out
./bio 'jacques tati' > test4/4.out
./bio 'spike lee' > test4/5.out

DIFF=$(diff test4/1.out test4/1.exp) 
if [ "$DIFF" != "" ] 
then
    echo "wrong answer on case 1"
else
    echo "pass test 1"
fi
DIFF=$(diff test4/2.out test4/2.exp) 
if [ "$DIFF" != "" ] 
then
    echo "wrong answer on case 2"
else
    echo "pass test 2"
fi
DIFF=$(diff test4/3.out test4/3.exp) 
if [ "$DIFF" != "" ] 
then
    echo "wrong answer on case 3"
else
    echo "pass test 3"
fi
DIFF=$(diff test4/4.out test4/4.exp) 
if [ "$DIFF" != "" ] 
then
    echo "wrong answer on case 4"
else
    echo "pass test 4"
fi
DIFF=$(diff test4/5.out test4/5.exp) 
if [ "$DIFF" != "" ] 
then
    echo "wrong answer on case 5"
else
    echo "pass test 5"
fi

rm test1/*.out test2/*.out test3/*.out test4/*.out

