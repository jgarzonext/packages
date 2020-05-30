/* Formatted on 2020/01/02 15:17 (Formatter Plus v4.8.8) */
CREATE OR REPLACE PACKAGE BODY "PAC_MD_SUPLEMENTOS"
AS
   /******************************************************************************
      NOMBRE:       PAC_MD_SUPLEMENTOS
      PROPSITO:  Permite crear suplementos

      REVISIONES:
      Ver        Fecha        Autor             Descripcin
      ---------  ----------  ---------------  ------------------------------------
      1.0        07/02/2008   ACC                1. Creacin del package.
      2.0        07/05/2009   DRA                2. 0009981: IAX - Baixar l'empresa a totes les taules del model CFG
      3.0        24/04/2009   RSC                3. Suplemento de cambio de forma de pago diferido
      4.0        07/06/2009   JRH                4. 0008648: CRE - Error en suplemento de suspencin aportacin periodica PPJ
      5.0        03/07/2009   ETM                5. 0009916: IAX -ACTIVIDAD - Anadir la actividad a nivel de pliza
      6.0        10/11/2009   AMC                6. 0011695: CEM - Fecha de efecto de los suplementos por defecto
      7.0        21/01/2010   XPL                7. APR - En la consulta de plisses, fer que els motius de suplements permesos es recuperin dinmicament de BD
      8.0        03/02/2010   RSC                8. 0011735: APR - suplemento de modificacin de capital /prima
      9.0        24/03/2010   DRA                9. 0013352: CEM003 - SUPLEMENTS: Parametritzar canvi de forma de pagament pels productes de risc
      10.0       10/05/2010   RSC               10. 0011735: APR - suplemento de modificacin de capital /prima
      11.0       10/03/2011   DRA               11. 0017787: CRE998 - Suplement mltiple en plisses d'estalvi
      12.0       04/07/2011   JTS               12. 0017255: CRT003 - Definir propuestas de suplementos en productos
      13.0       15/07/2011   JTS               13. 0018926: MSGV003- Activar el suplement de canvi de forma de pagament
      14.0       15/11/2011   APD               15. 0019169: LCOL_C001 - Campos nuevos a anadir para Agentes.
      16.0       13/11/2012   DRA               16. 0024271: LCOL_T010-LCOL - SUPLEMENTO DE TRASLADO DE VIGENCIA
      17.0       03/12/2012   APD               17. 0024278: LCOL_T010 - Suplementos diferidos - Cartera - colectivos
      18.0       08/01/2013   APD               18. 0023940: LCOL_T010-LCOL - Certificado 0 renovable - Renovaci?n colectivos
      19.0       21/02/2013   ECP               19. 0026070: LCOL_T010-LCOL - Revision incidencias qtracker (V) Nota 138777
      20.0       11/07/2013   RCL               20. 0023860: LCOL - Parametrizacin y suplementos - Vida Grupo
      21.0       10/01/2014   JDS               21. 0029582: LCOL_T010-Revision incidencias qtracker (2014/01)
      22.0       24/12/2019    ECP              22. IAXIS-3504 PAntallas Suplemento
   ******************************************************************************/
   e_object_error   EXCEPTION;
   e_param_error    EXCEPTION;

   /*************************************************************************
      Borra los registros de las tablas est y cancela suplemento
      param in pestsseguro : cdigo seguro en est
      param in pnmovimi    : nmero de movimiento nuevo
      parma in psseguro    : cdigo seguro real
   *************************************************************************/
   PROCEDURE limpiartemporales (
      pestsseguro   IN   NUMBER,
      pnmovimi      IN   NUMBER,
      psseguro      IN   NUMBER
   )
   IS
      nerr   NUMBER;
   BEGIN
      nerr :=
          pk_suplementos.f_final_suplemento (pestsseguro, pnmovimi, psseguro);
      COMMIT;
   END limpiartemporales;

   /*************************************************************************
      Funcin que valida si una pliza permite realizar un suplemento a una fecha determinada
      param in psseguro      : cdigo del seguro
      param in pfefecto      : fecha efecto
      param in pcmotmov      : cdigo movimiento
      param in out mensajes  : coleccin de mensajes
      return                 : 0 todo ha ido bien
                               1 se ha producido un error
   *************************************************************************/
   FUNCTION f_valida_poliza_permite_supl (
      psseguro   IN       NUMBER,
      pfefecto   IN       DATE,
      pcmotmov   IN       NUMBER,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vnumerr     NUMBER (8)             := 0;
      vpasexec    NUMBER (8)             := 1;
      vparam      VARCHAR2 (1000)
         :=    'psseguro='
            || psseguro
            || ' pfefecto='
            || pfefecto
            || ' pcmotmov='
            || pcmotmov;
      vobject     VARCHAR2 (200)
                          := 'PAC_MD_SUPLEMENTOS.F_Valida_Poliza_Permite_Supl';
      v_fefecto   DATE;
      ncont       NUMBER;
      vsproduc    seguros.sproduc%TYPE;
      vtmensaje   VARCHAR2 (200);
      vcactivi    NUMBER;
      vcactivo    agentes.cactivo%TYPE;        -- Bug 19169 - APD - 15/11/2011

      CURSOR riesgos (vcr_sseguro IN NUMBER)
      IS
         SELECT sperson
           FROM riesgos
          WHERE sseguro = vcr_sseguro;
   BEGIN
      --Comprovaci parmetres d'entrada
      IF psseguro IS NULL
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, 140896);
         RAISE e_param_error;
      END IF;

      vpasexec := 3;
      -- JLB 18346 25/05/2011
      vnumerr := pac_productos.f_get_sproduc (psseguro, vsproduc);

      IF vnumerr <> 0
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      vpasexec := 31;
      -- La fecha de efecto debe estar truncada
      v_fefecto := TRUNC (pfefecto);

      BEGIN
         SELECT COUNT (1)
           INTO ncont
           FROM estseguros
          WHERE ssegpol = psseguro;
      EXCEPTION
         WHEN OTHERS
         THEN
            pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                               vobject,
                                               1000005,
                                               vpasexec,
                                               vparam
                                              );
            ncont := 0;
      END;

      vpasexec := 4;

      

      -- Bug 19169 - APD - 15/11/2011
      -- los agentes solo pueden hacer Suplementos en estado (detvalores 31):
      -- 1.-Activo
      -- 2.- Inactivo temporalmente
      -- 3.-Cancelado con opcin de modificacin
      -- Ini IAXIS-3504 -- 26/12/2019
      BEGIN
         SELECT cactivo
           INTO vcactivo
           FROM agentes a, seguros s
          WHERE a.cagente = s.cagente AND s.sseguro = psseguro;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            BEGIN
               SELECT cactivo
                 INTO vcactivo
                 FROM agentes a, estseguros s
                WHERE a.cagente = s.cagente AND s.sseguro = psseguro;
            EXCEPTION
               WHEN OTHERS
               THEN
                  pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, 104473);
                  -- Error al leer de la tabla AGENTES
                  RAISE e_object_error;
            END;
      END;

      -- Fin IAXIS-3504 -- 26/12/2019
      IF vcactivo NOT IN (1, 2, 3)
      THEN                                                    -- detvalores 31
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, 9902692);
         -- Estado del agente no vlido
         RAISE e_object_error;
      END IF;

      -- Fin Bug 19169 - APD - 15/11/2011
      vpasexec := 6;
      --BUG11376-XVM-13102009
      vnumerr :=
          pk_suplementos.f_permite_suplementos (psseguro, v_fefecto, pcmotmov);

      IF vnumerr <> 0
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      IF pcmotmov IS NOT NULL
      THEN
         vpasexec := 7;
         vnumerr :=
            pk_suplementos.f_permite_este_suplemento (psseguro,
                                                      v_fefecto,
                                                      pcmotmov
                                                     );

         IF vnumerr <> 0
         THEN
            pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, vnumerr);
            RAISE e_object_error;
         END IF;

         --BUG17255 - 04/07/2011 - JTS
         SELECT cactivi
           INTO vcactivi
           FROM seguros
          WHERE sseguro = psseguro;

         vnumerr :=
            pk_suplementos.f_prod_permite_supl (vsproduc,
                                                pcmotmov,
                                                vcactivi,
                                                vtmensaje
                                               );

         IF vnumerr <> 0
         THEN
            pac_iobj_mensajes.crea_nuevo_mensaje (mensajes,
                                                  1,
                                                  NULL,
                                                  vtmensaje
                                                 );
            RAISE e_object_error;
         END IF;
      --Fi BUG17255
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
                                            || 'aqui'
                                            || 'v_fefecto-->'
                                            || v_fefecto
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
   END f_valida_poliza_permite_supl;

   /*************************************************************************
      Nos permite validar los cambios realizados en el suplemento
      param in psseguro      : cdigo del seguro
      param in pnmovimi      : nmero movimiento
      param in      : cdigo del seguro
      param in out mensajes  : coleccin de mensajes
      return                 : 0 todo ha ido bien
                               1 se ha producido un error
   *************************************************************************/
   FUNCTION f_validar_cambios (
      psseguro   IN       NUMBER,
      pnmovimi   IN       NUMBER,
      psproduc   IN       NUMBER,
      mensajes   OUT      t_iax_mensajes,
      pcmotmov   IN       NUMBER DEFAULT NULL
   ) -- Bug 20672 - RSC - 14/02/2012 - LCOL_T001-LCOL - UAT - TEC: Suplementos
      RETURN NUMBER
   IS
      vpasexec    NUMBER (8)     := 1;
      vparam      VARCHAR2 (500)
         :=    'psseguro='
            || psseguro
            || ' pnmovimi='
            || pnmovimi
            || ' psproduc='
            || psproduc;
      vobject     VARCHAR2 (200) := 'PAC_MD_SUPLEMENTOS.F_Validar_Cambios';
      vsseguro    NUMBER         := pac_iax_produccion.vsseguro;
      -- sseguro poliza
      vnmovimi    NUMBER         := pac_iax_produccion.vnmovimi;
      num_err     NUMBER;
      vcont       NUMBER;
      mi_cambio   NUMBER;                           --IAXIS-2085 03/04/2019 AP
      -- Bug 11735 - RSC - 03/02/2010 - suplemento de modificacin de capital /prima
      v_cmotmov   NUMBER;
   -- Fin Bug 11735
   BEGIN
      -- Bug 11735 - RSC - 03/02/2010 - suplemento de modificacin de capital /prima
      -- Bug 11735 - RSC - 10/05/2010 - suplemento de modificacin de capital /prima
      num_err :=
         pk_suplementos.f_validar_cambios (f_user,
                                           psseguro,
                                           pnmovimi,
                                           psproduc,
                                           'BBDD',
                                           'SUPLEMENTO',
                                           pac_md_common.f_get_cxtidioma,
                                           pcmotmov
                                          );

      -- Bug 20672 - RSC - 14/02/2012 - LCOL_T001-LCOL - UAT - TEC: Suplementos
      IF num_err <> 0
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 8, num_err);
         RETURN 1;
      END IF;

      BEGIN
         -- s'ha de validar que hi hagin registres
         SELECT COUNT (*)
           INTO vcont
           FROM estdetmovseguro
          WHERE sseguro = psseguro;
      EXCEPTION
         --IAXIS-2085 03/04/2019 AP
         WHEN NO_DATA_FOUND
         THEN
            SELECT COUNT (1)
              INTO mi_cambio
              FROM (SELECT sperson, cagrupa
                      FROM tomadores t
                     WHERE sseguro = (SELECT ssegpol
                                        FROM estseguros
                                       WHERE sseguro = psseguro)
                    MINUS
                    SELECT spereal, cagrupa
                      FROM esttomadores t, estper_personas e
                     WHERE t.sseguro = psseguro AND t.sperson = e.sperson);
         WHEN OTHERS
         THEN
            pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, 180264);
      END;

      IF vcont = 0 AND mi_cambio = 0
      THEN                                               -- No hi hagut canvis
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, 107804);
         RETURN 1;
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
   END f_validar_cambios;

   /*************************************************************************
      Funcin que obtiene la fecha de efecto del suplemento, y comprueba si
      un determinado usuario puede modificar dicga fecha de fefecto
      (por defecto F_SYSDATE y no modificable).
      Est comprobacin se realiza segn perfil del usuario.
      param in psseguro      : cdigo del seguro
      param in pusuario      : usuario
      param out pmodfefe     : permite modificar fecha de efecto (0/1 -> No/S)
      param in out mensajes  : coleccin de mensajes
      return                 : 0 todo ha ido bien
                               1 se ha producido un error

      Bug 11695 - 10/11/2009 - AMC
   *************************************************************************/
   FUNCTION f_calc_fefecto_supl (
      psseguro   IN       NUMBER,
      pusuario   IN       VARCHAR2,
      pcmotmov   IN       NUMBER,                                 --JAMF 11695
      pfefecto   OUT      DATE,
      pmodfefe   OUT      NUMBER,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vnumerr     NUMBER (8)             := 0;
      vpasexec    NUMBER (8)             := 1;
      vparam      VARCHAR2 (1000)
                     := 'psseguro=' || psseguro || ' - pusuario=' || pusuario;
      vobject     VARCHAR2 (200)  := 'PAC_MD_SUPLEMENTOS.F_Calc_Fefecto_Supl';
      vfefecpol   seguros.fefecto%TYPE;
      vnpoliza    seguros.npoliza%TYPE;
      vncertif    seguros.ncertif%TYPE;
      vnsuplem    seguros.nsuplem%TYPE;
      vsproduc    seguros.sproduc%TYPE;
      vcrealiza   NUMBER;
      vfefecto    VARCHAR2 (100);
   BEGIN
      --Comprpovaci del pas de parmetres
      IF psseguro IS NULL OR pusuario IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;

      SELECT s.sproduc
        INTO vsproduc
        FROM seguros s
       WHERE s.sseguro = psseguro;

      vpasexec := 3;
      --Comprovem si l'usuari pot modificar la data d'efecte del suplement.
      pmodfefe :=
         pac_cfg.f_get_user_accion_permitida (pusuario,
                                              'FECHA_SUPLEMENTO',
                                              vsproduc,
                                              pac_md_common.f_get_cxtempresa,
                                              -- BUG9981:DRA:07/05/2009
                                              vcrealiza
                                             );

      IF    NVL (f_parproductos_v (vsproduc, 'TFECREC_SUPLEMENTOS'), 0) = 1
         OR pmodfefe = 0
      THEN
         vnumerr :=
            pk_suplementos.f_get_fsupl_pds (vsproduc,
                                            psseguro,
                                            pcmotmov,
                                            pfefecto
                                           );

         IF vnumerr <> 0
         THEN
            pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 2, vnumerr);
            RAISE e_object_error;
         END IF;
      ELSE
         --Per defecte, la data d'efecte s la data del dia.
         --JAMF 11695
         --pfefecto := TRUNC(f_sysdate);  --JAMF  11695
         IF pmodfefe = 1
         THEN
            vpasexec := 5;

            --  JAMF 11695
            --   SELECT s.sproduc
            --     INTO vsproduc
            --     FROM seguros s
            --    WHERE s.sseguro = psseguro;
            IF f_prod_ahorro (vsproduc) = 1
            THEN
               -- El producto es de Ahorro
               pfefecto := NULL;
            ELSE
               -- El producto no es de Ahorro
               vnumerr := pk_suplementos.f_fcarpro (psseguro, pfefecto);

               IF vnumerr <> 0
               THEN
                  pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, vnumerr);
                  RAISE e_object_error;
               END IF;
            END IF;

            vpasexec := 7;

            IF pfefecto IS NULL
            THEN
               vpasexec := 9;
               vnumerr := f_buscapoliza (psseguro, vnpoliza, vncertif);

               IF vnumerr <> 0
               THEN
                  pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, vnumerr);
                  RAISE e_object_error;
               END IF;

               vpasexec := 11;
               vnumerr :=
                  f_ultsupl (vnpoliza, vncertif, vnsuplem, vfefecpol,
                             pfefecto);

               IF vnumerr <> 0
               THEN
                  pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, vnumerr);
                  RAISE e_object_error;
               END IF;

               vpasexec := 13;

               IF pfefecto < TRUNC (f_sysdate)
               THEN
                  pfefecto := TRUNC (f_sysdate);
               END IF;
            END IF;
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
   END f_calc_fefecto_supl;

   /*************************************************************************
      Funcin que obtiene la fecha de efecto del suplemento, prviamente calculada
      param in psseguro      : cdigo del seguro
      param in pnmovimi      : Nmero de movimiento
      param out pfefecto     : fecha de efecto del suplemento
      param in out mensajes  : coleccin de mensajes
      return                 : 0 todo ha ido bien
                               1 se ha producido un error
   *************************************************************************/
   FUNCTION f_get_fefecto_supl (
      psseguro   IN       NUMBER,
      pnmovimi   IN       NUMBER,
      pfefecto   OUT      DATE,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vnumerr    NUMBER (8)      := 0;
      vpasexec   NUMBER (8)      := 1;
      vparam     VARCHAR2 (1000)
                     := 'psseguro=' || psseguro || ' - pnmovimi=' || pnmovimi;
      vobject    VARCHAR2 (200)  := 'PAC_MD_SUPLEMENTOS.F_Get_Fefecto_Supl';
   BEGIN
      --Comprpovaci del pas de parmetres
      IF psseguro IS NULL OR pnmovimi IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;
      vnumerr := pk_suplementos.f_fecha_efecto (psseguro, pnmovimi, pfefecto);

      IF vnumerr <> 0
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, vnumerr);
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
   END f_get_fefecto_supl;

   /*************************************************************************
      Nos permite editar una poliza en modo suplemento
      param in psseguro      : cdigo del seguro
      param in pcmotmov      : cdigo motivo de movimiento
      param in pfefecto      : fecha efecto suplemento
      param out onmovimi     : nmero movimiento
      param out osseguro     : cdigo del seguro
      param in out mensajes  : coleccin de mensajes
      return                 : 0 todo ha ido bien
                               1 se ha producido un error
   *************************************************************************/
   FUNCTION f_editarsuplemento (
      psseguro   IN       NUMBER,
      pcmotmov   IN       NUMBER,
      pfefecto   IN       DATE,
      onmovimi   OUT      NUMBER,
      osseguro   OUT      NUMBER,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vpasexec       NUMBER (8)     := 1;
      vparam         VARCHAR2 (500)
                       := 'psseguro=' || psseguro || ' pcmotmov=' || pcmotmov;
      vobject        VARCHAR2 (200)
                                   := 'PAC_MD_SUPLEMENTOS.F_EditarSuplemento';
      nerr           NUMBER;
      vsseguro       NUMBER;
      vnpoliza       NUMBER;
      vncertif       NUMBER;
      vfefecto       DATE;
      vestsseguro    NUMBER;
      vnmovimi       NUMBER;
      vfefecto_aux   DATE;               -- CONF-1243 QT_724 -JLTS-23/01/2018
   BEGIN
      --Comprovaci del pas de parmetres.
      IF psseguro IS NULL OR pcmotmov IS NULL OR pfefecto IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;
      vfefecto := pfefecto;
      nerr :=
         f_valida_poliza_permite_supl (psseguro, vfefecto, pcmotmov, mensajes);

      IF nerr > 0
      THEN
         RAISE e_object_error;
      END IF;

      vpasexec := 3;
      nerr :=
         pk_suplementos.f_inicializar_suplemento (psseguro,
                                                  'SUPLEMENTO',
                                                  vfefecto,
                                                  'BBDD',
                                                  '*',
                                                  pcmotmov,
                                                  osseguro,
                                                  onmovimi
                                                 );
      vpasexec := 4;

      IF nerr <> 0
      THEN
         IF nerr = 1
         THEN
-- ES UN CAS ESPECIAL PQ pk_suplementos.F_PERMITE_AnADIR_SUPLEMENTOS RETORNA 0 O 1
            pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, 9001132);
         ELSE
            pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, nerr);
         END IF;

         ROLLBACK;
         vpasexec := 5;
         nerr :=
              pk_suplementos.f_final_suplemento (osseguro, onmovimi, psseguro);
         COMMIT;
         vpasexec := 6;
         RAISE e_object_error;
      ELSE
         -- BUG17787:DRA:10/03/2011:Inici
         nerr :=
               pk_suplementos.f_pre_suplemento (osseguro, onmovimi, pcmotmov);

         IF nerr > 0
         THEN
            pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, nerr);
            RAISE e_object_error;
         END IF;
      -- BUG17787:DRA:10/03/2011:Fi
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
   END f_editarsuplemento;

   /*************************************************************************
      Traspasa los datos de una propuesta de suplemento de las tablas EST a las REALES
      param in psseguro      : cdigo del seguro
      param in out mensajes  : coleccin de mensajes
      return                 : 0 todo ha ido bien
                               1 se ha producido un error
   *************************************************************************/
   FUNCTION f_traspasarsuplemento (
      psseguro   IN       NUMBER,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vpasexec         NUMBER (8)     := 1;
      vparam           VARCHAR2 (500) := 'psseguro=' || psseguro;
      vobject          VARCHAR2 (200)
                                := 'PAC_MD_SUPLEMENTOS.F_TraspasarSuplemento';
      vsproduc         NUMBER;
      vsseguro         NUMBER         := pac_iax_produccion.vsseguro;
      -- sseguro poliza
      vnmovimi         NUMBER         := pac_iax_produccion.vnmovimi;
      num_err          NUMBER;
      error_fin_supl   EXCEPTION;
      vcont            NUMBER;
      -- Bug 11735 - RSC - 03/02/2010 - suplemento de modificacin de capital /prima
      v_cmotmov        NUMBER;
   -- Fin Bug 11735
   BEGIN
      -- Se valida que hagi fet un canvi
      
      if vsseguro is null then
        begin
          select ssegpol
          into vsseguro
          from estseguros
          where sseguro =  pac_iax_produccion.vsolicit;
        end;
      end if;

      -- INi IAXIS-3504 -- ECP -- 27/12/2019
      BEGIN
         SELECT sproduc
           INTO vsproduc
           FROM seguros
          WHERE sseguro = vsseguro;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            BEGIN
               SELECT sproduc
                 INTO vsproduc
                 FROM estseguros
                WHERE sseguro = vsseguro;
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  RETURN 103286;
            END;
      END;
vpasexec := 2;
      -- INi IAXIS-3504 -- ECP -- 27/12/2019

      -- Bug 11735 - RSC - 03/02/2010 - suplemento de modificacin de capital /prima
      -- Bug 11735 - RSC - 10/05/2010 - suplemento de modificacin de capital /prima
      num_err :=
         pk_suplementos.f_validar_cambios (f_user,
                                           psseguro,
                                           vnmovimi,
                                           vsproduc,
                                           'BBDD',
                                           'SUPLEMENTO',
                                           pac_md_common.f_get_cxtidioma
                                          );
                                          vpasexec := 3;

      IF num_err <> 0
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, num_err);
         RAISE error_fin_supl;
      END IF;
vpasexec := 4;
      BEGIN
         -- s'ha de validar que hi hagin registres
         SELECT COUNT (*)
           INTO vcont
           FROM estdetmovseguro
          WHERE sseguro = psseguro;
      EXCEPTION
         WHEN OTHERS
         THEN
            pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, 180264);
            RAISE error_fin_supl;
      END;
vpasexec := 5;
      IF vcont = 0
      THEN                                               -- No hi hagut canvis
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, 107804);
         RAISE error_fin_supl;
      END IF;
vpasexec := 6;
      -- Es grava el suplement a las taules reals
      num_err :=
                pk_suplementos.f_grabar_suplemento_poliza (psseguro, vnmovimi);

      IF num_err <> 0
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, num_err);
         RAISE error_fin_supl;
      END IF;
vpasexec := 7;
      RETURN 0;
   EXCEPTION
      WHEN error_fin_supl
      THEN
         ROLLBACK;
         num_err :=
             pk_suplementos.f_final_suplemento (psseguro, vnmovimi, vsseguro);
         COMMIT;
         RETURN 1;
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
   END f_traspasarsuplemento;

   /*************************************************************************
      Recupera el detalle del movimiento
      param in psseguro      : cdigo del seguro
      param in pnmovimi      : nmero de movimiento
      param in pcidioma      : cdigo idioma
      param in out mensajes  : coleccin de mensajes
      return                 : objeto detalle movimientos
   *************************************************************************/
   FUNCTION f_get_detailmov (
      psseguro   IN       NUMBER,
      pnmovimi   IN       NUMBER,
      pcidioma   IN       NUMBER,
      mensajes   OUT      t_iax_mensajes
   )
      RETURN t_iax_detmovseguro
   IS
      vpasexec   NUMBER (8)         := 1;
      vparam     VARCHAR2 (500)
                       := 'psseguro=' || psseguro || ' pnmovimi=' || pnmovimi;
      vobject    VARCHAR2 (200)     := 'PAC_MD_SUPLEMENTOS.F_Get_DetailMov';
      detmov     t_iax_detmovseguro := NULL;
      vtmotmov   VARCHAR2 (1000);             -- Bug 25840 - APD - 06/05/2013
   BEGIN
      --Comprovaci pas de parmetres
      IF psseguro IS NULL OR pnmovimi IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;

      -- Bug 23940 - APD - 17/12/2012 - se a? el campo cpropagasupl
      FOR c IN (SELECT   dmov.sseguro, dmov.nriesgo, dmov.cgarant,
                         dmov.tvalora, dmov.tvalord, dmov.cmotmov,
                         dmov.cpropagasupl
                    FROM detmovseguro dmov
                   WHERE dmov.sseguro = psseguro AND dmov.nmovimi = pnmovimi
                ORDER BY dmov.nriesgo ASC)
      LOOP
         -- fin Bug 23940 - APD - 17/12/2012 - se a? el campo cpropagasupl
         vpasexec := 5;

         IF detmov IS NULL
         THEN
            detmov := t_iax_detmovseguro ();
         END IF;

         vpasexec := 7;
         detmov.EXTEND;
         detmov (detmov.LAST) := ob_iax_detmovseguro ();
         detmov (detmov.LAST).cmotmov := c.cmotmov;
         -- Bug 25840 - APD - 06/05/2013 -- se debe mirar primero si existe descripcion
         -- propia del suplemento (PDS_SUPL_GRUP), sino se debe obtener la descripcion del suplemento
         -- de MOTMOVSEG
         vtmotmov :=
            pac_iax_listvalores.f_getdescripvalor
                                   (   'SELECT f_axis_literales(slitera,'
                                    || pcidioma
                                    || ') FROM pds_supl_grup WHERE CMOTMOV= '
                                    || c.cmotmov
                                    || ' AND cempres ='
                                    || pac_md_common.f_get_cxtempresa (),
                                    mensajes
                                   );

         IF vtmotmov IS NULL
         THEN
            vtmotmov :=
               pac_iax_listvalores.f_getdescripvalor
                  (   'SELECT MTS.TMOTMOV FROM MOTMOVSEG MTS WHERE MTS.CMOTMOV= '
                   || c.cmotmov
                   || ' AND MTS.CIDIOMA='
                   || pcidioma,
                   mensajes
                  );
         END IF;

         detmov (detmov.LAST).tmotmov := vtmotmov;
         -- fin Bug 25840 - APD - 06/05/2013
         detmov (detmov.LAST).nriesgo := c.nriesgo;

         --Recuperaci de la descripci del risc. Si el risc s 0, significa que s un moviment a nivell de plissa.
         IF c.nriesgo = 0
         THEN
            detmov (detmov.LAST).triesgo :=
                    f_axis_literales (1000013, pac_md_common.f_get_cxtidioma);
         ELSE
            detmov (detmov.LAST).triesgo :=
               pac_md_obtenerdatos.f_desriesgos ('POL', c.sseguro, c.nriesgo);
         END IF;

         detmov (detmov.LAST).cgarant := c.cgarant;
         detmov (detmov.LAST).tvalora := c.tvalora;
         detmov (detmov.LAST).tvalord := c.tvalord;

         IF c.cmotmov = 699
         THEN
            BEGIN
               SELECT tmovimi
                 INTO detmov (detmov.LAST).tvalord
                 FROM texmovseguro
                WHERE sseguro = psseguro AND nmovimi = pnmovimi;
            EXCEPTION
               WHEN OTHERS
               THEN
                  NULL;
            END;
         END IF;

         -- Bug 23940 - APD - 17/12/2012 - se a? el campo cpropagasupl
         detmov (detmov.LAST).cpropagasupl := c.cpropagasupl;
         detmov (detmov.LAST).tpropagasupl :=
            pac_md_listvalores.f_getdescripvalores (1115,
                                                    c.cpropagasupl,
                                                    mensajes
                                                   );
      -- fin Bug 23940 - APD - 17/12/2012 - se a? el campo cpropagasupl
      END LOOP;

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
      Recupera el detalle del movimiento
      param in psseguro      : cdigo del seguro
      param in pnmovimi      : nmero de movimiento
      param in pfefecto      : fecha efecto suplemento se pasa para
                               devolverlo a JAVA pero puede ser nulo
      param in pcidioma      : cdigo idioma
      param in out mensajes  : coleccin de mensajes
      return                 : objeto detalle movimientos
   *************************************************************************/
   FUNCTION f_get_detailmovsupl (
      psseguro   IN       NUMBER,
      pnmovimi   IN       NUMBER,
      pfefecto   IN       DATE,
      pcidioma   IN       NUMBER,
      mensajes   OUT      t_iax_mensajes
   )
      RETURN t_iax_detmovseguro
   IS
      vpasexec   NUMBER (8)         := 1;
      vparam     VARCHAR2 (500)
                       := 'psseguro=' || psseguro || ' pnmovimi=' || pnmovimi;
      vobject    VARCHAR2 (200)     := 'PAC_MD_SUPLEMENTOS.F_Get_DetailMov';
      detmov     t_iax_detmovseguro := NULL;
      vtmotmov   VARCHAR2 (1000);             -- Bug 25840 - APD - 06/05/2013
   BEGIN
      -- Bug 23940 - APD - 17/12/2012 - se a? el campo cpropagasupl
      FOR c IN (SELECT dmov.sseguro, dmov.nriesgo, dmov.cgarant,
                       dmov.tvalora, dmov.tvalord, dmov.cmotmov,
                       dmov.cpropagasupl
                  FROM estdetmovseguro dmov
                 WHERE dmov.sseguro = psseguro AND dmov.nmovimi = pnmovimi)
      LOOP
         -- fin Bug 23940 - APD - 17/12/2012 - se a? el campo cpropagasupl
         IF detmov IS NULL
         THEN
            detmov := t_iax_detmovseguro ();
         END IF;

         detmov.EXTEND;
         detmov (detmov.LAST) := ob_iax_detmovseguro ();
         detmov (detmov.LAST).fsuplem := pfefecto;
         detmov (detmov.LAST).cmotmov := c.cmotmov;
         -- Bug 25840 - APD - 06/05/2013 -- se debe mirar primero si existe descripcion
         -- propia del suplemento (PDS_SUPL_GRUP), sino se debe obtener la descripcion del suplemento
         -- de MOTMOVSEG
         vtmotmov :=
            pac_iax_listvalores.f_getdescripvalor
                                   (   'SELECT f_axis_literales(slitera,'
                                    || pcidioma
                                    || ') FROM pds_supl_grup WHERE CMOTMOV= '
                                    || c.cmotmov
                                    || ' AND cempres ='
                                    || pac_md_common.f_get_cxtempresa (),
                                    mensajes
                                   );

         IF vtmotmov IS NULL
         THEN
            vtmotmov :=
               pac_iax_listvalores.f_getdescripvalor
                  (   'SELECT MTS.TMOTMOV FROM MOTMOVSEG MTS WHERE MTS.CMOTMOV= '
                   || c.cmotmov
                   || ' AND MTS.CIDIOMA='
                   || pcidioma,
                   mensajes
                  );
         END IF;

         detmov (detmov.LAST).tmotmov := vtmotmov;
         -- fin Bug 25840 - APD - 06/05/2013
         detmov (detmov.LAST).nriesgo := c.nriesgo;
         detmov (detmov.LAST).triesgo :=
                pac_md_obtenerdatos.f_desriesgos ('EST', c.sseguro, c.nriesgo);
         detmov (detmov.LAST).cgarant := c.cgarant;
         detmov (detmov.LAST).tvalora := c.tvalora;
         detmov (detmov.LAST).tvalord := c.tvalord;
         -- Bug 23940 - APD - 17/12/2012 - se a? el campo cpropagasupl
         detmov (detmov.LAST).cpropagasupl := c.cpropagasupl;
         detmov (detmov.LAST).tpropagasupl :=
            pac_md_listvalores.f_getdescripvalores (1115,
                                                    c.cpropagasupl,
                                                    mensajes
                                                   );
      -- fin Bug 23940 - APD - 17/12/2012 - se a? el campo cpropagasupl
      END LOOP;

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
   END f_get_detailmovsupl;

   /*************************************************************************
      Preproceso del suplemento
      param in plstmotmov    : lista motivos suplemento
      param in psseguro      : cdigo del seguro
      param in out mensajes  : coleccin de mensajes
      return                 : 0 = todo ha ido bien
                               1 = se ha producido un error
   *************************************************************************/
   FUNCTION f_preprocesarsuplemento (
      plstmotmov   IN OUT   t_iax_motmovsuple,
      psseguro     IN       NUMBER,
      mensajes     OUT      t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (500) := 'plstmotmov, psseguro=' || psseguro;
      vobject    VARCHAR2 (200)
                              := 'PAC_MD_SUPLEMENTOS.F_PreprocesarSuplemento';
      i          NUMBER;
      nerr       NUMBER;
   BEGIN
      IF plstmotmov IS NOT NULL
      THEN
         IF plstmotmov.COUNT > 0
         THEN
            FOR i IN plstmotmov.FIRST .. plstmotmov.LAST
            LOOP
               IF plstmotmov.EXISTS (i)
               THEN
                  IF plstmotmov (i).cproces = 1
                  THEN
                     nerr :=
                        pac_suplementos.f_preprocesarsuplemento
                                                      (plstmotmov (i).cmotmov,
                                                       psseguro
                                                      );
                     plstmotmov (i).cproces := 0;
/*
                            IF nerr <> 0 THEN
                                RAISE e_object_error;
                            END IF;
*/
                  END IF;
               END IF;
            END LOOP;
         END IF;
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
   END f_preprocesarsuplemento;

   /*************************************************************************
      Suplemento de canvio de forma de pago
      param in psseguro      : cdigo del seguro
      param in out mensajes  : coleccin de mensajes
      return                 : 0 = todo ha ido bien
                               1 = se ha producido un error
   *************************************************************************/
   FUNCTION f_canvi_forpag (
      psseguro   IN       NUMBER,
      pcontrol   OUT      NUMBER,
      mensajes   OUT      t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vpasexec       NUMBER (8)     := 1;
      vparam         VARCHAR2 (500) := NULL;
      vobject        VARCHAR2 (200) := 'PAC_MD_SUPLEMENTOS.F_CANVI_FORPAG';
      vcontrol       NUMBER;
      vnmovimi       NUMBER;
      vsproces       NUMBER;
      vcforpag_ant   NUMBER;
      nerr           NUMBER;
      v_cempres      NUMBER;
      v_fefecto      DATE;
      v_fcaranu      DATE;
      v_fcarpro      DATE;
      v_cforpag      NUMBER;
      v_ctipreb      NUMBER;
      v_csituac      NUMBER;
   BEGIN
      vcontrol := 0;

      SELECT cempres, fefecto, fcaranu, fcarpro, cforpag,
             ctipreb, csituac
        INTO v_cempres, v_fefecto, v_fcaranu, v_fcarpro, v_cforpag,
             v_ctipreb, v_csituac
        FROM seguros
       WHERE sseguro = psseguro;

      SELECT MAX (nmovimi)
        INTO vnmovimi
        FROM movseguro
       WHERE sseguro = psseguro;

      -- Bug 8648 - JRH - 11/06/2009 - Error en suplemento de suspensin
      SELECT COUNT (1)
        INTO vcontrol
        FROM detmovseguro
       WHERE sseguro = psseguro
         AND nmovimi = vnmovimi
         AND cmotmov IN (269, 266, 267)
         AND ROWNUM = 1;

      -- Fin Bug 8648
      pcontrol := vcontrol;

      IF vcontrol = 1
      THEN
         SELECT sproces.NEXTVAL
           INTO vsproces
           FROM DUAL;

         SELECT h.cforpag
           INTO vcforpag_ant
           FROM historicoseguros h
          WHERE h.sseguro = psseguro
            AND h.nmovimi =
                     (SELECT MAX (h1.nmovimi)
                        FROM historicoseguros h1
                       WHERE h1.sseguro = h.sseguro AND h1.nmovimi < vnmovimi);

         nerr :=
            pac_canviforpag.f_canvi_forpag_tf (v_cempres,
                                               vsproces,
                                               psseguro,
                                               v_fefecto,
                                               v_fcaranu,
                                               v_fcarpro,
                                               f_sysdate,
                                               vcforpag_ant,
                                               v_cforpag,
                                               v_ctipreb,
                                               0,
                                               vnmovimi
                                              );

         IF nerr <> 0
         THEN
             --vmsj:=PAC_IOBJ_MENSAJES.F_GET_DESCMENSAJE(nerr,PAC_MD_COMMON.F_GET_CXTIDIOMA);
            --PAC_IOBJ_MENSAJES.CREA_NUEVO_MENSAJE(mensajes,2,nerr,null);
            RAISE e_object_error;
         END IF;
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
         RETURN -1;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN -1;
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
         RETURN -1;
   END f_canvi_forpag;

   /*************************************************************************
      Emitir suplemento
      param in psseguro      : cdigo del seguro
      param in out mensajes  : coleccin de mensajes
      return                 : 0 = todo ha ido bien
                               1 = se ha producido un error
   *************************************************************************/
   FUNCTION f_emitir_suplemento (
      psseguro    IN       NUMBER,
      pvsseguro   IN       NUMBER,
      pemitesol   IN       BOOLEAN,              --BUG18926 - JTS - 15/07/2011
      pnmovimi    OUT      NUMBER,
      ponpoliza   OUT      NUMBER,
      posseguro   OUT      NUMBER,
      mensajes    OUT      t_iax_mensajes,
      pcommit              NUMBER DEFAULT 1   -- Bug 26070 --ECP -- 21/02/2013
   )
      RETURN NUMBER
   IS
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (500) := NULL;
      vobject    VARCHAR2 (200) := 'PAC_MD_SUPLEMENTOS.F_Emitir_Suplemento';
      num_err    NUMBER;
      vcontrol   NUMBER;
      vnsolici   NUMBER;
      vnpoliza   NUMBER;
      vncertif   NUMBER;
      lnmovimi   NUMBER;
      lcmotmov   NUMBER;
      lfefecto   DATE;
      vsproduc   NUMBER;
   BEGIN
      IF NOT pemitesol
      THEN                                      --BUG18926 - JTS - 15/07/2011
         num_err :=
                pac_md_suplementos.f_traspasarsuplemento (psseguro, mensajes);
                vpasexec := 2;

         IF num_err > 0
         THEN
            RETURN num_err;
         END IF;
      END IF;
       vpasexec := 3;
      p_tab_error (f_sysdate,
                   f_user,
                   vobject,
                   vpasexec,
                   'xxx',
                      ' psseguro-->'
                   || psseguro
                   || ' pvsseguro-->'
                   || pvsseguro
                   || 'ponpoliza  '
                   || ponpoliza
                   || 'nerr '
                   || num_err
                  );
      -- BUG24271:DRA:13/11/2012:Inici
      num_err :=
         pac_md_suplementos.f_traslado_vigencia (pvsseguro, vcontrol,
                                                 mensajes);
                                                  vpasexec := 4;
      p_tab_error (f_sysdate,
                   f_user,
                   vobject,
                   vpasexec,
                   'tras',
                      ' psseguro-->'
                   || psseguro
                   || ' pvsseguro-->'
                   || pvsseguro
                   || 'ponpoliza  '
                   || ponpoliza
                   || 'nerr '
                   || num_err
                  );

      IF num_err > 0
      THEN
         RETURN num_err;
      END IF;
      vpasexec := 5;
      IF vcontrol = 0
      THEN                   -- No hay suplemento de cambio de fecha de efecto
         num_err :=
            pac_md_suplementos.f_canvi_forpag (pvsseguro, vcontrol, mensajes);
             vpasexec := 6;
         p_tab_error (f_sysdate,
                      f_user,
                      vobject,
                      vpasexec,
                      'tras',
                         ' psseguro-2->'
                      || psseguro
                      || ' pvsseguro-->'
                      || pvsseguro
                      || 'ponpoliza  '
                      || ponpoliza
                      || 'nerr '
                      || num_err
                     );

         IF num_err > 0
         THEN
            RETURN num_err;
         END IF;
          vpasexec := 7;
         --si hay cambio de forma de pago propagamos el suplemento
         p_tab_error (f_sysdate,
                      f_user,
                      vobject,
                      vpasexec,
                      'tras',
                         ' psseguro-->'
                      || psseguro
                      || ' pvsseguro-->'
                      || pvsseguro
                      || 'ponpoliza  '
                      || ponpoliza
                      || 'nerr '
                      || num_err
                     );

         -- INi 3504 -- ECP -- 02/01/2020
         BEGIN
            SELECT sproduc
              INTO vsproduc
              FROM seguros
             WHERE sseguro = pvsseguro;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               BEGIN
                  SELECT sproduc
                    INTO vsproduc
                    FROM estseguros
                   WHERE sseguro = pvsseguro;
               EXCEPTION
                  WHEN NO_DATA_FOUND
                  THEN
                     NULL;
               END;
         END;
         vpasexec := 8;
         -- INi 3504 -- ECP -- 02/01/2020
         IF     vcontrol = 1
            AND NVL (f_parproductos_v (vsproduc, 'ADMITE_CERTIFICADOS'), 0) =
                                                                             1
            AND pac_seguros.f_get_escertifcero (NULL, pvsseguro) = 1
         THEN
            -- Miramos el movim. de seg. de ese seguro
             vpasexec := 9;
            BEGIN
               SELECT nmovimi, fefecto, cmotmov
                 INTO lnmovimi, lfefecto, lcmotmov
                 FROM movseguro
                WHERE sseguro = pvsseguro
                  AND nmovimi = (SELECT MAX (nmovimi)
                                   FROM movseguro
                                  WHERE sseguro = pvsseguro);
            EXCEPTION
               WHEN TOO_MANY_ROWS
               THEN
                  ROLLBACK;
                  num_err := 103106;                 --Ms de 1 mov. de seguro
                  vpasexec := 2;
                  p_tab_error (f_sysdate,
                               f_user,
                               'PAC_MD_SUPLEMENTOS.F_Emitir_Suplemento',
                               vpasexec,
                                  'psseguro = '
                               || psseguro
                               || ' pvsseguro = '
                               || pvsseguro
                               || ' pemitesol = '
                               || TO_CHAR (SYS.DIUTIL.bool_to_int (pemitesol)),
                               f_axis_literales (num_err)
                              );
               WHEN NO_DATA_FOUND
               THEN
                  ROLLBACK;
                  num_err := 103107;           --No hay movimientos de seguro
                  vpasexec := 3;
                  p_tab_error (f_sysdate,
                               f_user,
                               'PAC_MD_SUPLEMENTOS.F_Emitir_Suplemento',
                               vpasexec,
                                  'psseguro = '
                               || psseguro
                               || ' pvsseguro = '
                               || pvsseguro
                               || ' pemitesol = '
                               || TO_CHAR (SYS.DIUTIL.bool_to_int (pemitesol)),
                               f_axis_literales (num_err)
                              );
               WHEN OTHERS
               THEN
                  ROLLBACK;
                  num_err := SQLCODE;             --Error en la base de datos
                  vpasexec := 3;
                  p_tab_error (f_sysdate,
                               f_user,
                               'PAC_MD_SUPLEMENTOS.F_Emitir_Suplemento',
                               vpasexec,
                                  'psseguro = '
                               || psseguro
                               || ' pvsseguro = '
                               || pvsseguro
                               || ' pemitesol = '
                               || TO_CHAR (SYS.DIUTIL.bool_to_int (pemitesol)),
                               SQLERRM
                              );
            END;
 vpasexec := 10;
            num_err :=
               pac_sup_diferidos.f_propaga_suplemento (pvsseguro,
                                                       lcmotmov,
                                                       lnmovimi,
                                                       lfefecto
                                                      );

            IF num_err <> 0
            THEN
               ROLLBACK;
               vpasexec := 4;
               p_tab_error (f_sysdate,
                            f_user,
                            'PAC_MD_SUPLEMENTOS.F_Emitir_Suplemento',
                            vpasexec,
                               'psseguro = '
                            || psseguro
                            || ' pvsseguro = '
                            || pvsseguro
                            || ' pemitesol = '
                            || TO_CHAR (SYS.DIUTIL.bool_to_int (pemitesol)),
                            f_axis_literales (num_err)
                           );
            END IF;
         END IF;
      END IF;
       vpasexec := 11;
      IF vcontrol = 1
      THEN
         pac_alctr126.borrar_tablas_est (psseguro);

         IF num_err = 0
         THEN
            num_err := pk_suplementos.f_post_suplemento (pvsseguro);
              vpasexec := 12;
            IF num_err <> 0
            THEN
               p_tab_error (f_sysdate,
                            f_user,
                            'PAC_MD_SUPLEMENTOS.F_Emitir_Suplemento',
                            vpasexec,
                               'psseguro = '
                            || psseguro
                            || ' pvsseguro = '
                            || pvsseguro
                            || ' pemitesol = '
                            || TO_CHAR (SYS.DIUTIL.bool_to_int (pemitesol)),
                            f_axis_literales (num_err)
                           );
               RETURN num_err;
            END IF;
         END IF;
      END IF;
      p_tab_error (f_sysdate,
                            f_user,
                            'PAC_MD_SUPLEMENTOS.F_Emitir_Suplemento',
                            vpasexec,
                               'psseguro = '
                            || psseguro
                            || ' pvsseguro = '
                            || pvsseguro
                            || ' vcontrol = '
                            || vcontrol,
                            f_axis_literales (num_err)
                           );
      IF vcontrol = 0
      THEN  -- No es el suplemento de canvio de forma de pago y hay que emitir
       vpasexec := 13;
       p_tab_error (f_sysdate,
                            f_user,
                            'PAC_MD_SUPLEMENTOS.F_Emitir_Suplemento',
                            vpasexec,
                               'psseguro = '
                            || psseguro
                            || ' pvsseguro = '
                            || pvsseguro
                            || ' vcontrol = '
                            || vcontrol,
                            f_axis_literales (num_err)
                           );
         num_err :=
            pac_md_produccion.f_emitir_propuesta
                                     (psseguro,
                                      ponpoliza,
                                      posseguro,
                                      pnmovimi,
                                      mensajes,
                                      pcommit, -- Bug 26070 --ECP -- 21/02/2013
                                      pvsseguro
                                     );
                                     
                                     p_tab_error (f_sysdate,
                            f_user,
                            'PAC_MD_SUPLEMENTOS.F_Emitir_Suplemento',
                            vpasexec,
                               'psseguro = '
                            || psseguro
                            || ' pvsseguro = '
                            || pvsseguro
                            || ' vcontrol = '
                            || vcontrol
                            || ' num_err = '
                            || num_err,
                            f_axis_literales (num_err)
                           );

         IF num_err > 0
         THEN
            RETURN num_err;
         END IF;
      ELSE
         pnmovimi := pac_movseguro.f_nmovimi_ult (pvsseguro);
         -- BUG13352:DRA:24/03/2010:Inici
         posseguro := pvsseguro;
          vpasexec := 14;
           p_tab_error (f_sysdate,
                            f_user,
                            'PAC_MD_SUPLEMENTOS.F_Emitir_Suplemento',
                            vpasexec,
                               'psseguro = '
                            || psseguro
                            || ' pvsseguro = '
                            || pvsseguro
                            || ' vcontrol = '
                            || vcontrol
                            || ' num_err = '
                            || num_err
                            || ' pnmovimi = '
                            ||pnmovimi
                            || ' posseguro = '
                            || posseguro,
                            f_axis_literales (num_err)
                           );
         num_err :=
            pac_seguros.f_get_nsolici_npoliza (pvsseguro,
                                               NULL,
                                               NULL,
                                               NULL,
                                               vnsolici,
                                               vnpoliza,
                                               vncertif
                                              );

         IF num_err > 0
         THEN
            RETURN num_err;
         END IF;
         vpasexec := 15;
         IF vnpoliza IS NOT NULL
         THEN
            ponpoliza := vnpoliza;
         ELSIF vnsolici IS NOT NULL
         THEN
            ponpoliza := vnsolici;
         END IF;
      -- BUG13352:DRA:24/03/2010:Fi
       vpasexec := 16;
      END IF;
       vpasexec := 17;
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
         RETURN -1;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN -1;
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
         RETURN -1;
   END f_emitir_suplemento;

   --ACC 13122008
   /*************************************************************************
      Anula el riesgo especificado
      param in psseguro   : nmero seguro tablas est
      param in pnriesgo   : nmero de riesgo
      param in pfanulac   : fecha anulacin
      param in pnmovimi   : nmero movimiento
      param in pssegpol   : nmero seguro real
      param out mensajes  : coleccin de mensajes
      return              : objeto lista motivos pliza retenida
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
      vparam     VARCHAR2 (500)
         :=    'psseguro='
            || psseguro
            || ' pnriesgo='
            || pnriesgo
            || ' pfanulac='
            || pfanulac
            || ' pnmovimi='
            || pnmovimi
            || ' pssegpol='
            || pssegpol;
      vobject    VARCHAR2 (200) := 'PAC_MD_SUPLEMENTOS.F_Anular_Riesgo';
      nerr       NUMBER;
   BEGIN
      IF    psseguro IS NULL
         OR pnriesgo IS NULL
         OR pfanulac IS NULL
         OR pnmovimi IS NULL
         OR pssegpol IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      nerr :=
         pk_suplementos.f_anular_riesgo (psseguro,
                                         pnriesgo,
                                         pfanulac,
                                         pnmovimi,
                                         pssegpol
                                        );

      IF nerr <> 0
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, 112044);
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
   END f_anular_riesgo;

--ACC 13122008

   /*************************************************************************
      Determina si dos cdigos de movimiento son compatibles o no.

      param in pcmotmov1   : Cdigo de movimiento 1
      param in pcmotmov2   : Cdigo de movimiento 2

      return              : 0 no son compatibles
                            1 son compatibles
   *************************************************************************/
   -- Bug 9905 - 24/04/2009 - RSC - Suplemento de cambio de forma de pago diferido
   FUNCTION f_cmotmov_compatibles (pcmotmov1 IN NUMBER, pcmotmov2 IN NUMBER)
      RETURN NUMBER
   IS
      v_count   NUMBER;
   BEGIN
      IF pcmotmov1 IS NOT NULL AND pcmotmov2 IS NOT NULL
      THEN
         SELECT COUNT (*)
           INTO v_count
           FROM pds_dif_compatible
          WHERE (cmotmov1 = pcmotmov1 AND cmotmov2 = pcmotmov2)
             OR (cmotmov1 = pcmotmov2 AND cmotmov2 = pcmotmov1);

         IF v_count > 0
         THEN
            RETURN 1;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN -1;
   END f_cmotmov_compatibles;

   -- Fin Bug 9905

   /*************************************************************************
      Obtiene de seguros el valor parametrizado en el campo
      PDS_SUPL_DIF_CONFIG.TFECREC. Si F_FCARPRO, obtendr fcarpro, si
      F_FCARANU obtendr fcaranu.

      param in ptfecrec   : Identificador de fecha de suplemento diferido.
      param in psseguro   : Identificador de seguro

      return              : DATE (fcaranu o fcarpro)
   *************************************************************************/
   -- Bug 9905 - 24/04/2009 - RSC - Suplemento de cambio de forma de pago diferido
   FUNCTION f_fecha_diferido (ptfecrec IN VARCHAR2, psseguro IN NUMBER)
      RETURN DATE
   IS
      v_fdifer   DATE;
   BEGIN
      IF ptfecrec = 'F_FCARPRO'
      THEN
         SELECT fcarpro
           INTO v_fdifer
           FROM seguros
          WHERE sseguro = psseguro;
      ELSIF ptfecrec = 'F_FCARANU'
      THEN
         SELECT fcaranu
           INTO v_fdifer
           FROM seguros
          WHERE sseguro = psseguro;
      ELSE
         -- Si no parametrizado o a NULL se establecer por
         SELECT fcarpro
           INTO v_fdifer
           FROM seguros
          WHERE sseguro = psseguro;
      END IF;

      RETURN v_fdifer;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN NULL;
   END f_fecha_diferido;

   -- Fin Bug 9905

   /*************************************************************************
      Obtiene la lista de motivos de movimiento implicados en una modificacin
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
      verror       NUMBER;
      vpasexec     NUMBER         := 1;
      vparam       VARCHAR2 (500) := NULL;
      vobject      VARCHAR2 (200)
                               := 'PAC_MD_SUPLEMENTOS.f_get_diferir_cmotmovs';
      v_cmotmovs   t_lista_id     := t_lista_id ();
      v_sproduc    NUMBER;
   BEGIN
      SELECT sproduc
        INTO v_sproduc
        FROM estseguros
       WHERE sseguro = psseguro;

      verror :=
         pk_suplementos.f_get_cmotmov_cambios (f_user,
                                               psseguro,
                                               pnmovimi,
                                               v_sproduc,
                                               'BBDD',
                                               'SUPLEMENTO',
                                               v_cmotmovs
                                              );

      IF verror <> 0
      THEN
         RETURN verror;
      END IF;

      pcmotmovs := v_cmotmovs;
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

   -- fin Bug 9905

   /*************************************************************************
      A la hora de emitir un suplemento se debe validar si existen suplementos
      diferidos que coincidan con el suplemento que se est realizando, en cuyo caso,
      se deber de informar un mensaje y revisar los suplemento diferidos.

      param in pcmotmovs   : Lista de motivos de movimiento.
      param in ppoliza     : Objeto OB_IAX_DETPOLIZA de la seleccin
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
      vpasexec          NUMBER                  := 1;
      vparam            VARCHAR2 (500)          := NULL;
      vobject           VARCHAR2 (200)
                           := 'PAC_MD_SUPLEMENTOS.f_valida_emision_diferidos';
      v_nerr            NUMBER;
      vnaccion          NUMBER;
      v_texto           VARCHAR2 (2000);
      v_algun_error     NUMBER                  := 0;
      v_algun_warning   NUMBER                  := 0;
      -- 281
      v_ries            t_iax_riesgos;
      v_gars            t_iax_garantias;
      v_garprod         t_iaxpar_garantias;
      v_accion          NUMBER                  := 1;
      v_garantia        garanpro.cgarant%TYPE;
      v_conta           NUMBER;
   BEGIN
      IF pcmotmovs IS NOT NULL
      THEN
         IF pcmotmovs.COUNT > 0
         THEN
            FOR i IN pcmotmovs.FIRST .. pcmotmovs.LAST
            LOOP
               IF pcmotmovs.EXISTS (i)
               THEN
--------------------------------------------------------
--             Cambio de forma de pago                --
--------------------------------------------------------
                  IF pcmotmovs (i).idd = 269
                  THEN
                     SELECT COUNT (*)
                       INTO v_conta
                       FROM sup_diferidosseg p, sup_acciones_dif pa
                      WHERE p.sseguro = pa.sseguro
                        AND p.cmotmov = pa.cmotmov
                        AND p.sseguro = pac_iax_produccion.vsseguro
                        AND p.cmotmov = pcmotmovs (i).idd
                        AND pa.norden = 1;

                     IF v_conta > 0
                     THEN
                        v_texto :=
                              v_texto
                           || f_axis_literales (9001525,
                                                pac_md_common.f_get_cxtidioma
                                               )
                           || '<br><br>';
                        v_algun_warning := v_algun_warning + 1;
                     END IF;
                  --SELECT NACCION INTO vnaccion
                  --FROM SUP_DIFERIDOSSEG p, SUP_ACCIONES_DIF pa
                  --WHERE p.sseguro = pa.sseguro
                  --  AND p.cmotmov = pa.cmotmov
                  --  AND p.sseguro = pac_iax_produccion.vsseguro
                  --  AND p.cmotmov = pcmotmovs(i).idd
                  -- AND pa.norden = 1;

                  --IF vnaccion = PAC_IAX_PRODUCCION.poliza.det_poliza.gestion.cforpag THEN
                  --    v_texto := v_texto || f_axis_literales(9001517,PAC_MD_COMMON.F_GET_CXTIDIOMA)||'<br>';
                  --    v_algun_error := v_algun_error + 1;
                  --END IF;
                  END IF;

--------------------------------------------------------
--             Cambio de revalorizacin               --
--------------------------------------------------------
                  IF pcmotmovs (i).idd = 220
                  THEN
                     SELECT COUNT (*)
                       INTO v_conta
                       FROM sup_diferidosseg p, sup_acciones_dif pa
                      WHERE p.sseguro = pa.sseguro
                        AND p.cmotmov = pa.cmotmov
                        AND p.sseguro = pac_iax_produccion.vsseguro
                        AND p.cmotmov = pcmotmovs (i).idd
                        AND pa.norden = 1;

                     IF v_conta > 0
                     THEN
                        v_texto :=
                              v_texto
                           || f_axis_literales (9001529,
                                                pac_md_common.f_get_cxtidioma
                                               )
                           || '<br><br>';
                        v_algun_warning := v_algun_warning + 1;
                     END IF;
                  END IF;

--------------------------------------------------------
--           Modificacin de garantas                --
--------------------------------------------------------
                  IF pcmotmovs (i).idd = 281
                  THEN
                     --v_garprod := PAC_MDPAR_PRODUCTOS.f_get_garantias(ppoliza.sproduc, ppoliza.cactivi, mensajes);
                     v_ries :=
                           pac_iobj_prod.f_partpolriesgos (ppoliza, mensajes);

                     IF mensajes IS NOT NULL
                     THEN
                        IF mensajes.COUNT > 0
                        THEN
                           vpasexec := 1;
                           RAISE e_object_error;
                        END IF;
                     END IF;

                     IF v_ries IS NOT NULL
                     THEN
                        IF v_ries.COUNT > 0
                        THEN
                           FOR l IN v_ries.FIRST .. v_ries.LAST
                           LOOP
                              IF v_ries.EXISTS (l)
                              THEN
                                 v_gars :=
                                    pac_iobj_prod.f_partriesgarantias
                                                                  (v_ries (l),
                                                                   mensajes
                                                                  );

                                 FOR j IN v_gars.FIRST .. v_gars.LAST
                                 LOOP
                                    vpasexec := 2;

                                    IF v_gars.EXISTS (j)
                                    THEN
                                       FOR k IN
                                          (SELECT pa.*
                                             FROM sup_diferidosseg p,
                                                  sup_acciones_dif pa
                                            WHERE p.sseguro = pa.sseguro
                                              AND p.cmotmov = pa.cmotmov
                                              AND p.sseguro =
                                                     pac_iax_produccion.vsseguro
                                              AND p.cmotmov =
                                                             pcmotmovs (i).idd)
                                       LOOP
                                          v_garantia :=
                                             pac_util.splitt
                                                (pac_util.splitt
                                                             (UPPER (k.twhere),
                                                              2,
                                                              UPPER ('CGARANT')
                                                             ),
                                                 2,
                                                 '='
                                                );

                                          IF v_gars (j).cgarant =
                                                        TO_NUMBER (v_garantia)
                                          THEN
                                             --FOR w IN v_garprod.FIRST .. v_garprod.LAST LOOP
                                             --    IF v_garprod.EXISTS(w) THEN

                                             --        IF v_garprod(w).cgarant = v_gars(j).cgarant AND
                                             --           v_garprod(w).ctipcap IN (2,6) THEN

                                             -------------------------------
-- Modificacin de garantas --
-------------------------------
                                             IF UPPER (k.tcampo) = 'ICAPITAL'
                                             THEN
                                                --IF k.NACCION <> v_gars(j).icapital THEN
                                                v_texto :=
                                                      v_texto
                                                   || f_axis_literales
                                                         (9001526,
                                                          pac_md_common.f_get_cxtidioma
                                                         )
                                                   || '<br><br>';
                                                v_algun_warning :=
                                                           v_algun_warning + 1;
                                             --END IF;
                                             END IF;

                                             --        END IF;

                                             --        IF v_garprod(w).cgarant = v_gars(j).cgarant AND
                                             --           v_garprod(w).ctipgar IN (1,3) AND v_gars(j).cobliga = 0 AND
                                             --           v_gars(j).icapital IS NOT NULL THEN

                                             -----------------------------
-- Exclusin de garantas  --
-----------------------------
                                             IF UPPER (k.tcampo) = 'FFINEFE'
                                             THEN
                                                v_texto :=
                                                      v_texto
                                                   || f_axis_literales
                                                         (9001530,
                                                          pac_md_common.f_get_cxtidioma
                                                         )
                                                   || '<br><br>';
                                                v_algun_warning :=
                                                           v_algun_warning + 1;
                                             END IF;
                                          --        END IF;
                                          --    END IF;
                                          --END LOOP;
                                          END IF;
                                       END LOOP;
                                    END IF;
                                 END LOOP;
                              END IF;
                           END LOOP;
                        END IF;
                     END IF;
                  END IF;

--------------------------------------------------------
--             Cambio de agente                       --
--------------------------------------------------------
                  IF pcmotmovs (i).idd = 225
                  THEN
                     SELECT COUNT (*)
                       INTO v_conta
                       FROM sup_diferidosseg p, sup_acciones_dif pa
                      WHERE p.sseguro = pa.sseguro
                        AND p.cmotmov = pa.cmotmov
                        AND p.sseguro = pac_iax_produccion.vsseguro
                        AND p.cmotmov = pcmotmovs (i).idd
                        AND pa.norden = 1;

                     IF v_conta > 0
                     THEN
                        v_texto :=
                              v_texto
                           || f_axis_literales (9001531,
                                                pac_md_common.f_get_cxtidioma
                                               )
                           || '<br><br>';
                        v_algun_warning := v_algun_warning + 1;
                     END IF;
                  END IF;
               END IF;
            END LOOP;
         END IF;
      END IF;

      ptexto := v_texto;

      --IF v_algun_error > 0 THEN
      --    RETURN 1;
      --END IF;
      IF v_algun_warning > 0
      THEN
         RETURN 1;
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
      Funcin que realiza el diferimiento de cambio de forma de pago.

      param in ppoliza     : Objeto OB_IAX_DETPOLIZA de la seleccin
      param out mensajes   : Mensajes

      return              : 0 --> OK, <> 0 --> Error
   *************************************************************************/
   -- Bug 9905 - 24/04/2009 - RSC - Suplemento de cambio de forma de pago diferido
   FUNCTION f_diferir_spl_formapago (
      poliza     IN       ob_iax_detpoliza,
      pfdifer    IN       VARCHAR2,
      mensajes   OUT      t_iax_mensajes
   )
      RETURN NUMBER
   IS
      v_count       NUMBER;
      v_difer       pds_supl_dif_config%ROWTYPE;
      v_fdifer      DATE;
      vpasexec      NUMBER (8)                      := 1;
      vparam        VARCHAR2 (500);
      vobject       VARCHAR2 (200)
                              := 'PAC_MD_SUPLEMENTOS.f_diferir_spl_formapago';
      v_updatedif   VARCHAR2 (2000);
      v_ttabledif   sup_acciones_dif.ttable%TYPE;
      v_tcampodif   sup_acciones_dif.tcampo%TYPE;
      v_twheredif   sup_acciones_dif.twhere%TYPE;
      -- 05/05/2009
      v_tvalord     sup_diferidosseg.tvalord%TYPE;
      v_despues     VARCHAR2 (1000);
      v_num_err     NUMBER;
   BEGIN
      IF poliza IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      v_updatedif :=
            'UPDATE ESTSEGUROS SET CFORPAG = '
         || poliza.gestion.cforpag
         || ' WHERE SSEGURO = :SSEGURO';
      v_ttabledif := 'ESTSEGUROS';
      v_tcampodif := 'CFORPAG';
      v_twheredif := 'SSEGURO = :SSEGURO';
      vpasexec := 3;

      BEGIN
         SELECT *
           INTO v_difer
           FROM pds_supl_dif_config
          WHERE cmotmov = 269 AND (sproduc = poliza.sproduc OR sproduc = 0);
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            RETURN 9001505;
      END;

      -- De momento lo haremos as aunque esta fecha nos vendra de pantalla
      -- (se ir a buscar tambin a PDS_SUPL_DIF_CONFIG)
      vpasexec := 4;
      --v_fdifer := PAC_MD_SUPLEMENTOS.f_fecha_diferido(v_difer.tfecrec, poliza.ssegpol);
      v_fdifer :=
                 pac_md_suplementos.f_fecha_diferido (pfdifer, poliza.ssegpol);
      v_num_err :=
         f_desvalorfijo (17,
                         pac_md_common.f_get_cxtidioma,
                         poliza.gestion.cforpag,
                         v_despues
                        );
      v_tvalord :=
            f_axis_literales (102719, pac_md_common.f_get_cxtidioma)
         || ' '
         || v_despues;
      vpasexec := 5;

      BEGIN
         INSERT INTO sup_diferidosseg
                     (cmotmov, sseguro, fecsupl, fvalfun, estado,
                      cusuari, falta, tvalord
                     )
              VALUES (269, poliza.ssegpol, v_fdifer, v_difer.fvalfun, 0,
                      f_user, f_sysdate, v_tvalord
                     );
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX
         THEN
            RETURN 9001506;
         WHEN OTHERS
         THEN
            RAISE e_object_error;
      END;

      vpasexec := 6;

      BEGIN
         INSERT INTO sup_acciones_dif
                     (cmotmov, sseguro, norden, estado, dinaccion, ttable,
                      tcampo, twhere, taccion,
                      naccion, vaccion, ttarifa
                     )
              VALUES (269, poliza.ssegpol, 1, 0, 'U', v_ttabledif,
                      v_tcampodif, v_twheredif, v_updatedif,
                      poliza.gestion.cforpag, NULL, 1
                     );
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX
         THEN
            RETURN 9001506;
         WHEN OTHERS
         THEN
            RAISE e_object_error;
      END;

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
         RETURN -1;
      WHEN e_object_error
      THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN -1;
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
         RETURN -1;
   END f_diferir_spl_formapago;

   -- Fin Bug 9905

   /*************************************************************************
      Funcin que realiza el diferimiento de modificacin de garantias.

      param in ppoliza     : Objeto OB_IAX_DETPOLIZA de la seleccin
      param out mensajes   : Mensajes

      return              : 0 --> OK, <> 0 --> Error
   *************************************************************************/
   -- Bug 9905 - 24/04/2009 - RSC - Suplemento de cambio de forma de pago diferido
   FUNCTION f_diferir_spl_garantias (
      poliza     IN       ob_iax_detpoliza,
      pfdifer    IN       VARCHAR2,
      mensajes   OUT      t_iax_mensajes
   )
      RETURN NUMBER
   IS
      v_count       NUMBER;
      v_difer       pds_supl_dif_config%ROWTYPE;
      v_fdifer      DATE;
      vpasexec      NUMBER (8)                        := 1;
      vparam        VARCHAR2 (500);
      vobject       VARCHAR2 (200)
                              := 'PAC_MD_SUPLEMENTOS.f_diferir_spl_garantias';
      -- 26/04/2009
      v_ries        t_iax_riesgos;
      v_gars        t_iax_garantias;
      v_garprod     t_iaxpar_garantias;
      v_accion      NUMBER                            := 1;
      -- 28/04/2009
      v_icapital    NUMBER;
      v_icaptot     NUMBER;
      v_primercop   NUMBER                            := 1;
      v_updatedif   VARCHAR2 (2000);
      v_ttabledif   sup_acciones_dif.ttable%TYPE;
      v_tcampodif   sup_acciones_dif.tcampo%TYPE;
      v_twheredif   sup_acciones_dif.twhere%TYPE;
      v_exclusion   NUMBER (1);
      v_dinaccion   sup_acciones_dif.dinaccion%TYPE;
      -- 05/05/2009
      v_tvalord     sup_diferidosseg.tvalord%TYPE     := '';
   BEGIN
      IF poliza IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      v_ries := pac_iobj_prod.f_partpolriesgos (poliza, mensajes);

      IF mensajes IS NOT NULL
      THEN
         IF mensajes.COUNT > 0
         THEN
            vpasexec := 1;
            RAISE e_object_error;
         END IF;
      END IF;

      IF v_ries IS NOT NULL
      THEN
         IF v_ries.COUNT > 0
         THEN
            FOR i IN v_ries.FIRST .. v_ries.LAST
            LOOP
               IF v_ries.EXISTS (i)
               THEN
                  v_garprod :=
                     pac_mdpar_productos.f_get_garantias
                                                     (poliza.sproduc,
                                                      poliza.gestion.cactivi,
                                                      v_ries (i).nriesgo,
                                                      /*bug 9916: ETM :16-06-09:--poliza.cactivi,*/
                                                      mensajes
                                                     );
                  v_gars :=
                      pac_iobj_prod.f_partriesgarantias (v_ries (i), mensajes);

                  FOR j IN v_gars.FIRST .. v_gars.LAST
                  LOOP
                     v_exclusion := 0;
                     vpasexec := 2;

                     IF v_gars.EXISTS (j)
                     THEN
                        FOR k IN v_garprod.FIRST .. v_garprod.LAST
                        LOOP
                           vpasexec := 3;

                           IF v_garprod.EXISTS (k)
                           THEN
---------------------------
-- Exclusin de garanta --
---------------------------
                             /* IF v_garprod(k).cgarant = v_gars(j).cgarant
                                 AND v_garprod(k).ctipgar IN(1, 3)
                                 AND v_gars(j).cobliga = 0 THEN
                                 IF v_gars(j).icapital IS NOT NULL THEN
                                    vpasexec := 4;

                                    BEGIN
                                       SELECT *
                                         INTO v_difer
                                         FROM pds_supl_dif_config
                                        WHERE cmotmov = 281
                                          AND(sproduc = poliza.sproduc
                                              OR sproduc = 0);
                                    EXCEPTION
                                       WHEN NO_DATA_FOUND THEN
                                          RETURN 9001505;
                                    END;

                                    -- De momento lo haremos as aunque esta fecha nos vendra de pantalla
                                    -- (se ir a buscar tambin a PDS_SUPL_DIF_CONFIG)
                                    vpasexec := 5;
                                    --v_fdifer := PAC_MD_SUPLEMENTOS.f_fecha_diferido(v_difer.tfecrec, poliza.ssegpol);
                                    v_fdifer :=
                                       pac_md_suplementos.f_fecha_diferido(pfdifer,
                                                                           poliza.ssegpol);
                                    vpasexec := 6;

                                    BEGIN
                                       INSERT INTO sup_diferidosseg
                                                   (cmotmov, sseguro, fecsupl,
                                                    fvalfun, estado, cusuari, falta)
                                            VALUES (281, poliza.ssegpol, v_fdifer,
                                                    v_difer.fvalfun, 0, f_user, f_sysdate);
                                    EXCEPTION
                                       WHEN DUP_VAL_ON_INDEX THEN
                                          -- DUDA: Si difieres primero una modificacin de garanta
                                          -- y luego pretendes diferir una exclusin de garanta
                                          -- da casque por que ya existe un movimiento 281 programado.
                                          -- Reestructurar este diferimiento dara un poco de problema
                                          -- pero se podra hacer que el diferimiento de exclusin se
                                          -- anadiera al diferimiento existente. De momento lo dejamos
                                          -- as (comentado) y no se permitir diferir exclusin si antes
                                          -- existe una modificacin de garantas.

                                          --BEGIN
                                          --    SELECT dinaccion
                                          --    INTO v_dinaccion
                                          --    FROM SUP_ACCIONES_DIF
                                          --    WHERE cmotmov = 281
                                          --      AND sseguro = poliza.ssegpol
                                          --      AND dinaccion = 'D';
                                          --EXCEPTION
                                          --  WHEN NO_DATA_FOUND THEN
                                          --      NULL;
                                          --END;

                                          -- cmotmov = 281 + v_dinaccion = 'D'
                                          --         ==> Exclusin de garantia
                                          --IF v_primercop = 1 AND v_dinaccion = 'D' THEN
                                          IF v_primercop = 1 THEN
                                             RETURN 9001506;
                                          END IF;
                                       WHEN OTHERS THEN
                                          RAISE e_object_error;
                                    END;

                                    v_primercop := 0;
                                    -- Accion 1 --
                                    vpasexec := 7;
                                    v_updatedif :=
                                       'DELETE ESTGARANSEG'
                                       || ' WHERE SSEGURO = :SSEGURO AND NRIESGO = '
                                       || v_ries(i).nriesgo || ' AND CGARANT = '
                                       || v_gars(j).cgarant;
                                    v_ttabledif := 'ESTGARANSEG';
                                    v_tcampodif := 'FFINEFE';
                                    v_twheredif :=
                                       'SSEGURO = :SSEGURO AND NRIESGO = ' || v_ries(i).nriesgo
                                       || ' AND CGARANT = ' || v_gars(j).cgarant;
                                    -- Descripccin del suplemento
                                    v_tvalord :=
                                       v_tvalord
                                       || f_axis_literales(9001533,
                                                           pac_md_common.f_get_cxtidioma)
                                       || ' - '
                                       || f_axis_literales(100561,
                                                           pac_md_common.f_get_cxtidioma)
                                       || ': ' || v_gars(j).cgarant || ', '
                                       || f_axis_literales(100649,
                                                           pac_md_common.f_get_cxtidioma)
                                       || ': ' || v_ries(i).nriesgo || CHR(10);
                                    vpasexec := 8;

                                    BEGIN
                                       INSERT INTO sup_acciones_dif
                                                   (cmotmov, sseguro, norden, estado,
                                                    dinaccion, ttable, tcampo,
                                                    twhere, taccion,
                                                    naccion, vaccion, ttarifa)
                                            VALUES (281, poliza.ssegpol, v_accion, 0,
                                                    'D', v_ttabledif, v_tcampodif,
                                                    v_twheredif, v_updatedif,
                                                    v_gars(j).icapital, NULL, 0);
                                    EXCEPTION
                                       WHEN DUP_VAL_ON_INDEX THEN
                                          RETURN 9001506;
                                       WHEN OTHERS THEN
                                          RAISE e_object_error;
                                    END;

                                    v_accion := v_accion + 1;
                                    v_exclusion := 1;
                                 END IF;
                              END IF;*/

                              ---------------------------
-- Inclusin de garanta --
---------------------------
-- NULL;

                              -------------------------------
-- Modificacin de garantas --
-------------------------------
                              IF     v_garprod (k).cgarant =
                                                           v_gars (j).cgarant
                                 AND v_garprod (k).ctipcap IN (2, 6)
                                 AND v_exclusion = 0
                              THEN
                                 --v_garprod(k).ctipcap NOT IN (1,3,4,5) THEN
                                 IF v_gars (j).icapital IS NOT NULL
                                 THEN
                                    SELECT icapital, icaptot
                                      INTO v_icapital, v_icaptot
                                      FROM garanseg
                                     WHERE sseguro = poliza.ssegpol
                                       AND nriesgo = v_ries (i).nriesgo
                                       AND cgarant = v_gars (j).cgarant
                                       AND nmovimi =
                                              (SELECT MAX (g.nmovimi)
                                                 FROM garanseg g
                                                WHERE g.sseguro =
                                                              garanseg.sseguro
                                                  AND g.nriesgo =
                                                              garanseg.nriesgo
                                                  AND g.cgarant =
                                                              garanseg.cgarant);

                                    IF    v_gars (j).icapital <> v_icapital
                                       OR v_gars (j).icaptot <> v_icaptot
                                    THEN
                                       vpasexec := 4;

                                       BEGIN
                                          SELECT *
                                            INTO v_difer
                                            FROM pds_supl_dif_config
                                           WHERE cmotmov = 281
                                             AND (   sproduc = poliza.sproduc
                                                  OR sproduc = 0
                                                 );
                                       EXCEPTION
                                          WHEN NO_DATA_FOUND
                                          THEN
                                             RETURN 9001505;
                                       END;

                                       -- De momento lo haremos as aunque esta fecha nos vendra de pantalla
                                       -- (se ir a buscar tambin a PDS_SUPL_DIF_CONFIG)
                                       vpasexec := 5;
                                       --v_fdifer := PAC_MD_SUPLEMENTOS.f_fecha_diferido(v_difer.tfecrec, poliza.ssegpol);
                                       v_fdifer :=
                                          pac_md_suplementos.f_fecha_diferido
                                                               (pfdifer,
                                                                poliza.ssegpol
                                                               );
                                       vpasexec := 6;

                                       BEGIN
                                          INSERT INTO sup_diferidosseg
                                                      (cmotmov, sseguro,
                                                       fecsupl,
                                                       fvalfun, estado,
                                                       cusuari, falta
                                                      )
                                               VALUES (281, poliza.ssegpol,
                                                       v_fdifer,
                                                       v_difer.fvalfun, 0,
                                                       f_user, f_sysdate
                                                      );
                                       EXCEPTION
                                          WHEN DUP_VAL_ON_INDEX
                                          THEN
                                             --BEGIN
                                             --    SELECT dinaccion
                                             --    INTO v_dinaccion
                                             --    FROM SUP_ACCIONES_DIF
                                             --    WHERE cmotmov = 281
                                             --      AND sseguro = poliza.ssegpol
                                             --      AND dinaccion = 'D';
                                             --EXCEPTION
                                             --  WHEN NO_DATA_FOUND THEN
                                             --      NULL;
                                             --END;

                                             -- cmotmov = 281 + v_dinaccion = 'U'
                                              --         ==> Modificacin de garanta
                                              --IF v_primercop = 1 AND v_dinaccion = 'U' THEN
                                             /* IF v_primercop = 1 THEN  --DCT 03/07/2015
                                                 RETURN 9001506;
                                              END IF;*/
                                             NULL;
                                          WHEN OTHERS
                                          THEN
                                             RAISE e_object_error;
                                       END;

                                       -- Posem control a 0 (si se inserta mas de una vez
                                       -- en SUP_DIFERIDOSSEG aqui dentro dejamos continuar).
                                       -- La primera vez si casca el INSERT si que se debe avisar.
                                       v_primercop := 0;
                                       -- Accion 1 --
                                       vpasexec := 7;
                                       v_updatedif :=
                                             'UPDATE ESTGARANSEG SET ICAPITAL = '
                                          || TRANSLATE
                                                 (TO_CHAR (v_gars (j).icapital),
                                                  ',',
                                                  '.'
                                                 )
                                          || ' WHERE SSEGURO = :SSEGURO AND NRIESGO = '
                                          || v_ries (i).nriesgo
                                          || ' AND CGARANT = '
                                          || v_gars (j).cgarant;
                                       v_ttabledif := 'ESTGARANSEG';
                                       v_tcampodif := 'ICAPITAL';
                                       v_twheredif :=
                                             'SSEGURO = :SSEGURO AND NRIESGO = '
                                          || v_ries (i).nriesgo
                                          || ' AND CGARANT = '
                                          || v_gars (j).cgarant;
                                       v_tvalord :=
                                             v_tvalord
                                          || ff_desgarantia
                                                (v_gars (j).cgarant,
                                                 pac_md_common.f_get_cxtidioma
                                                )
                                          || ':'
                                          || v_gars (j).icapital;
                                       vpasexec := 8;

                                       BEGIN
                                          INSERT INTO sup_acciones_dif
                                                      (cmotmov, sseguro,
                                                       norden, estado,
                                                       dinaccion, ttable,
                                                       tcampo,
                                                       twhere,
                                                       taccion,
                                                       naccion,
                                                       vaccion, ttarifa
                                                      )
                                               VALUES (281, poliza.ssegpol,
                                                       v_accion, 0,
                                                       'U', v_ttabledif,
                                                       v_tcampodif,
                                                       v_twheredif,
                                                       v_updatedif,
                                                       v_gars (j).icapital,
                                                       NULL, 0
                                                      );
                                       EXCEPTION
                                          WHEN DUP_VAL_ON_INDEX
                                          THEN
                                             RETURN 9001506;
                                          WHEN OTHERS
                                          THEN
                                             RAISE e_object_error;
                                       END;

                                       v_accion := v_accion + 1;
                                       -- Accion 2 --
                                       vpasexec := 9;
                                       v_updatedif :=
                                             'UPDATE ESTGARANSEG SET ICAPTOT = '
                                          || TRANSLATE
                                                 (TO_CHAR (v_gars (j).icapital),
                                                  ',',
                                                  '.'
                                                 )
                                          || ' WHERE SSEGURO = :SSEGURO AND NRIESGO = '
                                          || v_ries (i).nriesgo
                                          || ' AND CGARANT = '
                                          || v_gars (j).cgarant;
                                       v_ttabledif := 'ESTGARANSEG';
                                       v_tcampodif := 'ICAPTOT';
                                       v_twheredif :=
                                             'SSEGURO = :SSEGURO AND NRIESGO = '
                                          || v_ries (i).nriesgo
                                          || ' AND CGARANT = '
                                          || v_gars (j).cgarant;
                                       vpasexec := 10;

                                       BEGIN
                                          INSERT INTO sup_acciones_dif
                                                      (cmotmov, sseguro,
                                                       norden, estado,
                                                       dinaccion, ttable,
                                                       tcampo,
                                                       twhere,
                                                       taccion,
                                                       naccion,
                                                       vaccion, ttarifa
                                                      )
                                               VALUES (281, poliza.ssegpol,
                                                       v_accion, 0,
                                                       'U', v_ttabledif,
                                                       v_tcampodif,
                                                       v_twheredif,
                                                       v_updatedif,
                                                       v_gars (j).icapital,
                                                       NULL, 0
                                                      );
                                       EXCEPTION
                                          WHEN DUP_VAL_ON_INDEX
                                          THEN
                                             RETURN 9001506;
                                          WHEN OTHERS
                                          THEN
                                             RAISE e_object_error;
                                       END;

                                       v_accion := v_accion + 1;
                                    END IF;
                                 END IF;
                              END IF;
                           END IF;
                        END LOOP;
                     END IF;
                  END LOOP;
               END IF;
            END LOOP;
         END IF;
      END IF;

      -- Actualizamos el literal del descripccin
      UPDATE sup_diferidosseg
         SET tvalord = v_tvalord
       WHERE cmotmov = 281 AND sseguro = poliza.ssegpol AND estado = 0;

      -- Actualizamos para tarifar tras el ltimo movimiento
      UPDATE sup_acciones_dif
         SET ttarifa = 1
       WHERE cmotmov = 281
         AND sseguro = poliza.ssegpol
         AND norden = (v_accion - 1);

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
         RETURN -1;
      WHEN e_object_error
      THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN -1;
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
         RETURN -1;
   END f_diferir_spl_garantias;

   /*************************************************************************
      Evalua si un seguro debe diferir algun suplemento en el futuro.

      param in psseguro     : Objeto OB_IAX_DETPOLIZA de la seleccin
      param in ppoliza     : Objeto OB_IAX_DETPOLIZA de la seleccin
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
      v_error    NUMBER;
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (500);
      vobject    VARCHAR2 (200)
                              := 'PAC_MD_SUPLEMENTOS.f_eval_diferidos_futuro';
   BEGIN
      v_error := pac_sup_diferidos.f_eval_diferidos_futuro (psseguro, pfecha);
      RETURN v_error;
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
         RETURN 0;
   END f_eval_diferidos_futuro;

   -- Fin Bug 9905

   /*************************************************************************
      Funcin para averiguar si el botn Diferir debe o no debe estar
      habilitado.

      param in psseguro    : Identificador de contrato.
      param in pcmotmovs   : Lista de motivos implicados en el suplemento.
      param out mensajes   : Mensajes.
      return               : 0 --> No activar Diferir,
                             1 --> Si activar Diferir,
                            -1 --> Error.
   *************************************************************************/
   -- Bug 9905 - 24/04/2009 - RSC - Suplemento de cambio de forma de pago diferido
   FUNCTION f_habilita_diferir (
      psseguro    IN       NUMBER,
      pcmotmovs   IN       t_lista_id,
      pmostrar    OUT      NUMBER,
      mensajes    OUT      t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vpasexec      NUMBER (8)                         := 1;
      vparam        VARCHAR2 (500)                     := NULL;
      vobject       VARCHAR2 (200) := 'PAC_MD_SUPLEMENTOS.f_habilita_diferir';
      nerr          NUMBER;
      onpoliza      NUMBER;
      osseguro      NUMBER;
      vsseguro      NUMBER;
      vvsseguro     NUMBER;
      vmsj          VARCHAR2 (500);
      vnmovimi      NUMBER;
      vsproduc      NUMBER;
      vsinterf      NUMBER;
      verror        VARCHAR2 (2000);
      vpoliza       ob_iax_poliza                := pac_iax_produccion.poliza;
      v_updatedif   VARCHAR2 (1000);
      vtest         NUMBER;
      v_cmotmovs    t_lista_id;
      v_npoliza     seguros.npoliza%TYPE;
      v_difermot    NUMBER                             := 0;
      v_sproduc     seguros.sproduc%TYPE;
      v_cmotmov     pds_supl_dif_config.cmotmov%TYPE;
   BEGIN
      BEGIN
         SELECT sproduc
           INTO v_sproduc
           FROM seguros
          WHERE sseguro = psseguro;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            BEGIN
               SELECT sproduc
                 INTO v_sproduc
                 FROM estseguros
                WHERE sseguro = psseguro;
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  pmostrar := 0;
                  RETURN 0;
            END;
      END;

      IF pcmotmovs IS NOT NULL
      THEN
         IF pcmotmovs.COUNT > 0
         THEN
            FOR i IN pcmotmovs.FIRST .. pcmotmovs.LAST
            LOOP
               IF pcmotmovs.EXISTS (i)
               THEN
                  BEGIN
                     SELECT cmotmov
                       INTO v_cmotmov
                       FROM pds_supl_dif_config
                      WHERE cmotmov = pcmotmovs (i).idd
                        AND (sproduc = v_sproduc OR sproduc = 0);

                     pmostrar := 1;
                     RETURN 0;
                  EXCEPTION
                     --Ini 3504 --ECP -- 24/12/2019
                     WHEN NO_DATA_FOUND
                     THEN
                        pmostrar := 0;
                        RETURN 0;
                  --Ini 3504 --ECP -- 24/12/2019
                  END;
               END IF;
            END LOOP;
         END IF;
      END IF;

      pmostrar := 0;
      RETURN 0;
   EXCEPTION
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

   -- Fin Bug 9905

   /*************************************************************************
      Funcin que realiza el diferimiento de cambio de reavlorizacin.

      param in ppoliza     : Objeto OB_IAX_DETPOLIZA de la seleccin
      param out mensajes   : Mensajes

      return              : 0 --> OK, <> 0 --> Error
   *************************************************************************/
   -- Bug 9905 - 24/04/2009 - RSC - Suplemento de cambio de forma de pago diferido
   FUNCTION f_diferir_spl_revali (
      poliza     IN       ob_iax_detpoliza,
      pfdifer    IN       VARCHAR2,
      mensajes   OUT      t_iax_mensajes
   )
      RETURN NUMBER
   IS
      v_count       NUMBER;
      v_difer       pds_supl_dif_config%ROWTYPE;
      v_fdifer      DATE;
      vpasexec      NUMBER (8)                      := 1;
      vparam        VARCHAR2 (500);
      vobject       VARCHAR2 (200)
                                 := 'PAC_MD_SUPLEMENTOS.f_diferir_spl_revali';
      v_updatedif   VARCHAR2 (2000);
      v_ttabledif   sup_acciones_dif.ttable%TYPE;
      v_tcampodif   sup_acciones_dif.tcampo%TYPE;
      v_twheredif   sup_acciones_dif.twhere%TYPE;
      v_norden      NUMBER                          := 1;
      -- 05/05/2009
      v_tvalord     sup_diferidosseg.tvalord%TYPE;
      v_despues     VARCHAR2 (1000);
      v_num_err     NUMBER;
   BEGIN
      IF poliza IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      v_updatedif :=
            'UPDATE ESTSEGUROS SET CREVALI = '
         || poliza.crevali
         || ' WHERE SSEGURO = :SSEGURO';
      v_ttabledif := 'ESTSEGUROS';
      v_tcampodif := 'CREVALI';
      v_twheredif := 'SSEGURO = :SSEGURO';
      vpasexec := 3;

      BEGIN
         SELECT *
           INTO v_difer
           FROM pds_supl_dif_config
          WHERE cmotmov = 220 AND (sproduc = poliza.sproduc OR sproduc = 0);
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            RETURN 9001505;
      END;

      -- De momento lo haremos as aunque esta fecha nos vendra de pantalla
      -- (se ir a buscar tambin a PDS_SUPL_DIF_CONFIG)
      vpasexec := 4;
      --v_fdifer := PAC_MD_SUPLEMENTOS.f_fecha_diferido(v_difer.tfecrec, poliza.ssegpol);
      v_fdifer :=
                 pac_md_suplementos.f_fecha_diferido (pfdifer, poliza.ssegpol);
      -- 05/05/2009
      v_num_err :=
         f_desvalorfijo (62,
                         pac_md_common.f_get_cxtidioma,
                         poliza.crevali,
                         v_despues
                        );
      v_tvalord :=
            f_axis_literales (101431, pac_md_common.f_get_cxtidioma)
         || ' '
         || v_despues;

      IF poliza.irevali IS NOT NULL
      THEN
         v_tvalord := v_tvalord || ' - ' || poliza.irevali;
      END IF;

      IF poliza.prevali IS NOT NULL
      THEN
         v_tvalord := v_tvalord || ' - ' || poliza.prevali || '%';
      END IF;

      vpasexec := 5;

      BEGIN
         INSERT INTO sup_diferidosseg
                     (cmotmov, sseguro, fecsupl, fvalfun, estado,
                      cusuari, falta, tvalord
                     )
              VALUES (220, poliza.ssegpol, v_fdifer, v_difer.fvalfun, 0,
                      f_user, f_sysdate, v_tvalord
                     );
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX
         THEN
            RETURN 9001506;
         WHEN OTHERS
         THEN
            RAISE e_object_error;
      END;

      vpasexec := 6;

      BEGIN
         INSERT INTO sup_acciones_dif
                     (cmotmov, sseguro, norden, estado, dinaccion, ttable,
                      tcampo, twhere, taccion, naccion,
                      vaccion, ttarifa
                     )
              VALUES (220, poliza.ssegpol, v_norden, 0, 'U', v_ttabledif,
                      v_tcampodif, v_twheredif, v_updatedif, poliza.crevali,
                      NULL, 0
                     );

         v_norden := v_norden + 1;
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX
         THEN
            RETURN 9001506;
         WHEN OTHERS
         THEN
            RAISE e_object_error;
      END;

      vpasexec := 7;

      IF poliza.irevali IS NOT NULL
      THEN
         v_updatedif :=
               'UPDATE ESTSEGUROS SET IREVALI = '
            || TRANSLATE (TO_CHAR (poliza.irevali), ',', '.')
            || ' WHERE SSEGURO = :SSEGURO';
         v_ttabledif := 'ESTSEGUROS';
         v_tcampodif := 'IREVALI';
         v_twheredif := 'SSEGURO = :SSEGURO';
         vpasexec := 8;

         BEGIN
            INSERT INTO sup_acciones_dif
                        (cmotmov, sseguro, norden, estado, dinaccion,
                         ttable, tcampo, twhere, taccion,
                         naccion, vaccion, ttarifa
                        )
                 VALUES (220, poliza.ssegpol, v_norden, 0, 'U',
                         v_ttabledif, v_tcampodif, v_twheredif, v_updatedif,
                         poliza.irevali, NULL, 0
                        );

            v_norden := v_norden + 1;
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX
            THEN
               RETURN 9001506;
            WHEN OTHERS
            THEN
               RAISE e_object_error;
         END;
      END IF;

      vpasexec := 9;

      IF poliza.prevali IS NOT NULL
      THEN
         v_updatedif :=
               'UPDATE ESTSEGUROS SET PREVALI = '
            || TRANSLATE (TO_CHAR (poliza.prevali), ',', '.')
            || ' WHERE SSEGURO = :SSEGURO';
         v_ttabledif := 'ESTSEGUROS';
         v_tcampodif := 'PREVALI';
         v_twheredif := 'SSEGURO = :SSEGURO';
         vpasexec := 10;

         BEGIN
            INSERT INTO sup_acciones_dif
                        (cmotmov, sseguro, norden, estado, dinaccion,
                         ttable, tcampo, twhere, taccion,
                         naccion, vaccion, ttarifa
                        )
                 VALUES (220, poliza.ssegpol, v_norden, 0, 'U',
                         v_ttabledif, v_tcampodif, v_twheredif, v_updatedif,
                         poliza.prevali, NULL, 0
                        );

            v_norden := v_norden + 1;
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX
            THEN
               RETURN 9001506;
            WHEN OTHERS
            THEN
               RAISE e_object_error;
         END;
      END IF;

      UPDATE sup_acciones_dif
         SET ttarifa = 1
       WHERE cmotmov = 220
         AND sseguro = poliza.ssegpol
         AND norden = (v_norden - 1);

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
         RETURN -1;
      WHEN e_object_error
      THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN -1;
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
         RETURN -1;
   END f_diferir_spl_revali;

   -- Fin Bug 9905

   /*************************************************************************
      Funcin que realiza el diferimiento de cambio de reavlorizacin.

      param in ppoliza     : Objeto OB_IAX_DETPOLIZA de la seleccin
      param out mensajes   : Mensajes

      return              : 0 --> OK, <> 0 --> Error
   *************************************************************************/
   -- Bug 9905 - 04/05/2009 - RSC - Suplemento de cambio de forma de pago diferido
   FUNCTION f_diferir_spl_agente (
      poliza     IN       ob_iax_detpoliza,
      pfdifer    IN       VARCHAR2,
      mensajes   OUT      t_iax_mensajes
   )
      RETURN NUMBER
   IS
      v_count       NUMBER;
      v_difer       pds_supl_dif_config%ROWTYPE;
      v_fdifer      DATE;
      vpasexec      NUMBER (8)                      := 1;
      vparam        VARCHAR2 (500);
      vobject       VARCHAR2 (200)
                                 := 'PAC_MD_SUPLEMENTOS.f_diferir_spl_agente';
      v_updatedif   VARCHAR2 (2000);
      v_ttabledif   sup_acciones_dif.ttable%TYPE;
      v_tcampodif   sup_acciones_dif.tcampo%TYPE;
      v_twheredif   sup_acciones_dif.twhere%TYPE;
      v_norden      NUMBER                          := 1;
      -- 05/05/2009
      v_tvalord     sup_diferidosseg.tvalord%TYPE;
      v_despues     VARCHAR2 (1000);
      v_num_err     NUMBER;
   BEGIN
      IF poliza IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      v_updatedif :=
            'UPDATE ESTSEGUROS SET CAGENTE = '
         || poliza.cagente
         || ' WHERE SSEGURO = :SSEGURO';
      v_ttabledif := 'ESTSEGUROS';
      v_tcampodif := 'CAGENTE';
      v_twheredif := 'SSEGURO = :SSEGURO';
      vpasexec := 3;

      BEGIN
         SELECT *
           INTO v_difer
           FROM pds_supl_dif_config
          WHERE cmotmov = 225 AND (sproduc = poliza.sproduc OR sproduc = 0);
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            RETURN 9001505;
      END;

      -- De momento lo haremos as aunque esta fecha nos vendra de pantalla
      -- (se ir a buscar tambin a PDS_SUPL_DIF_CONFIG)
      vpasexec := 4;
      --v_fdifer := PAC_MD_SUPLEMENTOS.f_fecha_diferido(v_difer.tfecrec, poliza.ssegpol);
      v_fdifer :=
                 pac_md_suplementos.f_fecha_diferido (pfdifer, poliza.ssegpol);
      v_tvalord :=
            f_axis_literales (102591, pac_md_common.f_get_cxtidioma)
         || ' '
         || poliza.cagente
         || ' '
         || ff_desagente (poliza.cagente);
      vpasexec := 5;

      BEGIN
         INSERT INTO sup_diferidosseg
                     (cmotmov, sseguro, fecsupl, fvalfun, estado,
                      cusuari, falta, tvalord
                     )
              VALUES (225, poliza.ssegpol, v_fdifer, v_difer.fvalfun, 0,
                      f_user, f_sysdate, v_tvalord
                     );
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX
         THEN
            RETURN 9001506;
         WHEN OTHERS
         THEN
            RAISE e_object_error;
      END;

      vpasexec := 6;

      BEGIN
         INSERT INTO sup_acciones_dif
                     (cmotmov, sseguro, norden, estado, dinaccion, ttable,
                      tcampo, twhere, taccion, naccion,
                      vaccion, ttarifa
                     )
              VALUES (225, poliza.ssegpol, v_norden, 0, 'U', v_ttabledif,
                      v_tcampodif, v_twheredif, v_updatedif, poliza.cagente,
                      NULL, 1
                     );

         v_norden := v_norden + 1;
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX
         THEN
            RETURN 9001506;
         WHEN OTHERS
         THEN
            RAISE e_object_error;
      END;

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
         RETURN -1;
      WHEN e_object_error
      THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN -1;
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
         RETURN -1;
   END f_diferir_spl_agente;

   -- Fin Bug 9905

   /***********************************************************************
      Recupera los movimientos de suplementos diferidos de la pliza.

      param out mensajes : mensajes de error
      return             : ref cursor
   ***********************************************************************/
   -- Bug 9905 - 04/05/2009 - RSC - Suplemento de cambio de forma de pago diferido
   FUNCTION f_get_mvtdiferidos (
      psolicit   IN       NUMBER,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN sys_refcursor
   IS
      squery     VARCHAR (2000);
      cur        sys_refcursor;
      vidioma    NUMBER         := pac_md_common.f_get_cxtidioma;
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (500) := 'psolicit=' || psolicit;
      vobject    VARCHAR2 (200) := 'PAC_MD_SUPLEMENTOS.F_Get_Mvtdiferidos';
   BEGIN
      squery :=
            'SELECT p.fecsupl, trunc(p.falta) falta, p.fanula, p.cmotmov, p.estado, m.tmotmov, '
         || 'FF_DESVALORFIJO(930,'
         || vidioma
         || ',p.estado) testado, p.cusuari, p.tvalord, DECODE(p.estado,0,''A'',''P'') canvi_estat
         FROM SUP_DIFERIDOSSEG p, motmovseg m
         WHERE p.cmotmov = m.cmotmov
           AND p.sseguro = '
         || psolicit
         || '  AND p.estado = 0
           and m.cidioma = '
         || vidioma
         || ' UNION '
         || 'SELECT s.fecsupl, trunc(s.falta) falta, s.fanula, s.cmotmov, s.estado, m3.tmotmov, '
         || 'FF_DESVALORFIJO(930,'
         || vidioma
         || ',s.estado) testado, s.cusuari, s.tvalord, NULL canvi_estat
         FROM HIS_SUP_DIFERIDOSSEG s, motmovseg m3
         WHERE s.cmotmov = m3.cmotmov
           AND s.sseguro = '
         || psolicit
         || '  AND s.estado = 2
           AND m3.cidioma = '
         || vidioma
         || ' UNION '
         || 'SELECT h.fecsupl, trunc(h.falta) falta, h.fanula, h.cmotmov, h.estado, m2.tmotmov, '
         || 'FF_DESVALORFIJO(930,'
         || vidioma
         || ',h.estado) testado, h.cusuari, h.tvalord, NULL canvi_estat
         FROM HIS_SUP_DIFERIDOSSEG h, motmovseg m2
         WHERE h.cmotmov = m2.cmotmov
           AND h.sseguro = '
         || psolicit
         || '  AND h.estado = 1
           AND m2.cidioma = '
         || vidioma
         || 'ORDER BY FECSUPL desc';
      cur := pac_iax_listvalores.f_opencursor (squery, mensajes);
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
      Funcin para marcar el radio button de fecha de diferimiento por defecto
      al diferir.

      param in psseguro    : Identificador de contrato.
      param in pcmotmovs   : Lista de motivos implicados en el suplemento.
      param out mensajes   : Mensajes.
      return               : 0 --> No Activar Todo (F_CARPRO y F_CARANU)
                             1 --> Activar Todo (F_CARPRO y F_CARANU),
                            -1 --> Error.
   *************************************************************************/
   -- Bug 9905 - 04/05/2009 - RSC - Suplemento de cambio de forma de pago diferido
   FUNCTION f_get_fecha_diferir (
      psseguro    IN       NUMBER,
      pcmotmovs   IN       t_lista_id,
      pfechap     OUT      VARCHAR2,
      mensajes    OUT      t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vpasexec      NUMBER (8)                         := 1;
      vparam        VARCHAR2 (500)                     := NULL;
      vobject       VARCHAR2 (200)
                                  := 'PAC_MD_SUPLEMENTOS.f_get_fecha_diferir';
      nerr          NUMBER;
      onpoliza      NUMBER;
      osseguro      NUMBER;
      vsseguro      NUMBER;
      vvsseguro     NUMBER;
      vmsj          VARCHAR2 (500);
      vnmovimi      NUMBER;
      vsproduc      NUMBER;
      vsinterf      NUMBER;
      verror        VARCHAR2 (2000);
      vpoliza       ob_iax_poliza                := pac_iax_produccion.poliza;
      v_updatedif   VARCHAR2 (1000);
      vtest         NUMBER;
      v_cmotmovs    t_lista_id;
      v_npoliza     seguros.npoliza%TYPE;
      v_difermot    NUMBER                             := 0;
      v_sproduc     seguros.sproduc%TYPE;
      v_cmotmov     pds_supl_dif_config.cmotmov%TYPE;
      v_tfecrec     pds_supl_dif_config.tfecrec%TYPE;

      TYPE v_assoc_array_fecha IS TABLE OF NUMBER
         INDEX BY pds_supl_dif_config.tfecrec%TYPE;

      v_fechas      v_assoc_array_fecha;
   BEGIN
      SELECT sproduc
        INTO v_sproduc
        FROM seguros
       WHERE sseguro = psseguro;

      IF pcmotmovs IS NOT NULL
      THEN
         IF pcmotmovs.COUNT > 0
         THEN
            FOR i IN pcmotmovs.FIRST .. pcmotmovs.LAST
            LOOP
               IF pcmotmovs.EXISTS (i)
               THEN
                  BEGIN
                     SELECT tfecrec
                       INTO v_tfecrec
                       FROM pds_supl_dif_config
                      WHERE cmotmov = pcmotmovs (i).idd
                            AND sproduc = v_sproduc;

                     IF v_tfecrec IS NOT NULL
                     THEN
                        IF v_fechas.EXISTS (v_tfecrec)
                        THEN
                           v_fechas (v_tfecrec) := v_fechas (v_tfecrec) + 1;
                        ELSE
                           v_fechas (v_tfecrec) := 1;
                        END IF;
                     END IF;
                  EXCEPTION
                     WHEN NO_DATA_FOUND
                     THEN
                        NULL;
                  END;
               END IF;
            END LOOP;
         END IF;
      END IF;

      IF v_fechas.COUNT = 0 OR v_fechas.COUNT > 1
      THEN
         RETURN 1;
      END IF;

      -- ==> v_fechas.COUNT = 1
      v_tfecrec := v_fechas.FIRST;

      WHILE v_tfecrec IS NOT NULL
      LOOP
         pfechap := v_tfecrec;
         v_tfecrec := v_fechas.NEXT (v_tfecrec);
      END LOOP;

      RETURN 0;
   EXCEPTION
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
         RETURN -1;
   END f_get_fecha_diferir;

   -- Fin Bug 9905

   /*************************************************************************
      Funcin para averiguar si el botn Diferir debe o no debe mostrarse.

      param out mensajes    : Mensajes
      return              : 0 --> OK, <> 0 --> Error
   *************************************************************************/
   -- Bug 9905 - 05/05/2009 - RSC - Suplemento de cambio de forma de pago diferido
   FUNCTION f_mostrar_diferir (
      pcempres   IN       NUMBER,
      pmostrar   OUT      NUMBER,
      mensajes   OUT      t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vpasexec      NUMBER (8)     := 1;
      vparam        VARCHAR2 (500) := NULL;
      vobject       VARCHAR2 (200) := 'PAC_MD_SUPLEMENTOS.f_mostrar_diferir';
      v_resultado   NUMBER;
      num_err       NUMBER;
   BEGIN
      pmostrar :=
             NVL (pac_parametros.f_parempresa_n (pcempres, 'SPL_DIFERIR'), 0);
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
      Funcin para averiguar si el botn Diferir debe o no debe mostrarse.

      param out pmostrar    : Indicador de si debe o no mostrar el botn Diferir.
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
                              := 'PAC_MD_SUPLEMENTOS.f_anular_abrir_diferido';
      num_err     NUMBER;
      v_mostrar   NUMBER;
      v_fecsupl   DATE;
      v_fcarpro   DATE;
      v_fecha     DATE;
   BEGIN
      v_fecha := f_sysdate;

      IF pestado = 0
      THEN                                             -- Acutlamente Abierto
         SELECT fecsupl
           INTO v_fecsupl
           FROM sup_diferidosseg
          WHERE cmotmov = pcmotmov AND sseguro = psseguro AND estado = pestado;

         SELECT fcarpro
           INTO v_fcarpro
           FROM seguros
          WHERE sseguro = psseguro;

         -- El diferimiento ya no es vigente
         IF v_fecsupl < v_fcarpro
         THEN
            pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 2, 9001536);
            RETURN 0;
         END IF;

         INSERT INTO his_sup_diferidosseg
                     (cmotmov, sseguro, ffinal, fecsupl, fvalfun, estado,
                      cusuari, falta, tvalord, fanula, nmovimi)
            SELECT cmotmov, sseguro, v_fecha, fecsupl, fvalfun, 2, cusuari,
                   falta, tvalord, v_fecha, nmovimi
              FROM sup_diferidosseg
             WHERE cmotmov = pcmotmov
               AND sseguro = psseguro
               AND estado = pestado;

         INSERT INTO his_sup_acciones_dif
            SELECT cmotmov, sseguro, norden, v_fecha, 2, dinaccion, ttable,
                   tcampo, twhere, taccion, naccion, vaccion, ttarifa
              FROM sup_acciones_dif
             WHERE cmotmov = pcmotmov
               AND sseguro = psseguro
               AND estado = pestado;

         DELETE      sup_acciones_dif
               WHERE cmotmov = pcmotmov
                 AND sseguro = psseguro
                 AND estado = pestado;

         DELETE      sup_diferidosseg
               WHERE cmotmov = pcmotmov
                 AND sseguro = psseguro
                 AND estado = pestado;
      ELSIF pestado = 1
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 2, 9001537);
         RETURN 0;
      ELSIF pestado = 2
      THEN                                              -- Actualmente Anulado
         SELECT fecsupl
           INTO v_fecsupl
           FROM his_sup_diferidosseg
          WHERE cmotmov = pcmotmov AND sseguro = psseguro AND estado = pestado;

         SELECT fcarpro
           INTO v_fcarpro
           FROM seguros
          WHERE sseguro = psseguro;

         -- El diferimiento ya no es vigente
         IF v_fecsupl < v_fcarpro
         THEN
            pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 2, 9001536);
            RETURN 0;
         END IF;

         INSERT INTO sup_diferidosseg
                     (cmotmov, sseguro, estado, fecsupl, fvalfun, cusuari,
                      falta, tvalord, fanula, nmovimi)
            SELECT cmotmov, sseguro, 0, fecsupl, fvalfun, cusuari, falta,
                   tvalord, NULL, nmovimi
              FROM his_sup_diferidosseg
             WHERE cmotmov = pcmotmov
               AND sseguro = psseguro
               AND estado = pestado;

         INSERT INTO sup_acciones_dif
                     (cmotmov, sseguro, norden, estado, dinaccion, ttable,
                      tcampo, twhere, taccion, naccion, vaccion, ttarifa)
            SELECT cmotmov, sseguro, norden, 0, dinaccion, ttable, tcampo,
                   twhere, taccion, naccion, vaccion, ttarifa
              FROM his_sup_acciones_dif
             WHERE cmotmov = pcmotmov
               AND sseguro = psseguro
               AND estado = pestado;

         DELETE      sup_acciones_dif
               WHERE cmotmov = pcmotmov
                 AND sseguro = psseguro
                 AND estado = pestado;

         DELETE      sup_diferidosseg
               WHERE cmotmov = pcmotmov
                 AND sseguro = psseguro
                 AND estado = pestado;
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
   END f_anular_abrir_diferido;

   /*************************************************************************
    Funcion para saber si un suplemento es incompatible
    param in psseguro : codigo del seguro
    param in pcmotmov : codigo del motivo del suplemento
    param out pcestado : estado del suplemento
    param out mensajes    : Mensajes
    retorno : 0 ok
              1 error

   -- Bug 116595 - 10/11/2009 - AMC
   *************************************************************************/
   FUNCTION f_supl_incompatible (
      psseguro   IN       NUMBER,
      pcmotmov   IN       NUMBER,
      pcestado   OUT      VARCHAR2,
      mensajes   OUT      t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (500)
                       := 'psseguro:' || psseguro || ' pcmotmov:' || pcmotmov;
      vobject    VARCHAR2 (200) := 'PAC_MD_SUPLEMENTOS.f_supl_incompatible';
      num_err    NUMBER;
   BEGIN
      IF psseguro IS NULL OR pcmotmov IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      num_err :=
             pk_suplementos.f_supl_incompatible (psseguro, pcmotmov, pcestado);

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
   END f_supl_incompatible;

   /*************************************************************************
    Funcion para buscar la fecha del suplemento de la configuracin indicada en las PDS
    param in psproduc : codigo del producto
    param in psseguro : codigo del seguro
    param in pcmotmov : codigo del motivo del suplemento
    param out pfefecto : fecha de efecto
    param out mensajes    : Mensajes
    retorno : 0 ok
              1 error

   -- Bug 116595 - 10/11/2009 - AMC
   *************************************************************************/
   FUNCTION f_get_fsupl_pds (
      psproduc   IN       NUMBER,
      psseguro   IN       NUMBER,
      pcmotmov   IN       NUMBER,
      pfefecto   OUT      DATE,
      mensajes   OUT      t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (500)
         :=    'psproduc:'
            || psproduc
            || ' psseguro:'
            || psseguro
            || ' pcmotmov:'
            || pcmotmov;
      vobject    VARCHAR2 (200) := 'PAC_MD_SUPLEMENTOS.f_get_fsupl_PDS';
      num_err    NUMBER;
   BEGIN
      IF psproduc IS NULL OR psseguro IS NULL OR pcmotmov IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      num_err :=
         pk_suplementos.f_get_fsupl_pds (psproduc,
                                         psseguro,
                                         pcmotmov,
                                         pfefecto
                                        );

      IF num_err <> 0
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 2, num_err);
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
   END f_get_fsupl_pds;

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
      mensajes         IN OUT   t_iax_mensajes,
      psseguro         IN       NUMBER DEFAULT NULL,
      ptablas          IN       VARCHAR2 DEFAULT NULL
   )
      RETURN NUMBER
   IS
      vpasexec    NUMBER (8)      := 1;
      vparam      VARCHAR2 (500)  := NULL;
      vobject     VARCHAR2 (200)  := 'PAC_MD_SUPLEMENTOS.f_get_suplementos';
      num_err     NUMBER;
      v_mostrar   NUMBER;
      squery      VARCHAR2 (3000);
   BEGIN
      vpasexec := 2;

      -- Inici Bug 23860 - 11/07/2013 - RCL
      IF psseguro IS NULL OR ptablas IS NULL
      THEN
         squery :=
               'SELECT p.tgrupdades, m.cmotmov,m.tmotmov, p.slitera'
            || ' FROM pds_supl_grup p, motmovseg m, pds_supl_config pp, pds_supl_cod_config pcc, pds_config_user pdu, productos pr, codiram cr '
            || ' WHERE p.cempres = pac_md_common.f_get_cxtempresa AND p.cmotmov = pp.cmotmov AND pcc.cconfig = pp.cconfig'
            || ' AND pdu.cuser = pac_md_common.f_get_cxtusuario AND pcc.cconsupl = pdu.cconsupl'
            || ' AND m.cidioma = pac_md_common.f_get_cxtidioma AND m.cmotmov = pp.cmotmov AND pp.sproduc ='
            || NVL (psproduc, 0)
            || ' AND pp.sproduc = pr.sproduc AND  pr.cramo = cr.cramo '
            || ' AND cr.cempres = pac_md_common.f_get_cxtempresa '
            || ' AND pp.cmodo = ''SUPLEMENTO'' ORDER BY p.tgrupdades, p.norden, p.cmotmov';
      ELSE
         squery :=
               'SELECT p.tgrupdades, m.cmotmov,m.tmotmov, p.slitera'
            || ' FROM pds_supl_grup p, motmovseg m, pds_supl_config pp, pds_supl_cod_config pcc, pds_config_user pdu, productos pr, codiram cr ';

         IF ptablas = 'EST'
         THEN
            squery := squery || ', ESTSEGUROS s ';
         ELSE
            squery := squery || ', SEGUROS s ';
         END IF;

         squery :=
               squery
            || ' WHERE p.cempres = pac_md_common.f_get_cxtempresa AND p.cmotmov = pp.cmotmov AND pcc.cconfig = pp.cconfig'
            || ' AND pdu.cuser = pac_md_common.f_get_cxtusuario AND pcc.cconsupl = pdu.cconsupl'
            || ' AND m.cidioma = pac_md_common.f_get_cxtidioma AND m.cmotmov = pp.cmotmov AND pp.sproduc ='
            || NVL (psproduc, 0)
            || ' AND pp.sproduc = pr.sproduc AND  pr.cramo = cr.cramo '
            || ' AND cr.cempres = pac_md_common.f_get_cxtempresa '
            || ' AND pp.cmodo = ''SUPLEMENTO'' '
            || ' AND s.sproduc = pp.sproduc '
            || ' AND s.sproduc = pr.sproduc '
            || ' AND s.sseguro = '
            || psseguro
            || ' AND ( '
            || '       ((pp.SUPLCOLEC IN (1, 3) OR pp.SUPLCOLEC IS NULL) AND s.ncertif = 0) '
            || '     OR  '
            || '       ((pp.SUPLCOLEC in (2,3) OR pp.SUPLCOLEC IS NULL) AND s.ncertif <> 0) '
            || ' )  '
            || 'ORDER BY p.tgrupdades, p.norden, p.cmotmov';
      END IF;

      -- Fi Bug 23860 - 11/07/2013 - RCL
      pcurconfigsupl := pac_iax_listvalores.f_opencursor (squery, mensajes);
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
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (500) := NULL;
      vobject    VARCHAR2 (200) := 'PAC_MD_SUPLEMENTOS.f_insdetmovseguro';
      vsseguro   NUMBER;
   BEGIN
      vpasexec := 2;

      BEGIN
         SELECT sseguro
           INTO vsseguro
           FROM estseguros
          WHERE ssegpol = psseguro;
      EXCEPTION
         WHEN OTHERS
         THEN
            NULL;
      END;

      INSERT INTO est_supdesc
                  (sseguro, nmovimi, cmotmov, nriesgo, cgarant, tvalor,
                   cpregun
                  )
           VALUES (vsseguro, pnmovimi + 1, pcmotmov, 1, 0, pdespues,
                   0
                  );

      RETURN 0;
   EXCEPTION
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
   END f_insdetmovseguro;

   FUNCTION f_traslado_vigencia (
      psseguro   IN       NUMBER,
      pcontrol   OUT      NUMBER,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (500) := NULL;
      vobject    VARCHAR2 (200) := 'PAC_MD_SUPLEMENTOS.f_traslado_vigencia';
      num_err    NUMBER;
      vcontrol   NUMBER;
      vnmovimi   NUMBER;
   BEGIN
      IF psseguro IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      SELECT MAX (nmovimi)
        INTO vnmovimi
        FROM movseguro
       WHERE sseguro = psseguro;

   
      SELECT COUNT (1)
        INTO vcontrol
        FROM detmovseguro
       WHERE sseguro = psseguro AND nmovimi = vnmovimi AND cmotmov = 674;

      pcontrol := vcontrol;

      IF vcontrol > 0
      THEN
         num_err := pk_suplementos.f_traslado_vigencia (psseguro);

         IF num_err <> 0
         THEN
            pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, num_err);
            RAISE e_object_error;
         END IF;
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
         RETURN num_err;
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
         RETURN 140999;
   END f_traslado_vigencia;

-- Bug 24278 - APD - 03/11/2012 - se crea la funcion
/*******************************************************************************
   Funcion que ejecuta los suplementos diferidos/automaticos programados para
   un colectivo para un movimiento determinado
   psseguro PARAM IN : Seguro
   pnmovimi PARAM IN : Movimiento del suplemento
   psproces PARAM OUT : Proceso generado.
********************************************************************************/
   FUNCTION f_ejecuta_supl_certifs (
      psseguro   IN       NUMBER,
      pnmovimi   IN       NUMBER,
      psproces   IN OUT   NUMBER,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vpasexec   NUMBER (8)       := 1;
      vparam     VARCHAR2 (10000)
         :=    'psseguro = '
            || psseguro
            || '; pnmovimi = '
            || pnmovimi
            || '; psproces = '
            || psproces;
      vobject    VARCHAR2 (200) := 'PAC_MD_SUPLEMENTOS.f_ejecuta_supl_certifs';
      num_err    NUMBER;
      vcontrol   NUMBER;
      vnmovimi   NUMBER;
   BEGIN
      IF psseguro IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      -- Si es el certificado 0
      IF pac_seguros.f_get_escertifcero (NULL, psseguro) = 1
      THEN
         num_err :=
            pac_sup_diferidos.f_ejecuta_supl_certifs (psseguro,
                                                      pnmovimi,
                                                      psproces
                                                     );

         IF num_err <> 0
         THEN
            pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, num_err);
            RAISE e_object_error;
         END IF;
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
      mensajes   IN OUT   t_iax_mensajes
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
                         := 'PAC_MD_SUPLEMENTOS.f_pregunta_propaga_suplemento';
      num_err    NUMBER;
   BEGIN
      IF psseguro IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      num_err :=
         pac_sup_diferidos.f_pregunta_propaga_suplemento
                                       (ptablas,
                                        psseguro,
                                        pnmovimi,
                                        pcmotmov,
                                        NVL (pcidioma,
                                             pac_md_common.f_get_cxtidioma ()
                                            ),
                                        opropaga,
                                        otexto
                                       );

      IF num_err <> 0
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, num_err);
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
      mensajes        IN OUT   t_iax_mensajes
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
                              := 'PAC_MD_SUPLEMENTOS.f_set_propaga_suplemento';
      num_err    NUMBER;
   BEGIN
      IF psseguro IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      num_err :=
         pac_sup_diferidos.f_set_propaga_suplemento (ptablas,
                                                     psseguro,
                                                     pnmovimi,
                                                     pcmotmov,
                                                     pcpropagasupl
                                                    );

      IF num_err <> 0
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, num_err);
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
   END f_set_propaga_suplemento;

     /*************************************************************************
    FUNCTION f_instexmovseguro
    param out mensajes    : Mensajes
    retorno : 0 ok
              1 error
   *************************************************************************/
   FUNCTION f_instexmovseguro (
      psseguro   IN       NUMBER,
      pnmovimi   IN       NUMBER,
      ptmovimi   IN       VARCHAR2,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (500) := NULL;
      vobject    VARCHAR2 (200) := 'PAC_MD_SUPLEMENTOS.f_instexmovseguro';
      vsseguro   NUMBER;
   BEGIN
      vpasexec := 2;

      INSERT INTO est_texmovseguro
                  (sseguro, nmovimi, tmovimi
                  )
           VALUES (psseguro, pnmovimi, ptmovimi
                  );

      RETURN 0;
   EXCEPTION
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
      pcmotmov   IN       VARCHAR2,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vpasexec    NUMBER (8)     := 1;
      vparam      VARCHAR2 (500) := NULL;
      vobject     VARCHAR2 (200) := 'PAC_MD_SUPLEMENTOS.f_ins_est_suspension';
      v_num_err   NUMBER;
   BEGIN
      vpasexec := 2;
      v_num_err :=
                  pac_suspension.f_set_mov_est (psseguro, pnmovimi, pcmotmov);

      IF v_num_err <> 0
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            v_num_err,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN 1;
      END IF;

      RETURN v_num_err;
   EXCEPTION
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
   END f_ins_est_suspension;

     /*************************************************************************
    FUNCTION f_get_existe_garantia
    param out mensajes    : Mensajes
    retorno : 0 ok
              1 error
   *************************************************************************/
   FUNCTION f_get_existe_garantia (
      psseguro   IN       NUMBER,
      pnriesgo   IN       NUMBER,
      pcgarant   IN       NUMBER,
      pnmovimi   IN       NUMBER,
      pmodo      IN       VARCHAR2,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vpasexec    NUMBER (8)     := 1;
      vparam      VARCHAR2 (500) := NULL;
      vobject     VARCHAR2 (200)
                                := 'PAC_MD_SUPLEMENTOS.f_get_existe_garantia';
      v_num_err   NUMBER;
      v_cont      NUMBER;
   BEGIN
      IF pmodo = 'EST'
      THEN
         SELECT COUNT (*)
           INTO v_cont
           FROM estgaranseg
          WHERE sseguro = psseguro
            AND nriesgo = pnriesgo
            AND cgarant = pcgarant
            AND nmovimi = pnmovimi
            AND cobliga = 1;
      ELSE
         SELECT COUNT (*)
           INTO v_cont
           FROM garanseg
          WHERE sseguro = psseguro
            AND nriesgo = pnriesgo
            AND cgarant = pcgarant
            AND nmovimi = pnmovimi;
      END IF;

      RETURN v_cont;
   EXCEPTION
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
         RETURN 0;
   END f_get_existe_garantia;

     /*************************************************************************
    FUNCTION f_get_nmovima_garantia
    param out mensajes    : Mensajes
    retorno : 0 ok
              1 error
   *************************************************************************/
   FUNCTION f_get_nmovima_garantia (
      psseguro   IN       NUMBER,
      pnriesgo   IN       NUMBER,
      pcgarant   IN       NUMBER,
      pnmovimi   IN       NUMBER,
      pmodo      IN       VARCHAR2,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vpasexec    NUMBER (8)                 := 1;
      vparam      VARCHAR2 (500)             := NULL;
      vobject     VARCHAR2 (200)
                               := 'PAC_MD_SUPLEMENTOS.f_get_nmovima_garantia';
      v_num_err   NUMBER;
      v_nmovima   estgaranseg.nmovima%TYPE;
   BEGIN
      IF pmodo = 'EST'
      THEN
         SELECT nmovima
           INTO v_nmovima
           FROM estgaranseg
          WHERE sseguro = psseguro
            AND nriesgo = pnriesgo
            AND cgarant = pcgarant
            AND nmovimi = pnmovimi
            AND cobliga = 1;
      ELSE
         SELECT nmovima
           INTO v_nmovima
           FROM garanseg
          WHERE sseguro = psseguro
            AND nriesgo = pnriesgo
            AND cgarant = pcgarant
            AND nmovimi = pnmovimi;
      END IF;

      RETURN v_nmovima;
   EXCEPTION
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
   END f_get_nmovima_garantia;

   /*************************************************************************
      Funcin que realiza el diferimiento de alta de garantias (237)

      param in ppoliza     : Objeto OB_IAX_DETPOLIZA de la seleccin
      param out mensajes   : Mensajes

      return              : 0 --> OK, <> 0 --> Error
   *************************************************************************/
   FUNCTION f_diferir_spl_alta_garan (
      poliza     IN       ob_iax_detpoliza,
      pfdifer    IN       VARCHAR2,
      mensajes   OUT      t_iax_mensajes
   )
      RETURN NUMBER
   IS
      v_count          NUMBER;
      v_difer          pds_supl_dif_config%ROWTYPE;
      v_fdifer         DATE;
      vpasexec         NUMBER (8)                        := 1;
      vparam           VARCHAR2 (500);
      vobject          VARCHAR2 (200)
                             := 'PAC_MD_SUPLEMENTOS.f_diferir_spl_alta_garan';
      -- 26/04/2009
      v_ries           t_iax_riesgos;
      v_gars           t_iax_garantias;
      v_garprod        t_iaxpar_garantias;
      v_accion         NUMBER                            := 1;
      -- 28/04/2009
      v_icapital       NUMBER;
      v_icaptot        NUMBER;
      v_primercop      NUMBER                            := 1;
      v_updatedif      VARCHAR2 (2000);
      v_ttabledif      sup_acciones_dif.ttable%TYPE;
      v_tcampodif      sup_acciones_dif.tcampo%TYPE;
      v_twheredif      sup_acciones_dif.twhere%TYPE;
      v_exclusion      NUMBER (1);
      v_dinaccion      sup_acciones_dif.dinaccion%TYPE;
      -- 05/05/2009
      v_tvalord        sup_diferidosseg.tvalord%TYPE     := '';
      v_cgarant        garanseg.cgarant%TYPE;
      v_primas         t_iax_primas;
      v_pdtocom        VARCHAR2 (100);
      v_irevali        VARCHAR2 (100);
      v_itarifa        VARCHAR2 (100);
      v_ipritot        VARCHAR2 (100);
      v_pdtotec        VARCHAR2 (100);
      v_preccom        VARCHAR2 (100);
      v_nfactor        VARCHAR2 (100);
      v_cfranq         VARCHAR2 (100);
      v_icaprecomend   VARCHAR2 (100);
      v_ipricom        VARCHAR2 (100);
      v_iextrap        VARCHAR2 (100);
   BEGIN
      IF poliza IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      v_ries := pac_iobj_prod.f_partpolriesgos (poliza, mensajes);
      v_primas := pac_iobj_prod.f_partpolprimas (poliza, mensajes);      --dct

      IF mensajes IS NOT NULL
      THEN
         IF mensajes.COUNT > 0
         THEN
            vpasexec := 1;
            RAISE e_object_error;
         END IF;
      END IF;

      IF v_ries IS NOT NULL
      THEN
         IF v_ries.COUNT > 0
         THEN
            FOR i IN v_ries.FIRST .. v_ries.LAST
            LOOP
               IF v_ries.EXISTS (i)
               THEN
                  v_garprod :=
                     pac_mdpar_productos.f_get_garantias
                                                     (poliza.sproduc,
                                                      poliza.gestion.cactivi,
                                                      v_ries (i).nriesgo,
                                                      /*bug 9916: ETM :16-06-09:--poliza.cactivi,*/
                                                      mensajes
                                                     );
                  v_gars :=
                      pac_iobj_prod.f_partriesgarantias (v_ries (i), mensajes);

                  FOR j IN v_gars.FIRST .. v_gars.LAST
                  LOOP
                     -- v_exclusion := 0;
                     vpasexec := 2;

                     IF v_gars.EXISTS (j)
                     THEN
                        FOR k IN v_garprod.FIRST .. v_garprod.LAST
                        LOOP
                           vpasexec := 3;

                           IF v_garprod.EXISTS (k)
                           THEN
---------------------------
-- Inclusin de garanta --
---------------------------
                              IF     v_garprod (k).cgarant =
                                                           v_gars (j).cgarant
                                 --AND v_garprod(k).ctipgar IN(1, 3)
                                 AND v_gars (j).cobliga = 1
                              THEN
                                 --IF v_gars(j).icapital IS NOT NULL THEN
                                 vpasexec := 4;

                                 BEGIN
                                    SELECT cgarant
                                      INTO v_cgarant
                                      FROM garanseg
                                     WHERE sseguro = poliza.ssegpol
                                       AND nriesgo = v_ries (i).nriesgo
                                       AND cgarant = v_gars (j).cgarant
                                       AND nmovimi =
                                              (SELECT MAX (g.nmovimi)
                                                 FROM garanseg g
                                                WHERE g.sseguro =
                                                              garanseg.sseguro
                                                  AND g.nriesgo =
                                                              garanseg.nriesgo
                                                  AND g.cgarant =
                                                              garanseg.cgarant);
                                 EXCEPTION
                                    WHEN NO_DATA_FOUND
                                    THEN
                                       v_cgarant := NULL;
                                 END;

                                 -- Miramos si no tenamos contratada antes el amparo
                                 IF     v_cgarant IS NULL
                                    AND v_gars (j).cgarant IS NOT NULL
                                 THEN
                                    BEGIN
                                       SELECT *
                                         INTO v_difer
                                         FROM pds_supl_dif_config
                                        WHERE cmotmov = 237
                                          AND (   sproduc = poliza.sproduc
                                               OR sproduc = 0
                                              );
                                    EXCEPTION
                                       WHEN NO_DATA_FOUND
                                       THEN
                                          RETURN 9001505;
                                    END;

                                    -- De momento lo haremos as aunque esta fecha nos vendra de pantalla
                                    -- (se ir a buscar tambin a PDS_SUPL_DIF_CONFIG)
                                    vpasexec := 5;
                                    --v_fdifer := PAC_MD_SUPLEMENTOS.f_fecha_diferido(v_difer.tfecrec, poliza.ssegpol);
                                    v_fdifer :=
                                       pac_md_suplementos.f_fecha_diferido
                                                               (pfdifer,
                                                                poliza.ssegpol
                                                               );
                                    vpasexec := 6;

                                    BEGIN
                                       INSERT INTO sup_diferidosseg
                                                   (cmotmov, sseguro,
                                                    fecsupl,
                                                    fvalfun, estado,
                                                    cusuari, falta
                                                   )
                                            VALUES (237, poliza.ssegpol,
                                                    v_fdifer,
                                                    v_difer.fvalfun, 0,
                                                    f_user, f_sysdate
                                                   );
                                    EXCEPTION
                                       WHEN DUP_VAL_ON_INDEX
                                       THEN
                                          -- DUDA: Si difieres primero una modificacin de garanta
                                          -- y luego pretendes diferir una exclusin de garanta
                                          -- da casque por que ya existe un movimiento 281 programado.
                                          -- Reestructurar este diferimiento dara un poco de problema
                                          -- pero se podra hacer que el diferimiento de exclusin se
                                          -- anadiera al diferimiento existente. De momento lo dejamos
                                          -- as (comentado) y no se permitir diferir exclusin si antes
                                          -- existe una modificacin de garantas.

                                          --BEGIN
                                          --    SELECT dinaccion
                                          --    INTO v_dinaccion
                                          --    FROM SUP_ACCIONES_DIF
                                          --    WHERE cmotmov = 281
                                          --      AND sseguro = poliza.ssegpol
                                          --      AND dinaccion = 'D';
                                          --EXCEPTION
                                          --  WHEN NO_DATA_FOUND THEN
                                          --      NULL;
                                          --END;

                                          -- cmotmov = 281 + v_dinaccion = 'D'
                                          --         ==> Exclusin de garantia
                                          --IF v_primercop = 1 AND v_dinaccion = 'D' THEN
                                          IF v_primercop = 1
                                          THEN
                                             RETURN 9001506;
                                          END IF;
                                       WHEN OTHERS
                                       THEN
                                          RAISE e_object_error;
                                    END;

                                    v_primercop := 0;
                                    -- Accion 1 --
                                    vpasexec := 7;
                                    v_updatedif :=
                                          'UPDATE ESTGARANSEG SET ICAPITAL = '
                                       || TRANSLATE
                                                 (TO_CHAR (v_gars (j).icapital),
                                                  ',',
                                                  '.'
                                                 )
                                       || ', COBLIGA = 1'
                                       || ' WHERE SSEGURO = :SSEGURO AND NRIESGO = '
                                       || v_ries (i).nriesgo
                                       || ' AND CGARANT = '
                                       || v_gars (j).cgarant
                                       || ' AND NMOVIMI = :NMOVIMI';
                                    vpasexec := 8;
                                    v_ttabledif := 'ESTGARANSEG';
                                    v_tcampodif := 'ICAPITAL';
                                    v_twheredif :=
                                          'SSEGURO = :SSEGURO AND NRIESGO = '
                                       || v_ries (i).nriesgo
                                       || ' AND CGARANT = '
                                       || v_gars (j).cgarant
                                       || ' AND NMOVIMI = '
                                       || ':NMOVIMI';
                                    -- Descripccin del suplemento
                                    v_tvalord :=
                                          v_tvalord
                                       || f_axis_literales
                                             (9900939,
                                              pac_md_common.f_get_cxtidioma
                                             )               --Alta de amparos
                                       || ' - '
                                       || f_axis_literales
                                                (100561,
                                                 pac_md_common.f_get_cxtidioma
                                                )
                                       || ': '
                                       || v_gars (j).cgarant
                                       || ', '
                                       || f_axis_literales
                                                (100649,
                                                 pac_md_common.f_get_cxtidioma
                                                )
                                       || ': '
                                       || v_ries (i).nriesgo
                                       || CHR (10);
                                    vpasexec := 9;

                                    BEGIN
                                       INSERT INTO sup_acciones_dif
                                                   (cmotmov, sseguro,
                                                    norden, estado,
                                                    dinaccion, ttable,
                                                    tcampo,
                                                    twhere,
                                                    taccion,
                                                    naccion,
                                                    vaccion, ttarifa
                                                   )
                                            VALUES (237, poliza.ssegpol,
                                                    v_accion, 0,
                                                    'U', v_ttabledif,
                                                    v_tcampodif,
                                                    v_twheredif,
                                                    v_updatedif,
                                                    v_gars (j).icapital,
                                                    NULL, 0
                                                   );
                                    EXCEPTION
                                       WHEN DUP_VAL_ON_INDEX
                                       THEN
                                          RETURN 9001506;
                                       WHEN OTHERS
                                       THEN
                                          RAISE e_object_error;
                                    END;

                                    v_accion := v_accion + 1;
                                      --v_exclusion := 1;
                                 --  END IF;
                                 END IF;
                              -- Miramos si notenamos contratada antes el amparo
                              END IF;
                           END IF;
                        END LOOP;
                     END IF;
                  END LOOP;
               END IF;
            END LOOP;
         END IF;
      END IF;

      -- Actualizamos el literal del descripccin
      UPDATE sup_diferidosseg
         SET tvalord = v_tvalord
       WHERE cmotmov = 237 AND sseguro = poliza.ssegpol AND estado = 0;

      -- Actualizamos para tarifar tras el ltimo movimiento
      UPDATE sup_acciones_dif
         SET ttarifa = 1
       WHERE cmotmov = 237
         AND sseguro = poliza.ssegpol
         AND norden = (v_accion - 1);

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
         RETURN -1;
      WHEN e_object_error
      THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN -1;
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
         RETURN -1;
   END f_diferir_spl_alta_garan;

   /*************************************************************************
      Funcin que realiza el diferimiento de modificacin de garantias.

      param in ppoliza     : Objeto OB_IAX_DETPOLIZA de la seleccin
      param out mensajes   : Mensajes

      return              : 0 --> OK, <> 0 --> Error
   *************************************************************************/
   -- Bug 9905 - 24/04/2009 - RSC - Suplemento de cambio de forma de pago diferido
   FUNCTION f_diferir_spl_baja_garan (
      poliza     IN       ob_iax_detpoliza,
      pfdifer    IN       VARCHAR2,
      mensajes   OUT      t_iax_mensajes
   )
      RETURN NUMBER
   IS
      v_count       NUMBER;
      v_difer       pds_supl_dif_config%ROWTYPE;
      v_fdifer      DATE;
      vpasexec      NUMBER (8)                        := 1;
      vparam        VARCHAR2 (500);
      vobject       VARCHAR2 (200)
                             := 'PAC_MD_SUPLEMENTOS.f_diferir_spl_baja_garan';
      -- 26/04/2009
      v_ries        t_iax_riesgos;
      v_gars        t_iax_garantias;
      v_garprod     t_iaxpar_garantias;
      v_accion      NUMBER                            := 1;
      -- 28/04/2009
      v_icapital    NUMBER;
      v_icaptot     NUMBER;
      v_primercop   NUMBER                            := 1;
      v_updatedif   VARCHAR2 (2000);
      v_ttabledif   sup_acciones_dif.ttable%TYPE;
      v_tcampodif   sup_acciones_dif.tcampo%TYPE;
      v_twheredif   sup_acciones_dif.twhere%TYPE;
      v_exclusion   NUMBER (1);
      v_dinaccion   sup_acciones_dif.dinaccion%TYPE;
      -- 05/05/2009
      v_tvalord     sup_diferidosseg.tvalord%TYPE     := '';
      v_cgarant     garanseg.cgarant%TYPE;
   BEGIN
      IF poliza IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      v_ries := pac_iobj_prod.f_partpolriesgos (poliza, mensajes);

      IF mensajes IS NOT NULL
      THEN
         IF mensajes.COUNT > 0
         THEN
            vpasexec := 1;
            RAISE e_object_error;
         END IF;
      END IF;

      IF v_ries IS NOT NULL
      THEN
         IF v_ries.COUNT > 0
         THEN
            FOR i IN v_ries.FIRST .. v_ries.LAST
            LOOP
               IF v_ries.EXISTS (i)
               THEN
                  v_garprod :=
                     pac_mdpar_productos.f_get_garantias
                                                     (poliza.sproduc,
                                                      poliza.gestion.cactivi,
                                                      v_ries (i).nriesgo,
                                                      /*bug 9916: ETM :16-06-09:--poliza.cactivi,*/
                                                      mensajes
                                                     );
                  v_gars :=
                      pac_iobj_prod.f_partriesgarantias (v_ries (i), mensajes);

                  FOR j IN v_gars.FIRST .. v_gars.LAST
                  LOOP
                     v_exclusion := 0;
                     vpasexec := 2;

                     IF v_gars.EXISTS (j)
                     THEN
                        FOR k IN v_garprod.FIRST .. v_garprod.LAST
                        LOOP
                           vpasexec := 3;

                           IF v_garprod.EXISTS (k)
                           THEN
---------------------------
-- Exclusin de garanta --
---------------------------
                              IF     v_garprod (k).cgarant =
                                                           v_gars (j).cgarant
                                 AND v_garprod (k).ctipgar IN (1, 3)
                                 AND v_gars (j).cobliga = 0
                              THEN
                                 --IF v_gars(j).icapital IS NOT NULL THEN
                                 vpasexec := 4;

                                 BEGIN
                                    SELECT cgarant
                                      INTO v_cgarant
                                      FROM garanseg
                                     WHERE sseguro = poliza.ssegpol
                                       AND nriesgo = v_ries (i).nriesgo
                                       AND cgarant = v_gars (j).cgarant
                                       AND nmovimi =
                                              (SELECT MAX (g.nmovimi)
                                                 FROM garanseg g
                                                WHERE g.sseguro =
                                                              garanseg.sseguro
                                                  AND g.nriesgo =
                                                              garanseg.nriesgo
                                                  AND g.cgarant =
                                                              garanseg.cgarant);
                                 EXCEPTION
                                    WHEN NO_DATA_FOUND
                                    THEN
                                       v_cgarant := NULL;
                                 END;

                                 -- Miramos si tenamos contratada antes el amparo
                                 IF     v_cgarant IS NOT NULL
                                    AND v_cgarant = v_gars (j).cgarant
                                 THEN
                                    BEGIN
                                       SELECT *
                                         INTO v_difer
                                         FROM pds_supl_dif_config
                                        WHERE cmotmov = 239
                                          AND (   sproduc = poliza.sproduc
                                               OR sproduc = 0
                                              );
                                    EXCEPTION
                                       WHEN NO_DATA_FOUND
                                       THEN
                                          RETURN 9001505;
                                    END;

                                    -- De momento lo haremos as aunque esta fecha nos vendra de pantalla
                                    -- (se ir a buscar tambin a PDS_SUPL_DIF_CONFIG)
                                    vpasexec := 5;
                                    --v_fdifer := PAC_MD_SUPLEMENTOS.f_fecha_diferido(v_difer.tfecrec, poliza.ssegpol);
                                    v_fdifer :=
                                       pac_md_suplementos.f_fecha_diferido
                                                               (pfdifer,
                                                                poliza.ssegpol
                                                               );
                                    vpasexec := 6;

                                    BEGIN
                                       INSERT INTO sup_diferidosseg
                                                   (cmotmov, sseguro,
                                                    fecsupl,
                                                    fvalfun, estado,
                                                    cusuari, falta
                                                   )
                                            VALUES (239, poliza.ssegpol,
                                                    v_fdifer,
                                                    v_difer.fvalfun, 0,
                                                    f_user, f_sysdate
                                                   );
                                    EXCEPTION
                                       WHEN DUP_VAL_ON_INDEX
                                       THEN
                                          -- DUDA: Si difieres primero una modificacin de garanta
                                          -- y luego pretendes diferir una exclusin de garanta
                                          -- da casque por que ya existe un movimiento 281 programado.
                                          -- Reestructurar este diferimiento dara un poco de problema
                                          -- pero se podra hacer que el diferimiento de exclusin se
                                          -- anadiera al diferimiento existente. De momento lo dejamos
                                          -- as (comentado) y no se permitir diferir exclusin si antes
                                          -- existe una modificacin de garantas.

                                          --BEGIN
                                          --    SELECT dinaccion
                                          --    INTO v_dinaccion
                                          --    FROM SUP_ACCIONES_DIF
                                          --    WHERE cmotmov = 281
                                          --      AND sseguro = poliza.ssegpol
                                          --      AND dinaccion = 'D';
                                          --EXCEPTION
                                          --  WHEN NO_DATA_FOUND THEN
                                          --      NULL;
                                          --END;

                                          -- cmotmov = 281 + v_dinaccion = 'D'
                                          --         ==> Exclusin de garantia
                                          --IF v_primercop = 1 AND v_dinaccion = 'D' THEN
                                          IF v_primercop = 1
                                          THEN
                                             RETURN 9001506;
                                          END IF;
                                       WHEN OTHERS
                                       THEN
                                          RAISE e_object_error;
                                    END;

                                    v_primercop := 0;
                                    -- Accion 1 --
                                    vpasexec := 7;
                                    v_updatedif :=
                                          'DELETE ESTGARANSEG'
                                       || ' WHERE SSEGURO = :SSEGURO AND NRIESGO = '
                                       || v_ries (i).nriesgo
                                       || ' AND CGARANT = '
                                       || v_gars (j).cgarant;
                                    --|| ' AND NMOVIMI = :NMOVIMI';
                                    v_ttabledif := 'ESTGARANSEG';
                                    v_tcampodif := 'FFINEFE';
                                    v_twheredif :=
                                          'SSEGURO = :SSEGURO AND NRIESGO = '
                                       || v_ries (i).nriesgo
                                       || ' AND CGARANT = '
                                       || v_gars (j).cgarant;
                                       --|| ' AND NMOVIMI = :NMOVIMI';
                                    -- Descripccin del suplemento
                                    v_tvalord :=
                                          v_tvalord
                                       || f_axis_literales
                                                (9001533,
                                                 pac_md_common.f_get_cxtidioma
                                                )
                                       || ' - '
                                       || f_axis_literales
                                                (100561,
                                                 pac_md_common.f_get_cxtidioma
                                                )
                                       || ': '
                                       || v_gars (j).cgarant
                                       || ', '
                                       || f_axis_literales
                                                (100649,
                                                 pac_md_common.f_get_cxtidioma
                                                )
                                       || ': '
                                       || v_ries (i).nriesgo
                                       || CHR (10);
                                    vpasexec := 8;

                                    BEGIN
                                       INSERT INTO sup_acciones_dif
                                                   (cmotmov, sseguro,
                                                    norden, estado,
                                                    dinaccion, ttable,
                                                    tcampo,
                                                    twhere,
                                                    taccion,
                                                    naccion,
                                                    vaccion, ttarifa
                                                   )
                                            VALUES (239, poliza.ssegpol,
                                                    v_accion, 0,
                                                    'D', v_ttabledif,
                                                    v_tcampodif,
                                                    v_twheredif,
                                                    v_updatedif,
                                                    v_gars (j).icapital,
                                                    NULL, 0
                                                   );
                                    EXCEPTION
                                       WHEN DUP_VAL_ON_INDEX
                                       THEN
                                          RETURN 9001506;
                                       WHEN OTHERS
                                       THEN
                                          RAISE e_object_error;
                                    END;

                                    v_accion := v_accion + 1;
                                    v_exclusion := 1;
                                 --  END IF;
                                 END IF;
                              -- Miramos si tenamos contratad0 antes el amparo
                              END IF;
                           END IF;
                        END LOOP;
                     END IF;
                  END LOOP;
               END IF;
            END LOOP;
         END IF;
      END IF;

      -- Actualizamos el literal del descripccin
      UPDATE sup_diferidosseg
         SET tvalord = v_tvalord
       WHERE cmotmov = 239 AND sseguro = poliza.ssegpol AND estado = 0;

      -- Actualizamos para tarifar tras el ltimo movimiento
      UPDATE sup_acciones_dif
         SET ttarifa = 1
       WHERE cmotmov = 239
         AND sseguro = poliza.ssegpol
         AND norden = (v_accion - 1);

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
         RETURN -1;
      WHEN e_object_error
      THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN -1;
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
         RETURN -1;
   END f_diferir_spl_baja_garan;

   /*************************************************************************
      Funcin que realiza el diferimiento de modificacin de garantias.

      param in ppoliza     : Objeto OB_IAX_DETPOLIZA de la seleccin
      param out mensajes   : Mensajes

      return              : 0 --> OK, <> 0 --> Error
   *************************************************************************/
   FUNCTION f_diferir_spl_aumento_cap (
      poliza     IN       ob_iax_detpoliza,
      pfdifer    IN       VARCHAR2,
      mensajes   OUT      t_iax_mensajes
   )
      RETURN NUMBER
   IS
      v_count       NUMBER;
      v_difer       pds_supl_dif_config%ROWTYPE;
      v_fdifer      DATE;
      vpasexec      NUMBER (8)                        := 1;
      vparam        VARCHAR2 (500);
      vobject       VARCHAR2 (200)
                            := 'PAC_MD_SUPLEMENTOS.f_diferir_spl_aumento_cap';
      -- 26/04/2009
      v_ries        t_iax_riesgos;
      v_gars        t_iax_garantias;
      v_garprod     t_iaxpar_garantias;
      v_accion      NUMBER                            := 1;
      -- 28/04/2009
      v_icapital    NUMBER;
      v_icaptot     NUMBER;
      v_primercop   NUMBER                            := 1;
      v_updatedif   VARCHAR2 (2000);
      v_ttabledif   sup_acciones_dif.ttable%TYPE;
      v_tcampodif   sup_acciones_dif.tcampo%TYPE;
      v_twheredif   sup_acciones_dif.twhere%TYPE;
      v_exclusion   NUMBER (1);
      v_dinaccion   sup_acciones_dif.dinaccion%TYPE;
      -- 05/05/2009
      v_tvalord     sup_diferidosseg.tvalord%TYPE     := '';
      v_tratar      NUMBER                            := 1;
   BEGIN
      IF poliza IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      v_ries := pac_iobj_prod.f_partpolriesgos (poliza, mensajes);

      IF mensajes IS NOT NULL
      THEN
         IF mensajes.COUNT > 0
         THEN
            vpasexec := 1;
            RAISE e_object_error;
         END IF;
      END IF;

      IF v_ries IS NOT NULL
      THEN
         IF v_ries.COUNT > 0
         THEN
            FOR i IN v_ries.FIRST .. v_ries.LAST
            LOOP
               IF v_ries.EXISTS (i)
               THEN
                  v_garprod :=
                     pac_mdpar_productos.f_get_garantias
                                                     (poliza.sproduc,
                                                      poliza.gestion.cactivi,
                                                      v_ries (i).nriesgo,
                                                      /*bug 9916: ETM :16-06-09:--poliza.cactivi,*/
                                                      mensajes
                                                     );
                  v_gars :=
                      pac_iobj_prod.f_partriesgarantias (v_ries (i), mensajes);

                  FOR j IN v_gars.FIRST .. v_gars.LAST
                  LOOP
                     v_exclusion := 0;
                     vpasexec := 2;

                     IF v_gars.EXISTS (j)
                     THEN
                        FOR k IN v_garprod.FIRST .. v_garprod.LAST
                        LOOP
                           vpasexec := 3;

                           IF v_garprod.EXISTS (k)
                           THEN
---------------------------
-- Exclusin de garanta --
---------------------------

                              ---------------------------
-- Inclusin de garanta --
---------------------------
-- NULL;

                              -------------------------------
-- Modificacin de garantas --
-------------------------------
                              IF     v_garprod (k).cgarant =
                                                           v_gars (j).cgarant
                                 AND v_garprod (k).ctipcap IN (2, 6)
                                 AND v_exclusion = 0
                              THEN
                                 --v_garprod(k).ctipcap NOT IN (1,3,4,5) THEN
                                 IF v_gars (j).icapital IS NOT NULL
                                 THEN
                                    BEGIN
                                       SELECT icapital, icaptot
                                         INTO v_icapital, v_icaptot
                                         FROM garanseg
                                        WHERE sseguro = poliza.ssegpol
                                          AND nriesgo = v_ries (i).nriesgo
                                          AND cgarant = v_gars (j).cgarant
                                          AND nmovimi =
                                                 (SELECT MAX (g.nmovimi)
                                                    FROM garanseg g
                                                   WHERE g.sseguro =
                                                              garanseg.sseguro
                                                     AND g.nriesgo =
                                                              garanseg.nriesgo
                                                     AND g.cgarant =
                                                              garanseg.cgarant);
                                    EXCEPTION
                                       WHEN NO_DATA_FOUND
                                       THEN
                                          --No es un aumento de capital ya que no existia el amparo antes.
                                          --No lo tratamos como un aumento de capital
                                          v_tratar := 0;
                                    END;

                                    IF    (    v_gars (j).icapital <>
                                                                    v_icapital
                                           AND v_gars (j).icapital >
                                                                    v_icapital
                                          )
                                       OR     (    v_gars (j).icaptot <>
                                                                     v_icaptot
                                               AND v_gars (j).icaptot >
                                                                     v_icaptot
                                              )
                                          AND v_tratar = 1
                                    THEN
                                       vpasexec := 4;

                                       BEGIN
                                          SELECT *
                                            INTO v_difer
                                            FROM pds_supl_dif_config
                                           WHERE cmotmov = 355
                                             AND (   sproduc = poliza.sproduc
                                                  OR sproduc = 0
                                                 );
                                       EXCEPTION
                                          WHEN NO_DATA_FOUND
                                          THEN
                                             RETURN 9001505;
                                       END;

                                       -- De momento lo haremos as aunque esta fecha nos vendra de pantalla
                                       -- (se ir a buscar tambin a PDS_SUPL_DIF_CONFIG)
                                       vpasexec := 5;
                                       --v_fdifer := PAC_MD_SUPLEMENTOS.f_fecha_diferido(v_difer.tfecrec, poliza.ssegpol);
                                       v_fdifer :=
                                          pac_md_suplementos.f_fecha_diferido
                                                               (pfdifer,
                                                                poliza.ssegpol
                                                               );
                                       vpasexec := 6;

                                       BEGIN
                                          INSERT INTO sup_diferidosseg
                                                      (cmotmov, sseguro,
                                                       fecsupl,
                                                       fvalfun, estado,
                                                       cusuari, falta
                                                      )
                                               VALUES (355, poliza.ssegpol,
                                                       v_fdifer,
                                                       v_difer.fvalfun, 0,
                                                       f_user, f_sysdate
                                                      );
                                       EXCEPTION
                                          WHEN DUP_VAL_ON_INDEX
                                          THEN
                                             --BEGIN
                                             --    SELECT dinaccion
                                             --    INTO v_dinaccion
                                             --    FROM SUP_ACCIONES_DIF
                                             --    WHERE cmotmov = 281
                                             --      AND sseguro = poliza.ssegpol
                                             --      AND dinaccion = 'D';
                                             --EXCEPTION
                                             --  WHEN NO_DATA_FOUND THEN
                                             --      NULL;
                                             --END;

                                             -- cmotmov = 281 + v_dinaccion = 'U'
                                             --         ==> Modificacin de garanta
                                             --IF v_primercop = 1 AND v_dinaccion = 'U' THEN
                                             IF v_primercop = 1
                                             THEN
                                                RETURN 9001506;
                                             END IF;
                                          WHEN OTHERS
                                          THEN
                                             RAISE e_object_error;
                                       END;

                                       -- Posem control a 0 (si se inserta mas de una vez
                                       -- en SUP_DIFERIDOSSEG aqui dentro dejamos continuar).
                                       -- La primera vez si casca el INSERT si que se debe avisar.
                                       v_primercop := 0;
                                       -- Accion 1 --
                                       vpasexec := 7;
                                       v_updatedif :=
                                             'UPDATE ESTGARANSEG SET ICAPITAL = '
                                          || TRANSLATE
                                                 (TO_CHAR (v_gars (j).icapital),
                                                  ',',
                                                  '.'
                                                 )
                                          || ' WHERE SSEGURO = :SSEGURO AND NRIESGO = '
                                          || v_ries (i).nriesgo
                                          || ' AND CGARANT = '
                                          || v_gars (j).cgarant;
                                       -- || ' AND NMOVIMI = :NMOVIMI';
                                       v_ttabledif := 'ESTGARANSEG';
                                       v_tcampodif := 'ICAPITAL';
                                       v_twheredif :=
                                             'SSEGURO = :SSEGURO AND NRIESGO = '
                                          || v_ries (i).nriesgo
                                          || ' AND CGARANT = '
                                          || v_gars (j).cgarant;
                                       --|| ' AND NMOVIMI = :NMOVIMI';
                                       v_tvalord :=
                                             v_tvalord
                                          || ff_desgarantia
                                                (v_gars (j).cgarant,
                                                 pac_md_common.f_get_cxtidioma
                                                )
                                          || ':'
                                          || v_gars (j).icapital;
                                       vpasexec := 8;

                                       BEGIN
                                          INSERT INTO sup_acciones_dif
                                                      (cmotmov, sseguro,
                                                       norden, estado,
                                                       dinaccion, ttable,
                                                       tcampo,
                                                       twhere,
                                                       taccion,
                                                       naccion,
                                                       vaccion, ttarifa
                                                      )
                                               VALUES (355, poliza.ssegpol,
                                                       v_accion, 0,
                                                       'U', v_ttabledif,
                                                       v_tcampodif,
                                                       v_twheredif,
                                                       v_updatedif,
                                                       v_gars (j).icapital,
                                                       NULL, 0
                                                      );
                                       EXCEPTION
                                          WHEN DUP_VAL_ON_INDEX
                                          THEN
                                             RETURN 9001506;
                                          WHEN OTHERS
                                          THEN
                                             RAISE e_object_error;
                                       END;

                                       v_accion := v_accion + 1;
                                       -- Accion 2 --
                                       vpasexec := 9;
                                       v_updatedif :=
                                             'UPDATE ESTGARANSEG SET ICAPTOT = '
                                          || TRANSLATE
                                                 (TO_CHAR (v_gars (j).icapital),
                                                  ',',
                                                  '.'
                                                 )
                                          || ' WHERE SSEGURO = :SSEGURO AND NRIESGO = '
                                          || v_ries (i).nriesgo
                                          || ' AND CGARANT = '
                                          || v_gars (j).cgarant;
                                       -- || ' AND NMOVIMI = :NMOVIMI';
                                       v_ttabledif := 'ESTGARANSEG';
                                       v_tcampodif := 'ICAPTOT';
                                       v_twheredif :=
                                             'SSEGURO = :SSEGURO AND NRIESGO = '
                                          || v_ries (i).nriesgo
                                          || ' AND CGARANT = '
                                          || v_gars (j).cgarant;
                                       -- || ' AND NMOVIMI = :NMOVIMI';
                                       vpasexec := 10;

                                       BEGIN
                                          INSERT INTO sup_acciones_dif
                                                      (cmotmov, sseguro,
                                                       norden, estado,
                                                       dinaccion, ttable,
                                                       tcampo,
                                                       twhere,
                                                       taccion,
                                                       naccion,
                                                       vaccion, ttarifa
                                                      )
                                               VALUES (355, poliza.ssegpol,
                                                       v_accion, 0,
                                                       'U', v_ttabledif,
                                                       v_tcampodif,
                                                       v_twheredif,
                                                       v_updatedif,
                                                       v_gars (j).icapital,
                                                       NULL, 0
                                                      );
                                       EXCEPTION
                                          WHEN DUP_VAL_ON_INDEX
                                          THEN
                                             RETURN 9001506;
                                          WHEN OTHERS
                                          THEN
                                             RAISE e_object_error;
                                       END;

                                       v_accion := v_accion + 1;
                                    END IF;
                                 END IF;
                              END IF;
                           END IF;
                        END LOOP;
                     END IF;
                  END LOOP;
               END IF;
            END LOOP;
         END IF;
      END IF;

      -- Actualizamos el literal del descripccin
      UPDATE sup_diferidosseg
         SET tvalord = v_tvalord
       WHERE cmotmov = 355 AND sseguro = poliza.ssegpol AND estado = 0;

      -- Actualizamos para tarifar tras el ltimo movimiento
      UPDATE sup_acciones_dif
         SET ttarifa = 1
       WHERE cmotmov = 355
         AND sseguro = poliza.ssegpol
         AND norden = (v_accion - 1);

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
         RETURN -1;
      WHEN e_object_error
      THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN -1;
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
         RETURN -1;
   END f_diferir_spl_aumento_cap;

   /*************************************************************************
      Funcin que realiza el diferimiento de modificacin de garantias.

      param in ppoliza     : Objeto OB_IAX_DETPOLIZA de la seleccin
      param out mensajes   : Mensajes

      return              : 0 --> OK, <> 0 --> Error
   *************************************************************************/
   FUNCTION f_diferir_spl_disminucion_cap (
      poliza     IN       ob_iax_detpoliza,
      pfdifer    IN       VARCHAR2,
      mensajes   OUT      t_iax_mensajes
   )
      RETURN NUMBER
   IS
      v_count       NUMBER;
      v_difer       pds_supl_dif_config%ROWTYPE;
      v_fdifer      DATE;
      vpasexec      NUMBER (8)                        := 1;
      vparam        VARCHAR2 (500);
      vobject       VARCHAR2 (200)
                        := 'PAC_MD_SUPLEMENTOS.f_diferir_spl_disminucion_cap';
      -- 26/04/2009
      v_ries        t_iax_riesgos;
      v_gars        t_iax_garantias;
      v_garprod     t_iaxpar_garantias;
      v_accion      NUMBER                            := 1;
      -- 28/04/2009
      v_icapital    NUMBER;
      v_icaptot     NUMBER;
      v_primercop   NUMBER                            := 1;
      v_updatedif   VARCHAR2 (2000);
      v_ttabledif   sup_acciones_dif.ttable%TYPE;
      v_tcampodif   sup_acciones_dif.tcampo%TYPE;
      v_twheredif   sup_acciones_dif.twhere%TYPE;
      v_exclusion   NUMBER (1);
      v_dinaccion   sup_acciones_dif.dinaccion%TYPE;
      -- 05/05/2009
      v_tvalord     sup_diferidosseg.tvalord%TYPE     := '';
      v_tratar      NUMBER                            := 1;
   BEGIN
      IF poliza IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      v_ries := pac_iobj_prod.f_partpolriesgos (poliza, mensajes);

      IF mensajes IS NOT NULL
      THEN
         IF mensajes.COUNT > 0
         THEN
            vpasexec := 1;
            RAISE e_object_error;
         END IF;
      END IF;

      IF v_ries IS NOT NULL
      THEN
         IF v_ries.COUNT > 0
         THEN
            FOR i IN v_ries.FIRST .. v_ries.LAST
            LOOP
               IF v_ries.EXISTS (i)
               THEN
                  v_garprod :=
                     pac_mdpar_productos.f_get_garantias
                                                     (poliza.sproduc,
                                                      poliza.gestion.cactivi,
                                                      v_ries (i).nriesgo,
                                                      /*bug 9916: ETM :16-06-09:--poliza.cactivi,*/
                                                      mensajes
                                                     );
                  v_gars :=
                      pac_iobj_prod.f_partriesgarantias (v_ries (i), mensajes);

                  FOR j IN v_gars.FIRST .. v_gars.LAST
                  LOOP
                     v_exclusion := 0;
                     vpasexec := 2;

                     IF v_gars.EXISTS (j)
                     THEN
                        FOR k IN v_garprod.FIRST .. v_garprod.LAST
                        LOOP
                           vpasexec := 3;

                           IF v_garprod.EXISTS (k)
                           THEN
---------------------------
-- Exclusin de garanta --
---------------------------

                              ---------------------------
-- Inclusin de garanta --
---------------------------
-- NULL;

                              -------------------------------
-- Modificacin de garantas --
-------------------------------
                              IF     v_garprod (k).cgarant =
                                                           v_gars (j).cgarant
                                 AND v_garprod (k).ctipcap IN (2, 6)
                                 AND v_exclusion = 0
                              THEN
                                 --v_garprod(k).ctipcap NOT IN (1,3,4,5) THEN
                                 IF v_gars (j).icapital IS NOT NULL
                                 THEN
                                    BEGIN
                                       SELECT icapital, icaptot
                                         INTO v_icapital, v_icaptot
                                         FROM garanseg
                                        WHERE sseguro = poliza.ssegpol
                                          AND nriesgo = v_ries (i).nriesgo
                                          AND cgarant = v_gars (j).cgarant
                                          AND nmovimi =
                                                 (SELECT MAX (g.nmovimi)
                                                    FROM garanseg g
                                                   WHERE g.sseguro =
                                                              garanseg.sseguro
                                                     AND g.nriesgo =
                                                              garanseg.nriesgo
                                                     AND g.cgarant =
                                                              garanseg.cgarant);
                                    EXCEPTION
                                       WHEN NO_DATA_FOUND
                                       THEN
                                          --No es una disminucin de capital ya que no existia el amparo antes.
                                          --No lo tratamos como una disminucin de capital
                                          v_tratar := 0;
                                    END;

                                    IF     (   (    v_gars (j).icapital <>
                                                                    v_icapital
                                                AND v_gars (j).icapital <
                                                                    v_icapital
                                               )
                                            OR (    v_gars (j).icaptot <>
                                                                     v_icaptot
                                                AND v_gars (j).icaptot <
                                                                     v_icaptot
                                               )
                                           )
                                       AND v_tratar = 1
                                    THEN
                                       vpasexec := 4;

                                       BEGIN
                                          SELECT *
                                            INTO v_difer
                                            FROM pds_supl_dif_config
                                           WHERE cmotmov = 356
                                             AND (   sproduc = poliza.sproduc
                                                  OR sproduc = 0
                                                 );
                                       EXCEPTION
                                          WHEN NO_DATA_FOUND
                                          THEN
                                             RETURN 9001505;
                                       END;

                                       -- De momento lo haremos as aunque esta fecha nos vendra de pantalla
                                       -- (se ir a buscar tambin a PDS_SUPL_DIF_CONFIG)
                                       vpasexec := 5;
                                       --v_fdifer := PAC_MD_SUPLEMENTOS.f_fecha_diferido(v_difer.tfecrec, poliza.ssegpol);
                                       v_fdifer :=
                                          pac_md_suplementos.f_fecha_diferido
                                                               (pfdifer,
                                                                poliza.ssegpol
                                                               );
                                       vpasexec := 6;

                                       BEGIN
                                          INSERT INTO sup_diferidosseg
                                                      (cmotmov, sseguro,
                                                       fecsupl,
                                                       fvalfun, estado,
                                                       cusuari, falta
                                                      )
                                               VALUES (356, poliza.ssegpol,
                                                       v_fdifer,
                                                       v_difer.fvalfun, 0,
                                                       f_user, f_sysdate
                                                      );
                                       EXCEPTION
                                          WHEN DUP_VAL_ON_INDEX
                                          THEN
                                             --BEGIN
                                             --    SELECT dinaccion
                                             --    INTO v_dinaccion
                                             --    FROM SUP_ACCIONES_DIF
                                             --    WHERE cmotmov = 281
                                             --      AND sseguro = poliza.ssegpol
                                             --      AND dinaccion = 'D';
                                             --EXCEPTION
                                             --  WHEN NO_DATA_FOUND THEN
                                             --      NULL;
                                             --END;

                                             -- cmotmov = 281 + v_dinaccion = 'U'
                                             --         ==> Modificacin de garanta
                                             --IF v_primercop = 1 AND v_dinaccion = 'U' THEN
                                             IF v_primercop = 1
                                             THEN
                                                RETURN 9001506;
                                             END IF;
                                          WHEN OTHERS
                                          THEN
                                             RAISE e_object_error;
                                       END;

                                       -- Posem control a 0 (si se inserta mas de una vez
                                       -- en SUP_DIFERIDOSSEG aqui dentro dejamos continuar).
                                       -- La primera vez si casca el INSERT si que se debe avisar.
                                       v_primercop := 0;
                                       -- Accion 1 --
                                       vpasexec := 7;
                                       v_updatedif :=
                                             'UPDATE ESTGARANSEG SET ICAPITAL = '
                                          || TRANSLATE
                                                 (TO_CHAR (v_gars (j).icapital),
                                                  ',',
                                                  '.'
                                                 )
                                          || ' WHERE SSEGURO = :SSEGURO AND NRIESGO = '
                                          || v_ries (i).nriesgo
                                          || ' AND CGARANT = '
                                          || v_gars (j).cgarant;
                                       -- || ' AND NMOVIMI = :NMOVIMI';
                                       v_ttabledif := 'ESTGARANSEG';
                                       v_tcampodif := 'ICAPITAL';
                                       v_twheredif :=
                                             'SSEGURO = :SSEGURO AND NRIESGO = '
                                          || v_ries (i).nriesgo
                                          || ' AND CGARANT = '
                                          || v_gars (j).cgarant;
                                       -- || ' AND NMOVIMI = :NMOVIMI';
                                       v_tvalord :=
                                             v_tvalord
                                          || ff_desgarantia
                                                (v_gars (j).cgarant,
                                                 pac_md_common.f_get_cxtidioma
                                                )
                                          || ':'
                                          || v_gars (j).icapital;
                                       vpasexec := 8;

                                       BEGIN
                                          INSERT INTO sup_acciones_dif
                                                      (cmotmov, sseguro,
                                                       norden, estado,
                                                       dinaccion, ttable,
                                                       tcampo,
                                                       twhere,
                                                       taccion,
                                                       naccion,
                                                       vaccion, ttarifa
                                                      )
                                               VALUES (356, poliza.ssegpol,
                                                       v_accion, 0,
                                                       'U', v_ttabledif,
                                                       v_tcampodif,
                                                       v_twheredif,
                                                       v_updatedif,
                                                       v_gars (j).icapital,
                                                       NULL, 0
                                                      );
                                       EXCEPTION
                                          WHEN DUP_VAL_ON_INDEX
                                          THEN
                                             RETURN 9001506;
                                          WHEN OTHERS
                                          THEN
                                             RAISE e_object_error;
                                       END;

                                       v_accion := v_accion + 1;
                                       -- Accion 2 --
                                       vpasexec := 9;
                                       v_updatedif :=
                                             'UPDATE ESTGARANSEG SET ICAPTOT = '
                                          || TRANSLATE
                                                 (TO_CHAR (v_gars (j).icapital),
                                                  ',',
                                                  '.'
                                                 )
                                          || ' WHERE SSEGURO = :SSEGURO AND NRIESGO = '
                                          || v_ries (i).nriesgo
                                          || ' AND CGARANT = '
                                          || v_gars (j).cgarant;
                                       -- || ' AND NMOVIMI = :NMOVIMI';
                                       v_ttabledif := 'ESTGARANSEG';
                                       v_tcampodif := 'ICAPTOT';
                                       v_twheredif :=
                                             'SSEGURO = :SSEGURO AND NRIESGO = '
                                          || v_ries (i).nriesgo
                                          || ' AND CGARANT = '
                                          || v_gars (j).cgarant;
                                       -- || ' AND NMOVIMI = :NMOVIMI';
                                       vpasexec := 10;

                                       BEGIN
                                          INSERT INTO sup_acciones_dif
                                                      (cmotmov, sseguro,
                                                       norden, estado,
                                                       dinaccion, ttable,
                                                       tcampo,
                                                       twhere,
                                                       taccion,
                                                       naccion,
                                                       vaccion, ttarifa
                                                      )
                                               VALUES (356, poliza.ssegpol,
                                                       v_accion, 0,
                                                       'U', v_ttabledif,
                                                       v_tcampodif,
                                                       v_twheredif,
                                                       v_updatedif,
                                                       v_gars (j).icapital,
                                                       NULL, 0
                                                      );
                                       EXCEPTION
                                          WHEN DUP_VAL_ON_INDEX
                                          THEN
                                             RETURN 9001506;
                                          WHEN OTHERS
                                          THEN
                                             RAISE e_object_error;
                                       END;

                                       v_accion := v_accion + 1;
                                    END IF;
                                 END IF;
                              END IF;
                           END IF;
                        END LOOP;
                     END IF;
                  END LOOP;
               END IF;
            END LOOP;
         END IF;
      END IF;

      -- Actualizamos el literal del descripccin
      UPDATE sup_diferidosseg
         SET tvalord = v_tvalord
       WHERE cmotmov = 356 AND sseguro = poliza.ssegpol AND estado = 0;

      -- Actualizamos para tarifar tras el ltimo movimiento
      UPDATE sup_acciones_dif
         SET ttarifa = 1
       WHERE cmotmov = 356
         AND sseguro = poliza.ssegpol
         AND norden = (v_accion - 1);

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
         RETURN -1;
      WHEN e_object_error
      THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN -1;
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
         RETURN -1;
   END f_diferir_spl_disminucion_cap;

   FUNCTION f_diferir_spl_preguntas (
      poliza     IN       ob_iax_detpoliza,
      pfdifer    IN       VARCHAR2,
      mensajes   OUT      t_iax_mensajes
   )
      RETURN NUMBER
   IS
      v_count       NUMBER;
      v_difer       pds_supl_dif_config%ROWTYPE;
      v_fdifer      DATE;
      vpasexec      NUMBER (8)                        := 1;
      vparam        VARCHAR2 (500);
      vobject       VARCHAR2 (200)
                              := 'PAC_MD_SUPLEMENTOS.f_diferir_spl_preguntas';
      -- 26/04/2009
      v_ries        t_iax_riesgos;
      v_preg        t_iax_preguntas;
      v_preprod     t_iaxpar_preguntas;
      v_accion      NUMBER                            := 1;
      -- 28/04/2009
      v_crespue     NUMBER;
      v_primercop   NUMBER                            := 1;
      v_updatedif   VARCHAR2 (2000);
      v_ttabledif   sup_acciones_dif.ttable%TYPE;
      v_tcampodif   sup_acciones_dif.tcampo%TYPE;
      v_twheredif   sup_acciones_dif.twhere%TYPE;
      v_exclusion   NUMBER (1);
      v_dinaccion   sup_acciones_dif.dinaccion%TYPE;
      -- 05/05/2009
      v_tvalord     sup_diferidosseg.tvalord%TYPE     := '';
   BEGIN
      IF poliza IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      v_ries := pac_iobj_prod.f_partpolriesgos (poliza, mensajes);

      IF mensajes IS NOT NULL
      THEN
         IF mensajes.COUNT > 0
         THEN
            vpasexec := 1;
            RAISE e_object_error;
         END IF;
      END IF;

      IF v_ries IS NOT NULL
      THEN
         IF v_ries.COUNT > 0
         THEN
            FOR i IN v_ries.FIRST .. v_ries.LAST
            LOOP
               IF v_ries.EXISTS (i)
               THEN
                  p_control_error ('DCT0',
                                   'f_diferir_spl_pregunta',
                                   'poliza.sproduc = ' || poliza.sproduc
                                  );
                    --v_garprod :=
                    -- pac_mdpar_productos.f_get_garantias
                    -- (poliza.sproduc, poliza.gestion.cactivi, v_ries(i).nriesgo, /*bug 9916: ETM :16-06-09:--poliza.cactivi,*/
                     -- mensajes);
                  --  v_preprod := pac_mdpar_productos.f_get_pregpoliza(poliza.sproduc, FALSE,
                   --                                                   TRUE, mensajes);
                  v_preprod :=
                     pac_mdpar_productos.f_get_datosriesgos
                                                      (poliza.sproduc,
                                                       poliza.gestion.cactivi,
                                                       FALSE,
                                                       mensajes
                                                      );
                  --v_gars := pac_iobj_prod.f_partriesgarantias(v_ries(i), mensajes);
                  v_preg :=
                      pac_iobj_prod.f_partriespreguntas (v_ries (i), mensajes);

                  FOR j IN v_preg.FIRST .. v_preg.LAST
                  LOOP
                     v_exclusion := 0;
                     vpasexec := 2;

                     IF v_preg.EXISTS (j)
                     THEN
                        FOR k IN v_preprod.FIRST .. v_preprod.LAST
                        LOOP
                           vpasexec := 3;

                           IF v_preprod.EXISTS (k)
                           THEN
                              -------------------------------
-- Modificacin de garantas --Modificacin de preguntas-
-------------------------------
                              IF v_preprod (k).cpregun = v_preg (j).cpregun
                              THEN
                                 -- AND v_garprod(k).ctipcap IN(2, 6)
                                 -- AND v_exclusion = 0 THEN
                                  --v_garprod(k).ctipcap NOT IN (1,3,4,5) THEN
                                 IF v_preg (j).crespue IS NOT NULL
                                 THEN
                                    BEGIN
                                       SELECT crespue
                                         INTO v_crespue
                                         FROM pregunseg
                                        WHERE sseguro = poliza.ssegpol
                                          AND nriesgo = v_ries (i).nriesgo
                                          AND cpregun = v_preg (j).cpregun
                                          AND nmovimi =
                                                 (SELECT MAX (p.nmovimi)
                                                    FROM pregunseg p
                                                   WHERE p.sseguro =
                                                             pregunseg.sseguro
                                                     AND p.nriesgo =
                                                             pregunseg.nriesgo
                                                     AND p.cpregun =
                                                             pregunseg.cpregun);
                                    EXCEPTION
                                       WHEN OTHERS
                                       THEN
                                          v_crespue := NULL;
                                    --No estaba contestada la pregunta ya que no procedia
                                    END;

                                    IF v_preg (j).crespue <>
                                                            NVL (v_crespue, 0)
                                    THEN
                                       --Si la pregunta antes no estava ahora la tendremos que insertar
                                       --IF v_crespue IS NULL
                                       vpasexec := 4;

                                       BEGIN
                                          SELECT *
                                            INTO v_difer
                                            FROM pds_supl_dif_config
                                           --WHERE cmotmov = 281
                                          WHERE  cmotmov = 685
                                             AND (   sproduc = poliza.sproduc
                                                  OR sproduc = 0
                                                 );
                                       EXCEPTION
                                          WHEN NO_DATA_FOUND
                                          THEN
                                             RETURN 9001505;
                                       END;

                                       -- De momento lo haremos as aunque esta fecha nos vendra de pantalla
                                       -- (se ir a buscar tambin a PDS_SUPL_DIF_CONFIG)
                                       vpasexec := 5;
                                       --v_fdifer := PAC_MD_SUPLEMENTOS.f_fecha_diferido(v_difer.tfecrec, poliza.ssegpol);
                                       v_fdifer :=
                                          pac_md_suplementos.f_fecha_diferido
                                                               (pfdifer,
                                                                poliza.ssegpol
                                                               );
                                       vpasexec := 6;

                                       BEGIN
                                          INSERT INTO sup_diferidosseg
                                                      (cmotmov, sseguro,
                                                       fecsupl,
                                                       fvalfun, estado,
                                                       cusuari, falta
                                                      )
                                               --VALUES (281, poliza.ssegpol, v_fdifer,
                                          VALUES      (685, poliza.ssegpol,
                                                       v_fdifer,
                                                       v_difer.fvalfun, 0,
                                                       f_user, f_sysdate
                                                      );
                                       EXCEPTION
                                          WHEN DUP_VAL_ON_INDEX
                                          THEN
                                             --BEGIN
                                             -- SELECT dinaccion
                                             -- INTO v_dinaccion
                                             -- FROM SUP_ACCIONES_DIF
                                             -- WHERE cmotmov = 281
                                             -- AND sseguro = poliza.ssegpol
                                             -- AND dinaccion = 'D';
                                             --EXCEPTION
                                             -- WHEN NO_DATA_FOUND THEN
                                             -- NULL;
                                             --END;

                                             -- cmotmov = 281 + v_dinaccion = 'U'
                                              -- ==> Modificacin de garanta
                                              --IF v_primercop = 1 AND v_dinaccion = 'U' THEN
                                             /* IF v_primercop = 1 THEN --DCT 03/07/2015
                                                 RETURN 9001506;
                                              END IF;*/
                                             NULL;
                                          WHEN OTHERS
                                          THEN
                                             RAISE e_object_error;
                                       END;

                                       -- Posem control a 0 (si se inserta mas de una vez
                                       -- en SUP_DIFERIDOSSEG aqui dentro dejamos continuar).
                                       -- La primera vez si casca el INSERT si que se debe avisar.
                                       v_primercop := 0;
                                       -- Accion 1 --
                                       vpasexec := 7;
                                       v_updatedif :=
                                             'BEGIN INSERT INTO ESTPREGUNSEG(CPREGUN,SSEGURO,NRIESGO,NMOVIMI,CRESPUE) VALUES ('
                                          || v_preg (j).cpregun
                                          || ', :SSEGURO,'
                                          || v_ries (i).nriesgo
                                          || ','
                                          || ':NMOVIMI,'
                                          || v_preg (j).crespue
                                          || ');'
                                          || ' EXCEPTION WHEN DUP_VAL_ON_INDEX THEN UPDATE ESTPREGUNSEG SET CRESPUE = '
                                          || v_preg (j).crespue
                                          || ' WHERE SSEGURO = :SSEGURO AND NRIESGO = '
                                          || v_ries (i).nriesgo
                                          || ' AND CPREGUN = '
                                          || v_preg (j).cpregun
                                          || '; END;';
                                       v_ttabledif := 'ESTPREGUNSEG';
                                       v_tcampodif := 'CRESPUE';
                                       v_twheredif :=
                                             'SSEGURO = :SSEGURO AND NRIESGO = '
                                          || v_ries (i).nriesgo
                                          || ' AND CPREGUN = '
                                          || v_preg (j).cpregun;
                                       v_tvalord :=
                                             v_tvalord
                                          ||
                                             --!!!!! Buscar descripcin pregunta
                                             ff_despregunta
                                                (v_preg (j).cpregun,
                                                 pac_md_common.f_get_cxtidioma
                                                )
                                          -- || ff_desgarantia(v_gars(j).cgarant,
                                           -- pac_md_common.f_get_cxtidioma)
                                          || ':'
                                          || v_preg (j).crespue;
                                       vpasexec := 8;

                                       BEGIN
                                          INSERT INTO sup_acciones_dif
                                                      (cmotmov, sseguro,
                                                       norden, estado,
                                                       dinaccion, ttable,
                                                       tcampo,
                                                       twhere,
                                                       taccion,
                                                       naccion,
                                                       vaccion, ttarifa
                                                      )
                                               --VALUES (281, poliza.ssegpol, v_accion, 0,
                                          VALUES      (685, poliza.ssegpol,
                                                       v_accion, 0,
                                                       'U', v_ttabledif,
                                                       v_tcampodif,
                                                       v_twheredif,
                                                       v_updatedif,
                                                       v_preg (j).cpregun,
                                                       NULL, 0
                                                      );
                                       EXCEPTION
                                          WHEN DUP_VAL_ON_INDEX
                                          THEN
                                             --RETURN 9001506;
                                             NULL;
                                          WHEN OTHERS
                                          THEN
                                             RAISE e_object_error;
                                       END;

                                       v_accion := v_accion + 1;
                                    END IF;
                                 END IF;
                              END IF;
                           END IF;
                        END LOOP;
                     END IF;
                  END LOOP;
               END IF;
            END LOOP;
         END IF;
      END IF;

      -- Actualizamos el literal del descripccin
      UPDATE sup_diferidosseg
         SET tvalord = v_tvalord
       --WHERE cmotmov = 281
      WHERE  cmotmov = 685 AND sseguro = poliza.ssegpol AND estado = 0;

      -- Actualizamos para tarifar tras el ltimo movimiento
      UPDATE sup_acciones_dif
         SET ttarifa = 1
       --WHERE cmotmov = 281
      WHERE  cmotmov = 685 AND sseguro = poliza.ssegpol;

      --AND norden =(v_accion - 1);
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
         RETURN -1;
      WHEN e_object_error
      THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN -1;
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
         RETURN -1;
   END f_diferir_spl_preguntas;

   FUNCTION f_diferir_spl_sobreprimas (
      poliza     IN       ob_iax_detpoliza,
      pfdifer    IN       VARCHAR2,
      mensajes   OUT      t_iax_mensajes
   )
      RETURN NUMBER
   IS
      v_count       NUMBER;
      v_difer       pds_supl_dif_config%ROWTYPE;
      v_fdifer      DATE;
      vpasexec      NUMBER (8)                        := 1;
      vparam        VARCHAR2 (500);
      vobject       VARCHAR2 (200)
                            := 'PAC_MD_SUPLEMENTOS.f_diferir_spl_sobreprimas';
      -- 26/04/2009
      v_ries        t_iax_riesgos;                           --ob_iax_riesgos
      v_gars        t_iax_garantias;
      v_garprod     t_iaxpar_garantias;
      v_accion      NUMBER                            := 1;
      -- 28/04/2009
      v_recargo     NUMBER;
      v_primercop   NUMBER                            := 1;
      v_updatedif   VARCHAR2 (2000);
      v_ttabledif   sup_acciones_dif.ttable%TYPE;
      v_tcampodif   sup_acciones_dif.tcampo%TYPE;
      v_twheredif   sup_acciones_dif.twhere%TYPE;
      v_exclusion   NUMBER (1);
      v_dinaccion   sup_acciones_dif.dinaccion%TYPE;
      -- 05/05/2009
      v_tvalord     sup_diferidosseg.tvalord%TYPE     := '';
      v_gars_preg   t_iax_preguntas;
      v_garpreg     t_iaxpar_preguntas;
      v_crespue     pregungaranseg.crespue%TYPE;
      v_trespue     pregungaranseg.trespue%TYPE;
   BEGIN
      IF poliza IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      --v_ries := pac_iobj_prod.f_partriesgarantias(poliza.riesgos.garantias, mensajes);
      v_ries := pac_iobj_prod.f_partpolriesgos (poliza, mensajes);

      IF mensajes IS NOT NULL
      THEN
         IF mensajes.COUNT > 0
         THEN
            vpasexec := 1;
            RAISE e_object_error;
         END IF;
      END IF;

      IF v_ries IS NOT NULL
      THEN
         IF v_ries.COUNT > 0
         THEN
            FOR i IN v_ries.FIRST .. v_ries.LAST
            LOOP
               IF v_ries.EXISTS (i)
               THEN
                  v_garprod :=
                     pac_mdpar_productos.f_get_garantias
                                                     (poliza.sproduc,
                                                      poliza.gestion.cactivi,
                                                      v_ries (i).nriesgo,
                                                      /*bug 9916: ETM :16-06-09:--poliza.cactivi,*/
                                                      mensajes
                                                     );
                  v_gars :=
                      pac_iobj_prod.f_partriesgarantias (v_ries (i), mensajes);

                  FOR j IN v_gars.FIRST .. v_gars.LAST
                  LOOP
                     v_exclusion := 0;
                     vpasexec := 2;

                     IF v_gars.EXISTS (j)
                     THEN
                        FOR k IN v_garprod.FIRST .. v_garprod.LAST
                        LOOP
                           vpasexec := 3;

                           IF v_garprod.EXISTS (k)
                           THEN
                              IF     v_garprod (k).cgarant =
                                                           v_gars (j).cgarant
                                 AND v_gars (j).cobliga = 1
                              THEN
                                 v_gars_preg :=
                                    pac_iobj_prod.f_partgarpreguntas
                                                                  (v_gars (j),
                                                                   mensajes
                                                                  );
                                 v_garpreg :=
                                    pac_mdpar_productos.f_get_preggarant
                                                      (poliza.sproduc,
                                                       poliza.gestion.cactivi,
                                                       v_gars (j).cgarant,
                                                       mensajes
                                                      );

                                 IF v_gars_preg.EXISTS (1)
                                 THEN
                                    FOR l IN
                                       v_gars_preg.FIRST .. v_gars_preg.LAST
                                    LOOP
                                       FOR m IN
                                          v_garpreg.FIRST .. v_garpreg.LAST
                                       LOOP                          -- Nuevo
                                          IF v_gars_preg.EXISTS (l)
                                          THEN
                                             IF v_gars_preg (l).cpregun =
                                                        v_garpreg (m).cpregun
                                             THEN
                                                IF    v_gars_preg (l).crespue IS NOT NULL
                                                   OR v_gars_preg (l).trespue IS NOT NULL
                                                THEN
                                                   BEGIN
                                                      SELECT crespue,
                                                             trespue
                                                        INTO v_crespue,
                                                             v_trespue
                                                        FROM pregungaranseg
                                                       WHERE sseguro =
                                                                poliza.ssegpol
                                                         AND nriesgo =
                                                                v_ries (i).nriesgo
                                                         AND cgarant =
                                                                v_gars (j).cgarant
                                                         AND cpregun =
                                                                v_gars_preg
                                                                           (l).cpregun
                                                         AND nmovimi =
                                                                (SELECT MAX
                                                                           (g.nmovimi
                                                                           )
                                                                   FROM pregungaranseg g
                                                                  WHERE g.sseguro =
                                                                           pregungaranseg.sseguro
                                                                    AND g.nriesgo =
                                                                           pregungaranseg.nriesgo
                                                                    AND g.cgarant =
                                                                           pregungaranseg.cgarant
                                                                    AND g.cpregun =
                                                                           pregungaranseg.cpregun);
                                                   EXCEPTION
                                                      WHEN NO_DATA_FOUND
                                                      THEN
                                                         v_crespue := NULL;
                                                   END;

                                                   IF    v_gars_preg (l).crespue <>
                                                            NVL (v_crespue, 0)
                                                      OR v_gars_preg (l).trespue <>
                                                            NVL (v_trespue,
                                                                 ' '
                                                                )
                                                   THEN
                                                      vpasexec := 4;

                                                      BEGIN
                                                         SELECT *
                                                           INTO v_difer
                                                           FROM pds_supl_dif_config
                                                          WHERE cmotmov = 801
                                                            AND (   sproduc =
                                                                       poliza.sproduc
                                                                 OR sproduc =
                                                                             0
                                                                );
                                                      EXCEPTION
                                                         WHEN NO_DATA_FOUND
                                                         THEN
                                                            RETURN 9001505;
                                                      END;

                                                      -- De momento lo haremos as aunque esta fecha nos vendra de pantalla
                                                      -- (se ir a buscar tambin a PDS_SUPL_DIF_CONFIG)
                                                      vpasexec := 5;
                                                      --v_fdifer := PAC_MD_SUPLEMENTOS.f_fecha_diferido(v_difer.tfecrec, poliza.ssegpol);
                                                      v_fdifer :=
                                                         pac_md_suplementos.f_fecha_diferido
                                                               (pfdifer,
                                                                poliza.ssegpol
                                                               );
                                                      vpasexec := 6;

                                                      BEGIN
                                                         INSERT INTO sup_diferidosseg
                                                                     (cmotmov,
                                                                      sseguro,
                                                                      fecsupl,
                                                                      fvalfun,
                                                                      estado,
                                                                      cusuari,
                                                                      falta
                                                                     )
                                                              VALUES (801,
                                                                      poliza.ssegpol,
                                                                      v_fdifer,
                                                                      v_difer.fvalfun,
                                                                      0,
                                                                      f_user,
                                                                      f_sysdate
                                                                     );
                                                      EXCEPTION
                                                         WHEN DUP_VAL_ON_INDEX
                                                         THEN
                                                            NULL;
                                                         WHEN OTHERS
                                                         THEN
                                                            RAISE e_object_error;
                                                      END;

                                                      -- Posem control a 0 (si se inserta mas de una vez
                                                      -- en SUP_DIFERIDOSSEG aqui dentro dejamos continuar).
                                                      -- La primera vez si casca el INSERT si que se debe avisar.
                                                      v_primercop := 0;
                                                      -- Accion 1 --
                                                      vpasexec := 7;

                                                      IF     (v_gars_preg (l).crespue <>
                                                                 NVL
                                                                    (v_crespue,
                                                                     0
                                                                    )
                                                             )
                                                         AND v_gars_preg (l).trespue IS NULL
                                                      THEN
                                                         v_updatedif :=
                                                               'BEGIN INSERT INTO ESTPREGUNGARANSEG(SSEGURO,NRIESGO,CGARANT,NMOVIMI,CPREGUN,CRESPUE,FINIEFE) VALUES ( :SSEGURO,'
                                                            || v_ries (i).nriesgo
                                                            || ','
                                                            || v_gars (j).cgarant
                                                            || ', :NMOVIMI,'
                                                            || v_gars_preg (l).cpregun
                                                            || ', '
                                                            || v_gars_preg (l).crespue
                                                            || ', '
                                                            || 'to_date('''
                                                            || poliza.gestion.fefecto
                                                            || ''','''
                                                            || 'dd/mm/yyyy'
                                                            || '''));'
                                                            || ' EXCEPTION WHEN DUP_VAL_ON_INDEX THEN UPDATE ESTPREGUNGARANSEG SET CRESPUE = '
                                                            || v_gars_preg (l).crespue
                                                            || ' WHERE SSEGURO = :SSEGURO AND NRIESGO = '
                                                            || v_ries (i).nriesgo
                                                            || ' AND CGARANT = '
                                                            || v_gars (j).cgarant
                                                            || ' AND CPREGUN = '
                                                            || v_gars_preg (l).cpregun
                                                            || '; END;';
                                                         v_ttabledif :=
                                                            'ESTPREGUNGARANSEG';
                                                         v_tcampodif :=
                                                                     'CRESPUE';
                                                         v_twheredif :=
                                                               'SSEGURO = :SSEGURO AND NRIESGO = '
                                                            || v_ries (i).nriesgo
                                                            || ' AND CGARANT = '
                                                            || v_gars (j).cgarant
                                                            || ' AND CPREGUN = '
                                                            || v_gars_preg (l).cpregun;
                                                         v_tvalord :=
                                                               v_tvalord
                                                            ||
                                                               --!!!!! Buscar descripcin pregunta
                                                               ff_despregunta
                                                                  (v_gars_preg
                                                                           (l).cpregun,
                                                                   pac_md_common.f_get_cxtidioma
                                                                  )
                                                            || ':'
                                                            || v_gars_preg (l).crespue;
                                                      ELSE
                                                         v_updatedif :=
                                                               'BEGIN INSERT INTO ESTPREGUNGARANSEG(SSEGURO,NRIESGO,CGARANT,NMOVIMI,CPREGUN,TRESPUE,FINIEFE) VALUES ( :SSEGURO,'
                                                            || v_ries (i).nriesgo
                                                            || ','
                                                            || v_gars (j).cgarant
                                                            || ', :NMOVIMI,'
                                                            || v_gars_preg (l).cpregun
                                                            || ', '
                                                            || ''''
                                                            || v_gars_preg (l).trespue
                                                            || ''', '
                                                            || 'to_date('''
                                                            || poliza.gestion.fefecto
                                                            || ''','''
                                                            || 'dd/mm/yyyy'
                                                            || '''));'
                                                            || ' EXCEPTION WHEN DUP_VAL_ON_INDEX THEN UPDATE ESTPREGUNGARANSEG SET TRESPUE = '
                                                            || 'NVL('
                                                            || ''''
                                                            || v_gars_preg (l).trespue
                                                            || ''''
                                                            || ', '''')'
                                                            || ' WHERE SSEGURO = :SSEGURO AND NRIESGO = '
                                                            || v_ries (i).nriesgo
                                                            || ' AND CGARANT = '
                                                            || v_gars (j).cgarant
                                                            || ' AND CPREGUN = '
                                                            || v_gars_preg (l).cpregun
                                                            || '; END;';
                                                         v_ttabledif :=
                                                            'ESTPREGUNGARANSEG';
                                                         v_tcampodif :=
                                                                     'TRESPUE';
                                                         v_twheredif :=
                                                               'SSEGURO = :SSEGURO AND NRIESGO = '
                                                            || v_ries (i).nriesgo
                                                            || ' AND CGARANT = '
                                                            || v_gars (j).cgarant
                                                            || ' AND CPREGUN = '
                                                            || v_gars_preg (l).cpregun;
                                                         v_tvalord :=
                                                               v_tvalord
                                                            ||
                                                               --!!!!! Buscar descripcin pregunta
                                                               ff_despregunta
                                                                  (v_gars_preg
                                                                           (l).cpregun,
                                                                   pac_md_common.f_get_cxtidioma
                                                                  )
                                                            || ':'
                                                            || v_gars_preg (l).trespue;
                                                      END IF;

                                                      vpasexec := 8;

                                                      BEGIN
                                                         INSERT INTO sup_acciones_dif
                                                                     (cmotmov,
                                                                      sseguro,
                                                                      norden,
                                                                      estado,
                                                                      dinaccion,
                                                                      ttable,
                                                                      tcampo,
                                                                      twhere,
                                                                      taccion,
                                                                      naccion,
                                                                      vaccion,
                                                                      ttarifa
                                                                     )
                                                              VALUES (801,
                                                                      poliza.ssegpol,
                                                                      v_accion,
                                                                      0,
                                                                      'U',
                                                                      v_ttabledif,
                                                                      v_tcampodif,
                                                                      v_twheredif,
                                                                      v_updatedif,
                                                                      v_gars
                                                                           (j).primas.precarg,
                                                                      NULL,
                                                                      0
                                                                     );
                                                      EXCEPTION
                                                         WHEN DUP_VAL_ON_INDEX
                                                         THEN
                                                            --RETURN 9001506;
                                                            NULL;
                                                         WHEN OTHERS
                                                         THEN
                                                            RAISE e_object_error;
                                                      END;

                                                      v_accion := v_accion + 1;
                                                   END IF;
                                                --IF v_gars_preg(l).crespue <> NVL(v_crespue, 0) THEN
                                                END IF;
                                             --F v_gars_preg(l).crespue  IS NOT NULL THEN
                                             END IF;
                                          --IF  v_gars_preg(l).cpregun =  v_garpreg(k).cpregun THEN
                                          END IF;
                                       --IF v_gars_preg.EXISTS(l) THEN
                                       END LOOP;
                                    --FOR m IN v_garpreg.FIRST .. v_garpreg.LAST LOOP     -- Nuevo
                                    END LOOP;
                                 --FOR l IN v_gars_preg.FIRST .. v_gars_preg.LAST LOOP
                                 END IF;       --IF v_gars_pred.EXISTS(1) THEN
                              END IF;
--IF v_garprod(k).cgarant = v_gars(j).cgarant  AND v_gars(j).cobliga = 1  THEN
                           END IF;              -- IF v_garprod.EXISTS(k) THEN
                        END LOOP;
                     -- FOR k IN v_garprod.FIRST .. v_garprod.LAST LOOP
                     END IF;                       -- IF v_gars.EXISTS(j) THEN
                  END LOOP;       -- FOR j IN v_gars.FIRST .. v_gars.LAST LOOP
               END IF;                              --IF v_ries.EXISTS(i) THEN
            END LOOP;             -- FOR i IN v_ries.FIRST .. v_ries.LAST LOOP
         END IF;                                    --IF v_ries.COUNT > 0 THEN
      END IF;                                     --IF v_ries IS NOT NULL THEN

      -- Actualizamos el literal del descripccin
      UPDATE sup_diferidosseg
         SET tvalord = v_tvalord
       WHERE cmotmov = 801 AND sseguro = poliza.ssegpol AND estado = 0;

      -- Actualizamos para tarifar tras el ltimo movimiento
      UPDATE sup_acciones_dif
         SET ttarifa = 1
       WHERE cmotmov = 801
         AND sseguro = poliza.ssegpol
         AND norden = (v_accion - 1);

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
         RETURN -1;
      WHEN e_object_error
      THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN -1;
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
         RETURN -1;
   END f_diferir_spl_sobreprimas;

   /*************************************************************************
    FUNCTION f_get_descmotmov Descripcion del suplemento
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
      vobjectname   VARCHAR2 (200) := 'PAC_MD_PRODUCCION.f_get_descmotmov';
   BEGIN
      ptmotmov :=
         pac_iax_listvalores.f_getdescripvalor
            (   'SELECT f_axis_literales(slitera,'
             || pcidioma
             || ')
                                                          FROM pds_supl_grup
                                                         WHERE cmotmov = '
             || pcmotmov
             || '
                                                           AND cempres ='
             || pac_md_common.f_get_cxtempresa (),
             mensajes
            );

      IF ptmotmov IS NULL
      THEN
         ptmotmov :=
            pac_iax_listvalores.f_getdescripvalor
               (   'SELECT mts.tmotmov
                                                             FROM motmovseg mts
                                                            WHERE mts.cmotmov = '
                || pcmotmov
                || '
                                                              AND mts.cidioma ='
                || pcidioma,
                mensajes
               );
      END IF;

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
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN 1;
   END f_get_descmotmov;
END pac_md_suplementos;
/