--------------------------------------------------------
--  DDL for Package PAC_MONEDAS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_MONEDAS" IS
/***********************************************************************
  PAC_MONEDAS
    Aquest paquet està preparat per gestionar les funcions relacionades amb la taula MONEDAS

   REVISIONS:
   Ver        Data              Autor             Descripció
   ---------  ----------        ---------------  ----------------------------------
   1.0        30/04/2008        MSR              Creación del package (BUG9902).
   2.0        26/10/2011        JMP              0018423: LCOL000 - Multimoneda
   3.0        28/11/2011        JMP              0018423: LCOL000 - Multimoneda
***********************************************************************/
   moneda_inst CONSTANT monedas.cmoneda%TYPE := f_parinstalacion_n('MONEDAINST');
   decimals_inst  monedas.ndecima%TYPE;   -- S'omple al'inicialitzar el package

/***********************************************************************
  FUNCIÓ: Decimals
  Torna el nombre de decimals d'una divisa
    Paràmetres
      p_cMoneda       Codi de la moneda de la qual volem els decimals a que s'han d'arrodonir el imports
                      NOTA: No s'hauria de passar la mondea NULL, en cas que es faci, tornarà 2 decimals.

    Exemple d'ús
      import_arrodonit := ROUND( import, PAC_MONEDAS.DECIMALS(moneda));
     o per la moneda per defecte
      import_arrodonit := ROUND( import, PAC_MONEDAS.DECIMALS);
    o encara més curt per la moneda per defecte
      import_arrodonit := ROUND( import );

      REVISIONS:
      Ver        Data        Autor             Descripció
      ---------  ----------  ---------------  ----------------------------------
      1.0        30/04/2008  MSR               Incorporació de l'antiga funció F_ROUND a dins un package.
***********************************************************************/
   FUNCTION decimals(p_cmoneda IN monedas.cmoneda%TYPE DEFAULT moneda_inst)
      RETURN monedas.ndecima%TYPE;

/***********************************************************************
   F_ROUND: Redondeamos el importe pasado segun la moneda. En caso de no
            pasar moneda se usará la de la instalación.
   REVISIONS:
   Ver        Data        Autor             Descripció
   ---------  ----------  ---------------  ----------------------------------
   1.0        30/04/2008  MSR               Incorporació de l'antiga funció F_ROUND a dins un package.
***********************************************************************/

   --   Exemple d'ús
   --     import_arrodonit := ROUND( import, PAC_MONEDAS.DECIMALS(moneda));
   --    o per la moneda per defecte
   --     import_arrodonit := ROUND( import, PAC_MONEDAS.DECIMALS);
   --   o encara més curt per la moneda per defecte
   --     import_arrodonit := ROUND( import );
   FUNCTION f_round(
      p_import IN NUMBER,
      p_moneda IN NUMBER
            DEFAULT NULL,   -- No es pot definir DEFAULT PAC_MONEDAS.Moneda_Inst per problemes de compatibilitat amb el Reports i Forms
            p_decimal IN NUMBER DEFAULT 0
                        )
      RETURN NUMBER;

-- BUG 18423 - 26/10/2011 - JMP - LCOL000 - Multimoneda
/*************************************************************************
   FUNCTION f_cmoneda_t
   Convierte el código de moneda numérico a su código alfanumérico.
   pcmoneda             : Código numérico de la moneda
   return               : El código alfanumérico de la moneda
*************************************************************************/
   FUNCTION f_cmoneda_t(pcmoneda NUMBER)
      RETURN VARCHAR2;

/*************************************************************************
   FUNCTION f_cmoneda_n
   Convierte el código de moneda alfanumérico a su código numérico.
   pcmoneda             : Código alfanumérico de la moneda
   return               : El código numérico de la moneda
*************************************************************************/
   FUNCTION f_cmoneda_n(pcmoneda VARCHAR2)
      RETURN NUMBER;

-- FIN BUG 18423 - 26/10/2011 - JMP - LCOL000 - Multimoneda

   -- INI BUG 18423 - 15/12/2011 - JLB - LCOL000 - Multimoneda
/*************************************************************************
   FUNCTION f_moneda_divisa
   Obtiene la moneda correspondiente a la divisa
   pcdivisa             : Código de moneda asociado a la divisa
   return               : El código de la moneda
*************************************************************************/
   FUNCTION f_moneda_divisa(pcdivisa IN NUMBER)
      RETURN NUMBER;

/*************************************************************************
   FUNCTION f_moneda_producto
   Obtiene la moneda correspondiente a al producto, a traves de la divisa
   psproduc             : Código de producto
   return               : El código de la moneda
*************************************************************************/
   FUNCTION f_moneda_producto(psproduc IN NUMBER)
      RETURN NUMBER;

-- FIN BUG 18423 - 15/12/2011 - JLB - LCOL000 - Multimoneda
   FUNCTION f_moneda_seguro(ptablas IN VARCHAR2, psseguro IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_moneda_producto_char(psproduc IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION f_moneda_seguro_char(ptablas IN VARCHAR2, psseguro IN NUMBER)
      RETURN VARCHAR2;
END pac_monedas;

/

  GRANT EXECUTE ON "AXIS"."PAC_MONEDAS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MONEDAS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MONEDAS" TO "PROGRAMADORESCSI";
