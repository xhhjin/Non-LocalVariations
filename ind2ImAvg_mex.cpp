#include <mex.h>
#include <matrix.h>
#include <math.h>
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    double *im = mxGetPr(prhs[0]);
    int *X = (int*)mxGetData(prhs[1]);
    int *Y = (int*)mxGetData(prhs[2]);
    double *D = mxGetPr(prhs[3]);
    
    
    int patch_row = mxGetScalar(prhs[4]);
    int patch_col = mxGetScalar(prhs[5]);
    
    const int *im_sz = mxGetDimensions(prhs[0]);
    const int d_im = mxGetNumberOfDimensions(prhs[0]);
    const int *ind_sz = mxGetDimensions(prhs[1]);
    const int d = mxGetNumberOfDimensions(prhs[1]);
    
    int nrows = im_sz[0];
    int ncols = im_sz[1];
    int nchannels = 1;
    if(d_im > 2){
        nchannels = im_sz[2];
    }
    
    int nknn = 1;
    if(d>2){
        nknn = ind_sz[2];
    }
    
    //mexPrintf("Input image of size %d x %d x %d\n", nrows, ncols, nchannels);
    //mexPrintf("K=%d NN\n", nknn);
    //mexPrintf("dim=%d \n", d_im);
    
    
    plhs[0] = mxCreateNumericArray(mxGetNumberOfDimensions(prhs[0]), im_sz, mxDOUBLE_CLASS,mxREAL);
     plhs[1] = mxCreateNumericArray(mxGetNumberOfDimensions(prhs[0]), im_sz, mxDOUBLE_CLASS,mxREAL);
    double *OUT = (double *)mxGetData(plhs[0]);
    mxArray *c = mxCreateNumericArray(mxGetNumberOfDimensions(prhs[0]), im_sz, mxDOUBLE_CLASS,mxREAL);
    double *COUNT = (double *)mxGetData( plhs[1] );
    
    
    int j=0;
    // Loop over all pixels
    
    for (int c = 0 ; c < ncols-patch_col+1 ; c++) // cols
    {
        for (int r = 0 ; r < nrows-patch_row+1 ; r++) //rows
        {
            
            for (int k=0; k < nknn; k++)
            {
                int xi = X[r + nrows*(c+ ncols*k)]-1;
                int yi = Y[r + nrows*(c+ ncols*k)]-1;
                double dist = D[r + nrows*(c+ ncols*k)];
                //double wi = exp(-0.5*dist/(patch_row*patch_col*0.01));
                //double wi = exp(-0.5*dist/(patch_row*patch_col*0.01));
                
                for (int prow = 0; prow < patch_row; prow++)
                {
                    for (int pcol = 0; pcol < patch_col; pcol++)
                    {
                        for (int z = 0 ; z < nchannels  ; z++) // color
                        {
                            double a = im[yi+prow + nrows*(xi+pcol+ncols*z)];
                            OUT[r + prow+nrows*(c+pcol+ncols*z)] += a*dist ;
                            COUNT[r +prow+nrows*(c+pcol+ncols*z)] +=1;
                        }
                    }
                }
                 
            } // knn
        } // time
        
    } // rows
    for (int c = 0 ; c < ncols ; c++) // cols
    {
        for (int r = 0 ; r < nrows ; r++) //rows
        {
            for (int z = 0 ; z < nchannels ; z++) // time/depth
            {
                OUT[r +nrows*(c+ncols*z)] = OUT[r +nrows*(c+ncols*z)]/(COUNT[r +nrows*(c+ncols*z)]/nknn)   ;
            }
        }
    }
    
    
}



