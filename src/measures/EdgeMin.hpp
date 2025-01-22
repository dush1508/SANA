#ifndef EDGEMIN_HPP
#define EDGEMIN_HPP
#include "Measure.hpp"

class EdgeMin: public Measure {
public:
    EdgeMin(const Graph* G1, const Graph* G2);
    virtual ~EdgeMin();
    double eval(const Alignment& A);

    static double adjustSumToTargetScore(const Graph *G1, const Graph *G2, const double edgeMinSum);
    static double getEdgeMinSum(const Graph *G1, const Graph *G2, const Alignment &A);
private:
    static double denominator;
    static double computeDenom(const Graph* G1, const Graph* G2);
};

#endif //EDGEDIFFERENCE_HPP
