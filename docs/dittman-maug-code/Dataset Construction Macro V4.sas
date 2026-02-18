/* This program contains a macro that constructs the CEO dataset for a single year.
   "%construct(1999,5)" constructs the dataset for all executives who are CEO in 2000 and who are in the database for
   at least 5 years, i.e., at least from 1995-1999. 
   Most data (like ns and no) are taken from 1999; only the salary is constructed from 2000 (in this example). */

/* Version 4 incorporates the following changes compared to version 3:
   (1) The CEO's option portfolio is approximated using the Core & Guay (2002) one-year approximation 
       Due to this change, there are a number of other changes:
   (2) Observations are not deleted any more if options were repriced or reloaded. 
   (3) If shares and exercisable options are not separated (pinclopt='TRUE'), this and all previous years are deleted
       for this CEO. In version 3, this CEO was entirely removed from the dataset. 
   (4) The number of restricted shares held is now correctly adjusted for stock splits (this was an error in version 3)
   (5) The resulting file does not contain the variable IP any longer.
   (6) The resulting file contains the year in which the CEO is CEO (i.e. the contract period starting year) 
   (7) When a CEO leaves a company, he now looses all restricted stock and all unexercisable options.
   (8) The maturity of all options in the approximated options portfolio is multiplied by 0.7 before calculating the 
       representative option (this acknowledges the fact that CEOs typically exercise their options before maturity)
       The "maturity reduction factor" mat_red can be easily changed at the beginning of the IML procedure. 
   (9) For the wealth accumulation, we now use the January yields of U.S. government bonds with a maturity of one year
       downloaded from the website of the Federal Reserve Board. (Version 3 used 1-month T-bill rates from Ibbotson)
   (10)For calculating the Black-Scholes value of the options, we use the January yields of U.S. govnerment bonds with a
       maturity of six years downloaded from the website of the Federal Reserve Board. (Version 3 used 1-month rates). 
       Any change of the rates of returns must be made in the IML procedure AND in the A18 data step. */


libname dir 'D:\Forschung\2002 executive compensation\ExecuComp';
libname out 'D:\Forschung\2002 executive compensation\SAS';

options mprint mtrace;

%MACRO construct(year,history);

/* year is the considered year minus one
   history is the number of consecutive years (including the considered year) that must be available to be included */

data work.a1;
  merge dir.comptabl dir.coperol;
  by co_per_rol;
run;

/* *********************************************************************************************** */
/* delete those who are not CEO in considered year and worked in the same company in the last year */
/* *********************************************************************************************** */

data work.a2a;
  set work.a1;
  if year=%eval(&year+1);
  keep co_per_rol ceoann execid;
run;

data work.a2b;
  set work.a1;
  if year=&year;
  keep co_per_rol salary;
run;

data work.a2;
  merge work.a2a work.a2b;
  by co_per_rol;
  if ceoann='CEO';
  if salary=. then delete;
  flag=1;
  keep execid flag;
run;

proc sort data=work.a1; by execid; run;
proc sort data=work.a2; by execid; run;

data work.a3;
  merge work.a1 work.a2;
  by execid;
  if flag=1;
  if year>&year then delete;
  drop flag;
run;

/* ******************************************************************************* */
/* delete observations if no. of shares owned is missing + preceeding observations */
/* ******************************************************************************* */

data work.a4;
  set work.a3;
  if ((shrown=.) or (pinclopt='TRUE')) then flag=1; else flag=0;
run;

proc sort data=work.a4;
  by execid descending year descending flag;
run;

data work.a5;
  set work.a4;
  if execid^=lag(execid) then x=0;
  if flag=1 then x=1;
  retain x 0;
run;

data work.a6;
  set work.a5;
  if x=0;
  drop x flag;
run;

/* *********************************************/
/* delete those who do not have enough history */
/* *********************************************/

%if &history>1 %then %do;

%MACRO flag(year);

  data work.b&year;
    set work.a6;
    if year=&year;
    d&year=1;
   keep d&year execid;
  run;

  proc sort data=b&year nodup;
    by execid;
  run;

%MEND;

%do y=(&year-&history+1) %to (&year-1);
  %flag(&y);
%end;

data work.a7;
  merge a6 %do y=(&year-&history+1) %to (&year-1); b&y %end; ;
  by execid;
  %if &history=2 %then %do;
    %let y=%eval(&year-1);
    if d&y=1;
  %end;
  %else %do;
    %let y=%eval(&year-1);
    if d&y=1 %do y=(&year-&history+1) %to (&year-2); & d&y=1 %end; ;
  %end;
  drop %do y=(&year-&history+1) %to (&year-1); d&y %end; ;
run;

%end; /* if history>1 */

%else %do;

data work.a7;
  set work.a6;
run;

%end;

/* *********************************************************************************************** */
/* delete CEOs who are listed as executives for 2 companies in the same year for at least one year */
/* *********************************************************************************************** */

proc sort data=work.a7;
  by execid year;
run;

proc means data=work.a7 noprint;
  var salary;
  output out=work.a8 mean=xxx;
  by execid year;
run;

proc means data=work.a8 noprint;
  var _freq_;
  output out=work.a9 max=maxfreq;
  by execid;
run;

data work.a10;
  merge work.a7 work.a9;
  by execid;
  if maxfreq>1 then delete;
  drop maxfreq _freq_ _type_;
  total_salary=salary+bonus+othann+ltip+allothtot;
  execid_num=0; execid_num=execid;
  year_num=0; year_num=year;
  permid_num=0; permid_num=permid;
run;

/* *********************************************************************** */
/* add market and stock-split information, adjust numbers for stock splits */
/* *********************************************************************** */

data work.a11;
  set dir.codirfin;
  keep permid year prccf ajex divyield fyr shrsout ni empl bs_volatility;
run;

proc sort data=work.a10;
  by permid year;
run;

data work.a12; /* a12 is the pricipal input dataset for the main IML program */
  merge work.a10 work.a11;
  by permid year;
  if co_per_rol=. then delete;
  /* adjust number of shares and stock prices to stock splits */
  shrown_a=shrown*ajex;
  shrsout_a=shrsout*ajex;
  prccf_a=prccf/ajex;
  dps_a=divyield/100*prccf/ajex;
  no=(uexnumex+uexnumun)*ajex;
  soptexsh_a=soptexsh*ajex;
  rstkhld_a=rstkhld*ajex;
  uexnumun_a=uexnumun*ajex;
  uexnumex_a=uexnumex*ajex;
  fyr_num=0; fyr_num=fyr;
  * if execid_num=6; /* debugging line */
run;

proc sort data=work.a12;
  by execid year;
run;

/* ********************* */
/* prepare options table */
/* ********************* */

data work.a13;
  set work.a12;
  keep co_per_rol year execid ajex;
run;

proc sort data=work.a13;
  by co_per_rol year;
run;

data work.a14;
  merge dir.stgrttab work.a13;
  by co_per_rol year;
  if execid=. then delete;
  if numsecur=. then numsecur=0;
  numsecur_a=numsecur*ajex;
  execid_num=0; execid_num=execid;
  year_num=0; year_num=year;
  exdate=datepart(exdate);
  format exdate date9.;
  expric_a=expric/ajex;
  keep execid_num year_num numsecur_a expric_a exdate;
run;

proc sort data=work.a14;
  by execid_num year_num;
run;

/* ********************** */
/* book-keeping algorithm */
/* ********************** */

proc iml symsize=512;

  mat_red=0.7; /* maturity reduction factor */
  
  /* ******************************************************* */
  /* define module for calculating the representative option */
  /* ******************************************************* */

  START calc_opt(K,T,code) global(options,rf,S0,sigma,BSq,Nd1q);
    /* K,T and code are the data returned by the routine.
       options contains information on the individual option grants (for the organization of the options matrix see below)
       (module assumes that options is not empty and that none of the options has expired)
       rf, S0 and sigma are paramters needed for the Black-Scholes formula
       BSq and Nd1q are the average BS and Nd1 listed for passing them as global variables to the deviation function */
       
    /* define deviation function needed for minimization */
    START deviation(K_T) global(rf,S0,sigma,BSq,Nd1q);
	  /* K_T contains two elements: K and T */

	  /* calculate value and incentives of option */
	  PVK=K_T[1]*exp(-rf*K_T[2]);
      vol=sigma*sqrt(K_T[2]);
      d1=log(S0/PVK)/vol + 0.5*vol;
      d2=d1-vol;
      Nd1=PROBNORM(d1);
      Nd2=PROBNORM(d2);
      BS=S0*Nd1-PVK*Nd2;

	  /* calculate deviation */
      dev=((BS-BSq)/BSq)**2+((Nd1-Nd1q)/Nd1q)**2;

	  RETURN (dev);

	FINISH deviation;

    /* calculate average Black-Scholes value and average N(d1) over portfolios */
	BSq=0; Nd1q=0;
    do j=1 to nrow(options);
	  BSq=BSq+options[j,2]*options[j,5];
	  Nd1q=Nd1q+options[j,2]*options[j,6];
   	end; /* j=1 to nrow(options) */
	BSq=BSq/options[+,2];
	Nd1q=Nd1q/options[+,2];
      
    /* prepare minimization */
    termination={. . 0 0 0 0 . 1E-12 1E-12 .};
	boundaries={0.1 0.1, . .};
    start=J(1,2,.); start[1]=S0; start[2]=10;

	/* minimization and returning the results */
	call NLPNMS(rc,K_T,"deviation",start) tc=termination blc=boundaries;
    K=K_T[1]; T=K_T[2];	code=rc;
	      
  FINISH calc_opt;

  /* ******************************************************************************************** */
  /* module for completing and saving the results when the end of the data for one CEO is reached */
  /* ******************************************************************************************** */

  START save;

    /* load option table for last year */

    use work.a14;
      read var{year_num numsecur_a expric_a exdate} 
           where ((execid_num=(current_line[1])) & (year_num=(A[i-1,2]))) all into options; 
	  /* contents of options:
	     1: year
	     2: number of options in grant (in thousands)
	     3: exercise price (in dollars)
	     4: expiry date (as SAS date), overwritten by maturity 
		 5: Black Scholes value of a single option in the option grant (will be added later)
		 6: N(d1) of the option grant (will be added later) */

    close work.a14;

    /* calculate last day of fiscal year */
	month=A[i-1,12];
    if month=4 | month=6 | month=9 | month=11 then day=30;
	                                          else if month=2 then day=28;
		                                                      else day=31;

    /* calculate the individual options' maturity and multiply it by mat_red */
	do j=1 to nrow(options);
	  options[j,4]=(options[j,4]-mdy(month,day,A[i-1,2]))/365.25*mat_red;
	  if ((-options[j,4]>0) | ((options[j,4]=.) & (options[j,2]>0))) then do; 
        /* maturity negative or maturity missing but positive number of options */
        options[j,4]=.; 
		current_line[6]=-1;
	  end;
	end;

    /* calculate Black-Scholes value and N(d1) for each option in the portfolio */
	rf=R6[A[i-1,2]-1992+1]/100;
	S0=A[i-1,7];
	if S0=. then current_line[6]=-5;
	sigma=A[i-1,13];
	options=options||J(nrow(options),2,.);
    do j=1 to nrow(options);
	  if options[j,3]=0 then do;
	    options[j,5]=S0;
		options[j,6]=1;
	  end;
	  else do;
	    PVK=options[j,3]*exp(-rf*options[j,4]);
        vol=sigma*sqrt(options[j,4]);
        d1=log(S0/PVK)/vol + 0.5*vol;
        d2=d1-vol;
        Nd1=PROBNORM(d1);
        Nd2=PROBNORM(d2);
        options[j,5]=S0*Nd1-PVK*Nd2;
		options[j,6]=Nd1;
	  end;
	end; /* j=1 to nrow(options) */

	/* calculate number, value, and average maturity of options newly granted in this year */
    
    new_num=0;
	new_gain=0;
	new_avg_mat=0;

    do j=1 to nrow(options);
	  new_num=new_num+options[j,2];
	  new_gain=new_gain+options[j,2]*max(0,S0-options[j,3]);
	  new_avg_mat=new_avg_mat+options[j,2]*options[j,4];
	end;

	if new_num>0 then new_avg_mat=new_avg_mat/new_num;

	/* add two aggregated option grants according to Core & Guay (2002) in 4 steps */

	options=J(2,6,.)//options; /* first row: unexercisable, second row: exercisable */

	/* step 1: deduct number and value of newly granted options from number and value of unexercisable options */
	
	if new_num>A[i-1,15] then do; /* if more newly granted options that unexercisable options */
      options[1,2]=0;
	  gain_unex=0;
	  options[2,2]=max(A[i-1,16]-new_num+A[i-1,15],0);
	  gain_ex=max(A[i-1,18]-(new_num-A[i-1,15])*new_gain/new_num,0);
	end;
	else do;
	  options[1,2]=A[i-1,15]-new_num;
	  gain_unex=max(A[i-1,17]-new_gain,0);
	  options[2,2]=A[i-1,16];
	  gain_ex=A[i-1,18];
	end;

	/* step 2: estimating the strike price */

	if options[1,2]>0 then options[1,3]=S0-gain_unex/options[1,2];
	if options[2,2]>0 then options[2,3]=S0-gain_ex/options[2,2];
	if ((-options[1,3]>0) | (-options[2,3]>0)) then do; /* if strike price is negative (not if missing) */
	  options[1,3]=.;
	  options[2,3]=.;
	  current_line[6]=-4;
	end;

	/* step 3: setting the maturity */

	if new_avg_mat=0 then do;
	  options[1,4]=9*mat_red;
	  options[2,4]=6*mat_red;
	end;
	else do;
	  options[1,4]=max(new_avg_mat-1*mat_red,1);
	  options[2,4]=max(new_avg_mat-3*mat_red,1);
	end;

	/* step 4: calculate Black-Scholes value and N(d1) */

    do j=1 to 2;
	  if options[j,3]=0 then do;
	    options[j,5]=S0;
		options[j,6]=1;
	  end;
	  else do;
	    PVK=options[j,3]*exp(-rf*options[j,4]);
        vol=sigma*sqrt(options[j,4]);
        d1=log(S0/PVK)/vol + 0.5*vol;
        d2=d1-vol;
        Nd1=PROBNORM(d1);
        Nd2=PROBNORM(d2);
        options[j,5]=S0*Nd1-PVK*Nd2;
		options[j,6]=Nd1;
	  end;
	end; /* j=1 to 2 */	

	* print options gain_unex gain_ex;   /* debugging line */

	/* save total number of options according to execucomp and according to our book-keeping */
    current_line[4]=A[i-1,15]+A[i-1,16]; /* execucomp */

	/* initialize and call module for the calculation of the representative option */
	K=0; T=0;
	if sigma=. then current_line[6]=-3; 

	if ((current_line[4]>0) & (options[+,2]>0) & (current_line[6]=0)) then do;
	  call calc_opt(K,T,code);
	  current_line[7]=K;
	  current_line[8]=T;
	  if code<0 then current_line[6]=-2; /* signal numerical problems */
	end;

	/* set "representative option" if there are no options */
	if current_line[4]=0 then do;
	  current_line[7]=S0;
	  current_line[8]=10;
	end;

	/* save new entry */
    output=output//current_line;

  FINISH save;

  /* load annual data into the matrix A */
  use work.a12;
     read var{execid_num year_num total_salary rstkgrnt soptexer shrown_a prccf_a dps_a permid_num no 
              soptexsh_a fyr_num bs_volatility rstkhld_a uexnumun_a uexnumex_a inmonun inmonex} into A all;
  close work.a12;

  /* contents of A:
     1: Executive ID
     2: Year
     3: total salary (in thousand dollars)
     4: value of restricted stock grants (in thousand dollars)
     5: net value realized from exercising options (in thousand dollars)
     6: total number of shares owned (in thousands)
     7: closing price of the company's stock for the fiscal year (dollars)
     8: dividends per share (dollars)
     9: company ID
     10: vacant: not needed any longer
     11: vacant: not needed any longer
     12: month of fiscal year end 
     13: Black-Scholes Volatility sigma 
     14: number of shares of restricted stock (in thousands)
     15: number of unexercisable options held (in thousands)
     16: number of exercisable options held (in thousands)
     17: realizable value from unexercisable options held (in thousand dollars)
     18: realizable value from exercisable options held (in thousand dollars) */

  /* define one-year and six-year returns on government bonds from 1993 to 2000
     see the folder C:\...\2002 executive compensation\ExecuComp\return data for source information */

  R={3.5, 3.54, 7.05, 5.09, 5.61, 5.24, 4.51, 6.12};
  R6={6.05, 5.26, 7.78, 5.45, 6.4, 5.48, 4.7, 6.64};
  
  /* define output matrix (it grows endogenously) */
  output=J(1,8,.);
  current_line=J(1,8,0);
  /* contents of output:
     1: executive id (execid)
     2: wealth (in thousands)
     3: number of shares (in last year, in thousands)
     4: number of options (in last year, in thousands)
     5: number of shares of restricted stock (in last year, in thousands)
     6: error code (-1: negative or missing option maturity; -2: representative option could not be found; 
                    -3: sigma is missing; -4: negative strike price; -5: missing stock price) 
     7: strike price of representative option (in dollars)
     8: maturity of the representative option (in years)*/

  do i=1 to nrow(A);

    /* determine personal tax rate */
	if A[i,2]=1992 then tau=0.31;
	if A[i,2]=1993 then tau=0.396;
	if A[i,2]>1993 then tau=0.42;
    
    /* CASE 1: new CEO: save and start again */
    if A[i,1]^=current_line[1] then do;

      /* invoke "save" module */
	  if current_line[1]>0 then run save;    

	  /* initialize new current line */
	  current_line[1]=A[i,1];                  /* execid */
        /* wealth=first-year salary plus (if not missing) net value realized from exercising options (both after tax) */
	  if A[i,5]=. then current_line[2]=A[i,3]*(1-tau); 
	              else current_line[2]=(A[i,3]+A[i,5])*(1-tau); 
	  current_line[3]=A[i,6];                  /* number of shares held=first-year shrown */
	  current_line[5]=A[i,14];                 /* number of shares of restricted stock */
      current_line[4]=.;                       /* number of options */
	  current_line[6]=0;                       /* error flag */
	  current_line[7]=.;                       /* strike price of representative option */
	  current_line[8]=.;                       /* maturity of representative option */

	  * print (A[i,]) current_line, '++++++++++++++++++'; /* debugging line */

	end; /* if A[i,1]^=current_line[1] */

	else do;

	/* CASE 2: CEO and company stay constant (no change) */
	  if A[i,9]=A[i-1,9] then do;

        /* growth of invested wealth (allowing for gaps in the data) */
	    do j=A[i-1,2]+1 to A[i,2];
		  current_line[2]=current_line[2]*(1+R[j-1992]/100);
		end;

		/* calculate taxes on restricted stock that becomes unrestricted stock */
		/* value of restr. stock (t) = value of restr. stock (t-1) - value of restr. stock that becomes unrestricted
		   + value of additional restr. stock granted */
		rst_tax=max(0,(current_line[5]-A[i,14])*A[i,7]+A[i,4])*tau;

	    /* new wealth=grown old wealth + value of restr. stock grant - taxes on restr. stock that became unrestr.
		              + (dividend income + new salary + value realized from exercising options)*(1-tau)
		              - additional investment in shares */
	    current_line[2] = current_line[2] + A[i,4] - rst_tax
                        + (current_line[3]*A[i,8] + A[i,3] + A[i,5])*(1-tau)
                        - (A[i,6]-current_line[3])*A[i,7];
	    current_line[3]=A[i,6];  /* update number of shares held */
		current_line[5]=A[i,14]; /* update number of shares of restricted stock held */

		* print (A[i,]) current_line, '++++++++++++++++++'; /* debugging line */

	  end; /* if A[i,9]=A[i-1,9] */

	/* CASE 3: same CEO, different company: CEO switched company */
	  else do;

	    /* sell all unrestricted shares */
	    current_line[2]=current_line[2]+max(current_line[3]-current_line[5],0)*A[i-1,7];

		/* exercise all exercisable in-the-money options */
		current_line[2]=current_line[2]+A[i-1,18];

        /* growth of invested wealth (allowing for gaps in the data) */
	    do j=A[i-1,2]+1 to A[i,2];
		  current_line[2]=current_line[2]*(1+R[j-1992]/100);
		end;

	    /* new wealth=grown old wealth + new salary + value of restricted stock grants - purchase of new shares */
	    current_line[2]=current_line[2]+A[i,3]*(1-tau)+A[i,4]-A[i,6]*A[i,7];
	    current_line[3]=A[i,6];  /* number of stocks in new company */
		current_line[5]=A[i,14]; /* number of shares of restricted stock in new company */

		* print (A[i,]) current_line, '+++++++++CEO CHANGE+++++++++'; /* debugging line */

	  end; /* else do */
	end; /* else do */
  end; /* do i=1 to nrow(A) */

  /* save results for last CEO */
  run save;
  output=output[2:nrow(output),];

  /* save new dataset */
  create work.ceo var{execid_num W0 nS nO nSr error K T};
    append from output;
  close work.ceo;

quit;

/* delete observations with errors or missing or negative wealth */

data work.a15;
  set work.ceo;
  if W0=. then delete;
  if W0<0 then delete;
  if error<0 then delete;
  year_num=&year;
run;

/* merge with financial data on the firm */

data work.a16;
  merge work.a15 work.a12;
  by execid_num year_num;
  if W0=. then delete;
  nSu=max(0,nS-nSr);
  nS=nS/shrsout_a/1000;
  nSu=nSu/shrsout_a/1000;
  nO=nO/shrsout_a/1000;
  NumOfShares=shrsout_a*1000;
  K=K*NumOfShares;
  P0=prccf_a*NumOfShares;
  sigma=bs_volatility;
  if sigma=. then delete;
  if shrsout_a=. then delete;
  d=divyield/100;
  keep execid_num W0 nS nSu nO K T P0 NumOfShares sigma year_num permid d;
run;

/* include risk-free return */

data work.a18;
  set work.a16;
  select (year_num+1);
    when (1997) rf=0.064;
	when (1998) rf=0.0548;
	when (1999) rf=0.047;
	when (2000) rf=0.0664;
	otherwise rf=.;
  end;
  drop year_num;
run;

/* merge with salary in year+1 */

data work.a19;
  set work.a1;
  if year=%eval(&year+1);
  phi=salary+bonus+othann+allothtot;
  execid_num=0; execid_num=execid;
  keep execid_num phi permid;
run;

proc sort data=work.a19;
  by execid_num permid;
run;

proc sort data=work.a18;
  by execid_num permid;
run;

data work.a20;
  merge work.a18 work.a19;
  by execid_num permid;
  if W0=. then delete;
  if phi=. then delete;
run;

/* prepare dataset for the optimization routine */

data work.a21;   /* calculate Black-Scholes values assuming continuous compounding */
  set work.a20;
  PVK=K*exp(-rf*T);
  S0=P0*exp(-d*T);      
  vol=sigma*sqrt(T);
  d1=log(S0/PVK)/vol + 0.5*vol;
  d2=d1-vol;
  Nd1=PROBNORM(d1);
  Nd2=PROBNORM(d2);
  BS=S0*Nd1-PVK*Nd2;
  year=%eval(&year+1);
  drop PVK S0 vol d1 d2;
run;

data work.CEO_%eval(&year+1)_&history.yrs;  /* calculate further constants */
  set work.a21;
  pi=2*arsin(1);
  CV=sigma*sqrt(T);                                         /* cumulative volatility */
  LD=exp((-d-0.5*(sigma**2))*T)/sqrt(2*pi);                 /* constants of lognormal density */
  PC=P0*exp(T*(rf-d-(sigma**2)/2));                         /* price constant*/			
  MD2=(log(K/P0)-(rf-d)*T+(sigma**2)*T/2)/(sigma*sqrt(T));  /* point of discontinuity */
  drop pi;
run;

%MEND;

%construct(1999,5);

data out.ceo_2000_5yrs_V4;
  set work.ceo_2000_5yrs;
run;