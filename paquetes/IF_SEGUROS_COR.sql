--------------------------------------------------------
--  DDL for Package IF_SEGUROS_COR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."IF_SEGUROS_COR" AS
   r              NUMBER := 0;
   num_certificado VARCHAR2(13) := NULL;
   num_certif     NUMBER := 0;
   moneda         VARCHAR2(3) := '???';
   subproducto    NUMBER(2, 0) := 0;
   cod_oficina    NUMBER(4, 0) := 0;
   cia            VARCHAR2(4);
   total_recibo_pagado NUMBER := 0;
   capital_1      NUMBER := 0;
   capital_2      NUMBER := 0;
   capital_3      NUMBER := 0;
   capital_4      NUMBER := 0;
   capital_5      NUMBER := 0;
   capital_obra   NUMBER := 0;
   capital_constr NUMBER := 0;
   capital_maq1   NUMBER := 0;
   capital_rcprom NUMBER := 0;
   capital_rccons NUMBER := 0;
   capital_maq2   NUMBER := 0;
   capital_maq3   NUMBER := 0;
   capital_maq4   NUMBER := 0;
   capital_maq5   NUMBER := 0;
   capital_cte    NUMBER := 0;
   capital_ctdo   NUMBER := 0;
   capital_cfc    NUMBER := 0;
   capital_cdc    NUMBER := 0;
   capital_rc     NUMBER := 0;
   capital_invalidez NUMBER := 0;
   capital_muerte NUMBER := 0;
   capital_cteb   NUMBER := 0;
   capital_ctega  NUMBER := 0;
   capital_ctegb  NUMBER := 0;
   capital_ctegc1 NUMBER := 0;
   capital_ctet   NUMBER := 0;
   capital_ctdot  NUMBER := 0;
   capital_averiamaq NUMBER := 0;
   capital_detalim NUMBER := 0;
   capital_estetico NUMBER := 0;
   capital_protjur NUMBER := 0;
   capital_asistencia NUMBER := 0;
   capital_subsidi NUMBER := 0;
   cta_prestamo   VARCHAR2(20) := NULL;
   ent_benef      VARCHAR2(4) := NULL;
   t_producto     VARCHAR2(10);
   sortir         BOOLEAN;
   numpol         VARCHAR2(13) := NULL;
   t_cperhos1     VARCHAR2(7) := NULL;
   t_cperhos2     VARCHAR2(7) := NULL;
   p_sclagen      NUMBER(4) := 0;
   p_tidenti      NUMBER := 0;
   p_nnumnif      VARCHAR2(10) := NULL;

   CURSOR seg_cv IS
      SELECT sseguro, cramo, cmodali, ctipseg, ccolect, npoliza, fefecto, fanulac,
             DECODE(fanulac, NULL, 'A', 'V'), fvencim,
             DECODE(cforpag, 1, 'A', 2, 'S', 3, 'C', 4, 'T', 6, 'B', 12, 'M', 0, NULL),
             cbancar, cagente, fcaranu
        FROM seguros
       WHERE sseguro IN(SELECT sseguro
                          FROM pila_ifases
                         WHERE fecha_envio IS NULL);

   TYPE regsegtyp IS RECORD(
      sseguro        NUMBER,
      cramo          NUMBER(8),
      cmodali        NUMBER(2, 0),
      ctipseg        NUMBER(2, 0),
      ccolect        NUMBER(2, 0),
      npoliza        NUMBER,   -- Bug 28462 - 08/10/2013 - HRE - Cambio de dimension SSEGURO
      fefecto        DATE,
      fanulac        DATE,
      estado         VARCHAR2(1),
      fvencim        DATE,
      cforpag        VARCHAR2(1),
      cbancar        seguros.cbancar%TYPE,
      cagente        NUMBER,   -- Bug 18225 - APD - 11/04/2011 - la precisión debe ser NUMBER
      fcaranu        DATE
   );

   regseg         regsegtyp;

   TYPE movsegtyp IS RECORD(
      fmodifi        DATE,
      finisus        DATE,
      prima_inicial  NUMBER
   );

   regmovseg      movsegtyp;

   TYPE regperstyp IS RECORD(
      sperson        NUMBER(10),
      tapelli        VARCHAR2(40),
      tnombre        VARCHAR2(20),
      csexper        VARCHAR2(1),
      fnacimi        DATE,
      fjubila        DATE
   );

   persona        regperstyp;
   persona2       regperstyp;

   TYPE regpersulktyp IS RECORD(
      sperson        NUMBER(10),
      cperhos        NUMBER(7, 0),
      cnifhos        VARCHAR2(13)
   );

   personaulk     regpersulktyp;
   personaulk2    regpersulktyp;

   TYPE segcurtyp IS REF CURSOR
      RETURN regsegtyp;

   PROCEDURE lee;

   FUNCTION fin
      RETURN BOOLEAN;

   PROCEDURE marcar_pila;
END if_seguros_cor;

/

  GRANT EXECUTE ON "AXIS"."IF_SEGUROS_COR" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."IF_SEGUROS_COR" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."IF_SEGUROS_COR" TO "PROGRAMADORESCSI";
