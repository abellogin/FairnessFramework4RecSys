#!/usr/bin/perl

#use Math::CDF;

use strict;

use Math::Random qw(:all);

#my $r = random_beta(1,1,0.1/(1-0.1));
#print "$r\n";
#die;


my %Util=();
my %ItemGroup=();
my %UserGroup=();
my %GroupItem=();
my %GroupUser=();
my %GSize=();
my %ItemUtil=();
my %UserUtil=();
my %ItemGroupUtil=();
my %UserGroupUtil=();
my %ItemUserGroupUtil=();
my %ItemGroupSingleUserUtil=();
my %SingleItemUserGroupUtil=();

my $TotUtil=0;
my $NumUsers=0;
my $NumItems=0;


my %Rank=();
my %Expo=();


my $goldFile="./DATASET1/citeulike-a_ratings_df_test.csv";
my $itemAtt="./DATASET1/citeulike-a_item_w_popClass.csv";
my $groupAtt="./DATASET1/citeulike-a_users_w_activClass.csv";
my $fileDir="./DATASET1/";
my @sysList=("BPR_citeulike-a_samplingRate_1.csv",
	     "MF_citeulike-a_samplingRate_1.csv",
	     "MostPop_citeulike-a_samplingRate_1.csv",
	     "NeuMF_citeulike-a_samplingRate_1.csv",
	     "PMF_citeulike-a_samplingRate_1.csv",
	     "Popular_citeulike-a_samplingRate_1.csv",
	     "Random_citeulike-a_samplingRate_1.csv",
	     "UnPopular_citeulike-a_samplingRate_1.csv",
	     "VAECF_citeulike-a_samplingRate_1.csv",
	     "WMF_citeulike-a_samplingRate_1.csv");



if (1==2){

$goldFile="./DATASET2/netflix-small_ratings_df_test.csv";
$itemAtt="./DATASET2/netflix-small_item_w_popClass.csv";
$groupAtt="./DATASET2/netflix-small_users_w_activClass.csv";

$fileDir="./DATASET2/";

@sysList=("BPR_netflix-small_samplingRate_1.csv",
	  "MF_netflix-small_samplingRate_1.csv",
	  "MostPop_netflix-small_samplingRate_1.csv",
	  "NeuMF_netflix-small_samplingRate_1.csv",
	  "PMF_netflix-small_samplingRate_1.csv",
	  "Popular_netflix-small_samplingRate_1.csv",
	  "Random_netflix-small_samplingRate_1.csv",
	  "UnPopular_netflix-small_samplingRate_1.csv",
	  "VAECF_netflix-small_samplingRate_1.csv",
	  "WMF_netflix-small_samplingRate_1.csv");
}













#LECTURA DEL GOLDSTANDARD
open (FICHIN,$goldFile) or die;
my $line=<FICHIN>;
while (my $line=<FICHIN>){
    chop($line);
    my ($aux,$u,$i,$r)=split(/,/,$line);
    $Util{$i}{$u}=$r;
    
}

#LECTURA DE LOS GRUPOS DE ITEMS
open (FICHIN,$itemAtt) or die;
my $line=<FICHIN>;
while (my $line=<FICHIN>){
    chop($line);
    my ($aux,$i,$aux2,$g)=split(/,/,$line);
    $g="i-$g";
    $ItemGroup{$i}=$g;
    $GroupItem{$g}{$i}=1;
    $GSize{$g}++;
    $NumItems++;
}

#LECTURA DE LOS GRUPOS DE USUARIOS
open (FICHIN,$groupAtt) or die;
my $line=<FICHIN>;
while (my $line=<FICHIN>){
    chop($line);
    if ($line ne ""){
	my ($AuX2,$u,$g)=split(/,/,$line);
	$g="u-$g";
	$UserGroup{$u}=$g;
	$GroupUser{$g}{$u}=1; 
	$GSize{$g}++;
	$NumUsers++;
    }
}



foreach my $i (keys %ItemGroup){
    if (exists $Util{$i}){
    foreach my $u (keys $Util{$i}){
	$ItemUtil{$i}+=$Util{$i}{$u};
	$UserUtil{$u}+=$Util{$i}{$u};
	$TotUtil+=$Util{$i}{$u};
	$ItemGroupUtil{$ItemGroup{$i}}+=$Util{$i}{$u};
	$UserGroupUtil{$UserGroup{$u}}+=$Util{$i}{$u};
	$ItemUserGroupUtil{$ItemGroup{$i}}{$UserGroup{$u}}+=$Util{$i}{$u};
	$ItemGroupSingleUserUtil{$ItemGroup{$i}}{$u}+=$Util{$i}{$u};
	$SingleItemUserGroupUtil{$i}{$UserGroup{$u}}+=$Util{$i}{$u};
	#print "Item Util $i=".$ItemUtil{$i}."\n";
	#print "User Util $u=".$UserUtil{$u}."\n";
	#print "TotUtil=".$TotUtil."\n";
	#print "ItemGroupUtil ".$ItemGroup{$i}." =".$ItemGroupUtil{$ItemGroup{$i}}."\n";
	#print "UserGroupUtil ".$UserGroup{$u}." =".$UserGroupUtil{$UserGroup{$u}}."\n";
	#print "\n";
	#print "\n";
    }
    }
}

#my @sysList=("BPR_citeulike-a_samplingRate_1.csv");


#LECTURA DE OUTPUTS
foreach my $file (@sysList) {
    print "Reading output ".$fileDir.$file. "\n";
    open (FICHIN,$fileDir.$file) or die;
    my $line=<FICHIN>;
    while (my $line=<FICHIN>){
	chop($line);
	my ($u,$i,$r)=split(/,/,$line); 
	$Rank{$file}{$u}{$i}=$r;
    }	
}


foreach my $u (keys  %UserUtil){
    my $r=1;
    foreach my $i (sort {$Util{$b}{$u} <=> $Util{$a}{$u}} keys %Util) {
	if (exists $Util{$i}{$u}){
	    
	    $Rank{"ORACLE"}{$u}{$i}=$r;
	    #print "ORACLE $u  $i  -> ".($Util{$i}{$u})."<- $r \n";
	}
	$r++;
    }
}

#die;

push (@sysList,"ORACLE");

foreach my $baseline (@sysList) {
    my %Expo=();
    my %Eff=();
    my %EffRec=();
    
    my %UserEff=();
    my %ItemEff=();
    my %ItemGroupEff=();
    my %UserGroupEff=();
    my %ItemUserGroupEff=();
    my %ItemGroupSingleUserEff=();
    my %SingleItemUserGroupEff=();
    my $TotEff=0;
    
    my %UserEffRec=();
    my %ItemEffRec=();
    my %ItemGroupEffRec=();
    my %UserGroupEffRec=();
    my $TotEffRec=0;

    my %ItemExpo=();
    my %UserExpo=();
    my %ItemGroupExpo=();
    my %UserGroupExpo=();
    my %ItemUserGroupExpo=();
    my %ItemGroupSingleUserExpo=();
    my %SingleItemUserGroupExpo=();
    my $TotExpo=0;
    
    print "SYSTEM $baseline ";
    #Para cada usuario
    foreach my $u (keys $Rank{$baseline}){
	foreach my $i (keys $Rank{$baseline}{$u}){
	    my $rank=$Rank{$baseline}{$u}{$i};
	    $Expo{$i}{$u}=1/(log($rank+1)/log(2));
	    $Eff{$i}{$u}=0;
	    if (exists $Util{$i}{$u}){
		$Eff{$i}{$u}=$Util{$i}{$u}*$Expo{$i}{$u};
	    }
	    $UserEff{$u}+=$Eff{$i}{$u};
	    $ItemEff{$i}+=$Eff{$i}{$u};
	    $ItemGroupEff{$ItemGroup{$i}}+=$Eff{$i}{$u};
	    $UserGroupEff{$UserGroup{$u}}+=$Eff{$i}{$u};
	    $ItemUserGroupEff{$ItemGroup{$i}}{$UserGroup{$u}}+=$Eff{$i}{$u};
	    $SingleItemUserGroupEff{$i}{$UserGroup{$u}}+=$Eff{$i}{$u};
	    $ItemGroupSingleUserEff{$ItemGroup{$i}}{$u}+=$Eff{$i}{$u};
	    
	    $TotEff+=$Eff{$i}{$u};
	    
	    $EffRec{$i}{$u}=0;
	    if (exists $Util{$i}{$u}){
		$EffRec{$i}{$u}=$Util{$i}{$u}/$UserUtil{$u}*$Expo{$i}{$u};
	    }
	    $UserEffRec{$u}+=$EffRec{$i}{$u};
	    $ItemEffRec{$i}+=$EffRec{$i}{$u};
	    $ItemGroupEffRec{$ItemGroup{$i}}+=$EffRec{$i}{$u};
	    $UserGroupEffRec{$UserGroup{$u}}+=$EffRec{$i}{$u};
	    $TotEffRec+=$EffRec{$i}{$u};
	    
	    $ItemExpo{$i}+=$Expo{$i}{$u};
	    $UserExpo{$u}+=$Expo{$i}{$u};
	    $ItemGroupExpo{$ItemGroup{$i}}+=$Expo{$i}{$u};
	    $UserGroupExpo{$UserGroup{$u}}+=$Expo{$i}{$u};
	    $ItemUserGroupExpo{$ItemGroup{$i}}{$UserGroup{$u}}+=$Expo{$i}{$u};
	    $SingleItemUserGroupExpo{$i}{$UserGroup{$u}}+=$Expo{$i}{$u};
	    $ItemGroupSingleUserExpo{$ItemGroup{$i}}{$u}+=$Expo{$i}{$u};
	    $TotExpo+=$Expo{$i}{$u};

	    
	}
    }

    
    print "\n";
    foreach my $g (keys %GroupUser){
	print "   User group size $g =\t".($GSize{$g}/$NumUsers)."\n";
	print "   Exposure for user group $g=\t".($UserGroupExpo{$g}/$TotExpo)."\n";
	print "   Eff for user group $g= \t".($UserGroupEff{$g}/$TotEff)."\n";
	print "   Utility for user group $g= \t".($UserGroupUtil{$g}/$TotUtil)."\n";
    }	
    foreach my $g (keys %GroupItem){
	
	print "   Item group size $g =\t".($GSize{$g}/$NumItems)."\n";
	print "   Exposure for item group $g= \t".($ItemGroupExpo{$g}/$TotExpo)."\n";
	print "   Eff for item group $g= \t".($ItemGroupEff{$g}/$TotEff)."\n";
	print "   Utility for item group $g= \t".($ItemGroupUtil{$g}/$TotUtil)."\n";
    }	
    

    print "SYSTEM\t".
       "EFF\t".
    "KL-U-psi-Pr\t".
    "KL-I-psi-Pr\t".
    "KL-U-psi-Un\t".
    "KL-I-psi-Un\t".
    "KL-U-Exp-Un\t".
    "KL-U-Exp-Pr\t".
     "KL-U-Exp-UtilEq\t".
    "KL-U-Eff-Un\t".
    "KL-U-Eff-Pr\t".
     "KL-U-Ef-UtilEq\t".
    "KL-I-Exp-Un\t".
    "KL-I-Exp-Pr\t".
     "KL-I-Exp-UtilEq\t".
    "KL-I-Eff-Un\t".
    "KL-I-Eff-Pr\t".
     "KL-I-Ef-UtilEq\t".
    "MI-U-I-Psi\t".
    "MI-U-I-Exp\t".
    "MI-U-I-Eff\t".
    "MI-I-u-Psi\t".
    "MI-I-u-Exp\t".
    "MI-I-u-Eff\t".
    "MI-i-U-Psi\t".
    "MI-i-U-Exp\t".
    "MI-i-U-Eff";
    print "\n";

    my $numUsers=(keys %UserGroup);
    print "$baseline\t".($TotEff/$numUsers);
    ######################################
    #KL-USER GROUP-UTILITY BIAS-GROUP SIZE PROPORTIONAL
    my $kl=0;
    foreach my $g (keys %GroupUser){
	my $P=$UserGroupUtil{$g}/$TotUtil;
	my $Q=$GSize{$g}/$NumUsers;
	#print "\n P y Q= $GSize{$g}  $NumUsers--> $P $Q \n";
	$kl+=$P*log($P/$Q)/log(2);
    }
    print "\t".(int($kl*1000)/1000)."";

    #KL-ITEM GROUP-UTILITY BIAS-GROUP SIZE PROPORTIONAL
    $kl=0;
    foreach my $g (keys %GroupItem){
	my $P=$ItemGroupUtil{$g}/$TotUtil;
	my $Q=$GSize{$g}/$NumItems;
	$kl+=$P*log($P/$Q)/log(2);
    }
    print "\t".(int($kl*1000)/1000)."";

    
    ######################################
    #KL-USER GROUP-UTILITY BIAS-Uniform
    my $kl=0;
    foreach my $g (keys %GroupUser){
	my $P=$UserGroupUtil{$g}/$TotUtil;
	my $Q=1/2;
	$kl+=$P*log($P/$Q)/log(2);
    }
    print "\t".(int($kl*1000)/1000)."";


    
    #INEQUITY-ITEM GROUP-UTILITY BIAS-Uniform
    $kl=0;
    foreach my $g (keys %GroupItem){
	my $P=$ItemGroupUtil{$g}/$TotUtil;
	my $Q=1/2;
	my $Q=$GSize{$g}/$NumItems;
	$kl+=$P*log($P/$Q)/log(2);
    }
    print "\t".(int($kl*1000)/1000)."";





    
    ######################################
    #INEQUITY-User group-Exposure-Uniform
    $kl=0;
    foreach my $g (keys %GroupUser){
	my $P=$UserGroupExpo{$g}/$TotExpo;
	my $Q=1/2;
	$kl+=$P*log($P/$Q)/log(2);
    }    
    print "\t".(int($kl*1000)/1000)."";

        
    #INEQUITY-User group-Exposure-Proportionality
    $kl=0;
    foreach my $g (keys %GroupUser){
	my $P=$UserGroupExpo{$g}/$TotExpo;
	my $Q=$GSize{$g}/$NumUsers;
	#print "\n--->Group $g -> $P $Q \n";
	$kl+=$P*log($P/$Q)/log(2);
    }    
    print "\t".(int($kl*1000)/1000)."";
    #die;
    #KL-User group-Exposure-UtilityEqualized
    $kl=0;
    foreach my $g (keys %GroupUser){
	my $P=$UserGroupExpo{$g}/$TotExpo;
	my $Q=$UserGroupUtil{$g}/$TotUtil;
	$kl+=$P*log($P/$Q)/log(2);
    }    
    print "\t".(int($kl*1000)/1000)."";








    
    
    ######################################
    #KL-User group-Eff-Uniform
    $kl=0;
    foreach my $g (keys %GroupUser){
        my $P=$UserGroupEff{$g}/$TotEff;
	my $Q=1/2;
	#print "\n--->Group $g -> $P $Q \n";
	if ($P>0){
	    $kl+=$P*log($P/$Q)/log(2);
	}  
    }    
    print "\t".(int($kl*1000)/1000)."";

        
    #INEQUITY-User group-Eff-Proportionality
    $kl=0;
    foreach my $g (keys %GroupUser){
        my $P=$UserGroupEff{$g}/$TotEff;
	my $Q=$GSize{$g}/$NumUsers;
	if ($P>0){
	    $kl+=$P*log($P/$Q)/log(2);
	}
    }    
    print "\t".(int($kl*1000)/1000)."";

    #INEQUITY-User group-Eff-UtilityEqualized
    $kl=0;
    foreach my $g (keys %GroupUser){
        my $P=$UserGroupEff{$g}/$TotEff;
	my $Q=$UserGroupUtil{$g}/$TotUtil;
	if ($P>0){
	    $kl+=$P*log($P/$Q)/log(2);
	}
    }    
    print "\t".(int($kl*1000)/1000)."";




    

    
    ######################################
    #INEQUITY-Item group-Exposure-Uniform
    $kl=0;
    foreach my $g (keys %GroupItem){
	my $P=$ItemGroupExpo{$g}/$TotExpo;
	my $Q=1/2;
	if ($P>0){
	    $kl+=$P*log($P/$Q)/log(2);
	}
    }    
    print "\t".(int($kl*1000)/1000)."";

        
    #INEQUITY-Item group-Exposure-Proportionality
    $kl=0;
    foreach my $g (keys %GroupItem){
	my $P=$ItemGroupExpo{$g}/$TotExpo;
	my $Q=$GSize{$g}/$NumItems;
	if ($P>0){
	    $kl+=$P*log($P/$Q)/log(2);
	}    
    }  
    print "\t".(int($kl*1000)/1000)."";

    #INEQUITY-Item group-Exposure-UtilityEqualized
    $kl=0;
    foreach my $g (keys %GroupItem){
	my $P=$ItemGroupExpo{$g}/$TotExpo;
	my $Q=$ItemGroupUtil{$g}/$TotUtil;
	
	if ($P>0){
	    $kl+=$P*log($P/$Q)/log(2);
	} 
    }    
    print "\t".(int($kl*1000)/1000)."";



    
    ######################################
    #KL-Item group-Eff-Uniform
    $kl=0;
    foreach my $g (keys %GroupItem){
	my $P=$ItemGroupEff{$g}/$TotEff;
	my $Q=1/2;
	if ($P>0){
	    $kl+=$P*log($P/$Q)/log(2);
	}
    }     
    print "\t".(int($kl*1000)/1000)."";

        
    #KL-Item group-Eff-Proportionality
    $kl=0;
    foreach my $g (keys %GroupItem){
	my $P=$ItemGroupEff{$g}/$TotEff;
	my $Q=$GSize{$g}/$NumItems;
	if ($P>0){
	    $kl+=$P*log($P/$Q)/log(2);
	}

    }    
    print "\t".(int($kl*1000)/1000)."";

    #KL-Item group-Eff-UtilityEqualized
    $kl=0;
    foreach my $g (keys %GroupItem){
	my $P=$ItemGroupEff{$g}/$TotEff;
	my $Q=$ItemGroupUtil{$g}/$TotUtil;
	if ($P>0){
	    $kl+=$P*log($P/$Q)/log(2);
	}
    }    
    print "\t".(int($kl*1000)/1000)."";







    
    ######################################
    ######################################

    #MI-I-U-Psi
    my $MI=0;
    foreach my $gi (keys %GroupItem){
	foreach my $gu (keys %GroupUser){
	    my $PQ=$ItemUserGroupUtil{$gi}{$gu}/$TotUtil;
	    my $P=$ItemGroupUtil{$gi}/$TotUtil;
	    my $Q=$UserGroupUtil{$gu}/$TotUtil;
	    #print "\n---> $gi $gu $PQ $P $Q \n";
	    if ($PQ>0){
		$MI+=$PQ*log($PQ/($Q*$P))/log(2);
	    }
	}
    }
    print "\t".(int($MI*1000)/1000)."";
    

    #MI-I-U-Exp
    $MI=0;
    foreach my $gi (keys %GroupItem){
	foreach my $gu (keys %GroupUser){
	    my $PQ=$ItemUserGroupExpo{$gi}{$gu}/$TotExpo;
	    my $P=$ItemGroupExpo{$gi}/$TotExpo;
	    my $Q=$UserGroupExpo{$gu}/$TotExpo;
	    #print "\n---> $gi $gu $PQ $P $Q \n";
	    if ($PQ>0){
		$MI+=$PQ*log($PQ/($Q*$P))/log(2);
		}	
	}
    }
    print "\t".(int($MI*10000)/10000)."";


    #MI-I-U-Eff
    $MI=0;
    foreach my $gi (keys %GroupItem){
	foreach my $gu (keys %GroupUser){
	    my $PQ=$ItemUserGroupEff{$gi}{$gu}/$TotEff;
	    my $P=$ItemGroupEff{$gi}/$TotEff;
	    my $Q=$UserGroupEff{$gu}/$TotEff;
	    #print "\n---> $gi $gu $PQ $P $Q \n";
	    if ($PQ>0){
		$MI+=$PQ*log($PQ/($Q*$P))/log(2);
	    }
	}
    }
    print "\t".(int($MI*10000)/10000)."";

    ######################################
    ######################################


    #MI-I-u-Psi
    $MI=0;
    foreach my $gi (keys %GroupItem){
	foreach my $u (keys %UserGroup){
	    my $PQ=$ItemGroupSingleUserUtil{$gi}{$u}/$TotUtil;
	    my $P=$ItemGroupUtil{$gi}/$TotUtil;
	    my $Q=$UserUtil{$u}/$TotUtil;
	    #print "\n---> $gi $gu $PQ $P $Q \n";
	    
	    if ($PQ>0){
		$MI+=$PQ*log($PQ/($Q*$P))/log(2);
	    }
	}
    }
    print "\t".(int($MI*1000)/1000)."";
    

    #MI-I-u-Exp
    $MI=0;
    foreach my $gi (keys %GroupItem){
	foreach my $u (keys %UserGroup){
	    my $PQ=$ItemGroupSingleUserExpo{$gi}{$u}/$TotExpo;
	    my $P=$ItemGroupExpo{$gi}/$TotExpo;
	    my $Q=$UserExpo{$u}/$TotExpo;
	    #print "\n---> $gi $gu $PQ $P $Q \n";
	    if ($PQ>0){
		$MI+=$PQ*log($PQ/($Q*$P))/log(2);
	    }
	}
    }
    print "\t".(int($MI*1000)/1000)."";


    #MI-I-u-Eff
    $MI=0;
    foreach my $gi (keys %GroupItem){
	foreach my $u (keys %UserGroup){
	    my $PQ=$ItemGroupSingleUserEff{$gi}{$u}/$TotEff;
	    my $P=$ItemGroupEff{$gi}/$TotEff;
	    my $Q=$UserEff{$u}/$TotEff;
	    #print "\n---> $gi $gu $PQ $P $Q \n";
	    if ($PQ>0){
		$MI+=$PQ*log($PQ/($Q*$P))/log(2);
	    }
	}
    }
    print "\t".(int($MI*1000)/1000)."";








    
    ######################################

    #MI-i-U-Psi
    $MI=0;
    foreach my $i (keys %ItemGroup){
	foreach my $gu (keys %GroupUser){
	    my $PQ=$SingleItemUserGroupUtil{$i}{$gu}/$TotUtil;
	    my $P=$ItemUtil{$i}/$TotUtil;
	    my $Q=$UserGroupUtil{$gu}/$TotUtil;
	    #print "\n---> $gi $gu $PQ $P $Q \n";
	    if ($PQ>0){
		$MI+=$PQ*log($PQ/($Q*$P))/log(2);
	    }
	}
    }
    print "\t".(int($MI*1000)/1000)."";
    

    
    #MI-i-U-Exp
    $MI=0;
    foreach my $i (keys %ItemGroup){
	foreach my $gu (keys %GroupUser){
	    my $PQ=$SingleItemUserGroupExpo{$i}{$gu}/$TotExpo;
	    my $P=$ItemExpo{$i}/$TotExpo;
	    my $Q=$UserGroupExpo{$gu}/$TotExpo;
	    #print "\n---> $i $gu $PQ $P $Q \n";
	    if ($PQ>0){
		$MI+=$PQ*log($PQ/($Q*$P))/log(2);
	    }
	}
    }
    print "\t".(int($MI*1000)/1000)."";
    

        
    #MI-i-U-Eff
    $MI=0;
    foreach my $i (keys %ItemGroup){
	foreach my $gu (keys %GroupUser){
	    my $PQ=$SingleItemUserGroupEff{$i}{$gu}/$TotEff;
	    my $P=$ItemEff{$i}/$TotEff;
	    my $Q=$UserGroupEff{$gu}/$TotEff;
	    #print "\n---> $i $gu $PQ $P $Q \n";
	    if ($PQ>0){
		$MI+=$PQ*log($PQ/($Q*$P))/log(2);
	    }

	}
    }
    print "\t".(int($MI*1000)/1000)."";
    
    
    
    
    print "\n";
    
    
    
    

    
}




sub max(){
    my $a=shift;
    my $b=shift;
    if ($b>$a){
	$a=$b;
    }	
    return $a;
}

    
