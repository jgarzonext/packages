--------------------------------------------------------
--  DDL for Package Body PAC_MD_ANULACIONES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_MD_ANULACIONES" AS
/******************************************************************************
   NOMBRE:       PAC_MD_ANULACIONES
   PROPÓSITO: Funciones para anular una póliza

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------  ------------------------------------
   1.0        19/12/2007  JAS        1. Creación del package.
   1.1        02/03/2009  DCM        2. Modificaciones Bug 8850
   1.2        19/05/2009  JTS        3. 9914: IAX- ANULACIÓN DE PÓLIZA - Baja inmediata
   4.0        26/02/2009  ICV        4. 0013068: CRE - Grabar el motivo de la anulación al anular la póliza
   5.0        14/04/2010  JGR        5. 0014114: CRE200 - Se generan recibos de extorno para un agente
                                        diferente al de la póliza (poficina que es el cagente del contexto)
   6.0        13/09/2010  DRA        6. 0015936: CIV800 - ERROR EN ANULACIÓN SIN EFECTO en VIDARIESGO
   7.0        13/12/2010  ICV        7. 0016775: CRT101 - Baja de pólizas
   8.0        20/01/2012  MDS        8. 0021016: LCOL705-Pantalla anulaci?
   9.0        26/01/2012  MDS        9. 0020664: LCOL_T001-LCOL - UAT - TEC - Anulaciones y Rehabilitaciones
   10.0       13/06/2012  ETM       10. 0022500: LCOL - TEC - Id2-Parametrización por producto del tiempo permitido antes del vencimiento de la póliza
   11.0       02/07/2012  MDS       11. 0022687: LCOL - Una Anulación al Efecto no debe crear movimientos de devolucion de valor de rescate ni devolucion de valores de cesion
   12.0       11/07/2012  APD       12. 0022826: LCOL_T010-Recargo por anulación a corto plazo
   13.0       27/09/2012  APD       13. 0023817: LCOL - Anulación de colectivos
   14.0       10-11-2012  JDS       14. 0023183: LCOL_T020-COA-Circuit d'alta de propostes amb coasseguran
   15.0       02/12/2014  RDD       15. 0028974: MSV0003-Desarrollo de Comisiones (COM04-Commercial Network Management)
******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

   /***********************************************************************
      Recupera los datos de los recibos de la poliza
      param in psseguro  : código de seguro
      param out mensajes : mensajes de error
      return             : ref cursor
   ***********************************************************************/
   FUNCTION f_get_recibos(psseguro IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vobjectname    VARCHAR2(500) := 'PAC_MD_ANULACIONES.F_Get_Recibos';
      vparam         VARCHAR2(500) := 'parámetros - psseguro: ' || psseguro;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      cur            sys_refcursor;
      squery         VARCHAR2(1000);
      -- BUG 21016 - MDS - 20/01/2012
      v_cempres      seguros.cempres%TYPE;
      v_tabla        VARCHAR2(50);
      v_sproduc      seguros.sproduc%TYPE;
      v_npoliza      seguros.npoliza%TYPE;
   BEGIN
      --Inicialitzacions
      IF psseguro IS NULL THEN
         RAISE e_param_error;
      END IF;

      -- ini BUG 21016 - MDS - 20/01/2012
      --  el 'Importe' de la tabla 'vdetrecibos_monpol' o de 'vdetrecibos'
      vpasexec := 2;

      SELECT cempres, sproduc, npoliza
        INTO v_cempres, v_sproduc, v_npoliza
        FROM seguros
       WHERE sseguro = psseguro;

      IF NVL(pac_parametros.f_parempresa_n(v_cempres, 'MONEDA_POL'), 0) = 1 THEN
         v_tabla := 'vdetrecibos_monpol v';
      ELSE
         v_tabla := 'vdetrecibos v';
      END IF;

      -- fin BUG 21016 - MDS - 20/01/2012
      vpasexec := 3;

      -- Bug 23817 - APD - 27/09/2012 -
      -- si el producto admite certificados
      -- y estamos en un certificado 0
      -- se realizan los mismos cambios que en la funcion pac_anulacion.f_recibos_colectivo
      IF NVL(f_parproductos_v(v_sproduc, 'ADMITE_CERTIFICADOS'), 0) = 1
         AND pac_seguros.f_get_escertifcero(NULL, psseguro) = 1 THEN
         squery :=
            'select r.nrecibo, '
            || '         to_date(to_char(r.fefecto,''dd/mm/yyyy hh24:mi:ss'') ,''dd/mm/yyyy hh24:mi:ss'') + 0.00001 as fefecto, '
            || '         to_date(to_char(r.fvencim,''dd/mm/yyyy hh24:mi:ss'') ,''dd/mm/yyyy hh24:mi:ss'') + 0.00001 as fvencim, '
            || '         itotalr as iconcep, ' || '         cestrec, '
            || '         (select tatribu from detvalores where cvalor = 1 and catribu = cestrec and cidioma = '
            || pac_md_common.f_get_cxtidioma || ') as testrec, ' || '         ctiprec, '
            || '         (select tatribu from detvalores where cvalor = 8 and catribu = ctiprec and cidioma = '
            || pac_md_common.f_get_cxtidioma || ') as ttiprec, r.CRECCIA  '
            || ' from seguros s, recibos r, movrecibo m, ' || v_tabla
            || ' where  s.npoliza = ' || v_npoliza || ' and r.sseguro = s.sseguro '
            || ' and r.nrecibo = m.nrecibo '
            || ' and m.smovrec = (select max(m2.smovrec) from movrecibo m2 where m2.nrecibo = m.nrecibo) '
            || ' and r.nrecibo = v.nrecibo '
            || ' and r.nrecibo NOT IN (SELECT nrecibo FROM adm_recunif) '
            || ' order by r.fefecto desc ';
      ELSE
         -- fin Bug 23817 - APD - 27/09/2012 -
         squery :=
            'select r.nrecibo, '
            || '         to_date(to_char(fefecto,''dd/mm/yyyy hh24:mi:ss'') ,''dd/mm/yyyy hh24:mi:ss'') + 0.00001 as fefecto, '
            || '         to_date(to_char(fvencim,''dd/mm/yyyy hh24:mi:ss'') ,''dd/mm/yyyy hh24:mi:ss'') + 0.00001 as fvencim, '
            || '         itotalr as iconcep, ' || '         cestrec, '
            || '         (select tatribu from detvalores where cvalor = 1 and catribu = cestrec and cidioma = '
            || pac_md_common.f_get_cxtidioma || ') as testrec, ' || '         ctiprec, '
            || '         (select tatribu from detvalores where cvalor = 8 and catribu = ctiprec and cidioma = '
            || pac_md_common.f_get_cxtidioma || ') as ttiprec, r.CRECCIA  '
            || ' from recibos r, movrecibo m, ' || v_tabla || ' where  r.sseguro = '
            || psseguro || ' and r.nrecibo = m.nrecibo '
            || ' and m.smovrec = (select max(m2.smovrec) from movrecibo m2 where m2.nrecibo = m.nrecibo) '
            || ' and r.nrecibo = v.nrecibo ' || ' order by r.fefecto desc ';
      END IF;

      vpasexec := 5;
      cur := pac_iax_listvalores.f_opencursor(squery, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN cur;
      WHEN OTHERS THEN
         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN cur;
   END f_get_recibos;

   /***********************************************************************
      Recupera los datos de los siniestros de la poliza
      param in psseguro  : código de seguro
      param out mensajes : mensajes de error
      return             : ref cursor
   ***********************************************************************/
   FUNCTION f_get_siniestros(psseguro IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vobjectname    VARCHAR2(500) := 'PAC_IAX_ANULACIONES.F_Get_Siniestros';
      vparam         VARCHAR2(500) := 'parámetros - psseguro: ' || psseguro;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      cur            sys_refcursor;
      squery         VARCHAR2(500);
      v_modsini      NUMBER;
   BEGIN
      --Comprovació de paràmetres d'entrada
      IF psseguro IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;

      --BUG 11635 - svj - 29/10/2009
      BEGIN
         SELECT NVL(pac_parametros.f_parempresa_n(cempres, 'MODULO_SINI'), 0)
           INTO v_modsini
           FROM seguros
          WHERE sseguro = psseguro;
      EXCEPTION
         WHEN OTHERS THEN
            v_modsini := 0;   -- Cero indica que va por el modulo antiguo. Tabla siniestros
                              -- Uno indica que va por el módulo nuevo. Tabla Sin_siniestros.
      END;

      IF v_modsini = 0 THEN
         squery := 'select nsinies,fsinies, ' || '       (select tatribu from detvalores '
                   || '       where cvalor=6 and catribu=cestsin ' || '       and cidioma='
                   || pac_md_common.f_get_cxtidioma || ') as cestsin, ' || '       tsinies '
                   || ' from siniestros ' || ' where sseguro=' || psseguro;
      ELSE
         squery := 'SELECT s.nsinies, s.fsinies, ' || '(SELECT tatribu ' || 'FROM detvalores '
                   || 'WHERE cvalor = 6 ' || 'AND catribu = (SELECT m.cestsin '
                   || 'FROM sin_movsiniestro m ' || 'WHERE m.nsinies = s.nsinies '
                   || 'AND m.nmovsin = (SELECT MAX(mm.nmovsin) '
                   || 'FROM sin_movsiniestro mm ' || 'WHERE mm.nsinies = s.nsinies)) '
                   || 'AND cidioma = pac_md_common.f_get_cxtidioma) AS cestsin, '
                   || 's.tsinies ' || 'FROM sin_siniestro s ' || 'WHERE s.sseguro = '
                   || psseguro;
      END IF;

      vpasexec := 5;
      cur := pac_iax_listvalores.f_opencursor(squery, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN cur;
      WHEN OTHERS THEN
         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, squery || '  -- ' || SQLERRM);
         RETURN cur;
   END f_get_siniestros;

   /***********************************************************************
      Dado el tipo de anulación (al efecto o al vencimiento) calcula la fecha
      de la anulación de un determinado seguro.
      param in psseguro  : código de seguro
      param in pctipanul : código tipo de anulación
      param out mensajes : mensajes de error
      return             : ref cursor
   ***********************************************************************/
   FUNCTION f_get_fanulac(
      psseguro IN NUMBER,
      pctipanul IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN DATE IS
      vobjectname    VARCHAR2(500) := 'PAC_MD_ANULACIONES.F_Get_Fanulac';
      vparam         VARCHAR2(500)
                     := 'parámetros - psseguro: ' || psseguro || ' - pctipanul: ' || pctipanul;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vfanulac       DATE;

      --JAMF 33921 23/01/2015  Nueva función interna para calcular la fecha de anulación si hay un cobro parcial de recibo
      FUNCTION f_fanulac_cobro_parcial(psseguro IN NUMBER)
         RETURN DATE IS
         vtotal         NUMBER;
         vnrecibo       recibos.nrecibo%TYPE;
         vimporte       NUMBER;
         vfefecto       DATE;
         vfvencim       DATE;
         vfanulac       DATE;
         vfactor        NUMBER;
         vencontrado    BOOLEAN;
      BEGIN
         BEGIN
            SELECT MIN(rr.nrecibo), MIN(rr.fefecto)
              INTO vnrecibo, vfanulac   --Recibo pendiente más antiguo, del seguro
              FROM recibos rr, movrecibo mm
             WHERE rr.sseguro = psseguro
               AND mm.nrecibo = rr.nrecibo
               AND mm.smovrec = (SELECT MAX(smovrec)
                                   FROM movrecibo
                                  WHERE nrecibo = rr.nrecibo)
               AND mm.cestrec = 0
               AND rr.fefecto = (SELECT MIN(fefecto)
                                   FROM recibos r, movrecibo m
                                  WHERE sseguro = psseguro
                                    AND r.nrecibo = m.nrecibo
                                    AND m.cestrec = 0
                                    AND m.smovrec IN(SELECT MAX(smovrec)
                                                       FROM movrecibo
                                                      WHERE nrecibo = r.nrecibo));

            BEGIN
               SELECT   SUM(iimporte) total, r.fefecto, r.fvencim
                   INTO vimporte, vfefecto, vfvencim
                   FROM recibos r, detmovrecibo p
                  WHERE r.sseguro = psseguro
                    AND p.nrecibo = r.nrecibo
                    AND r.nrecibo = vnrecibo
               GROUP BY p.nrecibo, r.fefecto, r.fvencim;

               SELECT NVL(itotalr, 0)
                 INTO vtotal
                 FROM vdetrecibos
                WHERE nrecibo = vnrecibo;

               vfactor := vimporte / vtotal;
               vfanulac := TRUNC(vfefecto + NVL((vfvencim - vfefecto) * vfactor, 0));
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  NULL;   --No hay cobro parcial, se deja como fecha de anlación la fecha de efecto del recibo pendiente
            END;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN   --Si no encuentra recibos pendientes
               vfanulac := NULL;
         END;

         RETURN vfanulac;
      END f_fanulac_cobro_parcial;
   BEGIN
      --Comprovació de paràmetres d'entrada
      IF psseguro IS NULL
         OR pctipanul IS NULL
         -- BUG 8850 - 8850 - DCM ¿ Añadimos el tipo 3
         --JAMF 33921 23/01/2015  Añadimos tipo 5
         OR pctipanul NOT IN(1, 2, 3, 4, 5) THEN
         -- FI BUG 8850 - 8850 - DCM ¿ Añadimos el tipo 3
         RAISE e_param_error;
      END IF;

      vpasexec := 3;

      IF pctipanul = 1 THEN   -- Anul·lació a l'efecte (VF. 553)
         SELECT s.fefecto
           INTO vfanulac
           FROM seguros s
          WHERE s.sseguro = psseguro;
      -- BUG 8850 - 8850 - DCM ¿ Tratamiento tipo de anulacion al VTO fecha de proxima cartera
      ELSIF pctipanul = 2 THEN   -- Anul·lació a la propera cartera (VF. 553)
         SELECT s.fcarpro
           INTO vfanulac
           FROM seguros s
          WHERE s.sseguro = psseguro;
      ELSIF pctipanul = 3 THEN   -- Anul·lació al venciment (VF. 553)
         SELECT s.fcaranu
           INTO vfanulac
           FROM seguros s
          WHERE s.sseguro = psseguro;
      ELSIF pctipanul = 4 THEN   -- Anul·lació inmediata (VF. 553)
         vfanulac := TRUNC(f_sysdate);
      ELSIF pctipanul = 5 THEN   --Baja con cobros parciales   JAMF  33921 23/01/2015
         vfanulac := f_fanulac_cobro_parcial(psseguro);
      END IF;

      -- FI BUG 8850 - 8850 - DCM ¿ Tratamiento tipo de anulacion al VTO fecha de proxima cartera

      --JAMF  33921  23/01/2015  Indicamos que no hay recibos pendientes Literal= No se puede hacer baja por impago si no hay recibos pendientes.
      IF vfanulac IS NULL THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, '', 9907492, vpasexec, vparam);
      END IF;

      RETURN vfanulac;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN NULL;
   END f_get_fanulac;

   /***********************************************************************
      Inserta un registro en la tabla AGENSEGU.
      param in psseguro  : código de seguro
      param in pctipanul : código del tipo de anulación
      param in pmotanula : motivo de anulación
      param out mensajes : mensajes de error
      return             :    0 -> Apunte realizado correctamente
                         : <> 0 -> Error realizando el apunte en agenda
   ***********************************************************************/
   -- Bug 22826 - APD - 11/07/2012 - se añade el parametro precextrn y paplica_penali
   FUNCTION f_ins_agensegu(
      psseguro IN NUMBER,
      pctipanul IN NUMBER,
      pmotanula IN VARCHAR2,
      pccauanul IN NUMBER,
      precextrn IN NUMBER,
      paplica_penali IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_MD_ANULACIONES.F_Ins_Agensegu';
      vparam         VARCHAR2(500)
         := 'parámetros - psseguro: ' || psseguro || ' - pctipanul: ' || pctipanul
            || ' - pmotanula: ' || pmotanula || ' - pccauanul: ' || pccauanul;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vttipanul      VARCHAR2(100);
      vmotmovseg     VARCHAR2(100);
      vtextos        agensegu.ttextos%TYPE;   -- Bug 22826 - APD - 11/07/2012
   BEGIN
      --Comprovació de paràmetres d'entrada
      IF psseguro IS NULL
         OR pctipanul IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;
      --Obtenim la descripció del tipus d'anul·lació per fer un apunt a l'agenda amb el motiu d'anul·lació.
      vttipanul := SUBSTR(pac_iax_listvalores.f_getdescripvalores(553, pctipanul, mensajes), 1,
                          100);

      IF vttipanul IS NULL THEN
         RAISE e_object_error;
      END IF;

      vpasexec := 5;
      --Busquem la casusa per ficar-ho  a l'agenda de l'assegurança
      --BUG10842-01/10/2009-JGM
      vnumerr := f_desmotmov(pccauanul, pac_md_common.f_get_cxtidioma, vmotmovseg);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      -- Bug 22826 - APD - 11/07/2012
      vtextos := f_axis_literales(100811, pac_md_common.f_get_cxtidioma) || ' ' || vmotmovseg
                 || CHR(13) || CHR(13) || pmotanula;

      IF NVL(precextrn, 0) = 1 THEN
         -- se ha marcado el check de Extornar recibos cobrados
         -- Aplica extorno recibos cobrados
         vtextos := vtextos || CHR(13) || CHR(13)
                    || f_axis_literales(9903949, pac_md_common.f_get_cxtidioma);

         IF NVL(paplica_penali, 0) = 1 THEN
            -- se ha marcado el check de Anulación a corto plazo
            -- Aplica anulación a corto plazo
            vtextos := vtextos || CHR(13) || CHR(13)
                       || f_axis_literales(9903950, pac_md_common.f_get_cxtidioma);
         END IF;
      END IF;

      -- fin Bug 22826 - APD - 11/07/2012
      --Apuntem el motiu de l'anul·lació a l'agenda de l'assegurança
      --BUG9208-28052009-XVM
      vnumerr := pac_agensegu.f_set_datosapunte(NULL, psseguro, NULL, vttipanul, vtextos, 6, 1,
                                                f_sysdate, f_sysdate, 0, 0);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_ins_agensegu;

   /***********************************************************************
      Procesa la anulación de la póliza al efecte e inmediata VF 553 (1,4)
      param out mensajes : mensajes de error
      param in precextrn : indica si se debe procesar el extorno
      return             : 0 todo ha sido correcto
                           1 ha habido un error
   ***********************************************************************/
   -- Bug 22826 - APD - 11/07/2012 - se añade el parametro paplica_penali
   -- se añade el parametro pbajacol = 0.Se está realizando la baja de un certificado normal
   -- 1.Se está realizando la baja del certificado 0
   FUNCTION f_anulacion_poliza(
      psseguro IN NUMBER,
      precextrn IN NUMBER,
      pfanulac IN DATE,
      pctipanul IN NUMBER,
      panula_rec IN NUMBER,
      precibos IN VARCHAR2,
      pccauanul IN NUMBER,
      paplica_penali IN NUMBER,
      pbajacol IN NUMBER DEFAULT 0,
      mensajes IN OUT t_iax_mensajes,
      pimpextorsion IN NUMBER DEFAULT 0,
      panumasiva IN NUMBER DEFAULT 0)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_MD_ANULACIONES.F_Anulacion_poliza';
      vparam         VARCHAR2(500)
         := 'parámetros - psseguro: ' || psseguro || ' - precextrn: ' || precextrn
            || ' - pctipanul: ' || pctipanul || ' - panula_rec: ' || panula_rec
            || ' - pfanulac: ' || pfanulac || ' - pimpextorsion: ' || pimpextorsion;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      v_existe       BOOLEAN;
      ocoderror      NUMBER;
      omsgerror      VARCHAR2(100);
      pcidioma       NUMBER := pac_md_common.f_get_cxtidioma;
      poficina       VARCHAR2(10) := pac_md_common.f_get_cxtagente;
      pterminal      VARCHAR2(10) := pac_md_common.f_get_cxtagente;
      --BUG 9914 - JTS - 19/05/2009
      rpend          pac_anulacion.recibos_pend;
      rcob           pac_anulacion.recibos_cob;
      vcur           sys_refcursor;
      vcont          NUMBER := 1;
      vfanulac       DATE;
      vfmovini       DATE;
      vmarcado       NUMBER;
      vtagente       VARCHAR2(200);
      vttiprec       VARCHAR2(200);
      vitotalr       NUMBER;
      vcmotmov       NUMBER;   --BUG 11635 - JTS - 29/10/2010
      vdummy         NUMBER;
      --Fi BUG 9914 - JTS - 19/05/2009
         -- Bug 19312 - RSC - 23/11/2011 - LCOL_T004 - Parametrizaci??nulaciones
      v_crealiza     cfg_accion.crealiza%TYPE;
   -- Fin Bug 19312
   BEGIN
      -- Validar que els camps obligatoris estan informats
      IF pac_util.validar(psseguro IS NOT NULL, 111995, pcidioma, ocoderror, omsgerror) THEN   -- Se tiene que informar la poliza
         IF pac_util.validar(poficina IS NOT NULL, 180252, pcidioma, ocoderror, omsgerror) THEN   -- Es obligatorio introducir la oficina
            --IF PAC_UTIL.Validar(pterminal IS NOT NULL,180253, pcidioma, oCODERROR, oMSGERROR) THEN                      -- Es obligatorio introducir el terminal
            vpasexec := 5;
            -- Recuperem dades de la pòlissa
            v_existe := FALSE;

            FOR rseguros IN
               (SELECT sseguro, sproduc, fefecto, cagente,
                       DECODE(pctipanul, 1, NULL, 11) valparcial,   --BUG 9914 - JTS - 09/11/2009
                       cempres   -- Bug 19312 - RSC - 23/11/2011 - LCOL_T004 - Parametrizaci??nulaciones
                  FROM seguros
                 WHERE sseguro = psseguro) LOOP
               v_existe := TRUE;
               vpasexec := 7;

               -- Validar que la pòlissa està en situació de poder ser anulada (retorni un 0), enviant com data d'anul·lació la data d'efecte
               IF pac_util.validar
                     (pac_anulacion.f_valida_permite_anular_poliza(psseguro, pfanulac,
                                                                   rseguros.valparcial,
                                                                   panumasiva),   --BUG 9914 - JTS - 09/11/2009
                      pcidioma, ocoderror, omsgerror) THEN   -- Utilitzem com error el que hagi retornat la funció
                  -- BUG15936:DRA:13/09/2010:Inici
                  vpasexec := 8;
                  p_tab_error(f_sysdate, f_user, vobjectname, psseguro,
                              'pctipanul: ' || pctipanul || ' fefecto: ' || rseguros.fefecto
                              || ' pfanulac: ' || TO_CHAR(pfanulac, 'DD-MM-YYYY'),
                              'ocoderror: ' || ocoderror || ' omsgerror: ' || omsgerror);
                  -- BUG15936:DRA:13/09/2010:Fi
                  vpasexec := 9;

                  --BUG 9914 - JTS - 19/05/2009
                  --IF pctipanul = 1 THEN
                  --   vfanulac := rseguros.fefecto;
                  IF pctipanul IN(1, 5) THEN   --JAMF  33921  23/01/2015
                     IF pctipanul = 1 THEN
                        vfanulac := rseguros.fefecto;
                     ELSE
                        vfanulac := pfanulac;
                     END IF;

                     vcur := pac_anulacion.f_recibos(psseguro, vfanulac, 0,
                                                     pac_md_common.f_get_cxtidioma, vnumerr, 1,
                                                     pbajacol);

                     IF vnumerr <> 0 THEN
                        pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
                        RAISE e_object_error;
                     END IF;

                     FETCH vcur
                      INTO rpend(vcont).nrecibo, rpend(vcont).fefecto, rpend(vcont).fvencim,
                           rpend(vcont).fmovini, vmarcado, vtagente, vttiprec, vitotalr;

                     WHILE vcur%FOUND LOOP
                        vcont := vcont + 1;

                        FETCH vcur
                         INTO rpend(vcont).nrecibo, rpend(vcont).fefecto,
                              rpend(vcont).fvencim, rpend(vcont).fmovini, vmarcado, vtagente,
                              vttiprec, vitotalr;
                     END LOOP;
                  ELSE
                     vfanulac := pfanulac;

                     IF precibos IS NOT NULL THEN
                        vcur := pac_anulacion.f_recibos_anulables(precibos, vnumerr);

                        IF vnumerr <> 0 THEN
                           pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
                           RAISE e_object_error;
                        END IF;

                        FETCH vcur
                         INTO rpend(vcont).nrecibo, rpend(vcont).fefecto, rpend(vcont).fvencim,
                              rpend(vcont).fmovini;

                        WHILE vcur%FOUND LOOP
                           vcont := vcont + 1;

                           FETCH vcur
                            INTO rpend(vcont).nrecibo, rpend(vcont).fefecto,
                                 rpend(vcont).fvencim, rpend(vcont).fmovini;
                        END LOOP;

                        vnumerr := pac_anulacion.f_recibos_anulados_mov(precibos);   --rdd

                        IF vnumerr <> 0 THEN
                           pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
                           RAISE e_object_error;
                        END IF;
                     END IF;
                  --
                  END IF;

                  -- Bug 19312 - RSC - 23/11/2011 - LCOL_T004 - Parametrizaci??nulaciones
                  vcont := 1;
                  vnumerr := pac_cfg.f_get_user_accion_permitida(f_user, 'EXTORNA_AHORRO',
                                                                 rseguros.sproduc,
                                                                 rseguros.cempres, v_crealiza);

                  IF NVL(v_crealiza, 1) = 0 THEN
-- Ini Bug 22687 - MDS - 02/07/2012
                     --IF pctipanul = 1 THEN
                     IF pctipanul IN(1, 5) THEN   --JAMF 33921  23/01/2015
                        IF pac_parametros.f_parmotmov_n(pccauanul, 'EXTORNA_BAJA_ERROR',
                                                        rseguros.sproduc) = 1 THEN
                           vcur := pac_anulacion.f_recibos(psseguro, vfanulac, 1,
                                                           pac_md_common.f_get_cxtidioma,
                                                           vnumerr, 1, pbajacol);
                        ELSE
                           vcur := pac_anulacion.f_recibos(psseguro, vfanulac, 1,
                                                           pac_md_common.f_get_cxtidioma,
                                                           vnumerr, v_crealiza, pbajacol);
                        END IF;
                     ELSE
                        vcur := pac_anulacion.f_recibos(psseguro, vfanulac, 1,
                                                        pac_md_common.f_get_cxtidioma,
                                                        vnumerr, v_crealiza, pbajacol);
                     END IF;
/*
                     vcur := pac_anulacion.f_recibos(psseguro, vfanulac, 1,
                                                     pac_md_common.f_get_cxtidioma, vnumerr,
                                                     v_crealiza);
*/
-- Fin Bug 22687 - MDS - 02/07/2012
                  ELSE
                     -- Fin Bug 19312
                     vcur := pac_anulacion.f_recibos(psseguro, vfanulac, 1,
                                                     pac_md_common.f_get_cxtidioma, vnumerr,
                                                     1, pbajacol);
                  END IF;

                  IF vnumerr <> 0 THEN
                     pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
                     RAISE e_object_error;
                  END IF;

                  FETCH vcur
                   INTO rcob(vcont).nrecibo, rcob(vcont).fefecto, rcob(vcont).fvencim,
                        rcob(vcont).fmovini, vmarcado, vtagente, vttiprec, vitotalr;

                  WHILE vcur%FOUND LOOP
                     vcont := vcont + 1;

                     FETCH vcur
                      INTO rcob(vcont).nrecibo, rcob(vcont).fefecto, rcob(vcont).fvencim,
                           rcob(vcont).fmovini, vmarcado, vtagente, vttiprec, vitotalr;
                  END LOOP;

                  --  Anular la pòlissa. Si torna un valor diferent de 0 és un error
                  --Inici bug 11635 - JTS - 29/10/2010
                  IF pctipanul = 1 THEN
                     vcmotmov := 306;
                  ELSIF pctipanul = 5 THEN   --JAMF  33921  23/01/2015
                     vcmotmov := 444;
                  ELSE
                     vcmotmov := 324;
                  END IF;

                  --Fi bug 11635 - JTS - 29/10/2010

                  --Ini Bug.: 13068 - 26/02/2010 - ICV - Se añade el paso del parametro PCCAUANUL
                  -- Bug 22826 - APD - 11/07/2012 - se añade el parametro paplica_penali
                  IF pac_util.validar
                        (pac_anulacion.f_anula_poliza
                                             (rseguros.sseguro, vcmotmov,   -- cmotmov

                                              --
                                               -- BUG 18423 - I - 27/12/2011 - JLB - LCOL000 - Multimoneda
                                               --f_parinstalacion_n('MONEDAINST'),   -- pcmoneda,
                                              pac_monedas.f_moneda_producto(rseguros.sproduc),

                                               -- BUG 18423 - F - 27/12/2011 - JLB - LCOL000 - Multimoneda
                                              --
                                              vfanulac,   -- pfanulac
                                              precextrn,   -- pcextorn  --//ACC VIGILAR EXTORN
                                              panula_rec,   -- Anular rebuts pendents
                                              rseguros.cagente,   --poficina, -- BUG 0014114 - JGR
                                              rpend,   -- rpend
                                              rcob,   -- rcob
                                              rseguros.sproduc, NULL,   -- pcnotibaja
                                              2, pccauanul, paplica_penali, pimpextorsion),
                         pcidioma, ocoderror, omsgerror) THEN
                     NULL;
                  END IF;
                  -- fin Bug 22826 - APD - 11/07/2012
               --Fi BUG 13068 - ICV

               --Fi BUG 9914 - JTS - 19/05/2009
               END IF;

               EXIT;   -- Només un registre
            END LOOP;

            -- Si no existeix la pòlissa també dóna un error
            IF ocoderror = 0 THEN
               IF pac_util.validar(v_existe, 100500, pcidioma, ocoderror, omsgerror) THEN   -- Pòlissa inexistent
                  NULL;
               END IF;
            END IF;
         --END IF;
         END IF;
      END IF;

      vpasexec := 13;

      IF ocoderror <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, ocoderror);
         RAISE e_object_error;
      ELSE
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, 101853);
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_anulacion_poliza;

   /***********************************************************************
      Procesa la anulación de la póliza a venciment VF 553 (2)
      param out mensajes : mensajes de error
      param in precextrn default 0 : indica si se debe procesar el extorno
      return             : 0 todo ha sido correcto
                           1 ha habido un error
   ***********************************************************************/
   FUNCTION f_anulacion_vto(
      psseguro IN NUMBER,
      pccauanul IN NUMBER,
      precextrn IN NUMBER DEFAULT 0,
      pctipanul IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_MD_ANULACIONES.F_Anulacion_VTO';
      vparam         VARCHAR2(500)
         := 'parámetros - psseguro: ' || psseguro || ' - pccauanul: ' || pccauanul
            || ' - precextrn: ' || precextrn;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
--        vfvencim        DATE;
--        vramo           NUMBER;
--        vmodali         NUMBER;
--        vtipseg         NUMBER;
--        vcolect         NUMBER;
--        vsproduc        NUMBER;
      vsituac        NUMBER;
      vreteni        NUMBER;
      vsuplem        NUMBER;
      vfefecto       DATE;
      vmovseg        NUMBER;
      vfecha         DATE;
      v_dif_anu      DATE;
      v_dias_anul_antes NUMBER;
      v_sproduc      NUMBER;
   BEGIN
      --Comprovació de paràmetres d'entrada
      IF psseguro IS NULL
         OR pccauanul IS NULL
         OR precextrn IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;

      BEGIN
         SELECT s.csituac, s.creteni
           INTO vsituac, vreteni
           FROM seguros s
          WHERE s.sseguro = psseguro;
      EXCEPTION
         WHEN OTHERS THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 103946);
            RAISE e_object_error;
      END;

      vpasexec := 5;

      IF vsituac <> 0 THEN
         IF vsituac IN(4, 5) THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 104257);
         ELSIF vsituac = 2 THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 101483);
         END IF;

         RAISE e_object_error;
      END IF;

      vpasexec := 7;

      -- ini BUG 20664 - MDS - 26/01/2012
      -- modificar validación del campo vreteni
      -- IF vreteni = 1 THEN
      IF vreteni <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 103816);
         RAISE e_object_error;
      END IF;

      vpasexec := 9;

      BEGIN
         SELECT   MAX(m.fefecto), s.nsuplem
             INTO vfefecto, vsuplem
             FROM movseguro m, seguros s
            WHERE m.cmovseg NOT IN(6, 52)
              AND m.sseguro = s.sseguro
              AND s.sseguro = psseguro
         GROUP BY s.sseguro, s.nsuplem;
      EXCEPTION
         WHEN OTHERS THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 104443);
            RAISE e_object_error;
      END;

      vpasexec := 11;

      BEGIN
         SELECT m.cmovseg
           INTO vmovseg
           FROM movseguro m
          WHERE m.sseguro = psseguro
            AND m.cmovseg NOT IN(6, 52)
            AND m.nmovimi IN(SELECT MAX(m2.nmovimi)
                               FROM movseguro m2
                              WHERE m2.sseguro = psseguro
                                AND m2.cmovseg NOT IN(6, 52));
      EXCEPTION
         WHEN OTHERS THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 104443);
            RAISE e_object_error;
      END;

      vpasexec := 13;

      IF f_bloquea_pignorada(psseguro, f_sysdate) <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 152213);
         RAISE e_object_error;
      END IF;

      vpasexec := 15;
      -- BUG 8850 - 8850 - DCM ¿ Tratamiento tipo de anulacion fecha de proxima cartera
      vfecha := f_get_fanulac(psseguro, pctipanul, mensajes);

      -- INI BUG   22500  13/06/2012  ETM
      BEGIN
         SELECT sproduc
           INTO v_sproduc
           FROM seguros
          WHERE sseguro = psseguro;
      EXCEPTION
         WHEN OTHERS THEN
            v_sproduc := 0;
      END;

      IF pctipanul IS NOT NULL THEN
         v_dias_anul_antes := NVL(f_parproductos_v(v_sproduc, 'DIAS_ANUL_ANTES_VTO'), 0);

         IF v_dias_anul_antes <> 0 THEN
            v_dif_anu := vfecha - v_dias_anul_antes;

            IF TRUNC(f_sysdate) >= v_dif_anu THEN
               pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9903803);
               RAISE e_object_error;
            END IF;
         END IF;
      END IF;

      -- FIN BUG 22500-- 13/06/2012 -- ETM

      --Programació de l'anul·lació de la pòlissa a la propera renovació (3) o en cartera (pctipanul=2)
      IF pctipanul = 3 THEN
         vnumerr := pac_anulacion.f_anula_poliza_vto(psseguro, pccauanul, f_sysdate, 221,
                                                     NULL, vfecha);
      ELSIF pctipanul = 2 THEN
         vnumerr := pac_anulacion.f_anula_poliza_vto(psseguro, pccauanul, f_sysdate, 236,
                                                     NULL, vfecha);
      END IF;

      -- FI BUG 8850 - 8850 - DCM ¿ Tratamiento tipo de anulacion fecha de proxima cartera
      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_anulacion_vto;

   --BUG 9914 - JTS - 20/05/2009
   /*************************************************************************
      FUNCTION f_get_reccobrados
      param in psseguro  : Num. seguro
      param in pfanulac  : Fecha de anulacion
      param out pcursor  : sys_refcursor
      param out mensajes : t_iax_mensajes
      return             : 0.- OK, 1.- KO
   *************************************************************************/
   FUNCTION f_get_reccobrados(
      psseguro IN NUMBER,
      pfanulac IN DATE,
      pcursor OUT sys_refcursor,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_MD_ANULACIONES.f_get_reccobrados';
      vparam         VARCHAR2(500)
                       := 'parámetros - psseguro: ' || psseguro || ' - pfanulac: ' || pfanulac;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vadmite        NUMBER;   -- Bug 23817 - APD - 10/10/2012
      vexiste        NUMBER;   -- Bug 23817 - APD - 10/10/2012
      vsproduc       seguros.sproduc%TYPE;   -- Bug 23817 - APD - 10/10/2012
      vbajacol       NUMBER;   -- Bug 23817 - APD - 10/10/2012
   BEGIN
      IF psseguro IS NULL
         OR pfanulac IS NULL THEN
         RAISE e_param_error;
      END IF;

      SELECT sproduc
        INTO vsproduc
        FROM seguros
       WHERE sseguro = psseguro;

      vadmite := NVL(f_parproductos_v(vsproduc, 'ADMITE_CERTIFICADOS'), 0);
      vexiste := pac_seguros.f_get_escertifcero(NULL, psseguro);

      -- si el producto admite certificados
      -- y estamos en un certificado 0
      IF vadmite = 1
         AND vexiste = 1 THEN
         vbajacol := 1;
      ELSE
         vbajacol := 0;
      END IF;

      vpasexec := 2;
      pcursor := pac_anulacion.f_recibos(psseguro, pfanulac, 1, pac_md_common.f_get_cxtidioma,
                                         vnumerr, 1, vbajacol);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      vpasexec := 3;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_get_reccobrados;

   /*************************************************************************
      FUNCTION f_get_recpendientes
      param in psseguro  : Num. seguro
      param in pfanulac  : Fecha de anulacion
      param out pcursor  : sys_refcursor
      param out mensajes : t_iax_mensajes
      return             : 0.- OK, 1.- KO
   *************************************************************************/
   FUNCTION f_get_recpendientes(
      psseguro IN NUMBER,
      pfanulac IN DATE,
      pcursor OUT sys_refcursor,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_MD_ANULACIONES.f_get_recpendientes';
      vparam         VARCHAR2(500)
                       := 'parámetros - psseguro: ' || psseguro || ' - pfanulac: ' || pfanulac;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vadmite        NUMBER;   -- Bug 23817 - APD - 10/10/2012
      vexiste        NUMBER;   -- Bug 23817 - APD - 10/10/2012
      vsproduc       seguros.sproduc%TYPE;   -- Bug 23817 - APD - 10/10/2012
      vbajacol       NUMBER;   -- Bug 23817 - APD - 10/10/2012
   BEGIN
      IF psseguro IS NULL
         OR pfanulac IS NULL THEN
         RAISE e_param_error;
      END IF;

      SELECT sproduc
        INTO vsproduc
        FROM seguros
       WHERE sseguro = psseguro;

      vadmite := NVL(f_parproductos_v(vsproduc, 'ADMITE_CERTIFICADOS'), 0);
      vexiste := pac_seguros.f_get_escertifcero(NULL, psseguro);

      -- si el producto admite certificados
      -- y estamos en un certificado 0
      IF vadmite = 1
         AND vexiste = 1 THEN
         vbajacol := 1;
      ELSE
         vbajacol := 0;
      END IF;

      vpasexec := 2;
      pcursor := pac_anulacion.f_recibos(psseguro, pfanulac, 0, pac_md_common.f_get_cxtidioma,
                                         vnumerr, 1, vbajacol);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      vpasexec := 3;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_get_recpendientes;

    /*************************************************************************
     Valida si es pot anular la pólissa a aquella data
     Paràmetres entrada:
        psSeguro : Identificador de l'assegurança   (obligatori)
        pFAnulac : Data d'anulació de la pòlissa    (obligatori)
        pValparcial : Valida parcialmente              (opcional)
                      1 posició = 0 o 1
                      2 posició = 1 no valida dies anulació (11)
                      3 posició = 1 ...
    Torna :
        0 si es permet anular la pòlissa, 1 KO
   **************************************************************************/
   FUNCTION f_val_fanulac(
      psseguro IN NUMBER,
      pfanulac IN DATE,
      pvalparcial IN NUMBER DEFAULT 0,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_MD_ANULACIONES.f_val_fanulac';
      vparam         VARCHAR2(500)
                       := 'parámetros - psseguro: ' || psseguro || ' - pfanulac: ' || pfanulac;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      IF psseguro IS NULL
         OR pfanulac IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      vnumerr := pac_anulacion.f_valida_permite_anular_poliza(psseguro, pfanulac, 11);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      vpasexec := 3;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_val_fanulac;

--Fi BUG 9914 - JTS - 20/05/2009

   --ini BUG10772-22/07/2009-JMF: CRE - Desanul·lar programacions al venciment/propera cartera
   /***********************************************************************
      Comprobar si es posible desanular una póliza.
      param out mensajes : mensajes de error
      param in seguro
      return             : 0.- no se puede desanular pero si anular
                           1.- se puede desanular
                           n.- error
   ***********************************************************************/
   FUNCTION f_es_desanulable(psseguro IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_MD_ANULACIONES.f_es_desanulable';
      vparam         VARCHAR2(500) := 'parámetros - psseguro: ' || psseguro;
      n_ret          NUMBER;
      vpasexec       NUMBER(5) := 1;
   BEGIN
      --Comprovació de paràmetres d'entrada
      vpasexec := 1;

      IF psseguro IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      n_ret := pac_anulacion.f_es_desanulable(psseguro);
      RETURN n_ret;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1000005;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1000001;
   END f_es_desanulable;

   --fin BUG10772-22/07/2009-JMF: CRE - Desanul·lar programacions al venciment/propera cartera

   --ini BUG10772-22/07/2009-JMF: CRE - Desanul·lar programacions al venciment/propera cartera
   /***********************************************************************
      Realizar la desanulación de una póliza.
      param out mensajes : mensajes de error
      param in seguro, fecha anulación, motivo
      return             : 0.- proceso correcto
                           1.- error
   ***********************************************************************/
   FUNCTION f_desanula_poliza_vto(
      psseguro IN NUMBER,
      pfanulac IN DATE,
      pnsuplem IN NUMBER DEFAULT NULL,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_MD_ANULACIONES.f_desanula_poliza_vto';
      vparam         VARCHAR2(500) := 'parámetros - psseguro: ' || psseguro;
      n_numerr       NUMBER;
      vpasexec       NUMBER(5) := 1;
      -- BUG 20664 - MDS - 27/01/2012 : añadir variables
      vsituac        NUMBER;
      vreteni        NUMBER;
   BEGIN
      --Comprovació de paràmetres d'entrada
      vpasexec := 1;

      IF psseguro IS NULL
         OR pfanulac IS NULL THEN
         RAISE e_param_error;
      END IF;

      -- ini BUG 20664 - MDS - 27/01/2012
      -- añadir validaciones
      vpasexec := 2;

      BEGIN
         SELECT s.csituac, s.creteni
           INTO vsituac, vreteni
           FROM seguros s
          WHERE s.sseguro = psseguro;
      EXCEPTION
         WHEN OTHERS THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 103946);
            RAISE e_object_error;
      END;

      vpasexec := 3;

      IF vsituac <> 0 THEN
         IF vsituac IN(4, 5) THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 104257);
         ELSIF vsituac = 2 THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 101483);
         END IF;

         RAISE e_object_error;
      END IF;

      vpasexec := 4;

      IF vreteni <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 103816);
         RAISE e_object_error;
      END IF;

      vpasexec := 5;
      -- fin BUG 20664 - MDS - 27/01/2012
      n_numerr := pac_anulacion.f_desanula_poliza_vto(psseguro, pfanulac, pnsuplem);

      IF n_numerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, n_numerr);
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_desanula_poliza_vto;

--fin BUG10772-22/07/2009-JMF: CRE - Desanul·lar programacions al venciment/propera cartera

   --Ini Bug.: 16775 - ICV - 30/11/2010
   /***********************************************************************
      Función que realiza una solicitud de Anulación.
      param in psseguro  : código de seguro
      param in pctipanul  : tipo anulación
      param in pnriesgo  : número de riesgo
      param in pfanulac  : fecha anulación
      param in ptobserv  : Observaciones.
      param in pTVALORD  : Descripción del motivio.
      param in pcmotmov  : Causa anulacion.
      param out mensajes : mensajes de error
      return             : 0.- proceso correcto
                           1.- error
   ***********************************************************************/
   FUNCTION f_set_solanulac(
      psseguro IN NUMBER,
      pctipanul IN NUMBER,
      pnriesgo IN NUMBER,
      pfanulac IN DATE,
      ptobserv IN VARCHAR2,
      ptvalord IN VARCHAR2,
      pcmotmov IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_MD_ANULACIONES.f_set_solanulac';
      vparam         VARCHAR2(500)
         := 'parámetros - psseguro: ' || psseguro || ' - pctipanul: ' || pctipanul
            || ' - pnriesgo: ' || pnriesgo || ' - pfanulac: ' || pfanulac || ' - ptobserv: '
            || ptobserv || ' - pTVALORD: ' || ptvalord;
      num_err        NUMBER;
      vpasexec       NUMBER(5) := 1;
   BEGIN
      --Comprovació de paràmetres d'entrada
      vpasexec := 1;

      IF psseguro IS NULL
         OR pfanulac IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      --BUG 18193 - 20/04/2011 - JRB - Se añade motivo anulacion.
      num_err := pac_anulacion.f_set_solanulac(psseguro, pctipanul, pnriesgo, pfanulac,
                                               ptobserv, ptvalord, pcmotmov);

      IF num_err <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, num_err);
         RAISE e_object_error;
      ELSE
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, 9901729);
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_set_solanulac;

   /***********************************************************************
     Funcion para determinar si se debe mostrar o no el check Anulacion a corto plazo
    1.   psproduc: Identificador del producto (IN)
    2.   pcmotmov: Motivo de movimiento (IN)
    3.   psseguro: Identificador de la poliza (IN)
    4.   pcvisible: Devuelve 0 si no es visible, 1 si si es visible (OUT)
      return             : NUMBER (0 --> OK)
   ***********************************************************************/
   -- Bug 22826 - APD - 12/07/2012- se crea la funcion
   -- Bug 23817 - APD - 04/10/2012 - se añade el parametro psseguro
   FUNCTION f_aplica_penali_visible(
      psproduc IN NUMBER,
      pcmotmov IN NUMBER,
      psseguro IN NUMBER,
      pcvisible OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_MD_ANULACIONES.f_aplica_penali_visible';
      vparam         VARCHAR2(4000)
         := 'psproduc = ' || psproduc || ' - pcmotmov = ' || pcmotmov || ' - psseguro = '
            || psseguro;
      n_numerr       NUMBER;
      vpasexec       NUMBER(5) := 1;
      -- BUG 20664 - MDS - 27/01/2012 : añadir variables
      vsituac        NUMBER;
      vreteni        NUMBER;
   BEGIN
      n_numerr := pac_anulacion.f_aplica_penali_visible(psproduc, pcmotmov, psseguro,
                                                        pcvisible);

      IF n_numerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, n_numerr);
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_aplica_penali_visible;
END pac_md_anulaciones;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_ANULACIONES" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_ANULACIONES" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_ANULACIONES" TO "PROGRAMADORESCSI";
