// makevfont.cpp : Defines the entry point for the console application.
//

#include "stdafx.h"
#include "fileimage.h"
#include "vfontdata.h"




bool CreateVFont(
	char *pOutFile,
	char *pFontName,
	int pointSize,
	bool bItalic,
	bool bBold,
	bool bUnderline)
{
	HFONT hFont, hOldFont;
	int i;
	char theChar;
	SIZE charSize;
	int bitmapCharWidth, bitmapCharHeight;
	HDC hDC, hMemDC;
	bool bRet;
	RECT rc, rcChar;
	HBITMAP hBitmap, hOldBitmap;
	BITMAPINFOHEADER *pbmheader;
	BITMAPINFO tempbmi;
	BITMAPINFO *pbmi;
	unsigned char *bits;
	int nScans;
	FileImage fileImage;
	FILE *fp;


	hFont = hOldFont = NULL;
	hDC = hMemDC = NULL;
	hBitmap = hOldBitmap = NULL;
	pbmi = NULL;
	bRet = true;


	// Make the font.
	hFont = CreateFont(
		pointSize, 
		0, 
		0, 
		0, 
		bBold ? FW_HEAVY : FW_MEDIUM, 
		bItalic, 
		bUnderline, 
		0, 
		ANSI_CHARSET, 
		OUT_TT_PRECIS, 
		CLIP_DEFAULT_PRECIS, 
		PROOF_QUALITY, 
		VARIABLE_PITCH | FF_DONTCARE, 
		pFontName);
	
	if(!hFont)
	{
		printf("CreateFont failed!\n");
		goto HANDLE_ERROR;
	}

	hDC		= GetDC(NULL);
	hMemDC	= CreateCompatibleDC(hDC);
	if(!hMemDC)
	{
		printf("CreateCompatibleDC failed!\n");
		goto HANDLE_ERROR;
	}
	hOldFont = (HFONT)SelectObject(hMemDC, hFont);

		// Figure out the biggest character.
		bitmapCharWidth = bitmapCharHeight = 0;
		for(i=0; i < NUM_VFONT_CHARS; i++)
		{
			theChar = (char)i;
			if(!GetTextExtentPoint32(hMemDC, &theChar, 1, &charSize))
			{
				printf("GetTextExtentPoint32 failed!\n");
				goto HANDLE_ERROR;
			}

			if(charSize.cx > bitmapCharWidth)
				bitmapCharWidth = charSize.cx;

			if(charSize.cy > bitmapCharHeight)
				bitmapCharHeight = charSize.cy;
		}

		// We get 1 pixel of padding because, for some reason, Windows likes to clip off the left pixel
		// on some letters like W.
		bitmapCharWidth++;

		// Setup our bitmap.
		hBitmap		= CreateBitmap(bitmapCharWidth * NUM_VFONT_CHARS, bitmapCharHeight, 1, 1, NULL); 
		if(!hBitmap)
		{
			printf("CreateBitmap failed!\n");
			goto HANDLE_ERROR;
		}
		hOldBitmap	= (HBITMAP)SelectObject(hMemDC, hBitmap);

		SetTextColor( hMemDC, 0x00ffffff );
		SetBkMode( hMemDC, TRANSPARENT );

		// Fill the background.
		rc.left = rc.top = 0;
		rc.right = bitmapCharWidth * NUM_VFONT_CHARS;
		rc.bottom = bitmapCharHeight;
		FillRect( hMemDC, &rc, (HBRUSH)GetStockObject( BLACK_BRUSH ) );

		// Draw characters in.
		for(i=0; i < NUM_VFONT_CHARS; i++)
		{
			// Draw the letter in the first slot for a letter.
			rcChar.left = 0;
			rcChar.top = 0;
			rcChar.right = bitmapCharWidth;
			rcChar.bottom = bitmapCharHeight;
			FillRect( hMemDC, &rcChar, (HBRUSH)GetStockObject( BLACK_BRUSH ) );

			if(i != '\t')
			{
				rcChar.left = 1; // 1-pixel border for letters like W...
				theChar = (char)i;
				DrawText(hMemDC, &theChar, 1, &rcChar, DT_NOPREFIX | DT_LEFT);

				// Blit into the correct spot (by drawing/blitting, it sort of automatically clips the letter into
				// its box (Windows seems to want to draw some of them out of their bounding box).
				rcChar.left = i * bitmapCharWidth;
				rcChar.top = 0;
				rcChar.right = (i+1) * bitmapCharWidth;
				rcChar.bottom = bitmapCharHeight;
				
				if(!BitBlt(hMemDC,
					i * bitmapCharWidth,
					0,
					bitmapCharWidth,
					bitmapCharHeight,
					hMemDC,
					0,
					0,
					SRCCOPY))
				{
					printf("BitBlt failed!\n");
					goto HANDLE_ERROR;
				}
			}
		}

		// Get the bits out.
		memset(&tempbmi, 0, sizeof(BITMAPINFO));
		pbmheader = ( BITMAPINFOHEADER * )&tempbmi;

		pbmheader->biSize	= sizeof( BITMAPINFOHEADER );
		pbmheader->biWidth	= bitmapCharWidth * NUM_VFONT_CHARS;
		pbmheader->biHeight	= -bitmapCharHeight; 
		pbmheader->biPlanes	= 1;
		pbmheader->biBitCount = 32;
		pbmheader->biCompression = BI_RGB;

		// Figure out how many bytes to allocate and setup a buffer.
		nScans = GetDIBits(hMemDC, hBitmap, 0, bitmapCharHeight, NULL, &tempbmi, DIB_RGB_COLORS);
		pbmi = ( BITMAPINFO * )malloc( sizeof ( BITMAPINFOHEADER ) + 2 * sizeof( RGBQUAD ) + pbmheader->biSizeImage );
		memcpy( pbmi, &tempbmi, sizeof( BITMAPINFO ) );
		bits = ( unsigned char * )pbmi + sizeof( BITMAPINFOHEADER ) + 2 * sizeof( RGBQUAD );
		
		// Read the bits in.
		nScans = GetDIBits(hMemDC, hBitmap, 0, bitmapCharHeight, bits, pbmi, DIB_RGB_COLORS);
		if(nScans == 0)
		{
			printf("GetDIBits failed!\n");
			goto HANDLE_ERROR;
		}
		
	
		// Save as a PCX/TGA file.
		fp = fopen(pOutFile, "wb");
		if(!fp)
		{
			printf("fopen(%s, \"wb\") failed!\n", pOutFile);
			goto HANDLE_ERROR;
		}

		fileImage.m_Width = bitmapCharWidth * NUM_VFONT_CHARS;
		fileImage.m_Height = bitmapCharHeight;
		fileImage.m_pData = (unsigned char*)bits;
		Save32BitTGA(fp, &fileImage);
		fileImage.Clear();
		
		fclose(fp);

	goto CLEANUP;


HANDLE_ERROR:;
	bRet = false;


CLEANUP:;
	if(hMemDC)
	{
		if(hOldBitmap)
			SelectObject(hMemDC, hOldBitmap);

		if(hOldFont)
			SelectObject(hMemDC, hOldFont);

		DeleteDC(hMemDC);
	}

	if(hBitmap)
	{
		DeleteObject(hBitmap);
	}

	if(hFont)
	{
		DeleteObject(hFont);
	}

	if(pbmi)
	{
		free(pbmi);
	}

	return true;
}


/*
// Writes out a test string to "testout.tga" using the font it just generated for debugging purposes.
void DoTest(char *pFilename)
{
	// TEST.
	FILE *fp;
	VFontData fontData;
	char *pStr = "Blah blah blah. This is a string of text I am printing out. \"Here is something in quotes, blah blah blah.\"";
	int len, curXOffset, iChar, width, x, y;
	HWND hWnd;
	HDC hDC;
	FileImage outImage;



	fp=fopen(pFilename, "rb");
	LoadVFontDataFrom32BitTGA(fp, &fontData);

	int spacing=1;

	len = strlen(pStr);
	outImage.m_Width = fontData.m_BitmapCharWidth * len + len*spacing;
	outImage.m_Height = fontData.m_BitmapCharHeight;
	outImage.m_pData = new unsigned char[outImage.m_Width * outImage.m_Height * 4];
	memset(outImage.m_pData, 0, outImage.m_Width*outImage.m_Height);

	hWnd = GetDesktopWindow();
	hDC = GetDC(hWnd);

		curXOffset = 0;
		for(iChar=0; iChar < len; iChar++)
		{
			width = fontData.m_CharWidths[(unsigned char)pStr[iChar]]+1;
			for(y=0; y < fontData.m_BitmapCharHeight; y++)
			{
				for(x=0; x < width; x++)
				{
					if(fontData.m_pBitmap[y*fontData.GetLineWidth()+x+(unsigned char)pStr[iChar]*fontData.m_BitmapCharWidth])
					{
						*((unsigned long*)&outImage.m_pData[(y*outImage.m_Width+curXOffset+x)*4]) = 0xFFFFFFFF;
					}
					else
					{
						*((long*)&outImage.m_pData[(y*outImage.m_Width+curXOffset+x)*4]) = 0;
					}
				}

				for(x=0; x < spacing; x++)
				{
					*((long*)&outImage.m_pData[(y*outImage.m_Width+curXOffset+width+x)*4]) = 0;
				}
			}

			curXOffset += width + spacing;
		}

	ReleaseDC(hWnd, hDC);

	fclose(fp);


	fp = fopen("testout.tga", "wb");
	Save32BitTGA(fp, &outImage);
	fclose(fp);
}
*/


int main(int argc, char* argv[])
{
	char fontName[256];
	int pointSize;
	bool bItalic, bBold, bUnderline;
	int i;


	// Setup defaults.
	strcpy(fontName, "Arial");
	pointSize = 7;
	bItalic = bBold = bUnderline = false;


	printf("makevfont.exe Version 1.0 by Valve (%s)\n", __DATE__ );
	printf ("----- Creating Font ----\n");


	// Read parameters in.
	for (i=1 ; i<argc ; i++)
	{
		if (!strcmp(argv[i],"-font"))
		{
			strcpy( fontName, argv[i+1] );
			i++;
		}
		else if (!strcmp(argv[i],"-pointsize"))
		{
			if (i + 1 >= argc )
			{
				printf( "MakeVFont:  Insufficient point sizes specified\n" );
				return -1;
			}
			pointSize = atoi( argv[i+1] );
			i += 1;
		}
		else if (!strcmp(argv[i],"-italic"))
		{
			bItalic = true;
			printf ( "italic set\n");
		}
		else if (!strcmp(argv[i],"-bold"))
		{
			bBold = true;
			printf ( "bold set\n");
		}
		else if (!strcmp(argv[i],"-underline"))
		{
			bUnderline = true;
			printf ( "underline set\n");
		}
		else if ( argv[i][0] == '-' )
		{
			printf("Unknown option \"%s\"", argv[i]);
			return -1;
		}
		else
			break;
	}

	if ( i != argc - 1 )
	{
		printf("usage: makevfont [-font \"fontname\"] [-italic] [-underline] [-bold] [-pointsize size] outfile");
		return -1;
	}

	CreateVFont(
		argv[argc-1],
		fontName,
		pointSize,
		bItalic,
		bBold,
		bUnderline);

	return 0;
}
