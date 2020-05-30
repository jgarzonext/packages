--------------------------------------------------------
--  DDL for Package Body PAC_MD_MANDATOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_MD_MANDATOS" IS
/*
   REVISIONES:
   Ver       Fecha          Autor           Descripci¿n
   -------  ---------       ------          ------------------------------------
   2.0      25/08/2016      JAVENDANO       CONF-236: Par¿metros fecha de archivado, eliminaci¿n y caducidad de los documentos
*/

      /*******************************************************************************
    FUNCION f_consulta_mandatos
         -- Descripcion
   Par¿metros:
    Entrada :


     Retorna un valor num¿rico: 0 si ha grabado el mandato y 1 si se ha producido alg¿n error.

   */
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

   FUNCTION f_consulta_mandatos(
      pnnumide IN VARCHAR2 DEFAULT NULL,
      pnombre IN VARCHAR2 DEFAULT NULL,
      pdeudormandante IN NUMBER DEFAULT NULL,
      pfvencimiento IN VARCHAR2 DEFAULT NULL,
      pformapago IN NUMBER DEFAULT NULL,
      pcbanco IN NUMBER DEFAULT NULL,
      pcbancar IN VARCHAR2 DEFAULT NULL,
      ptipotarjeta IN NUMBER DEFAULT NULL,
      pnumtarjeta IN VARCHAR2 DEFAULT NULL,
      pinstemisora IN NUMBER DEFAULT NULL,
      pmandato IN NUMBER DEFAULT NULL,
      paccion IN NUMBER DEFAULT NULL,
      psucursal IN VARCHAR2 DEFAULT NULL,
      pestado IN NUMBER DEFAULT NULL,
      pconsulta IN NUMBER DEFAULT NULL)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vwhere         VARCHAR2(4000) := '';
      v_select       VARCHAR2(5000);
      vcondicion_dat_banc VARCHAR2(1000) := '';
      condicion_dat_pers VARCHAR2(1000) := '';
      auxnom         VARCHAR2(200);
      vparam         VARCHAR2(2000)
         := 'pnnumide= ' || pnnumide || 'pnombre= ' || pnombre || 'pdeudormandante= '
            || pdeudormandante || 'pfvencimiento= ' || pfvencimiento || ', pformapago= '
            || pformapago || ',pcbanco= ' || pcbanco || ', pcbancar= ' || pcbancar
            || ', ptipotarjeta= ' || ptipotarjeta || ', pnumtarjeta= ' || pnumtarjeta
            || ', pinstemisora= ' || pinstemisora || ', pmandato= ' || pmandato
            || ', paccion= ' || paccion || ', psucursal= ' || psucursal || ', pestado= '
            || pestado || ', pconsulta= ' || pconsulta;
      vobject        VARCHAR2(200) := 'f_consulta_mandatos';
      vnumerr        NUMBER := 0;
      terror         VARCHAR2(200) := 'Error recuperar mandatos';
      vpasexec       NUMBER;
      nerr           NUMBER;
      tabtp          VARCHAR2(100) := '';
      v_max_reg      NUMBER;   -- n¿mero m¿xim de registres mostrats
      mensajes       t_iax_mensajes;
      vcbancar       VARCHAR2(200) := '';
      vnumtarjeta    VARCHAR2(200) := '';
   BEGIN
      vpasexec := 10;

      IF pnnumide IS NOT NULL
         OR pnombre IS NOT NULL THEN
         IF pnnumide IS NOT NULL THEN
            --21/05/2015 CJMR  Bug 35888/205345 Realizar la substituci¿n del upper nnumide D02 A01
              --condicion_dat_pers := condicion_dat_pers || ' AND upper(pp.nnumide) = upper('
              --                      || CHR(39) || pnnumide || CHR(39) || ')';
            --Bug 371152-21271 Busqueda de NIF minuscula KJSC 26/08/2015
            IF NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa(),
                                                 'NIF_MINUSCULAS'),
                   0) = 1 THEN
               condicion_dat_pers := condicion_dat_pers || ' AND UPPER(pp.nnumide) = UPPER('''
                                     || pnnumide || ''')';
            ELSE
               condicion_dat_pers := condicion_dat_pers || ' AND pp.nnumide = ' || CHR(39)
                                     || pnnumide || CHR(39);
            END IF;
         END IF;

         IF pnombre IS NOT NULL THEN
            nerr := f_strstd(pnombre, auxnom);
            condicion_dat_pers := condicion_dat_pers || ' AND upper ( replace ( p.tbuscar, '
                                  || CHR(39) || '  ' || CHR(39) || ',' || CHR(39) || ' '
                                  || CHR(39) || ' )) like upper(''%' || auxnom || '%'
                                  || CHR(39) || ')';
         END IF;

         vpasexec := 30;

         IF pdeudormandante IS NOT NULL THEN
            IF pdeudormandante = 1 THEN   -- DEUDOR
               vwhere :=
                  vwhere
                  || '  AND EXISTS (SELECT 1 FROM  per_detper p, per_personas pp WHERE pp.sperson = p.sperson  AND pp.sperson = tom.sperson '
                  || condicion_dat_pers || ')';
            ELSIF pdeudormandante = 2 THEN   -- MANDANTE
               vwhere :=
                  vwhere
                  || '  AND EXISTS (SELECT 1 FROM  per_detper p, per_personas pp WHERE pp.sperson = p.sperson AND pp.sperson = ma.sperson '
                  || condicion_dat_pers || ')';
            END IF;
         END IF;
      END IF;

      vpasexec := 40;
      vcondicion_dat_banc :=
         ' AND EXISTS  ( SELECT 1 FROM tipos_cuenta tip, mandatos man where tip.ctipban = man.ctipban AND man.ctipban= ma.ctipban ';

      IF pformapago IS NOT NULL THEN
         vwhere := vwhere || ' AND ma.ccobban = ' || pformapago;
      END IF;

      vpasexec := 50;

      IF pcbanco IS NOT NULL
         OR pcbancar IS NOT NULL THEN
         vwhere := vwhere || vcondicion_dat_banc;

         IF pcbanco IS NOT NULL THEN   --banco
            -- Si se selecciona el banco, ha de venir filtrado por la forma de pago
            vwhere := vwhere || ' AND ' || pcbanco
                      || ' = TO_NUMBER(SUBSTR(ma.cbancar, tip.pos_entidad, tip.long_entidad))';
         END IF;

         IF pcbancar IS NOT NULL THEN
            vcbancar := REPLACE(pcbancar, '-', '');
            vwhere := vwhere || ' AND ' || CHR(39) || vcbancar || CHR(39)
                      || ' = SUBSTR( ma.cbancar,tip.pos_entidad + tip.long_entidad) ';
         END IF;

         vwhere := vwhere || ')';
      END IF;

      IF pinstemisora IS NOT NULL
         OR ptipotarjeta IS NOT NULL
         OR pnumtarjeta IS NOT NULL THEN
         vwhere := vwhere || vcondicion_dat_banc;

         IF pinstemisora IS NOT NULL THEN   --banco
            -- Si se selecciona el banco, ha de venir filtrado por la forma de pago
            vwhere := vwhere || ' AND ' || CHR(39) || LPAD(pinstemisora, 4, '0') || CHR(39)
                      || ' = SUBSTR(ma.cbancar, tip.pos_entidad, tip.long_entidad)';
         END IF;

         IF ptipotarjeta IS NOT NULL THEN
            vwhere := vwhere || ' AND tip.ctipcc =' || ptipotarjeta;
         END IF;

         IF pnumtarjeta IS NOT NULL THEN
            vnumtarjeta := REPLACE(pnumtarjeta, '-', '');
            vwhere := vwhere || ' AND ' || CHR(39) || vnumtarjeta || CHR(39)
                      || ' = SUBSTR( ma.cbancar,tip.pos_entidad + tip.long_entidad) ';
         END IF;

         vwhere := vwhere || ')';
      END IF;

      IF pfvencimiento IS NOT NULL THEN
         vwhere := vwhere || ' and to_char(ma.fvencim,''MMYYYY'') = to_char(to_date('
                   || CHR(39) || pfvencimiento || CHR(39) || ', ''DD/MM/YYYY''),''MMYYYY'')';
      END IF;

      vpasexec := 60;

      IF pmandato IS NOT NULL THEN
         -- NUMERO DE FOLIO
         vwhere := vwhere || ' AND ms.numfolio = ' || pmandato;
      END IF;

      IF psucursal IS NOT NULL THEN
         vwhere := vwhere || ' AND ms.sucursal = ' || CHR(39) || psucursal || CHR(39);
      END IF;

      IF paccion IS NOT NULL THEN
         tabtp := tabtp || ' , mandatos_gestion mg ';
         vwhere := vwhere || '  AND mg.numfolio = ms.numfolio '
                   || '  AND mg.caviso = (SELECT MAX(mg2.caviso) '
                   || '                   FROM mandatos_gestion mg2 '
                   || '                   WHERE mg2.numfolio = mg.numfolio)'
                   || '  AND mg.accion = ' || paccion;
      END IF;

      IF pestado IS NOT NULL THEN
         tabtp := tabtp || ' , mandatos_estados me ';
         vwhere := vwhere || '  AND me.numfolio = ms.numfolio '
                   || '  AND me.fechaestado = (SELECT MAX(me2.fechaestado) '
                   || '                   FROM mandatos_estados me2 '
                   || '                   WHERE me2.numfolio = me.numfolio)'
                   || '  AND me.cestado = ' || pestado;
      END IF;

      IF pconsulta IS NOT NULL THEN
         -- INICIO Bug 0032654 MMS 20150115
         IF NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa, 'ROL_MANDATO'),
                0) = 1 THEN
            IF pconsulta = 0
               AND(pac_mandatos.f_getrolusuari(f_user) IS NULL
                   OR pac_mandatos.f_getrolusuari(f_user) NOT IN
                                                ('CENTRAL', 'MENU_TOTAL', 'OPE_GER', 'OPE_JPO')) THEN   --Viene de la pantalla GESTION y el usuario no es servicios centrales
               vwhere := vwhere || ' and ms.cusualtarel =' || CHR(39) || f_user || CHR(39);
            END IF;
         ELSE   -- FIN Bug 0032654 MMS 20150115
            IF pconsulta = 0
               AND(pac_mandatos.f_getrolusuari(f_user) IS NULL
                   OR pac_mandatos.f_getrolusuari(f_user) <> 'CENTRAL') THEN   --Viene de la pantalla GESTION y el usuario no es servicios centrales
               vwhere := vwhere || ' and ms.cusualtarel =' || CHR(39) || f_user || CHR(39);
            END IF;
         END IF;
      END IF;

      vpasexec := 70;
      v_select :=
         ' SELECT  ma.cmandato codmandato, ms.numfolio numerofolio,trunc(ma.ffirma) fechamandato, trunc(ms.ffinvig) ffinvig, pac_mandatos.f_get_rut(tom.sperson) rutdeudor,
             pac_mandatos.f_get_rut(ma.sperson)  rutmandante,  pac_mandatos.f_get_nombre(ms.sseguro, tom.sperson)  nombredeudor,
             pac_mandatos.f_get_nombre(ms.sseguro, ma.sperson)  nombremandante,  pac_mandatos.f_get_contactos(ms.sseguro, ma.sperson) telefonos,
             ma.ccobban cobradorbanc, pac_mandatos.f_desccobradorbanc(ma.ccobban) formapago,
             pac_mandatos.f_codbanco(ma.cbancar, ma.ctipban) codigobanco, pac_mandatos.f_descbanco(ma.cbancar,  ma.ctipban) banco, ms.sucursal sucursal, pac_mandatos.f_getcuentabancformateada(ma.ctipban,ma.cbancar) cuentabancaria,
             DECODE(ma.ccobban, 1, pac_mandatos.f_codtipotarjeta(ma.ctipban), NULL) codtipotarjeta, DECODE(ma.ccobban, 1, pac_mandatos.f_desctipotarjeta(ma.ctipban), NULL) tipotarjeta, to_char(ma.fvencim,''MM/YYYY'')  fvencim,
             ff_desvalorfijo(487,pac_md_common.f_get_cxtidioma,pac_mandatos.f_getultaccionmandato(ms.numfolio)) accion, pac_mandatos.f_getultestadomandato(ms.numfolio) estado
             from mandatos ma, mandatos_seguros ms, tomadores tom '
         || tabtp
         || '
             WHERE ma.cmandato = ms.cmandato
             AND ms.nmovimi = (SELECT MIN(mands.nmovimi) FROM  mandatos_seguros mands where  cmandato= ms.cmandato and numfolio = ms.numfolio)
             AND ms.numfolio IS NOT NULL
             AND tom.sseguro = ms.sseguro
             AND tom.nordtom = (SELECT MIN(tomador.nordtom) FROM tomadores tomador WHERE tomador.sseguro = tom.sseguro) '
         || vwhere;
      v_max_reg := pac_parametros.f_parinstalacion_n('N_MAX_REG');
      v_select := v_select || ' AND ROWNUM <= ' || v_max_reg || ' ORDER BY ms.numfolio ASC';
      vpasexec := 80;
      vnumerr := pac_md_log.f_log_consultas(v_select, 'PAC_MD_MANDATOS.f_consulta_mandatos', 1,
                                            1, mensajes);
      p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, v_select);

      OPEN cur FOR v_select;

      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           terror, SQLCODE, SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_consulta_mandatos;

   FUNCTION f_consulta_mandatos_masiva(
      pestado IN NUMBER DEFAULT NULL,
      pnomina IN NUMBER DEFAULT NULL)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vwhere         VARCHAR2(4000) := '';
      v_select       VARCHAR2(5000);
      auxnom         VARCHAR2(200);
      vparam         VARCHAR2(2000) := 'pestado= ' || pestado || 'pnomina= ' || pnomina;
      vobject        VARCHAR2(200) := 'f_consulta_mandatos_masiva';
      vnumerr        NUMBER := 0;
      terror         VARCHAR2(200) := 'Error recuperar mandatos masiva';
      vpasexec       NUMBER;
      nerr           NUMBER;
      tabtp          VARCHAR2(100) := '';
      v_max_reg      NUMBER;   -- n¿mero m¿xim de registres mostrats
      v_nominaselec  NUMBER;
      mensajes       t_iax_mensajes;
   BEGIN
      vpasexec := 10;

      IF pestado IS NOT NULL THEN
         tabtp := tabtp || ' , mandatos_estados me ';
         vwhere := vwhere || ' AND me.numfolio = ms.numfolio ' || ' AND me.cestado = '
                   || pestado || ' AND me.fechaestado = (SELECT MAX(me2.fechaestado)'
                   || '                       FROM mandatos_estados me2'
                   || '                       WHERE  me2.numfolio = me.numfolio) ';
      END IF;

      vpasexec := 20;

      IF pnomina IS NOT NULL THEN
         tabtp := tabtp || ' , mandatos_masiva mas ';
         vwhere := vwhere || ' AND mas.numfolio = ms.numfolio  AND mas.nomina = ' || pnomina;
         v_nominaselec := pnomina;
      ELSE
         v_nominaselec := 0;
      END IF;

      -- INICIO Bug 0032654 MMS 20150115
      IF NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa, 'ROL_MANDATO'), 0) =
                                                                                              1 THEN
         IF pac_mandatos.f_getrolusuari(f_user) IS NULL
            OR pac_mandatos.f_getrolusuari(f_user) NOT IN
                                                ('CENTRAL', 'MENU_TOTAL', 'OPE_GER', 'OPE_JPO') THEN   -- el usuario es diferente a servicios centrales
            vwhere := vwhere || ' and ms.cusualtarel =' || CHR(39) || f_user || CHR(39);
         END IF;
      ELSE   -- FIN Bug 0032654 MMS 20150115
         IF pac_mandatos.f_getrolusuari(f_user) IS NULL
            OR pac_mandatos.f_getrolusuari(f_user) <> 'CENTRAL' THEN   -- el usuario es diferente a servicios centrales
            vwhere := vwhere || ' and ms.cusualtarel =' || CHR(39) || f_user || CHR(39);
         END IF;
      END IF;

      vpasexec := 30;
      v_select :=
         ' SELECT  ms.numfolio numerofolio, pac_mandatos.f_getcodultestadomandato(ms.numfolio) situacion, ff_desvalorfijo(489,pac_md_common.f_get_cxtidioma,pac_mandatos.f_getcodultestadomandato(ms.numfolio)) situaciondesc,
             pac_mandatos.f_get_rut(tom.sperson) rutdeudor,
             pac_mandatos.f_get_rut(ma.sperson)  rutmandante,
             ma.ccobban cobradorbanc, pac_mandatos.f_desccobradorbanc(ma.ccobban) formapago,
             pac_mandatos.f_descbanco(ma.cbancar,  ma.ctipban) banco, ms.sucursal sucursal, pac_mandatos.f_getcuentabancformateada(ma.ctipban,ma.cbancar) cuentabancaria,
             DECODE(ma.ccobban, 1, pac_mandatos.f_desctipotarjeta(ma.ctipban), NULL) tipotarjeta, pac_mandatos.f_getult_nomina(ms.numfolio) ultnomina,
             DECODE(pac_mandatos.f_getcodultestadomandato(ms.numfolio),3,0,pac_mandatos.f_mandato_editable('
         || v_nominaselec
         || ',nvl(pac_mandatos.f_getult_nomina(ms.numfolio),0), pac_mandatos.f_getcodultestadomandato(ms.numfolio) )) editable
             from mandatos ma, mandatos_seguros ms, tomadores tom '
         || tabtp
         || '
             WHERE  ma.cmandato = ms.cmandato
             AND ms.nmovimi = (SELECT MIN(mands.nmovimi) FROM  mandatos_seguros mands where  cmandato= ms.cmandato and numfolio = ms.numfolio)
             AND ms.numfolio IS NOT NULL
             AND tom.sseguro = ms.sseguro
             AND tom.nordtom = (SELECT MIN(tomador.nordtom) FROM tomadores tomador WHERE tomador.sseguro = tom.sseguro) '
         || vwhere;
      v_max_reg := pac_parametros.f_parinstalacion_n('N_MAX_REG');
      v_select := v_select || ' AND ROWNUM <= ' || v_max_reg || ' ORDER BY ms.numfolio ASC';
      vpasexec := 40;
      vnumerr := pac_md_log.f_log_consultas(v_select, 'PAC_MD_MANDATOS.f_consulta_mandatos', 1,
                                            1, mensajes);
      p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, v_select);

      OPEN cur FOR v_select;

      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           terror, SQLCODE, SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_consulta_mandatos_masiva;

   FUNCTION f_set_mandatos_gestion(
      pnumfolio IN mandatos_gestion.numfolio%TYPE,
      paccion IN mandatos_gestion.accion%TYPE,
      pfproxaviso IN mandatos_gestion.fproxaviso%TYPE,
      pmotrechazo IN mandatos_gestion.motrechazo%TYPE DEFAULT NULL,
      pcomentario IN mandatos_gestion.comentario%TYPE DEFAULT NULL,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vcestado       mandatos.cestado%TYPE;
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vobject        VARCHAR2(200) := 'PAC_MD_MANDATOS.f_set_mandatos_gestion';
      vparam         VARCHAR2(4000)
         := 'pnumfolio = ' || pnumfolio || 'paccion = ' || paccion || 'pfproxaviso = '
            || pfproxaviso || 'pmotrechazo = ' || pmotrechazo || 'pcomentario = '
            || pcomentario;
   BEGIN
      vpasexec := 10;
      vnumerr := pac_mandatos.f_set_mandatos_gestion(pnumfolio, paccion, pfproxaviso,
                                                     pmotrechazo, pcomentario);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      -- Acciones manuales,
      IF paccion = 0 THEN   --Accion Env¿o a casa matriz
         vcestado := 7;   -- Estado Env¿o a casa matriz
      ELSIF paccion = 1 THEN   --Accion Custodia
         vcestado := 8;   -- Estado Custodia
      ELSIF paccion = 2 THEN   --Accion En tr¿nsito
         vcestado := 3;   --Estado En tr¿nsito
      ELSIF paccion = 8 THEN   -- Accion Anular
         vcestado := 2;   --Estado Anulado
      -- ELSIF paccion = 9 THEN   -- Accion Rechaxo
       --   vcestado := 4;   --Estado Rechazado
      END IF;

      IF vcestado IS NOT NULL THEN
         vnumerr := pac_mandatos.f_set_estado_mandato(pnumfolio, vcestado);

         IF vnumerr <> 0 THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
            RAISE e_object_error;
         END IF;
      END IF;

      vpasexec := 20;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_set_mandatos_gestion;

   FUNCTION f_get_lstacciones_mandato(
      pnumfolio IN mandatos_estados.numfolio%TYPE,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vcondicion     VARCHAR2(1000);
      vparam         VARCHAR2(2000) := 'pnumfolio= ' || pnumfolio;
      vobject        VARCHAR2(200) := 'PAC_MD_MANDATOS.f_get_lstacciones_mandato';
      vpasexec       NUMBER;
      vestado        mandatos_estados.cestado%TYPE;
   BEGIN
      vpasexec := 10;

      SELECT cestado
        INTO vestado
        FROM mandatos_estados
       WHERE numfolio = pnumfolio
         AND fechaestado = (SELECT MAX(fechaestado)
                              FROM mandatos_estados
                             WHERE numfolio = pnumfolio);

      vpasexec := 20;

      -- INICIO bug 32676 MMS 20150115
      IF NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa, 'ROL_MANDATO'), 0) =
                                                                                              1 THEN
         IF vestado = 6 THEN   --Estado Pendiente (sucursal)
            --1 custodia depende del usuario conectado
            IF pac_mandatos.f_getrolusuari(f_user) IN
                                               ('CENTRAL', 'MENU_TOTAL', 'OPE_GER', 'OPE_JPO') THEN   -- si es servicios centrales
               vcondicion := ' catribu in (3,4,5,6,7,8)';
            ELSE   -- si es oficina
               vcondicion := ' catribu in (0,3,4,5,6,7,8)';
            END IF;
         ELSIF vestado = 0 THEN   --Estado Pendiente(casa matriz)
            --1 custodia depende del usuario conectado
            IF pac_mandatos.f_getrolusuari(f_user) IN
                                               ('CENTRAL', 'MENU_TOTAL', 'OPE_GER', 'OPE_JPO') THEN   -- si es servicios centrales
               vcondicion := ' catribu in (1,3,4,5,6,7,8)';
            ELSE   -- si es oficina
               vcondicion := ' catribu in (3,4,5,6,7,8)';
            END IF;
         ELSIF vestado = 7 THEN   --Envio casa matriz
            IF pac_mandatos.f_getrolusuari(f_user) IN
                                               ('CENTRAL', 'MENU_TOTAL', 'OPE_GER', 'OPE_JPO') THEN   -- si es servicios centrales
               vcondicion := ' catribu in (1,3,5,6,7,8)';
            ELSE   -- si es oficina
               vcondicion := ' catribu in (3,5,6,7,8)';
            END IF;
         ELSIF vestado = 8 THEN   --Estado es custodia
            IF pac_mandatos.f_getrolusuari(f_user) IN
                                               ('CENTRAL', 'MENU_TOTAL', 'OPE_GER', 'OPE_JPO') THEN   -- si es servicios centrales
               vcondicion := ' catribu in (2,3,4,5,6,7,8)';
            ELSE   -- si es oficina
               vcondicion := ' catribu in (3,4,5,6,7,8)';
            END IF;
         ELSIF vestado IN(3, 1) THEN   --Estado es transito o aprobado
            vcondicion := ' catribu in (3,8)';
         ELSIF vestado IN(2, 4) THEN   --Estado anulado o rechazado
            vcondicion := ' catribu = 3';
         END IF;
      -- FIN bug 32676 MMS 20150115
      ELSE
         IF vestado = 6 THEN   --Estado Pendiente (sucursal)
            --1 custodia depende del usuario conectado
            IF pac_mandatos.f_getrolusuari(f_user) = 'CENTRAL' THEN   -- si es servicios centrales
               vcondicion := ' catribu in (3,4,5,6,7,8)';
            ELSE   -- si es oficina
               vcondicion := ' catribu in (0,3,4,5,6,7,8)';
            END IF;
         ELSIF vestado = 0 THEN   --Estado Pendiente(casa matriz)
            --1 custodia depende del usuario conectado
            IF pac_mandatos.f_getrolusuari(f_user) = 'CENTRAL' THEN   -- si es servicios centrales
               vcondicion := ' catribu in (1,3,4,5,6,7,8)';
            ELSE   -- si es oficina
               vcondicion := ' catribu in (3,4,5,6,7,8)';
            END IF;
         ELSIF vestado = 7 THEN   --Envio casa matriz
            IF pac_mandatos.f_getrolusuari(f_user) = 'CENTRAL' THEN   -- si es servicios centrales
               vcondicion := ' catribu in (1,3,5,6,7,8)';
            ELSE   -- si es oficina
               vcondicion := ' catribu in (3,5,6,7,8)';
            END IF;
         ELSIF vestado = 8 THEN   --Estado es custodia
            IF pac_mandatos.f_getrolusuari(f_user) = 'CENTRAL' THEN   -- si es servicios centrales
               vcondicion := ' catribu in (2,3,4,5,6,7,8)';
            ELSE   -- si es oficina
               vcondicion := ' catribu in (3,4,5,6,7,8)';
            END IF;
         ELSIF vestado IN(3, 1) THEN   --Estado es transito o aprobado
            vcondicion := ' catribu in (3,8)';
         ELSIF vestado IN(2, 4) THEN   --Estado anulado o rechazado
            vcondicion := ' catribu = 3';
         END IF;
      END IF;

      cur := pac_md_listvalores.f_detvalorescond(487, vcondicion, mensajes);
      vpasexec := 50;
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstacciones_mandato;

   FUNCTION f_get_lstestados_mandmasiva(mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vcondicion     VARCHAR2(1000);
      vparam         VARCHAR2(2000);
      vobject        VARCHAR2(200) := 'PAC_MD_MANDATOS.f_get_lstestados_mandmasiva';
      vpasexec       NUMBER;
      vestado        mandatos_estados.cestado%TYPE;
   BEGIN
      vpasexec := 10;

      --Pendiente de mirar el perfil de usuario que se ha conectado, para sacar unos estados u otros
      -- Perfil sucursal --> Pendiente sucursal
      -- Perfil mandatos --> Envio casa matriz, Custodia

      -- INICIO Bug 0032654 MMS 20150115
      IF NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa, 'ROL_MANDATO'), 0) =
                                                                                             1 THEN
         IF pac_mandatos.f_getrolusuari(f_user) IN
                                               ('CENTRAL', 'MENU_TOTAL', 'OPE_GER', 'OPE_JPO') THEN
            vcondicion := ' catribu in (7, 8)';
         ELSE
            vcondicion := ' catribu in (6)';
         END IF;
      ELSE   -- FIN Bug 0032654 MMS 20150115
         IF pac_mandatos.f_getrolusuari(f_user) = 'CENTRAL' THEN
            vcondicion := ' catribu in (7, 8)';
         ELSE
            vcondicion := ' catribu in (6)';
         END IF;
      END IF;

      cur := pac_md_listvalores.f_detvalorescond(489, vcondicion, mensajes);
      vpasexec := 50;
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstestados_mandmasiva;

   FUNCTION f_get_acciones_mandmasiva(
      pestado IN mandatos.cestado%TYPE,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vcondicion     VARCHAR2(1000);
      vparam         VARCHAR2(2000) := 'pestado= ' || pestado;
      vobject        VARCHAR2(200) := 'PAC_MD_MANDATOS.f_get_acciones_mandmasiva';
      vpasexec       NUMBER;
      vestado        mandatos_estados.cestado%TYPE;
   BEGIN
      vpasexec := 10;

      IF pestado = 6 THEN   --Estado Pendiente (sucursal)
         vcondicion := ' catribu = 0 ';   --  accion envio casa matriz
      ELSIF pestado = 7 THEN   --Envio casa matriz
         vcondicion := ' catribu = 1';
      ELSIF pestado = 8 THEN   --Estado es custodia
         vcondicion := ' catribu = 2';
      END IF;

      IF pestado IN(6, 7, 8) THEN
         cur := pac_md_listvalores.f_detvalorescond(487, vcondicion, mensajes);
      END IF;

      vpasexec := 50;
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_acciones_mandmasiva;

   FUNCTION f_getestadosmandato(
      pnumfolio IN mandatos_estados.numfolio%TYPE,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      v_select       VARCHAR2(1000);
      vparam         VARCHAR2(2000) := 'pnumfolio= ' || pnumfolio;
      vobject        VARCHAR2(200) := 'PAC_MD_MANDATOS.f_getestadosmandato';
      vpasexec       NUMBER := 10;
      terror         VARCHAR2(200) := 'Error recuperar estados mandatos';
   BEGIN
      v_select :=
         'SELECT ff_desvalorfijo(489,pac_md_common.f_get_cxtidioma,cestado) estado,
          decode(cestado, 2,ff_desvalorfijo(488,pac_md_common.f_get_cxtidioma,pac_mandatos.f_getmot_rechazo(numfolio)) ,NULL) subestado,
          fechaestado fechaestado, cusualta usuarioalta
                   FROM mandatos_estados
                   WHERE numfolio ='
         || pnumfolio || ' ORDER BY fechaestado DESC';
      vpasexec := 20;
      p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, v_select);

      OPEN cur FOR v_select;

      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           terror, SQLCODE, SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_getestadosmandato;

   FUNCTION f_getpolizasmandato(
      pnumfolio IN mandatos_seguros.numfolio%TYPE,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      v_select       VARCHAR2(1000);
      vparam         VARCHAR2(2000) := 'pnumfolio= ' || pnumfolio;
      vobject        VARCHAR2(200) := 'PAC_MD_MANDATOS.f_getpolizasmandato';
      vpasexec       NUMBER := 10;
      terror         VARCHAR2(200) := 'Error recuperar polizas mandatos';
   BEGIN
      v_select :=
         'SELECT ma.cmandato, ma.numfolio, nmovimi, seg.npoliza, seg.ncertif, ff_desvalorfijo(61, pac_md_common.f_get_cxtidioma, seg.csituac) estadopoliza,
             DECODE(fbajarel, null, f_axis_literales(9906712,pac_md_common.f_get_cxtidioma()),f_axis_literales(9906713,pac_md_common.f_get_cxtidioma())) estadomandato,
             faltarel fechasigna, cusualtarel usuasigna, fbajarel fechadesasigna, cusubajarel usudesasigna, pac_mandatos.f_get_nomina_mandato(ma.numfolio) nomina
          FROM mandatos_seguros ma, seguros seg
          WHERE ma.sseguro = seg.sseguro
          AND ma.numfolio =  '
         || pnumfolio || ' ORDER BY nmovimi DESC';
      vpasexec := 20;
      p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, v_select);

      OPEN cur FOR v_select;

      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           terror, SQLCODE, SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_getpolizasmandato;

   FUNCTION f_getgestionesmandato(
      pnumfolio IN mandatos_gestion.numfolio%TYPE,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      v_select       VARCHAR2(1000);
      vparam         VARCHAR2(2000) := 'pnumfolio= ' || pnumfolio;
      vobject        VARCHAR2(200) := 'PAC_MD_MANDATOS.f_getgestionesmandato';
      vpasexec       NUMBER := 10;
      terror         VARCHAR2(200) := 'Error recuperar gestiones mandato';
   BEGIN
      v_select :=
         'SELECT numfolio numfolio, faccion fechaaccion, ff_desvalorfijo(487,pac_md_common.f_get_cxtidioma,accion) descaccion,
                 ff_desvalorfijo(488,pac_md_common.f_get_cxtidioma, motrechazo) motivorechazo , comentario comentario, fproxaviso fecharevision
                 FROM mandatos_gestion
                 WHERE numfolio = '
         || pnumfolio || ' ORDER BY caviso DESC';
      vpasexec := 20;
      p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, v_select);

      OPEN cur FOR v_select;

      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           terror, SQLCODE, SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_getgestionesmandato;

   FUNCTION f_get_folio(
      psperson_man IN mandatos.sperson%TYPE,
      psperson_ase IN tomadores.sseguro%TYPE,
      pcbancar IN mandatos.cbancar%TYPE,
      pnumfolio OUT mandatos_seguros.numfolio%TYPE,
      pfechamandato OUT mandatos_seguros.fechamandato%TYPE,
      psucursal OUT mandatos_seguros.sucursal%TYPE,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vparam         VARCHAR2(2000)
         := 'psperson_man= ' || psperson_man || 'psperson_ase= ' || psperson_ase
            || 'pcbancar= ' || pcbancar;
      vobject        VARCHAR2(200) := 'PAC_MD_MANDATOS.f_get_folio';
      vpasexec       NUMBER := 10;
      terror         VARCHAR2(200) := 'Error recuperar num folio';
   BEGIN
      SELECT ms.numfolio, ms.fechamandato, ms.sucursal
        INTO pnumfolio, pfechamandato, psucursal
        FROM mandatos_seguros ms
       WHERE EXISTS(SELECT ma.cmandato
                      FROM mandatos ma
                     WHERE sperson = (SELECT spereal
                                        FROM estper_personas esper
                                       WHERE esper.sperson = psperson_man)
                       AND ma.cbancar = pcbancar
                       AND ma.cmandato = ms.cmandato)
         AND ms.nmovimi = (SELECT MAX(manseg.nmovimi)
                             FROM mandatos_seguros manseg
                            WHERE manseg.cmandato = ms.cmandato
                              AND manseg.numfolio = ms.numfolio
                              AND pac_mandatos.f_getcodultestadomandato(ms.numfolio) NOT IN
                                                                                         (2, 4))
         AND pac_mandatos.f_getcodultestadomandato(ms.numfolio) NOT IN(2, 4)
                                                                            /*AND EXISTS(SELECT 1
                                                                                         FROM asegurados aseg
                                                                                        WHERE aseg.sperson = (SELECT spereal
                                                                                                                FROM estper_personas esper
                                                                                                               WHERE esper.sperson = psperson_ase)
                                                                                          AND aseg.sseguro = ms.sseguro)*/
      ;

      RETURN 0;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RETURN 0;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_get_folio;

   FUNCTION f_set_mandatos_gestion_masiva(
      pcadenanumfol IN VARCHAR2,
      paccion IN mandatos_masiva.accion%TYPE,
      pnomina OUT mandatos_masiva.nomina%TYPE,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vcestado       mandatos_estados.cestado%TYPE;
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vobject        VARCHAR2(200) := 'PAC_MD_MANDATOS.f_set_mandatos_gestion_masiva';
      vparam         VARCHAR2(2000)
                             := 'pcadenanumfol = ' || pcadenanumfol || 'paccion = ' || paccion;
      v_numfolio     mandatos_masiva.numfolio%TYPE;
      v_ncarta       mandatos_masiva.ncarta%TYPE;
      v_nomina       mandatos_masiva.nomina%TYPE;
      caracter       CHAR;
      v_i            NUMBER := 0;
      registro       VARCHAR(50);
      v_rownum       NUMBER := 0;
      -- bug 0027500 - 08/05/2014 - JMF
      v_bancini      VARCHAR2(100);
      v_bancfin      VARCHAR2(100);
   BEGIN
      vpasexec := 10;

      IF paccion NOT IN(0, 1, 2) THEN
         RAISE e_param_error;
      END IF;

      IF paccion = 0 THEN   --Accion Env¿o a casa matriz
         vcestado := 7;   -- Estado Env¿o a casa matriz
      ELSIF paccion = 1 THEN   --Accion Custodia
         vcestado := 8;   -- Estado Custodia
      ELSIF paccion = 2 THEN   --Accion En tr¿nsito
         vcestado := 3;   --En transito
      END IF;

      SELECT nominamasiva_sec.NEXTVAL
        INTO v_nomina
        FROM DUAL;

      vpasexec := 20;

      FOR x IN 1 .. LENGTH(pcadenanumfol) LOOP
         caracter := SUBSTR(pcadenanumfol, x, 1);

         IF caracter = '-' THEN
            v_i := v_i + 1;
         END IF;
      END LOOP;

      vpasexec := 30;
      v_i := v_i + 1;

      FOR x IN 2 .. v_i LOOP
         SELECT pac_util.splitt(pcadenanumfol, x, '-')
           INTO registro
           FROM DUAL;

         v_numfolio := pac_util.splitt(registro, 1, '_');

         IF v_numfolio IS NOT NULL THEN
            vnumerr := pac_mandatos.f_set_estado_mandato(v_numfolio, vcestado);

            IF vnumerr <> 0 THEN
               pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
               RAISE e_object_error;
            END IF;

            vnumerr := pac_mandatos.f_set_mandatos_gestion(v_numfolio, paccion, NULL, NULL,
                                                           'NOMINA ' || v_nomina);

            IF vnumerr <> 0 THEN
               pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
               RAISE e_object_error;
            END IF;

            -- ini bug 0027500 - 08/05/2014 - JMF
            v_ncarta := NULL;

            IF paccion = 2 THEN   -- En transito
               SELECT MAX(pac_mandatos.f_codbanco(c.cbancar, c.ctipban))
                 INTO v_bancini
                 FROM mandatos_seguros b, mandatos c
                WHERE b.numfolio = v_numfolio
                  AND c.cmandato = b.cmandato;

               SELECT MAX(pac_mandatos.f_codbanco(c.cbancar, c.ctipban)), MAX(a.ncarta)
                 INTO v_bancfin, v_ncarta
                 FROM mandatos_masiva a, mandatos_seguros b, mandatos c
                WHERE a.nomina = v_nomina
                  AND b.numfolio = a.numfolio
                  AND c.cmandato = b.cmandato;

               IF NVL(v_bancfin, '*') <> NVL(v_bancini, '=') THEN
                  SELECT transitomandato_sec.NEXTVAL
                    INTO v_ncarta
                    FROM DUAL;
               END IF;
            END IF;

            -- fin bug 0027500 - 08/05/2014 - JMF
            v_rownum := v_rownum + 1;
            vnumerr := pac_mandatos.f_set_mandatos_masiva(v_nomina, v_numfolio, paccion,
                                                          v_rownum, v_ncarta);

            IF vnumerr <> 0 THEN
               pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
               RAISE e_object_error;
            END IF;
         END IF;
      END LOOP;

      vpasexec := 40;
      pnomina := v_nomina;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_set_mandatos_gestion_masiva;

   FUNCTION f_imp_mandatos_gestion_masiva(
      paccion IN NUMBER,
      pnomina IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vcestado       mandatos_estados.cestado%TYPE;
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vobject        VARCHAR2(200) := 'PAC_MD_MANDATOS.f_imp_mandatos_gestion_masiva';
      vparam         VARCHAR2(2000) := 'a=' || paccion || ' n = ' || pnomina;
   BEGIN
      vpasexec := 10;

      IF paccion IS NULL
         OR pnomina IS NULL THEN
         RAISE e_param_error;
      END IF;

      IF paccion = 0 THEN   -- Envio casa matriz
         vnumerr := f_imprime_enviomatriz(pnomina, mensajes);

         IF vnumerr <> 0 THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
            RAISE e_object_error;
         END IF;
      ELSIF paccion = 2 THEN   -- En Transito
         vnumerr := f_imprime_entransito(pnomina, mensajes);

         IF vnumerr <> 0 THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
            RAISE e_object_error;
         END IF;
      END IF;

      vpasexec := 50;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_imp_mandatos_gestion_masiva;

   FUNCTION f_imprime_rechazo(
      p_numfolio IN NUMBER,
      p_origen IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      --
      vobjectname    VARCHAR2(500) := 'PAC_MD_MANDATOS.f_imprime_rechazo';
      vparam         VARCHAR2(1000) := 'f=' || p_numfolio;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      --
      vmap           cfg_lanzar_informes.cmap%TYPE;
      vemp           cfg_lanzar_informes.cempres%TYPE;
      vidi           det_lanzar_informes.cidioma%TYPE;
      onomfichero    VARCHAR2(1000);
      ofichero       VARCHAR2(1000);
      vtinfo         t_iax_info;
      vinfo          ob_iax_info;
      e_object_error EXCEPTION;
      vtdesc         detplantillas.tdescrip%TYPE;
      v_gedox        codiplantillas.gedox%TYPE;
      v_idcat        codiplantillas.idcat%TYPE;
      v_cgenfich     codiplantillas.cgenfich%TYPE;
      vterror        VARCHAR2(1000);
      viddoc         mandatos_documentos.iddocgedox%TYPE;
      v_smandoc      mandatos_masiva.smandoc%TYPE;
      vnum_err       NUMBER;

      CURSOR curlis IS
         SELECT   p1.ccodplan
             FROM prod_plant_cab p1
            WHERE p1.sproduc = 0
              AND p1.ctipo = 49
              AND p1.fdesde = (SELECT MAX(p2.fdesde)
                                 FROM prod_plant_cab p2
                                WHERE p2.sproduc = p1.sproduc
                                  AND p2.ctipo = p1.ctipo)
         ORDER BY 1;

      vfarchiv      date; --CONF 236 JAAB
      vfelimin      date; --CONF 236 JAAB
      vfcaduci      date; --CONF 236 JAAB

   BEGIN
      vpasexec := 100;
      vemp := f_parinstalacion_n('EMPRESADEF');
      vpasexec := 110;

      SELECT MAX(nvalpar)
        INTO vidi
        FROM parinstalacion
       WHERE cparame = 'IDIOMARTF';

      SELECT documentomandato_sec.NEXTVAL
        INTO v_smandoc
        FROM DUAL;

      vnum_err := pac_mandatos.f_set_mandatos_gestion(p_numfolio, 9, NULL, NULL, p_origen,
                                                      v_smandoc);

      IF vnum_err <> 0 THEN
         vterror := 'Error modificando en tablas de mandatos ';
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9906756, vterror);
         RAISE e_object_error;
      END IF;

      FOR forlis IN curlis LOOP
         vpasexec := 120;
         --RSA022 RSA Carta Mandato Rechazado Cliente
         --RSA023 RSA Carta Mandato Rechazado Corredor
         --RSA024 RSA Carta Mandato Rechazado Sucursal
         vmap := forlis.ccodplan;
         vparam := 'f=' || p_numfolio || ' m=' || vmap;
         vpasexec := 130;

         SELECT MAX(gedox), MAX(idcat), MAX(cgenfich)
           INTO v_gedox, v_idcat, v_cgenfich
           FROM codiplantillas
          WHERE ccodplan = vmap;

         vpasexec := 140;

         IF v_cgenfich = 1 THEN
            vpasexec := 150;
            vtinfo := t_iax_info();
            vtinfo.DELETE;
            vinfo := ob_iax_info();
            vtinfo.EXTEND;
            vinfo.nombre_columna := 'PAR_NUMFOLIO';
            vinfo.valor_columna := p_numfolio;
            vinfo.tipo_columna := '1';
            vtinfo(vtinfo.LAST) := vinfo;
            vpasexec := 160;
            vnumerr := pac_md_informes.f_ejecuta_informe(vmap, vemp, 'PDF', vtinfo, vidi, 0,
                                                         NULL, onomfichero, ofichero,
                                                         mensajes);

            IF NVL(vnumerr, 0) <> 0 THEN
               DELETE      mandatos_gestion
                     WHERE numfolio = p_numfolio
                       AND accion = 9;

               COMMIT;
               RAISE e_object_error;
            END IF;

            IF v_gedox = 'S' THEN
               vpasexec := 150;

               SELECT MAX(tdescrip)
                 INTO vtdesc
                 FROM detplantillas
                WHERE ccodplan = vmap
                  AND cidioma = vidi;

               vpasexec := 160;

                --INI JAAB CONF-236 22/08/2016
                vfarchiv := PAC_MD_GEDOX.F_CALCULA_FECHA_AEC(1);
                vfcaduci := PAC_MD_GEDOX.F_CALCULA_FECHA_AEC(2);
                vfelimin := PAC_MD_GEDOX.F_CALCULA_FECHA_AEC(3);
                --FIN JAAB CONF 236 22/08/2016

               --Gravem la cap¿alera del document.
               --pac_axisgedox.grabacabecera(f_user, onomfichero, vtdesc, 1, 1, v_idcat, vterror, viddoc); --JAAB CONF 236

               pac_axisgedox.grabacabecera(f_user, onomfichero, vtdesc, 1, 1, v_idcat, vterror, viddoc, vfarchiv, vfelimin, vfcaduci);

               IF vterror IS NOT NULL
                  OR NVL(viddoc, 0) = 0 THEN
                  pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000001, vterror);
                  RAISE e_object_error;
               END IF;

               vpasexec := 170;
               --Gravem a la BD el fiter en q¿esti¿.
               pac_axisgedox.actualiza_gedoxdb(onomfichero, viddoc, vterror, NULL);

               IF vterror IS NOT NULL THEN
                  pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000001, vterror);
                  RAISE e_object_error;
               END IF;

               --> Guardar el documento
               vpasexec := 180;

               INSERT INTO mandatos_documentos
                           (smandoc, iddocgedox, numfolio, falta, cusualta)
                    VALUES (v_smandoc, viddoc, NULL, f_sysdate, f_user);

               --> asociar el documento al folio
               vpasexec := 190;
            END IF;
         END IF;
      END LOOP;

      vpasexec := 170;
      RETURN 0;
   EXCEPTION
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_imprime_rechazo;

   FUNCTION f_imprime_enviomatriz(p_nomina IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      --
      vobjectname    VARCHAR2(500) := 'PAC_MD_MANDATOS.f_imprime_enviomatriz';
      vparam         VARCHAR2(1000) := 'f=' || p_nomina;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      --
      vmap           cfg_lanzar_informes.cmap%TYPE;
      vemp           cfg_lanzar_informes.cempres%TYPE;
      vidi           det_lanzar_informes.cidioma%TYPE;
      onomfichero    VARCHAR2(1000);
      ofichero       VARCHAR2(1000);
      vtinfo         t_iax_info;
      vinfo          ob_iax_info;
      e_object_error EXCEPTION;
      v_gedox        codiplantillas.gedox%TYPE;
      v_idcat        codiplantillas.idcat%TYPE;
      v_cgenfich     codiplantillas.cgenfich%TYPE;
      vtdesc         detplantillas.tdescrip%TYPE;
      vterror        VARCHAR2(1000);
      viddoc         mandatos_documentos.iddocgedox%TYPE;
      v_smandoc      mandatos_masiva.smandoc%TYPE;

      CURSOR curlis IS
         SELECT   p1.ccodplan
             FROM prod_plant_cab p1
            WHERE p1.sproduc = 0
              AND p1.ctipo = 50
              AND p1.fdesde = (SELECT MAX(p2.fdesde)
                                 FROM prod_plant_cab p2
                                WHERE p2.sproduc = p1.sproduc
                                  AND p2.ctipo = p1.ctipo)
         ORDER BY 1;

      vfarchiv      date; --CONF 236 JAAB
      vfelimin      date; --CONF 236 JAAB
      vfcaduci      date; --CONF 236 JAAB

   BEGIN
      vpasexec := 100;
      vemp := f_parinstalacion_n('EMPRESADEF');
      vpasexec := 110;

      SELECT MAX(nvalpar)
        INTO vidi
        FROM parinstalacion
       WHERE cparame = 'IDIOMARTF';

      FOR forlis IN curlis LOOP
----------------------------------------------
         vpasexec := 120;
         -- RSA025 RSA Carta Generada por Sucursal para env¿o de Mandatos a Casa Matriz
         vmap := forlis.ccodplan;
         vparam := 'f=' || p_nomina || ' m=' || vmap;

         SELECT MAX(gedox), MAX(idcat), MAX(cgenfich)
           INTO v_gedox, v_idcat, v_cgenfich
           FROM codiplantillas
          WHERE ccodplan = vmap;

         IF v_cgenfich = 1 THEN
            vpasexec := 130;
            vtinfo := t_iax_info();
            vtinfo.DELETE;
            vinfo := ob_iax_info();
            vtinfo.EXTEND;
            vinfo.nombre_columna := 'PAR_NOMINA';
            vinfo.valor_columna := p_nomina;
            vinfo.tipo_columna := '1';
            vtinfo(vtinfo.LAST) := vinfo;
            vpasexec := 140;
            vnumerr := pac_md_informes.f_ejecuta_informe(vmap, vemp, 'PDF', vtinfo, vidi, 0,
                                                         NULL, onomfichero, ofichero,
                                                         mensajes);

            IF NVL(vnumerr, 0) <> 0 THEN
               RAISE e_object_error;
            END IF;

            IF v_gedox = 'S' THEN
               vpasexec := 150;

               SELECT MAX(tdescrip)
                 INTO vtdesc
                 FROM detplantillas
                WHERE ccodplan = vmap
                  AND cidioma = vidi;

               vpasexec := 160;

                --INI JAAB CONF-236 22/08/2016
                vfarchiv := PAC_MD_GEDOX.F_CALCULA_FECHA_AEC(1);
                vfcaduci := PAC_MD_GEDOX.F_CALCULA_FECHA_AEC(2);
                vfelimin := PAC_MD_GEDOX.F_CALCULA_FECHA_AEC(3);
                --FIN JAAB CONF 236 22/08/2016

               --Gravem la cap¿alera del document.
               --pac_axisgedox.grabacabecera(f_user, onomfichero, vtdesc, 1, 1, v_idcat, vterror,  viddoc); --JAAB CONF 236


                pac_axisgedox.grabacabecera(f_user, onomfichero, vtdesc, 1, 1, v_idcat, vterror,  viddoc, vfarchiv, vfelimin, vfcaduci);

               IF vterror IS NOT NULL
                  OR NVL(viddoc, 0) = 0 THEN
                  pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000001, vterror);
                  RAISE e_object_error;
               END IF;

               vpasexec := 170;
               --Gravem a la BD el fiter en q¿esti¿.
               pac_axisgedox.actualiza_gedoxdb(onomfichero, viddoc, vterror, NULL);

               IF vterror IS NOT NULL THEN
                  pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000001, vterror);
                  RAISE e_object_error;
               END IF;

               --> Guardar el documento
               vpasexec := 180;

               SELECT documentomandato_sec.NEXTVAL
                 INTO v_smandoc
                 FROM DUAL;

               INSERT INTO mandatos_documentos
                           (smandoc, iddocgedox, falta, cusualta)
                    VALUES (v_smandoc, viddoc, f_sysdate, f_user);

               --> asociar el documento a la nomina
               vpasexec := 190;

               UPDATE mandatos_masiva
                  SET smandoc = v_smandoc
                WHERE nomina = p_nomina;
            END IF;
         END IF;
----------------------------------------------
      END LOOP;

      vpasexec := 400;
      RETURN 0;
   EXCEPTION
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_imprime_enviomatriz;

   FUNCTION f_imprime_entransito(p_nomina IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      --
      vobjectname    VARCHAR2(500) := 'PAC_MD_MANDATOS.f_imprime_entransito';
      vparam         VARCHAR2(1000) := 'f=' || p_nomina;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      --
      vmap           cfg_lanzar_informes.cmap%TYPE;
      vemp           cfg_lanzar_informes.cempres%TYPE;
      vidi           det_lanzar_informes.cidioma%TYPE;
      onomfichero    VARCHAR2(1000);
      ofichero       VARCHAR2(1000);
      vtinfo         t_iax_info;
      vinfo          ob_iax_info;
      e_object_error EXCEPTION;
      v_gedox        codiplantillas.gedox%TYPE;
      v_idcat        codiplantillas.idcat%TYPE;
      v_cgenfich     codiplantillas.cgenfich%TYPE;
      vtdesc         detplantillas.tdescrip%TYPE;
      vterror        VARCHAR2(1000);
      viddoc         mandatos_documentos.iddocgedox%TYPE;
      v_smandoc      mandatos_masiva.smandoc%TYPE;
      v_ncartares    mandatos_masiva.ncartares%TYPE;

      CURSOR curlis IS
         SELECT   p1.ccodplan
             FROM prod_plant_cab p1
            WHERE p1.sproduc = 0
              AND p1.ctipo = 51
              AND p1.fdesde = (SELECT MAX(p2.fdesde)
                                 FROM prod_plant_cab p2
                                WHERE p2.sproduc = p1.sproduc
                                  AND p2.ctipo = p1.ctipo)
         ORDER BY 1;

      CURSOR curres IS
         SELECT   p1.ccodplan
             FROM prod_plant_cab p1
            WHERE p1.sproduc = 0
              AND p1.ctipo = 52
              AND p1.fdesde = (SELECT MAX(p2.fdesde)
                                 FROM prod_plant_cab p2
                                WHERE p2.sproduc = p1.sproduc
                                  AND p2.ctipo = p1.ctipo)
         ORDER BY 1;

      CURSOR c1 IS
         SELECT   TO_NUMBER(pac_mandatos.f_codbanco(c.cbancar, c.ctipban)) banco
             FROM mandatos_masiva a, mandatos_seguros b, mandatos c
            WHERE nomina = p_nomina
              AND b.numfolio = a.numfolio
              AND c.cmandato = b.cmandato
         GROUP BY pac_mandatos.f_codbanco(c.cbancar, c.ctipban)
         ORDER BY 1;

      vfarchiv      date; --CONF 236 JAAB
      vfelimin      date; --CONF 236 JAAB
      vfcaduci      date; --CONF 236 JAAB

   BEGIN
      vpasexec := 100;
      vemp := f_parinstalacion_n('EMPRESADEF');
      vpasexec := 110;

      SELECT MAX(nvalpar)
        INTO vidi
        FROM parinstalacion
       WHERE cparame = 'IDIOMARTF';

      v_smandoc := NULL;

      FOR forlis IN curlis LOOP
         FOR f1 IN c1 LOOP
----------------------------------------------
            vpasexec := 120;
            --RSA026 RSA Carta Mandatos Banco Chile
            --RSA028 RSA N¿mina de entrega Mandatos a Bancos
            vmap := forlis.ccodplan;

            SELECT MAX(gedox), MAX(idcat), MAX(cgenfich)
              INTO v_gedox, v_idcat, v_cgenfich
              FROM codiplantillas
             WHERE ccodplan = vmap;

            vparam := 'n=' || p_nomina || ' b=' || f1.banco || ' m=' || vmap;

            IF v_cgenfich = 1 THEN
               vpasexec := 130;
               vtinfo := t_iax_info();
               vtinfo.DELETE;
               vinfo := ob_iax_info();
               vtinfo.EXTEND;
               vinfo.nombre_columna := 'PAR_NOMINA';
               vinfo.valor_columna := p_nomina;
               vinfo.tipo_columna := '1';
               vtinfo(vtinfo.LAST) := vinfo;
               vtinfo.EXTEND;
               vinfo.nombre_columna := 'PAR_BANCO';
               vinfo.valor_columna := f1.banco;
               vinfo.tipo_columna := '1';
               vtinfo(vtinfo.LAST) := vinfo;
               vpasexec := 140;
               vnumerr := pac_md_informes.f_ejecuta_informe(vmap, vemp, 'PDF', vtinfo, vidi,
                                                            0, NULL, onomfichero, ofichero,
                                                            mensajes);

               IF NVL(vnumerr, 0) <> 0 THEN
                  RAISE e_object_error;
               END IF;

               IF v_gedox = 'S' THEN
                  vpasexec := 150;

                  SELECT MAX(tdescrip) || ' ' || f1.banco
                    INTO vtdesc
                    FROM detplantillas
                   WHERE ccodplan = vmap
                     AND cidioma = vidi;

                  vpasexec := 160;

                    --INI JAAB CONF-236 22/08/2016
                    vfarchiv := PAC_MD_GEDOX.F_CALCULA_FECHA_AEC(1);
                    vfcaduci := PAC_MD_GEDOX.F_CALCULA_FECHA_AEC(2);
                    vfelimin := PAC_MD_GEDOX.F_CALCULA_FECHA_AEC(3);
                    --FIN JAAB CONF 236 22/08/2016

                  --Gravem la cap¿alera del document.
                  --pac_axisgedox.grabacabecera(f_user, onomfichero, vtdesc, 1, 1, v_idcat, vterror, viddoc); --JAAB CONF 236

                  pac_axisgedox.grabacabecera(f_user, onomfichero, vtdesc, 1, 1, v_idcat, vterror, viddoc, vfarchiv, vfelimin, vfcaduci);

                  IF vterror IS NOT NULL
                     OR NVL(viddoc, 0) = 0 THEN
                     pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000001, vterror);
                     RAISE e_object_error;
                  END IF;

                  vpasexec := 170;
                  --Gravem a la BD el fiter en q¿esti¿.
                  pac_axisgedox.actualiza_gedoxdb(onomfichero, viddoc, vterror, NULL);

                  IF vterror IS NOT NULL THEN
                     pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000001, vterror);
                     RAISE e_object_error;
                  END IF;

                  --> insert into masivos_documentos
                  vpasexec := 180;

                  IF v_smandoc IS NULL THEN
                     SELECT documentomandato_sec.NEXTVAL
                       INTO v_smandoc
                       FROM DUAL;

                     --> asignar el documento a la nomina
                     UPDATE mandatos_masiva
                        SET smandoc = v_smandoc
                      WHERE nomina = p_nomina;
                  END IF;

                  vpasexec := 190;

                  -- guardar documento
                  INSERT INTO mandatos_documentos
                              (smandoc, iddocgedox, falta, cusualta)
                       VALUES (v_smandoc, viddoc, f_sysdate, f_user);
               END IF;
            END IF;
         END LOOP;
      END LOOP;

      FOR forres IN curres LOOP
         vpasexec := 200;
         --RSA027 RSA Carta Resumen para Banco Concentrador
         vmap := forres.ccodplan;
         vparam := 'f=' || p_nomina || ' m=' || vmap;

         SELECT MAX(gedox), MAX(idcat), MAX(cgenfich)
           INTO v_gedox, v_idcat, v_cgenfich
           FROM codiplantillas
          WHERE ccodplan = vmap;

         IF v_cgenfich = 1 THEN
            vpasexec := 210;

            SELECT transitomandato_sec.NEXTVAL
              INTO v_ncartares
              FROM DUAL;

            vparam := 'f=' || p_nomina || ' m=' || vmap || ' c=' || v_ncartares;
            vtinfo := t_iax_info();
            vtinfo.DELETE;
            vinfo := ob_iax_info();
            vtinfo.EXTEND;
            vinfo.nombre_columna := 'PAR_NOMINA';
            vinfo.valor_columna := p_nomina;
            vinfo.tipo_columna := '1';
            vtinfo(vtinfo.LAST) := vinfo;
            vtinfo.EXTEND;
            vinfo.nombre_columna := 'PAR_CARTA';
            vinfo.valor_columna := v_ncartares;
            vinfo.tipo_columna := '1';
            vtinfo(vtinfo.LAST) := vinfo;
            vpasexec := 220;
            vnumerr := pac_md_informes.f_ejecuta_informe(vmap, vemp, 'PDF', vtinfo, vidi, 0,
                                                         NULL, onomfichero, ofichero, mensajes);

            IF NVL(vnumerr, 0) <> 0 THEN
               RAISE e_object_error;
            END IF;

            IF v_gedox = 'S' THEN
               vpasexec := 230;

               SELECT MAX(tdescrip)
                 INTO vtdesc
                 FROM detplantillas
                WHERE ccodplan = vmap
                  AND cidioma = vidi;

               vpasexec := 240;
               --Gravem la cap¿alera del document.
               pac_axisgedox.grabacabecera(f_user, onomfichero, vtdesc, 1, 1, v_idcat, vterror,
                                           viddoc);

               IF vterror IS NOT NULL
                  OR NVL(viddoc, 0) = 0 THEN
                  pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000001, vterror);
                  RAISE e_object_error;
               END IF;

               vpasexec := 250;
               --Gravem a la BD el fiter en q¿esti¿.
               pac_axisgedox.actualiza_gedoxdb(onomfichero, viddoc, vterror, NULL);

               IF vterror IS NOT NULL THEN
                  pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000001, vterror);
                  RAISE e_object_error;
               END IF;

               --> insert into masivos_documentos
               vpasexec := 260;

               SELECT MAX(smandoc)
                 INTO v_smandoc
                 FROM mandatos_masiva
                WHERE nomina = p_nomina;

               INSERT INTO mandatos_documentos
                           (smandoc, iddocgedox, falta, cusualta)
                    VALUES (v_smandoc, viddoc, f_sysdate, f_user);

               --> update mandatos_masiva
               vpasexec := 270;

               UPDATE mandatos_masiva
                  SET ncartares = v_ncartares
                WHERE nomina = p_nomina;
            END IF;
         END IF;
----------------------------------------------
      END LOOP;

      vpasexec := 300;
      RETURN 0;
   EXCEPTION
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_imprime_entransito;

   FUNCTION f_consulta_documentos(
      pnomina IN mandatos_masiva.nomina%TYPE,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      v_select       VARCHAR2(1000);
      vparam         VARCHAR2(2000) := 'pnomina= ' || pnomina;
      vobject        VARCHAR2(200) := 'PAC_MD_MANDATOS.f_consulta_documentos';
      vpasexec       NUMBER := 10;
      terror         VARCHAR2(200) := 'Error recuperar consulta de documentos';
   BEGIN
      v_select :=
         'SELECT DISTINCT md.iddocgedox idgedox, pac_axisgedox.f_get_descdoc(md.iddocgedox) descgedox, ms.fecha fechanomina
              FROM mandatos_masiva ms, mandatos_documentos md
              WHERE ms.smandoc = md.smandoc
              AND nomina = '
         || pnomina;
      vpasexec := 20;
      p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, v_select);

      OPEN cur FOR v_select;

      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           terror, SQLCODE, SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_consulta_documentos;

   FUNCTION f_conscobradoresbanc(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      v_select       VARCHAR2(1000);
      vparam         VARCHAR2(2000);
      vobject        VARCHAR2(200) := 'PAC_MD_MANDATOS. f_conscobradoresbanc';
      vpasexec       NUMBER := 10;
      terror         VARCHAR2(200) := 'Error recuperar consulta de cobradores bancarios';
   BEGIN
      v_select := 'SELECT ccobban, descripcion FROM cobbancario ';
      vpasexec := 20;
      p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, v_select);

      OPEN cur FOR v_select;

      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           terror, SQLCODE, SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_conscobradoresbanc;

   FUNCTION f_set_mandatos_documentos(
      piddocgedox IN NUMBER,
      pnumfolio IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vobject        VARCHAR2(200) := 'PAC_MD_MANDATOS.f_set_mandatos_documentos';
      vparam         VARCHAR2(4000)
                             := 'piddocgedox = ' || piddocgedox || 'pnumfolio = ' || pnumfolio;
   BEGIN
      vpasexec := 10;
      vnumerr := pac_mandatos.f_set_mandatos_documentos(piddocgedox, pnumfolio);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      vpasexec := 20;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_set_mandatos_documentos;

   FUNCTION f_cons_doc_mandato(pnumfolio IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      v_select       VARCHAR2(1000);
      vparam         VARCHAR2(2000) := 'pnumfolio= ' || pnumfolio;
      vobject        VARCHAR2(200) := 'PAC_MD_MANDATOS.f_cons_doc_mandato';
      vpasexec       NUMBER := 10;
      terror         VARCHAR2(200)
                             := 'Error recuperar consulta de documentos de mandato, y rechazo';
   BEGIN
      v_select :=
         'SELECT * FROM (SELECT iddocgedox, pac_axisgedox.f_get_descdoc(iddocgedox) descgedox, trunc(falta) fechacreacion, 0 rechazo
                FROM  mandatos_documentos
                WHERE numfolio = '
         || pnumfolio
         || ' AND falta = (SELECT MAX(FALTA) FROM mandatos_documentos WHERE numfolio = '
         || pnumfolio
         || ')
            UNION ALL
              SELECT md.iddocgedox iddocgedox, pac_axisgedox.f_get_descdoc(md.iddocgedox) descgedox, trunc(faccion) fechacreacion, 1 rechazo
                FROM mandatos_gestion mg, mandatos_documentos md
                WHERE mg.smandoc_rechazo = md.smandoc
                AND mg.numfolio = '
         || pnumfolio || ' AND mg.accion = 9) ORDER BY fechacreacion ASC';
      vpasexec := 20;
      p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, v_select);

      OPEN cur FOR v_select;

      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           terror, SQLCODE, SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_cons_doc_mandato;

   FUNCTION f_usupermisogestion(
      pcmandato IN VARCHAR2,
      pnumfolio IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vobject        VARCHAR2(200) := 'PAC_MD_MANDATOS.f_usupermisogestion';
      vparam         VARCHAR2(4000)
                                 := 'pcmandato = ' || pcmandato || 'pnumfolio = ' || pnumfolio;
      terror         VARCHAR2(200) := 'Error recuperar usuarios permisos gesti¿n';
      vpermisgestion NUMBER(1) := 0;
   BEGIN
      vpasexec := 10;

      -- INICIO Bug 0032654 MMS 20150115
      IF NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa, 'ROL_MANDATO'), 0) =
                                                                                             1
         AND pac_mandatos.f_getrolusuari(f_user) IN
                                                ('CENTRAL', 'MENU_TOTAL', 'OPE_GER', 'OPE_JPO') THEN   -- Si el usuario no es servicios centrales, miramos si el mandato lo dio de alta
         vpermisgestion := 1;
      -- FIN Bug 0032654 MMS 20150115
      ELSIF NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa, 'ROL_MANDATO'),
                0) = 0
            AND pac_mandatos.f_getrolusuari(f_user) = 'CENTRAL' THEN   -- Si el usuario no es servicios centrales, miramos si el mandato lo dio de alta
         vpermisgestion := 1;
      ELSE
         SELECT 1
           INTO vpermisgestion
           FROM mandatos_seguros ms
          WHERE ms.cmandato = pcmandato
            AND ms.numfolio = pnumfolio
            AND ms.cusualtarel = f_user
            AND ms.faltarel = (SELECT MIN(ms2.faltarel)
                                 FROM mandatos_seguros ms2
                                WHERE ms2.cmandato = ms.cmandato
                                  AND ms2.numfolio = ms.numfolio);

         vpasexec := 20;
      END IF;

      RETURN(vpermisgestion);
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         --El folio no lo dio de alta el usuario conectado
         RETURN 0;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           terror, SQLCODE, SQLERRM);
         RETURN -1;
   END f_usupermisogestion;
END pac_md_mandatos;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_MANDATOS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_MANDATOS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_MANDATOS" TO "PROGRAMADORESCSI";
