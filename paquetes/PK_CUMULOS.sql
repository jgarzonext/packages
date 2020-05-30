--------------------------------------------------------
--  DDL for Package PK_CUMULOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PK_CUMULOS" AS
   num_certificado VARCHAR2(13);
   moneda         VARCHAR2(3);
   subproducto    NUMBER(2, 0);
   cod_oficina    NUMBER(4, 0);
   secuencia      NUMBER := 1;
   sseguro_ant    NUMBER := 0;
   ramo           NUMBER;
   modalidad      NUMBER;
   tipseg         NUMBER;
   colect         NUMBER;

   TYPE regpilafitx IS RECORD(
      subproducto    NUMBER(2),
      cmoneda        VARCHAR2(3),
      compania       VARCHAR2(4),
      vsperson1      NUMBER(10),
      vsperson2      NUMBER(10),
      cperhos1       NUMBER(7),
      cperhos2       NUMBER(7),
      riesgocont     NUMBER,
      riessol        NUMBER,
      cancont        NUMBER
   );

   acumulat       regpilafitx;
   actual         regpilafitx;
   sortida        regpilafitx;
   riesgo         NUMBER;
   riessol        NUMBER;
   riescon        NUMBER;
   cancont        NUMBER;
   ad             VARCHAR2(1);

   ----
   CURSOR seg_cv IS
      SELECT   tproducto, sperson1, 0, DECODE(cmoneda, 2, 'PTA', 3, 'EUR', '???'), sseguro,
               unidades, importes, motivo
          FROM pila_cumulos pc
         WHERE fecha_envio IS NULL
           AND sperson2 IS NULL
           AND(pk_autom.mensaje = 'FSE0700'
               AND NOT EXISTS(SELECT sperson
                                FROM asegurados
                               WHERE sseguro = pc.sseguro
                                 AND norden = 2))
      UNION ALL
      SELECT   tproducto, sperson1, sperson2, DECODE(cmoneda, 2, 'PTA', 3, 'EUR', '???'),
               sseguro, unidades, importes, motivo
          FROM pila_cumulos pc
         WHERE fecha_envio IS NULL
           AND sperson2 IS NOT NULL
           AND(pk_autom.mensaje = 'FSE0750'
               AND EXISTS(SELECT sperson
                            FROM asegurados
                           WHERE sseguro = pc.sseguro
                             AND norden = 2))
      ORDER BY 1, 2, 3;

   TYPE regpilatyp IS RECORD(
      tproducto      VARCHAR2(10),
      sperson1       NUMBER(10),
      sperson2       NUMBER(10),
      cmoneda        VARCHAR2(3),
      sseguro        NUMBER,
      unidades       NUMBER,
      importes       NUMBER,
      motivo         NUMBER
   );

   regpila        regpilatyp;

   TYPE regsegtyp IS RECORD(
      sseguro        NUMBER,
      cramo          NUMBER(8),
      cmodali        NUMBER(2, 0),
      ctipseg        NUMBER(2, 0),
      ccolect        NUMBER(2, 0),
      npoliza        VARCHAR2(13),
      cidioma        NUMBER,
      fefecto        DATE,
      fanulac        DATE,
      estado         VARCHAR2(1),
      fvencim        DATE,
      cforpag        VARCHAR2(1),
      cbancar        seguros.cbancar%TYPE
   );

   regseg         regsegtyp;

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
   dataoper       DATE;
   sortir         BOOLEAN := FALSE;
   acabar         BOOLEAN := FALSE;
   noenviar       EXCEPTION;

   PROCEDURE lee;

   PROCEDURE tratamiento;

   PROCEDURE marcar_pila;

   FUNCTION fin
      RETURN BOOLEAN;

   FUNCTION enviar
      RETURN BOOLEAN;
END pk_cumulos;

/

  GRANT EXECUTE ON "AXIS"."PK_CUMULOS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PK_CUMULOS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PK_CUMULOS" TO "PROGRAMADORESCSI";
