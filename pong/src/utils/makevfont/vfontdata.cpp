
#include "vfontdata.h"
#include "fileimage.h"



VFontData::VFontData()
{
	m_BitmapCharWidth = m_BitmapCharHeight = 0;
	m_pBitmap = NULL;
}

VFontData::~VFontData()
{
	if(m_pBitmap)
		delete [] m_pBitmap;
}



bool LoadVFontDataFrom32BitTGA(FileImageStream *fp, VFontData *pData)
{
	FileImage fileImage;
	unsigned char *pInLine, *pOutLine;
	int i, x, y;
	int rightX;

	
	if(!Load32BitTGA(fp, &fileImage))
		return false;

	pData->m_pBitmap = new unsigned char[fileImage.m_Width * fileImage.m_Height];
	if(!pData->m_pBitmap)
		return false;

	pData->m_BitmapCharWidth = fileImage.m_Width / NUM_VFONT_CHARS;
	pData->m_BitmapCharHeight = fileImage.m_Height;

	// Convert the data and figure out the extents of each letter.
	for(i=0; i < NUM_VFONT_CHARS; i++)
	{
		pInLine = &fileImage.m_pData[i * pData->m_BitmapCharWidth * 4];
		pOutLine = &pData->m_pBitmap[i * pData->m_BitmapCharWidth];
		
		rightX = 0;
		for(y=0; y < pData->m_BitmapCharHeight; y++)
		{
			for(x=0; x < pData->m_BitmapCharWidth; x++)
			{
				if(*((long*)&pInLine[x*4]))
				{
					pOutLine[x] = 1;
					if(x > rightX)
						rightX = x;
				}
				else
				{
					pOutLine[x] = 0;
				}
			}

			pInLine += pData->m_BitmapCharWidth * NUM_VFONT_CHARS * 4;
			pOutLine += pData->m_BitmapCharWidth * NUM_VFONT_CHARS;
		}

		// Wouldn't normally detect any spacing for the space character..
		if(i == ' ')
			pData->m_CharWidths[i] = pData->m_BitmapCharWidth / 4;
		else
			pData->m_CharWidths[i] = rightX;
	}

	return true;
}



