#include "GpuHelper.cuh"
 void GpuHelper::selectGpu(int *devsNum, int *gpuNum) {
	int best = *gpuNum;   // �õ�ϵͳ��NVIDIA GPU����Ŀ
	cudaGetDeviceCount(devsNum);
	if (*devsNum > 1) {
		int devId;
		int maxCores = 0;
		for (devId = 0; devId < *devsNum; devId++) {
			cudaDeviceProp devProperties;
			cudaGetDeviceProperties(&devProperties, devId);
			if (maxCores < devProperties.multiProcessorCount) {
				maxCores = devProperties.multiProcessorCount;//���ദ����(SM)�ĸ���
				best = devId;
			}
		}
		*gpuNum = best;
	}
}

void GpuHelper::testDevice(int devId) {
	cudaDeviceProp devProp;
	cudaGetDeviceProperties(&devProp, devId);
	//CUDA Capability Major/Minor version number
	if (devProp.major == 9999 && devProp.minor == 9999) {
		//printf("No device supporting CUDA.\n");
		cudaThreadExit();
	}
	else
		//printf("Using GPU device number %d.\n", devId);
		return;
}