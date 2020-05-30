--------------------------------------------------------
--  DDL for Package PAC_PARAMETROS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_PARAMETROS" IS
/****************************************************************************
   NOMBRE:       PAC_PARAMETROS
   PROP¿SITO:  Funciones para parametros

   REVISIONES:
   Ver        Fecha        Autor             Descripci¿n
   ---------  ----------  ---------------  ----------------------------------
   1.0                                     1. Creaci¿n del package
   5.0        22/10/2009   AMC             5. Bug 8999: Se a¿ade la funci¿n F_DESCDETPARAM
   6.0        29/10/2010   JMP             6. Bug 8999: Ajustes y revisiones
   8.0        10/10/2013   SPC             8. 0028024 : Optimizaci¿n proceso tarificaci¿n y cartera
***************************************************************************/
   CURSOR c_codparam IS
      SELECT cparam, ctipo, tdefecto
        FROM codparam;

   TYPE r_codparam IS TABLE OF c_codparam%ROWTYPE
      INDEX BY BINARY_INTEGER;

   v_codparam     r_codparam;

   CURSOR c_parproductos IS
      SELECT cvalpar, sproduc, cparpro, tvalpar
        FROM parproductos;

   TYPE r_parproductos IS TABLE OF c_parproductos%ROWTYPE
      INDEX BY BINARY_INTEGER;

   v_parproductos r_parproductos;

   CURSOR c_parinstalacion IS
      SELECT tvalpar, nvalpar, cparame
        FROM parinstalacion;

   TYPE r_parinstalacion IS TABLE OF c_parinstalacion%ROWTYPE
      INDEX BY BINARY_INTEGER;

   v_parinstalacion r_parinstalacion;

   CURSOR c_parempresas IS
      SELECT nvalpar, cempres, cparam
        FROM parempresas;

   TYPE r_parempresas IS TABLE OF c_parempresas%ROWTYPE
      INDEX BY BINARY_INTEGER;

   v_parempresas  r_parempresas;

   TYPE tind IS TABLE OF NUMBER
      INDEX BY VARCHAR2(512);

   vindt1         tind;
   vindt2         tind;
   vindt3         tind;
   vindt4         tind;

   FUNCTION f_parproducto_n(psproduc IN NUMBER, pcparam IN VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_parproducto_t(psproduc IN NUMBER, pcparam IN VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION f_parproducto_f(psproduc IN NUMBER, pcparam IN VARCHAR2)
      RETURN DATE;

   FUNCTION f_paractividad_n(psproduc IN NUMBER, pcactivi IN NUMBER, pcparam IN VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_paractividad_t(psproduc IN NUMBER, pcactivi IN NUMBER, pcparam IN VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION f_paractividad_f(psproduc IN NUMBER, pcactivi IN NUMBER, pcparam IN VARCHAR2)
      RETURN DATE;

   FUNCTION f_pargaranpro_n(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      pcparam IN VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_pargaranpro_t(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      pcparam IN VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION f_pargaranpro_f(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      pcparam IN VARCHAR2)
      RETURN DATE;

   FUNCTION f_parinstalacion_n(pcparam IN VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_parinstalacion_t(pcparam IN VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION f_parinstalacion_f(pcparam IN VARCHAR2)
      RETURN DATE;
   --INI BUG CONF-479  Fecha (20/01/2017) - HRE - Suplemento de aumento de valor
     FUNCTION f_parcontrato_n(pscontra IN NUMBER, pcparam IN VARCHAR2, psproduc IN NUMBER DEFAULT 0)
      RETURN NUMBER;
   --FIN BUG CONF-479  - Fecha (20/01/2017) - HRE
   FUNCTION f_parempresa_n(pcempres IN NUMBER, pcparam IN VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_parempresa_t(pcempres IN NUMBER, pcparam IN VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION f_parempresa_f(pcempres IN NUMBER, pcparam IN VARCHAR2)
      RETURN DATE;

   FUNCTION f_parmotmov_n(
      pcmotmov IN NUMBER,
      pcparam IN VARCHAR2,
      psproduc IN NUMBER DEFAULT 0)
      RETURN NUMBER;

   FUNCTION f_parmotmov_t(
      pcmotmov IN NUMBER,
      pcparam IN VARCHAR2,
      psproduc IN NUMBER DEFAULT 0)
      RETURN VARCHAR2;

   FUNCTION f_parmotmov_f(
      pcmotmov IN NUMBER,
      pcparam IN VARCHAR2,
      psproduc IN NUMBER DEFAULT 0)
      RETURN DATE;

   FUNCTION f_parconexion_n(pcparam IN VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_parconexion_t(pcparam IN VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION f_parconexion_f(pcparam IN VARCHAR2)
      RETURN DATE;

   FUNCTION f_desgrpparam(
      pcgrppar IN VARCHAR2,
      pcutili IN NUMBER,
      pcidioma IN NUMBER,
      ptgrppar IN OUT VARCHAR2,
      pnformat IN NUMBER DEFAULT 1)
      RETURN NUMBER;

   FUNCTION f_descparam(pcodi IN VARCHAR2, ptipo IN NUMBER, pcidioma IN NUMBER)
      RETURN VARCHAR2;

   /****************************************************************************
      F_DESCDETPARAM
      Obtener la descripci¿n del parametro
      param in pcparam   : codigo del parametro
      param in pcvalpar  : codigo del valor del parametro
      param in pcidioma  : idioma
      retorno texto del valor del parametro
     Bug 8999 - 22/10/2009 - AMC
   *****************************************************************************/
   FUNCTION f_descdetparam(pcparam IN VARCHAR2, pcvalpar IN NUMBER, pcidioma IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION f_parlistado_n(pcempres IN NUMBER, pcparam IN VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_parlistado_t(pcempres IN NUMBER, pcparam IN VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION f_parlistado_f(pcempres IN NUMBER, pcparam IN VARCHAR2)
      RETURN DATE;
END pac_parametros;

/

  GRANT EXECUTE ON "AXIS"."PAC_PARAMETROS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_PARAMETROS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_PARAMETROS" TO "PROGRAMADORESCSI";
