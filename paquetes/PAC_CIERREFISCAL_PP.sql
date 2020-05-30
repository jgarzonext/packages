--------------------------------------------------------
--  DDL for Package PAC_CIERREFISCAL_PP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_CIERREFISCAL_PP" AUTHID CURRENT_USER IS
/******************************************************************************
   NOMBRE:     Pac_Cierrefiscal_Pp
   PROPÓSITO:  Package que contiene la función para realizar el cierre fiscal de P.Pensiones

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        20/12/2005   MCA                1.Creación Package
   2.0        27/09/2010   RSC                 2. Bug 15702 - Models Fiscals: 347
******************************************************************************/
   FUNCTION cierre_pp(
      pany IN VARCHAR2,
      pempres IN NUMBER,
      psfiscab IN NUMBER,
      pfperfin IN DATE DEFAULT NULL)
      RETURN NUMBER;

   FUNCTION f_calculo_planfiscal(pany IN VARCHAR2)
      RETURN NUMBER;
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."PAC_CIERREFISCAL_PP" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_CIERREFISCAL_PP" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_CIERREFISCAL_PP" TO "PROGRAMADORESCSI";
