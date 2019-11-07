
// CUDA runtime �� + CUBLAS ��
#include <cublas_v2.h>
#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include"device_functions.h"

#include <cuda.h>
#include <stdio.h>
#include <math.h>
#include<iostream>
using namespace std;

using namespace std;

// ������Ծ����ά��
int  sizeT = 4096;
int  aW = sizeT;
int  aH = sizeT;
int  bW = sizeT;
int  bH = sizeT;
int  cW = bW;
int  cH = aH;
void mul_cpu(float * a, float * b, float * c) {
	for (int i = 0; i < aH; i++) {
		for (int j = 0; j < bW; j++) {
			c[i*bW + j] = 0;
			for (int k = 0; k < aW; k++) {
				c[i*bW + j] += (a[i*aW + k]) * (b[k*bW + j]);
			}
		}
	}
}
float check_diff(float * gpuC, float * cpuC) {
	float diff = 0;
	for (int i = 0; i < aH*bW; i++) {
		diff += abs(gpuC[i] - cpuC[i]);
	}
	return diff;
}

int matrix()
{
	// ����״̬����
	cublasStatus_t status;

	// �� �ڴ� ��Ϊ��Ҫ����ľ��󿪱ٿռ�
	float *h_A = (float*)malloc(aW*aH * sizeof(float));
	float *h_B = (float*)malloc(bW*bH * sizeof(float));

	// �� �ڴ� ��Ϊ��Ҫ����������ľ��󿪱ٿռ�
	float *h_C = (float*)malloc(cW*cH * sizeof(float));

	// �� �ڴ� ��Ϊ��Ҫ����������ľ��󿪱ٿռ�
	float *cpu_C = (float*)malloc(cW*cH * sizeof(float));

	//Ϊ����������Ԫ�ظ�ֵ
	for (int i = 0; i < aW*aH; ++i)
	{
		h_A[i] = (float)(rand() / (float)RAND_MAX);//(float)(rand() % 10);// (float)(rand() / (float)RAND_MAX); //(float)(rand() %10); (float)i;
	}
	for (int i = 0; i < bW*bH; ++i)
	{
		h_B[i] = (float)(rand() / (float)RAND_MAX);//(float)(rand() % 10);//  //(float)i*i;
	}
	//h_A[0] = 1; h_A[1] = 1;
	//h_B[0] = 2; h_B[1] = 1; h_B[2] = 0; h_B[3] = 1; h_B[4] = 3; h_B[5] = 0;



	//// ��ӡ�����Եľ���
	//cout << "���� A :" << endl;
	//for (int i = 0; i < aW*aH; i++) {
	//	cout << h_A[i] << " ";
	//	if ((i + 1) % aW == 0) cout << endl;
	//}
	//cout << endl;
	//cout << "���� B :" << endl;
	//for (int i = 0; i < bW*bH; i++) {
	//	cout << h_B[i] << " ";
	//	if ((i + 1) % bW == 0) cout << endl;
	//}
	//cout << endl;

	/*
	** GPU ����������
	*/

	
	float elapsedTime = 0.0;
	cudaEvent_t event_start, event_stop;
	cudaEventCreate(&event_start);
	cudaEventCreate(&event_stop);
	cudaEventRecord(event_start, 0);

	// ��������ʼ�� CUBLAS �����
	cublasHandle_t handle;
	status = cublasCreate(&handle);

	if (status != CUBLAS_STATUS_SUCCESS)
	{
		if (status == CUBLAS_STATUS_NOT_INITIALIZED) {
			cout << "CUBLAS ����ʵ��������" << endl;
		}
		getchar();
		return EXIT_FAILURE;
	}



	float *d_A, *d_B, *d_C;
	// �� �Դ� ��Ϊ��Ҫ����ľ��󿪱ٿռ�
	cudaMalloc(
		(void**)&d_A,    // ָ�򿪱ٵĿռ��ָ��
		aW*aH * sizeof(float)    //����Ҫ���ٿռ���ֽ���
	);
	cudaMalloc(
		(void**)&d_B,
		bW*bH * sizeof(float)
	);

	// �� �Դ� ��Ϊ��Ҫ����������ľ��󿪱ٿռ�
	cudaMalloc(
		(void**)&d_C,
		cW*cH * sizeof(float)
	);

	// ���������ݴ��ݽ� �Դ� ���Ѿ����ٺ��˵Ŀռ�
	cublasSetVector(
		aW*aH,    // Ҫ�����Դ��Ԫ�ظ���
		sizeof(float),    // ÿ��Ԫ�ش�С
		h_A,    // ��������ʼ��ַ
		1,    // ����Ԫ��֮��Ĵ洢���
		d_A,    // GPU ����ʼ��ַ
		1    // ����Ԫ��֮��Ĵ洢���
	);
	cublasSetVector(
		bW*bH,
		sizeof(float),
		h_B,
		1,
		d_B,
		1
	);

	// ͬ������
	cudaThreadSynchronize();

	// ���ݽ�������˺����еĲ��������庬����ο������ֲᡣ
	float a = 1; float b = 0;
	// ������ˡ��ú�����Ȼ���������������������
	cublasSgemm(
		handle,    // blas �����
		CUBLAS_OP_N,    // ���� A d_B��ת��
		CUBLAS_OP_N,    // ���� B  d_A��ת��
		bW,    // d_B, C ������
		aH,    // d_A, C ������
		bH,    // d_B �������� d_A ������
		&a,    // ����ʽ�� �� ֵ 1
		d_B,    // A ���Դ��еĵ�ַ
		bW,    // lda  ʹd_Bת��
		d_A,    // B ���Դ��еĵ�ַ
		aW,    // ldb ʹd_Aת��
		&b,    // ����ʽ�� �� ֵ
		d_C,    // C ���Դ��еĵ�ַ(�������)
		cW    // ldc
	);
	// ͬ������
	cudaThreadSynchronize();

	// �� �Դ� ��ȡ���������� �ڴ���ȥ
	cublasGetVector(
		cW*cH,    //  Ҫȡ��Ԫ�صĸ���
		sizeof(float),    // ÿ��Ԫ�ش�С
		d_C,    // GPU ����ʼ��ַ
		1,    // ����Ԫ��֮��Ĵ洢���
		h_C,    // ��������ʼ��ַ
		1    // ����Ԫ��֮��Ĵ洢���
	);
	cudaEventRecord(event_stop, 0);
	cudaEventSynchronize(event_stop);
	cudaEventElapsedTime(&elapsedTime, event_start, event_stop);
	// ͬ��device ��֤�������ȷ����
	cudaDeviceSynchronize();
	printf("matrix size:%d * %d \n", sizeT,sizeT);
	printf("cuda event time = %lfms\n", elapsedTime);
	mul_cpu(h_A, h_B, cpu_C);

	// ��ӡ������
	//cout << "��������ת�� ( (A*B)��ת�� )��" << endl;

	//for (int i = 0; i < cW*cH; i++) {
	//	cout << h_C[i] << " ";
	//	if ((i + 1) % cW == 0) cout << endl;
	//}

	//
	//cout << "cpu��������" << endl;

	//for (int i = 0; i < cW*cH; i++) {
	//	cout << cpu_C[i] << " ";
	//	if ((i + 1) % cW == 0) cout << endl;
	//}
	float diff = check_diff(h_C, cpu_C);
	printf("diff is %.10f\n", diff);
	// �����ʹ�ù����ڴ�
	free(h_A);
	free(h_B);
	free(h_C);
	cudaFree(d_A);
	cudaFree(d_B);
	cudaFree(d_C);

	// �ͷ� CUBLAS �����
	cublasDestroy(handle);
	return 0;
}

int main() {
	for (int i = 0; i < 10; i++) {
		int t = pow(2, i);
		sizeT = t;
		aW = sizeT;
		aH = sizeT;
		bW = sizeT;
		bH = sizeT;
		cW = bW;
		cH = aH;
		matrix();
		
	}
	return 0;
}