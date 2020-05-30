--------------------------------------------------------
--  DDL for Package Body PAC_MD_FONDOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_MD_FONDOS" 
IS
/******************************************************************************
      NOMBRE:     PAC_MD_FONDOS
      PROPÓSITO: Funciones para mantener fondos

      REVISIONES:
      Ver        Fecha        Autor             Descripción
      ---------  ----------  ---------------  ------------------------------------
      1.0        12/02/2014  NMM                1.Creació.
      2.0        06/10/2015  JCP                2. 0033665 Modificacion funciones fondos
   ******************************************************************************/
    /****************************************************************************
        función que recupera los fondos que cumplen con el criterio de selección.

            param in: pcempres
            param in: pccodfon
            parm  in: ptfoncmp
            param in: pcmoneda
            param in: pcmanager
            param in out: mensajes
    *****************************************************************************/
   FUNCTION f_buscar_fondos(
      pcempres     IN       NUMBER,
      pccodfon     IN       NUMBER,
      ptfoncmp     IN       VARCHAR2,
      pcmoneda     IN       NUMBER,
      pcmanager    IN       NUMBER,
      pcdividend   IN       NUMBER,
      mensajes     IN OUT   t_iax_mensajes
   )
      RETURN sys_refcursor
   IS
      vobject   VARCHAR2 (100)  := 'PAC_MD_FONDOS.f_buscar_fondos';
      v_query   VARCHAR2 (500)
         :=    'SELECT f.CCODFON, f.TFONCMP, mo.TDESCRI as TCMONEDA, ff_desvalorfijo(8000937,5,f.CMANAGER) as TCMANAGER
                                  FROM FONDOS f,MONEDAS mo
                                  WHERE  f.CMONEDA = mo.CMONEDA
                                         AND mo.CIDIOMA ='
            || pac_md_common.f_get_cxtidioma
            || ' ';
      v_where   VARCHAR2 (1000) := '';
      cur       sys_refcursor;
   BEGIN
      IF pcempres IS NOT NULL
      THEN
         v_where := v_where || ' AND f.CEMPRES =' || pcempres;
      END IF;

      IF pccodfon IS NOT NULL
      THEN
         v_where := v_where || ' AND f.CCODFON=' || pccodfon;
      END IF;

      IF ptfoncmp IS NOT NULL
      THEN
         v_where :=
               v_where
            || ' AND lower(f.TFONCMP) like lower('
            || CHR (39)
            || '%'
            || ptfoncmp
            || '%'
            || CHR (39)
            || ')';
      END IF;

      IF pcmoneda IS NOT NULL
      THEN
         v_where := v_where || ' AND f.CMONEDA = ' || pcmoneda;
      END IF;

      IF pcmanager IS NOT NULL
      THEN
         v_where := v_where || ' AND f.CMANAGER = ' || pcmanager;
      END IF;

      IF pcdividend IS NOT NULL
      THEN
         v_where := v_where || ' AND f.CDIVIDEND = ' || pcdividend;
      END IF;

      v_query := v_query || v_where;

      OPEN cur FOR v_query;

      RETURN cur;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000254,
                                            1,
                                            v_query,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
      WHEN OTHERS
      THEN
         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            1,
                                            v_query,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
   END f_buscar_fondos;

/****************************************************************************
        función que recupera un fondo en concreto.n.

            param in: pcempres
            param in: pccodfon
            param out: ptfonabv
            param out: ptfoncmp
            param out: pcmoneda
            param out: pcmanager
            param out: pnmaxuni
            param out: pigasttran
            param out: pfinicio
            param out: pcclsfon
            param out: pctipfon
            param out: pcdividend
            param in out: mensajes
    *****************************************************************************/
   FUNCTION f_get_fondo(
      pcempres      IN       NUMBER,
      pccodfon      IN       NUMBER,
      ptfonabv      OUT      VARCHAR2,
      ptfoncmp      OUT      VARCHAR2,
      pcmoneda      OUT      NUMBER,
      pcmanager     OUT      NUMBER,
      pnmaxuni      OUT      NUMBER,
      pigasttran    OUT      NUMBER,
      pfinicio      OUT      DATE,
      pcclsfon      OUT      NUMBER,
      pctipfon      OUT      NUMBER,
      pcmodabo      OUT      NUMBER,
      pndayaft      OUT      NUMBER,
      pnperiodbon   OUT      NUMBER,
      pcdividend    OUT      NUMBER,
      mensajes      IN OUT   t_iax_mensajes
   )
      RETURN NUMBER
   IS
   BEGIN
      IF pcempres IS NULL OR pccodfon IS NULL
      THEN
         RETURN 1;
      ELSE
         SELECT tfonabv, tfoncmp, cmoneda, cmanager, nmaxuni,
                igasttran, finicio, cclsfon, ctipfon, cmodabo,
                ndayaft, nperiodbon, cdividend
           INTO ptfonabv, ptfoncmp, pcmoneda, pcmanager, pnmaxuni,
                pigasttran, pfinicio, pcclsfon, pctipfon, pcmodabo,
                pndayaft, pnperiodbon, pcdividend
           FROM fondos
          WHERE ccodfon = pccodfon AND cempres = pcempres;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         RETURN 1000254;
      WHEN OTHERS
      THEN
         RETURN 1000001;
   END;

     /******************************************************************************
    función que graba o actualiza la tabla fondos

    param in:       pcempres
   param in out:   pccodfon
   param in:       ptfonabv
   param in:       ptfoncmp
   param in:       pcmoneda
   param in:       pcmanager
   param in:       pnmaxuni
   param in:       pigasttran
   param in:       pfinicio
   param in:       pcclsfon
   param in:       pctipfon
   param in:       pcdividend
   param in out:   mensajes

   ******************************************************************************/
   FUNCTION f_set_fondo(
      pcempres      IN       NUMBER,
      pccodfon      IN OUT   NUMBER,
      ptfonabv      IN       VARCHAR2,
      ptfoncmp      IN       VARCHAR2,
      pcmoneda      IN       NUMBER,
      pcmanager     IN       NUMBER,
      pnmaxuni      IN       NUMBER,
      pigasttran    IN       NUMBER,
      pfinicio      IN       DATE,
      pcclsfon      IN       NUMBER,
      pctipfon      IN       NUMBER,
      pcmodabo      IN       NUMBER,
      pndayaft      IN       NUMBER,
      pnperiodbon   IN       NUMBER,
      pcdividend    IN       NUMBER,
      mensajes      IN OUT   t_iax_mensajes
   )
      RETURN NUMBER
   IS
      verror        NUMBER    := 1;
      v_exception   EXCEPTION;
   BEGIN
      IF pcempres IS NOT NULL
      THEN
         verror :=
            pac_mantenimiento_fondos_finv.f_set_fondo (pcempres,
                                                       pccodfon,
                                                       ptfonabv,
                                                       ptfoncmp,
                                                       pcmoneda,
                                                       pcmanager,
                                                       pnmaxuni,
                                                       pigasttran,
                                                       pfinicio,
                                                       pcclsfon,
                                                       pctipfon,
                                                       pcmodabo,
                                                       pndayaft,
                                                       pnperiodbon,
                                                       pcdividend,
                                                       mensajes
                                                      );
      END IF;

      IF verror <> 0
      THEN
         RAISE v_exception;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN v_exception
      THEN
         RETURN verror;
      WHEN OTHERS
      THEN
         RETURN 1000001;
   END;

   /******************************************************************************
     función que recupera un modelo de inversion

     param in:       psproduc
     param in:       pcmodinv
     param out:      pmodelo
     param in out:   mensajes

    ******************************************************************************/
   FUNCTION f_get_modelinv(
      psproduc   IN       NUMBER,
      pcmodinv   IN       NUMBER,
      pmodelo    IN       t_iax_produlkmodelosinv,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN NUMBER
   IS
      verror   sys_refcursor;
   BEGIN
      verror :=
         pac_md_mntprod.f_get_modelinv (psproduc, pcmodinv, pmodelo,
                                        mensajes);
      RETURN 0;
   END f_get_modelinv;

   /******************************************************************************
     función que guarda un modelo de inversion

      param in     cramo
      param in     cmodali
      param in     ctipseg
      param in     ccolect
      param in     cmodinv
      param in     finicio
      param in     ffin
      param in out:   mensajes

    ******************************************************************************/
   FUNCTION f_set_modelinv(
      psproduc   IN       NUMBER,
      pcmodinv   IN       NUMBER,
      pidioma    IN       t_iax_info,
      mensajes   OUT      t_iax_mensajes
   )
      RETURN NUMBER
   IS
      verror   NUMBER;
   BEGIN
      FOR i IN pidioma.FIRST .. pidioma.LAST
      LOOP
         verror :=
            pac_md_mntprod.f_set_modelinv (psproduc,
                                           pcmodinv,
                                           pidioma (i).nombre_columna,
                                           pidioma (i).valor_columna,
                                           mensajes
                                          );
      END LOOP;

      RETURN 0;
   END f_set_modelinv;

   /******************************************************************************
     función que recupera los fondos de un  modelo de inversion

      param in     psproduc
      param in     pcmodinv
      param in     pmodinvfondo
      param in     mensajes
      param in out:   mensajes

    ******************************************************************************/
   FUNCTION f_get_modinvfondos(
      psproduc       IN       NUMBER,
      pcmodinv       IN       NUMBER,
      pmodinvfondo   OUT      t_iax_produlkmodinvfondo,
      mensajes       IN OUT   t_iax_mensajes
   )
      RETURN NUMBER
   IS
   BEGIN
      pmodinvfondo :=
             pac_md_mntprod.f_get_modinvfondos (psproduc, pcmodinv, mensajes);
      RETURN 0;
   END f_get_modinvfondos;

   /******************************************************************************
     función que guarda un fondo en un  modelo de inversion

      param in     psproduc
      param in     pcmodinv
      param in     pmodinvfondo
      param in     mensajes
      param in out:   mensajes

    ******************************************************************************/
   FUNCTION f_set_modinvfondos(
      psproduc       IN       NUMBER,
      pcmodinv       IN       NUMBER,
      pmodinvfondo   IN       t_iax_produlkmodinvfondo,
      mensajes       IN OUT   t_iax_mensajes
   )
      RETURN NUMBER
   IS
      verror         NUMBER;
      vmodinvfondo   t_iax_produlkmodinvfondo := t_iax_produlkmodinvfondo ();
   BEGIN
      verror :=
         pac_md_mntprod.f_set_modinvfondos (psproduc,
                                            pcmodinv,
                                            pmodinvfondo,
                                            mensajes
                                           );

      IF verror <> 0
      THEN
         RETURN verror;
      END IF;

      RETURN 0;
   END f_set_modinvfondos;

/******************************************************************************
    función que borra un fondo en un  modelo de inversion

     param in     pccodfon
     param in     pcmodinv
     param in     mensajes
     param in out:   mensajes

   ******************************************************************************/
   FUNCTION f_del_modinvfondos(
      pccodfon   IN       NUMBER,
      pcmodinv   IN       NUMBER,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN NUMBER
   IS
      verror   NUMBER;
   BEGIN
      verror :=
             pac_md_mntprod.f_del_modinvfondos (pccodfon, pcmodinv, mensajes);
      RETURN verror;
   END f_del_modinvfondos;

   /******************************************************************************
    función que recupera los fondos de un  modelo de inversion

     param in     psproduc
     param in     pcmodinv
     param in     pmodinvfondo
     param in     mensajes
     param in out:   mensajes

   ******************************************************************************/
   FUNCTION f_get_modinvfondosseg(
      psproduc       IN       NUMBER,
      pcmodinv       IN       NUMBER,
      pmodinvfondo   OUT      t_iax_produlkmodinvfondo,
      mensajes       IN OUT   t_iax_mensajes
   )
      RETURN NUMBER
   IS
   BEGIN
      pmodinvfondo :=
                    pac_md_mntprod.f_get_modinvfondosseg (pcmodinv, mensajes);
      RETURN 0;
   END f_get_modinvfondosseg;

   FUNCTION f_get_diasdep(pccodfon IN NUMBER)
      RETURN NUMBER
   IS
      vdiasaft   NUMBER := 0;
   BEGIN
      SELECT NVL (ndayaft, 0)
        INTO vdiasaft
        FROM fondos
       WHERE ccodfon = pccodfon;

      RETURN vdiasaft;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'PAC_OPERATIVA_FINV.f_cta_gastos_gestion',
                      1,
                      'ssss ',
                      SQLERRM
                     );
         RETURN 0;
   END f_get_diasdep;

   /******************************************************************************
     función que recupera los fondos de un  modelo de inversion

      param in     psproduc
      param in     pcmodinv
      param in     pmodinvfondo
      param in     mensajes
      param in out:   mensajes

    ******************************************************************************/
   FUNCTION f_get_modinvfondos2(
      psproduc       IN       NUMBER,
      pcmodinv       IN       NUMBER,
      pmodinvfondo   OUT      t_iax_produlkmodinvfondo,
      mensajes       IN OUT   t_iax_mensajes
   )
      RETURN NUMBER
   IS
   BEGIN
      pmodinvfondo :=
            pac_md_mntprod.f_get_modinvfondos2 (psproduc, pcmodinv, mensajes);
      RETURN 0;
   END f_get_modinvfondos2;

   FUNCTION f_asign_dividends(
      pmodo        IN       VARCHAR2,
      plstfondos   IN       t_iax_info,
      pfvigencia   IN       DATE,
      pfvalmov     IN       DATE,
      piimpdiv     IN       NUMBER,
      mensajes     IN OUT   t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vobjectname      VARCHAR2 (500)
                                 := 'PAC_MD_OPERATIVA_FINV.f_asign_dividends';
      vparam           VARCHAR2 (500)
         :=    'parametros - pmodo: '
            || pmodo
            || ', pfvigencia: '
            || TO_CHAR (pfvigencia, 'ddmmyyyy')
            || ', pfvalmov: '
            || TO_CHAR (pfvalmov, 'ddmmyyyy')
            || ', piimpdiv: '
            || piimpdiv;
      vpasexec         NUMBER (5)     := 1;
      vnumerr          NUMBER;
      vsproces         NUMBER;
      vlineas          NUMBER         := 0;
      vlineas_error    NUMBER         := 0;
      v_texto          VARCHAR2 (500);
      v_err            NUMBER;
      v_nnumlin        NUMBER         := NULL;
      e_param_error    EXCEPTION;
      e_object_error   EXCEPTION;
   BEGIN
      vpasexec := 1;

      IF    pmodo IS NULL
         OR plstfondos.COUNT = 0
         OR pfvigencia IS NULL
         OR pfvalmov IS NULL
         OR piimpdiv IS NULL
      THEN
         vnumerr := 103135;
         RAISE e_param_error;
      END IF;

      vpasexec := 2;

      FOR j IN plstfondos.FIRST .. plstfondos.LAST
      LOOP
         IF plstfondos (j).nombre_columna = 'CCODFON'
         THEN
            vpasexec := 3;
            vsproces := NULL;
            vnumerr :=
               pac_mantenimiento_fondos_finv.f_asign_dividends
                                                (pmodo,
                                                 plstfondos (j).valor_columna,
                                                 pfvigencia,
                                                 pfvalmov,
                                                 piimpdiv,
                                                 vsproces,
                                                 vlineas,
                                                 vlineas_error
                                                );

            IF vnumerr <> 0
            THEN
               pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, vnumerr);
               RAISE e_object_error;
            END IF;
         END IF;
      END LOOP;

      vpasexec := 4;
      v_texto :=
            f_axis_literales (103351, pac_md_common.f_get_cxtidioma)
         || TO_CHAR (vlineas - vlineas_error)
         || ' | '
         || f_axis_literales (103149, pac_md_common.f_get_cxtidioma)
         || vlineas_error;
      pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 2, NULL, v_texto);
      vpasexec := 5;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobjectname,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobjectname,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobjectname,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            NULL,
                                            SQLCODE,
                                            SQLERRM
                                           );
         RETURN 1;
   END f_asign_dividends;
END pac_md_fondos;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_FONDOS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_FONDOS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_FONDOS" TO "PROGRAMADORESCSI";
