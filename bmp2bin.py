#!/usr/bin/python

"""distills a BMP (given via stdin) to a monochrome (8bit by default) binary output
"""

def bitsFromByte(byte, size = 8):
	'''MSB first'''
	for i in range(size):
		yield (byte >> (size - i - 1)) & 1

def byteFromBits(bits, size = 8):
	'''MSB first'''
	byte = 0
	i = 0
	for bit in bits:
		byte |= bit << (size - i - 1)
		i += 1
	return byte

def distill8bit(fo, channel = 0):
	while 1:
		px = fo.read(4)
		if not len(px):
			break
		yield px[channel]

def distill(fo, bit = 8, channel = 0, compact = False):
	'''
	bit must be (0, 8]
		the depth (in bits) of the monochrome output, i.e. the resolution of luminocity per pixel
	channel is the channel (of your typical rgba image) to use for the monochrome output
		thus 0 = red, 1 = green, 2 = blue, 3 = alpha
	compact controls wether to align the output to 8bit or not
		e.g. compact = True with bit = 4 will pack 2 pixels in one byte
	'''
	fo.read(54) # discard the header
	if bit == 8:
		for c in distill8bit(fo):
			yield c
		return
	buf_in = ''
	buf_out = []
	while 1:
		data = fo.read(4)
		if not len(data):
			break
		buf_in += data
		if len(buf_in) >= 4:
			px, buf_in = buf_in[:4], buf_in[4:]
			monopx = ord(px[channel])
			monopx //= 2 ** (8 - bit) # map input to desired output depth
			if compact is False:
				yield chr(monopx)
			else:
				buf_out += list(bitsFromByte(monopx, bit))
				while 8 <= len(buf_out): # if we have enough data to output a char
					byte, buf_out = byteFromBits(buf_out[:8]), buf_out[8:]
					yield chr(byte)
	if buf_out:
		byte = byteFromBits(buf_out)
		yield chr(byte)

def main():
	import sys
	# depth is the amount of bits per pixel
	try:
		depth = int(sys.argv[1])
	except:
		depth = 8
	try:
		compact = bool(sys.argv[2])
	except:
		compact = False
	for c in distill(sys.stdin, bit = depth, compact = compact):
		sys.stdout.write(c)

if __name__ == '__main__':
	main()
