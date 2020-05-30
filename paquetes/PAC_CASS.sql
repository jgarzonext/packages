--------------------------------------------------------
--  DDL for Package PAC_CASS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_CASS" AUTHID CURRENT_USER IS
/******************************************************************************
   NOM:    PAC_CASS
   PROPÓSIT: Especificació del paquet de les funcions i procediments
                 per a la carga de fitxers de la CASS.

   REVISIONS:
   Ver        Data        Autor             Descripció
   ---------  ----------  ---------------  ------------------------------------
   1.0        14/08/2008  XVILA            1. Creación del package.
   2.0        04/12/2008  SBOU             2. Modificacions + P_CARGA
******************************************************************************/

   /*************************************************************************
     Determina quins arxius de càrrega són els que cal processar, els llegeix
     i els marca com a llegits.
   *************************************************************************/
   PROCEDURE p_carga;

   /*************************************************************************
     Rutina de lectura del fitxer extern que permet graba les dades en les taules
     cass i cassdet_01.
     param in P_PATH : Path fitxer
     param in P_NOMBRE : Nom fitxer
     param in PSPROCES : Nº procés
   *************************************************************************/
   PROCEDURE p_lee(p_path IN VARCHAR2, p_nombre IN VARCHAR2, psproces IN NUMBER);

   /*************************************************************************
     Rutina per recuperar les dades d'un contracte.
     param in  pcassbene  : Número CASS del beneficiari.
     param in  pfacto     : Data de l’acte, format AAAAMMDD.
     param in  pnremesa   : Nº remesa
     param in  psproces   : Nº procés
     param out psseguro   : Número de seguro.
     param out pnriesgo   : Número risc.
     param out pcgarant   : Códi garantia
     param out psperson   : Id. persona
     param out pagr_salud :
   *************************************************************************/
   FUNCTION f_datos_contrato(
      pcassbene IN VARCHAR2,
      pfacto IN VARCHAR2,
      pnremesa IN VARCHAR2,
      psproces IN NUMBER,
      psseguro IN OUT NUMBER,
      pnriesgo IN OUT NUMBER,
      pcgarant IN OUT NUMBER,
      psperson IN OUT NUMBER,
      pagr_salud IN OUT VARCHAR2)
      RETURN NUMBER;

   /***********************************************************************
      Rutina de creació dels reemborsaments corresponents a partir de
      cass i cassdet_01.
      param in PREMESA  : Nº remesa
      param in PSPROCES : Nº procés
   ***********************************************************************/
   FUNCTION f_genera_reemb(premesa IN VARCHAR2, psproces IN NUMBER)
      RETURN NUMBER;
END;

/

  GRANT EXECUTE ON "AXIS"."PAC_CASS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_CASS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_CASS" TO "PROGRAMADORESCSI";
