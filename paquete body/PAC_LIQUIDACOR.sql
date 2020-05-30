--------------------------------------------------------
--  DDL for Package Body PAC_LIQUIDACOR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_LIQUIDACOR" AS
/******************************************************************************
   NOMBRE:       PAC_MD_LIQUIDACOR
   PROPÓSITO:    Contiene las funciones para la liquidación de comisiones de Correduria

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        25/11/2010   XPL                1. Creación del package. Bug 16310
******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

   /*************************************************************************
          Función que devolverá la query con los sproliq de la busqueda realizada
          param in p_cempres   : código de la empresa
          param in p_sproduc   : Producto
          param in p_npoliza   : Póliza
          param in p_cagente   : Agente
          param in p_femiini   : Fecha inicio emisión.
          param in p_femifin   : Fecha fin emisión.
          param in p_fefeini   : Fecha inicio efecto
          param in p_fefefin   : Fecha fin efecto
          param in p_fcobini   : Fecha inicio cobro
          param in p_fcobfin   : Fecha fin cobro.
          param in p_idioma    : Idioma
          return out psquery   : varchar2
            25/11/2010#XPL#16310
   *************************************************************************/
   FUNCTION f_get_liquida(
      p_cempres IN NUMBER,
      p_sproduc IN NUMBER,
      p_sproliq IN NUMBER,
      p_nmes IN NUMBER,
      p_anyo IN NUMBER,
      p_cestado IN NUMBER,
      p_npoliza IN NUMBER,
      p_cpolcia IN VARCHAR2,
      p_nrecibo IN NUMBER,
      p_creccia IN VARCHAR2,
      p_ccompani IN NUMBER,
      p_cagente IN NUMBER,
      p_femiini IN DATE,
      p_femifin IN DATE,
      p_fefeini IN DATE,
      p_fefefin IN DATE,
      p_fcobini IN DATE,
      p_fcobfin IN DATE,
      p_idioma IN NUMBER)
      RETURN CLOB IS
      --v_selec        VARCHAR2(10000);
      v_selec        CLOB;
      v_selec1       VARCHAR2(500);
      v_selec2       VARCHAR2(500);
      v_selec3       VARCHAR2(500);
      v_object       VARCHAR2(500) := 'PAC_LIQUIDACOR.f_get_liquida';
      v_param        VARCHAR2(500) := 'parámetros -  p_cidioma: ' || p_idioma;
      v_pasexec      NUMBER(5) := 1;
      vdiasliq       NUMBER(5) := 0;
      v_data         DATE;
      v_recibos      NUMBER(1) := 0;
   BEGIN
      v_selec1 :=
         ' SELECT distinct(al.sproliq)
           FROM adm_liquida al, adm_liquida_mov alm, adm_liquida_recibos alr, recibos r, seguros s  where
           al.sproliq = alm.sproliq and alr.sproliq = al.sproliq and alr.nrecibo = r.nrecibo
           and r.sseguro = s.sseguro
           and alm.nmovliq = (select max(almm.nmovliq) from adm_liquida_mov almm where almm.sproliq = al.sproliq)  ';
      v_selec2 :=
         ' SELECT distinct(al.sproliq)
           FROM adm_liquida al, adm_liquida_mov alm
           WHERE al.sproliq = alm.sproliq  ';

      IF p_cagente IS NOT NULL THEN
         v_recibos := 1;
         v_selec3 := v_selec3 || ' and alr.cagente = ' || p_cagente;
      END IF;

      IF p_sproduc IS NOT NULL THEN
         v_recibos := 1;
         v_selec3 := v_selec3 || ' and s.sproduc = ' || p_sproduc;
      END IF;

      IF p_npoliza IS NOT NULL THEN
         v_recibos := 1;
         v_selec3 := v_selec3 || ' and s.npoliza = ' || p_npoliza;
      END IF;

      IF p_cempres IS NOT NULL THEN
         v_selec3 := v_selec3 || ' and al.cempres = ' || p_cempres;
      END IF;

      IF p_femiini IS NOT NULL THEN
         v_recibos := 1;
         v_selec3 := v_selec3 || ' and r.femisio >= ' || p_femiini;
      END IF;

      IF p_femifin IS NOT NULL THEN
         v_recibos := 1;
         v_selec3 := v_selec3 || ' and r.femisio <= ' || p_femifin;
      END IF;

      IF p_fefeini IS NOT NULL THEN
         v_recibos := 1;
         v_selec3 := v_selec3 || ' and r.fefecto >= ' || p_fefeini;
      END IF;

      IF p_fefefin IS NOT NULL THEN
         v_recibos := 1;
         v_selec3 := v_selec3 || ' and r.fefecto <= ' || p_fefefin;
      END IF;

      IF p_fcobini IS NOT NULL THEN
         v_recibos := 1;
         v_selec3 :=
            v_selec3
            || ' and r.nrecibo in (select b.nrecibo   from movrecibo b  where b.fmovini >= '
            || p_fcobini || ' ) ';
      END IF;

      IF p_fcobfin IS NOT NULL THEN
         v_recibos := 1;
         v_selec3 :=
            v_selec3
            || ' and r.nrecibo in (select b.nrecibo   from movrecibo b  where b.fmovini <= '
            || p_fcobfin || ') ';
      END IF;

      IF p_sproliq IS NOT NULL THEN
         v_selec3 := v_selec3 || ' and al.sproliq = ' || p_sproliq;
      END IF;

      IF p_cestado IS NOT NULL THEN
         v_selec3 := v_selec3 || ' and alm.cestliq = ' || p_cestado;
      END IF;

      IF p_cpolcia IS NOT NULL THEN
         v_recibos := 1;
         v_selec3 := v_selec3 || ' and s.cpolcia  like  ' || CHR(39) || p_cpolcia || CHR(39);
      END IF;

      IF p_nrecibo IS NOT NULL THEN
         v_recibos := 1;
         v_selec3 := v_selec3 || ' and alr.nrecibo = ' || p_nrecibo;
      END IF;

      IF p_creccia IS NOT NULL THEN
         v_recibos := 1;
         v_selec3 := v_selec3 || ' and r.creccia  like  ' || CHR(39) || p_creccia || CHR(39);
      END IF;

      IF p_ccompani IS NOT NULL THEN
         v_selec3 := v_selec3 || ' and al.ccompani = ' || p_ccompani;
      END IF;

      IF p_cagente IS NOT NULL THEN
         v_recibos := 1;
         v_selec3 := v_selec3 || ' and alr.cagente = ' || p_cagente;
      END IF;

      IF p_nmes IS NOT NULL
         AND p_anyo IS NOT NULL THEN
         v_data := TO_DATE('01/' || p_nmes || '/' || p_anyo, 'DD/MM/YYYY');
         v_selec3 := v_selec3 || ' and al.fliquida =   ' || CHR(39) || v_data || CHR(39);
      END IF;

      IF v_recibos = 0 THEN
         v_selec := v_selec2 || v_selec3;
      ELSE
         v_selec := v_selec1 || v_selec3;
      END IF;

      --  p_control_error('xpl', 'query get liquida', v_selec);
      RETURN v_selec;
   EXCEPTION
      WHEN e_param_error THEN
         p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param,
                     'Parámetros incorrectos');
         RETURN NULL;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param,
                     SQLCODE || ' - ' || SQLERRM);
         RETURN NULL;
   END f_get_liquida;

   /*************************************************************************
          Función que devolverá la query con la información del/los movimientos de la liquidacion(ob_iax_liquida_mov)
          param in p_sproliq   : código de la liquidación
          param in p_nmovliq   : Movimiento de la liquidacion
          param in p_cestliq   : Estado de la liquidacion
          param in p_cmonliq   : Moneda de la liquidacion
          param in p_idioma    : Idioma
          return out psquery   : VARCHAR2
            25/11/2010#XPL#16310
   *************************************************************************/
   FUNCTION f_get_cabecera_liquida(
      p_cempres IN NUMBER,
      p_ccompani IN NUMBER,
      p_finiliq IN DATE,
      p_ffinliq IN DATE,
      p_sproliq IN NUMBER,
      p_fliquida IN DATE,
      p_idioma IN NUMBER)
      RETURN CLOB IS
      --v_selec        VARCHAR2(10000);
      v_selec        CLOB;
      v_object       VARCHAR2(500) := 'PAC_LIQUIDACOR.f_get_cabecera_liquida';
      v_param        VARCHAR2(500) := 'parámetros -  p_cidioma: ' || p_idioma;
      v_pasexec      NUMBER(5) := 1;
      vdiasliq       NUMBER(5) := 0;
   BEGIN
      v_selec :=
         ' SELECT al.sproliq, al.cempres, (select tempres from empresas where cempres = '
         || p_cempres
         || ') tempres, al.fliquida, al.tliquida, alm.nmovliq, alm.cestliq, ff_desvalorfijo(800030,'
         || p_idioma
         || ',alm.cestliq) testliq, alm.itotliq, al.IIMPORT, al.FINILIQ, al.FFINLIQ, al.ccompani,
          (select tcompani from companias where ccompani = al.ccompani) tcompani
           FROM adm_liquida al, adm_liquida_mov alm
            where
           al.sproliq = alm.sproliq
           and alm.nmovliq = (select max(almm.nmovliq) from adm_liquida_mov almm where almm.sproliq = al.sproliq)  ';

      IF p_sproliq IS NOT NULL THEN
         v_selec := v_selec || ' and al.sproliq = ' || p_sproliq;
      END IF;

      IF p_cempres IS NOT NULL THEN
         v_selec := v_selec || ' and al.cempres = ' || p_cempres;
      END IF;

      IF p_ccompani IS NOT NULL THEN
         v_selec := v_selec || ' and al.ccompani = ' || p_ccompani;
      END IF;

      IF p_fliquida IS NOT NULL THEN
         v_selec := v_selec || ' and al.fliquida <=   ' || CHR(39) || p_fliquida || CHR(39);
      END IF;

      IF p_finiliq IS NOT NULL THEN
         v_selec := v_selec || ' and al.finiliq <=   ' || CHR(39) || p_finiliq || CHR(39);
      END IF;

      IF p_ffinliq IS NOT NULL THEN
         v_selec := v_selec || ' and al.ffinliq <=   ' || CHR(39) || p_ffinliq || CHR(39);
      END IF;

      --p_control_error('xpl', 'query get liquida', v_selec);
      RETURN v_selec;
   EXCEPTION
      WHEN e_param_error THEN
         p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param,
                     'Parámetros incorrectos');
         RETURN NULL;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param,
                     SQLCODE || ' - ' || SQLERRM);
         RETURN NULL;
   END f_get_cabecera_liquida;

   /*************************************************************************
          Función que devolverá la query con la información del/los movimientos de la liquidacion(ob_iax_liquida_mov)
          param in p_sproliq   : código de la liquidación
          param in p_nmovliq   : Movimiento de la liquidacion
          param in p_cestliq   : Estado de la liquidacion
          param in p_cmonliq   : Moneda de la liquidacion
          param in p_idioma    : Idioma
          return out psquery   : VARCHAR2
            25/11/2010#XPL#16310
   *************************************************************************/
   FUNCTION f_get_liquidamov(
      p_sproliq IN NUMBER,
      p_nmovliq IN NUMBER,
      p_cestliq IN NUMBER,
      p_cmonliq IN VARCHAR2,
      p_idioma IN NUMBER)
      RETURN VARCHAR2 IS
      --v_selec        VARCHAR2(10000);
      v_selec        CLOB;
      v_object       VARCHAR2(500) := 'PAC_LIQUIDAcor. f_get_liquidamov';
      v_param        VARCHAR2(500) := 'parámetros -  p_cidioma: ' || p_idioma;
      v_pasexec      NUMBER(5) := 1;
      vdiasliq       NUMBER(5) := 0;
   BEGIN
      v_selec :=
         ' SELECT sproliq, alm.nmovliq, alm.cestliq, ff_desvalorfijo(800030,' || p_idioma
         || ',alm.cestliq) testliq, alm.itotliq, alm.cmonliq, null tmonliq, cusualt, falta
           FROM  adm_liquida_mov alm
           where alm.sproliq = '
         || p_sproliq;

      IF p_nmovliq IS NOT NULL THEN
         v_selec := v_selec || ' and alm.nmovliq = ' || p_nmovliq;
      END IF;

      IF p_cestliq IS NOT NULL THEN
         v_selec := v_selec || ' and alm.cestliq = ' || p_cestliq;
      END IF;

      IF p_cmonliq IS NOT NULL THEN
         v_selec := v_selec || ' and alm.cmonliq  like  ' || CHR(39) || p_cmonliq || CHR(39);
      END IF;

      RETURN v_selec;
   EXCEPTION
      WHEN e_param_error THEN
         p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param,
                     'Parámetros incorrectos');
         RETURN NULL;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param,
                     SQLCODE || ' - ' || SQLERRM);
         RETURN NULL;
   END f_get_liquidamov;

   /*************************************************************************
          Función que devolverá la query con la información del/los recibos de la liquidacion(ob_iax_liquida_rec)
      param in  p_sproliq   : Proceso liquidacion
      param in  p_nrecibo   : Movimiento liquidacion
      param in  p_ccompani   : Estado de la liquidación(abierto, cerrado..)
      param in  p_cagente   : Agente
      param in  p_cmonseg   : Moneda seguro
      param in  p_cmonliq   : Moneda liquidacion
      param in  p_cgescob   : ges cob
      param in  p_cramo   : ramo
      param in  p_sproduc   : producto
      param in  p_fefectoini   : fecha efecto inicial
      param in  p_fefectofin   : fecha efecto fin
      param out pt_recliquida : coleccion de recibos
          return out psquery   : VARCHAR2
            25/11/2010#XPL#16310
   *************************************************************************/
   FUNCTION f_get_liquidarec(
      p_cempres IN NUMBER,
      p_sproliq IN NUMBER,
      p_nrecibo IN NUMBER,
      p_ccompani IN NUMBER,
      p_cagente IN NUMBER,
      p_cmonseg IN VARCHAR2,
      p_cmonliq IN VARCHAR2,
      p_cgescob IN NUMBER,
      p_cramo IN NUMBER,
      p_sproduc IN NUMBER,
      p_fefectoini IN DATE,
      p_fefectofin IN DATE,
      p_idioma IN NUMBER)
      RETURN VARCHAR2 IS
      --v_selec        VARCHAR2(10000);
      v_selec        CLOB;
      v_object       VARCHAR2(500) := 'PAC_LIQUIDAcor. f_get_liquidarec';
      v_param        VARCHAR2(500) := 'parámetros -  p_cidioma: ' || p_idioma;
      v_pasexec      NUMBER(5) := 1;
      vdiasliq       NUMBER(5) := 0;
   BEGIN
      v_selec :=
         ' SELECT sproliq, alr.nrecibo, alr.ccompani, (select tcompani from companias where ccompani = alr.ccompani) tcompani,
           alr.cagente, f_nombre(a.sperson,1,alr.cagente) tagente, alr.cmonseg, null tmonseg, itotalr, icomisi,
           iretenc, iprinet, iliquida, cmonliq, null tmonliq, iliquidaliq, fcambio, alr.cgescob,
           ff_desvalorfijo(694,'
         || p_idioma
         || ',alr.cgescob) tgescob
           FROM  adm_liquida_recibos alr, recibos r, agentes a, seguros s
           where alr.nrecibo = r.nrecibo and alr.cagente(+) = a.cagente and r.sseguro = s.sseguro ';

      IF p_sproliq IS NOT NULL THEN
         v_selec := v_selec || ' and alr.sproliq = ' || p_sproliq;
      END IF;

      IF p_nrecibo IS NOT NULL THEN
         v_selec := v_selec || ' and alr.nrecibo = ' || p_nrecibo;
      END IF;

      IF p_ccompani IS NOT NULL THEN
         v_selec := v_selec || ' and alr.ccompani = ' || p_ccompani;
      END IF;

      IF p_cagente IS NOT NULL THEN
         v_selec := v_selec || ' and alr.cagente = ' || p_cagente;
      END IF;

      IF p_cmonseg IS NOT NULL THEN
         v_selec := v_selec || ' and alr.cmonseg  like  ' || CHR(39) || p_cmonseg || CHR(39);
      END IF;

      IF p_cmonliq IS NOT NULL THEN
         v_selec := v_selec || ' and alr.cmonliq  like  ' || CHR(39) || p_cmonliq || CHR(39);
      END IF;

      IF p_cgescob IS NOT NULL THEN
         v_selec := v_selec || ' and alr.cgescob = ' || p_cgescob;
      END IF;

      IF p_cramo IS NOT NULL THEN
         v_selec := v_selec || ' and s.cramo = ' || p_cramo;
      END IF;

      IF p_sproduc IS NOT NULL THEN
         v_selec := v_selec || ' and s.sproduc = ' || p_sproduc;
      END IF;

      /*  IF  p_fefectoini IS NOT NULL THEN
           v_selec := v_selec || ' and r.fefecto = ' || p_fefectoini;
        END IF;

        */
      v_selec := v_selec || ' order by r.creccia asc, s.cpolcia asc ';
      RETURN v_selec;
   EXCEPTION
      WHEN e_param_error THEN
         p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param,
                     'Parámetros incorrectos');
         RETURN NULL;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param,
                     SQLCODE || ' - ' || SQLERRM);
         RETURN NULL;
   END f_get_liquidarec;

   /*************************************************************************
      Función que nos comprueba si existen liquidaciones para un mes y año en concreto
      param in  p_mes   : Mes liquidacion
      param in  p_anyo   : Año liquidacion
          return NUMBER : 1/0
            25/11/2010#XPL#16310
   *************************************************************************/
   FUNCTION f_valida_propuesta(
      p_mes IN NUMBER,
      p_anyo IN NUMBER,
      p_ccompani IN NUMBER,
      psproces IN NUMBER DEFAULT NULL)
      RETURN NUMBER IS
      v_object       VARCHAR2(500) := 'PAC_LIQUIDACOR.f_valida_propuesta';
      v_param        VARCHAR2(500) := 'parámetros - p_mes: ' || p_mes || '- p_anyo ' || p_anyo;
      v_pasexec      NUMBER(5) := 1;
      v_factor       NUMBER;
      vcestliq       NUMBER := 1;
      vcempres       NUMBER;
      vcagente       NUMBER;
      vitotalr       NUMBER;
      vitotimp       NUMBER;
      vicomisi       NUMBER;
      viliquida      NUMBER;
      v_cont         NUMBER;
      vfliquida      DATE;
   BEGIN
      vfliquida := TO_DATE('01/' || p_mes || '/' || p_anyo, 'DD/MM/YYYY');

      IF psproces IS NULL THEN
         SELECT COUNT(1)
           INTO v_cont
           FROM adm_liquida
          WHERE ccompani = p_ccompani
            AND fliquida = vfliquida;
      ELSE
         SELECT COUNT(1)
           INTO v_cont
           FROM adm_liquida
          WHERE ccompani = p_ccompani
            AND fliquida = vfliquida
            AND sproliq <> psproces;
      END IF;

      IF v_cont > 0 THEN
         RETURN 9901673;
      END IF;

      /*  SELECT COUNT(1)
          INTO v_cont
          FROM adm_liquida
         WHERE TO_CHAR(fliquida, 'DD') = p_mes
           AND TO_CHAR(fliquida, 'YYYY') = p_anyo
           AND ccompani = p_ccompani;

        IF v_cont > 0 THEN
           RETURN 9901673;
        END IF;*/
      v_pasexec := 8;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param, SQLERRM);
         RETURN 9001752;
   END f_valida_propuesta;

   /*************************************************************************
      Función que devolverá la query con la información del/los recibos de la liquidacion(ob_iax_liquida_rec)
      param in  p_cempres   : Empresa
      param in  p_sproliq   : Proceso liquidacion
      param in  p_nrecibo   : Movimiento liquidacion
      param in  p_ccompani   : Estado de la liquidación(abierto, cerrado..)
      param in  p_cagente   : Agente
      param in  p_cmonseg   : Moneda seguro
      param in  p_cmonliq   : Moneda liquidacion
      param in  p_cgescob   : ges cob
      param in  p_cramo   : ramo
      param in  p_sproduc   : producto
      param in  p_fefectoini   : fecha efecto inicial
      param in  p_fefectofin   : fecha efecto fin
      param in  p_mes   : Mes liquidacion
      param in  p_anyo   : Año liquidacion
      param in  p_idioma   : Idioma
      return out psquery   : VARCHAR2
            25/11/2010#XPL#16310
   *************************************************************************/
   FUNCTION f_recibos_propuestos(
      p_cempres IN NUMBER,
      p_sproliq IN NUMBER,
      p_nrecibo IN NUMBER,
      p_ccompani IN NUMBER,
      p_cagente IN NUMBER,
      p_cmonseg IN VARCHAR2,
      p_cmonliq IN VARCHAR2,
      p_cgescob IN NUMBER,
      p_cramo IN NUMBER,
      p_sproduc IN VARCHAR2,
      p_fefectoini IN DATE,
      p_fefectofin IN DATE,
      p_mes IN NUMBER,
      p_anyo IN NUMBER,
      p_idioma IN NUMBER)
      RETURN VARCHAR2 IS
      v_object       VARCHAR2(500) := 'PAC_LIQUIDACOR.f_recibos_propuestos';
      v_param        VARCHAR2(500) := 'parámetros - p_mes: ' || p_mes || '- p_anyo ' || p_anyo;
      v_pasexec      NUMBER(5) := 1;
      v_factor       NUMBER;
      vcestliq       NUMBER := 1;
      vcempres       NUMBER;
      vcagente       NUMBER;
      vitotalr       NUMBER;
      vitotimp       NUMBER;
      vicomisi       NUMBER;
      viliquida      NUMBER;
      v_cont         NUMBER;
      v_data         DATE;
      v_selec        VARCHAR2(1000);
      v_query        VARCHAR2(1000);
   BEGIN
      IF p_mes IS NOT NULL
         AND p_anyo IS NOT NULL THEN
         v_data := TO_DATE('28/' || p_mes || '/' || p_anyo, 'DD/MM/YYYY');
      END IF;

      IF v_data IS NOT NULL THEN
         v_selec := v_selec || ' and mr.fmovini <=  ' || CHR(39) || v_data || CHR(39);
      END IF;

      IF p_ccompani IS NOT NULL THEN
         v_selec := v_selec || ' and s.ccompani = ' || p_ccompani;
      END IF;

      IF p_cagente IS NOT NULL THEN
         v_selec := v_selec || ' and r.cagente = ' || p_cagente;
      END IF;

      IF p_cempres IS NOT NULL THEN
         v_selec := v_selec || ' and r.cempres = ' || p_cempres;
      END IF;

      /*  IF p_cmonseg IS NOT NULL THEN
           v_selec := v_selec || ' and alr.cmonseg  like  ' || CHR(39) ||  p_cmonseg || CHR(39) ;
        END IF;

        IF p_cmonliq IS NOT NULL THEN
           v_selec := v_selec || ' and alr.cmonliq  like  ' || CHR(39) ||  p_cmonliq || CHR(39) ;
        END IF;

        IF p_cgescob IS NOT NULL THEN
           v_selec := v_selec || ' and alr.cgescob = ' || p_cgescob;
        END IF;*/
      IF p_cramo IS NOT NULL THEN
         v_selec := v_selec || ' and s.cramo = ' || p_cramo;
      END IF;

      IF p_sproduc IS NOT NULL THEN
         v_selec := v_selec || ' and s.sproduc IN (' || p_sproduc || ') ';
      END IF;

      IF p_fefectoini IS NOT NULL THEN
         IF p_fefectofin IS NOT NULL THEN
            v_selec := v_selec || ' and mr.fmovini between ' || CHR(39) || p_fefectoini
                       || ''' and ''' || p_fefectofin || CHR(39);
         ELSE
            v_selec := v_selec || ' and mr.fmovini >=  ' || CHR(39) || p_fefectoini || CHR(39);
         END IF;
      END IF;

      IF p_fefectofin IS NOT NULL THEN
         IF p_fefectoini IS NULL THEN
            v_selec := v_selec || ' and mr.fmovini <=   ' || CHR(39) || p_fefectofin
                       || CHR(39);
         END IF;
      END IF;

      /* v_query :=
          ' select nrecibo from  (SELECT r.nrecibo
            FROM  recibos r, seguros s
            where  f_cestrec_mv(r.nrecibo, null)  = 1 and s.sseguro = r.sseguro '
          || v_selec
          || '
            minus
            select alr.nrecibo from adm_liquida_recibos alr)
            where NVL(pac_parametros.f_parinstalacion_n(''N_MAX_REG''), ROWNUM) >= ROWNUM ';*/
      v_query :=
         'SELECT  mr.nrecibo
  FROM recibos r, seguros s, movrecibo mr
 WHERE s.sseguro = r.sseguro
   AND mr.nrecibo = r.nrecibo
   AND mr.fmovfin IS NULL
   AND mr.cestrec IN(0, 1, 2)
   AND(mr.cestrec = 1
        OR mr.cestrec = 2
        OR(mr.cestrec = 0
           AND mr.cestant != 0) ) '   --and NVL(pac_parametros.f_parinstalacion_n(''N_MAX_REG''), ROWNUM) >= ROWNUM '
         || v_selec;               /*
                        || '
                       minus
                       select alr.nrecibo from adm_liquida_recibos alr  ';      */
      v_pasexec := 8;
      -- v_selec := v_selec || ' and rownum  < ' || 100;
      --p_control_error('xpl', 'query', v_query);
      RETURN v_query;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param, SQLERRM);
         RETURN NULL;
   END f_recibos_propuestos;

   /*************************************************************************
      Función que nos grabará en la tabla adm_liquida
      param in  p_sproliq   : Proceso liquidacion
      param in  p_cempres   : Empresa
      param in  pfliquida   : Fecha liquidación
      param in  ptliquida   : Observacion liquidación
      return out psquery   : VARCHAR2
            25/11/2010#XPL#16310
   *************************************************************************/
   FUNCTION f_set_liquida(
      psproliq IN NUMBER,
      pccompani IN NUMBER,
      pfiniliq IN DATE,
      pffinliq IN DATE,
      pcempres IN NUMBER,
      pfliquida IN DATE,
      pimport IN NUMBER,
      ptliquida IN VARCHAR2)
      RETURN NUMBER IS
      v_object       VARCHAR2(500) := 'PAC_LIQUIDACOR.f_set_liquida';
      v_param        VARCHAR2(500)
         := 'parámetros - pSPROLIQ: ' || psproliq || ', pCEMPRES: ' || pcempres
            || ', pFLIQUIDA: ' || pfliquida || ', pTLIQUIDA: ' || ptliquida || ', pccompani: '
            || pccompani || ', pfiniliq: ' || pfiniliq || ', pffinliq: ' || pffinliq
            || ', pimport: ' || pimport;
      v_pasexec      NUMBER(5) := 1;
      v_factor       NUMBER;
      vcestliq       NUMBER := 1;
      vcempres       NUMBER;
      vcagente       NUMBER;
      vitotalr       NUMBER;
      vitotimp       NUMBER;
      vicomisi       NUMBER;
      viliquida      NUMBER;
      v_cont         NUMBER;
      v_sproliq      NUMBER := psproliq;
   BEGIN
      IF v_sproliq IS NULL THEN
         SELECT sproliq.NEXTVAL
           INTO v_sproliq
           FROM DUAL;
      END IF;

      BEGIN
         INSERT INTO adm_liquida
                     (sproliq, cempres, ccompani, fliquida, tliquida, finiliq,
                      ffinliq, iimport)
              VALUES (v_sproliq, pcempres, pccompani, pfliquida, ptliquida, pfiniliq,
                      pffinliq, pimport);
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
            UPDATE adm_liquida
               SET cempres = pcempres,
                   fliquida = pfliquida,
                   tliquida = ptliquida,
                   finiliq = pfiniliq,
                   ffinliq = pffinliq,
                   iimport = pimport,
                   ccompani = pccompani
             WHERE sproliq = psproliq
               AND ccompani = pccompani;
      END;

      v_pasexec := 8;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param, SQLERRM);
         RETURN 9001752;
   END f_set_liquida;

   /*************************************************************************
      Función que nos grabará en la tabla adm_liquida_mov
      param in  p_sproliq   : Proceso liquidacion
      param in  pnmovliq   : Movimiento liquidacion
      param in  pcestliq   : Estado liquidación
      param in  pcmonliq   : Moneda liquidación
      param in  pitotliq   : Importe liquidación
      return out psquery   : VARCHAR2
            25/11/2010#XPL#16310
   *************************************************************************/
   FUNCTION f_set_movliquida(
      psproliq IN NUMBER,
      pccompani IN NUMBER,
      pnmovliq IN NUMBER,
      pcestliq IN NUMBER,
      pcmonliq IN VARCHAR2,
      pitotliq IN NUMBER)
      RETURN NUMBER IS
      v_object       VARCHAR2(500) := 'PAC_LIQUIDACOR.f_set_liquida';
      v_param        VARCHAR2(500) := 'parámetros - pSPROLIQ: ' || psproliq;
      v_pasexec      NUMBER(5) := 1;
      v_factor       NUMBER;
      vcestliq       NUMBER := 1;
      vcempres       NUMBER;
      vcagente       NUMBER;
      vitotalr       NUMBER;
      vitotimp       NUMBER;
      vicomisi       NUMBER;
      viliquida      NUMBER;
      v_cont         NUMBER;
      v_sproliq      NUMBER := psproliq;
   BEGIN
      BEGIN
         INSERT INTO adm_liquida_mov
                     (sproliq, ccompani, nmovliq, cestliq, cmonliq, itotliq, cusualt,
                      falta)
              VALUES (psproliq, pccompani, pnmovliq, pcestliq, pcmonliq, pitotliq, f_user,
                      f_sysdate);
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
            UPDATE adm_liquida_mov
               SET sproliq = psproliq,
                   nmovliq = pnmovliq,
                   cestliq = pcestliq,
                   cmonliq = pcmonliq,
                   itotliq = pitotliq
             WHERE sproliq = psproliq
               AND nmovliq = pnmovliq
               AND ccompani = pccompani;
      END;

      v_pasexec := 8;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param, SQLERRM);
         RETURN 9001752;
   END f_set_movliquida;

   /*************************************************************************
      Función que nos grabará en la tabla adm_liquida_rec
      param in  p_sproliq   : Proceso liquidacion
      param in  pnrecibo   : Recibo liquidacion
      param in  pccompani   : Compañia liquidación
      param in  pcagente   : Agente liquidación
      param in  pitotalr   : Importe total recibo
      param in  picomisi   : Comision liquidación
      param in  piretenc   : Importe retencion liquidación
      param in  piliquida   : Importe liquidación
      param in  pcmonliq   : Moneda liquidación
      param in  piliquidaliq   : Importe (moneda)liquidación
      param in  pfcambio   : Importe liquidación(moneda)
      param in  pcgescob   : codigo ges cob
      return out psquery   : VARCHAR2
            25/11/2010#XPL#16310
   *************************************************************************/
   FUNCTION f_set_recliquida(
      psproliq IN NUMBER,
      pnrecibo IN NUMBER,
      pccompani IN NUMBER,
      pcagente IN NUMBER,
      pcmonseg IN VARCHAR2,
      pitotalr IN NUMBER,
      picomisi IN NUMBER,
      piretenc IN NUMBER,
      piprinet IN NUMBER,
      piliquida IN NUMBER,
      pcmonliq IN VARCHAR2,
      piliquidaliq IN NUMBER,
      pfcambio IN DATE,
      pcgescob IN NUMBER)
      RETURN NUMBER IS
      v_object       VARCHAR2(500) := 'PAC_LIQUIDACOR.f_set_recliquida';
      v_param        VARCHAR2(500) := 'parámetros - pSPROLIQ: ' || psproliq;
      v_pasexec      NUMBER(5) := 1;
      v_factor       NUMBER;
      vcestliq       NUMBER := 1;
      vcempres       NUMBER;
      vcagente       NUMBER;
      vitotalr       NUMBER;
      vitotimp       NUMBER;
      vicomisi       NUMBER;
      viliquida      NUMBER;
      v_cont         NUMBER;
      v_sproliq      NUMBER := psproliq;
   BEGIN
      BEGIN
         INSERT INTO adm_liquida_recibos
                     (sproliq, nrecibo, ccompani, cagente, cmonseg, itotalr, icomisi,
                      iretenc, iprinet, iliquida, cmonliq, iliquidaliq, fcambio,
                      cgescob)
              VALUES (psproliq, pnrecibo, pccompani, pcagente, pcmonseg, pitotalr, picomisi,
                      piretenc, piprinet, piliquida, pcmonliq, piliquidaliq, pfcambio,
                      pcgescob);
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
            UPDATE adm_liquida_recibos
               SET cagente = pcagente,
                   cmonseg = pcmonseg,
                   itotalr = pitotalr,
                   icomisi = picomisi,
                   iretenc = piretenc,
                   iprinet = piprinet,
                   iliquida = piliquida,
                   cmonliq = pcmonliq,
                   iliquidaliq = piliquidaliq,
                   fcambio = pfcambio,
                   cgescob = pcgescob
             WHERE sproliq = psproliq
               AND nrecibo = pnrecibo
               AND ccompani = pccompani;
      END;

      v_pasexec := 8;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param, SQLERRM);
         RETURN 9001752;
   END f_set_recliquida;

   /*************************************************************************
      Función que nos eliminar un recibo de la liquidación
      param in  p_sproliq   : Proceso liquidacion
      param in  pnrecibo   : Recibo liquidacion

            25/11/2010#XPL#16310
   *************************************************************************/
   FUNCTION f_del_recliquida(psproliq IN NUMBER, pccompani IN NUMBER, pnrecibo IN NUMBER)
      RETURN NUMBER IS
      v_object       VARCHAR2(500) := 'PAC_LIQUIDACOR.f_del_recliquida';
      v_param        VARCHAR2(500)
                        := 'parámetros - pSPROLIQ: ' || psproliq || ', pnrecibo: ' || pnrecibo;
      v_pasexec      NUMBER(5) := 1;
      v_factor       NUMBER;
      vcestliq       NUMBER := 1;
      vcempres       NUMBER;
      vcagente       NUMBER;
      vitotalr       NUMBER;
      vitotimp       NUMBER;
      vicomisi       NUMBER;
      viliquida      NUMBER;
      v_cont         NUMBER;
      v_sproliq      NUMBER := psproliq;
   BEGIN
      DELETE      adm_liquida_recibos
            WHERE sproliq = psproliq
              AND nrecibo = pnrecibo
              AND ccompani = pccompani;

      v_pasexec := 8;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param, SQLERRM);
         RETURN 9001752;
   END f_del_recliquida;

   /*************************************************************************
          Función nos devuelve las liquidaciones en las cuales se encuentra el recibo
          param in  P_nrecibo   : Nº de recibo
          param out mensajes    : Mensajes de error
          return                : 0.-    OK
                                  1.-    KO
          03/06/2011#XPL#0018732
       *************************************************************************/
   FUNCTION f_get_liquida_rec(pnrecibo IN NUMBER, p_idioma IN NUMBER, vquery OUT VARCHAR2)
      RETURN NUMBER IS
      v_object       VARCHAR2(500) := 'PAC_LIQUIDACOR.f_get_liquida_rec';
      v_param        VARCHAR2(500)
                         := 'parámetros - pnrecibo: ' || pnrecibo || '- p_idioma ' || p_idioma;
      v_pasexec      NUMBER(5) := 1;
   BEGIN
      vquery :=
         ' select cempres, al.sproliq, al.ccompani, ff_descompania(al.ccompani) tcompani,tliquida,
           finiliq,ffinliq, fliquida, nrecibo, alr.cagente,f_nombre(a.sperson,1,alr.cagente) tagente, iliquida,
           cestliq, ff_desvalorfijo(800030,'
         || p_idioma
         || ',alm.cestliq) testliq
           from adm_liquida al, adm_liquida_recibos alr,adm_liquida_mov alm, agentes a
           where al.sproliq = alr.sproliq
           and a.CAGENTE = alr.cagente
           and al.sproliq = alm.sproliq
           and al.ccompani = alm.ccompani
           and al.ccompani = alr.ccompani
           and alm.nmovliq = (select max(nmovliq) from adm_liquida_mov where sproliq = al.sproliq)
           and nrecibo = '
         || pnrecibo || ' order by al.sproliq';
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param, SQLERRM);
         RETURN 1;
   END f_get_liquida_rec;
END pac_liquidacor;

/

  GRANT EXECUTE ON "AXIS"."PAC_LIQUIDACOR" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_LIQUIDACOR" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_LIQUIDACOR" TO "PROGRAMADORESCSI";
