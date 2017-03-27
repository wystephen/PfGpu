
#include "cuda_runtime.h"
#include "device_launch_parameters.h"


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