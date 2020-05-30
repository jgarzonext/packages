--------------------------------------------------------
--  DDL for Package PK_PLANESPENS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PK_PLANESPENS" AS
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
   idseq2         VARCHAR2(25);
   faltaplan      DATE;
   faltagest      DATE;
   siglascom      VARCHAR2(2);
   domicilio      VARCHAR2(25);
   numero         NUMBER;
   emplaza        VARCHAR2(15);
   codpostal      VARCHAR2(30);   --3606 jdomingo 29/11/2007  canvi format codi postal - no podem usar type
   municipio      VARCHAR2(20);
   provincia      NUMBER;
   poblac         NUMBER;
   tipopers       VARCHAR2(1);
   nhijos         NUMBER;
   --****************************** Declaración de Alberto *************************
   fjub           DATE;
   fpasben        DATE;
   codconting     VARCHAR2(3);
   tippresta      NUMBER;
   cdivisa        NUMBER;
   mmonpro        NUMBER;
   ivalorp        NUMBER;   /*  NUMBER(25, 9);   */
   nparpla        NUMBER;   /*  NUMBER(25, 6);       */
   ipresta        NUMBER;
   fpago          DATE;
   iretenc        NUMBER;
   codcon         VARCHAR2(3);
   ccont1         VARCHAR2(1);
   ccont2         VARCHAR2(1);
   ccont3         VARCHAR2(1);
   tipcap         NUMBER(1);
   contin         NUMBER(1);
   via            NUMBER(5);
   fvalmov        DATE;
   imovimi        NUMBER;
   cmovimi        NUMBER;
   ctipapor       VARCHAR2(1);
   codsperson     NUMBER;
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
   resguardo      NUMBER;
   sitpart        VARCHAR2(1);
   conind         VARCHAR2(1);
   nrevanu        NUMBER;
   ctiprev        VARCHAR2(1);
   cestado        VARCHAR2(1);
   total_b        NUMBER := 0;
   PLAN           NUMBER;
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
   agrupacion1    NUMBER(6);
   agrupacion2    NUMBER(6);
   fecha_desde    DATE;
   fecha_hasta    DATE;
   tratreg        VARCHAR2(1);
   ----2/1/03. Canvis provisionals per als plans de promoció conjunta
   clau_promotor  VARCHAR2(4);
   apor_promotor  NUMBER := 0;
   ccodapor       VARCHAR2(1) := ' ';

--******************************************************************************
   CURSOR seg_cv IS
      SELECT seguros.sseguro, segmento, cambio, ID, id2, id3, estado, benef
        FROM ctaseguro, pila_planes, seguros, productos, proplapen
       WHERE fecha_envio IS NULL
         AND pila_planes.sseguro = seguros.sseguro
         AND seguros.cramo = productos.cramo
         AND seguros.cmodali = productos.cmodali
         AND seguros.ctipseg = productos.ctipseg
         AND seguros.ccolect = productos.ccolect
         AND proplapen.sproduc = productos.sproduc
         AND ctaseguro.sseguro = seguros.sseguro
         AND pila_planes.ID = ctaseguro.nnumlin
         AND pila_planes.id2 = ctaseguro.cmovimi
         AND proplapen.ccodpla IN(agrupacion1, agrupacion2)
         AND TO_CHAR(ctaseguro.fvalmov, 'YYYYMMDD') BETWEEN TO_CHAR(fecha_desde, 'YYYYMMDD')
                                                        AND TO_CHAR(fecha_hasta, 'YYYYMMDD')
         AND benef IS NULL
      UNION
      SELECT seguros.sseguro, segmento, cambio, ID, id2, id3, estado, benef
        FROM pila_planes, seguros, productos, proplapen
       WHERE fecha_envio IS NULL
         AND pila_planes.sseguro = seguros.sseguro
         AND seguros.cramo = productos.cramo
         AND seguros.cmodali = productos.cmodali
         AND seguros.ctipseg = productos.ctipseg
         AND seguros.ccolect = productos.ccolect
         AND proplapen.sproduc = productos.sproduc
         AND proplapen.ccodpla IN(agrupacion1, agrupacion2)
         AND TO_CHAR(pila_planes.fecha, 'YYYYMMDD') BETWEEN TO_CHAR(fecha_desde, 'YYYYMMDD')
                                                        AND TO_CHAR(fecha_hasta, 'YYYYMMDD')
         AND benef IS NOT NULL;

   TYPE regpilatyp IS RECORD(
      sseguro        NUMBER,
      segmento       VARCHAR2(1),
      cambio         VARCHAR2(1),
      ID             NUMBER,
      id2            NUMBER,
      id3            NUMBER,
      estado         VARCHAR2(1),
      benef          NUMBER
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
      sperson        NUMBER(10, 0),
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
   nom            VARCHAR2(20);
   ape            VARCHAR2(40);

   TYPE regpersulktyp IS RECORD(
      sperson        NUMBER(10, 0),
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

   FUNCTION datpartic
      RETURN BOOLEAN;

   FUNCTION datepartic
      RETURN BOOLEAN;

   FUNCTION bloqueos
      RETURN BOOLEAN;

   FUNCTION datbenef
      RETURN BOOLEAN;

   FUNCTION datprest
      RETURN BOOLEAN;

   FUNCTION dataport
      RETURN BOOLEAN;

   FUNCTION datanula
      RETURN BOOLEAN;

   PROCEDURE marcar_pila;
END pk_planespens;

/

  GRANT EXECUTE ON "AXIS"."PK_PLANESPENS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PK_PLANESPENS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PK_PLANESPENS" TO "PROGRAMADORESCSI";
