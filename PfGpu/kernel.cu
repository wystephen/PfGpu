
#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include <cuda.h>
#include <curand.h>

#include <stdio.h>

#include <iostream>

#include "CSVReader.h"
#include "time_stamp.h"

#include "UwbParticleFilter.cuh"
#include <curand_globals.h>
#pragma comment(lib,"cudart.lib")
#pragma comment(lib,"curand.lib")

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
	float z_offset = 1.12;

	float *h_raw = new float[(beacon_num )*(raw_num_times)];
	float *h_beaconset = new float[(beacon_num + 1)*dimisional];
	float *h_result = new float[(dimisional)*(raw_num_times )];

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
	float *d_raw;
	float *d_beaconset;
	cudaMalloc((void**)&d_raw, (beacon_num )*(raw_num_times ) * sizeof(float));
	cudaMalloc((void**)&d_beaconset, (beacon_num )*(dimisional) * sizeof(float));
	
	cudaMemcpy(d_raw, h_raw, (beacon_num)*(raw_num_times)*sizeof(float),cudaMemcpyHostToDevice);
	cudaMemcpy(d_beaconset, h_beaconset, (beacon_num )*(dimisional) * sizeof(float), cudaMemcpyHostToDevice);


	//PF
	int particle_num = 10000;
	double sample_sigma = 0.5;

	int thread_dim_x = 100;


	float *p_state = NULL;
	float *p_score = NULL;
	float *rnd_x = NULL;
	float *rnd_y = NULL;

	cudaMalloc((void**)&p_state, particle_num*dimisional * sizeof(float));
	cudaMalloc((void **)&p_score, particle_num * 1 * sizeof(float));
	cudaMalloc((void **)&rnd_x, particle_num * 1 * sizeof(float));
	cudaMalloc((void **)&rnd_y, particle_num * 1 * sizeof(float));

	//Random generator 
	curandGenerator_t gen;
	curandCreateGenerator(&gen, CURAND_RNG_PSEUDO_DEFAULT);
	curandSetPseudoRandomGeneratorSeed(gen, long long(TimeStamp::now()*100));

	//INITIAL
	//-9.9777 - 6.0391	1.4184
	InitialParticle <<<ceil(particle_num/thread_dim_x),thread_dim_x >>> (p_state, p_score,
		-9.977, -6.0391, 1.4184,
		particle_num);
	


	//Sample
	curandGenerateNormal(gen, rnd_x, particle_num , 0.0, sample_sigma);
	curandGenerateNormal(gen, rnd_y, particle_num , 0.0, sample_sigma);
	Sample <<<ceil(particle_num / thread_dim_x), thread_dim_x >>> (p_state, rnd_x, rnd_y,
		1, particle_num);

	//Evaluate
	//COMMIT


	//Get result


	//Resample

	//Compute error


	//save output.
	float *h_p_state = new float[particle_num*dimisional];
	float *h_p_score = new float[particle_num];
	cudaMemcpy(h_p_state,p_state, particle_num*dimisional * sizeof(float), cudaMemcpyDeviceToHost);
	cudaMemcpy(h_p_score,p_score, particle_num * sizeof(float), cudaMemcpyDeviceToHost);
	for(int i(0);i<particle_num;++i)
	{
		for(int j(0);j<dimisional;++j)
		{
			std::cout << h_p_state[i*dimisional + j] << "-";
		}
		std::cout << std::endl;
		std::cout << h_p_score[i] << "   =====" << std::endl;
	}

	int a(0);
	std::cin >> a;

	cudaFree(d_raw);
	cudaFree(d_beaconset);

	return 0;

}

