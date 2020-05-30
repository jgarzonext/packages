--------------------------------------------------------
--  DDL for Package IF_SEGUROS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."IF_SEGUROS" AS
   r              NUMBER := 0;
   ----
   num_certificado VARCHAR2(40) := NULL;   -- Bug 28462 - 07/10/2013 - HRE - Cambio de dimension NCERTIF
   moneda         VARCHAR2(3) := '???';
   subproducto    NUMBER(2, 0) := 0;
   t_producto     VARCHAR2(10);   ---clase de tipos_producto
   vtipoproducto  VARCHAR2(10);   ---tipo_producto de tipo_producto
   ----
   cod_oficina    NUMBER(4, 0) := 0;
   ----
   aport_periodica NUMBER := 0;
   aport_inicial  NUMBER := 0;
   faport_periodica DATE := TO_DATE('0001-01-01', 'yyyy-mm-dd');
   tipo_crecimiento VARCHAR2(1) := ' ';
   fcrecimiento   DATE := TO_DATE('0001-01-01', 'yyyy-mm-dd');
   fultaport      DATE := TO_DATE('0001-01-01', 'yyyy-mm-dd');
   pcrec          NUMBER := 0;
   forma_crecimiento VARCHAR2(1) := ' ';
   percre         VARCHAR2(1) := ' ';
   ----
   total_recibo_pagado NUMBER := 0;
   ----
   capital_1      NUMBER := 0;
   capital_2      NUMBER := 0;
   capital_3      NUMBER := 0;
   capital_4      NUMBER := 0;
   capital_5      NUMBER := 0;
   capital_mort   NUMBER := 0;
   capital_invalidesa NUMBER := 0;
   capital_vida   NUMBER := 0;
   ----
   pm             NUMBER := 0;
   pm_dercons     NUMBER := 0;
   impmens1       NUMBER := 0;
   ----
   cta_prestamo   VARCHAR2(20) := NULL;
   ----
   garantia       NUMBER := 0;
   dataoper       DATE;
   norden1        NUMBER := NULL;
   norden2        NUMBER := NULL;
   diaenv         DATE;

   CURSOR seg_cv(diaenv DATE) IS
      SELECT sseguro, cramo, cmodali, ctipseg, ccolect, npoliza, fefecto, fanulac,
             DECODE(fanulac, NULL, 'A', 'V'),
             NVL(fvencim, TO_DATE('0001-01-01', 'yyyy-mm-dd')),
             DECODE(cforpag, 1, 'A', 2, 'S', 3, 'C', 4, 'T', 6, 'B', 12, 'M', 0, 'U'),
             fcarant, fcarpro, fcaranu, cforpag ncforpag, cbancar, csituac
        FROM seguros
       WHERE sseguro IN(SELECT sseguro
                          FROM pila_ifases
                         WHERE fecha_envio IS NULL
                           AND ifase = pk_autom.mensaje
                           AND TRUNC(fecha) <= diaenv);

   TYPE regsegtyp IS RECORD(
      sseguro        NUMBER,   -- Bug 28462 - 07/10/2013 - HRE - Cambio de dimension SSEGURO
      cramo          NUMBER(2, 0),
      cmodali        NUMBER(2, 0),
      ctipseg        NUMBER(2, 0),
      ccolect        NUMBER(2, 0),
      npoliza        VARCHAR2(40),   -- Bug 28462 - 07/10/2013 - HRE - Cambio de dimension NPOLIZA
      fefecto        DATE,
      fanulac        DATE,
      estado         VARCHAR2(1),
      fvencim        DATE,
      cforpag        VARCHAR2(1),
      fcarant        DATE,
      fcarpro        DATE,
      fcaranu        DATE,
      ncforpag       NUMBER(3),
      cbancar        seguros.cbancar%TYPE,
      csituac        NUMBER
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
      fjubila        DATE,
      ejubila        NUMBER
   );

   persona        regperstyp;
   persona2       regperstyp;

   TYPE regpersulktyp IS RECORD(
      sperson        NUMBER(10),
      cperhos        VARCHAR2(7),
      cnifhos        VARCHAR2(13)
   );

   personaulk     regpersulktyp;
   personaulk2    regpersulktyp;

   TYPE segcurtyp IS REF CURSOR
      RETURN regsegtyp;

   compania       VARCHAR2(4) := 'C569';

   PROCEDURE lee;

   FUNCTION fin
      RETURN BOOLEAN;

   PROCEDURE marcar_pila;

   PROCEDURE inicialitzar(diain IN DATE);
END if_seguros;

/

  GRANT EXECUTE ON "AXIS"."IF_SEGUROS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."IF_SEGUROS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."IF_SEGUROS" TO "PROGRAMADORESCSI";
