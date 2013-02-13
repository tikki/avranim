#!/bin/sh
PYTHON_PATH="/usr/bin/python"
#
echo "#ifndef __FRAMES_H__"
echo "#define __FRAMES_H__"
echo "#include <avr/pgmspace.h>"
i=0
for image in *.bmp; do
	SYMBOL=`/bin/echo -n _frame_${image%%.*} | python clean.py`
	echo "extern PROGMEM const uint8_t ${SYMBOL}[];"
	let "i += 1"
done
echo "extern const uint8_t* _frames[${i}];"
echo "#endif"
