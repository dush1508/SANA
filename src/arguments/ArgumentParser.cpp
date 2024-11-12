#include <iostream>
#include "ArgumentParser.hpp"
#include "../utils/utils.hpp"
#include "../utils/FileIO.hpp"
#include "SupportedArguments.hpp"
using namespace std;



ArgumentParser::ArgumentParser(int argc, char* argv[]) {
    if(argc == 1) {
	cout << "Usage: " << argv[0] << " [OPTION] [ARG(S)] [OPTION] [ARG(S)]..." << endl
             << "Try './sana --help' or './sana -h' for more information." << endl;
        exit(0);
    }
    for (int i = 0; i < argc; i++) originalArgv.push_back(argv[i]);

    vector<string> vArg;
    //add first the base values
    vector<string> baseValues;
    for (string line: defaultArguments) { //from defaultArguments.hpp
        for (string s: nonEmptySplit(line, ' ')) {
            vArg.push_back(s);
        }
    }
    if (argc >= 2) {
        //next add values from file
        bool addValuesFromFile = FileIO::fileExists(argv[1]);
        if (addValuesFromFile) {
            vector<string> aux = FileIO::fileToWords(argv[1]);
            vArg.insert(vArg.end(), aux.begin(), aux.end());
        }
        //finally, add command line values
        for (int i = addValuesFromFile ? 2 : 1; i < argc; i++) {
            vArg.push_back(string(argv[i]));
        }
    }

    //initializes the argument arrays declared in SupportedArguments.hpp
    SupportedArguments::validateAndAddArguments();

    //default values for missing arguments
    for (string s: stringArgs)       strings[s]       = "";
    for (string s: doubleArgs)       doubles[s]       = 0;
    for (string s: boolArgs)         bools[s]         = false;
    for (string s: doubleVectorArgs) doubleVectors[s] = vector<double> (0);
    for (string s: stringVectorArgs) stringVectors[s] = vector<string> (0);
    for (string s: commaArgs) commaVectors[s] = std::make_pair(0,0);

   


    bool helpFound = false;
    unordered_set<string> helpArgs;
    //check to see if there is a help argument
    for (string arg : vArg) {
        if (arg == "-h" or arg == "--help") helpFound = true;
        else if (helpFound) helpArgs.insert(arg);
        else if (arg == "-V" or arg == "--version"){
	    cout << SANAversion << endl;
	    exit(0);
	}
    }
    if (helpFound) {
        SupportedArguments::printAllArgumentDescriptions(helpArgs);
        exit(0);
    }

    for (uint i = 0; i < vArg.size(); i++) {
        string arg = vArg[i];
        if(strings.count(arg)) {
            strings[arg]=vArg[i+1];
            i++;
        } else if (doubles.count(arg)) {
            doubles[arg]=stod(vArg[i+1]);
            i++;
        } else if (bools.count(arg)) {
            bools[arg] = true;
        } else if (doubleVectors.count(arg)) {
            int k = stoi(vArg[i+1]);
            doubleVectors[arg] = vector<double> (0);
            for (int j = 0; j < k; j++) {
                doubleVectors[arg].push_back(stod(vArg[i+2+j]));
            }
            i = i+k+1;
        } else if (stringVectors.count(arg)){
            int k = stoi(vArg[i+1]);
            stringVectors[arg] = vector<string>(0);
            for (int j = 0; j < k; j++)
                stringVectors[arg].push_back(vArg[i+2+j]);
            i = i+k+1;
        } else if (commaVectors.count(arg)){
            commaVectors[arg] = std::make_pair(0,-1);
            string commaBuffer = vArg[i+1];
           
            double weight_value = static_cast<double>( commaBuffer[0] - '0');
            if(weight_value > 0 ){
                cout<<"Sorry, SANA does not support the f-measure. We are currently working on adding the f-measure to SANA. Stay tuned!\n";
                exit(1);
            }
            double beta_value = std::stod(commaBuffer.substr(2));
            if( beta_value < 0)
                runtime_error("The range of beta values is [0,inf). The current value is not in this range.\n");
            
            if(commaBuffer[2] == '#')
                commaVectors[arg] = std::make_pair((static_cast<double>( commaBuffer[0] - '0')),-1);  
            else
                commaVectors[arg] = std::make_pair((static_cast<double>( commaBuffer[0] - '0')),(static_cast<double>( commaBuffer[2] - '0')));
            
            i=i+1;
        }
        else {
            // if (arg.size() > 1)  I *think* this was needed because of a bug in split that I just fixed. Not sure, so leaving it commented -Nil
                throw runtime_error("Unknown argument: "+arg+". See the README for the correct syntax");
        }
    }
}

void ArgumentParser::writeArguments() {
    cout << "=== Parsed arguments ===" << endl;
    cout << "Executable name: " << originalArgv[0] << endl;
    for (auto kv : strings) {
        if (kv.second != "") cout << kv.first << ": " << kv.second << '\t';
    }
    cout << endl;
    for (auto kv : doubles) {
        if (kv.second != 0) cout << kv.first << ": " << kv.second << '\t';
    }
    cout << endl;
    for (auto kv : bools) {
        if (kv.second) cout << kv.first << ": " << kv.second << '\t';
    }
    cout << endl;
    for (auto kv : doubleVectors) {
        if (kv.second.size() != 0) {
            cout << kv.first << ": ";
            for (uint i = 0; i < kv.second.size(); i++) cout << kv.second[i] << " ";
            cout << endl;
        }
    }
    cout << endl;
    for (auto kv : stringVectors) {
        if (kv.second.size() != 0) {
            cout << kv.first << ": ";
            for (uint i = 0; i < kv.second.size(); i++) cout << kv.second[i] << " ";
            cout << endl;
        }
    }
    cout << endl;

    for (const auto& kv : commaVectors) {
        if (kv.second.first != 0) {  // Check if the first element of the pair is not 0
            std::cout << kv.first << ": ";
            std::cout << kv.second.first << ", " << kv.second.second;
            std::cout << std::endl;
        }
    }
    cout << endl;
}
