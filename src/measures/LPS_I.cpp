#include "LPS_I.hpp"
#include <stdexcept>
using namespace std;

LPS_I::LPS_I(const Graph* G1, const Graph* G2)
    : Measure(G1, G2, "lps_i") {
}


LPS_I::~LPS_I(){}

double LPS_I::eval(const Alignment& A) {
    double TruePositive = A.numAlignedEdges(*G1, *G2);
    double V1 = G1->getNumNodes();
    double omega = 1/2 * (V1) * (V1-1);
    double TrueNegative = omega - (G1->getNumEdges() + G2->numEdgesInNodeInducedSubgraph(A.asVector()) - TruePositive);

    return (TruePositive/(2*G1->getNumEdges())) + (TrueNegative/(2*(omega-G2->numEdgesInNodeInducedSubgraph(A.asVector()))));

    
}
