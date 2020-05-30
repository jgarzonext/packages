--------------------------------------------------------
--  DDL for Package PAC_SIMUL_COMU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_SIMUL_COMU" AUTHID CURRENT_USER IS
/******************************************************************************
  04/04/2007.
  Package encargado de las simulaciones. Tiene funciones comunes.

******************************************************************************/
   FUNCTION f_actualiza_riesgo(pssolicit IN NUMBER, pnriesgo IN NUMBER, pfnacimi IN DATE, psexo IN NUMBER,
                               pnombre IN VARCHAR2,  ptapelli IN VARCHAR2)
   RETURN NUMBER;

   FUNCTION f_actualiza_asegurado(pssolicit IN NUMBER, pnorden IN NUMBER, pfnacimi IN DATE, psexo IN NUMBER,
                                  pnombre IN VARCHAR2,  ptapelli IN VARCHAR2)
   RETURN NUMBER;

   FUNCTION f_crea_solasegurado (pssolicit IN NUMBER, pnorden IN NUMBER,
                                 ptapelli IN VARCHAR2 DEFAULT '*', ptnombre IN VARCHAR2 DEFAULT '*',
                                 pfnacimi IN DATE DEFAULT NULL, pcsexper IN NUMBER DEFAULT NULL)
   RETURN NUMBER;

   FUNCTION f_actualiza_capital(pssolicit IN NUMBER, pnriesgo IN NUMBER, pcgarant IN NUMBER, picapital IN NUMBER)
   RETURN NUMBER ;

   FUNCTION f_actualiza_duracion_periodo(pssolicit IN NUMBER, pndurper IN NUMBER)
   RETURN NUMBER;

   -- MSR 4/7/2007. Afegir paràmetre pfvencim amb defecte a NULL per no afectar cap programa ja funcionant.
   FUNCTION f_actualiza_duracion(pssolicit IN NUMBER, pndurper IN NUMBER, pfvencim IN DATE DEFAULT NULL)
   RETURN NUMBER;

   FUNCTION f_ins_inttec (pssolicit IN NUMBER, pfefemov IN DATE, ppinttec IN NUMBER)
   RETURN NUMBER;

   FUNCTION f_actualiza_inttec(pssolicit IN NUMBER, ppinttec IN NUMBER)
   RETURN NUMBER;

   FUNCTION f_ins_simulaestadist (pcagente IN NUMBER, psproduc IN NUMBER, ptipo IN NUMBER)
   RETURN NUMBER;

END Pac_Simul_Comu;
 
 

/

  GRANT EXECUTE ON "AXIS"."PAC_SIMUL_COMU" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_SIMUL_COMU" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_SIMUL_COMU" TO "PROGRAMADORESCSI";
