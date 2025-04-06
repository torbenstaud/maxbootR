#include <Rcpp.h>
using namespace Rcpp;

// [[Rcpp::export]]
NumericVector dbMaxC(NumericVector x, int block_size) {
  int n = x.size();  // Get the size of the input vector
  int num_blocks = n / block_size;  // Calculate the number of disjoint blocks

  // Initialize a vector to store the maximum values of each block
  // We use num_blocks + 1 to account for any remainder block
  NumericVector max_samples(num_blocks);

  // Loop over each full block
  for (int i = 0; i < num_blocks; ++i) {
    // Create a sub-vector for the current block
    NumericVector current_block = x[Range(i * block_size, (i + 1) * block_size - 1)];

    // Find the maximum value in the current block
    double max_val = max(current_block);

    // Store the maximum value in the max_samples vector
    max_samples[i] = max_val;
  }

  // Check if there's a remainder block
  if (num_blocks * block_size != n) {
    // Calculate the maximum for the remaining elements
    NumericVector remainder_block = x[Range(num_blocks * block_size, n - 1)];
    double remainder_max = max(remainder_block);

    // Resize the max_samples vector to include the remainder max
    max_samples.push_back(remainder_max);
  }

  // Return the vector of maximum values
  return max_samples;
}

// [[Rcpp::export]]
NumericVector seqC(int a, int b){
  // kein Runtime Vorteil
  NumericVector res (b-a+1);
  for(int ind = 0; ind < b-a +1; ind++){
    res[ind] = ind +a;
  }
  return(res);
}

// [[Rcpp::export]]
NumericVector slidMaxC(
    NumericVector xx, int r
){
  int len = xx.length();
  NumericVector xxL (len + r -1);
  xxL[seqC(0, len -1)] = xx;
  xxL[seqC(len, len + r -2)] = xx[seqC(0, r-2)];
  NumericVector bms (len);
  for(int ind = 0; ind < len; ind++){
    bms[ind] = max(xxL[seq(ind, ind + r - 1)]);
  }
  return(bms);
}

// [[Rcpp::export]]
NumericVector repC(double val, int times){
  NumericVector res (times);
  for(int ind = 0; ind < times; ++ind){
    res[ind] = val;
  }
  return(res);
}

// [[Rcpp::export]]
NumericVector kMaxTrC(
    NumericVector sample, int r, int k

){
  // k is assumed to be 1 < k < m; hence, the true kmax case!
  int n;
  double mk;
  n = sample.length();
  mk = std::floor(1.0*n/(k*r));
  NumericVector bms (n);
  for(int ind = 0; ind < mk; ++ind){
    NumericVector iBlockInd = seqC((ind)*k*r, (ind+1)*k*r-1);
    bms[iBlockInd] = slidMaxC(sample[iBlockInd], r);
  }
  //now treat the last block and distinguish two cases, which need different handling:
  //size of last block
  int lbSize = n-k*r*mk;
  //if n is not divisible k*r:
  if(lbSize != 0){
    //last block indices
    NumericVector lbInd = seqC(mk*k*r, n-1);
    //case 1: size of last block is smaller then r: Then take bm of last block
    // and repeat it last-block size- times
    if(lbSize < r){
      NumericVector lastBlock = sample[lbInd];
      double maxLblock = max(lastBlock);
      bms[lbInd] = repC(maxLblock, lbSize);
    }else{ //case 2: size of last block >= r: use generic sliding max on last block
      bms[lbInd] = slidMaxC(sample[lbInd], r);
    }
  }
  return(bms);
}
