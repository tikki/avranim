#!/bin/sh
PYTHON_PATH="/usr/bin/python"
#
echo "#include \"frames.h\""
ALL_FRAMES=
for image in *.bmp; do
	SYMBOL=`/bin/echo -n _frame_${image%%.*} | python clean.py`
	$PYTHON_PATH bmp2bin.py 3 < $image | $PYTHON_PATH bin2carray.py $SYMBOL
	ALL_FRAMES="${ALL_FRAMES}, ${SYMBOL}"
done
echo "const unsigned char* _frames[] = {${ALL_FRAMES:2}};"
