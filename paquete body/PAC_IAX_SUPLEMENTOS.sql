/* Formatted on 2020/01/03 09:05 (Formatter Plus v4.8.8) */
CREATE OR REPLACE PACKAGE BODY "PAC_IAX_SUPLEMENTOS"
AS
/******************************************************************************
   NOMBRE:       PAC_IAX_SUPLEMENTOS
   PROPÓSITO:  Permite crear suplementos

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        07/02/2008   ACC                1. Creación del package.
   2.0        24/04/2009   RSC                2. Suplemento de cambio de forma de pago diferido
   3.0        10/11/2009   AMC                3. 0011695: CEM - Fecha de efecto de los suplementos por defecto
   4.0        14/12/2009   RSC                4. 0012206: CRE201 - Incidencias Ramo Salud - Diciembre 2009
   5.0        28/12/2009   APD                5. 0012485: CEM - Incidencias varias PPA
   6.0        21/01/2010   XPL                6. APR - En la consulta de pòlisses, fer que els motius de suplements permesos es recuperin dinàmicament de BD
   7.0        19/01/2010   RSC                7. 0011735: APR - suplemento de modificación de capital /prima
   8.0        07/05/2010   RSC                8. 0011735: APR - suplemento de modificación de capital /prima
   9.0        29/06/2010   JGR                9. 0015215: CRE - Incidència al fer suplements en més d'un risc
   10.0       17/06/2010   RSC                10. 0013832: APRS015 - Suplemento de aportaciones únicas
   11.0       24/01/2011   JMP                11. 0017341: APR703 - Suplemento de preguntas - FlexiLife
   12.0       24/02/2011   ICV                12. 0017718: CCAT003 - Accés a productes en funció de l'operació
   13.0       09/03/2011   JMF                13. 0017881 CX800 - SOBREPRIMA EN UNA PROPOSTA ASSEGURANÇA
   14.0       04/07/2011   JTS                14. 0017255: CRT003 - Definir propuestas de suplementos en productos
   15.0       15/07/2011   JTS                15. 0018926: MSGV003- Activar el suplement de canvi de forma de pagament
   16.0       21/10/2011   DRA                16. 0019863: CIV903 - Desconnexió de les crides a Eclipse pels productes PPA i PIES
   17.0       03/12/2012   APD                17. 0024278: LCOL_T010 - Suplementos diferidos - Cartera - colectivos
   18.0       04/02/2013   DRA                18. 0024726: (POSDE600)-Desarrollo-GAPS Tecnico-Id 32 - Anexos de cambio de valor rentas e Inclusion de Beneficiario
   19.0       07/02/2013   JDS                19. 0025583: LCOL - Revision incidencias qtracker (IV)
   20.0       08/03/2013   JMC                20. 0026261: LCOL_T010-LCOL - Revision incidencias qtracker (IV)
   21.0       11/07/2013   RCL                21. 0023860: LCOL - Parametrización y suplementos - Vida Grupo
   22.0       08/10/2013   HRE                22. Bug 0028462: HRE - Cambio dimension campo NPOLIZA
   23.0       31/10/2013   FPG                23. 0028263: LCOL899-Proceso Emisi?n Vida Grupo - Desarrollo modificaciones de iAxis para BPM
   24.0       19/02/2014   RCL                24. 0029665: LCOL_PROD-Qtrackers Fase 2 - iAXIS Produccion
   25.0       31/03/2015   FAL                25. 0034462: I - GTEC2 + GTEC3. Suplementos Convenios
   26.0       30/06/2015   AFM                26. 0034462/208987: Después del suplem. regularización personas lanzar supl. modif. pregunta riesgo.
                                                  para modificar Pregunta nro asegurados.
   27.0       16/10/2015   KJSC               27. 36507  - 215507 Nueva funcion que trae el nombre del suplemento
   28.0       23/01/2018   JLTS               28. BUG CONF-1243 QT_724 - 23/01/2018 - Grabar datos de fechas para Vigencia Amparos (SUPLEMENTO 918)
   29.0       13/03/2019   CJMR               29. TCS-344 Funcionalidad Marcas.
   30.0       25/02/2020   CJMR               30. IAXIS-12903. Solución al bug
******************************************************************************/
   e_object_error    EXCEPTION;
   e_param_error     EXCEPTION;
   ispendentemetre   NUMBER    := 0;                    --// 1 TRUE  0 FALSE;

   /*************************************************************************
      Función que devuelve si el suplemento esta pendiente de emitir
      return : 1 esta pendiente de emitir
               0 ha sido emitido
   *************************************************************************/
   FUNCTION f_get_pendiente_emision
      RETURN NUMBER
   IS
   BEGIN
      RETURN ispendentemetre;
   END f_get_pendiente_emision;

   /*************************************************************************
      Procedimiento que modifica si el suplemento esta pendiente de emitir
   *************************************************************************/
   PROCEDURE p_set_pendiente_emision (pvalue NUMBER)
   IS
   BEGIN
      ispendentemetre := pvalue;
   END p_set_pendiente_emision;

   /*************************************************************************
      Función que devuelve ya se ha editado el suplemento
      return : 1 no existe
               0 se ha editado
   *************************************************************************/
   FUNCTION f_existcmotmov (pcmotmov IN NUMBER)
      RETURN NUMBER
   IS
   BEGIN
      IF lstmotmov IS NOT NULL
      THEN
         IF lstmotmov.COUNT > 0
         THEN
            FOR i IN lstmotmov.FIRST .. lstmotmov.LAST
            LOOP
               IF lstmotmov.EXISTS (i)
               THEN
                  IF lstmotmov (i).cmotmov = pcmotmov
                  THEN
                     RETURN 0;
                  END IF;
               END IF;
            END LOOP;
         END IF;
      END IF;

      RETURN 1;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN 1;
   END f_existcmotmov;

   FUNCTION f_recarregapol (psseguro IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER
   IS
      vpasexec   NUMBER (8)      := 1;
      vparam     VARCHAR2 (1000) := 'psseguro=' || psseguro;
      vobject    VARCHAR2 (200)  := 'PAC_IAX_SUPLEMENTOS.F_RecarregaPol';
      vnumerr    NUMBER (8)      := 0;
   BEGIN
      --Comprovació paràmetres d'entrada
      IF psseguro IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;
      -- recupera poliza real
      pac_iax_produccion.issuplem := FALSE;
      pac_iax_produccion.vsseguro := NULL;
      pac_iax_produccion.vnmovimi := NULL;
      pac_iax_produccion.vfefecto := NULL;
      p_set_pendiente_emision (0);
      vpasexec := 5;
      vnumerr :=
           pac_iax_produccion.f_set_consultapoliza (psseguro, mensajes, 'POL');

      IF vnumerr <> 0
      THEN
         RAISE e_object_error;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN 1;
   END f_recarregapol;

   /*************************************************************************
      Borra los registros de las tablas est y cancela el suplemento
   *************************************************************************/
   PROCEDURE limpiartemporales
   IS
      msj       t_iax_mensajes;
      vnumerr   NUMBER;
   BEGIN
      IF f_get_pendiente_emision = 0
      THEN
         RETURN;
      END IF;

      pac_md_suplementos.limpiartemporales (pac_iax_produccion.vsolicit,
                                            pac_iax_produccion.vnmovimi,
                                            pac_iax_produccion.vsseguro
                                           );
      vnumerr := f_recarregapol (pac_iax_produccion.vsseguro, msj);
      pac_iax_produccion.issuplem := FALSE;
      -- Bug 11735 - RSC - 19/01/2010 - APR - suplemento de modificación de capital /prima
      pac_iax_produccion.isaltagar := FALSE;
      pac_iax_produccion.imodifgar := FALSE;
      -- Fin Bug 11735

      -- Bug 11735 - RSC - 07/05/2010 - APR - suplemento de modificación de capital /prima
      pac_iax_produccion.isbajagar := FALSE;
      -- Fin Bug 11735
      p_set_pendiente_emision (0);
   END;

   /*************************************************************************
      Nos permite inicializar un seguro para realizar suplementos
      param in psseguro    : código del seguro
      param in pcmotmov    : código movimiento           (puede ser nulo => validación genérica)
      param out pmodfefe   : permite modificar fecha efecto del suplemento (0/1).
      param out mensajes   : colección de mensajes
      return               : 0 todo ha ido bien
                             1 se ha producido un error
   *************************************************************************/
   FUNCTION f_inicializar_suplemento (
      psseguro   IN       NUMBER,
      pcmotmov   IN       NUMBER,
      pfefecto   OUT      DATE,
      pmodfefe   OUT      NUMBER,
      pmodo      IN       VARCHAR2,
      mensajes   OUT      t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vnumerr     NUMBER (8)             := 0;
      vpasexec    NUMBER (8)             := 1;
      vparam      VARCHAR2 (1000)
         :=    'psseguro='
            || psseguro
            || ' - pcmotmov='
            || pcmotmov
            || ' - pmodo : '
            || pmodo;
      vobject     VARCHAR2 (200)
                             := 'PAC_IAX_SUPLEMENTOS.F_Inicializar_Suplemento';
      vfefecto    DATE;
      vnpoliza    NUMBER;
      -- Bug 28462 - 07/10/2013 - HRE - Cambio de dimension SSEGURO
      vncertif    seguros.ncertif%TYPE;
      v_sproduc   NUMBER;
      vcfefecto   VARCHAR2 (100);
      vcestado    CHAR (1);
      vcempres    NUMBER;
   BEGIN
      --Comprovació del pas de paràmetres
      IF psseguro IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      p_tab_error (f_sysdate, f_user, vobject, vpasexec, 'traza', vparam);
      vpasexec := 3;

      BEGIN
         SELECT sproduc
           INTO v_sproduc
           FROM estseguros
          WHERE sseguro = psseguro;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            BEGIN
               SELECT sproduc
                 INTO v_sproduc
                 FROM seguros
                WHERE sseguro = (SELECT ssegpol
                                   FROM estseguros
                                  WHERE sseguro = psseguro);
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  NULL;
            END;
      END;
      --vnumerr := pac_seguros.f_get_sproduc (psseguro, NULL, v_sproduc);
      p_tab_error (f_sysdate,
                   f_user,
                   vobject,
                   vpasexec,
                   'traza',
                   vparam || ' v_sproduc-->' || v_sproduc
                  );

      IF vnumerr <> 0
      THEN
         RAISE e_object_error;
      END IF;

      vcempres :=
         NVL (pac_md_common.f_get_cxtempresa,
              f_parinstalacion_n ('EMPRESADEF')
             );
      p_tab_error (f_sysdate,
                   f_user,
                   vobject,
                   vpasexec,
                   'traza',
                   vparam || ' vcempres-->' || vcempres
                  );

      IF NVL (pac_parametros.f_parempresa_n (vcempres, 'ENVIO_SRI'), 0) = 1
      THEN
         vnumerr := pac_sri.f_comprobar_sri (psseguro);

         IF vnumerr <> 0
         THEN
            pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, vnumerr);
            RETURN vnumerr;
         END IF;
      END IF;

      --Si la pòlissa està a mig realitzar suplements, la pòlissa ja ha estat inicialitzada anteriorment.
      IF f_get_pendiente_emision = 1
      THEN
         vpasexec := 5;
         pmodfefe := 0;
         -- Bug 11695 - 10/11/2009 - AMC
         --Miramos si el suplemento ya está marcado como incompatible (si se marcó al hacer los anteriores supls.)
         --De momento hacemos las select aquí directamente...
         vnumerr :=
            pac_md_suplementos.f_supl_incompatible (psseguro,
                                                    pcmotmov,
                                                    vcestado,
                                                    mensajes
                                                   );

         IF vnumerr <> 0
         THEN
            RAISE e_object_error;
         END IF;

         -- 29/06/2010 - JGR - 9. 0015215: CRE - Incidència al fer suplements en més d'un risc
         -- COMMENT del camp pds_segurosupl.cestado es: "Estado : 0, acción posible,X acción realizable,
         -- F:acción imcompatible con las hechas", per tant incompatible només es quan es valor "F".
         -- IF vcestado IN('X', 'F') THEN --> Comentat
         IF vcestado = 'F'
         THEN
            pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, 151391);
            RETURN 151391;                        --Suplementos incompatibles
         END IF;

         vpasexec := 9;
         --Al no tener configuración de acción buscamos la fecha del suplemento de la configuración indicada en las PDS
         p_tab_error (f_sysdate,
                      f_user,
                      vobject,
                      vpasexec,
                      'traza',
                         'psseguro-->'
                      || psseguro
                      || ' pnmovimi-->'
                      || psseguro
                      || ' pfefecto-->'
                      || pfefecto
                      || '  pcmotmov)-->'
                      || pcmotmov
                     );
         vnumerr :=
            pac_md_suplementos.f_get_fsupl_pds (v_sproduc,
                                                psseguro,
                                                pcmotmov,
                                                pfefecto,
                                                mensajes
                                               );

         IF vnumerr <> 0
         THEN
            RAISE e_object_error;
         END IF;

         --Fi Bug 11695 - 10/11/2009 - AMC
         RETURN 0;
      END IF;

      p_tab_error (f_sysdate,
                   f_user,
                   vobject,
                   vpasexec,
                   'traza',
                      'psseguro-->'
                   || psseguro
                   || ' pnmovimi-->'
                   || psseguro
                   || ' pfefecto-->'
                   || pfefecto
                   || '  pcmotmov)-->'
                   || pcmotmov
                  );
      vpasexec := 11;
      --Comprovació de que el suplement estigui permés/la pòlissa estigui en situació de realitzar suplements.
      -- INI IAXIS-12903 CJMR 25/02/2020
      --vfefecto := NVL (pfefecto, f_sysdate);
      IF pfefecto IS NULL THEN

          BEGIN
              SELECT m.fefecto
                INTO vfefecto
                FROM movseguro m
               WHERE m.sseguro = psseguro
                 AND m.nmovimi =
                        (SELECT MAX (mm.nmovimi)
                           FROM movseguro mm
                          WHERE mm.sseguro = psseguro
                            AND mm.cmovseg NOT IN (52)
                            AND mm.cmotmov NOT IN
                                   (999,
                                    996,
                                    997,
                                    403,
                                    391,
                                    pac_suspension.vcod_reinicio,
                                    261,
                                    263
                                   ));

              IF TRUNC(vfefecto) < TRUNC(f_sysdate) THEN
                  vfefecto := TRUNC(f_sysdate);
              END IF;

          EXCEPTION WHEN OTHERS THEN
              vfefecto := TRUNC(f_sysdate);
          END;

      END IF;
      -- FIN IAXIS-12903 CJMR 25/02/2020
      p_tab_error (f_sysdate,
                   f_user,
                   vobject,
                   vpasexec,
                   'traza',
                      'psseguro-->'
                   || psseguro
                   || ' pnmovimi-->'
                   || psseguro
                   || ' vfefecto-->'
                   || vfefecto
                   || '  pcmotmov)-->'
                   || pcmotmov
                  );
      vnumerr :=
         pac_md_suplementos.f_valida_poliza_permite_supl (psseguro,
                                                          vfefecto,
                                                          pcmotmov,
                                                          mensajes
                                                         );
      vpasexec := 181;
      --Comprovació de que el suplement estigui permés/la pòlissa estigui en situació de realitzar suplements.
      vfefecto := NVL (pfefecto, f_sysdate);
      p_tab_error (f_sysdate,
                   f_user,
                   vobject,
                   vpasexec,
                   'traza',
                      'psseguro-->'
                   || psseguro
                   || ' pnmovimi-->'
                   || psseguro
                   || ' vfefecto-->'
                   || vfefecto
                   || ' vnumerr-->'
                   || vnumerr
                  );

      IF vnumerr <> 0
      THEN
         RAISE e_object_error;
      END IF;

      -- DRA 16-12-2008: bug mantis 7826
      -- Validem si té accés per contractar el producte
      vpasexec := 13;
      vnumerr :=
         pac_md_validaciones.f_valida_acces_prod
                                               (v_sproduc,
                                                pac_md_common.f_get_cxtagente,
                                                6,
                                                mensajes
                                               );

      IF vnumerr <> 0
      THEN
         RAISE e_object_error;
      END IF;

      vpasexec := 15;
      --Obtenció de la data d'efecte del suplement i de l'indicador de si l'usuari pot modificar la data d'efecte del suplement.
      vnumerr :=
         pac_md_suplementos.f_calc_fefecto_supl
                                              (psseguro,
                                               pac_md_common.f_get_cxtusuario,
                                               pcmotmov,          --JAMF 11695
                                               pfefecto,
                                               pmodfefe,
                                               mensajes
                                              );

      IF vnumerr <> 0
      THEN
         RAISE e_object_error;
      END IF;

      IF pmodo IS NOT NULL AND pmodo = 'GESTRENOVA'
      THEN
         vnumerr := pk_suplementos.f_fcaranu (psseguro, pfefecto);

         IF vnumerr <> 0
         THEN
            pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, vnumerr);
            RAISE e_object_error;
         END IF;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN 1;
   END f_inicializar_suplemento;

   /*************************************************************************
      Nos permite editar una poliza en modo suplemento
      param in psseguro      : código del seguro
      param in pfefecto      : fecha de efecto del suplemento
      param in pcmotmov      : código motivo de movimiento
      param in out pestsseguro : sseguro d'estudi
      param in out mensajes  : colección de mensajes
      return                 : 0 todo ha ido bien
                               1 se ha producido un error
   *************************************************************************/
   FUNCTION f_editarsuplemento (
      psseguro      IN       NUMBER,
      pfefecto      IN       DATE,
      pcmotmov      IN       NUMBER,
      pestsseguro   OUT      NUMBER,
      mensajes      OUT      t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vpasexec      NUMBER (8)                := 1;
      vparam        VARCHAR2 (500)
         :=    'psseguro='
            || psseguro
            || ' pfefecto='
            || pfefecto
            || ' pcmotmov='
            || pcmotmov;
      vobject       VARCHAR2 (200) := 'PAC_IAX_SUPLEMENTOS.F_EditarSuplemento';
      vnumerr       NUMBER;
      vsseguro      NUMBER;
      vnpoliza      NUMBER;
      vncertif      seguros.ncertif%TYPE;
      vestsseguro   NUMBER;
      vnmovimi      NUMBER;
      vfsuplem      DATE;
      gest          ob_iax_gestion;
      vusufefecto   NUMBER;
      v_cmovseg     codimotmov.cmovseg%TYPE;    --BUG 34462 - FAL - 31/03/2015
   BEGIN
-- Inicio IAXIS-3398 31/07/2019 Marcelo Ozawa
      pac_iax_produccion.veditmotmov := pcmotmov;

-- Fin IAXIS-3398 31/07/2019 Marcelo Ozawa
      IF psseguro IS NULL
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, 101903);
         RAISE e_param_error;
      END IF;

      IF pcmotmov IS NULL
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, 1000509);
         RAISE e_param_error;
      END IF;

      vpasexec := 3;

      IF lstmotmov IS NOT NULL
      THEN
         IF lstmotmov.COUNT > 0
         THEN
            IF lstmotmov (lstmotmov.FIRST).sseguro <> psseguro
            THEN
               lstmotmov := t_iax_motmovsuple ();
            END IF;
         END IF;
      END IF;

      IF pac_iax_produccion.issuplem = FALSE
      THEN
         vpasexec := 5;

         --(JAS)06.06.2008 - Afegeixo data d'efecte com a paràmetre de entrada.
         --Comprovem que la data d'efecte ens vingui informda.
         IF pfefecto IS NULL
         THEN
            pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, 120077);
            RAISE e_object_error;
         END IF;

         vpasexec := 7;
         pac_iax_produccion.issuplem := FALSE;
         pac_iax_produccion.vsseguro := NULL;
         pac_iax_produccion.vnmovimi := NULL;
         pac_iax_produccion.vsolicit := NULL;
         pestsseguro := NULL;                           --BUG9727-28042009-XVM
         --PAC_IAX_PRODUCCION.vfefecto:=null;

         --ACC 131208 indica que la pòlissa estem consultant
         pac_iax_produccion.isconsult := FALSE;
         -- INI CONF-1243 QT_724 - 23/01/2018
         vnumerr :=
            pac_md_suplementos.f_editarsuplemento (psseguro,
                                                   pcmotmov,
                                                   pfefecto,
                                                   vnmovimi,
                                                   vestsseguro,
                                                   mensajes
                                                  );

         -- FIN CONF-1243 QT_724 - 23/01/2018
         IF vnumerr <> 0
         THEN
            RAISE e_object_error;
         END IF;

         --BUG9727-28042009-XVM
         pestsseguro := vestsseguro;
         vpasexec := 9;
         pac_iax_produccion.issuplem := TRUE;
         pac_iax_produccion.vsseguro := psseguro;
         pac_iax_produccion.vnmovimi := vnmovimi;
         pac_iax_produccion.vsolicit := vestsseguro;
         --ACC 131208 indica que la pòlissa estem consultant
         pac_iax_produccion.isconsult := TRUE;
         vpasexec := 11;
         vnumerr :=
            pac_iax_produccion.f_set_consultapoliza (vestsseguro,
                                                     mensajes,
                                                     'EST'
                                                    );

         IF vnumerr <> 0
         THEN
            pac_iax_produccion.issave := FALSE;
            pac_iax_produccion.issuplem := FALSE;
            pac_iax_produccion.vsseguro := NULL;
            pac_iax_produccion.vnmovimi := NULL;
            pac_iax_produccion.vsolicit := NULL;
            --ACC 131208 indica que la pòlissa estem consultant
            pac_iax_produccion.isconsult := FALSE;
            RAISE e_object_error;
         END IF;

         pac_iax_produccion.issave := FALSE;
         p_set_pendiente_emision (1);
         vpasexec := 13;
         COMMIT;
      ELSE
         -- Bug 12206  - RSC - 14/12/2009 - CRE201 - Incidencias Ramo Salud - Diciembre 2009
         pestsseguro := pac_iax_produccion.vsolicit;
         -- Bug 12206
         vpasexec := 21;
         --gest := PAC_IOBJ_PROD.F_PARTPOLDATOSGESTION(PAC_IOBJ_PROD.F_GETPOLIZA(MENSAJES),MENSAJES);
         vnumerr :=
            pk_suplementos.f_fecha_efecto (pac_iax_produccion.vsolicit,
                                           pac_iax_produccion.vnmovimi,
                                           vfsuplem
                                          );

         IF vnumerr <> 0
         THEN
            RAISE e_object_error;
         END IF;

         vpasexec := 23;
         vnumerr :=
            pac_md_suplementos.f_valida_poliza_permite_supl (psseguro,
                                                             vfsuplem,
                                                             pcmotmov,
                                                             mensajes
                                                            );

         IF vnumerr <> 0
         THEN
            RAISE e_object_error;
         END IF;
      END IF;

      IF vnumerr = 0
      THEN
         vpasexec := 27;

         IF lstmotmov IS NULL
         THEN
            lstmotmov := t_iax_motmovsuple ();
         END IF;

         vpasexec := 29;

         IF f_existcmotmov (pcmotmov) = 1
         THEN
            lstmotmov.EXTEND ();
            lstmotmov (lstmotmov.LAST) := ob_iax_motmovsuple ();
            lstmotmov (lstmotmov.LAST).cmotmov := pcmotmov;
            lstmotmov (lstmotmov.LAST).sseguro := psseguro;
         END IF;

         vpasexec := 31;
      END IF;

      -- BUG 0034462 - FAL - 31/03/2015. Obliga a tarifar riesgos en supl. regularización
      /*
      vnumerr := pk_suplementos.f_get_cmovseg(pcmotmov, v_cmovseg);
      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;
      */
      BEGIN
         SELECT cmovseg
           INTO v_cmovseg
           FROM codimotmov
          WHERE cmotmov = pcmotmov;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            v_cmovseg := NULL;
      END;

      IF v_cmovseg = 6
      THEN
         pac_iax_produccion.poliza.det_poliza.p_set_needtarificar (1);
      END IF;

      IF pac_iax_suplementos.lstmotmov (1).cmotmov = 918
      THEN
         pac_iax_produccion.poliza.det_poliza.p_set_needtarificar (0);
      END IF;

      -- FI BUG 0034462
      RETURN vnumerr;
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
   END f_editarsuplemento;

   /*************************************************************************
      Emitimos la propuesta de suplemento
      param in out mensajes  : colección de mensajes
      return                 : 0 todo ha ido bien
                               1 se ha producido un error
   *************************************************************************/
   FUNCTION f_emitirpropuesta (mensajes OUT t_iax_mensajes)
      RETURN NUMBER
   IS
      vpasexec         NUMBER (8)                    := 1;
      vparam           VARCHAR2 (500)                := NULL;
      vobject          VARCHAR2 (200)
                                   := 'PAC_IAX_SUPLEMENTOS.F_EmitirPropuesta';
      nerr             NUMBER;
      onpoliza         NUMBER;
      osseguro         NUMBER;
      vsseguro         NUMBER;
      vvsseguro        NUMBER;
      vmsj             VARCHAR2 (500);
      vnmovimi         NUMBER;
      vsproduc         NUMBER;
      vsinterf         NUMBER;
      verror           VARCHAR2 (2000);
      -- Bug 9905 - 24/04/2009 - RSC - Suplemento de cambio de forma de pago diferido
      v_cmotmovs       t_lista_id;
      v_texto          VARCHAR2 (2000);
      -- Fin Bug 9905

      -- Bug 18351 - RSC - 09/08/2011 - LCOL003 - Documentación requerida en contratación y suplementos
      v_haypendiente   NUMBER;
      v_produce_req    NUMBER;
      v_emitir         NUMBER                        := 0;
                                  --0. Emetre, 1. retenerpropuesta , 2. Error
      -- Fin Bug 18351
      v_sproces        procesoslin.sproces%TYPE;
      -- Bug 24278 - APD - 03/12/2012
      v_fefecto        movseguro.fefecto%TYPE;
      -- Bug 24278 - APD - 03/12/2012
      v_contadif       NUMBER;         --BUG 029665/166752 - RCL - 19/02/2014
      v_npoliza        NUMBER;         --BUG 029665/166752 - RCL - 19/02/2014
      v_cmovseg        NUMBER;         --BUG 034462/208987 - AFM - 30/06/2015
      v_sseguro        NUMBER;         --BUG 034462/208987 - AFM - 30/06/2015
      v_nmovimi        NUMBER;         --BUG 034462/208987 - AFM - 30/06/2015
      hay_asegmes      NUMBER;         --BUG 034462/208987 - AFM - 30/06/2015
      --INI CJMR 13/03/2019
      cur_marcas       sys_refcursor;
      v_sperson        per_agr_marcas.sperson%TYPE;
      v_area           VARCHAR2 (500);
      v_cmarca         per_agr_marcas.cmarca%TYPE;
      v_descripcion    VARCHAR2 (500);
      v_tipo           VARCHAR2 (50);
      v_caacion        agr_marcas.caacion%TYPE;
      v_accion         VARCHAR2 (50);
      v_persona        VARCHAR2 (500);
      v_rol            VARCHAR2 (50);
      v_validamarca    BOOLEAN                       := FALSE;
   --FIN CJMR 13/03/2019
   BEGIN
      v_sseguro := pac_iax_produccion.vsseguro;
      --BUG 034462/208987 - AFM - 30/06/2015
      v_nmovimi := pac_iax_produccion.vnmovimi;
      --BUG 034462/208987 - AFM - 30/06/2015
--      p_tab_error (f_sysdate,
--                   f_user,
--                   vobject,
--                   1,
--                   'fechat 77',
--                      ' v_sseguro-->'
--                   || v_sseguro
--                   || ' v_nmovimi-->'
--                   || v_nmovimi
--                   || 'pac_iax_produccion.vsolicit  '
--                   || pac_iax_produccion.vsolicit
--                  );
      --INI CJMR 13/03/2019
      cur_marcas :=
         pac_md_marcas.f_get_marcas_poliza (pac_md_common.f_get_cxtempresa,
                                            pac_iax_produccion.vsolicit,
                                            'EST',
                                            mensajes
                                           );

      FETCH cur_marcas
       INTO v_sperson, v_area, v_cmarca, v_descripcion, v_tipo, v_caacion,
            v_accion, v_persona, v_rol;

      WHILE cur_marcas%FOUND
      LOOP
         IF v_caacion != 0
         THEN
            v_validamarca := TRUE;
            pac_iobj_mensajes.crea_nuevo_mensaje
                           (mensajes,
                            1,
                            0,
                               f_axis_literales (9909325,
                                                 pac_md_common.f_get_cxtidioma
                                                )
                            || ' :'
                            || ' Area:'
                            || v_area
                            || ' Marca:'
                            || v_cmarca
                            || ' '
                            || v_descripcion
                            || ' Tipo:'
                            || v_tipo
                            || ' Accion:'
                            || v_accion
                            || ' Persona:'
                            || v_persona
                            || ' Rol:'
                            || v_rol
                           );
         END IF;

         FETCH cur_marcas
          INTO v_sperson, v_area, v_cmarca, v_descripcion, v_tipo, v_caacion,
               v_accion, v_persona, v_rol;
      END LOOP;

      IF (v_validamarca)
      THEN
         RAISE e_object_error;
      END IF;

      --FIN CJMR 13/03/2019

      -- Bug 9905 - 29/04/2009 - RSC - Suplemento de cambio de forma de pago diferido
      IF pac_iax_suplementos.f_eval_diferidos_futuro
                                                 (pac_iax_produccion.vsseguro,
                                                  f_sysdate,
                                                  mensajes
                                                 ) = 1
      THEN
         -- Bug 9905 - 24/04/2009 - RSC - Suplemento de cambio de forma de pago diferido
         nerr :=
            pac_iax_suplementos.f_get_diferir_cmotmovs
                                                (pac_iax_produccion.vsolicit,
                                                 pac_iax_produccion.vnmovimi,
                                                 v_cmotmovs,
                                                 mensajes
                                                );

         IF nerr <> 0
         THEN
            pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, nerr);
            vpasexec := 1;
            RAISE e_object_error;
         END IF;

         nerr :=
            pac_iax_suplementos.f_valida_emision_diferidos
                                        (v_cmotmovs,
                                         pac_iax_produccion.poliza.det_poliza,
                                         v_texto,
                                         mensajes
                                        );

         IF nerr <> 0
         THEN
            pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 2, NULL, v_texto);
            vpasexec := 1;
         --RAISE e_object_error;
         END IF;
      END IF;

      -- Fin Bug 9905
--      p_tab_error (f_sysdate,
--                   f_user,
--                   vobject,
--                   1,
--                   'fechat 78',
--                      ' v_sseguro-->'
--                   || v_sseguro
--                   || ' v_nmovimi-->'
--                   || v_nmovimi
--                   || 'pac_iax_produccion.vsolicit  '
--                   || pac_iax_produccion.vsolicit
--                   || 'pac_iax_produccion.vsseguro'
--                   || pac_iax_produccion.vsseguro
--                  );
      IF pac_iax_produccion.vsseguro IS NOT NULL
      THEN
         nerr :=
            pac_seguros.f_get_sproduc (pac_iax_produccion.vsseguro,
                                       NULL,
                                       vsproduc
                                      );
--         p_tab_error (f_sysdate,
--                      f_user,
--                      vobject,
--                      1,
--                      'fechat 79 ',
--                         ' v_sseguro-->'
--                      || v_sseguro
--                      || ' v_nmovimi-->'
--                      || v_nmovimi
--                      || 'pac_iax_produccion.vsolicit  '
--                      || pac_iax_produccion.vsolicit
--                      || 'pac_iax_produccion.vsseguro'
--                      || pac_iax_produccion.vsseguro
--                      || 'nerr'
--                      || nerr
--                     );
      ELSIF pac_iax_produccion.vsolicit IS NOT NULL
      THEN
         IF nerr <> 0
         THEN
            nerr :=
               pac_seguros.f_get_sproduc (pac_iax_produccion.vsolicit,
                                          NULL,
                                          vsproduc
                                         );
         END IF;
--         p_tab_error (f_sysdate,
--                      f_user,
--                      vobject,
--                      1,
--                      'fechat 80',
--                         ' v_sseguro-->'
--                      || v_sseguro
--                      || ' v_nmovimi-->'
--                      || v_nmovimi
--                      || 'pac_iax_produccion.vsolicit  '
--                      || pac_iax_produccion.vsolicit
--                      || 'pac_iax_produccion.vsseguro'
--                      || pac_iax_produccion.vsseguro
--                      || 'nerr'
--                      || nerr
--                     );
      END IF;

      IF nerr <> 0
      THEN
         RAISE e_object_error;
      END IF;

      -- DRA 29/10/2008: bug mantis 7519
      vpasexec := 7;
      -- Bug 20672 - RSC - 17/01/2012 - LCOL_T001-LCOL - UAT - TEC: Suplementos
      --IF (NVL(pac_mdpar_productos.f_get_parproducto('PSU', vsproduc), 0) = 0) THEN
      -- FIn bug 20672

      -- Bug 18351 - RSC - 09/08/2011 - LCOL003 - Documentación requerida en contratación y suplementos
      vpasexec := 21;
      -- Validem si hi ha documentació requerida pendent
      v_haypendiente :=
         pac_md_docrequerida.f_aviso_docreq_pendiente
                        (pac_iax_produccion.vsolicit,
                         pac_iax_produccion.poliza.det_poliza.nmovimi,
                         pac_iax_produccion.poliza.det_poliza.sproduc,
                         pac_iax_produccion.poliza.det_poliza.gestion.cactivi,
                         mensajes
                        );
      v_produce_req :=
         NVL (pac_parametros.f_parempresa_n (pac_md_common.f_get_cxtempresa,
                                             'PRODUCE_REQUERIDA'
                                            ),
              0
             );

      -- Bug 20672 - RSC - 17/01/2012 - LCOL_T001-LCOL - UAT - TEC: Suplementos
      --END IF;
      -- Fin bug 20672
      IF v_haypendiente <> 0 AND v_produce_req <> 0
      THEN
         IF v_produce_req = 1
         THEN
            -- Error
            v_emitir := 2;
            pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 2, 9902065);
            vpasexec := 22;
            RAISE e_object_error;
         ELSIF v_produce_req = 2
         THEN
            -- retenerpropuesta
            v_emitir := 1;
         END IF;
      END IF;

      IF v_emitir = 0
      THEN
         -- Fin 18351 - RSC - 09/08/2011 - LCOL003 - Documentación requerida en contratación y suplementos

         -- toda la informació s'ha de baixar a la base de dades
         vpasexec := 2;

         -- Bug 11735 - RSC - 03/02/2010 - suplemento de modificación de capital /prima
         -- Bug 11735 - RSC - 07/05/2010 - APR - suplemento de modificación de capital /prima
         -- Bug 0017881 - JMF - 09/03/2011
         IF     NVL
                   (pac_parametros.f_parproducto_n
                                (pac_iax_produccion.poliza.det_poliza.sproduc,
                                 'DETALLE_GARANT'
                                ),
                    0
                   ) IN (1, 2)
            AND (   pac_iax_produccion.isaltagar
                 OR pac_iax_produccion.imodifgar
                 OR pac_iax_produccion.isbajagar
                )
         THEN
            vpasexec := 221;
            nerr := 0;
         ELSE
            -- Fin bug 11735
            -- Bug 0017881 - JMF - 09/03/2011
            IF pac_iax_produccion.issuplem
            THEN
               vpasexec := 221;

               -- BUG 17341 - 24/01/2011 - JMP  - Para algunos suplementos no se debe grabar en BDD
               IF pac_md_produccion.f_bloqueo_grabarobjectodb
                                   (pac_iax_suplementos.lstmotmov (1).sseguro,
                                    pac_iax_suplementos.lstmotmov (1).cmotmov,
                                    mensajes
                                   ) = 0
               THEN
                  vpasexec := 223;
                  nerr := pac_iax_produccion.f_grabarobjetodb (mensajes);
               END IF;
            ELSE
               vpasexec := 224;
               nerr := pac_iax_produccion.f_grabarobjetodb (mensajes);
            END IF;
         -- FIN BUG 17341 - 24/01/2011 - JMP
         END IF;

         IF nerr = 1
         THEN
            pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, 9000773);
            vpasexec := 3;
            RAISE e_object_error;
         END IF;

         vsseguro := pac_iax_produccion.vsolicit;
         vvsseguro := pac_iax_produccion.vsseguro;
   p_tab_error (f_sysdate,
                      f_user,
                      vobject,
                      vpasexec,
                      'tras',
                         ' vsseguro-->'
                      || vsseguro
                      || ' vvsseguro-->'
                      || vvsseguro
                      || ' vnmovimi-->'
                      || vnmovimi
                      || 'ponpoliza  '
                      || onpoliza
                      || 'posseguro  '
                      || osseguro
                      || 'nerr '
                      || nerr
                     );

         IF vvsseguro IS NULL
         THEN
             p_tab_error (f_sysdate,
                      f_user,
                      vobject,
                      vpasexec,
                      'tras',
                         ' vsseguro-2->'
                      || vsseguro
                      || ' vvsseguro-->'
                      || vvsseguro
                      || ' vnmovimi-->'
                      || vnmovimi
                      || 'ponpoliza  '
                      || onpoliza
                      || 'posseguro  '
                      || osseguro
                      || 'nerr '
                      || nerr
                     );
            BEGIN
               SELECT ssegpol
                 INTO vvsseguro
                 FROM estseguros
                WHERE sseguro = vsseguro;
                p_tab_error (f_sysdate,
                      f_user,
                      vobject,
                      vpasexec,
                      'tras',
                         ' vsseguro-3->'
                      || ' vvsseguro-->'
                      || vvsseguro
                      || ' vnmovimi-->'
                      || vnmovimi
                      || 'ponpoliza  '
                      || onpoliza
                      || 'posseguro  '
                      || osseguro
                      || 'nerr '
                      || nerr
                     );
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  BEGIN
                     SELECT sseguro
                       INTO vvsseguro
                       FROM seguros
                      WHERE nsolici = vsseguro;
                      p_tab_error (f_sysdate,
                      f_user,
                      vobject,
                      vpasexec,
                      'tras',
                         ' vsseguro-4->'
                      || vsseguro
                      || ' vvsseguro-->'
                      || vvsseguro
                      || ' vnmovimi-->'
                      || vnmovimi
                      || 'ponpoliza  '
                      || onpoliza
                      || 'posseguro  '
                      || osseguro
                      || 'nerr '
                      || nerr
                     );
                  EXCEPTION
                     WHEN NO_DATA_FOUND
                     THEN
                        NULL;
                  END;
            END;
         END IF;
p_tab_error (f_sysdate,
                      f_user,
                      vobject,
                      vpasexec,
                      'tras',
                         ' vsseguro-5->'
                      || vsseguro
                      || ' vvsseguro-->'
                      || vvsseguro
                      || ' vnmovimi-->'
                      || vnmovimi
                      || 'ponpoliza  '
                      || onpoliza
                      || 'posseguro  '
                      || osseguro
                      || 'nerr '
                      || nerr
                     );
         vpasexec := 331;
         nerr :=
            pac_md_suplementos.f_emitir_suplemento (vsseguro,
                                                    vvsseguro,
                                                    FALSE,
                                                    vnmovimi,
                                                    --BUG18926 - JTS - 15/07/2011
                                                    onpoliza,
                                                    osseguro,
                                                    mensajes
                                                   );
         p_tab_error (f_sysdate,
                      f_user,
                      vobject,
                      vpasexec,
                      'tras',
                         ' vsseguro-->'
                      || vsseguro
                      || ' vvsseguro-->'
                      || vnmovimi
                      || ' vnmovimi-->'
                      || vvsseguro
                      || 'ponpoliza  '
                      || onpoliza
                      || 'posseguro  '
                      || osseguro
                      || 'nerr '
                      || nerr
                     );

         IF nerr <> 0
         THEN
            RAISE e_object_error;
         --RETURN nerr;
         END IF;

         vpasexec := 6;
         nerr :=
            pac_seguros.f_get_sproduc (NVL (osseguro, vvsseguro),
                                       NULL,
                                       vsproduc
                                      );

         IF nerr <> 0
         THEN
            RAISE e_object_error;
         END IF;

         -- DRA 29/10/2008: bug mantis 7519
         vpasexec := 7;

         IF     (pac_mdpar_productos.f_get_parproducto ('COBRO_AUTOMATICO',
                                                        vsproduc
                                                       ) = 1
                )
            AND nerr = 0
         THEN
            nerr :=
               pac_md_produccion.f_cobro_recibos (NVL (osseguro, vvsseguro),
                                                  vnmovimi,
                                                  NULL,
                                                  NULL,
                                                  NULL,
                                                  mensajes
                                                 );

            IF nerr <> 0
            THEN
               --RETURN nerr;
               --COMMIT;
               RAISE e_object_error;
            END IF;
         END IF;

         COMMIT;

         --Inici BUG 029665/166752 - RCL - 19/02/2014
         IF pac_seguros.f_get_escertifcero (NULL, NVL (osseguro, vvsseguro)) =
                                                                             1
         THEN
            -- Obtener NPOLIZA del coelctivo:
            SELECT npoliza
              INTO v_npoliza
              FROM seguros
             WHERE sseguro = NVL (osseguro, vvsseguro);

            -- Obtener si hay suplementos diferidos programados:
            SELECT COUNT (1)
              INTO v_contadif
              FROM sup_diferidosseg
             WHERE sseguro IN (SELECT sseguro
                                 FROM seguros
                                WHERE npoliza = v_npoliza)
               AND nmovimi = vnmovimi;

            IF v_contadif > 0
            THEN
               -- Bug 24278 - APD - 03/12/2012
               -- Si la emisi??el suplemento ha ido correctamente, ejecutar los
               -- suplementos diferidos programados en caso de colectivo (ncertif = 0)
               nerr :=
                  pac_iax_suplementos.f_ejecuta_supl_certifs (NVL (osseguro,
                                                                   vvsseguro
                                                                  ),
                                                              NULL,
                                                              mensajes
                                                             );

               IF nerr <> 0
               THEN
                  RAISE e_object_error;
               END IF;
            -- fin Bug 24278 - APD - 03/12/2012
            END IF;
         END IF;

         --Fi BUG 029665/166752 - RCL - 19/02/2014

         -- BUG19863:DRA:21/10/2011: Se pasa el parametro a productos
         IF NVL (pac_parametros.f_parproducto_n (vsproduc,
                                                 'INT_SINCRON_POLIZA'
                                                ),
                 0
                ) = 1
         THEN
            nerr :=
               pac_md_con.f_proceso_alta
                                   (pac_md_common.f_get_cxtempresa, -- empresa
                                    NVL (osseguro, vvsseguro),        --seguro
                                    vnmovimi,                       -- nmovimi
                                    'M',         -- A (alta ) 'M' (suplemento)
                                    f_user,                           -- fuser
                                    vsinterf,                       -- ni caso
                                    verror                          -- ni caso
                                   );
            COMMIT;
         END IF;

         vpasexec := 8;
         p_set_pendiente_emision (0);
         vpasexec := 9;
         nerr := f_recarregapol (NVL (osseguro, vvsseguro), mensajes);

         IF nerr = 0
         THEN
            -- Bug 9905 - 30/04/2009 - RSC - Suplemento de cambio de forma de pago diferido
            IF v_texto IS NOT NULL
            THEN
               vmsj :=
                  pac_iobj_mensajes.f_get_descmensaje
                                               (151301,
                                                pac_md_common.f_get_cxtidioma
                                               );

               IF NVL
                     (pac_parametros.f_parempresa_n
                                              (pac_md_common.f_get_cxtempresa,
                                               'SHOW_MOV'
                                              ),
                      0
                     ) = 1
               THEN
                  pac_iobj_mensajes.crea_nuevo_mensaje
                           (mensajes,
                            2,
                            NULL,
                               '<span style="color: red;">'
                            || v_texto
                            || '</span><br>'
                            || vmsj
                            || ' '
                            || onpoliza
                            || '. '
                            || f_axis_literales (9001954,
                                                 pac_md_common.f_get_cxtidioma
                                                )
                            || ': '
                            || vnmovimi
                           );
               ELSE
                  pac_iobj_mensajes.crea_nuevo_mensaje
                                             (mensajes,
                                              2,
                                              NULL,
                                                 '<span style="color: red;">'
                                              || v_texto
                                              || '</span><br>'
                                              || vmsj
                                              || ' '
                                              || onpoliza
                                             );
               END IF;
            ELSE
               -- Fin Bug 9905
               vmsj :=
                  pac_iobj_mensajes.f_get_descmensaje
                                               (151301,
                                                pac_md_common.f_get_cxtidioma
                                               );

               IF NVL
                     (pac_parametros.f_parempresa_n
                                              (pac_md_common.f_get_cxtempresa,
                                               'SHOW_MOV'
                                              ),
                      0
                     ) = 1
               THEN
                  pac_iobj_mensajes.crea_nuevo_mensaje
                           (mensajes,
                            2,
                            151301,
                               vmsj
                            || ' '
                            || onpoliza
                            || '. '
                            || f_axis_literales (9001954,
                                                 pac_md_common.f_get_cxtidioma
                                                )
                            || ': '
                            || vnmovimi
                           );
               ELSE
                  pac_iobj_mensajes.crea_nuevo_mensaje (mensajes,
                                                        2,
                                                        151301,
                                                        vmsj || ' '
                                                        || onpoliza
                                                       );
               END IF;
            END IF;
         END IF;

         nerr :=
            pac_md_docrequerida.f_subir_docsgedox (osseguro,
                                                   vnmovimi,
                                                   mensajes
                                                  );

         IF nerr > 0
         THEN
            vpasexec := 10;
            RAISE e_object_error;
         END IF;

         -- BUG 28263 - 31/10/2013 - FPG - Inicio
         IF nerr = 0
         THEN
            nerr :=
               pac_md_bpm.f_lanzar_proceso (osseguro,
                                            vnmovimi,
                                            NULL,
                                            '*',
                                            'EMITIDA',
                                            mensajes
                                           );
            COMMIT;
            nerr := 0;
         END IF;
      -- BUG 28263 - 31/10/2013 - FPG - Final
      ELSE
         -- Actulizamos el crteni de las tablas est.
         pac_iax_produccion.poliza.det_poliza.creteni := 1;
         nerr :=
            pac_md_docrequerida.f_retencion
                       (pac_iax_produccion.vsolicit,
                        pac_iax_produccion.poliza.det_poliza.nmovimi,
                        pac_iax_produccion.poliza.det_poliza.gestion.fefecto,
                        mensajes
                       );

         IF nerr > 0
         THEN
            vpasexec := 15;
            RAISE e_object_error;
         END IF;

         nerr :=
            pac_iax_produccion.f_retenerpropuesta (onpoliza,
                                                   osseguro,
                                                   mensajes
                                                  );

         IF nerr > 0
         THEN
            vpasexec := 16;
            RAISE e_object_error;
         END IF;
      END IF;

       -- Inicio del BUG: 0034462 nota: 0208987
       -- Si el suplemento que se acaba de realizar es un suplemento de regularización de personas
       -- y además existen ASEGURADOSMES, Se genera un nuevo suplemento de cambio de numero de asegurados
      -- incorporando el promedio resultante en el suplemento de regularización.
       --
      BEGIN
         SELECT cmovseg
           INTO v_cmovseg
           FROM movseguro
          WHERE sseguro = v_sseguro AND nmovimi = v_nmovimi;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            v_cmovseg := 0;
      END;

      --
      IF v_cmovseg = 6
      THEN
         SELECT COUNT (1)
           INTO hay_asegmes
           FROM aseguradosmes
          WHERE sseguro = v_sseguro AND nmovimi = v_nmovimi;
      END IF;

      --
      IF v_cmovseg = 6 AND NVL (hay_asegmes, 0) > 0
      THEN
         nerr := pac_sup_general.f_cambio_aut_numaseg (v_sseguro);

         IF nerr = 0
         THEN
            -- Se ha actualizado la pregunta nro. de asegurados con el promedio calculado.
            vmsj :=
               pac_iobj_mensajes.f_get_descmensaje
                                               (9908264,
                                                pac_md_common.f_get_cxtidioma
                                               );
            pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 2, 9908264, vmsj);
            COMMIT;
         ELSE
            -- No se puede realizar la actualización de la pregunta nro de personas. Tiene que realizarse manualmente.
            vmsj :=
               pac_iobj_mensajes.f_get_descmensaje
                                               (9908265,
                                                pac_md_common.f_get_cxtidioma
                                               );
            pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 2, 9908265, vmsj);
         END IF;
      END IF;

      RETURN nerr;
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
   END f_emitirpropuesta;

   /*************************************************************************
      Recupera el detalle del movimiento
      param in psseguro      : código del seguro
      param in pnmovimi      : número de movimiento
      param in out mensajes  : colección de mensajes
      return                 : objeto detalle movimientos
   *************************************************************************/
   FUNCTION f_get_detailmov (
      psseguro   IN       NUMBER,
      pnmovimi   IN       NUMBER,
      mensajes   OUT      t_iax_mensajes
   )
      RETURN t_iax_detmovseguro
   IS
      detmov     t_iax_detmovseguro;
      vpasexec   NUMBER (8)         := 1;
      vparam     VARCHAR2 (500)
                       := 'psseguro=' || psseguro || ' pnmovimi=' || pnmovimi;
      vobject    VARCHAR2 (200)     := 'PAC_IAX_SUPLEMENTOS.F_Get_DetailMov';
   BEGIN
      detmov :=
         pac_md_suplementos.f_get_detailmov (psseguro,
                                             pnmovimi,
                                             pac_md_common.f_get_cxtidioma,
                                             mensajes
                                            );
      RETURN detmov;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN NULL;
   END f_get_detailmov;

   /*************************************************************************
      Recupera el detalle del movimiento del suplemento para tablas EST
      param in out mensajes  : colección de mensajes
      return                 : objeto detalle movimientos
   *************************************************************************/
   FUNCTION f_get_detailmovsupl (
      pcmotmov   IN       NUMBER,
      mensajes   OUT      t_iax_mensajes
   )
      RETURN t_iax_detmovseguro
   IS
      vpasexec        NUMBER (8)         := 1;
      vnumerr         NUMBER (8)         := 0;
      vparam          VARCHAR2 (500)     := 'pcmotmov: ' || pcmotmov;
      vobject         VARCHAR2 (200)
                                 := 'PAC_IAX_SUPLEMENTOS.f_get_detailmovsupl';
      vtobdetmovseg   t_iax_detmovseguro;
      vobdetpoliza    ob_iax_detpoliza;
      vefecto         DATE;
      vsseguro        NUMBER;
      vnmovimi        NUMBER;
      vcagrupa        NUMBER             := 0;     --IAXIS-2085 03/04/2019 AP
   BEGIN
      -- toda la informació s'ha de baixar a la base de dades

      -- Bug 11735 - RSC - 03/02/2010 - suplemento de modificación de capital /prima
      -- Bug 13832 - RSC - 17/06/2010 - APRS015 - suplemento de aportaciones únicas (añadimos isaltagar y isbajagar)
      -- Bug 0017881 - JMF - 09/03/2011
      IF     NVL
                (pac_parametros.f_parproducto_n
                                (pac_iax_produccion.poliza.det_poliza.sproduc,
                                 'DETALLE_GARANT'
                                ),
                 0
                ) IN (1, 2)
         AND (   pac_iax_produccion.imodifgar
              OR pac_iax_produccion.isaltagar
              OR pac_iax_produccion.isbajagar
             )
      THEN
         vnumerr := 0;
      ELSE
         -- Fin Bug 11735

         -- Bug 0017881 - JMF - 09/03/2011
         IF pac_iax_produccion.issuplem
         THEN
            -- BUG 17341 - 24/01/2011 - JMP  - Para algunos suplementos no se debe grabar en BDD
            IF pac_md_produccion.f_bloqueo_grabarobjectodb
                                   (vsseguro,
                                    pac_iax_suplementos.lstmotmov (1).cmotmov,
                                    mensajes
                                   ) = 0
            THEN
               vnumerr := pac_iax_produccion.f_grabarobjetodb (mensajes);
            END IF;
         ELSE
            vnumerr := pac_iax_produccion.f_grabarobjetodb (mensajes);
         END IF;
      -- FIN BUG 17341 - 24/01/2011 - JMP
      END IF;

      IF vnumerr <> 0
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, 9000773);
         vpasexec := 3;
         RAISE e_object_error;
      END IF;

      vpasexec := 3;
      vobdetpoliza := pac_iobj_prod.f_getpoliza (mensajes);

      IF vobdetpoliza IS NULL
      THEN
         RAISE e_object_error;
      END IF;

      vsseguro := pac_iax_produccion.vsolicit;
      vnmovimi := pac_iax_produccion.vnmovimi;
      vpasexec := 5;
      vnumerr :=
         pac_md_suplementos.f_preprocesarsuplemento (lstmotmov,
                                                     vsseguro,
                                                     mensajes
                                                    );

      IF vnumerr <> 0
      THEN
         RAISE e_object_error;
      END IF;

      -- INI IAXIS-2085 03/04/2019 AP
      BEGIN
         SELECT cagrupa
           INTO vcagrupa
           FROM esttomadores
          WHERE sseguro = vsseguro;
      EXCEPTION
         WHEN OTHERS
         THEN
            NULL;
      END;

      --
      vcagrupa := 0;
      -- FIN IAXIS-2085 03/04/2019 AP
      vpasexec := 7;
      vnumerr :=
         pac_md_suplementos.f_validar_cambios (vsseguro,
                                               vnmovimi,
                                               vobdetpoliza.sproduc,
                                               mensajes,
                                               pcmotmov
                                              );

      IF vnumerr <> 0
      THEN
         -- dra 24/12/2008
         -- PAC_IOBJ_MENSAJES.Crea_Nuevo_Mensaje(mensajes,1,39385,'No se ha podido almecenar la información correctamente');
         RAISE e_object_error;
      END IF;

      vpasexec := 9;
      --Recuperem la data d'efecte del suplement
      -- Ini IAXIS-3504 -- ECP -- 27/12/2019
      vparam :=
            vparam
         || 'sseguro '
         || vsseguro
         || 'vnmovimi '
         || vnmovimi
         || 'vefecto '
         || vefecto;
--      p_tab_error (f_sysdate,
--                   f_user,
--                   vobject,
--                   vpasexec,
--                   'traza',
--                      vparam
--                   || 'vsseguro-->'
--                   || vsseguro
--                   || ' vnmovimi-->'
--                   || vnmovimi
--                   || 'vefecto-->'
--                   || vefecto
--                  );
      vnumerr :=
         pk_suplementos.f_inicializar_fechas
                                (vsseguro,
                                 vnmovimi,
                                 pac_iax_produccion.poliza.det_poliza.sproduc,
                                 vefecto,
                                 'SUPLEMENTO',
                                 pcmotmov
                                );
      vpasexec := 911;
--      p_tab_error (f_sysdate,
--                   f_user,
--                   vobject,
--                   vpasexec,
--                   'traza',
--                      vparam
--                   || 'vsseguro-->'
--                   || vsseguro
--                   || ' vnmovimi-->'
--                   || vnmovimi
--                   || 'vefecto-->'
--                   || vefecto
--                   || 'vnumerr '
--                   || vnumerr
--                  );
      -- Fin IAXIS-3504 -- ECP -- 27/12/2019
      vnumerr := pk_suplementos.f_fecha_efecto (vsseguro, vnmovimi, vefecto);
      vparam :=
            vparam
         || 'sseguro '
         || vsseguro
         || 'vnmovimi '
         || vnmovimi
         || ' vefecto '
         || vefecto
         || 'vnumerr '
         || vnumerr;

--      p_tab_error (f_sysdate, f_user, vobject, vpasexec, 'traza 1', vparam);
      IF vnumerr <> 0
      THEN
         RAISE e_object_error;
      END IF;

      vpasexec := 11;

      --INI IAXIS-2085 03/04/2019 AP
      BEGIN
         SELECT cagrupa
           INTO vcagrupa
           FROM esttomadores
          WHERE sseguro = vsseguro;
      EXCEPTION
         WHEN OTHERS
         THEN
            NULL;
      END;

      --
      vcagrupa := 0;
      --FIN IAXIS-2085 03/04/2019 AP
      vpasexec := 12;
--      p_tab_error (f_sysdate,
--                   f_user,
--                   vobject,
--                   vpasexec,
--                   'traza 1',
--                   vparam || ' vefecto-->' || vefecto
--                  );
      vtobdetmovseg :=
         pac_md_suplementos.f_get_detailmovsupl
                                               (vsseguro,
                                                vnmovimi,
                                                vefecto,
                                                pac_md_common.f_get_cxtidioma,
                                                mensajes
                                               );

      -- INI IAXIS-2085 03/04/2019 AP
      BEGIN
         SELECT cagrupa
           INTO vcagrupa
           FROM esttomadores
          WHERE sseguro = vsseguro;
      EXCEPTION
         WHEN OTHERS
         THEN
            NULL;
      END;

      --FIN IAXIS-2085 03/04/2019 AP
      -- INi 3504 --ECP -- 02/01/2020;
      IF vtobdetmovseg IS NULL
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, 107804);
         vpasexec := 3;
      END IF;

      -- Fin 3504 --ECP -- 02/01/2020;
      RETURN vtobdetmovseg;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN NULL;
   END f_get_detailmovsupl;

   /*************************************************************************
      Recupera los motivos de retención de la póliza
      param in out mensajes  : colección de mensajes
      return                 : objeto lista motivos póliza retenida
   *************************************************************************/
   FUNCTION f_get_mvtretencion (mensajes OUT t_iax_mensajes)
      RETURN t_iax_polmvtreten
   IS
      vret       t_iax_polmvtreten;
      vpasexec   NUMBER (8)        := 1;
      vparam     VARCHAR2 (500)    := NULL;
      vobject    VARCHAR2 (200)   := 'PAC_IAX_SUPLEMENTOS.F_Get_MvtRetencion';
   BEGIN
      IF pac_iax_produccion.issuplem = FALSE
      THEN
         RETURN NULL;
      END IF;

      vret :=
         pac_iax_produccion.f_get_motretenmov (pac_iax_produccion.vsolicit,
                                               pac_iax_produccion.vnmovimi,
                                               mensajes
                                              );
      RETURN vret;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN NULL;
   END f_get_mvtretencion;

   --ACC 13122008
   /*************************************************************************
      Anula el riesgo especificado
      param in psseguro   : número seguro tablas est
      param in pnriesgo   : número de riesgo
      param in pfanulac   : fecha anulación
      param in pnmovimi   : número movimiento
      param in pssegpol   : número seguro real
      param out mensajes  : colección de mensajes
      return              : objeto lista motivos póliza retenida
      return              : 0 todo ha ido bien
                            1 se ha producido un error
   *************************************************************************/
   FUNCTION f_anular_riesgo (
      psseguro   IN       NUMBER,
      pnriesgo   IN       NUMBER,
      pfanulac   IN       DATE,
      pnmovimi   IN       NUMBER,
      pssegpol   IN       NUMBER,
      mensajes   OUT      t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (500) := 'pnriesgo ' || pnriesgo;
      vobject    VARCHAR2 (200) := 'PAC_IAX_SUPLEMENTOS.F_Anular_Riesgo';
      nerr       NUMBER;
   BEGIN
      IF pnriesgo IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 1;
      nerr :=
         pac_md_suplementos.f_anular_riesgo (psseguro,
                                             pnriesgo,
                                             pfanulac,
                                             pnmovimi,
                                             pssegpol,
                                             mensajes
                                            );
      RETURN nerr;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN 1;
   END f_anular_riesgo;

--ACC 13122008

   /*************************************************************************
      Obtiene la lista de motivos de movimiento implicados en una modificación
      generada por un suplemento seleccionado por pantalla.


      param in psseguro   : Identificador de seguro
      param in pnmovimi   : Identificador de movimiento (suplemento)
      param out pcmotmovs : Lista de motivos.
      param out mensajes  : Mensajes.

      return              : 0 --> OK, <> 0 --> Error
   *************************************************************************/
   -- Bug 9905 - 24/04/2009 - RSC - Suplemento de cambio de forma de pago diferido
   FUNCTION f_get_diferir_cmotmovs (
      psseguro    IN       NUMBER,
      pnmovimi    IN       NUMBER,
      pcmotmovs   OUT      t_lista_id,
      mensajes    OUT      t_iax_mensajes
   )
      RETURN NUMBER
   IS
      verror     NUMBER;
      vpasexec   NUMBER         := 1;
      vparam     VARCHAR2 (500) := NULL;
      vobject    VARCHAR2 (200)
                              := 'PAC_IAX_SUPLEMENTOS.f_get_diferir_cmotmovs';
   BEGIN
      verror :=
         pac_md_suplementos.f_get_diferir_cmotmovs (psseguro,
                                                    pnmovimi,
                                                    pcmotmovs,
                                                    mensajes
                                                   );

      IF verror <> 0
      THEN
         RETURN verror;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN 1;
   END f_get_diferir_cmotmovs;

   -- Fin Bug 9905

   /*************************************************************************
      Determina si dos códigos de movimiento son compatibles o no.

      param in pcmotmov1   : Código de movimiento 1
      param in pcmotmov2   : Código de movimiento 2

      return              : 0 no son compatibles
                            1 son compatibles
   *************************************************************************/
   -- Bug 9905 - 24/04/2009 - RSC - Suplemento de cambio de forma de pago diferido
   FUNCTION f_cmotmov_compatibles (
      pcmotmovs   IN       t_lista_id,
      mensajes    OUT      t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vpasexec   NUMBER         := 1;
      vparam     VARCHAR2 (500) := NULL;
      vobject    VARCHAR2 (200)
                               := 'PAC_IAX_SUPLEMENTOS.f_cmotmov_compatibles';
   BEGIN
      IF pcmotmovs IS NOT NULL
      THEN
         IF pcmotmovs.COUNT > 0
         THEN
            FOR i IN pcmotmovs.FIRST .. pcmotmovs.LAST
            LOOP
               IF pcmotmovs.EXISTS (i)
               THEN
                  -- Todos contra todos
                  FOR j IN pcmotmovs.FIRST .. pcmotmovs.LAST
                  LOOP
                     IF pcmotmovs (i).idd <> pcmotmovs (j).idd
                     THEN
                        IF pac_md_suplementos.f_cmotmov_compatibles
                                                           (pcmotmovs (i).idd,
                                                            pcmotmovs (j).idd
                                                           ) = 0
                        THEN
                           RETURN 0;
                        END IF;
                     END IF;
                  END LOOP;
               END IF;
            END LOOP;
         END IF;
      END IF;

      RETURN 1;
   EXCEPTION
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN 1;
   END f_cmotmov_compatibles;

   -- Fin Bug 9905

   /*************************************************************************
      Realiza el diferimiento de suplemento tratando cada motivo de movimiento
      seleccionado y difiriendolo.

      param in pcmotmovs   : Lista de motivos de movimiento implicados.
      param in ppoliza     : Objeto OB_IAX_DETPOLIZA de la selección.
      param out mensajes   : Mensajes.
      return               : 0 --> OK, <> 0 --> Error
   *************************************************************************/
   -- Bug 9905 - 24/04/2009 - RSC - Suplemento de cambio de forma de pago diferido
   FUNCTION f_tratar_diferidos_motmov (
      pcmotmovs   IN       t_lista_id,
      ppoliza     IN       ob_iax_detpoliza,
      pfdifer     IN       VARCHAR2,
      mensajes    OUT      t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vpasexec   NUMBER         := 1;
      vparam     VARCHAR2 (500) := NULL;
      vobject    VARCHAR2 (200)
                               := 'PAC_IAX_SUPLEMENTOS.f_cmotmov_compatibles';
      v_nerr     NUMBER;
   BEGIN
      IF pcmotmovs IS NOT NULL
      THEN
         IF pcmotmovs.COUNT > 0
         THEN
            FOR i IN pcmotmovs.FIRST .. pcmotmovs.LAST
            LOOP
               IF pcmotmovs.EXISTS (i)
               THEN
                  IF pcmotmovs (i).idd = 269
                  THEN                          -- Canvi de forma de pagament
                     v_nerr :=
                        pac_md_suplementos.f_diferir_spl_formapago (ppoliza,
                                                                    pfdifer,
                                                                    mensajes
                                                                   );

                     IF v_nerr <> 0
                     THEN
                        RETURN v_nerr;
                     END IF;
                  END IF;

                  /*IF pcmotmovs(i).idd = 281 THEN   -- Modificación de garantías
                                       v_nerr := pac_md_suplementos.f_diferir_spl_garantias(ppoliza, pfdifer,
                                                                                            mensajes);
                                       IF v_nerr <> 0 THEN
                                          RETURN v_nerr;
                                       END IF;
                     END IF;*/
                  IF pcmotmovs (i).idd = 220
                  THEN                             -- Cambio de revalorización
                     v_nerr :=
                        pac_md_suplementos.f_diferir_spl_revali (ppoliza,
                                                                 pfdifer,
                                                                 mensajes
                                                                );

                     IF v_nerr <> 0
                     THEN
                        RETURN v_nerr;
                     END IF;
                  END IF;

                  IF pcmotmovs (i).idd = 685
                  THEN                  -- Modificación de preguntas de riesgo
                     v_nerr :=
                        pac_md_suplementos.f_diferir_spl_preguntas (ppoliza,
                                                                    pfdifer,
                                                                    mensajes
                                                                   );

                     IF v_nerr <> 0
                     THEN
                        RETURN v_nerr;
                     END IF;
                  END IF;

                  IF pcmotmovs (i).idd = 801
                  THEN                             -- Cambio de revalorización
                     v_nerr :=
                        pac_md_suplementos.f_diferir_spl_sobreprimas
                                                                    (ppoliza,
                                                                     pfdifer,
                                                                     mensajes
                                                                    );

                     IF v_nerr <> 0
                     THEN
                        RETURN v_nerr;
                     END IF;
                  END IF;

                  IF pcmotmovs (i).idd = 225
                  THEN                                    -- Cambio de oficina
                     v_nerr :=
                        pac_md_suplementos.f_diferir_spl_agente (ppoliza,
                                                                 pfdifer,
                                                                 mensajes
                                                                );

                     IF v_nerr <> 0
                     THEN
                        RETURN v_nerr;
                     END IF;
                  END IF;

                  IF pcmotmovs (i).idd = 237
                  THEN                            -- Alta de garantias/amparos
                     v_nerr :=
                        pac_md_suplementos.f_diferir_spl_alta_garan (ppoliza,
                                                                     pfdifer,
                                                                     mensajes
                                                                    );

                     IF v_nerr <> 0
                     THEN
                        RETURN v_nerr;
                     END IF;
                  END IF;

                  IF pcmotmovs (i).idd = 239
                  THEN                            -- Baja de garantias/amparos
                     v_nerr :=
                        pac_md_suplementos.f_diferir_spl_baja_garan (ppoliza,
                                                                     pfdifer,
                                                                     mensajes
                                                                    );

                     IF v_nerr <> 0
                     THEN
                        RETURN v_nerr;
                     END IF;
                  END IF;

                  IF pcmotmovs (i).idd = 355
                  THEN                                 -- Aumento de capitales
                     v_nerr :=
                        pac_md_suplementos.f_diferir_spl_aumento_cap
                                                                    (ppoliza,
                                                                     pfdifer,
                                                                     mensajes
                                                                    );

                     IF v_nerr <> 0
                     THEN
                        RETURN v_nerr;
                     END IF;
                  END IF;

                  IF pcmotmovs (i).idd = 356
                  THEN                             -- Disminución de capitales
                     v_nerr :=
                        pac_md_suplementos.f_diferir_spl_disminucion_cap
                                                                    (ppoliza,
                                                                     pfdifer,
                                                                     mensajes
                                                                    );

                     IF v_nerr <> 0
                     THEN
                        RETURN v_nerr;
                     END IF;
                  END IF;
               END IF;
            END LOOP;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN 1;
   END f_tratar_diferidos_motmov;

   -- Fin Bug 9905

   /*************************************************************************
      Funcion inicial que arranca todo el proceso de diferimiento de suplemento.

      param out mensajes   : Mensajes.
      return               : 0 no son compatibles
                             1 son compatibles
   *************************************************************************/
   -- Bug 9905 - 24/04/2009 - RSC - Suplemento de cambio de forma de pago diferido
   FUNCTION f_diferirpropuesta (
      pfdifer    IN       VARCHAR2,
      mensajes   OUT      t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vpasexec          NUMBER (8)             := 1;
      vparam            VARCHAR2 (500)         := NULL;
      vobject           VARCHAR2 (200)
                                   := 'PAC_IAX_SUPLEMENTOS.F_EmitirPropuesta';
      nerr              NUMBER;
      onpoliza          NUMBER;
      osseguro          NUMBER;
      vsseguro          NUMBER;
      vvsseguro         NUMBER;
      vmsj              VARCHAR2 (500);
      vnmovimi          NUMBER;
      vsproduc          NUMBER;
      vsinterf          NUMBER;
      verror            VARCHAR2 (2000);
      vpoliza           ob_iax_poliza          := pac_iax_produccion.poliza;
      v_updatedif       VARCHAR2 (1000);
      vtest             NUMBER;
      v_cmotmovs        t_lista_id;
      v_npoliza         seguros.npoliza%TYPE;
      v_hay_diferidos   NUMBER;
   BEGIN
      --VALIDAR_DIFERIR_SUPL
      --Indica si hay que validar los suplementos diferidos. Si es así no se podrán diferir mas de un suplemento
      --De momento sólo para los productos de vida individual de POSITIVA
      IF NVL (pac_parametros.f_parproducto_n (pac_iax_produccion.vproducto,
                                              'VALIDAR_DIFERIR_SUPL'
                                             ),
              0
             ) = 1
      THEN
         SELECT COUNT (*)
           INTO v_hay_diferidos
           FROM sup_diferidosseg
          WHERE sseguro = pac_iax_produccion.vsseguro AND estado = 0;

         --0-Abierto
         IF v_hay_diferidos > 0
         THEN
            ROLLBACK;
            pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, 9001506);
            --Existe una programación pendiente para este tipo de suplemento diferido. Revise los suplementos diferidos.
            RETURN 1;
         END IF;
      END IF;

      nerr :=
         pac_iax_suplementos.f_get_diferir_cmotmovs
                                                 (pac_iax_produccion.vsolicit,
                                                  pac_iax_produccion.vnmovimi,
                                                  v_cmotmovs,
                                                  mensajes
                                                 );

      IF nerr <> 0
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, nerr);
         vpasexec := 1;
         RAISE e_object_error;
      END IF;

      nerr := pac_iax_suplementos.f_cmotmov_compatibles (v_cmotmovs, mensajes);

      IF nerr = 0
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, 9001503);
         vpasexec := 1;
         RAISE e_object_error;
      END IF;

      nerr :=
         pac_iax_suplementos.f_tratar_diferidos_motmov (v_cmotmovs,
                                                        vpoliza.det_poliza,
                                                        pfdifer,
                                                        mensajes
                                                       );

      IF nerr <> 0
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, nerr);
         vpasexec := 1;
         RAISE e_object_error;
      END IF;

      IF nerr = 0
      THEN
         COMMIT;
         vmsj :=
            pac_iobj_mensajes.f_get_descmensaje
                                               (9001508,
                                                pac_md_common.f_get_cxtidioma
                                               );
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes,
                                               2,
                                               9001508,
                                                  vmsj
                                               || ' '
                                               || vpoliza.det_poliza.npoliza
                                              );
      END IF;

      RETURN nerr;
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
   END f_diferirpropuesta;

   -- Fin Bug 9905

   /*************************************************************************
      A la hora de emitir un suplemento se debe validar si existen suplementos
      diferidos que coincidan con el suplemento que se está realizando, en cuyo caso,
      se deberá de informar un mensaje y revisar los suplemento diferidos.

      param in pcmotmovs   : Lista de motivos de movimiento.
      param in ppoliza     : Objeto OB_IAX_DETPOLIZA de la selección
      param out ptexto     : Variable que almacena todos los mensajes de incompatibilidad.
      param out mensajes  : Mensajes.

      return              : 0 --> OK, 1 --> Error
   *************************************************************************/
   -- Bug 9905 - 24/04/2009 - RSC - Suplemento de cambio de forma de pago diferido
   FUNCTION f_valida_emision_diferidos (
      pcmotmovs   IN       t_lista_id,
      ppoliza              ob_iax_detpoliza,
      ptexto      OUT      VARCHAR2,
      mensajes    OUT      t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vpasexec   NUMBER         := 1;
      vparam     VARCHAR2 (500) := NULL;
      vobject    VARCHAR2 (200)
                               := 'PAC_IAX_SUPLEMENTOS.f_cmotmov_compatibles';
      v_nerr     NUMBER;
   BEGIN
      v_nerr :=
         pac_md_suplementos.f_valida_emision_diferidos (pcmotmovs,
                                                        ppoliza,
                                                        ptexto,
                                                        mensajes
                                                       );

      IF v_nerr <> 0
      THEN
         RETURN v_nerr;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN 1;
   END f_valida_emision_diferidos;

   -- Fin Bug 9905

   /*************************************************************************
      Evalua si un seguro debe diferir algun suplemento en el futuro.

      param in psseguro     : Objeto OB_IAX_DETPOLIZA de la selección
      param in ppoliza     : Objeto OB_IAX_DETPOLIZA de la selección
      param out mensajes   : Mensajes

      return              : 0 --> OK, <> 0 --> Error
   *************************************************************************/
   -- Bug 9905 - 29/04/2009 - RSC - Suplemento de cambio de forma de pago diferido
   FUNCTION f_eval_diferidos_futuro (
      psseguro   IN       NUMBER,
      pfecha     IN       DATE,
      mensajes   OUT      t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vpasexec   NUMBER         := 1;
      vparam     VARCHAR2 (500) := NULL;
      vobject    VARCHAR2 (200)
                             := 'PAC_IAX_SUPLEMENTOS.f_eval_diferidos_futuro';
      v_error    NUMBER;
   BEGIN
      v_error :=
         pac_md_suplementos.f_eval_diferidos_futuro (psseguro,
                                                     pfecha,
                                                     mensajes
                                                    );

      IF v_error <> 0
      THEN
         RETURN v_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN 1;
   END f_eval_diferidos_futuro;

   -- Fin Bug 9905

   /*************************************************************************
      Función para averiguar si el botón Diferir debe o no debe estar
      habilitado.

      param in psseguro     : Identificador de seguro
      param in pfecha       :
      param out mensajes    : Mensajes

      return              : 0 --> OK, <> 0 --> Error
   *************************************************************************/
   -- Bug 9905 - 24/04/2009 - RSC - Suplemento de cambio de forma de pago diferido
   FUNCTION f_habilita_diferir (
      psseguro   IN       NUMBER,
      pmostrar   OUT      NUMBER,
      mensajes   OUT      t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vpasexec      NUMBER (8)             := 1;
      vparam        VARCHAR2 (500)         := NULL;
      vobject       VARCHAR2 (200)
                                  := 'PAC_IAX_SUPLEMENTOS.f_habilita_diferir';
      nerr          NUMBER;
      v_cmotmovs    t_lista_id;
      v_npoliza     seguros.npoliza%TYPE;
      v_resultado   NUMBER;
      v_mostrar     NUMBER;
   BEGIN
      IF psseguro IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      nerr :=
         pac_iax_suplementos.f_get_diferir_cmotmovs
                                                 (pac_iax_produccion.vsolicit,
                                                  pac_iax_produccion.vnmovimi,
                                                  v_cmotmovs,
                                                  mensajes
                                                 );

      IF nerr <> 0
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, nerr);
         vpasexec := 1;
         RAISE e_object_error;
      END IF;

      vpasexec := 3;
      v_resultado :=
         pac_md_suplementos.f_habilita_diferir (pac_iax_produccion.vsseguro,
                                                v_cmotmovs,
                                                v_mostrar,
                                                mensajes
                                               );

      IF v_resultado <> 0
      THEN
         RAISE e_object_error;
      END IF;

      pmostrar := v_mostrar;
      RETURN 0;
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
   END f_habilita_diferir;

   /***********************************************************************
      Recupera los movimientos de suplementos diferidos de la póliza.

      param out mensajes : mensajes de error
      return             : ref cursor
   ***********************************************************************/
   -- Bug 9905 - 04/05/2009 - RSC - Suplemento de cambio de forma de pago diferido
   FUNCTION f_get_mvtdiferidos (psolicit IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (1)   := NULL;
      vobject    VARCHAR2 (200) := 'PAC_IAX_SUPLEMENTOS.f_get_mvtdiferidos';
   BEGIN
      cur := pac_md_suplementos.f_get_mvtdiferidos (psolicit, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_mvtdiferidos;

   -- Fin Bug 9905

   /*************************************************************************
      Función para marcar el radio button de fecha de diferimiento por defecto
      al diferir.

      param in psseguro     : Identificador de seguro
      param in pfecha       :
      param out mensajes    : Mensajes

      return              : 0 --> OK, <> 0 --> Error
   *************************************************************************/
   -- Bug 9905 - 04/05/2009 - RSC - Suplemento de cambio de forma de pago diferido
   FUNCTION f_get_fecha_diferir (
      psseguro   IN       NUMBER,
      pfechap    OUT      VARCHAR2,
      mensajes   OUT      t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vpasexec      NUMBER (8)             := 1;
      vparam        VARCHAR2 (500)         := NULL;
      vobject       VARCHAR2 (200)
                                  := 'PAC_IAX_SUPLEMENTOS.f_habilita_diferir';
      nerr          NUMBER;
      v_cmotmovs    t_lista_id;
      v_npoliza     seguros.npoliza%TYPE;
      v_resultado   NUMBER;
   BEGIN
      IF psseguro IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      nerr :=
         pac_iax_suplementos.f_get_diferir_cmotmovs
                                                 (pac_iax_produccion.vsolicit,
                                                  pac_iax_produccion.vnmovimi,
                                                  v_cmotmovs,
                                                  mensajes
                                                 );

      IF nerr <> 0
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, nerr);
         vpasexec := 1;
         RAISE e_object_error;
      END IF;

      vpasexec := 3;
      v_resultado :=
         pac_md_suplementos.f_get_fecha_diferir (pac_iax_produccion.vsseguro,
                                                 v_cmotmovs,
                                                 pfechap,
                                                 mensajes
                                                );
      RETURN v_resultado;
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
   END f_get_fecha_diferir;

   /*************************************************************************
      Función para averiguar si el botón Diferir debe o no debe mostrarse.

      param out pmostrar    : Indicador de si debe o no mostrar el botón Diferir.
      param out mensajes    : Mensajes
      return              : 0 --> OK, <> 0 --> Error
   *************************************************************************/
   -- Bug 9905 - 05/05/2009 - RSC - Suplemento de cambio de forma de pago diferido
   FUNCTION f_mostrar_diferir (pmostrar OUT NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER
   IS
      vpasexec    NUMBER (8)     := 1;
      vparam      VARCHAR2 (500) := NULL;
      vobject     VARCHAR2 (200) := 'PAC_IAX_SUPLEMENTOS.f_mostrar_diferir';
      num_err     NUMBER;
      v_mostrar   NUMBER;
   BEGIN
      vpasexec := 2;
      num_err :=
         pac_md_suplementos.f_mostrar_diferir
                                             (pac_md_common.f_get_cxtempresa,
                                              v_mostrar,
                                              mensajes
                                             );

      IF num_err <> 0
      THEN
         RAISE e_object_error;
      END IF;

      pmostrar := v_mostrar;
      RETURN 0;
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
   END f_mostrar_diferir;

   /*************************************************************************
      Función para averiguar si el botón Diferir debe o no debe mostrarse.

      param out pmostrar    : Indicador de si debe o no mostrar el botón Diferir.
      param out mensajes    : Mensajes
      return              : 0 --> OK, <> 0 --> Error
   *************************************************************************/
   -- Bug 9905 - 05/05/2009 - RSC - Suplemento de cambio de forma de pago diferido
   FUNCTION f_anular_abrir_diferido (
      pcmotmov   IN       NUMBER,
      psseguro   IN       NUMBER,
      pestado    IN       NUMBER,
      mensajes   OUT      t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vpasexec    NUMBER (8)     := 1;
      vparam      VARCHAR2 (500) := NULL;
      vobject     VARCHAR2 (200)
                             := 'PAC_IAX_SUPLEMENTOS.f_anular_abrir_diferido';
      num_err     NUMBER;
      v_mostrar   NUMBER;
   BEGIN
      IF pcmotmov IS NULL OR psseguro IS NULL OR pestado IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      num_err :=
         pac_md_suplementos.f_anular_abrir_diferido (pcmotmov,
                                                     psseguro,
                                                     pestado,
                                                     mensajes
                                                    );

      IF num_err <> 0
      THEN
         RAISE e_object_error;
      END IF;

      RETURN 0;
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
   END f_anular_abrir_diferido;

   /*************************************************************************
    Funcion que recupera los diferentes suplementos permitidos para cada producto y empresa
    param in psproduc : codigo del producto
    param out pcurconfigsupl : Cursor con los suplementos permitidos
    param out mensajes    : Mensajes
    param in psseguro   : sseguro (default NULL)
    param in ptablas    : tipo tablas (default NULL)
    retorno : 0 ok
              1 error
   -- Bug 10781 - 21/01/2010 - XPL
   *************************************************************************/
   FUNCTION f_get_suplementos (
      psproduc         IN       NUMBER,
      pcurconfigsupl   OUT      sys_refcursor,
      mensajes         OUT      t_iax_mensajes,
      psseguro         IN       NUMBER DEFAULT NULL,
      ptablas          IN       VARCHAR2 DEFAULT NULL
   )
      RETURN NUMBER
   IS
      vpasexec    NUMBER (8)     := 1;
      vparam      VARCHAR2 (500) := NULL;
      vobject     VARCHAR2 (200) := 'PAC_IAX_SUPLEMENTOS.f_get_suplementos';
      num_err     NUMBER;
      v_mostrar   NUMBER;
      squery      VARCHAR2 (500);
   BEGIN
      vpasexec := 2;
      -- Inici Bug 23860 - 11/07/2013 - RCL
      num_err :=
         pac_md_suplementos.f_get_suplementos (psproduc,
                                               pcurconfigsupl,
                                               mensajes,
                                               psseguro,
                                               ptablas
                                              );

      -- Fi Bug 23860 - 11/07/2013 - RCL
      IF num_err <> 0
      THEN
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN 1;
   END f_get_suplementos;

   /*************************************************************************
    FUNCTION f_insdetmovseguro
    param out mensajes    : Mensajes
    retorno : 0 ok
              1 error
   -- Bug 17255 - 05/07/2011 - JTS
   *************************************************************************/
   FUNCTION f_insdetmovseguro (
      psseguro   IN       NUMBER,
      pcmotmov   IN       NUMBER,
      pnmovimi   IN       NUMBER,
      pdespues   IN       VARCHAR2,
      mensajes   OUT      t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (500) := NULL;
      vobject    VARCHAR2 (200) := 'PAC_IAX_SUPLEMENTOS.f_insdetmovseguro';
      num_err    NUMBER;
   BEGIN
      vpasexec := 2;
      num_err :=
         pac_md_suplementos.f_insdetmovseguro (psseguro,
                                               pcmotmov,
                                               pnmovimi,
                                               pdespues,
                                               mensajes
                                              );

      IF num_err <> 0
      THEN
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         ROLLBACK;
         RETURN 1;
   END f_insdetmovseguro;

-- Bug 24278 - APD - 03/11/2012 - se crea la funcion
/*******************************************************************************
   Funcion que ejecuta los suplementos diferidos/automaticos programados para
   un colectivo para un movimiento determinado
   psseguro PARAM IN : Seguro
   pnmovimi PARAM IN : Movimiento del suplemento
 *******************************************************************************/
   FUNCTION f_ejecuta_supl_certifs (
      psseguro   IN       NUMBER,
      pnmovimi   IN       NUMBER,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vpasexec         NUMBER (8)               := 1;
      vparam           VARCHAR2 (500)
                  := 'psseguro = ' || psseguro || '; pnmovimi = ' || pnmovimi;
      vobject          VARCHAR2 (200)
                              := 'PAC_IAX_SUPLEMENTOS.f_ejecuta_supl_certifs';
      num_err          NUMBER;
      vsproces         NUMBER                   := NULL;
      vfefecto         movseguro.fefecto%TYPE;
      -- Bug 24278 - APD - 03/12/2012
      v_es_col_admin   NUMBER;                -- Bug 24278 - APD - 03/12/2012
      v_emitir         NUMBER                   := 0;
      -- bug 25583 JDS - 07-02-2013
      vsproduc         NUMBER;         -- Bug 29358/162059 - 07/01/2014 - AMC
      v_plsql          VARCHAR2 (500);
   BEGIN
      vpasexec := 1;

      IF psseguro IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;

      -- Bug 29358/162059 - 07/01/2014 - AMC
      SELECT sproduc
        INTO vsproduc
        FROM seguros
       WHERE sseguro = psseguro;

      vpasexec := 3;

      IF NVL (pac_md_param.f_get_parproducto_n (vsproduc,
                                                'DIFIERE_JOB',
                                                mensajes
                                               ),
              0
             ) = 1
      THEN
         vpasexec := 4;
         v_plsql :=
               'declare num_err NUMBER; '
            || ' begin '
            || CHR (10)
            || 'num_err:= pac_contexto.f_inicializarctx('
            || CHR (39)
            || f_user
            || CHR (39)
            || ');'
            || CHR (10)
            || ' num_err:= PAC_IAX_SUPLEMENTOS.F_LANZAPROCESO_DIFERIDOS('
            || psseguro
            || ','
            || NVL (TO_CHAR (pnmovimi), 'null')
            || '); '
            || CHR (10)
            || ' end;';
         vpasexec := 5;
         num_err := pac_jobs.f_ejecuta_job (NULL, v_plsql, NULL);

         IF num_err <> 0
         THEN
            RAISE e_object_error;
         END IF;
      ELSE
         -- Bug 30448/0169858 - APD - 17/03/2014
         num_err :=
            pac_iax_suplementos.f_lanzaproceso_diferidos (psseguro, pnmovimi);

         IF num_err <> 0
         THEN
            RAISE e_object_error;
         END IF;
/*
         -- Si es el certificado 0
         IF pac_seguros.f_get_escertifcero(NULL, psseguro) = 1 THEN
            -- Poliza administrada si f_es_col_admin = 1
            v_es_col_admin := pac_seguros.f_es_col_admin(psseguro, 'SEG');

            IF pnmovimi IS NULL THEN
               IF v_es_col_admin = 1 THEN
                  -- se debe abrir automaticamente el suplemento del certificado 0
                  -- para poder ejecutar los suplementos diferidos programados
                  -- en sus ncertifs
                  num_err := pac_md_produccion.f_abrir_suplemento(psseguro, mensajes);

                  IF num_err <> 0 THEN
                     RAISE e_object_error;
                  END IF;

                  COMMIT;
               END IF;

               vsproces := NULL;
               num_err := pac_md_suplementos.f_ejecuta_supl_certifs(psseguro, pnmovimi,
                                                                    vsproces, mensajes);

               IF num_err <> 0 THEN
                  RAISE e_object_error;
               END IF;

               IF v_es_col_admin = 1 THEN
                  num_err := pac_iax_produccion.f_emitir_col_admin(psseguro, v_emitir,
                                                                   mensajes, 0);   --6166

                  IF num_err <> 0 THEN
                     RAISE e_object_error;
                  END IF;
               END IF;
            ELSE
               -- no se debe abrir el suplemento 670 del certifcado 0 ya que s??se quiere
               -- ejecutar los suplementos diferidos de sus certificados para un movimiento
               -- en concreto
               vsproces := NULL;
               num_err := pac_md_suplementos.f_ejecuta_supl_certifs(psseguro, pnmovimi,
                                                                    vsproces, mensajes);

               IF num_err <> 0 THEN
                  RAISE e_object_error;
               END IF;
            END IF;
         END IF;
*/       -- fin Bug 30448/0169858 - APD - 17/03/2014
      END IF;

      -- Fi Bug 29358/162059 - 07/01/2014 - AMC
      RETURN 0;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         ROLLBACK;
         RETURN 1;
   END f_ejecuta_supl_certifs;

   -- Bug 24278 - APD - 10/12/2012 - se crea la funcion
/*******************************************************************************
   Funcion que pregunta si se existe algun suplemento que se debe propagar
   ptablas PARAM IN : EST o REA
   psseguro PARAM IN : Seguro
   pnmovimi PARAM IN : Movimiento del suplemento
   pcvalpar PARAM IN : Valor del parmotmov
   pcmotmov PARAM IN : Motivo
   pcidioma PARAM IN : Idioma
   opropaga PARAM OUT: 0.-No se propaga ning?plemento
                       1.-Si se propaga alg?plemento
   otexto PARAM OUT : Texto de la pregunta que se le realiza al usuario
                      (solo para el caso cvalpar = 2)
********************************************************************************/
   FUNCTION f_pregunta_propaga_suplemento (
      ptablas    IN       VARCHAR2,
      psseguro   IN       NUMBER,
      pnmovimi   IN       NUMBER,
      pcmotmov   IN       NUMBER,
      pcidioma   IN       NUMBER,
      opropaga   OUT      NUMBER,
      otexto     OUT      VARCHAR2,
      mensajes   OUT      t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vpasexec   NUMBER (8)       := 1;
      vparam     VARCHAR2 (10000)
         :=    'ptablas = '
            || ptablas
            || '; psseguro = '
            || psseguro
            || '; pnmovimi = '
            || pnmovimi
            || '; pcmotmov = '
            || pcmotmov
            || '; pcidioma = '
            || pcidioma;
      vobject    VARCHAR2 (200)
                        := 'PAC_IAX_SUPLEMENTOS.f_pregunta_propaga_suplemento';
      num_err    NUMBER;
   BEGIN
      IF psseguro IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      num_err :=
         pac_md_suplementos.f_pregunta_propaga_suplemento (ptablas,
                                                           psseguro,
                                                           pnmovimi,
                                                           pcmotmov,
                                                           pcidioma,
                                                           opropaga,
                                                           otexto,
                                                           mensajes
                                                          );

      IF num_err <> 0
      THEN
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN 1;
   END f_pregunta_propaga_suplemento;

-- Bug 24278 - APD - 11/12/2012 - se crea la funcion
/*******************************************************************************
   Funcion que actualiza el valor del campo detmovseguro.cpropagasupl
   ptablas PARAM IN : EST o REA
   psseguro PARAM IN : Seguro
   pnmovimi PARAM IN : Movimiento del suplemento
   pcmotmov PARAM IN : Motivo
   pcpropagasupl PARAM IN : Valor que indica si se propaga el suplemento a sus certificado
                            en funcion de la decision del usuario
********************************************************************************/
   FUNCTION f_set_propaga_suplemento (
      ptablas         IN       VARCHAR2,
      psseguro        IN       NUMBER,
      pnmovimi        IN       NUMBER,
      pcmotmov        IN       NUMBER,
      pcpropagasupl   IN       NUMBER,
      mensajes        OUT      t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vpasexec   NUMBER (8)       := 1;
      vparam     VARCHAR2 (10000)
         :=    'ptablas = '
            || ptablas
            || '; psseguro = '
            || psseguro
            || '; pnmovimi = '
            || pnmovimi
            || '; pcmotmov = '
            || pcmotmov
            || '; pcpropagasupl = '
            || pcpropagasupl;
      vobject    VARCHAR2 (200)
                             := 'PAC_IAX_SUPLEMENTOS.f_set_propaga_suplemento';
      num_err    NUMBER;
   BEGIN
      IF psseguro IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      num_err :=
         pac_md_suplementos.f_set_propaga_suplemento (ptablas,
                                                      psseguro,
                                                      pnmovimi,
                                                      pcmotmov,
                                                      pcpropagasupl,
                                                      mensajes
                                                     );

      IF num_err <> 0
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, num_err);
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN 0;
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
   END f_set_propaga_suplemento;

   /*************************************************************************
    FUNCTION f_insdetmovseguro
    param out mensajes    : Mensajes
    retorno : 0 ok
              1 error
   *************************************************************************/
   FUNCTION f_instexmovseguro (
      psseguro   IN       NUMBER,
      pnmovimi   IN       NUMBER,
      ptmovimi   IN       VARCHAR2,
      mensajes   OUT      t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (500) := NULL;
      vobject    VARCHAR2 (200) := 'PAC_IAX_SUPLEMENTOS.f_instexmovseguro';
      num_err    NUMBER;
   BEGIN
      vpasexec := 3;
      num_err :=
         pac_md_suplementos.f_instexmovseguro (pac_iax_produccion.vsolicit,
                                               pac_iax_produccion.vnmovimi,
                                               ptmovimi,
                                               mensajes
                                              );

      IF num_err <> 0
      THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         ROLLBACK;
         RETURN 1;
   END f_instexmovseguro;

   /*************************************************************************
    FUNCTION f_ins_est_suspension
    param out mensajes    : Mensajes
    retorno : 0 ok
              1 error
   *************************************************************************/
   FUNCTION f_ins_est_suspension (
      psseguro   IN       NUMBER,
      pnmovimi   IN       NUMBER,
      pcmotmov   IN       NUMBER,
      mensajes   OUT      t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (500) := NULL;
      vobject    VARCHAR2 (200) := 'PAC_IAX_SUPLEMENTOS.f_ins_est_suspension';
      num_err    NUMBER;
   BEGIN
      vpasexec := 3;
      num_err :=
         pac_md_suplementos.f_ins_est_suspension (psseguro,
                                                  pnmovimi,
                                                  pcmotmov,
                                                  mensajes
                                                 );

      IF num_err <> 0
      THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN num_err;
   EXCEPTION
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         ROLLBACK;
         RETURN 1;
   END f_ins_est_suspension;

   /*************************************************************************
    FUNCTION f_ins_est_suspension
    param in psseguro
    param in pnmovimi
    param out mensajes    : Mensajes
    retorno : 0 ok 1 error

    Bug 29358/162059 - 24/12/2013 - AMC
   *************************************************************************/
   FUNCTION f_lanzaproceso_diferidos (psseguro IN NUMBER, pnmovimi IN NUMBER)
      RETURN NUMBER
   IS
      vpasexec         NUMBER (8)               := 1;
      vparam           VARCHAR2 (500)           := NULL;
      vobject          VARCHAR2 (200)
                            := 'PAC_IAX_SUPLEMENTOS.f_lanzaproceso_diferidos';
      num_err          NUMBER;
      vsproces         NUMBER                   := NULL;
      vfefecto         movseguro.fefecto%TYPE;
      -- Bug 24278 - APD - 03/12/2012
      v_es_col_admin   NUMBER;                -- Bug 24278 - APD - 03/12/2012
      v_emitir         NUMBER                   := 0;
      -- bug 25583 JDS - 07-02-2013
      mensajes         t_iax_mensajes;
   BEGIN
      IF psseguro IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;

      -- Si es el certificado 0
      IF pac_seguros.f_get_escertifcero (NULL, psseguro) = 1
      THEN
         -- Poliza administrada si f_es_col_admin = 1
         v_es_col_admin := pac_seguros.f_es_col_admin (psseguro, 'SEG');

         IF pnmovimi IS NULL
         THEN
            IF v_es_col_admin = 1
            THEN
               -- se debe abrir automaticamente el suplemento del certificado 0
               -- para poder ejecutar los suplementos diferidos programados
               -- en sus ncertifs
               num_err :=
                    pac_md_produccion.f_abrir_suplemento (psseguro, mensajes);

               IF num_err <> 0
               THEN
                  RAISE e_object_error;
               END IF;

               COMMIT;
               -- Bug 30448/0169858 - APD - 17/03/2014 - se actualiza el creteni = 22
               pac_seguros.p_modificar_seguro (psseguro, 22);
            -- fin Bug 30448/0169858 - APD - 17/03/2014
            END IF;

            vsproces := NULL;
            num_err :=
               pac_md_suplementos.f_ejecuta_supl_certifs (psseguro,
                                                          pnmovimi,
                                                          vsproces,
                                                          mensajes
                                                         );

            IF num_err <> 0
            THEN
               RAISE e_object_error;
            END IF;

            IF v_es_col_admin = 1
            THEN
               -- Bug 30448/0169858 - APD - 17/03/2014 - si el proceso de ejecucion
               -- de suplementos diferidos ha ido correctmente, se actualiza el creteni = 0
               pac_seguros.p_modificar_seguro (psseguro, 0);
               -- fin Bug 30448/0169858 - APD - 17/03/2014
               num_err :=
                  pac_iax_produccion.f_emitir_col_admin (psseguro,
                                                         v_emitir,
                                                         mensajes,
                                                         0
                                                        );              --6166

               IF num_err <> 0
               THEN
                  RAISE e_object_error;
               END IF;
            END IF;
         ELSE
            -- no se debe abrir el suplemento 670 del certifcado 0 ya que s??se quiere
            -- ejecutar los suplementos diferidos de sus certificados para un movimiento
            -- en concreto
            vsproces := NULL;
            num_err :=
               pac_md_suplementos.f_ejecuta_supl_certifs (psseguro,
                                                          pnmovimi,
                                                          vsproces,
                                                          mensajes
                                                         );

            IF num_err <> 0
            THEN
               RAISE e_object_error;
            END IF;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         ROLLBACK;
         RETURN 1;
   END f_lanzaproceso_diferidos;

   /*************************************************************************
    FUNCTION f_get_descmotmov
    param in pcmotmov
    param in pcidioma
    param out ptmotmov
    param out mensajes
    retorno : 0 ok 1 error

    Bug 36507  215507 - 16/10/2015 - KJSC
   *************************************************************************/
   FUNCTION f_get_descmotmov (
      pcmotmov   IN       NUMBER,
      pcidioma   IN       NUMBER,
      ptmotmov   OUT      VARCHAR2,
      mensajes   OUT      t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vparam        VARCHAR2 (500)
         :=    'pcmotmov:'
            || pcmotmov
            || ' pcidioma:'
            || pcidioma
            || 'ptmotmov:'
            || ptmotmov;
      vpasexec      NUMBER (8)     := 1;
      vobjectname   VARCHAR2 (200) := 'PAC_IAX_SUPLEMENTOS.f_get_descmotmov';
      vnumerr       NUMBER         := 0;
   BEGIN
      vnumerr :=
         pac_md_suplementos.f_get_descmotmov (pcmotmov,
                                              pcidioma,
                                              ptmotmov,
                                              mensajes
                                             );

      IF vnumerr <> 0
      THEN
         RAISE e_object_error;
      END IF;

      RETURN vnumerr;
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
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN 1;
   END f_get_descmotmov;

   /*************************************************************************
    FUNCTION f_traslada_vigencia
    Función que traslada la vigencia de una póliza de acuerdo a la nueva fecha de efecto
    param in pfefetrasvig
    retorno : 0 ok 1 error

    IAXIS-3394 CJMR 16/04/2019
   *************************************************************************/
   FUNCTION f_traslada_vigencia (
      pndias     IN       NUMBER,
      pnmeses    IN       NUMBER,
      pnanios    IN       NUMBER,
      mensajes   OUT      t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vparam        VARCHAR2 (100)
         :=    'pndias:'
            || NVL (pndias, 0)
            || ' pnmeses:'
            || NVL (pnmeses, 0)
            || ' pnanios:'
            || NVL (pnanios, 0);
      vpasexec      NUMBER (8)     := 1;
      vobjectname   VARCHAR2 (200)
                                  := 'PAC_IAX_SUPLEMENTOS.f_traslada_vigencia';
      vnumerr       NUMBER         := 0;
      vnumdias      NUMBER         := 0;
   BEGIN
      pac_iax_produccion.poliza.det_poliza.gestion.fefecto :=
           (  (  TRUNC (pac_iax_produccion.poliza.det_poliza.gestion.fefecto)
               + NUMTODSINTERVAL (NVL (pndias, 0), 'DAY')
              )
            + NUMTOYMINTERVAL (NVL (pnmeses, 0), 'MONTH')
           )
         + NUMTOYMINTERVAL (NVL (pnanios, 0), 'YEAR');
      vpasexec := 2;
      pac_iax_produccion.poliza.det_poliza.gestion.fvencim :=
           (  (  TRUNC (pac_iax_produccion.poliza.det_poliza.gestion.fvencim)
               + NUMTODSINTERVAL (NVL (pndias, 0), 'DAY')
              )
            + NUMTOYMINTERVAL (NVL (pnmeses, 0), 'MONTH')
           )
         + NUMTOYMINTERVAL (NVL (pnanios, 0), 'YEAR');
      vpasexec := 3;
      pac_iax_produccion.poliza.det_poliza.gestion.fefeplazo :=
           (  (  TRUNC (pac_iax_produccion.poliza.det_poliza.gestion.fefeplazo)
               + NUMTODSINTERVAL (NVL (pndias, 0), 'DAY')
              )
            + NUMTOYMINTERVAL (NVL (pnmeses, 0), 'MONTH')
           )
         + NUMTOYMINTERVAL (NVL (pnanios, 0), 'YEAR');
      vpasexec := 4;
      pac_iax_produccion.poliza.det_poliza.gestion.fvencplazo :=
           (  (  TRUNC
                      (pac_iax_produccion.poliza.det_poliza.gestion.fvencplazo)
               + NUMTODSINTERVAL (NVL (pndias, 0), 'DAY')
              )
            + NUMTOYMINTERVAL (NVL (pnmeses, 0), 'MONTH')
           )
         + NUMTOYMINTERVAL (NVL (pnanios, 0), 'YEAR');
      RETURN 0;
   EXCEPTION
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
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN 1;
   END f_traslada_vigencia;
END pac_iax_suplementos;
/