--------------------------------------------------------
--  DDL for Package PAC_PROVI_MV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_PROVI_MV" authid current_user is
function f_pintec_adicional (pmodo IN NUMBER, psproduc in number, reserva_bruta IN NUMBER,
                             pfecha IN DATE, pinteres OUT NUMBER, psseguro in number ) return number;

FUNCTION F_calculos_cap_garantit(psuplem IN NUMBER,pmodo IN NUMBER,pfefecto IN DATE,pfecha IN DATE,
	psproduc IN NUMBER, IPFIJA IN NUMBER, CFPAGO IN NUMBER, IAPEXTIN IN NUMBER,
	pfnacimi IN DATE, NSEXE IN NUMBER, irevali in number,prevali IN NUMBER, --
	ptipo IN NUMBER, pfcaranu in date, ndiaspro IN NUMBER, psseguro in number default null,
	capital OUT NUMBER, capital_mort OUT NUMBER, aportaciones OUT NUMBER)
   RETURN NUMBER;

FUNCTION F_calculos_provmat(pmodo IN NUMBER,psseguro number, pfecha date)
   RETURN NUMBER;

FUNCTION F_capital_risc_a_fecha(pmodo IN NUMBER,psseguro IN NUMBER, pfecha IN DATE,
                                provision in number)
   RETURN NUMBER;

FUNCTION F_capital(num_sesion in number,psuplem in number,pmodo IN NUMBER,pfefecto IN NUMBER,pfecha IN NUMBER,
	psproduc IN NUMBER, IPFIJA IN NUMBER, CFPAGO IN NUMBER, IAPEXTIN IN NUMBER,
	pfnacimi IN NUMBER, NSEXE IN NUMBER, irevali in number,prevali IN NUMBER,
	ptipo IN NUMBER, pfcaranu in number, NDIASPRO in number, psseguro IN NUMBER default null,
	pcmovimi in number default null, pimovimi in number default null)
   RETURN NUMBER;

FUNCTION f_capital_actual(psseguro in number, pfecha in date, num_err out number)
RETURN number;

FUNCTION F_capital_mort_garantit(num_sesion in number,psuplem in number,pmodo IN NUMBER,pfefecto IN NUMBER,pfecha IN NUMBER,
	psproduc IN NUMBER, IPFIJA IN NUMBER, CFPAGO IN NUMBER, IAPEXTIN IN NUMBER,
	pfnacimi IN NUMBER, NSEXE IN NUMBER, irevali in number,prevali IN NUMBER,
	ptipo IN NUMBER, pfcaranu in number, ndiaspro in number)
   RETURN NUMBER;
FUNCTION F_aportaciones(num_sesion IN NUMBER,psuplem in number,pmodo IN NUMBER,pfefecto IN NUMBER,pfecha IN NUMBER,
	psproduc IN NUMBER, IPFIJA IN NUMBER, CFPAGO IN NUMBER, IAPEXTIN IN NUMBER,
	pfnacimi IN NUMBER, NSEXE IN NUMBER, irevali in number,prevali IN NUMBER,
	ptipo IN NUMBER, pfcaranu in number, ndiaspro in number)
   RETURN NUMBER;
FUNCTION f_calformulas_cap_garan(psseguro IN NUMBER, pfecha IN DATE, pcampo IN VARCHAR2)
  RETURN NUMBER ;

END pac_provi_mv;
 
 

/

  GRANT EXECUTE ON "AXIS"."PAC_PROVI_MV" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_PROVI_MV" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_PROVI_MV" TO "PROGRAMADORESCSI";
