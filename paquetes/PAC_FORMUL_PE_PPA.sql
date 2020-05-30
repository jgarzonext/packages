--------------------------------------------------------
--  DDL for Package PAC_FORMUL_PE_PPA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_FORMUL_PE_PPA" authid current_user IS
  -- Valors calculats
  gProvMat    CTASEGURO.IMOVIMI%TYPE;
  gCapGar     CTASEGURO_LIBRETA.CCAPGAR%TYPE;
  gCapFall    CTASEGURO_LIBRETA.CCAPFAL%TYPE;

  --
  --  CALCULO
  --      Calcula simultàniament les variables gCapFall, gCapGar i gProvMat per una pòlissa i data donada
  --
  PROCEDURE Calculo( pSesion IN NUMBER, psSolit_Seguro IN NUMBER );

  --
  --  CAPFALL
  --    Torna Capital de defunció per una pòlissa a una data
  --
  FUNCTION CAPFALL ( pSesion IN NUMBER, psSeguro IN SEGUROS.SSEGURO%TYPE ) RETURN NUMBER;

  --
  --  CAPGAR
  --    Torna el Capital de Supervivència per una pòlissa a una data
  --
  FUNCTION CAPGAR ( pSesion IN NUMBER, psSeguro IN SEGUROS.SSEGURO%TYPE ) RETURN NUMBER;

  --
  --  PROVMAT
  --    Torna la Provisió Matemàtica per una pòlissa a una data
  --
  FUNCTION PROVMAT ( pSesion IN NUMBER, psSeguro IN SEGUROS.SSEGURO%TYPE ) RETURN NUMBER;
END; 
 
 

/

  GRANT EXECUTE ON "AXIS"."PAC_FORMUL_PE_PPA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_FORMUL_PE_PPA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_FORMUL_PE_PPA" TO "PROGRAMADORESCSI";
