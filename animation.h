#ifndef __ANIMATION_H__
#define __ANIMATION_H__

#include <avr/pgmspace.h>

template <size_t PIXELCOUNT>
class Animation {
  public:
	typedef uint8_t frameBufferType[PIXELCOUNT];
	typedef void (*displayFunctionType)(frameBufferType buffer);

	Animation(const uint8_t** frames, uint8_t frameCount, uint8_t colorDepth);

	void play(uint8_t repeats);

	uint8_t fps;
	displayFunctionType displayFunction;
	const uint8_t colorDepth;

  private:
	frameBufferType frameBuffer;
	frameBufferType frameBufferStep;
	const uint8_t** frames;
	const uint8_t frameCount;
};

// implementation: (template impls cannot be separate for most compilers)

template <size_t PIXELCOUNT>
Animation<PIXELCOUNT>::Animation(const uint8_t** frames, uint8_t frameCount, uint8_t colorDepth)
	: fps(15), colorDepth(colorDepth),
	  frames(frames), frameCount(frameCount)
{}

template <size_t PIXELCOUNT>
void Animation<PIXELCOUNT>::play(uint8_t repeats = 1) {
	// calculating some things
	const uint8_t shades = 1 << colorDepth;
	const uint16_t X = 222U; // trying to guesstimate the factor to have 1 Hz last 1 second (depends heavily on optimazation; the lower this factor, the 'longer' a Hz lasts)
	const uint16_t hz = F_CPU / shades / fps / X; // setting the maximum Hz we can get with the desired depth & fps
	for (; repeats; --repeats) {
		for (uint8_t frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
			// load frame
			memcpy_P(&frameBuffer, frames[frameIndex], PIXELCOUNT);
			// display frame
			for (uint16_t hzi = 0; hzi < hz; ++hzi) {
				for (uint8_t shadesi = 0; shadesi < shades; ++shadesi) {
					// convert full depth frame for output (binary)
					for (uint8_t stepi = 0; stepi < PIXELCOUNT; ++stepi) {
						frameBufferStep[stepi] = shadesi < frameBuffer[stepi];
					}
					displayFunction(frameBufferStep);
				}
			}
		}
	}
}

#endif
