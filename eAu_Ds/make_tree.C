//R__LOAD_LIBRARY(libeicsmear)
#include <eicsmear/functions.h>
void make_tree(std::string filstr){

  //erhic::DisKinematics::BoundaryWarning=false; //Need to comment this for eic account

  gSystem->Load("libeicsmear");
  std::string dirstr = ".";
  std::string inputstr = dirstr + "/" + filstr;
  std::string outputdir = dirstr;
  BuildTree(inputstr,outputdir);
  //BuildTree(inputstr);
}

