--------------------------------------------------------
--  DDL for Package Body PAC_RELACIONES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_RELACIONES" IS
   /******************************************************************************
      NOMBRE:       PAC_RELACIONES
      PROPÓSITO:    Funciones de la capa lógica para realizar acciones sobre la tabla RELACIONES

      REVISIONES:
      Ver        Fecha        Autor             Descripción
      ---------  ----------  ---------------  ------------------------------------
      1.0        12/07/2012   APD             1. Creación del package. 0022494: MDP_A001- Modulo de relacion de recibos
      2.0        17/06/2015   MMS             2. Rediseño de Relaciones (0036392: agregar un campo de factura a los recibos que agrupados y agrupador en colectivos)
   ******************************************************************************/

   /*************************************************************************
    Función que realiza la búsqueda de relaciones a partir de los criterios de consulta entrados
    param in pcempres     : codigo empresa
    param in pcagente     : codigo de agente
    param in psrelacion   : codigo de la relacion
    param in pfiniefe     : Fecha de inicio de efecto , del recibo dentro de la relación
    param in pffinefe     : Fecha de fin del recibo, dentro de la relación
    param out pquery      : select a ejcutar
         return             : 0 busqueda correcta
                           <> 0 busqueda incorrecta
   *************************************************************************/
   FUNCTION f_obtener_relaciones(
      pcempres IN NUMBER,
      pcagente IN NUMBER,
      psrelacion IN NUMBER,
      pfiniefe IN DATE,
      pffinefe IN DATE,
      pcidioma IN NUMBER,
      pquery OUT VARCHAR2)
      RETURN NUMBER IS
      vparam         VARCHAR2(2000)
         := 'parámetros - pcempres:' || pcempres || ' - pcagente:' || pcagente
            || ' - pcrelacion:' || psrelacion || ' - pfiniefe:'
            || TO_CHAR(pfiniefe, 'dd/mm/yyyy') || ' - pffinefe:'
            || TO_CHAR(pffinefe, 'dd/mm/yyyy');
      vlin           NUMBER := 1;
      vobj           VARCHAR2(200) := 'pac_relaciones.f_obtener_relaciones';
      vwhere         VARCHAR2(2000);
      vsperson       per_personas.sperson%TYPE;
   BEGIN
      IF pcagente IS NULL THEN
         RETURN 101076;   --Es obligatorio introducir el código del agente.
      END IF;

/*

      IF pcempres IS NOT NULL THEN
         vwhere := vwhere || ' and f.cempres = ' || pcempres;
      END IF;
*/
      IF pcagente IS NOT NULL THEN
         vwhere := vwhere || ' and r.cagente = ' || pcagente;
      END IF;

      IF psrelacion IS NOT NULL THEN
         vwhere := vwhere || ' and r.srelacion = ' || psrelacion;
      END IF;

      IF pfiniefe IS NOT NULL THEN
         vwhere := vwhere || ' and r.finiefe >= ' || CHR(39) || pfiniefe || CHR(39);
      END IF;

      IF pffinefe IS NOT NULL THEN
         vwhere := vwhere || ' and r.finiefe <= ' || CHR(39) || pffinefe || CHR(39);
      END IF;

      pquery :=
         'SELECT r.srelacion, r.finiefe, r.ctipo, ff_desvalorfijo(1085, ' || pcidioma
         || ', r.ctipo) ttipo,
          COUNT(r.nrecibo) recibos, sum(NVL(v.itotalr,0)) itotalr ,
          sum (NVL(v.itotalr,0) - NVL(v.icombru,0) - NVL(v.icombrui,0)) liquido
                 FROM relaciones r, vdetrecibos v
                 WHERE r.nrecibo = v.nrecibo
                   AND r.ffinefe IS NULL '
         || vwhere || ' GROUP BY r.srelacion, r.finiefe, r.ctipo' || ' ORDER BY srelacion';
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobj, vlin, vparam, SQLERRM || CHR(10) || pquery);
         RETURN 1000455;   -- Error no controlado.
   END f_obtener_relaciones;

    /*************************************************************************
    Función que realiza la búsqueda de relaciones a partir de los criterios de consulta entrados
        PCAGENTE IN  NUMBER
        PCRELACION IN NUMBER
        PCTIPO IN NUNBER ( tipo de busqueda  DEFAULT 0)
        TSELECT OUT VARCHAR2

         return             : 0 busqueda correcta
                           <> 0 busqueda incorrecta
   *************************************************************************/
   FUNCTION f_set_recibos_relacion(
      pcagente IN NUMBER,
      pcrelacion IN NUMBER,
      pnrecibo IN NUMBER,
      pctipo IN NUMBER,
      pcidioma IN NUMBER,
      pquery OUT VARCHAR2)
      RETURN NUMBER IS
      vparam         VARCHAR2(2000)
         := 'parámetros - pcrelacion:' || pcrelacion || ' - pcagente:' || pcagente
            || ' - pnrecibo:' || pnrecibo || ' - pctipo:' || pctipo;
      vlin           NUMBER := 1;
      vobj           VARCHAR2(200) := 'pac_relaciones.f_set_recibos_relacion';
      vwhere         VARCHAR2(2000);
      vsperson       per_personas.sperson%TYPE;
   BEGIN
      IF pcagente IS NULL THEN
         RETURN 101076;   --Es obligatorio introducir el código del agente.
      END IF;

      IF pctipo = 1 THEN
         IF pcrelacion IS NULL THEN
            RETURN 9904428;
         END IF;

         pquery :=
            ' SELECT 0 COBLIGA, rel.NRECIBO,r.FEFECTO,s.NPOLIZA,FF_TOMADOR_PER(s.sseguro, 1 ) TOMADOR, F_DESRIESGO_T(s.sseguro , r.nriesgo , f_sysdate,
     '
            || pcidioma
            || ') RIESGO, rel.srelacion CRELACION,(NVL(v.itotalr,0) - NVL(v.icombru,0) - NVL(v.icombrui,0)) liquido , NVL(v.itotalr,0) IMPORTE
 FROM RELACIONES rel, vdetrecibos v, recibos r, seguros s
WHERE rel.ffinefe IS NULL
and r.nrecibo = v.nrecibo
and r.nrecibo = rel.nrecibo
and r.cagente = rel.cagente
and r.sseguro = s.sseguro
   AND rel.Srelacion = '
            || pcrelacion || '
   AND rel.cagente = ' || pcagente;
      ELSIF pctipo = 0 THEN
         pquery :=
            ' SELECT 0 COBLIGA, r.NRECIBO,r.FEFECTO,s.NPOLIZA,FF_TOMADOR_PER(s.sseguro, 1 ) TOMADOR, F_DESRIESGO_T(s.sseguro , r.nriesgo , f_sysdate,
     '
            || pcidioma || ') RIESGO, (select srelacion
from relaciones
where cagente = ' || pcagente
            || '
and nrecibo = r.nrecibo
and ffinefe is null) CRELACION,(NVL(v.itotalr,0) - NVL(v.icombru,0) - NVL(v.icombrui,0)) liquido , NVL(v.itotalr,0) IMPORTE
 FROM  vdetrecibos v, recibos r, seguros s, movrecibo m
WHERE r.nrecibo = v.nrecibo
and r.sseguro = s.sseguro
   AND r.cagente = '
            || pcagente
            || ' and r.nrecibo = m.nrecibo
   AND m.cestrec = 0
   AND m.fmovfin IS NULL ';
      ELSIF pctipo = 2 THEN
         IF pnrecibo IS NULL THEN
            RETURN 9904027;
         END IF;

         pquery :=
            ' SELECT 0 COBLIGA, r.NRECIBO,r.FEFECTO,s.NPOLIZA,FF_TOMADOR_PER(s.sseguro, 1 ) TOMADOR, F_DESRIESGO_T(s.sseguro , r.nriesgo , f_sysdate,
     '
            || pcidioma || ') RIESGO, (select srelacion
from relaciones
where cagente = ' || pcagente
            || '
and nrecibo = r.nrecibo
and ffinefe is null) CRELACION,(NVL(v.itotalr,0) - NVL(v.icombru,0) - NVL(v.icombrui,0)) liquido , NVL(v.itotalr,0) IMPORTE
 FROM  vdetrecibos v, recibos r, seguros s
WHERE  r.nrecibo = v.nrecibo
and r.nrecibo = '
            || pnrecibo || '
and r.sseguro = s.sseguro
   AND r.cagente = ' || pcagente;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobj, vlin, vparam, SQLERRM || CHR(10) || pquery);
         RETURN 1000455;   -- Error no controlado.
   END f_set_recibos_relacion;

   /*
    F_GUARDAR_RECIBO EN_RELACION
     crear una nueva relación con todos los recibos que se han informado */
   FUNCTION f_guardar_recibo_en_relacion(
      pnrecibo IN NUMBER,
      pcagente IN NUMBER,
      pcrelacion IN NUMBER,
      pctipo IN NUMBER)
      RETURN NUMBER IS
      vparam         VARCHAR2(2000)
         := 'parámetros - pnrecibo:' || pnrecibo || ' - pcrelacion:' || pcrelacion
            || ' - pctipo:' || pctipo || ' - pcagente:' || pcagente;
      vlin           NUMBER := 1;
      vobj           VARCHAR2(200) := 'pac_relaciones.f_guardar_recibo_en_relacion';
      vcont          NUMBER;
   BEGIN
      BEGIN
         UPDATE relaciones
            SET ffinefe = f_sysdate
          WHERE ffinefe IS NULL
            AND nrecibo = pnrecibo
            AND cagente = pcagente;

         INSERT INTO relaciones
                     (srelacion, cagente, nrecibo, ctipo, finiefe)
              VALUES (pcrelacion, pcagente, pnrecibo, pctipo, f_sysdate);
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
            UPDATE relaciones
               SET ctipo = pctipo
             WHERE srelacion = pcrelacion
               AND cagente = pcagente
               AND nrecibo = pnrecibo;
      END;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobj, vlin, vparam, SQLERRM);
         RETURN 1000455;   -- Error no controlado.
   END f_guardar_recibo_en_relacion;

   /*************************************************************************
    Función que realiza la búsqueda de relaciones a partir de los criterios de consulta entrados
    param in pnrecibo     : numero de recibo
    param in pcidioma     : codigo del idioma
    param out pquery      : select a ejcutar
         return             : 0 busqueda correcta
                           <> 0 busqueda incorrecta
   *************************************************************************/
   FUNCTION f_get_reg_retro_cobro_masivo(
      pnrecibo IN NUMBER,
      pcidioma IN NUMBER,
      pquery OUT VARCHAR2)
      RETURN NUMBER IS
      vparam         VARCHAR2(2000) := 'parámetros - pnrecibo:' || pnrecibo;
      vobj           VARCHAR2(200) := 'pac_relaciones.f_get_reg_retro_cobro_masivo';
      vwhere         VARCHAR2(2000);
      vsperson       per_personas.sperson%TYPE;
   BEGIN
      IF pnrecibo IS NULL THEN
         RETURN 9904027;   --Es obligatorio introducir el código del recibo
      END IF;

      pquery := ' select r.nrecibo,r.nanuali,r.nfracci,'
                || ' F_DESPRODUCTO_T (s.cramo,s.cmodali,s.ctipseg,s.ccolect,1,' || pcidioma
                || ') PRODUCTO,s.npoliza,' || ' F_DESAGENTE_T(s.cagente) MEDIADOR,v.itotalr,'
                || ' r.femisio,r.fefecto,r.fvencim,'
                || ' decode(r.cbancar,null,f_axis_literales(9902262,' || pcidioma
                || '),f_axis_literales(9901930,' || pcidioma || ')) TCOBRO,'
                || ' decode(r.ctiprec,9,f_axis_literales(109474,' || pcidioma || '),13,'
                || ' f_axis_literales(109474,' || pcidioma || '),f_axis_literales(100895,'
                || pcidioma || ')) TTIPREC,' || ' m.fmovini FCOBRO'
                || ' from recibos r,seguros s,vdetrecibos v,movrecibo m'
                || ' where r.nrecibo = ' || pnrecibo || ' and r.sseguro = s.sseguro'
                || ' and r.nrecibo = v.nrecibo' || ' and r.nrecibo = m.nrecibo'
                || ' and m.cestrec = 1' || ' and m.fmovfin is null';
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobj, 1, vparam, SQLERRM || CHR(10) || pquery);
         RETURN 1000455;   -- Error no controlado.
   END f_get_reg_retro_cobro_masivo;

   -- INICIO Bug 0036392 MMS 20150617
      /*************************************************************************
    Función que crea una cabecera de una relación
      param in pmes_ano     : number
      param in pnfactura    : varchar2
      param in pcagente     : number
      param out psrelacion  : number
           return             : 0 insert correcto
                             <> 0 insert incorrecto
     *************************************************************************/
   FUNCTION f_set_relacion(
      pmes_ano IN NUMBER,
      pnfactura IN VARCHAR2,
      pcagente IN NUMBER,
      psrelacion OUT NUMBER)
      RETURN NUMBER IS
      vrelacion      NUMBER;
      vobj           VARCHAR2(70) := 'PAC_RELACIONES.F_SET_RELACION';
      vlin           NUMBER;
      vparam         VARCHAR2(200)
         := 'pmes_ano: ' || pmes_ano || ', pnfactura: ' || pnfactura || ', pcagente:'
            || pcagente;
      vmes_ano       DATE;
   BEGIN
      vlin := 1;

      -- Obtenemos la PK
      SELECT srelacion.NEXTVAL
        INTO vrelacion
        FROM DUAL;

      vlin := 2;
      vmes_ano := TO_DATE(pmes_ano || '01', 'RRRRMMDD');
      vlin := 3;

      INSERT INTO relaciones_cab
                  (srelacion, trelacion, frelacion, ctipo,
                   cagente, nmes_ano, nfactura, frelalta, frealbaja, falta, cusualt, fmodifi,
                   cusumod)
           VALUES (vrelacion, 'Bolsa de ' || TO_CHAR(vmes_ano, 'MM/RRRR'), vmes_ano, 4,
                   pcagente, pmes_ano, pnfactura, f_sysdate, NULL, f_sysdate, f_user, NULL,
                   NULL);

      psrelacion := vrelacion;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobj, vlin, vparam, SQLERRM);
         RETURN 1000455;   -- Error no controlado.
   END f_set_relacion;

    /*************************************************************************
    Función que realiza la vallidación de una cabecera de una relación
    param in pmes_ano     : number
    param in pnfactura    : varchar2
    param in pcagente     : number
         return             : 0 iNo existe relació
                           <> 0 insert incorrecto
   *************************************************************************/
   FUNCTION f_existe_relacion(pmes_ano IN NUMBER, pnfactura IN VARCHAR2)
      RETURN NUMBER IS
      vcont          NUMBER;
      vobj           VARCHAR2(70) := 'PAC_RELACIONES.F_EXISTE_RELACION';
      vlin           NUMBER;
      vparam         VARCHAR2(200) := 'pmes_ano: ' || pmes_ano || ', pnfactura: ' || pnfactura;
   BEGIN
      vlin := 1;

      SELECT COUNT(*)
        INTO vcont
        FROM relaciones_cab
       WHERE nmes_ano = pmes_ano
         AND nfactura = NVL(pnfactura, nfactura);

      vlin := 2;

      IF vcont <> 0 THEN
         RETURN 9908178;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobj, vlin, vparam, SQLERRM);
         RETURN 1000455;   -- Error no controlado.
   END f_existe_relacion;
-- FIN Bug 0036392 MMS 20150617
END pac_relaciones;

/

  GRANT EXECUTE ON "AXIS"."PAC_RELACIONES" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_RELACIONES" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_RELACIONES" TO "PROGRAMADORESCSI";
