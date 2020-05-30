--------------------------------------------------------
--  DDL for Package PAC_PROVI_MV_PRUEBAS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_PROVI_MV_PRUEBAS" authid current_user is
function f_permf2000
		 (ptabla IN number, pedad in number, psexo in number,
		  pnacim in number, ptipo in number, psimbolo in varchar2)
		  return number;
function f_lx_i (pfecha1 in date, pfecha2 in date, psexo in number,
                 pnacim in number, ptipo in number)
		 return number;
function f_cr (pfechaini in date, pfechafin	in date, pfnacimi IN DATE,
               psexo in number,  ptipo in number, paportacion in number,
			   pinteres in number)
		 return number;
function f_PM (reserva_bruta IN NUMBER, pfechaini IN DATE, pfechafin IN DATE, pinteres in number,
               psproduc IN NUMBER, pfnacimi IN DATE, pcsexo IN NUMBER, ptipo IN NUMBER,
			   ppgasext IN NUMBER, ppgasint IN NUMBER)
         return NUMBER ;

FUNCTION F_calculos_cap_garantit(psuplem IN NUMBER,pmodo IN NUMBER,pfefecto IN DATE,pfecha IN DATE,
	psproduc IN NUMBER, IPFIJA IN NUMBER, CFPAGO IN NUMBER, IAPEXTIN IN NUMBER,
	pfnacimi IN DATE, NSEXE IN NUMBER, irevali in number,prevali IN NUMBER, --
	ptipo IN NUMBER, pfcaranu in date, ndiaspro IN NUMBER,
	capital OUT NUMBER, capital_mort OUT NUMBER, aportaciones OUT NUMBER)
   RETURN NUMBER;

FUNCTION F_calculos_provmat(pmodo IN NUMBER,psseguro number, pfecha date)
   RETURN NUMBER;

FUNCTION F_provmat_linea(pmodo IN NUMBER,psseguro IN NUMBER, pfecha IN DATE,
                         pcmovimi in number, pimovimi in number, psproduc IN NUMBER,
						 pinttec  IN NUMBER, pfnacimi IN DATE, pcsexo  IN NUMBER,
						 ptipo   IN NUMBER, pgasext in number, pgasint in number)
  RETURN NUMBER;

FUNCTION F_calculo_intereses(pmodo IN VARCHAR2,psseguro IN NUMBER, pfecha IN DATE,
                             intereses OUT  number) return number;

FUNCTION F_capital(num_sesion in number,psuplem in number,pmodo IN NUMBER,pfefecto IN NUMBER,pfecha IN NUMBER,
	psproduc IN NUMBER, IPFIJA IN NUMBER, CFPAGO IN NUMBER, IAPEXTIN IN NUMBER,
	pfnacimi IN NUMBER, NSEXE IN NUMBER, irevali in number,prevali IN NUMBER,
	ptipo IN NUMBER, pfcaranu in number, NDIASPRO in number, psseguro IN NUMBER default null,
	pcmovimi in number default null, pimovimi in number default null)
   RETURN NUMBER;

FUNCTION F_capital_mort(num_sesion in number,psuplem in number,pmodo IN NUMBER,pfefecto IN NUMBER,pfecha IN NUMBER,
	psproduc IN NUMBER, IPFIJA IN NUMBER, CFPAGO IN NUMBER, IAPEXTIN IN NUMBER,
	pfnacimi IN NUMBER, NSEXE IN NUMBER, irevali in number,prevali IN NUMBER,
	ptipo IN NUMBER, pfcaranu in number, ndiaspro in number)
   RETURN NUMBER;
FUNCTION F_aportaciones(num_sesion IN NUMBER,psuplem in number,pmodo IN NUMBER,pfefecto IN NUMBER,pfecha IN NUMBER,
	psproduc IN NUMBER, IPFIJA IN NUMBER, CFPAGO IN NUMBER, IAPEXTIN IN NUMBER,
	pfnacimi IN NUMBER, NSEXE IN NUMBER, irevali in number,prevali IN NUMBER,
	ptipo IN NUMBER, pfcaranu in number, ndiaspro in number)
   RETURN NUMBER;
END pac_provi_mv_pruebas;

 
 

/

  GRANT EXECUTE ON "AXIS"."PAC_PROVI_MV_PRUEBAS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_PROVI_MV_PRUEBAS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_PROVI_MV_PRUEBAS" TO "PROGRAMADORESCSI";
