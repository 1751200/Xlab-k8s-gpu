// ConsoleApplication1.cpp : ���ļ����� "main" ����������ִ�н��ڴ˴���ʼ��������
#include <iostream>
using namespace std;
#include <ctime>
#include <Eigen/Core>
#include <Eigen/Dense>
#include <Eigen/SparseCholesky>
//ӳ��Cholesky
#include <Eigen/Cholesky>
// ���ܾ���Ĵ������㣨�棬����ֵ�ȣ�
#include <Eigen/SparseQR>
#include <Eigen/SparseLU>
#include <Eigen/Sparse>
using namespace Eigen;
using namespace std;

#define  MATRIX_SIZE 1500
int main(int argc, char** argv)
{
    srand((unsigned)time(NULL));
    // �ⷽ��
    // ������� A * x = b �������
    // ֱ��������Ȼ����ֱ�ӵģ�����������������

    //Eigen::Matrix< double, Eigen::Dynamic, Eigen::Dynamic > A1;
    //A1 = Eigen::MatrixXd::Random(MATRIX_SIZE, MATRIX_SIZE);
    //SparseMatrix<double> A1(MATRIX_SIZE, MATRIX_SIZE);
    //Eigen::Matrix< double, Eigen::Dynamic, Eigen::Dynamic > b1;
    //b1 = Eigen::MatrixXd::Random(MATRIX_SIZE, 1);

    //Cholesky �ⷽ��
    Eigen::SparseMatrix<double> smA(MATRIX_SIZE, MATRIX_SIZE);
    for (int i = 0; i < MATRIX_SIZE; i++) {
        for (int j = 0; j < MATRIX_SIZE; j++) {
            if (i == j) {
                smA.insert(i, j) = rand();
                continue;
            }
            if (rand() / double(RAND_MAX) < 0.002) {
                smA.insert(i, j) = rand();
            }
        }
    }

    smA.makeCompressed();
    Eigen::SparseMatrix<double> b(MATRIX_SIZE, 1);
    for (int i = 0; i < MATRIX_SIZE; i++) {
        b.insert(i, 0) = rand();
    }
    b.makeCompressed();
    Eigen::SparseMatrix<double> x(MATRIX_SIZE, 1);
    cout << "�Ѿ���ֵ" << endl;


    SparseLU < SparseMatrix < double >, AMDOrdering < int > > lu;
    clock_t time_stt = clock();
    lu.analyzePattern(smA);
    //lu.compute(smA);
    lu.factorize(smA);
    x = lu.solve(b);
    cout << "time use in sparse LU decomposition is " << 1000 * (clock() - time_stt) / (double)CLOCKS_PER_SEC << "ms" << endl;

    SparseQR < SparseMatrix < double >, AMDOrdering < int > > qr;
    qr.compute(smA);
    x=qr.solve(b);
    cout << "time use in sparse QR decomposition is " << 1000 * (clock() - time_stt) / (double)CLOCKS_PER_SEC << "ms" << endl;

    SimplicialLDLT < SparseMatrix < double >> chloe;
    time_stt = clock();
    chloe.compute(smA);
    x = chloe.solve(b);
    cout << "time use in sparse Cholesky decomposition is " << 1000 * (clock() - time_stt) / (double)CLOCKS_PER_SEC << "ms" << endl;


    //solver.analyzePattern(A);
    // Compute the numerical factorization 
    //solver.factorize(A);
    //Use the factors to solve the linear system 
    //x = solver.solve(b);


}
// ���г���: Ctrl + F5 ����� >����ʼִ��(������)���˵�
// ���Գ���: F5 ����� >����ʼ���ԡ��˵�

// ����ʹ�ü���: 
//   1. ʹ�ý��������Դ�������������/�����ļ�
//   2. ʹ���Ŷ���Դ�������������ӵ�Դ�������
//   3. ʹ��������ڲ鿴���������������Ϣ
//   4. ʹ�ô����б��ڲ鿴����
//   5. ת������Ŀ��>���������Դ����µĴ����ļ�����ת������Ŀ��>�����������Խ����д����ļ���ӵ���Ŀ
//   6. ��������Ҫ�ٴδ򿪴���Ŀ����ת�����ļ���>���򿪡�>����Ŀ����ѡ�� .sln �ļ�
