
#ifndef __VFONTDATA_H__
#define __VFONTDATA_H__


	#include <stdio.h>
	#include "fileimage.h"


	#define NUM_VFONT_CHARS	256

	
	class VFontData
	{
	public:
						VFontData();
						~VFontData();

		// Line width in pixels.
		int				GetLineWidth()	{return m_BitmapCharWidth * NUM_VFONT_CHARS;}


	public:
		
		int				m_CharWidths[NUM_VFONT_CHARS];
		
		// The letters are placed in the bitmap at constant spacing.
		// m_CharWidths is used while drawing.
		int				m_BitmapCharWidth;
		int				m_BitmapCharHeight;

		// Each pixel is a byte - 1 or 0.
		unsigned char	*m_pBitmap;
	};


	// Setup a VFontData from a TGA file.
	bool LoadVFontDataFrom32BitTGA(FileImageStream *fp, VFontData *pData);


#endif



