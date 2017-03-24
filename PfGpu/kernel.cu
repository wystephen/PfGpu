
#include "cuda_runtime.h"
#include "device_launch_parameters.h"

#include <stdio.h>

#include <iostream>

#include "CSVReader.h"
#include "time_stamp.h"


int main()
{
	//Load Data
	CSVReader rawdatafile("C:\\Users\\steve\\Documents\\Visual\ Studio\ 2015\\Projects\\PfGpu\\Debug\\5UwbData.data.csv");
	
	CSVReader resultdatafile("C:\\Users\\steve\\Documents\\Visual\ Studio\ 2015\\Projects\\PfGpu\\Debug\\5RealPose.csv");
	CSVReader beacondatafile("C:\\Users\\steve\\Documents\\Visual\ Studio\ 2015\\Projects\\PfGpu\\Debug\\5beaconset.data.csv");
	//CSVReader datafile("C:\\Users\\steve\\Documents\\Visual\ Studio\ 2015\\Projects\\PfGpu\\Debug\\5UwbData.data.csv");
	//std::cout << "test:kkkk:" << std::endl;
	std::cout << "raw uwb data:" << rawdatafile.GetMatrix().GetRows()<<":"
		<< rawdatafile.GetMatrix().GetCols() << std::endl;

	std::cout << "result data :" << resultdatafile.GetMatrix().GetRows()<<":"
		<< resultdatafile.GetMatrix().GetCols() << std::endl;

	std::cout << "beaconset :" << beacondatafile.GetMatrix().GetRows()<<":"
		<< beacondatafile.GetMatrix().GetCols() << std::endl;

	int beacon_num = rawdatafile.GetMatrix().GetCols() - 1;
	int raw_num_times = rawdatafile.GetMatrix().GetRows();
	int dimisional = 3;
	double z_offset = 1.12;

	double *h_raw = new double[(beacon_num + 1)*(raw_num_times + 1)];
	double *h_beaconset = new double[(beacon_num + 1)*dimisional];
	double *h_result = new double[(dimisional)*(raw_num_times + 1)];

	for(int i(0);i<raw_num_times;i++)
	{
		for(int j(0);j<beacon_num;++j)
		{
			h_raw[i, j] = *rawdatafile.GetMatrix()(i, j + 1);
		}
	}

	for(int i(0);i<beacon_num;++i)
	{
		for(int j(0);j<dimisional;++j)
		{
			h_beaconset[i, j] = *beacondatafile.GetMatrix()(i, j);
		}
	}

	for(int i(0);i<raw_num_times;++i)
	{
		for(int j(0);j<dimisional;++j)
		{
			h_result[i, j] = *resultdatafile.GetMatrix()(i, j);
		}
	}

	//Save to array
	double *d_raw;
	double *d_beaconset;
	cudaMalloc((void**)&d_raw, (beacon_num + 1)*(raw_num_times + 1) * sizeof(double));
	cudaMalloc((void**)&d_beaconset, (beacon_num + 1)*(dimisional) * sizeof(double));


	//PF
	int particle_num = 10000;
	double *p_state = NULL;
	double *p_score = NULL;

	cudaMalloc((void**)&p_state, particle_num*dimisional * sizeof(double));
	cudaMalloc((void **)&p_score, particle_num * 1 * sizeof(double));



	//Sample

	//Evaluate

	//Get result


	//Resample

	//Compute error


	//save output.

	int a(0);
	std::cin >> a;
	return 0;

}

