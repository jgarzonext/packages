--------------------------------------------------------
--  DDL for Package PK_PLANESMES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PK_PLANESMES" AS
   r              NUMBER := 0;
   num_certificado VARCHAR2(13) := NULL;
   moneda         VARCHAR2(3) := '???';
   subproducto    NUMBER(2, 0) := 0;
   cod_oficina    NUMBER(4, 0) := 0;
   aport_periodica NUMBER := 0;
   aport_inicial  NUMBER := 0;
   faport_periodica DATE := TO_DATE('0001-01-01', 'yyyy-mm-dd');
   tipo_crecimiento VARCHAR2(1) := ' ';
   fcrecimiento   DATE := TO_DATE('0001-01-01', 'yyyy-mm-dd');
   fultaport      DATE := TO_DATE('0001-01-01', 'yyyy-mm-dd');
   pcrec          NUMBER := 0;
   forma_crecimiento VARCHAR2(1) := ' ';
   percre         VARCHAR2(1) := ' ';
   cta_prestamo   VARCHAR2(20) := NULL;
   garantia       NUMBER := 0;
   t_producto     VARCHAR2(10);
   clavefondo     NUMBER;
   claveplan      NUMBER;
   idseq1         NUMBER;
   idseq2         VARCHAR2(12);
   faltaplan      DATE;
   faltagest      DATE;
   siglascom      VARCHAR2(2);
   domicilio      VARCHAR2(25);
   numero         NUMBER;
   emplaza        VARCHAR2(15);
   codpostal      VARCHAR2(30);   --3606 jdomingo 29/11/2007  canvi format codi postal
   municipio      VARCHAR2(20);
   provincia      NUMBER;
   poblac         NUMBER;
   tipopers       VARCHAR2(1);
   nhijos         NUMBER;
   --****************************** Declaración de Alberto *************************
   cdivisa        NUMBER;
   PLAN           NUMBER;
   mmonpro        NUMBER;
   ivalorp        NUMBER;   /*  NUMBER(25, 9);   */
   nparpla        NUMBER;   /*  NUMBER(25, 6);    */
   ipresta        NUMBER;
   fpago          DATE;
   iretenc        NUMBER;
   codcon         VARCHAR2(3);
   ccont1         VARCHAR2(1);
   ccont2         VARCHAR2(1);
   ccont3         VARCHAR2(1);
   tipcap         NUMBER(1);
   contin         NUMBER(1);
   fvalmov        DATE;
   fmes           DATE;
   fcuadre        DATE;
   imovimi        NUMBER;
   cmovimi        NUMBER;
   ctipapor       VARCHAR2(1);
   codsperson     NUMBER(10);
   faccion        DATE;
   nporcen        NUMBER;
   numbloq        NUMBER;
   nparret        NUMBER;
   finibloq       DATE;
   ffinbloq       DATE;
   codbloq        VARCHAR2(1);
   ibloq          NUMBER;
   cbancar        seguros.cbancar%TYPE;
   finicio        DATE;
   cperiod        NUMBER;
   fprorev        DATE;
   prevalo        NUMBER;
   nrevanu        NUMBER;
   ctiprev        VARCHAR2(1);
   cestado        VARCHAR2(1);
   total_b        NUMBER := 0;
   total_d        NUMBER := 0;
   total_m        NUMBER := 0;
   total_n        NUMBER := 0;
   total_r        NUMBER := 0;
   total_s        NUMBER := 0;
   bruto_s        NUMBER := 0;   /*  NUMBER(25, 2) := 0;        */
   pres_r         NUMBER := 0;   /*  NUMBER(25, 2) := 0;        */
   ret_r          NUMBER := 0;   /*  NUMBER(25, 2) := 0;        */
   ireducsn       NUMBER;
   nanos          NUMBER(2);
   agrupacion1    NUMBER;
   agrupacion2    NUMBER;
   agrupafecha    DATE;

--******************************************************************************
   CURSOR seg_cv IS
      SELECT sseguro
        FROM seguros, productos, proplapen, planpensiones
       WHERE seguros.cagrpro = 11
         AND seguros.cramo = productos.cramo
         AND seguros.cmodali = productos.cmodali
         AND seguros.ctipseg = productos.ctipseg
         AND seguros.ccolect = productos.ccolect
         AND productos.sproduc = proplapen.sproduc
         AND proplapen.ccodpla = planpensiones.ccodpla
         AND TO_CHAR(seguros.fefecto, 'yyyymmdd') <= TO_CHAR(agrupafecha, 'yyyymmdd') - 1
         AND seguros.csituac = 0
         AND(planpensiones.ccodpla = agrupacion1
             OR planpensiones.ccodpla = agrupacion2);

   TYPE regpilatyp IS RECORD(
      sseguro        NUMBER
   );

   regpila        regpilatyp;

   TYPE regsegtyp IS RECORD(
      sseguro        NUMBER,
      cramo          NUMBER(8),
      cmodali        NUMBER(2, 0),
      ctipseg        NUMBER(2, 0),
      ccolect        NUMBER(2, 0),
      npoliza        VARCHAR2(13),
      fefecto        DATE,
      fanulac        DATE,
      estado         VARCHAR2(1),
      fvencim        DATE,
      cforpag        VARCHAR2(1),
      cbancar        seguros.cbancar%TYPE
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
      nnumnif        VARCHAR2(10),
      cestciv        VARCHAR2(1),
      tidenti        VARCHAR2(1),
      fnacimi        DATE,
      fjubila        DATE
   );

   persona        regperstyp;
   nomape         VARCHAR2(60);

   TYPE regpersulktyp IS RECORD(
      sperson        NUMBER(10),
      cperhos        NUMBER(7, 0),
      cnifhos        VARCHAR2(13)
   );

   personaulk     regpersulktyp;

   TYPE segcurtyp IS REF CURSOR
      RETURN regsegtyp;

   PROCEDURE lee;

   PROCEDURE tratamiento;

   FUNCTION fin
      RETURN BOOLEAN;
END pk_planesmes;

/

  GRANT EXECUTE ON "AXIS"."PK_PLANESMES" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PK_PLANESMES" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PK_PLANESMES" TO "PROGRAMADORESCSI";
