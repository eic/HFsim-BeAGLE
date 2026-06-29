//================================================
// Study the kinematics of produced hadron in 
// certain (x, Q2, nu) bin
//
// To-do:
// 1. Exclude/include feed-down?
//================================================
R__LOAD_LIBRARY(libeicsmear);

#include "bins.h"

using namespace std;


void filter_Ds(const char* inFile = "eAu.root")
{

  // Prepare output name
  TString outname = inFile;
  outname = outname.ReplaceAll(".root", ".filterDs.root");
  
  TFile *f = new TFile(inFile);

  //Get EICTree Tree
  TTree *tree = (TTree*)f->Get("EICTree");

  Int_t nEntries = tree->GetEntries();
  cout<<"-------------------------------"<<endl;
  cout<<"Total Number of Events = "<<nEntries<<endl<<endl;

  // Event Class
  erhic::EventBeagle *event_beagle(NULL);

  // Access event Branch
  tree->SetBranchAddress("event",&event_beagle);

  // new tree
  TFile* fout = new TFile(outname.Data(),"recreate");
  fout->SetCompressionLevel(9);
  TTree *newtree = tree->CloneTree(0);
  
  //Loop Over Events
  const float EtaMax = 3.5;
  int nevt = nEntries;
  for(Int_t ievt = 0; ievt < nevt; ievt++)
  {    
    if (ievt%1000==0) cout<<"Processing event = "<<ievt<<"/"<<nevt<<endl;

    tree->GetEntry(ievt);

    erhic::EventMC* event = event_beagle;

    //cout << endl << "[i] Event " << ievt << endl;

    bool is_selected = false;

    for(int ipart = 0; ipart < event->GetNTracks(); ipart++)
      {
	erhic::ParticleMC* part = event->GetTrack(ipart);

	// it is Ds
	if (abs(part->Id()) != 431) continue;

	//printf("Mother %d\n", (int)part->Id());

	// decay to phi+pi
	int nDaug = part->GetNChildren();
	if (nDaug != 2) continue;
	const erhic::ParticleMC* daughter1 = part->GetChild(0);
	const erhic::ParticleMC* daughter2 = part->GetChild(1);
	//printf("Mother %d, daughters: %d %d\n", (int)part->Id(), (int)daughter1->Id(), (int)daughter2->Id());
	int phi_index = -1, pi_index = -1;
	if( (abs(daughter1->Id())==333 && abs(daughter2->Id())==211) )
	  {
	    phi_index = daughter1->GetIndex();
	    pi_index = daughter2->GetIndex();
	  }
	
	if( (abs(daughter1->Id())==211 && abs(daughter2->Id())==333) )
	  {
	    phi_index = daughter2->GetIndex();
	    pi_index = daughter1->GetIndex();
	  }

	if(phi_index==-1 || pi_index==-1) continue;
	erhic::ParticleMC* daug_phi = event->GetTrack(phi_index-1);
	erhic::ParticleMC* daug_pi = event->GetTrack(pi_index-1);

	// phi decays to K+K
	if (daug_phi->GetNChildren() != 2) continue;
	//printf("Mother %d, daughters: %d %d, grand-daughters: %d %d\n", (int)part->Id(), (int)daug_phi->Id(), (int)daug_pi->Id(), (int)daug_phi->GetChild(0)->Id(), (int)daug_phi->GetChild(1)->Id());
	if(abs(daug_phi->GetChild(0)->Id())!=321 || abs(daug_phi->GetChild(1)->Id())!=321) continue;
	const erhic::ParticleMC* granddaughter1 = daug_phi->GetChild(0);
	const erhic::ParticleMC* granddaughter2 = daug_phi->GetChild(1);

	// pi, K, K are within ePIC acceptance
	if(fabs(daug_pi->GetEta()) > EtaMax || fabs(granddaughter1->GetEta()) > EtaMax || fabs(granddaughter2->GetEta()) > EtaMax) continue;
	     
	printf("Mother %d, daughters: %d %d, grand-daughters: %d %d\n", (int)part->Id(), (int)daug_phi->Id(), (int)daug_pi->Id(), (int)granddaughter1->Id(), (int)granddaughter2->Id());

	is_selected = true;
	break;
      }

    if(is_selected)
      {
	newtree->Fill();
      }
  }
  
  printf("[i] Acceptance fraction %lld/%d = %4.4f%%\n",newtree->GetEntries(),nEntries,newtree->GetEntries()*1./nEntries*100);
 
  newtree->AutoSave();
  fout->Close();
}
