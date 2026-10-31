#!/bin/bash

rm *.svg

echo '["case",'

echo -n '["has", "maxweight"], ["coalesce", ["image", ["concat", "B13-maxweight-", ["step", ["get", "maxweight"], "X"'
for n in X 1,5 2 2,5 2,8 3 3,5 4 5 5,5 6 7 7,5 8 9 10 12 15 16 18 19 20 24 25 26 30 32 40 44 48 52 64 72 74 94 120; do
    cat models/B13-maxweight.svg | sed -e "s/>7,5</>${n}</g" > B13-maxweight-${n}.svg
    cat models/B13-maxweight.svg | sed -e "s/>7,5</>${n}</g" -e "s/fill:#FFFFFF/fill:#C0C0C0/i" > B13-maxweight-${n}-conditional.svg
    if [ "$n" != "X" ]; then
        echo -n ", ${n/,/.}, \"${n}\""
    fi
done
echo "], [\"case\", [\"has\", \"maxweight:conditional\"], \"-conditional\", \"\"]]], [\"image\", \"B13-maxweight-X\"]],"

echo -n '["has", "maxwidth"], ["coalesce", ["image", ["concat", "B11-maxwidth-", ["step", ["get", "maxwidth"], "X"'
for n in X 0,5 0,8 0,9 1 1,1 1,2 1,3 1,4 1,5 1,6 1,7 1,8 1,9 2 2,1 2,2 2,3 2,4 2,5 2,6 2,7 2,8 2,9 3 3,4 3,5 4 4,2 4,5 5 6 8 10 12; do
    cat models/B11-maxwidth.svg | sed -e "s/>5,5</>${n}</g" > B11-maxwidth-${n}.svg
    cat models/B11-maxwidth.svg | sed -e "s/>5,5</>${n}</g" -e "s/fill:#FFFFFF/fill:#C0C0C0/i" > B11-maxwidth-${n}-conditional.svg
    if [ "$n" != "X" ]; then
        echo -n ", ${n/,/.}, \"${n}\""
    fi
done
echo "], [\"case\", [\"has\", \"maxwidth:conditional\"], \"-conditional\", \"\"]]], [\"image\", \"B11-maxwidth-X\"]],"

echo -n '["has", "maxheight"], ["coalesce", ["image", ["concat", "B12-maxheight-", ["step", ["get", "maxheight"], "X"'
for n in X 1,8 1,9 1,95 2 2,05 2,1 2,2 2,3 2,4 2,5 2,6 2,7 2,8 2,9 3 3,1 3,2 3,3 3,4 3,5 3,6 3,7 3,8 3,9 4 4,1 4,2 4,3 4,4 4,5 4,6 4,7 4,8 4,9 5 5,4 5,5; do
    cat models/B12-maxheight.svg | sed -e "s/>5,5</>${n}</g" > B12-maxheight-${n}.svg
    cat models/B12-maxheight.svg | sed -e "s/>5,5</>${n}</g" -e "s/fill:#FFFFFF/fill:#C0C0C0/i" > B12-maxheight-${n}-conditional.svg
    if [ "$n" != "X" ]; then
        echo -n ", ${n/,/.}, \"${n}\""
    fi
done
echo "], [\"case\", [\"has\", \"maxheight:conditional\"], \"-conditional\", \"\"]]], [\"image\", \"B12-maxheight-X\"]],"

echo -n '["has", "maxlength"], ["coalesce", ["image", ["concat", "B10a-maxlength-", ["step", ["get", "maxlength"], "X"'
for n in X 5 5,5 6 6,5 7 7,5 8 9 9,5 10 11 12 13 14 15 16 18 20 22 25 30 35 40 45; do
    cat models/B10a-maxlength.svg | sed -e "s/>5,5</>${n}</g" > B10a-maxlength-${n}.svg
    cat models/B10a-maxlength.svg | sed -e "s/>5,5</>${n}</g" -e "s/fill:#FFFFFF/fill:#C0C0C0/i" > B10a-maxlength-${n}-conditional.svg
    if [ "$n" != "X" ]; then
        echo -n ", ${n/,/.}, \"${n}\""
    fi
done
echo "], [\"case\", [\"has\", \"maxlength:conditional\"], \"-conditional\", \"\"]]], [\"image\", \"B10a-maxlength-X\"]],"

cp models/B8-goods.svg B8-goods.svg
cat models/B8-goods.svg | sed -e "s/fill:#FFFFFF/fill:#C0C0C0/i" > B8-goods-conditional.svg
echo '["has", "goods"], "B8-goods",'
echo '["has", "hgv"], "B8-goods",'

echo '""]'
