--------------------------------------------------------
--  DDL for Package Body PAC_MD_OPERATIVA_FINV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_MD_OPERATIVA_FINV" IS
   /******************************************************************************
      NOMBRE:       PAC_MD_OPERATIVA_FINV
      PROPÓSITO: Funciones para operativa de productos financieros de inversión.

      REVISIONES:
      Ver        Fecha        Autor             Descripción
      ---------  ----------  ---------------  ------------------------------------
      1.0        13/03/2009   RSC                1. Creación del package.
      2.0        07/04/2009   RSC                2. Análisis adaptación productos indexados
      3.0        15/06/2009   RSC                3. Bug 10040 - Ajustes PPJ Dinámico y PLa Estudiant
      4.0        17/09/2009   RSC                4. Bug 0010828: CRE - Revisión de los productos PPJ dinámico y Pla Estudiant (ajustes)
      5.0        25/09/2009   JGM                5. Bug 0011175
      6.0        12/03/2010   JTS                6. 13510: CRE - Ajustes en la pantalla de entrada de valores liquidativos - AXISFINV002
      7.0        16/04/2010   RSC                7. 0014160: CEM800 - Adaptar packages de productos de inversión al nuevo módulo de siniestros
      8.0        15/12/2010   LCF                8. 16971: Cambio del nivel de mensaje de error a información en validación valor liq.
      9.0        17/02/2011   APD                9. 17243: ENSA101 - Rebuts de comissió
     10.0        06/04/2011   JTS               10. 18136: ENSA101 - Mantenimiento cotizaciones
     11.0        30/11/2011   RSC               11. 0020309: LCOL_T004-Parametrización Fondos
     12.         30/07/2015   IGIL              12. 0211289 : Cambio de precision variable f_control_valorpart --> v_iuniact_aux
   ******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

   /*************************************************************************
      Recupera la los fondos de inversión a cargar valores liquidativos
      param in pcacto     : codigo del acto
      param out mensajes  : mesajes de error
      return              : descripción del acto
   *************************************************************************/
   -- Bug 9031 - 13/03/2009 - RSC -  iAxis: Análisis adaptación productos indexados
   FUNCTION f_getfondosoperafinv(
      pcempres IN NUMBER,
      pccodfon IN NUMBER,
      pfvalor IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vobjectname    VARCHAR2(500) := 'PAC_MD_OPERATIVA_FINV.F_GetFondosOperaFinv';
      vparam         VARCHAR2(500)
         := 'parámetros - pcempres: ' || pcempres || ', pccodfon: ' || pccodfon
            || ', pfvalor: ' || pfvalor;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vcursor        sys_refcursor;
      vsquery        VARCHAR2(9000);
      vidioma        NUMBER := 2;
      v_max_reg      NUMBER;
      vcopera        NUMBER;
   BEGIN
      vpasexec := 1;

      SELECT COUNT(*)
        INTO vcopera
        FROM fonoper2
       WHERE TRUNC(fvalor) = TRUNC(pfvalor)
         AND cempres = NVL(pcempres, cempres)
         AND ccodfon = NVL(pccodfon, ccodfon);

      IF vcopera > 0 THEN
         IF pcempres IS NULL
            AND pccodfon IS NULL THEN
            -- Bug 9031 - 07/04/2009 - RSC - Análisis adaptación productos indexados
            -- Modificamos fvalor a retornar y hacemos la right join con fonoper2
            -- Bug 15707 - APD - 02/03/2011 - El valor ivalactfondo en vez de obtenerlo de f.ivalact
            -- se obtiene de fonoper2.ipatrimonio con el último valor introducido
            vsquery :=
               'select f.cempres, f.ccodfon, f.tfonabv, f.fultval, f.iuniact iuniult,ff.iuniactcmp,f.iuniactcmpshw,f.iuniactvtashw,f.iuniactcmp,f.ctipfon,
                       (select ipatrimonio
                               from fonoper2
                               where cempres = f.cempres
                                 and ccodfon = f.ccodfon
                                 and fvalor = (select MAX(fvalor)
                                               from fonoper2
                                               where cempres = f.cempres
                                               and ccodfon = f.ccodfon)) ivalactfondo,
                       to_date('''
               || TO_CHAR(pfvalor, 'dd/mm/yyyy')
               || ''',''dd/mm/yyyy'') fvalor, ff.iuniact,
                       ff.iimpcmp, ff.nunicmp, ff.iimpvnt, ff.nunivnt, ff.ivalact
                from fonoper2 ff, fondos f
                where ff.fvalor (+) = to_date('''
               || TO_CHAR(pfvalor, 'dd/mm/yyyy')
               || ''',''dd/mm/yyyy'')
                  and ff.cempres (+) = f.cempres
                  and ff.ccodfon (+) = f.ccodfon
                  and f.ffin is null
                order by f.ccodfon';
         -- Fin Bug 15707 - APD - 02/03/2011
         -- Fin Bug 9031
         ELSIF pcempres IS NULL THEN
            -- Bug 9031 - 07/04/2009 - RSC - Análisis adaptación productos indexados
            -- Modificamos fvalor a retornar y hacemos la right join con fonoper2
            -- Bug 15707 - APD - 02/03/2011 - El valor ivalactfondo en vez de obtenerlo de f.ivalact
            -- se obtiene de fonoper2.ipatrimonio con el último valor introducido
            vsquery :=
               'select f.cempres, f.ccodfon, f.tfonabv, f.fultval, f.iuniact iuniult,ff.iuniactcmp,f.iuniactcmpshw,f.iuniactvtashw,f.iuniactcmp,f.ctipfon,
                       (select ipatrimonio
                               from fonoper2
                               where cempres = f.cempres
                                 and ccodfon = f.ccodfon
                                 and fvalor = (select MAX(fvalor)
                                               from fonoper2
                                               where cempres = f.cempres
                                               and ccodfon = f.ccodfon)) ivalactfondo,
                        to_date('''
               || TO_CHAR(pfvalor, 'dd/mm/yyyy')
               || ''',''dd/mm/yyyy'') fvalor, ff.iuniact, ff.iimpcmp, ff.nunicmp, ff.iimpvnt, ff.nunivnt, ff.ivalact
                        from fonoper2 ff, fondos f
                        where ff.fvalor (+) = to_date('''
               || TO_CHAR(pfvalor, 'dd/mm/yyyy')
               || ''',''dd/mm/yyyy'') fvalor
                          and ff.cempres (+) = f.cempres
                          and ff.ccodfon (+) = f.ccodfon
                          and f.ffin is null
                          and f.ccodfon = '
               || pccodfon || '
                        order by f.ccodfon';
         -- Fin Bug 15707 - APD - 02/03/2011
         -- Fin Bug 9031
         ELSIF pccodfon IS NULL THEN
            -- Bug 9031 - 07/04/2009 - RSC - Análisis adaptación productos indexados
            -- Modificamos fvalor a retornar y hacemos la right join con fonoper2
            -- Bug 15707 - APD - 02/03/2011 - El valor ivalactfondo en vez de obtenerlo de f.ivalact
            -- se obtiene de fonoper2.ipatrimonio con el último valor introducido
            vsquery :=
               'select f.cempres, f.ccodfon, f.tfonabv, f.fultval, f.iuniact iuniult,ff.iuniactcmp,ff.iuniactcmpshw,ff.iuniactvtashw,ff.iuniactcmp,f.ctipfon,
                       (select ipatrimonio
                               from fonoper2
                               where cempres = f.cempres
                                 and ccodfon = f.ccodfon
                                 and fvalor = (select MAX(fvalor)
                                               from fonoper2
                                               where cempres = f.cempres
                                               and ccodfon = f.ccodfon)) ivalactfondo,
                        to_date('''
               || TO_CHAR(pfvalor, 'dd/mm/yyyy')
               || ''',''dd/mm/yyyy'') fvalor, ff.iuniact, ff.iimpcmp, ff.nunicmp, ff.iimpvnt, ff.nunivnt, ff.ivalact
                        from fonoper2 ff, fondos f
                        where ff.fvalor (+) = to_date('''
               || TO_CHAR(pfvalor, 'dd/mm/yyyy')
               || ''',''dd/mm/yyyy'')
                          and ff.cempres (+) = f.cempres
                          and ff.ccodfon (+) = f.ccodfon
                          and f.ffin is null
                          and f.cempres ='
               || pcempres || '
                        order by f.ccodfon';
         -- Fin Bug 15707 - APD - 02/03/2011
         -- Fin Bug 9031
         ELSE
            -- Bug 9031 - 07/04/2009 - RSC - Análisis adaptación productos indexados
            -- Modificamos fvalor a retornar y hacemos la right join con fonoper2
            -- Bug 15707 - APD - 02/03/2011 - El valor ivalactfondo en vez de obtenerlo de f.ivalact
            -- se obtiene de fonoper2.ipatrimonio con el último valor introducido
            vsquery :=
               'select f.cempres, f.ccodfon, f.tfonabv, f.fultval, f.iuniact iuniult,ff.iuniactcmp,ff.iuniactcmpshw,ff.iuniactvtashw,ff.iuniactcmp,f.ctipfon,
                       (select ipatrimonio
                               from fonoper2
                               where cempres = f.cempres
                                 and ccodfon = f.ccodfon
                                 and fvalor = (select MAX(fvalor)
                                               from fonoper2
                                               where cempres = f.cempres
                                               and ccodfon = f.ccodfon)) ivalactfondo,
                        to_date('''
               || TO_CHAR(pfvalor, 'dd/mm/yyyy')
               || ''',''dd/mm/yyyy'') fvalor, ff.iuniact, ff.iimpcmp, ff.nunicmp, ff.iimpvnt, ff.nunivnt, ff.ivalact
                        from fonoper2 ff, fondos f
                        where ff.fvalor (+) = to_date('''
               || TO_CHAR(pfvalor, 'dd/mm/yyyy')
               || ''',''dd/mm/yyyy'')
                          and ff.cempres (+) = f.cempres
                          and ff.ccodfon (+) = f.ccodfon
                          and f.ffin is null
                          and f.cempres ='
               || pcempres || '
                          and f.ccodfon =' || pccodfon
               || '
                        order by f.ccodfon';
         -- Fin Bug 15707 - APD - 02/03/2011
         -- Fin Bug 9031
         END IF;
      ELSE
         IF pcempres IS NULL
            AND pccodfon IS NULL THEN
            -- Bug 15707 - APD - 02/03/2011 - El valor ivalactfondo en vez de obtenerlo de f.ivalact
            -- se obtiene de fonoper2.ipatrimonio con el último valor introducido
            vsquery :=
               'select f.cempres, f.ccodfon, f.tfonabv, f.fultval, f.iuniact iuniult,ff.iuniactcmp,ff.iuniactcmpshw,ff.iuniactvtashw,ff.iuniactcmp,f.ctipfon,
                       (select ipatrimonio
                               from fonoper2
                               where cempres = f.cempres
                                 and ccodfon = f.ccodfon
                                 and fvalor = (select MAX(fvalor)
                                               from fonoper2
                                               where cempres = f.cempres
                                               and ccodfon = f.ccodfon)) ivalactfondo,
               to_date('''
               || TO_CHAR(pfvalor, 'dd/mm/yyyy')
               || ''',''dd/mm/yyyy'') fvalor, NULL iuniact, NULL iimpcmp, NULL nunicmp, NULL iimpvnt, NULL nunivnt, NULL ivalact
             from fondos f
             where f.ffin is null
             order by f.ccodfon';
         -- Fin Bug 15707 - APD - 02/03/2011
         ELSIF pcempres IS NULL THEN
            -- Bug 15707 - APD - 02/03/2011 - El valor ivalactfondo en vez de obtenerlo de f.ivalact
            -- se obtiene de fonoper2.ipatrimonio con el último valor introducido
            vsquery :=
               'select f.cempres, f.ccodfon, f.tfonabv, f.fultval, f.iuniact iuniult,f.iuniactcmp,f.iuniactcmpshw,f.iuniactvtashw,f.iuniactcmp,f.ctipfon,
                       (select ipatrimonio
                               from fonoper2
                               where cempres = f.cempres
                                 and ccodfon = f.ccodfon
                                 and fvalor = (select MAX(fvalor)
                                               from fonoper2
                                               where cempres = f.cempres
                                               and ccodfon = f.ccodfon)) ivalactfondo,
               to_date('''
               || TO_CHAR(pfvalor, 'dd/mm/yyyy')
               || ''',''dd/mm/yyyy'') fvalor, NULL iuniact, NULL iimpcmp, NULL nunicmp, NULL iimpvnt, NULL nunivnt, NULL ivalact
             from fondos f
             where f.ccodfon = '
               || pccodfon
               || '
               and f.ffin is null
               order by f.ccodfon';
         -- Fin Bug 15707 - APD - 02/03/2011
         ELSIF pccodfon IS NULL THEN
            -- Bug 15707 - APD - 02/03/2011 - El valor ivalactfondo en vez de obtenerlo de f.ivalact
            -- se obtiene de fonoper2.ipatrimonio con el último valor introducido
            vsquery :=
               'select f.cempres, f.ccodfon, f.tfonabv, f.fultval, f.iuniact iuniult,f.iuniactcmp,f.iuniactcmpshw,f.iuniactvtashw,f.iuniactcmp,f.ctipfon,
                       (select ipatrimonio
                               from fonoper2
                               where cempres = f.cempres
                                 and ccodfon = f.ccodfon
                                 and fvalor = (select MAX(fvalor)
                                               from fonoper2
                                               where cempres = f.cempres
                                               and ccodfon = f.ccodfon)) ivalactfondo,
               to_date('''
               || TO_CHAR(pfvalor, 'dd/mm/yyyy')
               || ''',''dd/mm/yyyy'') fvalor, NULL iuniact, NULL iimpcmp, NULL nunicmp, NULL iimpvnt, NULL nunivnt, NULL ivalact
             from fondos f
             where f.cempres = '
               || pcempres
               || '
               and f.ffin is null
               order by f.ccodfon';
         -- Fin Bug 15707 - APD - 02/03/2011
         ELSE
            -- Bug 15707 - APD - 02/03/2011 - El valor ivalactfondo en vez de obtenerlo de f.ivalact
            -- se obtiene de fonoper2.ipatrimonio con el último valor introducido
            vsquery :=
               'select f.cempres, f.ccodfon, f.tfonabv, f.fultval, f.iuniact iuniult,f.iuniactcmp,f.iuniactcmpshw,f.iuniactvtashw,f.iuniactcmp,f.ctipfon,
                       (select ipatrimonio
                               from fonoper2
                               where cempres = f.cempres
                                 and ccodfon = f.ccodfon
                                 and fvalor = (select MAX(fvalor)
                                               from fonoper2
                                               where cempres = f.cempres
                                               and ccodfon = f.ccodfon)) ivalactfondo,
               to_date('''
               || TO_CHAR(pfvalor, 'dd/mm/yyyy')
               || ''',''dd/mm/yyyy'') fvalor, NULL iuniact, NULL iimpcmp, NULL nunicmp, NULL iimpvnt, NULL nunivnt, NULL ivalact
             from fondos f
             where f.cempres = '
               || pcempres || '
               and f.ccodfon = ' || pccodfon
               || '
               and f.ffin is null
               order by f.ccodfon';
         -- Fin Bug 15707 - APD - 02/03/2011
         END IF;
      END IF;

      vcursor := pac_iax_listvalores.f_opencursor(vsquery, mensajes);

      IF pac_md_log.f_log_consultas(vsquery, 'PAC_MD_PRODUCCION_AHO.F_GetFondosOperaFinv', 1,
                                    4, mensajes) <> 0 THEN
         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;
      END IF;

      RETURN vcursor;
   EXCEPTION
      WHEN OTHERS THEN
         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN vcursor;
   END f_getfondosoperafinv;

   /*************************************************************************
      Realiza la grabación de la operación liquidativa Finv
      param in pcempres     : codigo de empresa
      param in pccodfon     : codigo de fondo de inversión
      param in pfvalor      : Fecha de valoración
      param in piimpcmp     : Importe de compras
      param in pnunicmp     : Partipaciones o Unidades de compra
      param in piimpvnt     : Importe de ventas
      param in pnunivnt     : Participaciones o Unidades de venta
      param in piuniact     : Valor liquidativo a fecha de valoración
      param in pivalact     : Valor de la operación
      param in ppatrimonio  : Valor del patrimonio
      param out mensajes    : mesajes de error
      return                : numérico
   *************************************************************************/
   -- Bug 9031 - 13/03/2009 - RSC -  iAxis: Análisis adaptación productos indexados
   -- Bug 17243 - 17/02/2011 - APD -  se añade el parametro ppatrimonio a la funcion
   FUNCTION f_grabaroperacionfinv(
      pcempres IN NUMBER,
      pccodfon IN NUMBER,
      pfvalor IN DATE,
      piimpcmp IN NUMBER,
      pnunicmp IN NUMBER,
      piimpvnt IN NUMBER,
      pnunivnt IN NUMBER,
      piuniact IN NUMBER,
      pivalact IN NUMBER,
      ppatrimonio IN NUMBER,
      piuniactcmp IN NUMBER,
      piuniactcmpshw IN NUMBER,
      piuniactvtashw IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_MD_OPERATIVA_FINV.F_GrabarOperacionFinv';
      vparam         VARCHAR2(500)
         := 'parámetros - pcempres: ' || pcempres || ', pccodfon: ' || pccodfon
            || ', pfvalor: ' || pfvalor || ', piimpcmp: ' || piimpcmp || ', pnunicmp: '
            || pnunicmp || ', piimpvnt: ' || piimpvnt || ', pnunivnt: ' || pnunivnt
            || ', piuniact: ' || piuniact || ', pivalact: ' || pivalact;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vsquery        VARCHAR2(9000);
      vidioma        NUMBER := 2;
      v_max_reg      NUMBER;
      vcvalorat      NUMBER;
      v_texto        VARCHAR2(200);
      v_ivalact      NUMBER;
      v_iimpcmp      NUMBER;
      v_nunicmp      NUMBER;
      v_iimpvnt      NUMBER;
      v_nunivnt      NUMBER;
   BEGIN
      -- Si no se informa el valor liquidativo pues mensaje
      IF piuniact IS NULL THEN
         RETURN 9001553;
      END IF;

      -- Bug 10828 - RSC -16/09/2009 - CRE - Revisión de los productos PPJ dinámico y Pla Estudiant (ajustes)
      IF piimpcmp IS NULL
         AND pnunicmp IS NULL
         AND piimpvnt IS NULL
         AND pnunivnt IS NULL
         AND pivalact IS NULL THEN
         v_ivalact := 0;
         v_iimpcmp := 0;
         v_nunicmp := 0;
         v_iimpvnt := 0;
         v_nunivnt := 0;
      ELSE
         -- Fin Bug 10828
            -- Bug 10040 - RSC - 15/06/2009 - Ajustes PPJ Dinámico y PLa Estudiant
         IF pivalact IS NULL THEN
            RETURN 9001665;
         ELSE
            v_ivalact := pivalact;
            v_iimpcmp := piimpcmp;
            v_nunicmp := pnunicmp;
            v_iimpvnt := piimpvnt;
            v_nunivnt := pnunivnt;
         END IF;
      -- Bug 10828 - RSC -16/09/2009 - CRE - Revisión de los productos PPJ dinámico y Pla Estudiant (ajustes)
      END IF;

      -- Fin Bug 10828
      IF NVL(pac_parametros.f_parempresa_n(pcempres, 'MODIFICAR_VALOR_UP'), 0) = 0 THEN
         -- Fin Bug 10040
         SELECT COUNT(*)
           INTO vcvalorat
           FROM tabvalces
          WHERE ccesta = pccodfon
            AND fvalor = pfvalor;
      ELSE
         vcvalorat := 0;
      END IF;

      IF vcvalorat > 0 THEN
         RETURN 9001259;
      ELSE
         -- Bug 17243 - 17/02/2011 - APD -  se añade el parametro ppatrimonio a la tabla
         BEGIN
            INSERT INTO fonoper2
                        (cempres, ccodfon, foperac, fvalor, iuniact, nunicmp,
                         iimpcmp, iimpvnt, nunivnt, ivalact, ctipope, ccesta, cestado,
                         ipatrimonio, iuniactcmp, iuniactcmpshw, iuniactvtashw)
                 VALUES (pcempres, pccodfon, f_sysdate, pfvalor, piuniact, v_nunicmp,
                         v_iimpcmp, v_iimpvnt, v_nunivnt, v_ivalact, 3, pccodfon, 0,
                         ppatrimonio, piuniactcmp, piuniactcmpshw, piuniactvtashw);
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
               UPDATE fonoper2
                  SET cempres = pcempres,
                      foperac = f_sysdate,
                      iuniact = piuniact,
                      nunicmp = v_nunicmp,
                      iimpcmp = v_iimpcmp,
                      iimpvnt = v_iimpvnt,
                      nunivnt = v_nunivnt,
                      ivalact = v_ivalact,
                      ctipope = 3,
                      ccesta = pccodfon,
                      cestado = 0,
                      ipatrimonio = ppatrimonio,
                      iuniactcmp = piuniactcmp,
                      iuniactcmpshw = piuniactcmpshw,
                      iuniactvtashw = piuniactvtashw
                WHERE ccodfon = pccodfon
                  AND TRUNC(fvalor) = TRUNC(pfvalor);
         END;
      -- fim Bug 17243 - 17/02/2011 - APD
      END IF;

      -- Bug 9031 - 07/04/2009 - RSC - Análisis adaptación productos indexados
      -- Añadimos el COMMIT
      COMMIT;
      -- Fin Bug 9031
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_grabaroperacionfinv;

   /*************************************************************************
      Sincroniza los valores de la operación (Introducción de valore liquidativos
      + operaciones)
      param in picompra_in     : Importe de compra
      param in pncompra_in     : Unidades de compra
      param in piventa_in      : Importe de venta
      param in pnventa_in      : Unidades de venta
      param in piuniact_in     : Valor liquidativo
      param out picompra_out   : Importe de compra
      param out pncompra_out   : Unidades de compra
      param out piventa_out    : Importe de venta
      param out pnventa_out    : Unidades de venta
      param out pivalact_out   : Valor de operación
      param out mensajes       : mesajes de error
      return                   : numerico
   *************************************************************************/
   -- Bug 9031 - 13/03/2009 - RSC -  iAxis: Análisis adaptación productos indexados
   FUNCTION f_sinccalcularoperacionfinv(
      picompra_in IN NUMBER,
      pncompra_in IN NUMBER,
      piventa_in IN NUMBER,
      pnventa_in IN NUMBER,
      piuniact_in IN NUMBER,
      picompra_out OUT NUMBER,
      pncompra_out OUT NUMBER,
      piventa_out OUT NUMBER,
      pnventa_out OUT NUMBER,
      pivalact_out OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_MD_OPERATIVA_FINV.F_SincCalcularOperacionFinv';
      vparam         VARCHAR2(500)
         := 'parámetros - picompra_in: ' || picompra_in || ', pncompra_in: ' || pncompra_in
            || ', piventa_in: ' || piventa_in || ', pnventa_in: ' || pnventa_in
            || ', piuniact_in: ' || piuniact_in;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vsquery        VARCHAR2(9000);
      vidioma        NUMBER := 2;
      v_max_reg      NUMBER;
      -- Bug 9031 - 07/04/2009 - RSC - Análisis adaptación productos indexados
      v_numerr       NUMBER;
   -- Fin Bug 9031
   BEGIN
      IF piuniact_in IS NULL
         OR piuniact_in = 0 THEN
         v_numerr := 9001373;
         RAISE e_param_error;
      END IF;

      -- Bug 9031 - 07/04/2009 - RSC - Análisis adaptación productos indexados
      -- Añadimos validaciones
      --IF picompra_in IS NULL
      --   AND pncompra_in IS NULL THEN
      --   v_numerr := 9001374;
      --   RAISE e_param_error;
      --END IF;

      --IF pnventa_in IS NULL
      --   AND piventa_in IS NULL THEN
      --   v_numerr := 9001375;
      --   RAISE e_param_error;
      --END IF;

      -- manda el importe de compra
      IF picompra_in IS NOT NULL THEN
         picompra_out := picompra_in;
         pncompra_out := picompra_in / piuniact_in;
      ELSE
         IF pncompra_in IS NOT NULL THEN
            picompra_out := pncompra_in * piuniact_in;
         ELSE
            picompra_out := NULL;
         END IF;

         pncompra_out := pncompra_in;
      END IF;

      -- Mandan las participaciones de venta
      IF pnventa_in IS NOT NULL THEN
         pnventa_out := pnventa_in;
         piventa_out := pnventa_in * piuniact_in;
      ELSE
         IF piventa_in IS NOT NULL THEN
            pnventa_out := piventa_in / piuniact_in;
         ELSE
            pnventa_out := NULL;
         END IF;

         piventa_out := piventa_in;
      END IF;

      IF pncompra_out IS NOT NULL
         AND pnventa_out IS NOT NULL THEN
         pivalact_out := (pncompra_out - pnventa_out) * piuniact_in;
      ELSE
         pivalact_out := NULL;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, v_numerr, vpasexec, vparam);
         RETURN v_numerr;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000052, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_sinccalcularoperacionfinv;

   /*************************************************************************
      Realiza la carga mediante fichero de valores liquidativos y operaciones.
      param in pruta      : ruta del fichero
      param in pfvalor    : Fecha de valoración
      param out mensajes  : mesajes de error
      return              : descripción del acto
   *************************************************************************/
   -- Bug 9031 - 13/03/2009 - RSC -  iAxis: Análisis adaptación productos indexados
   FUNCTION f_grabaroperacionfilefinv(
      pruta IN VARCHAR2,
      pcempres IN NUMBER,
      pfvalor IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_MD_OPERATIVA_FINV.F_GrabarOperacionFileFinv';
      vparam         VARCHAR2(500)
                               := 'parámetros - pruta: ' || pruta || ', pfvalor: ' || pfvalor;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vsquery        VARCHAR2(9000);
      vidioma        NUMBER := 2;
      v_max_reg      NUMBER;
      e_error        EXCEPTION;
      num_err        NUMBER;
      viunicomp      NUMBER;
      vuncompra      NUMBER;
      vunventa       NUMBER;
      viuniven       NUMBER;
      vpatrimonio    NUMBER;
      dirarxiu       VARCHAR2(2000);
      fitxerr        VARCHAR2(2000);
      v_ppathser     VARCHAR2(100);
   BEGIN
      -- Bug 14160 - RSC - 16/04/2010 - CEM800 - Adaptar packages de productos de inversión al nuevo módulo de siniestros
      num_err := pac_md_operativa_finv.f_get_directorio('PATH_VLIQ', v_ppathser, mensajes);

      -- Fin Bug 14160
      IF num_err <> 0 THEN
         RAISE e_error;
      END IF;

      num_err := pac_util.f_path_filename(pruta, dirarxiu, fitxerr);

      IF num_err <> 0 THEN
         RAISE e_error;
      END IF;

      IF dirarxiu IS NULL
         OR fitxerr IS NULL THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 112223, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN(1);
      END IF;

      num_err := pac_mantenimiento_fondos_finv.f_carga_fichero_vliquidativo(v_ppathser,
                                                                            fitxerr, pcempres,
                                                                            pfvalor);

      IF num_err <> 0 THEN
         RAISE e_error;
      END IF;

      FOR regs IN (SELECT *
                     FROM tmp_vliquidativos2
                    WHERE ffecha = pfvalor) LOOP
         -- si se trata de una actualización del importe de la compra
         IF regs.iunicomp != 0
            AND regs.uncompra != 0 THEN
            viunicomp := regs.iunicomp;
            vuncompra := regs.iunicomp / regs.vliq;
         END IF;

         -- si se trata de una actualización de las unidades de venta
         IF regs.unventa != 0
            AND regs.iuniven != 0 THEN
            vunventa := regs.unventa;
            viuniven := regs.unventa * regs.vliq;
         END IF;

         IF regs.iunicomp = 0
            AND regs.uncompra != 0 THEN
            viunicomp := regs.uncompra * regs.vliq;
         ELSE
            viunicomp := regs.iunicomp;
         END IF;

         IF regs.uncompra = 0
            AND regs.iunicomp != 0 THEN
            vuncompra := regs.iunicomp / regs.vliq;
         ELSE
            vuncompra := regs.uncompra;
         END IF;

         IF regs.iuniven = 0
            AND regs.unventa != 0 THEN
            viuniven := regs.unventa * regs.vliq;
         ELSE
            viuniven := regs.iuniven;
         END IF;

         IF regs.unventa = 0
            AND regs.iuniven != 0 THEN
            vunventa := regs.iuniven / regs.vliq;
         ELSE
            vunventa := regs.unventa;
         END IF;

         INSERT INTO fonoper2
                     (cempres, ccodfon, foperac, fvalor, iuniact, nunicmp,
                      iimpcmp, iimpvnt, nunivnt, ivalact, ctipope,
                      ccesta, cestado, iuniactvtashw, iuniactcmp, iuniactcmpshw)
              VALUES (pcempres, regs.ccesta, f_sysdate, regs.ffecha, regs.vliq, vuncompra,
                      viunicomp, viuniven, vunventa, (vuncompra - vunventa) * regs.vliq, 3,
                      regs.ccesta, 0, regs.vliqvtashw, regs.vliqcmp, regs.vliqcmpshw);
      END LOOP;

      -- Bug 9031 - 07/04/2009 - RSC - Análisis adaptación productos indexados
      -- Añadimos el COMMIT
      COMMIT;
      -- Fin Bug 9031
      RETURN 0;
   EXCEPTION
      WHEN e_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, num_err, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000052, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_grabaroperacionfilefinv;

   /*************************************************************************
      Realiza la valoración de fondos de inversión.
      param in pruta      : ruta del fichero
      param in pfvalor    : Fecha de valoración
      param out mensajes  : mesajes de error
      return              : descripción del acto
   *************************************************************************/
   -- Bug 9031 - 16/03/2009 - RSC -  iAxis: Análisis adaptación productos indexados
   FUNCTION f_valorarfinv(pfvalor IN DATE, pcempres IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := NULL;
      vobjectname    VARCHAR2(200) := 'PAC_MD_OPERATIVA_FINV.F_ValorarFinv';
      e_error        EXCEPTION;
   BEGIN
      --Recuperación de los recibos.
      -- JGM - bug 10824 -- 31/07/09 --añado empresa
      vnumerr := pac_mantenimiento_fondos_finv.f_valorar(pfvalor, pcempres);

      IF vnumerr <> 0 THEN
         RAISE e_error;
      END IF;

      -- Bug 9031 - 07/04/2009 - RSC - Análisis adaptación productos indexados
      -- Añadimos el COMMIT
      COMMIT;
      -- Fin Bug 9031
      RETURN vnumerr;
   EXCEPTION
      WHEN e_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, vnumerr, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000052, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_valorarfinv;

   /*************************************************************************
      Realiza la valoración de fondos de inversión.
      param in pruta      : ruta del fichero
      param in pfvalor    : Fecha de valoración
      param out mensajes  : mesajes de error
      return              : descripción del acto
   *************************************************************************/
   -- Bug 9031 - 16/03/2009 - RSC -  iAxis: Análisis adaptación productos indexados
   FUNCTION f_asignarfinv(
      pfvalor IN DATE,
      pcidioma IN NUMBER,
      pcempres IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := NULL;
      vobjectname    VARCHAR2(200) := 'PAC_MD_OPERATIVA_FINV.F_AsignarFinv';
      e_error        EXCEPTION;
   BEGIN
      --Recuperación de los recibos.
      -- JGM - bug 10824 -- 31/07/09 --añado empresa
      vnumerr := pac_mantenimiento_fondos_finv.f_asign_unidades(pfvalor, pcidioma, pcempres);

      IF vnumerr <> 0 THEN
         RAISE e_error;
      END IF;

/*
      vnumerr := pac_mantenimiento_fondos_finv.f_asign_unidades_shw(pfvalor, pcidioma,
                                                                    pcempres);

      IF vnumerr <> 0 THEN
         RAISE e_error;
      END IF;
*/    -- Bug 9031 - 07/04/2009 - RSC - Análisis adaptación productos indexados
      -- Añadimos el COMMIT
      COMMIT;
      -- Fin Bug 9031
      RETURN vnumerr;
   EXCEPTION
      WHEN e_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, vnumerr, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000052, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_asignarfinv;

   /*************************************************************************
      Función que nos retorna un literal con el estado a modificar los fondos
      de inversión.
      param in pfvalor     : codigo de fecha de valoración
      param out mensajes  : mesajes de error
      return              : descripción del acto
   *************************************************************************/
   -- Bug 9031 - 16/03/2009 - RSC -  iAxis: Análisis adaptación productos indexados
   FUNCTION f_estado_a_modificar(
      pcempres IN NUMBER,
      pfvalor IN DATE,
      paestado OUT VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN VARCHAR2 IS
      vaestado       VARCHAR2(30);
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := NULL;
      vobjectname    VARCHAR2(200) := 'PAC_MD_OPERATIVA_FINV.f_estado_a_modificar';
      e_error        EXCEPTION;
   BEGIN
      --Recuperación de los recibos.
      vaestado := pac_mantenimiento_fondos_finv.f_cambio_aestado(pcempres, pfvalor, paestado);
      RETURN vaestado;
   EXCEPTION
      WHEN e_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000052, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000052, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_estado_a_modificar;

     /*************************************************************************
      Función que nos retorna un literal con el estado a modificar los fondos
      de inversión.
      param in pfvalor     : codigo de fecha de valoración
      param out mensajes  : mesajes de error
      return              : descripción del acto
   *************************************************************************/
   -- Bug 9031 - 16/03/2009 - RSC -  iAxis: Análisis adaptación productos indexados
   FUNCTION f_cambio_estado(
      pcempres IN NUMBER,
      pfvalor IN DATE,
      paestado IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := NULL;
      vobjectname    VARCHAR2(200) := 'PAC_MD_OPERATIVA_FINV.f_cambio_a_estado';
      e_error        EXCEPTION;
   BEGIN
      --Recuperación de los recibos.
      vnumerr := pac_mantenimiento_fondos_finv.p_modifica_estadofondos(pcempres, pfvalor,
                                                                       paestado);

      IF vnumerr <> 0 THEN
         RAISE e_error;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN e_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, vnumerr, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000052, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_cambio_estado;

     /*************************************************************************
      Retorna el estado de los fondos de inversión.
      param in pcempres    : código de empresa
      param in pfvalor     : codigo de fecha de valoración
      param out mensajes  : mesajes de error
      return              : descripción del acto
   *************************************************************************/
   -- Bug 9031 - 16/03/2009 - RSC -  iAxis: Análisis adaptación productos indexados
   FUNCTION f_getestadofondosfinv(
      pcempres IN NUMBER,
      pfvalor IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN VARCHAR2 IS
      vnumerr        NUMBER;
      vestado        VARCHAR2(30);
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := NULL;
      vobjectname    VARCHAR2(200) := 'PAC_MD_OPERATIVA_FINV.F_SwitchToStateFinv';
      e_error        EXCEPTION;
   BEGIN
      --Recuperación de los recibos.
      vestado := pac_mantenimiento_fondos_finv.f_get_estado(pcempres, pfvalor);

      IF vestado IS NULL THEN
         RAISE e_error;
      END IF;

      RETURN vestado;
   EXCEPTION
      WHEN e_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000052, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000052, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_getestadofondosfinv;

   /*************************************************************************
      Recupera las entradas y salidas sin consolidar producidas a un fecha de
      valoración.
      param in pcempres     : codigo de empresa
      param in pccodfon     : codigo de fondo
      param in pfvalor      : codigo de valoración
      param out mensajes    : mesajes de error
      return                : descripción del acto
   *************************************************************************/
   -- Bug 9031 - 17/03/2009 - RSC -  iAxis: Análisis adaptación productos indexados
   FUNCTION f_getentradassalidasfinv(
      pcempres IN NUMBER,
      pfvalor IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN t_iax_entradasalida IS
      vobjectname    VARCHAR2(500) := 'PAC_MD_OPERATIVA_FINV.F_GetEntradasSalidasFinv';
      vparam         VARCHAR2(500)
                         := 'parámetros - pcempres: ' || pcempres || ', pfvalor: ' || pfvalor;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vcursor        sys_refcursor;
      vsquery        VARCHAR2(9000);
      vidioma        NUMBER := 2;
      v_max_reg      NUMBER;
      -- Variables de salida de PAC_MANTENIMIENTO_FONDOS_ULK.f_proponer_entradas_salidas
      vtentrada      NUMBER;
      vtsalidas      NUMBER;
      vtcompras      NUMBER;
      vtentunidades  NUMBER;
      vtsalunidades  NUMBER;
      vsaldocesta    NUMBER;
      vfvalor        DATE;
      vliq           NUMBER;
      vliqcmp        NUMBER;
      vliqvtashw     NUMBER;
      vliqcmpshw     NUMBER;
      -- Variables de retorno
      -- Bug 9031 - 07/04/2009 - RSC - Análisis adaptación productos indexados
      -- Inicializamos vresultado
      vresultado     t_iax_entradasalida := t_iax_entradasalida();
   -- Fin Bug 9031
   BEGIN
      vpasexec := 1;

      FOR regs IN (SELECT   f.ccodfon, f.tfonabv, f.fultval, f.iuniact, f.iuniactcmp,
                            f.iuniactvtashw, f.iuniactcmpshw
                       FROM fondos f
                      WHERE f.cempres = NVL(pcempres, f.cempres)
                        --and f.ccodfon = NVL(pccodfon,f.ccodfon)
                        AND f.ffin IS NULL
                   ORDER BY f.ccodfon) LOOP
         BEGIN
            SELECT fvalor, iuniact, iuniactcmp, iuniactvtashw, iuniactcmpshw
              INTO vfvalor, vliq, vliqcmp, vliqvtashw, vliqcmpshw
              FROM tabvalces
             WHERE ccesta = regs.ccodfon
               AND fvalor = (SELECT MAX(t2.fvalor)
                               FROM tabvalces t2
                              WHERE t2.ccesta = regs.ccodfon
                                AND t2.fvalor <= pfvalor);
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               vfvalor := regs.fultval;
               vliq := regs.iuniact;
               vliqcmp := regs.iuniactcmp;
               vliqvtashw := regs.iuniactvtashw;
               vliqcmpshw := regs.iuniactcmpshw;
         END;

         vnumerr := pac_mantenimiento_fondos_finv.f_proponer_entradas_salidas(pfvalor,
                                                                              regs.ccodfon,
                                                                              vtentrada,
                                                                              vtsalidas,
                                                                              vtcompras,
                                                                              vtentunidades,
                                                                              vtsalunidades,
                                                                              vsaldocesta,
                                                                              vliq, vliqcmp,
                                                                              vliqvtashw,
                                                                              vliqcmpshw);
         vresultado.EXTEND;
         vresultado(vresultado.LAST) := ob_iax_entradasalida();
         vresultado(vresultado.LAST).ccodfon := regs.ccodfon;
         vresultado(vresultado.LAST).tfonabv := regs.tfonabv;
         vresultado(vresultado.LAST).fvalor := vfvalor;
         vresultado(vresultado.LAST).iuniult := vliq;
         vresultado(vresultado.LAST).iuniultcmp := vliqcmp;
         vresultado(vresultado.LAST).iuniultvtashw := vliqvtashw;
         vresultado(vresultado.LAST).iuniultcmpshw := vliqcmpshw;
         vresultado(vresultado.LAST).entradas := vtentrada;
         vresultado(vresultado.LAST).salidas := vtsalidas;
         vresultado(vresultado.LAST).pentrada := vtentunidades;
         vresultado(vresultado.LAST).psalidas := vtsalunidades;
         vresultado(vresultado.LAST).diferencia := vtcompras;
      END LOOP;

      RETURN vresultado;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN NULL;
   END f_getentradassalidasfinv;

   /*************************************************************************
      Generación de un fichero con las entradas y salidas sin consolidar producidas
      a un fecha de valoración.
      param in pcempres      : codigo de empresa
      param in pfvalor       : codigo de valoración
      param out pfichero_out : fichero de salida generado
      param out mensajes     : mesajes de error
      return                 : descripción del acto
   *************************************************************************/
   -- Bug 9031 - 17/03/2009 - RSC -  iAxis: Análisis adaptación productos indexados
   FUNCTION f_execfileentradassalidasfinv(
      pcempres IN NUMBER,
      pfvalor IN DATE,
      pfichero_out OUT VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER;
      vestado        VARCHAR2(30);
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := NULL;
      vobjectname    VARCHAR2(200) := 'PAC_MD_OPERATIVA_FINV.F_ExecFileEntradasSalidasFinv';
      e_error        EXCEPTION;
      perror         VARCHAR2(1000);
      vexcel         pac_excel.nombre_fichero_tabtyp;
      -- Bug 9031 - 07/04/2009 - RSC - Análisis adaptación productos indexados
      v_error        NUMBER;
      v_linia        VARCHAR2(2000);
      v_texto        VARCHAR2(200);
      -- Fin Bug 9031
      vsproces       NUMBER;   -- Bug 17373 - 04/02/2011 - AMC
      vcount         NUMBER;   -- Bug 17373 - 04/02/2011 - AMC
      vfichero       VARCHAR2(2000);
      pejecutarep    VARCHAR2(2000);
   BEGIN
      --Recuperación de los recibos.
      vexcel := pac_excel.f_sictr024finv(pac_md_common.f_get_cxtidioma, pfvalor, pcempres,
                                         NULL, NULL, NULL, vsproces, perror);

      IF vexcel IS NULL THEN
         RAISE e_error;
      END IF;

      pfichero_out := vexcel(1).nombre;
      -- Bug 9031 - 07/04/2009 - RSC - Análisis adaptación productos indexados
      -- Añadimos mensaje para pantalla al generar fichero .csv
      v_texto := f_axis_literales(105267, pac_md_common.f_get_cxtidioma) || pfichero_out;
      pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, v_error, v_texto);

      -- Fin Bug 9031

      -- Bug 17373 - 04/02/2011 - AMC
      SELECT COUNT(1)
        INTO vcount
        FROM map_codigos
       WHERE cmapead IN('433', '434');

      IF vcount > 0 THEN
         vnumerr := pac_map2.f_genera_xml('433', vsproces, TO_CHAR(pfvalor, 'YYYYMMDD'), 0,
                                          vfichero);
         vnumerr := pac_map2.f_genera_xml('434', vsproces, TO_CHAR(pfvalor, 'YYYYMMDD'), 0,
                                          vfichero);
      END IF;

      -- Fi Bug 17373 - 04/02/2011 - AMC
      RETURN 0;
   EXCEPTION
      WHEN e_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000052, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000052, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_execfileentradassalidasfinv;

   /***********************************************************************
       Recupera un path de directori
       param in pparam : valor de path
       param out ppath    : pàrametre PATH_VLIQ
       param out mensajes : missatge d'error
       return             : 0/1 -> Tot OK/Error
    ***********************************************************************/
   FUNCTION f_get_directorio(
      pparam IN VARCHAR2,
      ppath OUT VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_MD_OPERATIVA_FINV.F_Get_Directorio';
      vparam         VARCHAR2(500) := 'parámetros - pparam: ' || pparam;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(1) := 0;
   BEGIN
      ppath := f_parinstalacion_t(pparam);
      RETURN vnumerr;
   EXCEPTION
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_get_directorio;

   /***********************************************************************
        JGM 22-09-2009.
        Devolverá una colección de objetos T_IAX_TABVALCES, rsultado de buscar en la tabla tabvalces
        para el ccesta igual al parámetro pccesta.

      param in  pcempres : Cod. Empresa
      param in  pccesta : Cod. de la cesta
      param in  pcidioma: idioma
      param out mensajes : missatge d'error
      return             : t_iax_TABVALCES

      Bug 0011175:
   ***********************************************************************/
   -- BUG 21546_108727- 23/02/2012 - JLTS - Se elimin? funcion PAC_OPERATIVA_FINV.f_get_tabvalces
   -- y se uni?n esta
   FUNCTION f_get_tabvalces(
      pcempres IN NUMBER,
      pccesta IN NUMBER,
      pcidioma IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN t_iax_tabvalces IS
      vnumerr        NUMBER := 0;
      tabval         t_iax_tabvalces;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := NULL;
      vobjectname    VARCHAR2(200) := 'PAC_MD_OPERATIVA_FINV.f_get_tabvalces';
      iuniact_anterior tabvalces.iuniact%TYPE := NULL;
      vresta         tabvalces.iuniact%TYPE := NULL;
      v_texto        VARCHAR2(500);
      e_error        EXCEPTION;

      CURSOR c1 IS
         SELECT   t.*
             FROM tabvalces t, fondos f
            WHERE t.ccesta = f.ccodfon
              AND t.ccesta = pccesta
              AND f.cempres = pcempres
         ORDER BY fvalor DESC;

      v_c1           c1%ROWTYPE;
   BEGIN
      IF pccesta IS NULL
         OR pcempres IS NULL
         OR pcidioma IS NULL THEN
         RAISE e_object_error;
      END IF;

      vpasexec := 2;

      BEGIN
         OPEN c1;

         FETCH c1
          INTO v_c1;

         vpasexec := 3;
         tabval := t_iax_tabvalces();
         tabval.DELETE;
         vpasexec := 4;

         WHILE c1%FOUND LOOP
            tabval.EXTEND;
            tabval(tabval.LAST) := ob_iax_tabvalces();
            tabval(tabval.LAST).ccesta := v_c1.ccesta;
            tabval(tabval.LAST).fvalor := v_c1.fvalor;
            tabval(tabval.LAST).nparact := v_c1.nparact;
            tabval(tabval.LAST).iuniact := v_c1.iuniact;
            tabval(tabval.LAST).iuniultcmp := v_c1.iuniactcmp;
            tabval(tabval.LAST).iuniultvtashw := v_c1.iuniactvtashw;
            tabval(tabval.LAST).iuniultcmpshw := v_c1.iuniactcmpshw;
            tabval(tabval.LAST).ivalact := v_c1.ivalact;
            tabval(tabval.LAST).nparasi := v_c1.nparasi;
            tabval(tabval.LAST).igastos := v_c1.igastos;
            vpasexec := 5;

            BEGIN
               SELECT ff_desvalorfijo(932, pcidioma, TO_CHAR(v_c1.fvalor, 'd'))
                 INTO tabval(tabval.LAST).diasem
                 FROM DUAL;
            EXCEPTION
               WHEN OTHERS THEN
                  tabval(tabval.LAST).diasem := '';
            END;

            vpasexec := 6;
            /*IF iuniact_anterior IS NULL THEN
               tabval(tabval.LAST).varinum := 0;
               tabval(tabval.LAST).varisig := '=';
            ELSE
               vresta := v_c1.iuniact - iuniact_anterior;

               IF vresta = 0 THEN
                  tabval(tabval.LAST).varinum := 0;
                  tabval(tabval.LAST).varisig := '=';
               ELSIF vresta > 0 THEN
                  tabval(tabval.LAST).varinum := vresta;
                  tabval(tabval.LAST).varisig := '+';
               ELSIF vresta < 0 THEN
                  tabval(tabval.LAST).varinum := vresta * -1;
                  tabval(tabval.LAST).varisig := '-';
               END IF;
            END IF;*/
            iuniact_anterior := v_c1.iuniact;

            FETCH c1
             INTO v_c1;

            vpasexec := 7;

            IF c1%FOUND THEN
               vresta := v_c1.iuniact - iuniact_anterior;
               vpasexec := 8;

               IF vresta = 0 THEN
                  tabval(tabval.LAST).varinum := 0;
                  tabval(tabval.LAST).varisig := '=';
               ELSIF vresta > 0 THEN
                  tabval(tabval.LAST).varinum := vresta;
                  tabval(tabval.LAST).varisig := '-';
               ELSIF vresta < 0 THEN
                  tabval(tabval.LAST).varinum := vresta * -1;
                  tabval(tabval.LAST).varisig := '+';
               END IF;
            ELSE
               vpasexec := 9;
               --es el ?ltimo
               tabval(tabval.LAST).varinum := 0;
               tabval(tabval.LAST).varisig := '=';
            END IF;
         END LOOP;

         CLOSE c1;
      EXCEPTION
         WHEN OTHERS THEN
            vpasexec := 10;
            vnumerr := 1;
      END;

      vpasexec := 11;

      --Recuperación de los recibos.
--      tabval := pac_operativa_finv.f_get_tabvalces(pcempres, pccesta, pcidioma, vnumerr);
      IF vnumerr <> 0 THEN
         vpasexec := 12;
         v_texto := f_axis_literales(1000254, pac_md_common.f_get_cxtidioma);
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, vnumerr, v_texto);
         RAISE e_error;
      END IF;

      RETURN tabval;
   EXCEPTION
      WHEN e_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000052, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000052, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_tabvalces;

   /*************************************************************************
      Recupera las entradas y salidas sin consolidar producidas a un fecha de
      valoración (nueva versión CRE).
      param in pcempres     : codigo de empresa
      param in pccodfon     : codigo de fondo
      param in pfvalor      : codigo de valoración
      param out mensajes    : mesajes de error
      return                : descripción del acto
   *************************************************************************/
   -- Bug 10828 - 14/10/2009 - RSC - CRE - Revisión de los productos PPJ dinámico y Pla Estudiant (ajustes)
   FUNCTION f_getentsal_ampliado(
      pcempres IN NUMBER,
      pfvalor IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN t_iax_entradasalida IS
      vobjectname    VARCHAR2(500) := 'PAC_MD_OPERATIVA_FINV.f_getentsal_ampliado';
      vparam         VARCHAR2(500)
                         := 'parámetros - pcempres: ' || pcempres || ', pfvalor: ' || pfvalor;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vcursor        sys_refcursor;
      vsquery        VARCHAR2(9000);
      vidioma        NUMBER := 2;
      v_max_reg      NUMBER;
      -- Variables de salida de PAC_MANTENIMIENTO_FONDOS_ULK.f_proponer_entradas_salidas
      vtentrada      NUMBER;
      -- Bug 20309 - RSC - 30/11/2011 - LCOL_T004-Parametrización Fondos
      vtentrada_penali NUMBER;
      -- Fin Bug 20309
      vtentrada_teo  NUMBER;
      vtsalidas      NUMBER;
      vtsalidas_teo  NUMBER;
      vtcompras      NUMBER;
      vtentunidades  NUMBER;
      vtentunidades_teo NUMBER;
      vtsalunidades  NUMBER;
      vtsalunidades_teo NUMBER;
      vsaldocesta    NUMBER;
      vfvalor        DATE;
      vliq           NUMBER;
      vliqcmp        NUMBER;
      vliqvtashw     NUMBER;
      vliqcmpshw     NUMBER;
      -- Variables de retorno
      -- Bug 9031 - 07/04/2009 - RSC - Análisis adaptación productos indexados
      -- Inicializamos vresultado
      vresultado     t_iax_entradasalida := t_iax_entradasalida();
   -- Fin Bug 9031
   BEGIN
      vpasexec := 1;

      FOR regs IN (SELECT   f.ccodfon, f.tfonabv, f.fultval, f.iuniact, f.iuniactcmp,
                            f.iuniactvtashw, f.iuniactcmpshw
                       FROM fondos f
                      WHERE f.cempres = NVL(pcempres, f.cempres)
                        --and f.ccodfon = NVL(pccodfon,f.ccodfon)
                        AND f.ffin IS NULL
                   ORDER BY f.ccodfon) LOOP
         BEGIN
            SELECT fvalor, iuniact, iuniactcmp, iuniactvtashw, iuniactcmpshw
              INTO vfvalor, vliq, vliqcmp, vliqvtashw, vliqcmpshw
              FROM tabvalces
             WHERE ccesta = regs.ccodfon
               AND fvalor = (SELECT MAX(t2.fvalor)
                               FROM tabvalces t2
                              WHERE t2.ccesta = regs.ccodfon
                                AND t2.fvalor <= pfvalor);
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               vfvalor := regs.fultval;
               vliq := regs.iuniact;
               vliqcmp := regs.iuniactcmp;
               vliqvtashw := regs.iuniactvtashw;
               vliqcmpshw := regs.iuniactcmpshw;
         END;

         vnumerr := pac_mantenimiento_fondos_finv.f_proponer_ent_sal(pfvalor, regs.ccodfon,
                                                                     vtentrada, vtentrada_teo,
                                                                     vtsalidas, vtsalidas_teo,
                                                                     vtentunidades,
                                                                     vtentunidades_teo,
                                                                     vtsalunidades,
                                                                     vtsalunidades_teo,
                                                                     vtcompras, vliq, vliqcmp,
                                                                     vliqvtashw, vliqcmpshw,
                                                                     vtentrada_penali);
         vresultado.EXTEND;
         vresultado(vresultado.LAST) := ob_iax_entradasalida();
         vresultado(vresultado.LAST).ccodfon := regs.ccodfon;
         vresultado(vresultado.LAST).tfonabv := regs.tfonabv;
         vresultado(vresultado.LAST).fvalor := vfvalor;
         vresultado(vresultado.LAST).iuniult := vliq;
         vresultado(vresultado.LAST).iuniultcmp := vliqcmp;
         vresultado(vresultado.LAST).iuniultvtashw := vliqvtashw;
         vresultado(vresultado.LAST).iuniultcmpshw := vliqcmpshw;
         vresultado(vresultado.LAST).entradas := vtentrada;
         -- Bug 20309 - RSC - 30/11/2011 - LCOL_T004-Parametrización Fondos
         vresultado(vresultado.LAST).entradas_penali := vtentrada_penali;
         -- Fin Bug 20309
         vresultado(vresultado.LAST).entradas_teo := vtentrada_teo;
         vresultado(vresultado.LAST).salidas := vtsalidas;
         vresultado(vresultado.LAST).salidas_teo := vtsalidas_teo;
         vresultado(vresultado.LAST).pentrada := vtentunidades;
         vresultado(vresultado.LAST).pentrada_teo := vtentunidades_teo;
         vresultado(vresultado.LAST).psalidas := vtsalunidades;
         vresultado(vresultado.LAST).psalidas_teo := vtsalunidades_teo;
         vresultado(vresultado.LAST).diferencia := vtcompras;
      END LOOP;

      RETURN vresultado;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN NULL;
   END f_getentsal_ampliado;

   /*************************************************************************
      FUNCTION f_control_valorpart
      param in pcempres     : codigo de empresa
      param in pccodfon     : codigo de fondo
      param in pfvalor      : codigo de valoración
      param in piuniact     : iuniact
      param out mensajes    : mesajes de error
      return                : literal
      --BUG 13510 - JTS - 12/03/2010
   *************************************************************************/
   FUNCTION f_control_valorpart(
      pcempres IN NUMBER,
      pccodfon IN NUMBER,
      pfvalor IN DATE,
      piuniact IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_MD_OPERATIVA_FINV.f_control_valorpart';
      vparam         VARCHAR2(500)
         := 'parámetros - pcempres: ' || pcempres || ', pccodfon: ' || pccodfon
            || ', pfvalor: ' || pfvalor || ', piuniact: ' || piuniact;
      vpasexec       NUMBER(5) := 1;
      v_iuniact_aux  NUMBER;
      v_texto        VARCHAR2(1000);
      v_vvliquida    NUMBER;
      v_texto2       VARCHAR2(1000);
      v_error        NUMBER;
      v_sproduc      NUMBER;
      v_vliquidafijo NUMBER;   -- Bug 15707 - APD - 28/02/2011
   BEGIN
      SELECT MAX(p.sproduc)
        INTO v_sproduc
        FROM productos p, modinvfondo m, fondos f
       WHERE m.ccodfon = f.ccodfon
         AND f.ccodfon = pccodfon
         AND p.cramo = m.cramo
         AND p.cmodali = m.cmodali
         AND p.ctipseg = m.ctipseg
         AND p.ccolect = m.ccolect
         AND f.cempres = pcempres;

      BEGIN
         SELECT t.iuniact
           INTO v_iuniact_aux
           FROM tabvalces t, fondos f
          WHERE t.fvalor = (SELECT MAX(fvalor)
                              FROM tabvalces
                             WHERE fvalor < pfvalor
                               AND ccesta = t.ccesta)
            AND ccesta = pccodfon
            AND t.ccesta = f.ccodfon
            AND f.cempres = pcempres;

         v_error := f_parproductos(v_sproduc, 'VAR_VAL_LIQUIDATIVO', v_vvliquida);

         IF v_error = 0 THEN
            IF piuniact >(v_iuniact_aux *(1 +(v_vvliquida / 100)))
               OR piuniact <(v_iuniact_aux *(1 -(v_vvliquida / 100))) THEN
               v_texto := f_axis_literales(9901062, pac_md_common.f_get_cxtidioma);
               v_texto2 := f_axis_literales(9901063, pac_md_common.f_get_cxtidioma);
               pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, NULL,
                                                    v_texto || v_vvliquida || v_texto2);
               RETURN 1;
--            ELSE
--               RETURN 0;
            END IF;
         ELSE
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, v_error, NULL);
            RETURN 1;
         END IF;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
--            RETURN 0;
            NULL;
      END;

      -- Bug 15707 - APD - 28/02/2011 - Si el valor del parametro piuniact es diferente al valor
      -- del parproducto 'VAL_LIQUIDA_FIJO', entonces se informará de un error
      v_error := f_parproductos(v_sproduc, 'VAL_LIQUIDA_FIJO', v_vliquidafijo);

      IF v_error = 0 THEN
         IF piuniact <> v_vliquidafijo THEN
            v_texto := f_axis_literales(9901865, pac_md_common.f_get_cxtidioma);   -- El Valor liquidativo debe ser
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, NULL,
                                                 v_texto || ' ' || v_vliquidafijo);
            RETURN 1;
--         ELSE
--            RETURN 0;
         END IF;
      ELSE
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, v_error, NULL);
         RETURN 1;
      END IF;

      -- Fin Bug 15707 - APD - 28/02/2011
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_control_valorpart;

   /*************************************************************************
      FUNCTION f_filecotizaciones
      param in pruta        : ruta del fichero
      param in pcempres     : codigo de empresa
      param in pfvalor      : codigo de valoración
      param in out mensajes : mesajes de error
      return                : 0 ok
                              1 ko
      --BUG 18136 - JTS - 06/04/2011
   *************************************************************************/
   FUNCTION f_filecotizaciones(
      pruta IN VARCHAR2,
      pcempres IN NUMBER,
      pfvalor IN DATE,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := NULL;
      vobject        VARCHAR2(200) := 'PAC_MD_OPERATIVA_FINV.F_filecotizaciones';
      vnerror        VARCHAR2(50);
      vsinterf       NUMBER;
   BEGIN
      SELECT sinterf.NEXTVAL
        INTO vsinterf
        FROM DUAL;

      vpasexec := 2;
      vnerror := pac_map.f_carga_map('IC001', vsinterf, pruta, 0);
      vpasexec := 3;

      IF vnerror LIKE '0|%' THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, 9001809);
         COMMIT;
      ELSE
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9001896);
         ROLLBACK;
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_filecotizaciones;

   /*************************************************************************
      Recupera las cotizaciones de monedas
      param in pcmonori   :  moneda origen
      param in pcmondes   :  moneda destino
      param out mensajes  :  mesajes de error
      return              :  sys_refcursor
   *************************************************************************/
   -- Bug 18136 - JTS - 07/04/2011
		FUNCTION f_getcotizaciones(
      pcmonori IN VARCHAR2,
      pcmondes IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vobjectname    VARCHAR2(500) := 'PAC_MD_OPERATIVA_FINV.f_getcotizaciones';
      vparam         VARCHAR2(500)
                       := 'parámetros - pcmonori: ' || pcmonori || ', pcmondes: ' || pcmondes;
      vpasexec       NUMBER(5) := 1;
      vcursor        sys_refcursor;
      vsquery        VARCHAR2(4000);
   BEGIN
      vpasexec := 1;
      vsquery :=
         'SELECT   ed2.tmoneda monedaorigen, ed2.cmoneda cmonori, ed1.cmoneda cmondest,
         ed1.tmoneda monedadestino, et.itasa, et.fcambio
    FROM eco_tipocambio et, eco_desmonedas ed1, eco_desmonedas ed2
   WHERE et.cmondes = ed1.cmoneda
     AND et.cmonori = ed2.cmoneda
     AND ed2.cidioma = '
         || pac_md_common.f_get_cxtidioma() || ' AND ed1.cidioma = ed2.cidioma ';

      IF pcmondes IS NOT NULL THEN
         vsquery := vsquery || ' AND et.cmondes = ''' || pcmondes || CHR(39);
      END IF;

      IF pcmonori IS NOT NULL THEN
         vsquery := vsquery || ' AND et.cmonori = ''' || pcmonori || CHR(39);
      END IF;

      vsquery :=
         vsquery
         || ' AND et.fcambio IN (SELECT max (fcambio )
                         FROM eco_tipocambio etp
                        WHERE etp.cmondes = ed1.cmoneda
                          AND etp.cmonori = ed2.cmoneda)
            order by ed2.tmoneda asc';
      vcursor := pac_iax_listvalores.f_opencursor(vsquery, mensajes);
      RETURN vcursor;
   EXCEPTION
      WHEN OTHERS THEN
         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN vcursor;
   END f_getcotizaciones;

   /*************************************************************************
      Recupera las monedas
      param out mensajes  :  mesajes de error
      return              :  sys_refcursor
   *************************************************************************/
   -- Bug 18136 - JTS - 07/04/2011
   FUNCTION f_monedas(mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vobjectname    VARCHAR2(500) := 'PAC_MD_OPERATIVA_FINV.f_monedas';
      vparam         VARCHAR2(500) := '';
      vpasexec       NUMBER(5) := 1;
      vcursor        sys_refcursor;
      vsquery        VARCHAR2(4000);
   BEGIN
      vpasexec := 1;
      vsquery :=
         ' select m.cmoneda, d.tmoneda
  from eco_codmonedas m, eco_desmonedas D
  where bvisualiza = 1 and
  m.CMONEDA = d.CMONEDA and cidioma = '
         || pac_md_common.f_get_cxtidioma() || ' order by d.tmoneda asc';
      vcursor := pac_iax_listvalores.f_opencursor(vsquery, mensajes);
      RETURN vcursor;
   EXCEPTION
      WHEN OTHERS THEN
         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN vcursor;
   END f_monedas;

   /*************************************************************************
      Recupera el histórico de cotizaciones de monedas
      param in pcmonori   :  moneda origen
      param in pcmondes   :  moneda destino
      param out mensajes  :  mesajes de error
      return              :  sys_refcursor
   *************************************************************************/
   -- Bug 18136 - JTS - 07/04/2011
   FUNCTION f_gethistcotizaciones(
      pcmonori IN VARCHAR2,
      pcmondes IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vobjectname    VARCHAR2(500) := 'PAC_MD_OPERATIVA_FINV.f_gethistcotizaciones';
      vparam         VARCHAR2(500)
                       := 'parámetros - pcmonori: ' || pcmonori || ', pcmondes: ' || pcmondes;
      vpasexec       NUMBER(5) := 1;
      vcursor        sys_refcursor;
      vsquery        VARCHAR2(4000);
   BEGIN
      vpasexec := 1;
      vsquery :=
         'SELECT   ed2.tmoneda monedaorigen, ed2.cmoneda cmonori, ed1.cmoneda cmondest,
         ed1.tmoneda monedadestino, et.itasa, et.fcambio
    FROM eco_tipocambio et, eco_desmonedas ed1, eco_desmonedas ed2
   WHERE et.cmondes = ed1.cmoneda
     AND et.cmonori = ed2.cmoneda
     AND ed2.cidioma = '
         || pac_md_common.f_get_cxtidioma() || ' AND ed1.cidioma = ed2.cidioma ';

      IF pcmondes IS NOT NULL THEN
         vsquery := vsquery || ' AND et.cmondes = ''' || pcmondes || CHR(39);
      END IF;

      IF pcmonori IS NOT NULL THEN
         vsquery := vsquery || ' AND et.cmonori = ''' || pcmonori || CHR(39);
      END IF;

      vsquery := vsquery || ' order by et.fcambio desc';
      vcursor := pac_iax_listvalores.f_opencursor(vsquery, mensajes);
      RETURN vcursor;
   EXCEPTION
      WHEN OTHERS THEN
         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN vcursor;
   END f_gethistcotizaciones;

   /*************************************************************************
      Recupera nueva cotizacion de monedas
      param in pcmonori   :  moneda origen
      param in pcmondes   :  moneda destino
      param out mensajes  :  mesajes de error
      return              :  sys_refcursor
   *************************************************************************/
   -- Bug 18136 - JTS - 07/04/2011
   FUNCTION f_newcotizacion(
      pcmonori IN VARCHAR2,
      pcmondes IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vobjectname    VARCHAR2(500) := 'PAC_MD_OPERATIVA_FINV.f_newcotizacion';
      vparam         VARCHAR2(500)
                       := 'parámetros - pcmonori: ' || pcmonori || ', pcmondes: ' || pcmondes;
      vpasexec       NUMBER(5) := 1;
      vcursor        sys_refcursor;
      vsquery        VARCHAR2(4000);
   BEGIN
      vpasexec := 1;
      vsquery :=
         'SELECT   ed2.tmoneda monedaorigen, ed2.cmoneda cmonori, ed1.cmoneda cmondest,
         ed1.tmoneda monedadestino, 0 itasa, (et.fcambio+1) fcambio
    FROM eco_tipocambio et, eco_desmonedas ed1, eco_desmonedas ed2
   WHERE et.cmondes = ed1.cmoneda
     AND et.cmonori = ed2.cmoneda
     AND ed2.cidioma = '
         || pac_md_common.f_get_cxtidioma() || ' AND ed1.cidioma = ed2.cidioma ';

      IF pcmondes IS NOT NULL THEN
         vsquery := vsquery || ' AND et.cmondes = ''' || pcmondes || CHR(39);
      END IF;

      IF pcmonori IS NOT NULL THEN
         vsquery := vsquery || ' AND et.cmonori = ''' || pcmonori || CHR(39);
      END IF;

      vsquery :=
         vsquery
         || ' AND et.fcambio = (SELECT MAX(fcambio)
                         FROM eco_tipocambio etp
                        WHERE etp.cmondes = ed1.cmoneda
                          AND etp.cmonori = ed2.cmoneda)';
      vcursor := pac_iax_listvalores.f_opencursor(vsquery, mensajes);
      RETURN vcursor;
   EXCEPTION
      WHEN OTHERS THEN
         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN vcursor;
   END f_newcotizacion;

   /*************************************************************************
      Crea nueva cotizacion de monedas
      param in pcmonori   :  moneda origen
      param in pcmondes   :  moneda destino
      param out mensajes  :  mesajes de error
      return              :  error
   *************************************************************************/
   -- Bug 18136 - JTS - 07/04/2011
   FUNCTION f_creacotizacion(
      pcmonori IN VARCHAR2,
      pcmondes IN VARCHAR2,
      pfvalor IN DATE,
      ptasa IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_MD_OPERATIVA_FINV.f_creacotizacion';
      vparam         VARCHAR2(500)
         := 'parámetros - pcmonori: ' || pcmonori || ', pcmondes: ' || pcmondes
            || ', pfvalor: ' || TO_CHAR(pfvalor, 'ddmmyyyy') || ', ptasa: ' || ptasa;
      vpasexec       NUMBER(5) := 1;
      v_count        NUMBER;
   BEGIN
      vpasexec := 1;

      IF pcmonori = pcmondes THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9901985);
         RAISE e_object_error;
      END IF;

      vpasexec := 2;

      BEGIN
         INSERT INTO eco_tipocambio
                     (cmonori, cmondes, fcambio, itasa, cusualt, falta)
              VALUES (pcmonori, pcmondes, pfvalor, ptasa, f_user, f_sysdate);
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
            UPDATE eco_tipocambio
               SET itasa = ptasa
             WHERE cmonori = pcmonori
               AND cmondes = pcmondes
               AND fcambio = pfvalor;
      END;

      RETURN 0;
   EXCEPTION
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_creacotizacion;

   /*************************************************************************
      Recupera los gastos de los fondos
      param in pcempres   :
      param in pccodfon   :
      param out mensajes  :  mesajes de error
      return              :  sys_refcursor
   *************************************************************************/
   --BUG18799 - JTS - 16/06/2011
   FUNCTION f_get_fongastos(
      pcempres IN NUMBER,
      pccodfon IN NUMBER,
      pcidioma IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vobjectname    VARCHAR2(500) := 'PAC_MD_OPERATIVA_FINV.f_get_fongastos';
      vparam         VARCHAR2(500)
         := 'parámetros - pcempres: ' || pcempres || ', pccodfon: ' || pccodfon
            || ', pcidioma: ' || pcidioma;
      vpasexec       NUMBER(5) := 1;
      vcursor        sys_refcursor;
   BEGIN
      vpasexec := 1;
      vcursor := pac_operativa_finv.f_get_gastos(pcempres, pccodfon, pcidioma);
      RETURN vcursor;
   EXCEPTION
      WHEN OTHERS THEN
         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN vcursor;
   END f_get_fongastos;

   /*************************************************************************
      Recupera los gastos de los fondos
      param in pcempres   :
      param in pccodfon   :
      param out mensajes  :  mesajes de error
      return              :  sys_refcursor
   *************************************************************************/
   --BUG18799 - JTS - 16/06/2011
   FUNCTION f_get_fongastos_hist(
      pccodfon IN NUMBER,
      pcidioma IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vobjectname    VARCHAR2(500) := 'PAC_MD_OPERATIVA_FINV.f_get_fongastos_hist';
      vparam         VARCHAR2(500)
                       := 'parámetros - pccodfon: ' || pccodfon || ', pcidioma: ' || pcidioma;
      vpasexec       NUMBER(5) := 1;
      vcursor        sys_refcursor;
   BEGIN
      vpasexec := 1;
      vcursor := pac_operativa_finv.f_get_gastos_hist(pccodfon, pcidioma);
      RETURN vcursor;
   EXCEPTION
      WHEN OTHERS THEN
         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN vcursor;
   END f_get_fongastos_hist;

   /*************************************************************************
      FUNCTION f_set_reggastos
      param out mensajes  :  mesajes de error
      return              :  error
   *************************************************************************/
   --BUG18799 - JTS - 16/06/2011
   FUNCTION f_set_reggastos(
      pccodfon IN NUMBER,
      pfinicio IN DATE,
      pffin IN DATE,
      piimpmin IN NUMBER,
      piimpmax IN NUMBER,
      pcdivisa IN NUMBER,
      ppgastos IN NUMBER,
      piimpfij IN NUMBER,
      pcolumn9 IN NUMBER,
      pctipcom IN NUMBER,
      pcconcep IN NUMBER,
      pctipocalcul IN NUMBER,
      pclave IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_MD_OPERATIVA_FINV.f_set_reggastos';
      vparam         VARCHAR2(500)
                       := 'parámetros - pccodfon: ' || pccodfon || ', pfinicio: ' || pfinicio;
      vpasexec       NUMBER(5) := 1;
      verror         NUMBER;
      vpcdivisa      NUMBER;
   BEGIN
      IF pcdivisa IS NULL THEN
         BEGIN
            SELECT NVL(cdivisa, pac_md_common.f_get_parinstalacion_n('MONEDAINST'))
              INTO vpcdivisa
              FROM fonpensiones
             WHERE ccodfon = pccodfon;
         EXCEPTION
            WHEN OTHERS THEN
               vpcdivisa := pac_md_common.f_get_parinstalacion_n('MONEDAINST');
         END;
      ELSE
         vpcdivisa := pcdivisa;
      END IF;

      verror := pac_operativa_finv.f_insert_reggastos(pccodfon, pfinicio, pffin, piimpmin,
                                                      piimpmax, vpcdivisa, ppgastos, piimpfij,
                                                      pcolumn9, pctipcom, pcconcep,
                                                      pctipocalcul, pclave);

      IF verror > 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, verror);
         RAISE e_object_error;
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
   END f_set_reggastos;

   /*************************************************************************
      Retorna si ha de mostrar o no la icone de impresora.
      També retorna el literal que es comenta en el bug "Pòlissa amb operacions pedents de valorar"
      param in pcempres   :
      param in psseguro   :
      param in pcidioma   :
      param out mensajes  :  mesajes de error
      return              :  sys_refcursor
   *************************************************************************/
   FUNCTION f_op_pdtes_valorar(
      pcempres IN NUMBER,
      psseguro IN NUMBER,
      pcidioma IN NUMBER,
      pliteral IN OUT VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_MD_OPERATIVA_FINV.f_op_pdtes_valorar';
      vparam         VARCHAR2(500)
         := 'parámetros - pcempres: ' || pcempres || ', psseguro: ' || psseguro
            || ', pcidioma: ' || pcidioma;
      vpasexec       NUMBER(5) := 1;
      vnumero        NUMBER := 1;
   BEGIN
      vpasexec := 1;
      vnumero := pac_operativa_finv.f_op_pdtes_valorar(pcempres, psseguro, pcidioma, pliteral);
      RETURN vnumero;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN vnumero;
   END f_op_pdtes_valorar;

    /*************************************************************************
       Recupera los datos de fondos contratados en la poliza.
      param in psseguro   :
      param out pfondos
      param out mensajes  :  mesajes de error

   *************************************************************************/
   FUNCTION f_get_datos_rescate(
      psseguro IN NUMBER,
      pctipcal IN NUMBER,
      pfondos OUT t_iax_datos_fnd,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpsproduc      NUMBER;
      vnmaxuni       NUMBER := 0;
      vnmaximporte   NUMBER := 0;
      vtotalcestas   NUMBER := 0;
      vnmaxunishw    NUMBER := 0;
      vnmaximporteshw NUMBER := 0;
      vtotalcestasshw NUMBER := 0;
      v_error        NUMBER := 0;
      usashw         NUMBER;
      precio_cesta   NUMBER := 0;

      CURSOR datosfnd IS
         (SELECT sdi2.*, f.tfonabv AS tcesta, t.fvalor, t.ivalact
            FROM segdisin2 sdi2, fondos f, tabvalces t
           WHERE sdi2.ccesta = f.ccodfon
             AND sdi2.sseguro = psseguro
             AND sdi2.ffin IS NULL
             AND t.ccesta = sdi2.ccesta
             AND t.fvalor = (SELECT MAX(fvalor)
                               FROM tabvalces
                              WHERE sdi2.ccesta = ccesta)
             AND nmovimi = (SELECT MAX(nmovimi)
                              FROM segdisin2
                             WHERE ccesta = sdi2.ccesta
                               AND sseguro = sdi2.sseguro));
   BEGIN
      SELECT sproduc
        INTO vpsproduc
        FROM seguros
       WHERE sseguro = psseguro;

      IF NVL(pac_parametros.f_parproducto_n(vpsproduc, 'RESCATE_UNIDAD_PEND'), 0) IN(2, 3) THEN
         pfondos := t_iax_datos_fnd();

         FOR fondo IN datosfnd LOOP
            usashw := pac_propio.f_usar_shw(psseguro, NULL);
            pfondos.EXTEND;
            pfondos(pfondos.LAST) := ob_iax_datos_fnd();
            vnmaxuni := 0;
            vnmaximporte := 0;
            vtotalcestas := 0;

            --
            IF pctipcal = 3 THEN
               --
               IF NVL(usashw, 0) = 1 THEN
                  --
                  v_error := pac_operativa_finv.f_get_imppb_shw(psseguro, fondo.ccesta,
                                                                f_sysdate, vnmaximporte);

                  --
                  IF v_error <> 0 THEN
                     RETURN v_error;
                  END IF;
               --
               ELSE
                  --
                  v_error := pac_operativa_finv.f_get_imppb(psseguro, fondo.ccesta, f_sysdate,
                                                            vnmaximporte);

                  --
                  IF v_error <> 0 THEN
                     RETURN v_error;
                  END IF;
               --
               END IF;

               --
               BEGIN
                  --
                  SELECT NVL(iuniact, 0)
                    INTO precio_cesta
                    FROM tabvalces
                   WHERE ccesta = fondo.ccesta
                     AND TRUNC(fvalor) = fondo.fvalor;
               --
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     precio_cesta := 0;
               END;

               --
               IF precio_cesta = 0 THEN
                  vnmaxuni := 0;
               ELSE
                  vnmaxuni := NVL(vnmaximporte, 0) / precio_cesta;
               END IF;
            --
            ELSE
               --
               IF NVL(usashw, 0) = 1 THEN
                  v_error := pac_operativa_finv.f_cta_saldo_fondos_cesta_shw(psseguro, NULL,
                                                                             fondo.ccesta,
                                                                             vnmaxuni,
                                                                             vnmaximporte,
                                                                             vtotalcestas);

                  IF v_error <> 0 THEN
                     RETURN v_error;
                  END IF;
               ELSE
                  v_error := pac_operativa_finv.f_cta_saldo_fondos_cesta(psseguro, NULL,
                                                                         fondo.ccesta,
                                                                         vnmaxuni,
                                                                         vnmaximporte,
                                                                         vtotalcestas);

                  IF v_error <> 0 THEN
                     RETURN v_error;
                  END IF;
               END IF;
            END IF;

            pfondos(pfondos.LAST).cobliga := 1;
            pfondos(pfondos.LAST).ccesta := fondo.ccesta;
            pfondos(pfondos.LAST).tcesta := fondo.tcesta;
            pfondos(pfondos.LAST).nuniact := vnmaxuni;
            pfondos(pfondos.LAST).iimpact := f_round(vnmaximporte,
                                                     pac_monedas.f_moneda_seguro('SEG',
                                                                                 psseguro));
            pfondos(pfondos.LAST).fultval := fondo.fvalor;
         END LOOP;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           'PAC_MD_OPERATIVA_FINV.f_get_datos_rescate',
                                           1000001, 1, NULL, NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_get_datos_rescate;

   /******************************************************************************
    funcin que reaiza un switch por miporte

    param in:       psseguro
    param in:       pfecha
    param in:       plstfondos
    param out:      mensajes

   ******************************************************************************/
   FUNCTION f_switch_importe(
      psseguro IN NUMBER,
      pfecha IN DATE,
      plstfondos IN OUT t_iax_produlkmodinvfondo,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      verror         NUMBER;
      vobject        VARCHAR2(60) := 'PAC_MD_OPERATIVA_FINV.F_SWITCH_IMPORTE';
      vpasexec       NUMBER := 0;
      vparam         VARCHAR2(500)
                      := 'psseguro:' || psseguro || 'pfecha:' || TO_CHAR(pfecha, 'dd/mm/yyyy');
      vsumimporte    NUMBER := 0;
      vsumimporteant NUMBER := 0;
      vunidadescesta NUMBER := 0;
      vimporte       NUMBER := 0;
      vimportetot    NUMBER := 0;
      vusarshw       NUMBER := 0;
      vtotalseg      NUMBER := 0;
      vtotalsegcest  NUMBER := 0;
      v_det_modinv   pac_operativa_finv.tt_det_modinv;
      vpercent       NUMBER := 0;
      vlstfondos     ob_iax_produlkmodelosinv
                                             := pac_iax_produccion.poliza.det_poliza.modeloinv;
      vexistecfon    BOOLEAN;
      vcountsegdis   NUMBER;
   BEGIN
      vusarshw := NVL(pac_propio.f_usar_shw(psseguro, NULL), 0);

      IF vusarshw = 1 THEN
         verror := pac_operativa_finv.f_cta_saldo_fondos_shw(psseguro, NULL, vtotalseg,
                                                             vtotalsegcest, v_det_modinv);
      ELSE
         verror := pac_operativa_finv.f_cta_saldo_fondos(psseguro, NULL, vtotalseg,
                                                         vtotalsegcest, v_det_modinv);
      END IF;

      FOR i IN plstfondos.FIRST .. plstfondos.LAST LOOP
         IF plstfondos(i).ivalact < 0 THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, verror);
            RETURN 1;
         END IF;

         vunidadescesta := 0;
         vimporte := 0;
         vimportetot := 0;

         IF vusarshw = 1 THEN
            verror := pac_operativa_finv.f_cta_saldo_fondos_cesta_shw(psseguro, NULL,
                                                                      plstfondos(i).ccodfon,
                                                                      vunidadescesta,
                                                                      vimporte, vimportetot);
            vpercent := ROUND(plstfondos(i).ivalact * 100 / vtotalseg, 6);
         ELSE
            verror := pac_operativa_finv.f_cta_saldo_fondos_cesta(psseguro, NULL,
                                                                  plstfondos(i).ccodfon,
                                                                  vunidadescesta, vimporte,
                                                                  vimportetot);
            vpercent := ROUND(plstfondos(i).ivalact * 100 / vtotalseg, 6);
         END IF;

         p_tab_error(f_sysdate, f_user, 'PAC_MD_OPERATIVA.switch', 1,
                     'ccodfon:' || plstfondos(i).ccodfon || ' ivalact:'
                     || plstfondos(i).ivalact || ' PERCENT: ' || vpercent,
                     'aaaaa');
         plstfondos(i).pinvers := vpercent;
         vsumimporteant := vsumimporteant + vimporte;
         vsumimporte := vsumimporte + plstfondos(i).ivalact;
      END LOOP;

      p_tab_error(f_sysdate, f_user, 'PAC_MD_OPERATIVA.switch', 1,
                  'sumimporte:' || vsumimporte || 'vsumimporteant:' || vsumimporteant, 'aaaaa');

      IF vsumimporte > vsumimporteant THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1, f_axis_literales(109855));
         RETURN 109855;
      END IF;

      FOR i IN vlstfondos.modinvfondo.FIRST .. vlstfondos.modinvfondo.LAST LOOP
         vexistecfon := FALSE;

         FOR j IN plstfondos.FIRST .. plstfondos.LAST LOOP
            IF vlstfondos.modinvfondo(i).ccodfon = plstfondos(j).ccodfon THEN
               vlstfondos.modinvfondo(i).pinvers := plstfondos(j).pinvers;
               vexistecfon := TRUE;
            END IF;
         END LOOP;

         IF NOT vexistecfon THEN
            SELECT COUNT(1)
              INTO vcountsegdis
              FROM segdisin2
             WHERE sseguro = psseguro
               AND ccesta = vlstfondos.modinvfondo(i).ccodfon;

            IF vcountsegdis = 0 THEN
               vlstfondos.modinvfondo.DELETE(i);
            END IF;
         END IF;
      END LOOP;

      pac_iax_produccion.poliza.det_poliza.modeloinv := vlstfondos;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, 'PAC_MD_OPERATIVA_FINV.f_switch_importe',
                                           1000001, 1, NULL, NULL, SQLCODE, SQLERRM);
         RETURN 1000006;
   END f_switch_importe;

     /*************************************************************************
      Retorna el tipo de fondo
      param in pcempres    : código de empresa
      param in pfvalor     : codigo de fecha de valoración
      param out mensajes  : mesajes de error
      return              : descripción del acto
   *************************************************************************/
   FUNCTION f_getctipfonfinv(
      pcempres IN NUMBER,
      pccodfon IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER;
      vestado        VARCHAR2(30);
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := NULL;
      vobjectname    VARCHAR2(200) := 'PAC_MD_OPERATIVA_FINV.f_getctipfonfinv';
      e_error        EXCEPTION;
      v_ctipfon      NUMBER;
   BEGIN
      SELECT ctipfon
        INTO v_ctipfon
        FROM fondos
       WHERE cempres = pcempres
         AND ccodfon = pccodfon;

      RETURN v_ctipfon;
   EXCEPTION
      WHEN e_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000052, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000052, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_getctipfonfinv;

-- Bug 36746/0211309 - APD - 17/09/2015 - se crea la funcion
   FUNCTION f_get_lstfondosseg(
      pcempres IN NUMBER,
      psseguro IN NUMBER,
      pfecha IN DATE,
      plstfondos IN OUT sys_refcursor,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_MD_OPERATIVA_FINV.F_GetFondosOperaFinv';
      vparam         VARCHAR2(500)
         := 'parametros - pcempres: ' || pcempres || ', psseguro: ' || psseguro
            || ', pfecha: ' || TO_CHAR(pfecha, 'DD/MM/YYYY');
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vcursor        sys_refcursor;
      vsquery        VARCHAR2(9000);
   BEGIN
      vpasexec := 1;
      vnumerr := pac_operativa_finv.f_get_lstfondosseg(pcempres, psseguro, pfecha, vsquery);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RETURN 1;
      END IF;

      vpasexec := 2;
      vcursor := pac_iax_listvalores.f_opencursor(vsquery, mensajes);

      IF pac_md_log.f_log_consultas(vsquery, 'PAC_MD_OPERATIVA_FINV.f_get_lstfondosseg', 1, 4,
                                    mensajes) <> 0 THEN
         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 180855);
         RETURN 1;
      END IF;

      plstfondos := vcursor;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_get_lstfondosseg;

-- Bug 36746/0211309 - APD - 17/09/2015 - se crea la funcion
   FUNCTION f_switch_fondos(
      pccodfonori IN NUMBER,
      pccodfondtn IN NUMBER,
      psseguro IN NUMBER,
      pfecha IN DATE,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_MD_OPERATIVA_FINV.f_switch_fondos';
      vparam         VARCHAR2(500)
         := 'parametros - pccodfonori: ' || pccodfonori || ', pccodfondtn: ' || pccodfondtn
            || ', psseguro: ' || psseguro || ', pfecha: ' || TO_CHAR(pfecha, 'ddmmyyyy');
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER;
      v_sproces      NUMBER;
      vlineas        NUMBER := 0;
      vlineas_error  NUMBER := 0;
      v_texto        VARCHAR2(500);
      v_err          NUMBER;
      v_nnumlin      NUMBER := NULL;
   BEGIN
      vpasexec := 1;
      vnumerr := f_procesini(f_user, pac_md_common.f_get_cxtempresa, 'SWITCH FONDOS',
                             f_axis_literales(9908373, f_idiomauser), v_sproces);
      vpasexec := 2;
      vnumerr := pac_operativa_finv.f_valida_switch(pccodfonori, pccodfondtn, psseguro,
                                                    pfecha);

      IF vnumerr <> 0 THEN
         v_texto := f_axis_literales(vnumerr, f_idiomauser);
         v_err := f_proceslin(v_sproces, v_texto, psseguro, v_nnumlin);
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      vpasexec := 3;
      vnumerr := pac_operativa_finv.f_switch_fondos(pccodfonori, pccodfondtn, psseguro, pfecha,
                                                    v_sproces, vlineas, vlineas_error);

      IF vnumerr <> 0 THEN
         v_texto := f_axis_literales(vnumerr, f_idiomauser);
         v_err := f_proceslin(v_sproces, v_texto, psseguro, v_nnumlin);
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      vnumerr := f_procesfin(v_sproces, 0);
      --
      v_texto := f_axis_literales(9000493, pac_md_common.f_get_cxtidioma) || ' : ' || v_sproces
                 || '.' || f_axis_literales(103351, pac_md_common.f_get_cxtidioma)
                 || TO_CHAR(vlineas - vlineas_error) || ' | '
                 || f_axis_literales(103149, pac_md_common.f_get_cxtidioma) || vlineas_error;
      pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, NULL, v_texto);
      RETURN 0;
   EXCEPTION
      WHEN e_object_error THEN
         vnumerr := f_procesfin(v_sproces, 0);
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         vnumerr := f_procesfin(v_sproces, 0);
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_switch_fondos;
END pac_md_operativa_finv;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_OPERATIVA_FINV" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_OPERATIVA_FINV" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_OPERATIVA_FINV" TO "PROGRAMADORESCSI";
