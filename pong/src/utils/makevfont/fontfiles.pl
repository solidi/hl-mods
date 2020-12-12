
#####################################################################################
# FontFiles.pl
# Parses the VGUI scheme text files and generates font bitmaps.
# Font bitmaps go in valve\gfx\vgui\fonts or tfc\gfx\vgui\fonts.
#####################################################################################

#####################################################################################
# NOTE TO MOD AUTHORS
# Point gameDir at the game's root directory.
#####################################################################################


$gameDir = "..\\..\\..";

# Other paths
$searchDir = "$gameDir\\tfc";
$makevfontCmd = "release\\makevfont.exe";
$outDir = "$gameDir\\valve\\gfx\\vgui\\fonts";


# Open stuff and make sure it all exists.
open   (TESTFILE1, $makevfontCmd) or die "File $makevfontCmd doesn't exist, please edit the script to point to the right location.\n";
opendir(DIR,       $searchDir)    or die "Directory $searchDir doesn't exist, please edit the script to point to the right location.\n";
opendir(TESTDIR1,  $outDir)       or die "Directory $outDir doesn't exist, please edit the script to point to the right location.\n";


while($_ = readdir(DIR))
{
	if($_ =~ /_textscheme.txt/)
	{
		# Get the filename.
		$filename = $_;

		# Extract the prefix.
		s{
			(.*)_textscheme\.txt
		}{$1}x;
		$prefix = $_;

		# Parse it.
		$schemeName = "";
		$fontName = "";
		$fontSize = "";

		open(FILE, "$searchDir\\$filename") or die "Cannot open $filename for read!";
		while(<FILE>)
		{
			if($_ =~ /SchemeName.*=.*/)
			{
				# Get SchemeName.
				s{
					SchemeName.*=.*\"(.*)\"
				}{$1}x;
				s{(.*)\n}{$1}x; # For some reason, it captures the carriage return here..
				$schemeName = $_;
			}
			else
			{
				if($_ =~ /FontName.*=.*/)
				{
					# Get FontName.
					s{
						FontName.*=.*\"(.*)\"
					}{$1}x;
					s{(.*)\n}{$1}x; # For some reason, it captures the carriage return here..
					$fontName = $_;
				}
				else
				{
					if($_ =~ /FontSize.*=.*/)
					{
						# Get FontSize.
						s{
							FontSize.*=[ ]*(.*)
						}{$1}x;
						s{(.*)\n}{$1}x; # For some reason, it captures the carriage return here..
						$fontSize = $_;
					}
				}
			}

			if($schemeName =~ /.+/ && $fontName =~ /.+/ && $fontSize =~ /.+/)
			{
				# Ok, found a scheme.. generate a file for it.
				$cmd = "$makevfontCmd -font \"$fontName\" -pointsize $fontSize \"$outDir\\$prefix\_$schemeName.tga\"\n";
				print "$cmd";
				system("$cmd");
				print "\n";

				$schemeName = "";
				$fontName = "";
				$fontSize = "";
			}
		}		
	}
}


