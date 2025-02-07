#ifndef LPS_L_HPP
#define LPS_L_HPP
#include "Measure.hpp"

class LPS_L: public Measure {
public:
    LPS_L(const Graph* G1,const Graph* G2);
    virtual ~LPS_L();
    double eval(const Alignment& A);
};

#endif

