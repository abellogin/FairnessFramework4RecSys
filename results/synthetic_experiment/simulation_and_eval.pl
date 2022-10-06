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
my $TotSamples=100;


my %Pri=();
my %Expo=();

for (my $i=1;$i<=100;$i++){
    for (my $u=1;$u<=100;$u++){
	$Util{$i}{$u}=&max(1/sqrt($i*$u),1/sqrt((101-$i)*(101-$u)));
	#print "$i $u $Util{$i}{$u}\n";
    }	   
}

for (my $c=1;$c<=10;$c++){
    $ItemGroup{$c}="I";
    $UserGroup{$c}="A";
    $GroupItem{"I"}{$c};
    $GroupUser{"A"}{$c};
    $GSize{"I"}++;
    $GSize{"A"}++;
    
}
for (my $c=11;$c<=40;$c++){
    $ItemGroup{$c}="II";
    $UserGroup{$c}="B";
    $GroupItem{"II"}{$c};
    $GroupUser{"B"}{$c};
    $GSize{"II"}++;
    $GSize{"B"}++;
}
for (my $c=41;$c<=100;$c++){
    $ItemGroup{$c}="III";
    $UserGroup{$c}="C";
    $GroupItem{"III"}{$c};
    $GroupUser{"C"}{$c};
    $GSize{"III"}++;
    $GSize{"C"}++;
}

for (my $i=1;$i<=100;$i++){
    for (my $u=1;$u<=100;$u++){
	$ItemUtil{$i}+=$Util{$i}{$u};
	$UserUtil{$u}+=$Util{$i}{$u};
	$TotUtil+=$Util{$i}{$u};
	$ItemGroupUtil{$ItemGroup{$i}}+=$Util{$i}{$u};
	#print "ITEM GROUP UTIL $ItemGroup{$i} = $ItemGroupUtil{$ItemGroup{$i}}\n";
	$UserGroupUtil{$UserGroup{$u}}+=$Util{$i}{$u};
	$ItemUserGroupUtil{$ItemGroup{$i}}{$UserGroup{$u}}+=$Util{$i}{$u};
	$ItemGroupSingleUserUtil{$ItemGroup{$i}}{$u}+=$Util{$i}{$u};
	$SingleItemUserGroupUtil{$i}{$UserGroup{$u}}+=$Util{$i}{$u};
    }
}


for (my $i=1;$i<=100;$i++){
    for (my $u=1;$u<=100;$u++){
	$Pri{"ORACLE"}{$i}{$u}=$Util{$i}{$u};
	$Pri{"RAND"}{$i}{$u}=rand();
	$Pri{"POPULARITY"}{$i}{$u}=$ItemUtil{$i};
	$Pri{"RANDOMIZED_ORACLE"}{$i}{$u}=$Util{$i}{$u}*rand();
	#my $p=$GSize{$ItemGroup{$i}}/100;
	#my $r = random_beta(1,1,$p/(1-$p));
	my $p=100/$GSize{$ItemGroup{$i}};
	$Pri{"ITEM_GROUP_SIZE_NORMALIZED_ORACLE"}{$i}{$u}=$Util{$i}{$u}*$p;
	
	$p=$ItemGroupUtil{$ItemGroup{$i}}/(100*$GSize{$ItemGroup{$i}});
	$Pri{"ITEM_GROUP_EXPOSURE_CALIBRATED_ORACLE"}{$i}{$u}=$Util{$i}{$u}*$p;
	$Pri{"ITEM_GROUP_EXPOSURE_CALIBRATED_ORACLE_RAND"}{$i}{$u}=rand()*$p;
	

	#my $pi=($GSize{$ItemGroup{$i}})/100;
	#my $pu=($GSize{$UserGroup{$u}})/100;
	my $pi=$ItemGroupUtil{$ItemGroup{$i}}/$TotUtil;
	my $pu=$UserGroupUtil{$UserGroup{$u}}/$TotUtil;
	$Pri{"ITEM_USER_GROUP_DEBIASED_ORACLE"}{$i}{$u}=$Util{$i}{$u}/($pi*$pu);
	$p=$SingleItemUserGroupUtil{$i}{$UserGroup{$u}}/$ItemUtil{$i};
	$Pri{"USER_GROUP_SINGLE_ITEM_DEBIASED_ORACLE"}{$i}{$u}=$Util{$i}{$u}/$p;
	$p=$ItemGroupSingleUserUtil{$ItemGroup{$i}}{$u}/$UserUtil{$u};
	$Pri{"ITEM_GROUP_SINGLE_USER_DEBIASED_ORACLE"}{$i}{$u}=$Util{$i}{$u}/$p;

    }	
}

my @baselineList=("ORACLE","RAND","POPULARITY","RANDOMIZED_ORACLE","ITEM_GROUP_SIZE_NORMALIZED_ORACLE",
		  "ITEM_GROUP_EXPOSURE_CALIBRATED_ORACLE","ITEM_GROUP_EXPOSURE_CALIBRATED_ORACLE_RAND",
		  "ITEM_USER_GROUP_DEBIASED_ORACLE",
		  "ITEM_GROUP_SINGLE_USER_DEBIASED_ORACLE",
		  "USER_GROUP_SINGLE_ITEM_DEBIASED_ORACLE");

print "BASELINE\t".
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
    "MI-u-I-Psi\t".
    "MI-u-I-Exp\t".
    "MI-u-I-Eff\t".
    "MI-U-i-Psi\t".
    "MI-U-i-Exp\t".
    "MI-U-i-Eff";
print "\n";

foreach my $baseline (@baselineList){

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
    
    print "$baseline";
    for (my $u=1;$u<=100;$u++){
	my $rank=1;
	foreach my $i (sort {$Pri{$baseline}{$b}{$u} <=> $Pri{$baseline}{$a}{$u}} keys %ItemUtil) {
	    $Expo{$i}{$u}=1/(log($rank+1)/log(2));
	    #$Expo{$i}{$u}=0.8**($rank-1);
	    #$Expo{$i}{$u}=int(0.8**($rank-1)*1000)/1000;
	    #if ($Expo{$i}{$u}==0){
	#	$Expo{$i}{$u}=0.001
	    #}
	    #print "EXPO $Expo{$i}{$u}  ".(1/(log($rank+1)/log(2)))."\n";
	    
	    #if ($rank<=30){
	#	$Expo{$i}{$u}=1;
	    #}else{
	#	$Expo{$i}{$u}=0.00000001;
	    #}
	    #print "user $u item $i util $Util{$i}{$u} Expo = $Expo{$baseline}{$i}{$u}\n";
	    $rank++;
	    $Eff{$i}{$u}=$Util{$i}{$u}*$Expo{$i}{$u};
	    
	    $UserEff{$u}+=$Eff{$i}{$u};
	    $ItemEff{$i}+=$Eff{$i}{$u};
	    $ItemGroupEff{$ItemGroup{$i}}+=$Eff{$i}{$u};
	    $UserGroupEff{$UserGroup{$u}}+=$Eff{$i}{$u};
	    $ItemUserGroupEff{$ItemGroup{$i}}{$UserGroup{$u}}+=$Eff{$i}{$u};
	    $SingleItemUserGroupEff{$i}{$UserGroup{$u}}+=$Eff{$i}{$u};
	    $ItemGroupSingleUserEff{$ItemGroup{$i}}{$u}+=$Eff{$i}{$u};
	    
	    $TotEff+=$Eff{$i}{$u};

	    	  
	    $EffRec{$i}{$u}=$Util{$i}{$u}/$UserUtil{$u}*$Expo{$i}{$u};  
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

    
    print "\t".(0.2*int($TotEff*1000)/100000)."";

    
    ######################################
    #INEQUITY-USER GROUP-UTILITY BIAS-GROUP SIZE PROPORTIONAL
    my $kl=0;
    foreach my $g (keys %GroupUser){
	my $P=$UserGroupUtil{$g}/$TotUtil;
	my $Q=$GSize{$g}/$TotSamples;
	$kl+=$P*log($P/$Q)/log(2);
    }
    print "\t".(int($kl*1000)/1000)."";

    #INEQUITY-ITEM GROUP-UTILITY BIAS-GROUP SIZE PROPORTIONAL
    $kl=0;
    foreach my $g (keys %GroupItem){
	my $P=$ItemGroupUtil{$g}/$TotUtil;
	my $Q=$GSize{$g}/$TotSamples;
	$kl+=$P*log($P/$Q)/log(2);
    }
    print "\t".(int($kl*1000)/1000)."";

    
    ######################################
    #INEQUITY-USER GROUP-UTILITY BIAS-Uniform
    my $kl=0;
    foreach my $g (keys %GroupUser){
	my $P=$UserGroupUtil{$g}/$TotUtil;
	my $Q=1/3;
	$kl+=$P*log($P/$Q)/log(2);
    }
    print "\t".(int($kl*1000)/1000)."";


    
    #INEQUITY-ITEM GROUP-UTILITY BIAS-Uniform
    $kl=0;
    foreach my $g (keys %GroupItem){
	my $P=$ItemGroupUtil{$g}/$TotUtil;
	my $Q=1/3;
	my $Q=$GSize{$g}/$TotSamples;
	$kl+=$P*log($P/$Q)/log(2);
    }
    print "\t".(int($kl*1000)/1000)."";





    
    ######################################
    #INEQUITY-User group-Exposure-Uniform
    $kl=0;
    foreach my $g (keys %GroupUser){
	my $P=$UserGroupExpo{$g}/$TotExpo;
	my $Q=1/3;
	$kl+=$P*log($P/$Q)/log(2);
    }    
    print "\t".(int($kl*1000)/1000)."";

        
    #INEQUITY-User group-Exposure-Proportionality
    $kl=0;
    foreach my $g (keys %GroupUser){
	my $P=$UserGroupExpo{$g}/$TotExpo;
	my $Q=$GSize{$g}/$TotSamples;
	$kl+=$P*log($P/$Q)/log(2);
    }    
    print "\t".(int($kl*1000)/1000)."";

    #INEQUITY-User group-Exposure-UtilityEqualized
    $kl=0;
    foreach my $g (keys %GroupUser){
	my $P=$UserGroupExpo{$g}/$TotExpo;
	my $Q=$UserGroupUtil{$g}/$TotUtil;
	$kl+=$P*log($P/$Q)/log(2);
    }    
    print "\t".(int($kl*1000)/1000)."";



    
    ######################################
    #INEQUITY-User group-Eff-Uniform
    $kl=0;
    foreach my $g (keys %GroupUser){
        my $P=$UserGroupEff{$g}/$TotEff;
	my $Q=1/3;
	$kl+=$P*log($P/$Q)/log(2);
    }    
    print "\t".(int($kl*1000)/1000)."";

        
    #INEQUITY-User group-Eff-Proportionality
    $kl=0;
    foreach my $g (keys %GroupUser){
        my $P=$UserGroupEff{$g}/$TotEff;
	my $Q=$GSize{$g}/$TotSamples;
	$kl+=$P*log($P/$Q)/log(2);
    }    
    print "\t".(int($kl*1000)/1000)."";

    #INEQUITY-User group-Eff-UtilityEqualized
    $kl=0;
    foreach my $g (keys %GroupUser){
        my $P=$UserGroupEff{$g}/$TotEff;
	my $Q=$UserGroupUtil{$g}/$TotUtil;
	$kl+=$P*log($P/$Q)/log(2);
    }    
    print "\t".(int($kl*1000)/1000)."";



    
    ######################################
    #INEQUITY-Item group-Exposure-Uniform
    $kl=0;
    foreach my $g (keys %GroupItem){
	my $P=$ItemGroupExpo{$g}/$TotExpo;
	my $Q=1/3;
	$kl+=$P*log($P/$Q)/log(2);
    }    
    print "\t".(int($kl*1000)/1000)."";

        
    #INEQUITY-Item group-Exposure-Proportionality
    $kl=0;
    foreach my $g (keys %GroupItem){
	my $P=$ItemGroupExpo{$g}/$TotExpo;
	my $Q=$GSize{$g}/$TotSamples;
	$kl+=$P*log($P/$Q)/log(2);
    }    
    print "\t".(int($kl*1000)/1000)."";

    #INEQUITY-Item group-Exposure-UtilityEqualized
    $kl=0;
    foreach my $g (keys %GroupItem){
	my $P=$ItemGroupExpo{$g}/$TotExpo;
	my $Q=$ItemGroupUtil{$g}/$TotUtil;
	$kl+=$P*log($P/$Q)/log(2);
    }    
    print "\t".(int($kl*1000)/1000)."";



    
    ######################################
    #INEQUITY-Item group-Eff-Uniform
    $kl=0;
    foreach my $g (keys %GroupItem){
	my $P=$ItemGroupEff{$g}/$TotEff;
	my $Q=1/3;
	$kl+=$P*log($P/$Q)/log(2);
    }    
    print "\t".(int($kl*1000)/1000)."";

        
    #INEQUITY-Item group-Eff-Proportionality
    $kl=0;
    foreach my $g (keys %GroupItem){
	my $P=$ItemGroupEff{$g}/$TotEff;
	my $Q=$GSize{$g}/$TotSamples;
	$kl+=$P*log($P/$Q)/log(2);
    }    
    print "\t".(int($kl*1000)/1000)."";

    #INEQUITY-Item group-Eff-UtilityEqualized
    $kl=0;
    foreach my $g (keys %GroupItem){
	my $P=$ItemGroupEff{$g}/$TotEff;
	my $Q=$ItemGroupUtil{$g}/$TotUtil;
	$kl+=$P*log($P/$Q)/log(2);
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
	    $MI+=$PQ*log($PQ/($Q*$P))/log(2);
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
	    $MI+=$PQ*log($PQ/($Q*$P))/log(2);
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
	    $MI+=$PQ*log($PQ/($Q*$P))/log(2);
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
	    $MI+=$PQ*log($PQ/($Q*$P))/log(2);
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
	    $MI+=$PQ*log($PQ/($Q*$P))/log(2);
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
	    $MI+=$PQ*log($PQ/($Q*$P))/log(2);
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
	    $MI+=$PQ*log($PQ/($Q*$P))/log(2);
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
	    $MI+=$PQ*log($PQ/($Q*$P))/log(2);
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
	    $MI+=$PQ*log($PQ/($Q*$P))/log(2);
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

    
