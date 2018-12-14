#include <fstream>
#include <iostream>
#include <regex>
#include <cstdlib>
#include <chrono>

/// Essentially this puzzle is just tracking overlapping boxes. Part one counts the number of overlaps and part two
/// tracks which box has no overlaps. Approaching this puzzle a bit more DoD. Allocating the size of the arrays based
/// on the actual data (number of boxes, size of grid, etc) rather than trying to make something flexible.

const int k_fabricDimension = 1000;
const int k_fabricArea = k_fabricDimension * k_fabricDimension;
const int k_numClaims = 1295;
const std::regex k_areaDescParseRegex("#([0-9]+) @ ([0-9]+),([0-9]+): ([0-9]+)x([0-9]+)");

struct AreaDesc
{
	int m_id;
	int m_x;
	int m_y;
	int m_width;
	int m_height;
};

//Mutable data
struct GridCellData
{
	int m_overlaps;
	int m_ownerId;
};

/// Line is formatted like #1 @ 35,93: 11x13 - #id @ rightMargin,topMargin: WxH
/// This function just converts it to actual numbers
///
AreaDesc ParseAreaDesc(const std::string& toParse)
{
	std::smatch matches;
	std::regex_match(toParse, matches, k_areaDescParseRegex);

	AreaDesc desc;
	desc.m_id = std::atoi(matches[1].str().c_str());
	desc.m_x = std::atoi(matches[2].str().c_str());
	desc.m_y = std::atoi(matches[3].str().c_str());
	desc.m_width = std::atoi(matches[4].str().c_str());
	desc.m_height = std::atoi(matches[5].str().c_str());
	return desc;
}

/// Plot the area on the grid.
/// Increments the count for each cell of how many claims overlap that cell
/// Flags claimants as being overlapped or not
///
void PlotArea(AreaDesc areaDesc, GridCellData* fabricGrid, char* claimantOverlapFlags)
{
	for(int x=0; x<areaDesc.m_width; ++x)
	{
		for(int y=0; y<areaDesc.m_height; ++y)
		{
			int index = (areaDesc.m_x + x) + k_fabricDimension * (areaDesc.m_y + y);
			int ownerId = fabricGrid[index].m_ownerId;
			fabricGrid[index].m_overlaps++;
			fabricGrid[index].m_ownerId = areaDesc.m_id;

			//If there is already an owner of this cell (>=1) then both claimants are flagged as overlapping
			//If there is no ownerId (==0) then the claimant writing is not flagged
			claimantOverlapFlags[ownerId] = 1;
			claimantOverlapFlags[areaDesc.m_id] = 1 * ownerId;
		}
	}
}

/// Calculate the number of overlapped cells - the grid tracks the number of assignments to each cell
/// so just find the total number that have more than 1 occupant
///
int PartOne(GridCellData* const fabricGrid)
{
	int overlaps = 0;
	for(int i=0; i<k_fabricArea; ++i)
	{
		if(fabricGrid[i].m_overlaps > 1)
		{
			++overlaps;
		}
	}
	return overlaps;
}

/// Return the Id of the claim that overlaps nothing by finding the first claimant with
/// no overlap flag
///
int PartTwo(char* const claimantOverlapFlags)
{
	for(int i=0; i<k_numClaims; ++i)
	{
		if(claimantOverlapFlags[i] == 0)
			return i;
	}

	return 0;
}

///
int main()
{
	std::chrono::high_resolution_clock::time_point t1 = std::chrono::high_resolution_clock::now();

	GridCellData* fabricGrid =  new GridCellData[k_fabricArea];
	for(int i=0; i<k_fabricArea; ++i)
	{
		fabricGrid[i] = GridCellData{0};
	}

	char* claimantOverlapFlags = new char[k_numClaims];
	for(int i=0; i<k_numClaims; ++i)
	{
		claimantOverlapFlags[i] = 0;
	}

	//Read the data from file and plot the claims on the fabric
	std::ifstream inputFile("/Users/taggames/Work/AdventOfCodeSolutions/2018/Day3/input.txt");
	std::string line;
    while (std::getline(inputFile, line))
    {
        PlotArea(ParseAreaDesc(line), fabricGrid, claimantOverlapFlags);
    }

	int overlaps = PartOne(fabricGrid);
	int claimId = PartTwo(claimantOverlapFlags);

	//Don't need to delete as will be cleaned-up
	// delete[] fabricGrid;
	// delete[] claimantOverlapFlags;

	std::chrono::high_resolution_clock::time_point t2 = std::chrono::high_resolution_clock::now();
	std::chrono::duration<double> time_span = std::chrono::duration_cast<std::chrono::duration<double>>(t2 - t1);
	std::cout << "Time Taken " << time_span.count() << " seconds." << std::endl;

	std::cout << overlaps << std::endl;
	std::cout << claimId << std::endl;

	return 0;
}
