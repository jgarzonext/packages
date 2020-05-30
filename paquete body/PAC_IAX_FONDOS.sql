--------------------------------------------------------
--  DDL for Package Body PAC_IAX_FONDOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_IAX_FONDOS" 
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
   e_object_error   EXCEPTION;
   e_param_error    EXCEPTION;

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
      mensajes     OUT      t_iax_mensajes
   )
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vobject    VARCHAR2 (50)  := 'PAC_IAX_FONDOS.f_buscar_fondos';
      vpasexec   NUMBER         := 1;
      vparam     VARCHAR (1000)
         :=    'pcempres: '
            || pcempres
            || ' pccodfon: '
            || pccodfon
            || ' ptfoncmp: '
            || ptfoncmp
            || ' pcmoneda: '
            || pcmoneda
            || ' pcmanager: '
            || pcmanager
            || ' pcdividend: '
            || pcdividend;
   BEGIN
      cur :=
         pac_md_fondos.f_buscar_fondos (pcempres,
                                        pccodfon,
                                        ptfoncmp,
                                        pcmoneda,
                                        pcmanager,
                                        pcdividend,
                                        mensajes
                                       );
      RETURN cur;
   EXCEPTION
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            NULL,
                                            SQLCODE,
                                            SQLERRM
                                           );
         RETURN NULL;
   END f_buscar_fondos;

   /****************************************************************************
       función que recupera un fondo en concreto.

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
      mensajes      OUT      t_iax_mensajes
   )
      RETURN NUMBER
   IS
      v_error             NUMBER;
      v_error_exception   EXCEPTION;
      vobject             VARCHAR2 (50)  := 'PAC_IAX_FONDOS.f_get_fondo';
      vpasexec            NUMBER         := 1;
      vparam              VARCHAR (1000)
         :=    'pcempres: '
            || pcempres
            || ' pccodfon: '
            || pccodfon
            || ' ptfonabv: '
            || ptfonabv
            || ' ptfoncmp: '
            || ptfoncmp
            || ' pcmoneda: '
            || pcmoneda
            || ' pcmanager: '
            || pcmanager
            || ' pnmaxuni: '
            || pnmaxuni
            || ' pigasttran: '
            || pigasttran
            || ' pfinicio: '
            || pfinicio
            || ' pcclsfon: '
            || pcclsfon
            || ' pctipfon: '
            || pctipfon
            || ' pcdividend: '
            || pcdividend;
   BEGIN
      v_error :=
         pac_md_fondos.f_get_fondo (pcempres,
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

      IF v_error <> 0
      THEN
         RAISE v_error_exception;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN v_error_exception
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            v_error,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN 1;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            v_error,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN 2;
   END f_get_fondo;

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
      mensajes      OUT      t_iax_mensajes
   )
      RETURN NUMBER
   IS
      v_error         NUMBER;
      vobject         VARCHAR2 (50)  := 'PAC_IAX_FONDOS.f_set_fondo';
      vpasexec        NUMBER         := 1;
      vparam          VARCHAR (1000)
         :=    'pcempres: '
            || pcempres
            || ' pccodfon: '
            || pccodfon
            || ' ptfonabv: '
            || ptfonabv
            || ' ptfoncmp: '
            || ptfoncmp
            || ' pcmoneda: '
            || pcmoneda
            || ' pcmanager: '
            || pcmanager
            || ' pnmaxuni: '
            || pnmaxuni
            || ' pigasttran: '
            || pigasttran
            || ' pfinicio: '
            || pfinicio
            || ' pcclsfon: '
            || pcclsfon
            || ' pctipfon: '
            || pctipfon
            || ' cmodabo '
            || pcmodabo
            || ' ndayaft '
            || pndayaft
            || ' pcdividend '
            || pcdividend;
      vsql            CLOB;
      e_param_error   EXCEPTION;
   BEGIN
      v_error :=
         pac_md_fondos.f_set_fondo (pcempres,
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

      IF v_error <> 0
      THEN
         RAISE e_param_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            v_error,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            v_error,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN 2;
   END f_set_fondo;

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
      pmodelo    OUT      t_iax_produlkmodelosinv,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN NUMBER
   IS
      nerror           NUMBER;
      error_consulta   EXCEPTION;
   BEGIN
      nerror :=
         pac_md_fondos.f_get_modelinv (psproduc, pcmodinv, pmodelo, mensajes);

      IF nerror <> 0
      THEN
         RAISE error_consulta;
      END IF;
   EXCEPTION
      WHEN error_consulta
      THEN
         NULL;
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
      pidiomas   IN       t_iax_info,
      mensajes   OUT      t_iax_mensajes
   )
      RETURN NUMBER
   IS
      nerror   NUMBER;
   BEGIN
      nerror :=
         pac_md_fondos.f_set_modelinv (psproduc, pcmodinv, pidiomas,
                                       mensajes);
      RETURN nerror;
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
      mensajes       OUT      t_iax_mensajes
   )
      RETURN NUMBER
   IS
      verror   NUMBER;
   BEGIN
      verror :=
         pac_md_fondos.f_get_modinvfondos (psproduc,
                                           pcmodinv,
                                           pmodinvfondo,
                                           mensajes
                                          );
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
      pmodinvfondo   IN       t_iax_info,
      mensajes       OUT      t_iax_mensajes
   )
      RETURN NUMBER
   IS
      verror            NUMBER;
      vmodinvfondo      t_iax_produlkmodinvfondo
                                               := t_iax_produlkmodinvfondo
                                                                          ();
      nccodfon          NUMBER;
      vmodinv           NUMBER;
      vobject           VARCHAR2 (100) := 'PAC_IAX_FONDOS.f_set_modinvfondos';
      vpasexec          NUMBER                    := 1;
      vparam            VARCHAR2 (100)
                     := 'psproduct: ' || psproduc || ' cmodinv: ' || pcmodinv;
      vnotin            VARCHAR2 (100)            := '(';
      vcur              sys_refcursor;
      vobmodinvfnd      ob_iax_produlkmodinvfondo
                                              := ob_iax_produlkmodinvfondo
                                                                          ();
      vpinverssum       NUMBER                    := 0;
      vcodfondel        NUMBER;
      v_error_proceso   EXCEPTION;
      tmpsubstr         VARCHAR2 (1000);
   BEGIN
      IF pmodinvfondo IS NOT NULL AND pmodinvfondo.COUNT > 0
      THEN
         FOR i IN pmodinvfondo.FIRST .. pmodinvfondo.LAST
         LOOP
            vpasexec := 2;
            vobmodinvfnd.ccodfon := pmodinvfondo (i).nombre_columna;
            vobmodinvfnd.pinvers :=
               SUBSTR (pmodinvfondo (i).valor_columna,
                       1,
                       INSTR (pmodinvfondo (i).valor_columna, '#') - 1
                      );
            tmpsubstr :=
               SUBSTR (pmodinvfondo (i).valor_columna,
                       INSTR (pmodinvfondo (i).valor_columna, '#') + 1
                      );
            vobmodinvfnd.pmaxcont :=
                              SUBSTR (tmpsubstr, 1, INSTR (tmpsubstr, '#') - 1);
            tmpsubstr := SUBSTR (tmpsubstr, INSTR (tmpsubstr, '#') + 1);

            IF tmpsubstr != 'null'
            THEN
               vobmodinvfnd.cmodabo := tmpsubstr;
            END IF;

            verror :=
               f_valida_modinvfondo (psproduc,
                                     pcmodinv,
                                     vobmodinvfnd,
                                     mensajes
                                    );

            IF verror <> 0
            THEN
               RAISE v_error_proceso;
            END IF;

            vpasexec := 3;
            vnotin := vnotin || vobmodinvfnd.ccodfon || ',';
            vpinverssum := vpinverssum + vobmodinvfnd.pinvers;
            vmodinvfondo.EXTEND;
            vmodinvfondo (vmodinvfondo.LAST) := vobmodinvfnd;
         END LOOP;

         vpasexec := 4;

         IF     vpinverssum <> 100
            AND NVL (pac_parametros.f_parproducto_n (psproduc, 'PERFIL_LIBRE'),
                     -99
                    ) <> pcmodinv
         THEN
            verror := 9902398;
            RAISE v_error_proceso;
         END IF;
      END IF;

      vnotin := vnotin || '-999)';
      vpasexec := 5;

      BEGIN
         OPEN vcur FOR    'SELECT CCODFON,CMODINV FROM MODINVFONDO WHERE CMODINV ='
                       || pcmodinv
                       || ' AND CCODFON NOT IN '
                       || vnotin;

         LOOP
            FETCH vcur
             INTO nccodfon, vmodinv;

            SELECT COUNT (1)
              INTO vcodfondel
              FROM segdisin2 s, modinvfondo m, seguros_ulk u
             WHERE m.ccodfon = nccodfon
               AND s.ccesta = m.ccodfon
               AND s.sseguro = u.sseguro
               AND m.cmodinv = u.cmodinv
               AND m.cmodinv = vmodinv
               AND (m.cramo, m.cmodali, m.ctipseg, m.ccolect) IN (
                                       SELECT cramo, cmodali, ctipseg,
                                              ccolect
                                         FROM productos
                                        WHERE sproduc = psproduc)
               AND nmovimi IN (
                               SELECT MAX (nmovimi)
                                 FROM segdisin2
                                WHERE s.sseguro = sseguro
                                      AND s.ccesta = ccesta);

            IF vcodfondel = 0
            THEN
               verror :=
                  pac_md_fondos.f_del_modinvfondos (nccodfon,
                                                    vmodinv,
                                                    mensajes
                                                   );
            ELSE
               verror := 180442;
               RAISE v_error_proceso;
            END IF;

            EXIT WHEN vcur%NOTFOUND OR verror <> 0;
         END LOOP;

         CLOSE vcur;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            verror := 0;
      END;

      IF vmodinvfondo IS NOT NULL AND vmodinvfondo.COUNT > 0
      THEN
         verror :=
            pac_md_fondos.f_set_modinvfondos (psproduc,
                                              pcmodinv,
                                              vmodinvfondo,
                                              mensajes
                                             );
      END IF;

      IF verror <> 0
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            ' ',
                                            verror,
                                            vpasexec,
                                            vparam
                                           );
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN v_error_proceso
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            ' ',
                                            verror,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
   END f_set_modinvfondos;

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
      mensajes       OUT      t_iax_mensajes
   )
      RETURN NUMBER
   IS
      verror   NUMBER;
   BEGIN
      verror :=
         pac_md_fondos.f_get_modinvfondosseg (psproduc,
                                              pcmodinv,
                                              pmodinvfondo,
                                              mensajes
                                             );
      RETURN 0;
   END f_get_modinvfondosseg;

    /******************************************************************************
    función que valida los fondos de un  modelo de inversion antes de su inserción

     param in     psproduc
     param in     pcmodinv
     param in     pmodinvfondo
     param in     mensajes
     param in out:   mensajes

   ******************************************************************************/
   FUNCTION f_valida_modinvfondo(
      psproduc       IN       NUMBER,
      pcmodinv       IN       NUMBER,
      pmodinvfondo   IN OUT   ob_iax_produlkmodinvfondo,
      mensajes       OUT      t_iax_mensajes
   )
      RETURN NUMBER
   IS
      nccodfon      NUMBER;
      nccodfonseg   NUMBER;
      vmonedacont   NUMBER;
      maxpinvers    NUMBER;
      minpinvers    NUMBER;
   BEGIN
      SELECT COUNT (1)
        INTO nccodfon
        FROM modinvfondo
       WHERE ccodfon = pmodinvfondo.ccodfon AND cmodinv = pcmodinv;

      IF    (pmodinvfondo.pmaxcont NOT BETWEEN 0 AND 100)
         OR (pmodinvfondo.pinvers NOT BETWEEN 0 AND 100)
      THEN
         RETURN 9904621;
      END IF;

      --si no existe la relacion fondo-modelo miramos que los valores sean correctos.
      IF pmodinvfondo.pmaxcont < pmodinvfondo.pinvers
      THEN
         RETURN 111104;
      END IF;

      --validamos que los fondos sean de la moneda correcta...
      SELECT COUNT (1)
        INTO vmonedacont
        FROM fondos f
       WHERE f.ccodfon = pmodinvfondo.ccodfon
         AND f.cmoneda = (SELECT p.cdivisa
                            FROM productos p
                           WHERE sproduc = psproduc);

      IF vmonedacont <> 1
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes,
                                               1,
                                               1,
                                               f_axis_literales (9903148)
                                              );
         RETURN 1;
      END IF;

      IF nccodfon <> 0
      THEN
         --validamos si existe alguna poliza con el fondo asignado
         SELECT COUNT (1)
           INTO nccodfonseg
           FROM segdisin2 sds2, seguros_ulk u, modinvfondo m
          WHERE ccesta = pmodinvfondo.ccodfon
            AND u.sseguro = sds2.sseguro
            AND u.cmodinv = pcmodinv
            AND m.cmodinv = u.cmodinv
            AND ccesta = m.ccodfon
            AND (m.cramo, m.cmodali, m.ctipseg, m.ccolect) IN (
                                       SELECT cramo, cmodali, ctipseg,
                                              ccolect
                                         FROM productos
                                        WHERE sproduc = psproduc)
            AND nmovimi IN (
                   SELECT MAX (nmovimi)
                     FROM segdisin2 sds21
                    WHERE sds2.sseguro = sds21.sseguro
                      AND sds2.ccesta = sds21.ccesta);

         IF nccodfonseg <> 0
         THEN
            SELECT MAX (pdistrec), MIN (pdistrec)
              INTO maxpinvers, minpinvers
              FROM segdisin2 sds2, seguros_ulk u
             WHERE ccesta = pmodinvfondo.ccodfon
               AND u.sseguro = sds2.sseguro
               AND u.cmodinv = pcmodinv
               AND nmovimi IN (
                         SELECT MAX (nmovimi)
                           FROM segdisin2
                          WHERE sds2.sseguro = sseguro
                                AND sds2.ccesta = ccesta);

            --validamos que estemos insertando el maximo y el minimo correctamente
            IF     maxpinvers < pmodinvfondo.pmaxcont
               AND minpinvers > pmodinvfondo.pinvers
            THEN
               RETURN 9902398;
            END IF;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            'validaModinvFondo',
                                            1000005,
                                            1,
                                            ' '
                                           );
         RETURN 0;
   END f_valida_modinvfondo;

   FUNCTION f_get_diasdep(pccodfon IN NUMBER)
      RETURN NUMBER
   IS
      vdiasaft   NUMBER := 0;
   BEGIN
      vdiasaft := pac_md_fondos.f_get_diasdep (pccodfon);
      RETURN vdiasaft;
   EXCEPTION
      WHEN OTHERS
      THEN
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
      mensajes       OUT      t_iax_mensajes
   )
      RETURN NUMBER
   IS
      verror   NUMBER;
   BEGIN
      verror :=
         pac_md_fondos.f_get_modinvfondos2 (psproduc,
                                            pcmodinv,
                                            pmodinvfondo,
                                            mensajes
                                           );
      RETURN 0;
   END f_get_modinvfondos2;

   FUNCTION f_asign_dividends(
      pmodo        IN       VARCHAR2,
      plstfondos   IN       t_iax_info,
      pfvigencia   IN       DATE,
      pfvalmov     IN       DATE,
      piimpdiv     IN       NUMBER,
      mensajes     OUT      t_iax_mensajes
   )
      RETURN NUMBER
   IS
      v_error    NUMBER         := 0;
      vpasexec   NUMBER;
      vobject    VARCHAR2 (200) := 'PAC_IAX_FONDOS.f_asign_dividends';
      vparam     VARCHAR2 (200)
         :=    'pmodo : '
            || pmodo
            || ' pfvigencia : '
            || TO_CHAR (pfvigencia, 'dd/mm/yyyy')
            || ' pfvalmov : '
            || TO_CHAR (pfvalmov, 'dd/mm/yyyy')
            || ' piimpdiv : '
            || piimpdiv;
   BEGIN
      vpasexec := 1;

      IF    pmodo IS NULL
         OR plstfondos IS NULL
         OR pfvigencia IS NULL
         OR pfvalmov IS NULL
         OR piimpdiv IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      v_error :=
         pac_md_fondos.f_asign_dividends (pmodo,
                                          plstfondos,
                                          pfvigencia,
                                          pfvalmov,
                                          piimpdiv,
                                          mensajes
                                         );
      vpasexec := 3;

      IF v_error != 0
      THEN
         RAISE e_object_error;
      END IF;

      vpasexec := 4;
      COMMIT;
      RETURN v_error;
   EXCEPTION
      WHEN e_param_error
      THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN e_object_error
      THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN OTHERS
      THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN 1;
   END f_asign_dividends;
END pac_iax_fondos;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_FONDOS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_FONDOS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_FONDOS" TO "PROGRAMADORESCSI";
