// CJS Model with constant survival (s) and capture probability (p)
    
data{
  int<lower = 1> NsumCH;
  int<lower = 1> n_occasions;
  int<lower = 1, upper = 2> sumCH[NsumCH, n_occasions];
  int<lower = 1> sumf[NsumCH];
  int<lower = 1> sumFR[NsumCH];
}

parameters{
  // vector<lower = 0, upper = 1>[1] s;   // 3 month survivals 
  // vector<lower = 0, upper = 1>[1] pi;  // capture probability
  real<lower = 0, upper = 1> s;   // 3 month survivals 
  real<lower = 0, upper = 1> p;  // capture probability
}

transformed parameters{
  simplex[2] tr[2];
  simplex[2] pmat[2];
  
    tr[1,1] = s;
    tr[1,2] = (1 - s);
    tr[2,1] = 0;
    tr[2,2] = 1;
    
    
    pmat[1,1] = p;
    pmat[1,2] = (1 - p);
    pmat[2,1] = 0;
    pmat[2,2] = 1;
}
  
model{
    vector[2] pz[n_occasions];
    
    for(i in 1:NsumCH){  
      pz[sumf[i],1] = 1;
      pz[sumf[i],2] = 0;
      
      for(k in (sumf[i] + 1):n_occasions){ 
        pz[k,1] = pz[k-1,1] * tr[1,1] * pmat[1,sumCH[i,(k)]];
        pz[k,2] = (pz[k-1, 1] * tr[1,2] + pz[k-1, 2]) * pmat[2,sumCH[i,(k)]];
      }  
      
      target += sumFR[i] * log(sum(pz[n_occasions])); 
    }
  }
    
