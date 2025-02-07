#ifndef LPS_I_HPP
#define LPS_I_HPP
#include "Measure.hpp"

class LPS_I: public Measure {
public:
    LPS_I(const Graph* G1,const Graph* G2);
    virtual ~LPS_I();
    double eval(const Alignment& A);
};

#endif

