import re

"""
"""

def clean(fo, allowed = r'[a-zA-Z0-9]', replace = ''):
	is_okay = re.compile(allowed).match
	while 1:
		data = fo.read()
		if not len(data):
			break
		for c in data:
			if is_okay(c):
				yield c
			elif replace:
				yield replace

def main():
	import sys
	for c in clean(sys.stdin, replace = '_'):
		sys.stdout.write(c)

if __name__ == '__main__':
	main()