#include "EdgeMin.hpp"
#include <vector>


double EdgeMin::denominator = 0.0;

EdgeMin::EdgeMin(const Graph* G1, const Graph* G2): 
    Measure(G1, G2, "emin") { denominator=computeDenom(G1,G2); }

double EdgeMin::computeDenom(const Graph* G1, const Graph* G2) {
    double sum1=0, sum2=0;
    for(const auto& edge : *(G1->getEdgeList())){ uint u=edge[0], v=edge[1]; sum1+=abs(G1->getEdgeWeight(u,v));}
    for(const auto& edge : *(G2->getEdgeList())){ uint u=edge[0], v=edge[1]; sum2+=abs(G2->getEdgeWeight(u,v));}
    return min(sum1,sum2);
}

EdgeMin::~EdgeMin() {
}

double EdgeMin::eval(const Alignment& A) {
    double edgeMinSum = EdgeMin::getEdgeMinSum(G1, G2, A);
    return EdgeMin::adjustSumToTargetScore(G1, G2, edgeMinSum);
}

double EdgeMin::getEdgeMinSum(const Graph* G1, const Graph* G2, const Alignment &A) {
    double edgeMinSum = 0, simpleSum=0;
    double c = 0; // used for high-precision sum
    for (const auto& edge : *(G1->getEdgeList())) {
       uint node1 = edge[0], node2 = edge[1];
       double val = min(G1->getEdgeWeight(node1,node2), G2->getEdgeWeight(A[node1],A[node2]));
       assert(val>=0); // not sure how to handle my negative weights in directed-to-undirected case...
       simpleSum += val;
       double y = val - c;
       double t = edgeMinSum + y;
       c = (t - edgeMinSum) - y;
       edgeMinSum = t;
    }
    assert(abs(edgeMinSum-simpleSum)/max(edgeMinSum,simpleSum) < 1e-6);
    return edgeMinSum;
}

double EdgeMin::adjustSumToTargetScore(const Graph *G1, const Graph *G2, const double edgeMinSum) {
    return edgeMinSum / denominator;
}
