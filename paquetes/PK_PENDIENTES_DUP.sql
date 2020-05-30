--------------------------------------------------------
--  DDL for Package PK_PENDIENTES_DUP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PK_PENDIENTES_DUP" AS
   num_certificado VARCHAR2(13) := '0';
   moneda         VARCHAR2(3) := 'EUR';
   subproducto    NUMBER(2, 0) := 00;
   cod_oficina    NUMBER(4, 0) := 0;
   secuencia      NUMBER := 1;
   sseguro_ant    NUMBER := 0;
   fecmov         DATE := TO_DATE('01/01/0001', 'dd/mm/yyyy');
   impmov         NUMBER(15) := 0;
   codmov         NUMBER(3) := 0;
   coment         VARCHAR2(120) := ' ';
   fultmod        DATE := SYSDATE;
   valorfijo      VARCHAR2(58);
   r              NUMBER(2);
   ramo           NUMBER(8);
   modalidad      NUMBER(2);
   tipseg         NUMBER(2);
   colect         NUMBER(2);
   brut           NUMBER := 0;
   penal          NUMBER := 0;
   reten          NUMBER := 0;
   liquid         NUMBER := 0;
   dataoper       DATE;
   compania       VARCHAR2(4) := 'C569';
   ------
   sortir         BOOLEAN := FALSE;
   enviar         BOOLEAN := TRUE;
   noenviar       EXCEPTION;

   ------
   TYPE valors IS RECORD(
      impmov         NUMBER,
      codmov         NUMBER,
      coment         VARCHAR2(120)
   );

   TYPE tvalors IS TABLE OF valors
      INDEX BY BINARY_INTEGER;

   vtvalors       tvalors;
   nreg           NUMBER;

   --En el cursor: orden és un número de comentari que s'escriurà en el fitxer
   --De moment només s'utilitza en el cas d'interessos PEG, PIG i PLA18.
   CURSOR seg_cv IS
      SELECT   pilapk, sseguro, ffecmov, iimpmov, ccodmov, coment,
               TO_NUMBER(SUBSTR(NVL(coment, '0'), 1, 2)) aclcod, 0 indint
          FROM pila_pendientes_dup
         WHERE TRUNC(ffecmov) <= TRUNC(SYSDATE)
           AND fecha_envio IS NULL
           AND sseguro > 0
      UNION ALL   ----Primer registre interes PEG, PIG i PLA18
      SELECT   pilapk, s.sseguro, ffecmov, iimpmov, ccodmov, coment, 0 acclod,
               TO_NUMBER(SUBSTR(NVL(coment, '0'), 1, 2)) indint
          FROM pila_pendientes_dup p, seguros s
         WHERE p.sseguro = 0
           AND TRUNC(p.ffecmov) <= TRUNC(SYSDATE)
           AND cramo = TO_NUMBER(SUBSTR(NVL(coment, ' '), 6, 2))
           AND cmodali = TO_NUMBER(SUBSTR(NVL(coment, ' '), 9, 2))
           AND ctipseg = TO_NUMBER(SUBSTR(NVL(coment, ' '), 12, 2))
           AND ccolect = TO_NUMBER(SUBSTR(NVL(coment, ' '), 15, 2))
           AND f_vigente(s.sseguro, NULL, ffecmov) = 0
           AND TO_NUMBER(SUBSTR(NVL(coment, '0'), 1, 2)) IN(2, 4)
           AND p.fecha_envio IS NULL
      UNION ALL   ----Segon registre interes PEG, PIG i PLA18
      SELECT   pilapk, s.sseguro, ffecmov, iimpmov, ccodmov, coment, 0 acclod,
               TO_NUMBER(SUBSTR(NVL(coment, '0'), 3, 2)) indint
          FROM pila_pendientes_dup p, seguros s
         WHERE p.sseguro = 0
           AND TRUNC(p.ffecmov) <= TRUNC(SYSDATE)
           AND cramo = TO_NUMBER(SUBSTR(NVL(coment, ' '), 6, 2))
           AND cmodali = TO_NUMBER(SUBSTR(NVL(coment, ' '), 9, 2))
           AND ctipseg = TO_NUMBER(SUBSTR(NVL(coment, ' '), 12, 2))
           AND ccolect = TO_NUMBER(SUBSTR(NVL(coment, ' '), 15, 2))
           AND f_vigente(s.sseguro, NULL, ffecmov) = 0
           AND TO_NUMBER(SUBSTR(NVL(coment, '0'), 1, 2)) IN(2, 4)
           AND p.fecha_envio IS NULL
      ORDER BY 2, 3 ASC, 1 DESC;

   TYPE regpilatyp IS RECORD(
      pilapk         NUMBER(12),
      sseguro        NUMBER,
      ffecmov        DATE,
      iimpmov        NUMBER,
      ccodmov        NUMBER,
      coment         VARCHAR2(56),
      aclcod         NUMBER,
      indint         NUMBER
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

   PROCEDURE lee;

   PROCEDURE tratamiento;

   PROCEDURE marcar_pila;

   FUNCTION numsequencia(vseguro IN seguros.sseguro%TYPE)
      RETURN NUMBER;

   FUNCTION fin
      RETURN BOOLEAN;

   PROCEDURE actualitza(i NUMBER);

   FUNCTION distingirprestacions(
      ssegur IN NUMBER,
      diacontab IN DATE,
      numli NUMBER,
      codmov NUMBER)
      RETURN NUMBER;

   PROCEDURE calcular_imports(ssegur IN NUMBER, diacontab IN DATE, numli NUMBER, codmov NUMBER);
END pk_pendientes_dup;

/

  GRANT EXECUTE ON "AXIS"."PK_PENDIENTES_DUP" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PK_PENDIENTES_DUP" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PK_PENDIENTES_DUP" TO "PROGRAMADORESCSI";
