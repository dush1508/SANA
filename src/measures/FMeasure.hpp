#ifndef FMEASURE_HPP
#define FMEASURE_HPP
#include "Measure.hpp"
#include "../Graph.hpp"

class FMeasure: public Measure {
public:
    FMeasure(const Graph* G1,const Graph* G2,const double input_beta);
    virtual ~FMeasure();
    double eval(const Alignment& A);
private:
    double beta;

};

#endif

