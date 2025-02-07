#include "LPS_L.hpp"
#include <stdexcept>
using namespace std;

LPS_L::LPS_L(const Graph* G1, const Graph* G2)
    : Measure(G1, G2, "lps_l") {
}


LPS_L::~LPS_L(){}

double LPS_L::eval(const Alignment& A) {

    double TruePositive = A.numAlignedEdges(*G1, *G2);
    double V1 = G1->getNumNodes();
    double omega = 1/2 * (V1) * (V1-1);
    double TrueNegative = omega - (G1->getNumEdges() + G2->numEdgesInNodeInducedSubgraph(A.asVector()) - TruePositive);

    return (TruePositive/(2*G1->getNumEdges())) + (TrueNegative/(2*(omega-G1->getNumEdges())));
}
