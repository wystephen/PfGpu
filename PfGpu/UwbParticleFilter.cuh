
#include "cuda_runtime.h"
#include "device_launch_parameters.h"
//#include "cu"

/*
Distance from x1,y1,z1,to x2,y2,z2;
*/

__device__ float distance(float x1,float y1,float z1,
	float x2,float y2,float z2)
{
	return sqrt((x1 - x2)*(x1 - x2) + (y1 - y2)*(y1 - y2) + (z1 - z2)*(z1 - z2));
}

/**
Norm pdf
*/
__device__ float norm_pdf(float x,float miu,float sigma)
{
	float para1 = 1 / (sqrt(2 * 3.1415926)*sigma);
	float para2 = -(x - miu)*(x - miu) / 2 / sigma / sigma;
	return para1 * exp(-para2);
}

/**
Initial Particle and score.
*/
__global__ void InitialParticle(float p_state[],
	float p_score[],
	float x,float y,float z,
	int particle_num)
{
	int index_x = blockDim.x*blockIdx.x+threadIdx.x;
	if(index_x < particle_num)
	{
		p_state[index_x*3] = x;
		p_state[index_x * 3 + 1] = y;
		p_state[index_x * 3 + 2] = 2.0-1.12;
		p_score[index_x] = 1.0 / particle_num;
		
		//printf("index x : %d \n", index_x);
	}
	//printf("block dim x :%d block id x : %d thread id : %d index id : %d\n", 
	//blockDim.x, blockIdx.x, threadIdx.x,index_x);

}

/*
Sample according to rnd x and rnd y.
*/
__global__ void Sample(float* p_state,
	float * rnd_x,
	float * rnd_y,
	int times,
	int particle_num)
{
	int index_x = blockDim.x * blockIdx.x + threadIdx.x;

	if(index_x<particle_num)
	{
		p_state[index_x * 3] += rnd_x[index_x];
		p_state[index_x * 3 + 1] += rnd_y[index_x];
	}
	//printf("inde x : %d,x:%f,y%f,/n",index_x,p_state[index_x*3],p_state[index_x*3+1]);
}

/*
Evaluate each particle according to raw_data,without normalize.
*/
__global__ void Evaluate(float * p_state,
	float * p_score,
	float * beacon_set,
	int beacon_num,
	float * raw_data,
	float eval_sigma,
	int particle_num)
{
	int index_x = blockDim.x * blockIdx.x + threadIdx.x;

	if(index_x < particle_num)
	{
		// for every particle 

		float score(1.0);

		// sum of all probability.
		for(int i(0);i<beacon_num;++i)
		{
			score *= (norm_pdf(raw_data[i], 
				distance(p_state[index_x],p_state[index_x+1],1.12,
					beacon_set[i*3],beacon_set[i*3+1],beacon_set[i*3+2]), 
				eval_sigma)+1e-20);
		}
		p_score[index_x] *= score;
	}
}

/*
normalize p_score
*/
__global__ void Normalized(float * p_score,int particle_num)
{
	int index_x = blockDim.x * blockIdx.x + threadIdx.x;

	// Sum 
	
	// __ syncthreads
	//__syncthreads();
	//cudaDeviceSynchronize();


	// normalize
}

/*
Get result
*/
__global__ void GetResult(float *p_state,float *p_score,int particle_num
,float * res)
{
	int index_x = blockDim.x * blockIdx.x + threadIdx.x;
	// SUM
	if(index_x<particle_num)
	{
		float tmp_score = p_score[index_x];
		float tmp_x = p_state[index_x * 3];
		float tmp_y = p_state[index_x * 3 + 1];
		float tmp_z = p_state[index_x * 3 + 2];


	}

	
}

/*
Resample
*/
__global__ void ReSample(float *p_state,float *p_score,int particle_num)
{
	int index_x = blockDim.x * blockIdx.x + threadIdx.x;
	// Resample

	// syncthreads....

	// write to p_state and p_score

}

