#!/usr/bin/python

"""converts any input (stdin) to a C array representation (stdout)
"""

def CArrayWithFileObject(fo, name):
	yield 'const unsigned char %s[] = {' % name
	yield hex(ord(fo.read(1)))
	while 1:
		data = fo.read()
		if not len(data):
			break
		for c in data:
			yield ', 0x%x' % ord(c)
	yield '};\n'

def main():
	import sys
	symbol = sys.argv[1]
	for c in CArrayWithFileObject(sys.stdin, symbol):
		sys.stdout.write(c)

if __name__ == '__main__':
	main()
