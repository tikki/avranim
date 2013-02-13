#include <avr/io.h>

#include "animation.h"

#include "frames.h"

#define frameSize (3 * 3)

/*
naming:
	A1 A2 A3
	B1 B2 B3
	C1 C2 C3
*/
union Pb {
	uint8_t pb;
	char : 7;
	bool b3:1;
};
union Pd {
	uint8_t pd;
	struct {
		bool c1:1;
		bool c2:1;
		bool c3:1;
		bool b1:1;
		bool b2:1;
		bool a1:1;
		bool a2:1;
		bool a3:1;
	};
};

void render(Animation<frameSize>::frameBufferType buffer) {
	Pd pd;
	pd.a1 = buffer[0];
	pd.a2 = buffer[1];
	pd.a3 = buffer[2];
	pd.b1 = buffer[3];
	pd.b2 = buffer[4];
	PORTB = buffer[5];
	pd.c1 = buffer[6];
	pd.c2 = buffer[7];
	pd.c3 = buffer[8];
	PORTD = pd.pd;
}

int main() {
	// set up ports (define outputs)
	DDRD = 0b11111111;
	DDRB = 0b00000001;
	// define Animation
	const uint8_t frameCount = sizeof(_frames) / sizeof(uint8_t*);
	Animation<frameSize> animation(_frames, frameCount, 3);
	animation.fps = 1;
	animation.displayFunction = &render;
	// start playing
	for (;;) {
		animation.play(0xff);
	}
}

