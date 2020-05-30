--------------------------------------------------------
--  DDL for Package Body PAC_IAX_SIMULACIONES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_IAX_SIMULACIONES" 
AS
   /******************************************************************************
   NOMBRE: PAC_IAX_SIMULACIONES
   PROPÓSITO: Funciones para simulación

   REVISIONES:
   Ver Fecha Autor Descripción
   --------- ---------- --------------- ------------------------------------
   1.0 19/12/2007 ACC 1. Creación del package.
   2.0 25/06/2009 AMC 2. Se añade la función f_actmodtom bug 9642
   3.0 16/09/2009 AMC 3. 11165: Se sustituñe T_iax_saldodeutorseg por t_iax_prestamoseg
   4.0 05/11/2009 NMM 4. 10093: CRE - Afegir filtre per RAM en els cercadors.
   5.0 22/06/2010 PFA 5. 14599: CEM301 - Ajuste pantalla simulación (Rentas)
   6.0 03/11/2010 DRA 6. 0016436: CRT001 - Configurar simulación y perfil oficina
   7.0 14/12/2010 XPL 7. 16799: CRT003 - Alta rapida poliza correduria
   8.0 16/05/2011 APD 8. 0017931: CRE800 - Persones duplicades
   9.0 27/06/2011 APD 9.0018848: LCOL003 - Vigencia fecha de tarifa
   10.0 08/09/2011 APD 10.0018848: LCOL003 - Vigencia fecha de tarifa
   11.0 02/12/2011 AMC 11. Bug 20307/99655 - Se añaden nuevos parametros a las funciones f_grabaasegurado y f_gravatomadores
   12.0 26/01/2012 RSC 12. 0020995: LCOL - UAT - TEC - Incidencias de Contratacion
   13.0 04/06/2013 JDS 13. 0026923: LCOL - TEC - Revisi�n Q-Trackers Fase 3A
   14.0 03/07/2013 NMM 14. 27499: CALI101-Error en nrenova en p�lisses que venen de projectes
   15.0 09/07/2013 APD 15. 0026907/148107: LCOL - AUT - Simulaciones conductores. (ID 50)
   16.0 12/08/2013 RCL 16. 0027610: LCOL - AUT - No borrar simulaci�n cuando se pasa a propuesta (f_grabarsimulacion_sinvalidar)
   17.0 05/09/2013 JSV 17. 0027955: LCOL_T031- QT GUI de Fase 3
   18.0 03/10/2013 MMS 18. 0027304: POSS518 (POSSF200)- Resolucion de Incidencias FASE 1-2: Tecnico - Rentas Vitalicias
   19.0 04/12/2013 JDS 19. 0028455: LCOL_T031- TEC - Revisi�n Q-Trackers Fase 3A II
   20.0 05/12/2013 RCL 20. 0029268: LCOL - PER - No permitir duplicar la persona en simulaci�n.
   21.0 27/01/2014 JTT 21. 0027429: Persistencia simulacin
   22.0 03/02/2014 JTT 22. 0027430: A�adir al filtro de busqueda de simulaciones el tomador y la fecha de cotizacion
   23.0 23/11/2015 DCT 23. 0034066: POSPT500-POSTEC PV LARGO PLAZO INVERSI�N ERROR EN CALCULO DE RESERVA DIARIA (bug hermano interno)
   ******************************************************************************/
   e_object_error   EXCEPTION;
   e_param_error    EXCEPTION;

   /*************************************************************************
   Recupera el riesgo asegurado indicado por el parametro
   param in pnriesgo : número de riesgo
   param out : mensajes de error
   return : objeto asegurado
   *************************************************************************/
   FUNCTION f_get_asegurado(
      pnriesgo   IN       NUMBER,
      psperson   IN       NUMBER,
      mensajes   OUT      t_iax_mensajes
   )
      RETURN ob_iax_asegurados
   IS
      rie          ob_iax_riesgos;
      asg          t_iax_asegurados;
      det_poliza   ob_iax_detpoliza := pac_iobj_prod.f_getpoliza (mensajes);
      vpasexec     NUMBER (8)       := 1;
      vparam       VARCHAR2 (100)
                    := 'pnriesgo= ' || pnriesgo || ', psperson= ' || psperson;
      vobject      VARCHAR2 (200)   := 'PAC_IAX_SIMULACIONES.F_Get_Asegurado';
   BEGIN
      IF det_poliza IS NULL
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, 1000644);
                                      --'No se ha inicializado correctamente'
         RAISE e_param_error;
      END IF;

      vpasexec := 2;

      IF pnriesgo = 0
      THEN
         RETURN NULL;
      END IF;                      -- perque entra per primer cop a simulació

      rie := pac_iobj_prod.f_partpolriesgo (det_poliza, pnriesgo, mensajes);
      vpasexec := 3;

      IF rie IS NULL
      THEN
         vpasexec := 4;
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, 1000441);
                                         --'No existen riesgos en la póliza'
         vpasexec := 5;
         RAISE e_object_error;
      END IF;

      asg := rie.riesgoase;

      IF psperson IS NOT NULL
      THEN
         RETURN pac_iax_produccion.f_get_asegurado (psperson, mensajes);
      ELSIF asg IS NOT NULL AND asg.COUNT > 0
      THEN
         -- INI RLLF 20/03/2014 Canvi per fer que no recuperi un element per defecte.
         IF NVL (pac_iaxpar_productos.f_get_parproducto ('2_CABEZAS',
                                                         det_poliza.sproduc
                                                        ),
                 0
                ) <> 1
         THEN
            --// ACC esta a pinyo q recupera l'ultim risc
            RETURN asg (asg.LAST);
         ELSE
            RETURN NULL;
         END IF;
      -- FIN RLLF 20/03/2014 Canvi per fer que no recuperi un element per defecte.
      ELSE
         RETURN NULL;
      END IF;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
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
   END f_get_asegurado;

   /*************************************************************************
   Graba el asegurado
   param in psperson : número de persona
   param in pcsexper : sexo de la persona
   param in pfnacimi : fecha nacimiento
   param in pnnumnif : número identificación persona
   param in tnombre : nombre de la persona
   param in tapelli1 : primer apellido
   param in tapelli2 : segundo apellido
   param in pctipide : Tipo de identificación persona V.F. 672
   param in pctipper : Tipo de persona V.F. 85
   param out : mensajes de error
   return : 0 todo correcto
   1 ha habido un error

   Bug 20307/99655 - 02/12/2011 - AMC -
   *************************************************************************/
   FUNCTION f_grabaasegurados(
      psperson    IN       NUMBER,
      pcsexper    IN       NUMBER,
      pfnacimi    IN       DATE,
      pnnumnif    IN       VARCHAR2,
      ptnombre    IN       VARCHAR2,
      ptnombre1   IN       VARCHAR2,
      ptnombre2   IN       VARCHAR2,
      ptapelli1   IN       VARCHAR2,
      ptapelli2   IN       VARCHAR2,
      pctipide    IN       NUMBER,
      pctipper    IN       NUMBER,
      pcestciv    IN       NUMBER,
      mensajes    OUT      t_iax_mensajes
   )
      RETURN NUMBER
   IS
      nerr         NUMBER           := 0;
      vsperson     NUMBER;
      mjs          t_iax_mensajes;
      tom          t_iax_tomadores;
      det_poliza   ob_iax_detpoliza;
      vpasexec     NUMBER (8)       := 1;
      vparam       VARCHAR2 (500)
         :=    'psperson='
            || psperson
            || ' pcsexper='
            || pcsexper
            || ' pfnacimi='
            || pfnacimi
            || ' pnnumnif='
            || pnnumnif
            || ' ptnombre='
            || ptnombre
            || ' ptapelli1='
            || ptapelli1
            || ' ptapelli2='
            || ptapelli2
            || ' pctipide='
            || pctipide
            || ' pctipper='
            || pctipper;
      vobject      VARCHAR2 (200)  := 'PAC_IAX_SIMULACIONES.F_GrabaAsegurados';
      pduplicada   NUMBER;                     -- Bug 17931 - APD - 16/05/2011
   BEGIN
      det_poliza := pac_iobj_prod.f_getpoliza (mensajes);

      IF det_poliza IS NULL
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, 1000644);
                                      --'No se ha inicializado correctamente'
         RAISE e_param_error;
      END IF;

      vpasexec := 2;

      IF NVL (pcsexper, 0) = 0 AND pctipper = 1
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, 9000771);
                                    --'Debe informar del sexo de la persona.'
         RAISE e_param_error;
      END IF;

      vpasexec := 3;

      -- Bug AMA-16 - 02/06/2016 - AMC
      if nvl(pac_parametros.f_parproducto_n(det_poliza.sproduc, 'FNACIMI_SIMUL'),0) = 0 then
      IF NVL (TO_CHAR (pfnacimi), ' ') = ' ' AND pctipper = 1
        THEN
           pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, 9000772);
                        --'Debe informar de la fecha nacimiento de la persona.'
           RAISE e_param_error;
        END IF;
      end if;
      -- Fi Bug AMA-16 - 02/06/2016 - AMC

      IF NVL (psperson, 0) = 0
      THEN
         -- Bug 17931 - APD - 16/05/2011 - si se ha informado el n de documento, se debe validar
         -- que no exista otra persona con el mismo n de documento, ya que si existiera se
         -- deberia seleccionar dicha persona y no crear una persona desde simulacion
         IF pnnumnif IS NOT NULL
         THEN
            -- Bug 18668 - APD - 07/06/2011 - se valida que el nnumide sea correcto
            nerr :=
               pac_md_persona.f_validanif (pnnumnif,
                                           pctipide,
                                           pcsexper,
                                           pfnacimi,
                                           mensajes
                                          );

            IF nerr <> 0
            THEN
               pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, nerr);
               RAISE e_object_error;
            END IF;

            -- Fin Bug 18668 - APD - 07/06/2011
            nerr :=
               pac_md_persona.f_persona_duplicada (psperson,
                                                   pnnumnif,
                                                   pcsexper,
                                                   pfnacimi,
                                                   NULL,
                                                   NULL,
                                                   NULL,
                                                   pctipide,
                                                   pduplicada,
                                                   mensajes,
                                                   det_poliza.sseguro
                                                  );
                                         --BUG 29268/160635 - RCL - 25/12/2013

            IF pduplicada <> 0
            THEN
               nerr := 9001806;
               pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, nerr);
               RAISE e_object_error;
            END IF;
         END IF;

         -- Fin Bug 17931 - APD - 16/05/2011
         vpasexec := 4;
         --Bug 23510 - XVM - 18/10/2012 Se a�ade par�metro cagente
         nerr :=
            pac_md_simulaciones.f_grabaasegurados (det_poliza.sseguro,
                                                   pcsexper,
                                                   pfnacimi,
                                                   pnnumnif,
                                                   ptnombre,
                                                   ptnombre1,
                                                   ptnombre2,
                                                   ptapelli1,
                                                   ptapelli2,
                                                   pctipide,
                                                   pctipper,
                                                   det_poliza.cagente,
                                                   vsperson,
                                                   NULL,
                                                   pcestciv,
                                                   mensajes
                                                  );
         vpasexec := 5;

         IF nerr = 0
         THEN
            nerr :=
                   pac_iax_produccion.f_insertasegurado (vsperson, NULL, mjs);

            IF nerr > 0
            THEN
               vpasexec := 6;
               pac_iobj_mensajes.p_mergemensaje (mensajes, mjs);
            END IF;

            IF mensajes IS NOT NULL
            THEN
               IF mensajes.COUNT > 0
               THEN
                  vpasexec := 7;
                  RAISE e_object_error;
               END IF;
            END IF;
         ELSE
            RAISE e_object_error;
         END IF;
      ELSE
         vsperson := psperson;
      END IF;

      vpasexec := 8;
      --// ACC Ara perque es un risc personal
      --// ACC 150207 aixo ja no cal que es faci no ens cal prenedor
      -- tom := PAC_IOBJ_PROD.F_PartPolTomadores(det_poliza,mensajes);
      -- IF tom is null THEN
      -- tom:=T_IAX_TOMADORES();
      -- END IF;
      --
      -- IF tom.count=0 THEN
      -- vpasexec:=9;
      --
      -- nerr:=PAC_IAX_PRODUCCION.F_InsertTomadores(vsperson,mjs);
      -- IF nerr>0 THEN
      -- vpasexec:=10;
      --
      -- PAC_IOBJ_MENSAJES.P_Mergemensaje(mensajes,mjs);
      -- RAISE e_object_error;
      -- END IF;
      -- END IF;
      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
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
   END f_grabaasegurados;

   /*************************************************************************
   Comprova el numero asegurats permessos
   param in out : mensajes de error
   return : 0 pot afegir com asegurat
   1 no pot afegir com asegurat
   *************************************************************************/
   FUNCTION comprovanumtomaseg(
      sperson    IN       NUMBER,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN NUMBER
   IS
      naseg      NUMBER           := 0;
      aaseg      NUMBER           := pac_iaxpar_productos.f_permitirmultiaseg;
      aseg       t_iax_asegurados;
      ries       t_iax_riesgos;
      rie        ob_iax_riesgos;
      nerr       NUMBER           := 0;
      vpasexec   NUMBER (8)       := 1;
      vparam     VARCHAR2 (1)     := NULL;
      vobject    VARCHAR2 (200)   := 'PAC_IAX_PRODUCCION.ComprovaNumTomAseg';
   BEGIN
      ries :=
         pac_iobj_prod.f_partpolriesgos
                                       (pac_iax_produccion.poliza.det_poliza,
                                        mensajes
                                       );

      IF ries IS NULL
      THEN
         RETURN 0;
      ELSE
         IF ries.COUNT = 0
         THEN
            RETURN 0;
         END IF;
      END IF;

      IF mensajes IS NOT NULL
      THEN
         IF mensajes.COUNT > 0
         THEN
            RETURN 0;
         END IF;
      END IF;

      FOR vrie IN ries.FIRST .. ries.LAST
      LOOP
         IF ries.EXISTS (vrie)
         THEN
            aseg := pac_iobj_prod.f_partriesasegurado (ries (vrie), mensajes);

            IF aseg IS NOT NULL
            THEN
               IF aseg.COUNT > 0
               THEN
                  IF mensajes IS NULL
                  THEN
                     FOR vaseg IN aseg.FIRST .. aseg.LAST
                     LOOP
                        IF aseg.EXISTS (vaseg)
                        THEN
                           IF aseg (vaseg).sperson <> sperson
                           THEN
                              naseg := naseg + 1;
                           END IF;
                        END IF;
                     END LOOP;
                  END IF;
               END IF;
            END IF;
         END IF;
      END LOOP;

      IF aaseg = 1 AND naseg >= 1
      THEN
         RETURN 0;
      ELSIF aaseg = 0 AND naseg > 0
      THEN
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
         RETURN 0;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 0;
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
   END comprovanumtomaseg;

   /*************************************************************************
   Comprova que existeixi el asegurat
   param in sperson : codigo de persona
   param in out : mensajes de error
   return : 0 no existe
   1 existe
   *************************************************************************/
   FUNCTION f_existtomaseg(sperson IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER
   IS
      aseg       t_iax_asegurados;
      ries       t_iax_riesgos;
      rie        ob_iax_riesgos;
      nerr       NUMBER           := 0;
      vpasexec   NUMBER (8)       := 1;
      vparam     VARCHAR2 (1)     := NULL;
      vobject    VARCHAR2 (200)   := 'PAC_IAX_PRODUCCION.F_ExistTomAseg';
   BEGIN
      IF pac_iax_produccion.poliza.det_poliza IS NULL
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, 1000644);
         RAISE e_param_error;
      END IF;

      ries :=
         pac_iobj_prod.f_partpolriesgos (pac_iax_produccion.poliza.det_poliza,
                                         mensajes
                                        );

      IF ries IS NULL
      THEN
         RETURN 0;
      ELSE
         IF ries.COUNT = 0
         THEN
            RETURN 0;
         END IF;
      END IF;

      IF mensajes IS NOT NULL
      THEN
         IF mensajes.COUNT > 0
         THEN
            RETURN 0;
         END IF;
      END IF;

      FOR vrie IN ries.FIRST .. ries.LAST
      LOOP
         IF ries.EXISTS (vrie)
         THEN
            aseg := pac_iobj_prod.f_partriesasegurado (ries (vrie), mensajes);

            IF aseg IS NULL
            THEN
               RETURN 0;
            END IF;

            IF aseg.COUNT > 0
            THEN
               IF mensajes IS NOT NULL
               THEN
                  IF mensajes.COUNT > 0
                  THEN
                     RETURN 0;
                  END IF;
               END IF;

               FOR vaseg IN aseg.FIRST .. aseg.LAST
               LOOP
                  IF aseg.EXISTS (vaseg)
                  THEN
                     IF     aseg (vaseg).sperson = sperson
                        AND aseg (vaseg).ffecfin IS NULL
                     THEN                                              -- acc.
                        RETURN 1;
                     END IF;
                  END IF;
               END LOOP;
            END IF;
         END IF;
      END LOOP;

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
         RETURN 0;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 0;
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
   END f_existtomaseg;

   /*************************************************************************
   Inserta un nuevo tomador al objeto poliza
   param in sperson : cdigo de persona a insertar
   param out mensajes : mensajes de error
   param out ppregun : Pregunta sobre asegurado
   return : 0 todo ha sido correcto
   1 ha habido un error
   *************************************************************************/
   FUNCTION f_inserttomadores(
      psperson   IN       NUMBER,
      mensajes   OUT      t_iax_mensajes,
      ppregun    OUT      NUMBER
   )
      RETURN NUMBER
   IS
      dtpoliza            ob_iax_detpoliza;
      toma                t_iax_tomadores;
      ntom                NUMBER           := 1;
      nerr                NUMBER;
      vpasexec            NUMBER (8)       := 1;
      npartom             NUMBER           := 0;
                -- Tarea 8695: nmero de tomadores admitidos para el producto.
      vparam              VARCHAR2 (200)   := 'sperson=' || psperson;
      vobject             VARCHAR2 (200)
                                    := 'PAC_IAX_PRODUCCION.F_InsertTomadores';
      v_mismoaseg         NUMBER;
      -- Bug 33515 nota 200270
      v_mismoaseg_simul   NUMBER;
      -- Bug 33515 nota 200270
      vctipper            NUMBER;
   BEGIN
      IF pac_iax_produccion.poliza.det_poliza IS NULL
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, 1000644);
         RAISE e_param_error;
      ELSE
         dtpoliza := pac_iax_produccion.poliza.det_poliza;
      END IF;

      vpasexec := 2;

      IF dtpoliza.tomadores IS NULL
      THEN
         toma := t_iax_tomadores ();
      ELSE
         toma := dtpoliza.tomadores;
      END IF;

      pac_iax_produccion.isneedtom := TRUE;
      -- BUG 0008695 - 28-01-09 - jmf - 0008695: IAX - Control del nmero mximo de tomadores
      npartom :=
         pac_iaxpar_productos.f_get_parproducto
                                 ('NUM_TOMADORES',
                                  pac_iax_produccion.poliza.det_poliza.sproduc
                                 );

      IF toma.COUNT > npartom AND npartom <> 0
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje
                           (mensajes,
                            1,
                            42321,
                               f_axis_literales (9000795,
                                                 pac_md_common.f_get_cxtidioma
                                                )
                            || ' '
                            || npartom
                            || ' '
                            || f_axis_literales (1000380,
                                                 pac_md_common.f_get_cxtidioma
                                                )
                           );
         RAISE e_object_error;
      END IF;

      vpasexec := 5;

      -- BUG 0008695 - 28-01-09 - jmf - 0008695: IAX - Control del nmero mximo de tomadores

      -- 2 CABEZAS ACC 040308
      IF pac_iax_produccion.f_existtom (psperson, mensajes) = 1
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, 9000824);
         RETURN 1;
      END IF;

      vpasexec := 7;
      ntom := toma.COUNT + 1;
      toma.EXTEND;
      toma (toma.LAST) := ob_iax_tomadores ();
      toma (toma.LAST).sperson := psperson;
      toma (toma.LAST).nordtom := ntom;
      toma (toma.LAST).direcciones := t_iax_direcciones ();

      IF f_existtomaseg (psperson, mensajes) = 1
      THEN
         toma (toma.LAST).isaseg := 1;
      ELSE
         toma (toma.LAST).isaseg := 0;
      END IF;

      v_mismoaseg :=
         pac_iaxpar_productos.f_get_parproducto
                                 ('MISMO_ASEG',
                                  pac_iax_produccion.poliza.det_poliza.sproduc
                                 );
      -- Bug 33515 nota 200270
      v_mismoaseg_simul :=
         pac_iaxpar_productos.f_get_parproducto
                                 ('MISMO_ASEG_SIMUL',
                                  pac_iax_produccion.poliza.det_poliza.sproduc
                                 );
      -- Bug 33515 nota 200270
      vpasexec := 9;
      nerr :=
         pac_md_persona.f_get_persona_agente
                                (psperson,
                                 pac_iax_produccion.poliza.det_poliza.cagente,
                                 pac_iax_produccion.vpmode,
                                 toma (toma.LAST),
                                 mensajes
                                );
      vpasexec := 11;
      vpasexec := 11;
      --INI JBN--
      nerr :=
         pac_md_validaciones.f_valida_edad_tomador
                                (toma,
                                 pac_iax_produccion.poliza.det_poliza.sproduc,
                                 f_sysdate,
                                 mensajes
                                );

      IF nerr <> 0
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, nerr);
         RAISE e_object_error;
      END IF;

      -- FIN JBN: BUG 0017041
      IF (   (    pac_iaxpar_productos.f_get_parproducto
                                 ('2_CABEZAS',
                                  pac_iax_produccion.poliza.det_poliza.sproduc
                                 ) = 1
              AND toma (toma.FIRST).sperson = psperson
              AND NVL (toma (toma.LAST).ctipper, 0) = 1
             )
          OR v_mismoaseg = 1
         )
      THEN
         IF toma (toma.FIRST).sperson = psperson
         THEN
            toma (toma.LAST).isaseg := 1;

            IF pac_iax_simulaciones.isparammismo_aseg = FALSE
            THEN                                                   --Bug 7581
               vpasexec := 13;

               IF comprovanumtomaseg (psperson, mensajes) != 1
               THEN
                  nerr :=
                     pac_iax_produccion.f_insertasegurado (psperson,
                                                           NULL,
                                                           mensajes
                                                          );
               END IF;

               IF nerr <> 0
               THEN
                  RAISE e_object_error;
               END IF;
            END IF;                                                 --Bug 7581
         END IF;

         ppregun := 0;
      -- Bug 33515 nota 200270
      ELSIF    v_mismoaseg = 4
            OR (v_mismoaseg IN (2, 5) AND v_mismoaseg_simul = 1)
      THEN                                                 --Si, persona fsica
         -- Bug 33515 nota 200270
         IF     toma (toma.LAST).sperson = psperson  --JRH roma.LAST en lugar de TOMA.FIRST
            AND NVL (toma (toma.LAST).ctipper, 0) = 1
         THEN
            toma (toma.LAST).isaseg := 1;

            IF pac_iax_simulaciones.isparammismo_aseg = FALSE
            THEN                                                   --Bug 7581
               vpasexec := 15;

               IF pac_iax_simulaciones.comprovanumtomaseg (psperson,
                                                           mensajes) != 1
               THEN
                  nerr :=
                     pac_iax_produccion.f_insertasegurado (psperson,
                                                           NULL,
                                                           mensajes
                                                          );

                  IF nerr <> 0
                  THEN
                     --nerr := 0; Bug 20307 - 20/12/2011 - AMC
                     --XPL 10/02/2010 Bug 12727 , es comenta per tal que sortir els missatges per pantalla quan hi hagi errors
                     -- mensajes.DELETE;
                     toma (toma.LAST).isaseg := 0;
                  END IF;
               END IF;
            END IF;                                                 --BUG 7581
         END IF;

         ppregun := 0;
      ELSIF v_mismoaseg IN (2, 5)
      THEN                                                          --Pregunta
         ppregun := 1;
      ELSIF v_mismoaseg = 3
      THEN                                                         --No, nunca
         ppregun := 0;
      ELSIF v_mismoaseg = 6 THEN
        IF toma(toma.LAST).sperson = psperson
        THEN
          --
          toma(toma.LAST).isaseg := 1;
          --
          IF pac_iax_simulaciones.isparammismo_aseg = FALSE
          THEN
             --
             vpasexec := 40;
             --
             IF comprovanumtomaseg (psperson, mensajes) != 1 THEN
                nerr := pac_iax_produccion.f_insertasegurado (psperson, NULL, mensajes);
             END IF;
             --
             IF nerr <> 0 THEN
                RAISE e_object_error;
             END IF;
             --
          END IF;
          --
        END IF;
        --
        ppregun := 0;
        --
      END IF;

      -- 2 CABEZAS ACC 040308
      vpasexec := 17;
      pac_iax_produccion.poliza.det_poliza.tomadores := toma;

      -- Actualitzaci de l'idioma per defecte de la plissa
      -- en funci de l'idioma per defecte del primer prenedor
      IF pac_iax_produccion.poliza.det_poliza.tomadores.COUNT = 1
      THEN
         -- Si l'idioma del prenedor s null, s'agafa el de l' empresa.#6.
         pac_iax_produccion.poliza.det_poliza.gestion.cidioma :=
            NVL
               (pac_iax_produccion.poliza.det_poliza.tomadores
                         (pac_iax_produccion.poliza.det_poliza.tomadores.FIRST).cidioma,
                pac_parametros.f_parempresa_n (pac_md_common.f_get_cxtempresa,
                                               'IDIOMA_DEF'
                                              )
               );
      END IF;

      --Bug 20307 - 20/12/2011 - AMC
      IF nerr <> 0
      THEN
         RAISE e_object_error;
      END IF;

      --Fi Bug 20307 - 20/12/2011 - AMC
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
   END f_inserttomadores;

/*************************************************************************
 Graba el asegurado
 param in psperson : número de persona
 param in pcsexper : sexo de la persona
 param in pfnacimi : fecha nacimiento
 param in pnnumnif : número identificación persona
 param in tnombre : nombre de la persona
 param in tnombre1 : primer nombre de la persona
 param in tnombre2 : segundo nombre de la persona
 param in tapelli1 : primer apellido
 param in tapelli2 : segundo apellido
 param in pctipide : Tipo de identificación persona V.F. 672
 param in pctipper : Tipo de persona V.F. 85
 param out : mensajes de error
 return : 0 todo correcto
 1 ha habido un error

 Bug 25378/137309 - 18/02/2013 - AMC, Se a�ade los parametros pcpoblac,pcprovin,pcpais
 *************************************************************************/
   FUNCTION f_grabatomadores(
      psperson      IN       NUMBER,
      pcsexper      IN       NUMBER,
      pfnacimi      IN       DATE,
      pnnumnif      IN       VARCHAR2,
      ptnombre      IN       VARCHAR2,
      ptnombre1     IN       VARCHAR2,
      ptnombre2     IN       VARCHAR2,
      ptapelli1     IN       VARCHAR2,
      ptapelli2     IN       VARCHAR2,
      pctipide      IN       NUMBER,
      pctipper      IN       NUMBER,
      pcdomici      IN       NUMBER,
      pcpoblac      IN       NUMBER,
      pcprovin      IN       NUMBER,
      pcpais        IN       NUMBER,
      pcocupacion   IN       NUMBER,
      pcestciv      IN       NUMBER,
      mensajes      OUT      t_iax_mensajes
   )
      RETURN NUMBER
   IS
      nerr                NUMBER           := 0;
      vsperson            NUMBER;
      mjs                 t_iax_mensajes;
      tom                 t_iax_tomadores;
      det_poliza          ob_iax_detpoliza;
      vpasexec            NUMBER (8)       := 1;
      pduplicada          NUMBER;
      vparam              VARCHAR2 (500)
         :=    'psperson='
            || psperson
            || ' pcsexper='
            || pcsexper
            || ' pfnacimi='
            || pfnacimi
            || ' pnnumnif='
            || pnnumnif
            || ' ptnombre='
            || ptnombre
            || ' ptapelli1='
            || ptapelli1
            || ' ptapelli2='
            || ptapelli2
            || ' pctipide='
            || pctipide
            || ' pctipper='
            || pctipper
            || ' pcestciv='
            || pcestciv;
      vobject             VARCHAR2 (200)
                                    := 'PAC_IAX_SIMULACIONES.f_grabatomadores';
      v_ppregun           NUMBER;
      vcdomici            NUMBER;
      vosperson           NUMBER;
      vperreal            NUMBER;
      v_mismoaseg_simul   NUMBER;
   BEGIN
      det_poliza := pac_iobj_prod.f_getpoliza (mensajes);

      IF det_poliza IS NULL
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, 1000644);
                                      --'No se ha inicializado correctamente'
         RAISE e_param_error;
      END IF;

      vpasexec := 2;

      --Bug 20499/100655 - 15/12/2011 - AMC
      /*IF NVL(pcsexper, 0) = 0 THEN
      pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9000771); --'Debe informar del sexo de la persona.'
      RAISE e_param_error;
      END IF;

      vpasexec := 3;

      IF NVL(TO_CHAR(pfnacimi), ' ') = ' ' THEN
      pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9000772); --'Debe informar de la fecha nacimiento de la persona.'
      RAISE e_param_error;
      END IF;*/
      --Fi Bug 20499/100655 - 15/12/2011 - AMC
      IF NVL (psperson, 0) = 0
      THEN
         vpasexec := 4;

         IF pnnumnif IS NOT NULL
         THEN
            -- Bug 18668 - APD - 07/06/2011 - se valida que el nnumide sea correcto
            nerr :=
               pac_md_persona.f_validanif (pnnumnif,
                                           pctipide,
                                           pcsexper,
                                           pfnacimi,
                                           mensajes
                                          );

            IF nerr <> 0
            THEN
               pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, nerr);
               RAISE e_object_error;
            END IF;

            -- Fin Bug 18668 - APD - 07/06/2011
            nerr :=
               pac_md_persona.f_persona_duplicada (psperson,
                                                   pnnumnif,
                                                   pcsexper,
                                                   pfnacimi,
                                                   NULL,
                                                   NULL,
                                                   NULL,
                                                   pctipide,
                                                   pduplicada,
                                                   mensajes,
                                                   det_poliza.sseguro
                                                  );
                                         --BUG 29268/160635 - RCL - 25/12/2013

            IF pduplicada <> 0
            THEN
               nerr := 9001806;
               pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, nerr);
               RAISE e_object_error;
            END IF;
         END IF;

         --Bug 23510 - XVM - 18/10/2012 Se a�ade par�metro cagente
         -- Bug 25378/137309 - 18/02/2013 - AMC
         nerr :=
            pac_md_simulaciones.f_grabaasegurados (det_poliza.sseguro,
                                                   pcsexper,
                                                   pfnacimi,
                                                   pnnumnif,
                                                   ptnombre,
                                                   ptnombre1,
                                                   ptnombre2,
                                                   ptapelli1,
                                                   ptapelli2,
                                                   pctipide,
                                                   pctipper,
                                                   det_poliza.cagente,
                                                   vsperson,
                                                   pcocupacion,
                                                   pcestciv,
                                                   mensajes
                                                  );
         vpasexec := 5;
         nerr :=
             pac_iax_simulaciones.f_inserttomadores (vsperson, mjs, v_ppregun);

         IF nerr > 0
         THEN
            vpasexec := 6;
            pac_iobj_mensajes.p_mergemensaje (mensajes, mjs);
         END IF;

         IF mensajes IS NOT NULL
         THEN
            IF mensajes.COUNT > 0
            THEN
               vpasexec := 7;
               RAISE e_object_error;
            END IF;
         END IF;

         vcdomici := pcdomici;

         IF pcdomici = -1
         THEN
            vcdomici := NULL;
         END IF;

         IF vsperson IS NOT NULL
         THEN
            nerr :=
               pac_iax_persona.f_set_estdireccion
                                              (vsperson,
                                               pac_md_common.f_get_cxtidioma,
                                               vcdomici,
                                               vcdomici,
                                               99,
                                               NULL,
                                               NULL,
                                               NULL,
                                               NULL,
                                               NULL,
                                               pcpoblac,
                                               pcprovin,
                                               pcpais,
                                               NULL,
                                               NULL,
                                               NULL,
                                               NULL,
                                               NULL,
                                               NULL,
                                               NULL,
                                               NULL,
                                               NULL,
                                               NULL,
                                               NULL,
                                               NULL,
                                               NULL,
                                               NULL,
                                               NULL,
                                               NULL,
                                               mensajes
                                              );

            IF nerr > 0
            THEN
               vpasexec := 6;
               pac_iobj_mensajes.p_mergemensaje (mensajes, mjs);
               RAISE e_object_error;
            END IF;
         END IF;
      -- Fi Bug 25378/137309 - 18/02/2013 - AMC
      ELSE
 -- bug 26380/140307 - 12/03/2013 - AMC
-- nerr := pac_persona.f_existe_persona(pac_md_common.f_get_cxtempresa, pnnumnif,
-- pcsexper, pfnacimi, vperreal, NULL);
         vpasexec := 2;
         vsperson := psperson;
-- nerr := pac_md_persona.f_set_persona(det_poliza.sseguro, vsperson, vperreal,
-- det_poliza.cagente, pctipper, pctipide,
-- pnnumnif, pcsexper, pfnacimi, NULL, 99, NULL,
-- NULL, NULL, NULL, pac_md_common.f_get_cxtidioma,
-- ptapelli1, ptapelli2, ptnombre, NULL, NULL,
-- NULL,
-- pac_parametros.f_parinstalacion_n('PAIS_DEF'),
-- 'EST', 0, NULL, ptnombre1, ptnombre2, NULL,
-- pcocupacion, mensajes);

         -- IF mensajes IS NOT NULL THEN
-- IF mensajes.COUNT > 0 THEN
-- RETURN 1;
-- END IF;
-- END IF;
         v_mismoaseg_simul :=
            NVL
               (pac_iaxpar_productos.f_get_parproducto
                                 ('MISMO_ASEG_SIMUL',
                                  pac_iax_produccion.poliza.det_poliza.sproduc
                                 ),
                0
               );

         IF (v_mismoaseg_simul = 1 AND NVL (pctipper, 0) = 1)
         THEN
            nerr :=
                   pac_iax_produccion.f_insertasegurado (vsperson, NULL, mjs);

            IF nerr > 0
            THEN
               vpasexec := 6;
               pac_iobj_mensajes.p_mergemensaje (mensajes, mjs);
            END IF;

            IF mensajes IS NOT NULL
            THEN
               IF mensajes.COUNT > 0
               THEN
                  vpasexec := 7;
                  RAISE e_object_error;
               END IF;
            END IF;
         END IF;

         IF pcdomici IS NULL AND vsperson IS NOT NULL
         THEN
            nerr :=
               pac_iax_persona.f_set_estdireccion
                                              (vsperson,
                                               pac_md_common.f_get_cxtidioma,
                                               vcdomici,
                                               vcdomici,
                                               99,
                                               NULL,
                                               NULL,
                                               NULL,
                                               NULL,
                                               NULL,
                                               pcpoblac,
                                               pcprovin,
                                               pcpais,
                                               NULL,
                                               NULL,
                                               NULL,
                                               NULL,
                                               NULL,
                                               NULL,
                                               NULL,
                                               NULL,
                                               NULL,
                                               NULL,
                                               NULL,
                                               NULL,
                                               NULL,
                                               NULL,
                                               NULL,
                                               NULL,
                                               mensajes
                                              );

            IF nerr > 0
            THEN
               vpasexec := 6;
               pac_iobj_mensajes.p_mergemensaje (mensajes, mjs);
               RAISE e_object_error;
            END IF;
         END IF;
      -- vsperson := psperson;
      -- Fi bug 26380/140307 - 12/03/2013 - AMC
      END IF;

      vpasexec := 8;
      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
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
   END f_grabatomadores;

   /*************************************************************************
   Graba la simulación
   param out : mensajes de error
   return : 0 todo correcto
   1 ha habido un error
   *************************************************************************/
   FUNCTION f_grabarsimulacion(mensajes OUT t_iax_mensajes)
      RETURN NUMBER
   IS
      nerr         NUMBER           := 0;
      det_poliza   ob_iax_detpoliza;
      vpasexec     NUMBER (8)       := 1;
      vparam       VARCHAR2 (1)     := NULL;
      vobject      VARCHAR2 (200)
                                 := 'PAC_IAX_SIMULACIONES.F_GrabarSimulacion';
      vtexto       VARCHAR2 (400);
      vidioma      NUMBER           := pac_md_common.f_get_cxtidioma ();
   BEGIN
      det_poliza := pac_iobj_prod.f_getpoliza (mensajes);
      vpasexec := 2;

      IF det_poliza IS NULL
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, 1000644);
                                      --'No se ha inicializado correctamente'
         RAISE e_param_error;
      END IF;

      vpasexec := 3;
      nerr := f_validaciones ('GUARDAR_SIMULACION', mensajes);

      IF nerr > 0
      THEN
         RETURN nerr;
      END IF;

      vpasexec := 4;

      IF det_poliza.tomadores IS NOT NULL AND det_poliza.tomadores.COUNT > 0
      THEN
         pac_iax_produccion.isneedtom := TRUE;
      END IF;

      nerr := pac_iax_produccion.f_grabarobjetodb (mensajes);

      IF nerr = 1
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, 9000773);
                  --'No se ha podido almecenar la información correctamente'
         vpasexec := 5;
         RAISE e_object_error;
      END IF;

      vpasexec := 6;
      det_poliza := pac_iobj_prod.f_getpoliza (mensajes);
                                                        -- bug 7535 ACC 180209
      vpasexec := 7;
      nerr :=
          pac_md_simulaciones.f_set_simulestudi (det_poliza.sseguro, mensajes);
      det_poliza.csituac := 7;

      IF nerr = 0
      THEN
         vpasexec := 8;
         --vtexto := F_AXIS_LITERALES(9000774,vidioma); --'Se ha guardado correctamente la simulación con número '
         vtexto := pac_iobj_mensajes.f_get_descmensaje (9000774, vidioma);
                 --'Se ha guardado correctamente la simulación con número '
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes,
                                               2,
                                               9000774,
                                                  vtexto
                                               || ' '
                                               || pac_iax_produccion.vsolicit
                                              );
      END IF;

      vpasexec := 9;
      isconsultsimul := TRUE;
      vpasexec := 10;
      det_poliza.p_set_needtarificar (0);                --bug 7535 ACC 180209
      vpasexec := 11;
      pac_iobj_prod.p_set_poliza (det_poliza);          -- bug 7535 ACC 180209
      vpasexec := 12;
      pac_iax_produccion.issave := TRUE;
      simulacion := ob_iax_poliza ();
      simulacion.det_poliza := det_poliza;
      -- Bug 20995 - RSC - 26/01/2012 - LCOL - UAT - TEC - Incidencias de Contratacion
      COMMIT;
      -- Fin Bug 20995
      RETURN nerr;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN e_object_error
      THEN
         -- Bug 20995 - RSC - 26/01/2012 - LCOL - UAT - TEC - Incidencias de Contratacion
         ROLLBACK;
         -- Fin Bug 20995
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN OTHERS
      THEN
         -- Bug 20995 - RSC - 26/01/2012 - LCOL - UAT - TEC - Incidencias de Contratacion
         ROLLBACK;
         -- Fin bug 20995
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN 1;
   END f_grabarsimulacion;

   /*************************************************************************
   Graba la simulaciÃ³n sin validaciones
   param out : mensajes de error
   return : 0 todo correcto
   1 ha habido un error
   *************************************************************************/
   FUNCTION f_grabarsimulacion_sinvalidar(mensajes OUT t_iax_mensajes)
      RETURN NUMBER
   IS
      nerr         NUMBER           := 0;
      det_poliza   ob_iax_detpoliza;
      vpasexec     NUMBER (8)       := 1;
      vparam       VARCHAR2 (1)     := NULL;
      vobject      VARCHAR2 (200)
                      := 'PAC_IAX_SIMULACIONES.F_GrabarSimulacion_SinValidar';
      vtexto       VARCHAR2 (400);
      vidioma      NUMBER           := pac_md_common.f_get_cxtidioma ();
   BEGIN
      det_poliza := pac_iobj_prod.f_getpoliza (mensajes);
      vpasexec := 2;

      IF det_poliza IS NULL
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, 1000644);
                                      --'No se ha inicializado correctamente'
         RAISE e_param_error;
      END IF;

      vpasexec := 3;

      IF det_poliza.tomadores IS NOT NULL AND det_poliza.tomadores.COUNT > 0
      THEN
         pac_iax_produccion.isneedtom := TRUE;
      END IF;

      nerr := pac_iax_produccion.f_grabarobjetodb (mensajes);

      IF nerr = 1
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, 9000773);
                --'No se ha podido almecenar la informaciÃ³n correctamente'
         vpasexec := 4;
         RAISE e_object_error;
      END IF;

      vpasexec := 5;
      det_poliza := pac_iobj_prod.f_getpoliza (mensajes);
                                                        -- bug 7535 ACC 180209
      vpasexec := 6;
      nerr :=
          pac_md_simulaciones.f_set_simulestudi (det_poliza.sseguro, mensajes);
      det_poliza.csituac := 7;

      IF nerr = 0
      THEN
         vpasexec := 7;
         --vtexto := F_AXIS_LITERALES(9000774,vidioma); --'Se ha guardado correctamente la simulaciÃ³n con nÃºmero '
         vtexto := pac_iobj_mensajes.f_get_descmensaje (9000774, vidioma);
             --'Se ha guardado correctamente la simulaciÃ³n con nÃºmero '
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes,
                                               2,
                                               9000774,
                                                  vtexto
                                               || ' '
                                               || pac_iax_produccion.vsolicit
                                              );
      END IF;

      vpasexec := 8;
      isconsultsimul := TRUE;
      vpasexec := 9;
      det_poliza.p_set_needtarificar (0);                --bug 7535 ACC 180209
      vpasexec := 10;
      pac_iobj_prod.p_set_poliza (det_poliza);          -- bug 7535 ACC 180209
      vpasexec := 11;
      pac_iax_produccion.issave := TRUE;
      simulacion := ob_iax_poliza ();
      simulacion.det_poliza := det_poliza;
      -- Bug 20995 - RSC - 26/01/2012 - LCOL - UAT - TEC - Incidencias de Contratacion
      COMMIT;
      -- Fin Bug 20995
      RETURN nerr;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN e_object_error
      THEN
         -- Bug 20995 - RSC - 26/01/2012 - LCOL - UAT - TEC - Incidencias de Contratacion
         ROLLBACK;
         -- Fin Bug 20995
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN OTHERS
      THEN
         -- Bug 20995 - RSC - 26/01/2012 - LCOL - UAT - TEC - Incidencias de Contratacion
         ROLLBACK;
         -- Fin bug 20995
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN 1;
   END f_grabarsimulacion_sinvalidar;

   /*************************************************************************
   Elimina un riesgo
   param in pnriesgo : número de riesgo
   param out mensajes : mensajes de error
   return : 0 todo ha sido correcto
   1 ha habido un error
   *************************************************************************/
   FUNCTION f_eliminariesgo(pnriesgo IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER
   IS
      nerr       NUMBER;
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (100) := 'pnriesgo=' || pnriesgo;
      vobject    VARCHAR2 (200) := 'PAC_IAX_SIMULACIONES.F_EliminaRiesgo';
   BEGIN
      nerr := pac_iax_produccion.f_eliminariesgo (pnriesgo, mensajes);
      RETURN nerr;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
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
   END f_eliminariesgo;

   PROCEDURE p_renumriesgo (
      ries       IN OUT   t_iax_riesgos,
      mensajes   IN OUT   t_iax_mensajes
   )
   IS
      nrie       NUMBER           := 0;
      naseg      NUMBER           := 0;
      vpasexec   NUMBER           := 1;
      aseg       t_iax_asegurados;
      vparam     VARCHAR2 (500)   := 'valors risc';
      vobject    VARCHAR2 (200)   := 'PAC_IAX_PRODUCCION.P_RENUMRIESGO';
   BEGIN
      IF ries IS NOT NULL
      THEN
         IF ries.COUNT > 0
         THEN
            FOR vrie IN ries.FIRST .. ries.LAST
            LOOP
               vpasexec := 2;

               IF ries.EXISTS (vrie)
               THEN
                  vpasexec := 3;
                  nrie := nrie + 1;
                  ries (vrie).nriesgo := nrie;
                  aseg :=
                     pac_iobj_prod.f_partriesasegurado (ries (vrie),
                                                        mensajes);
                  vpasexec := 4;

                  IF aseg IS NOT NULL
                  THEN
                     IF aseg.COUNT > 0
                     THEN
                        vpasexec := 8;
                        naseg := 0;

                        FOR vaseg IN aseg.FIRST .. aseg.LAST
                        LOOP
                           vpasexec := 9;

                           IF aseg.EXISTS (vaseg)
                           THEN
                              vpasexec := 10;

                              IF pac_iax_produccion.poliza.det_poliza.csubpro =
                                                                            2
                              THEN
                                 aseg (vaseg).norden := ries (vrie).nriesgo;
                              ELSE
                                 naseg := naseg + 1;
                                 aseg (vaseg).norden := naseg;
                              END IF;

                              vpasexec := 11;
                              aseg (vaseg).nriesgo := ries (vrie).nriesgo;
                              ries (vrie).riesgoase := aseg;
                           END IF;
                        END LOOP;
                     END IF;
                  END IF;
               END IF;
            END LOOP;
         END IF;
      END IF;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
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
   END p_renumriesgo;

   -- BUG 14599 - PFA - Ajuste pantalla simulación (Rentas)
   /*************************************************************************
   Elimina un asegurado
   param in sperson : identificador del asegurado
   param out mensajes : mensajes de error
   return : 0 todo ha sido correcto
   1 ha habido un error
   *************************************************************************/
   FUNCTION f_eliminaaseg(psperson IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER
   IS
      nerr             NUMBER;
      vpasexec         NUMBER (8)       := 1;
      vparam           VARCHAR2 (100)   := 'psperson=' || psperson;
      vobject          VARCHAR2 (200) := 'PAC_IAX_SIMULACIONES.F_EliminaAseg';
      aseg             t_iax_asegurados;
      rip              t_iax_personas;
      ries             t_iax_riesgos;
      rie              ob_iax_riesgos;
      ndel             NUMBER           := 0;
                                       -- per saber si sha trobat el asegurat
      msj              t_iax_mensajes;
      msjt             t_iax_mensajes;
      veliminariesgo   NUMBER           := 0;
   BEGIN
      IF pac_iax_produccion.poliza.det_poliza IS NULL
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, 1000644);
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      ries :=
         pac_iobj_prod.f_partpolriesgos (pac_iax_produccion.poliza.det_poliza,
                                         mensajes
                                        );

      IF ries IS NULL
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, 9001040);
         vpasexec := 3;
         RAISE e_object_error;
      ELSE
         IF ries.COUNT = 0
         THEN
            pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, 9001040);
            vpasexec := 4;
            RAISE e_object_error;
         END IF;
      END IF;

      vpasexec := 5;

      IF mensajes IS NOT NULL
      THEN
         IF mensajes.COUNT > 0
         THEN
            vpasexec := 6;
            RAISE e_object_error;
         END IF;
      END IF;

      vpasexec := 7;

      FOR vrie IN ries.FIRST .. ries.LAST
      LOOP
         vpasexec := 8;

         IF ries.EXISTS (vrie)
         THEN
            --ACC 29122008 controlar no mostrar assegurat baixa
            IF ries (vrie).fanulac IS NULL AND ries (vrie).nmovimb IS NULL
            THEN
               vpasexec := 9;
               aseg :=
                    pac_iobj_prod.f_partriesasegurado (ries (vrie), mensajes);
               vpasexec := 10;

               IF pac_iax_produccion.poliza.det_poliza.cobjase != 5
               THEN
                  IF aseg IS NULL
                  THEN
                     pac_iobj_mensajes.crea_nuevo_mensaje (mensajes,
                                                           1,
                                                           9001041
                                                          );
                     vpasexec := 11;
                     RAISE e_object_error;
                  ELSE
                     IF aseg.COUNT = 0
                     THEN
                        pac_iobj_mensajes.crea_nuevo_mensaje (mensajes,
                                                              1,
                                                              9001041
                                                             );
                        vpasexec := 12;
                        RAISE e_object_error;
                     END IF;
                  END IF;

                  IF mensajes IS NOT NULL
                  THEN
                     IF mensajes.COUNT > 0
                     THEN
                        vpasexec := 13;
                        RAISE e_object_error;
                     END IF;
                  END IF;
               END IF;

               vpasexec := 14;

               IF aseg IS NOT NULL AND aseg.COUNT > 0
               THEN
                  FOR vaseg IN aseg.FIRST .. aseg.LAST
                  LOOP
                     vpasexec := 15;

                     IF aseg.EXISTS (vaseg)
                     THEN
                        vpasexec := 16;

                        IF aseg (vaseg).sperson = psperson
                        THEN
                           vpasexec := 17;
                           aseg.DELETE (vaseg);
                           ndel := 1;
                           --ACC 13122008
                           ries (vrie).riesgoase := aseg;

                           IF ries (vrie).riesgoase.COUNT = 0
                           THEN
                              veliminariesgo := 1;
                           -- INI RLLF 31102014 Modificar el riesgo con el asegurado que ha quedado despu�s de eliminar.
                           ELSE
                              ries (vrie).riespersonal
                                                (ries (vrie).riespersonal.LAST
                                                ).sperson :=
                                                      aseg (aseg.LAST).sperson;
                           -- FIN RLLF 31102014 Modificar el riesgo con el asegurado que ha quedado despu�s de eliminar.
                           END IF;

                           vpasexec := 19;
                           --ACC 13122008 fi modificació afegir condició
                           EXIT;
                        END IF;
                     END IF;
                  END LOOP;
               END IF;

               vpasexec := 21;

               IF pac_iax_produccion.poliza.det_poliza.cobjase != 5
               THEN
                  rip :=
                     pac_iobj_prod.f_partriespersonal (ries (vrie), mensajes);

                  IF rip IS NULL
                  THEN
                     pac_iobj_mensajes.crea_nuevo_mensaje (mensajes,
                                                           1,
                                                           9001085
                                                          );
                     vpasexec := 22;
                     RAISE e_object_error;
                  ELSE
                     IF rip.COUNT = 0
                     THEN
                        pac_iobj_mensajes.crea_nuevo_mensaje (mensajes,
                                                              1,
                                                              9001085
                                                             );
                        vpasexec := 23;
                        RAISE e_object_error;
                     END IF;
                  END IF;

                  IF mensajes IS NOT NULL
                  THEN
                     IF mensajes.COUNT > 0
                     THEN
                        vpasexec := 24;
                        RAISE e_object_error;
                     END IF;
                  END IF;
               END IF;

               vpasexec := 25;
            END IF;                                             --ACC 29122008
         END IF;
      END LOOP;

      vpasexec := 29;

      --// S'ha de recorrer tots els riscos per modificar el número de risc corresponent
      IF ndel = 1
      THEN
         p_renumriesgo (ries, mensajes);
      END IF;

      vpasexec := 30;
      pac_iax_produccion.poliza.det_poliza.riesgos := ries;
      vpasexec := 31;

      IF     veliminariesgo = 1
         AND pac_iax_produccion.poliza.det_poliza.cobjase != 5
      THEN
         pac_iax_produccion.poliza.det_poliza.riesgos.DELETE;
      END IF;

      /* IF ndel = 0 THEN
      pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9001086);
      RETURN 1;
      END IF;*/
      vpasexec := 32;
      -- indicar se s'ha de tarificar només val per primes
      pac_iax_produccion.poliza.det_poliza.p_set_needtarificar (1);
      RETURN nerr;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
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
   END f_eliminaaseg;

--Fi BUG 14599 - PFA - Ajuste pantalla simulación (Rentas)

   /*************************************************************************
   Recupera el número de solicitud
   param out mensajes : mensajes de error
   return : número de solicitud
   *************************************************************************/
   FUNCTION f_get_codigosimul(mensajes OUT t_iax_mensajes)
      RETURN NUMBER
   IS
      det_poliza   ob_iax_detpoliza;
      vpasexec     NUMBER (8)       := 1;
      vparam       VARCHAR2 (100)   := NULL;
      vobject      VARCHAR2 (200) := 'PAC_IAX_SIMULACIONES.F_Get_CodigoSimul';
   BEGIN
      det_poliza := pac_iobj_prod.f_getpoliza (mensajes);

      IF NOT contracsimul
      THEN
         pac_iax_produccion.issimul := TRUE;
         pac_iax_produccion.isneedtom := FALSE;
         contracsimul := FALSE;                        --BUG9427-02042009-XVM
      END IF;

      IF det_poliza IS NULL
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, 1000644);
                                      --'No se ha inicializado correctamente'
         RAISE e_param_error;
      END IF;

      RETURN det_poliza.sseguro;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
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
   END f_get_codigosimul;

   /*************************************************************************
   Borra los registros de las tablas est
   *************************************************************************/
   -- Bug 27429 - 10/02/2014 - JTT: Tenemos en cuenta el estado rechazado
   PROCEDURE limpiartemporales
   IS
      mensajes   t_iax_mensajes;
      nerr       NUMBER;
   BEGIN
      IF isconsultsimul = FALSE
      THEN
         pac_iax_produccion.limpiartemporales;
      ELSE
         IF simulacion IS NOT NULL
         THEN
            pac_iax_produccion.poliza := simulacion;

            IF (pac_iax_produccion.poliza.det_poliza.csituac = 10)
            THEN                              --  Rechazado   Bug 27429 - JTT
               NULL;
            ELSE
               pac_iax_produccion.poliza.det_poliza.csituac := -1;
            END IF;

            --PAC_MD_PRODUCCION.Borrar_Tablas_Est(PAC_IAX_PRODUCCION.vsolicit,mensajes);
            --COMMIT;
            -- Bug 18848 - APD - 08/09/2011 - variable que nos indicara en la funcion
            -- pac_md_grabardatos.f_grabargarantia si se estan insertando de nuevo los
            -- datos que habia al principio debido a que se ha pulsado el boton Cancelar
            islimpiartemporales := TRUE;
            nerr :=
               pac_md_produccion.f_borra_datos_prod_simul
                                                 (pac_iax_produccion.vsolicit,
                                                  pac_iax_produccion.vnmovimi,
                                                  mensajes
                                                 );
            nerr := pac_iax_produccion.f_grabarobjetodb (mensajes);
            -- BUG 19478 Treiem la crida la funci f_get_personsimul perqu la simulaci es guarda el prenador a esttomadores
            -- nerr := pac_md_produccion.f_get_personsimul(pac_iax_produccion.vsolicit, mensajes);
            -- FI BUG 19478
            -- Bug 18848 - APD - 08/09/2011
            islimpiartemporales := FALSE;
            COMMIT;
         END IF;

         -- Bug 27429 - 10/02/2014 - JTT: Tenim en compte l'estat rebutjat.
         IF simulacion IS NOT NULL
         THEN
            IF (simulacion.det_poliza.csituac = 10)
            THEN                                                 -- Rechazado
               nerr :=
                  pac_md_simulaciones.f_rechazar_simul
                                                (pac_iax_produccion.vsolicit,
                                                 mensajes
                                                );  -- Acualiza el estado a 10
            ELSE
               nerr :=
                  pac_md_simulaciones.f_set_simulestudi
                                                (pac_iax_produccion.vsolicit,
                                                 mensajes
                                                );  -- Actualiza el estado a 7
            END IF;
         END IF;

         -- Fi Bug 27429
         COMMIT;
      END IF;

      simulacion := NULL;
      isconsultsimul := FALSE;
      pac_iax_produccion.issimul := FALSE;
      pac_iax_produccion.issave := FALSE;
      pac_iax_produccion.isneedtom := TRUE;
      pac_iax_produccion.issuplem := FALSE;
      pac_iax_produccion.vsolicit := NULL;
      pac_iax_produccion.poliza := NULL;
      pac_iax_produccion.vpmode := NULL;
      contracsimul := FALSE;                            --BUG9427-02042009-XVM
      mensajes := NULL;
      pac_iax_liquidacor.vtliquida := NULL;
   END;

/************************************************************************
 INICI CONSULTA
************************************************************************/

   /*************************************************************************
   Devuelve las simulaciones que cumplan con el criterio de selección
   param in psproduc : código de producto
   param in psolicit : número de solicitud
   param in ptriesgo : descripción del riesgo
   param out mensajes : mensajes de error
   return : ref cursor
   *************************************************************************/
   -- Bug 10093.NMM.05/11/2009. S'afegeixen 2 camps a la funció.
   -- Bug 27430 - 03/02/2014 - JTT: S'afegeixen els camps pnnumide, pbucar i pfcotiza a la funcio
   FUNCTION f_consultasimul(
      psproduc       IN       NUMBER,
      psolicit       IN       NUMBER,
      ptriesgo       IN       VARCHAR2,
      p_cramo        IN       NUMBER,
      p_filtroprod   IN       VARCHAR2,
      mensajes       OUT      t_iax_mensajes,
      pnnumide       IN       VARCHAR2 DEFAULT NULL,
      pbuscar        IN       VARCHAR2 DEFAULT NULL,
      pfcotiza       IN       DATE DEFAULT NULL,
      pnpoliza       IN       NUMBER
            DEFAULT NULL                      -- Bug 34409/196980 20150420 POS
   )
      RETURN sys_refcursor
   IS
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (1)   := NULL;
      vobject    VARCHAR2 (200) := 'PAC_IAX_SIMULACIONES.F_ConsultaSimul';
      nerr       NUMBER;
      cur        sys_refcursor;
   BEGIN
      simulacion := NULL;
      cur :=
         pac_md_simulaciones.f_consultasimul (psproduc,
                                              psolicit,
                                              pnpoliza,
                                              ptriesgo,
                                              p_cramo,
                                              p_filtroprod,
                                              pnnumide,
                                              pbuscar,
                                              pfcotiza,
                                              mensajes
                                             );
      RETURN cur;
   EXCEPTION
      WHEN e_param_error
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
      WHEN e_object_error
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
   END f_consultasimul;

   /*************************************************************************
   Recupera la solicitud guarda anteriormente
   param in psolicit : código simulación
   param out osproduc : código de producto
   param out mensajes : mensajes de error
   return : 0 todo ha sido correcto
   1 ha habido un error
   *************************************************************************/
   FUNCTION f_recuperasimul(
      psolicit   IN       NUMBER,
      osproduc   OUT      NUMBER,
      mensajes   OUT      t_iax_mensajes
   )
      RETURN NUMBER
   IS
      nerr          NUMBER;
      msj           t_iax_mensajes;
      rie           t_iax_riesgos;
      det_poliza    ob_iax_detpoliza;
      vpasexec      NUMBER (8)       := 1;
      vparam        VARCHAR2 (100)   := 'psolicit=' || psolicit;
      vobject       VARCHAR2 (200)  := 'PAC_IAX_SIMULACIONES.F_RecuperaSimul';
      --
      v_existe      NUMBER;
      v_escertif0   NUMBER;
   BEGIN
      isconsultsimul := TRUE;
      simulacion := NULL;
      pac_iax_produccion.issimul := TRUE;
      pac_iax_produccion.issave := TRUE;
      pac_iax_produccion.isneedtom := FALSE;
      contracsimul := FALSE;                           --BUG9427-02042009-XVM
      vpasexec := 2;
      nerr := pac_iax_produccion.f_set_consultapoliza (psolicit, msj, 'EST');

      IF msj IS NOT NULL
      THEN
         IF msj.COUNT > 0
         THEN
            pac_iobj_mensajes.p_mergemensaje (mensajes, msj);
            vpasexec := 3;
            RAISE e_object_error;
         END IF;
      END IF;

      IF nerr = 0
      THEN
         det_poliza := pac_iobj_prod.f_getpoliza (mensajes);
         rie := det_poliza.riesgos;

         IF rie IS NULL
         THEN
            pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, 9902155);
                             --'No se ha encontrado la simulación indicada.'
            RAISE e_object_error;
         END IF;

         IF rie.COUNT = 0
         THEN
            pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, 9902155);
                             --'No se ha encontrado la simulación indicada.'
            RAISE e_object_error;
         END IF;

         osproduc := det_poliza.sproduc;
         det_poliza.p_set_needtarificar (0);             --bug 7535 ACC 180209
         pac_iobj_prod.p_set_poliza (det_poliza);       -- bug 7535 ACC 180209
      END IF;

      -- Bug 18848 - APD - 27/06/2011 - se llama a la funcion f_valida_simulacion
      -- Al recuperar una simulacin grabada se debe validar si est dentro de la vigencia permitida
      nerr :=
         pac_iax_validaciones.f_valida_simulacion (psolicit,
                                                   det_poliza.nmovimi,
                                                   'EST',
                                                   mensajes
                                                  );

      IF nerr <> 0
      THEN
         RAISE e_object_error;
      END IF;

      -- Fin Bug 18848 - APD - 27/06/2011

      -- Bug 47429 - 30/01/2014 - JTT: Si el estado es Propuesta (4) cambiamos a 7 y actualizamos la tabla de persistencia
      vpasexec := 5;

      IF det_poliza.csituac = 4
      THEN
         nerr :=
            pac_md_simulaciones.f_actualizar_persistencia
                                                         (det_poliza.sseguro,
                                                          mensajes
                                                         );

         IF nerr <> 0
         THEN
            RAISE e_object_error;
         END IF;
      END IF;

      vpasexec := 6;
      -- Fi Bug 27429

      -- omplim les dades de la simulació i la guardem a simulació
      -- per poder recuperar les dades originals al cancelar la edició
      -- de la simulació
      pac_iax_produccion.issave := FALSE;

      -- BUG34409: DRA: 27/05/2015: Si no se inicializa, entonces al grabar un certificado 0, si se selecciona el hijo en simulacion, recupera las preguntas del 0
      IF NVL (f_parproductos_v (osproduc, 'ADMITE_CERTIFICADOS'), 0) = 1
      THEN
         -- vsseguro: en modificaci??e propuestas en el sseguro del certificado 0 en las reales.
         v_existe := pac_seguros.f_get_escertifcero (det_poliza.npoliza);
         v_escertif0 :=
                    pac_seguros.f_get_escertifcero (NULL, det_poliza.ssegpol);

         IF v_escertif0 > 0
         THEN
            pac_iax_produccion.isaltacol := TRUE;
         ELSE
            IF v_existe > 0
            THEN
               pac_iax_produccion.isaltacol := FALSE;
            ELSE
               pac_iax_produccion.isaltacol := TRUE;
            END IF;
         END IF;
      ELSE
         pac_iax_produccion.isaltacol := FALSE;
      END IF;

      -- BUG34409: DRA: 27/05/2015: Fi
      simulacion := ob_iax_poliza ();
      simulacion.det_poliza := det_poliza;
      RETURN nerr;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
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
   END f_recuperasimul;

/************************************************************************
 FI CONSULTA
************************************************************************/

   /************************************************************************
 INICI VALIDACIONS
************************************************************************/

   /*************************************************************************
   Valida datos de simulaciones
   param out mensajes : mensajes de error
   return : 0 todo correcto
   1 ha habido un error
   *************************************************************************/
   FUNCTION f_validaciones(ptipo VARCHAR2, mensajes OUT t_iax_mensajes)
      RETURN NUMBER
   IS
      vpasexec          NUMBER (8)       := 1;
      vparam            VARCHAR2 (1)     := NULL;
      vobject           VARCHAR2 (200)
                                     := 'PAC_IAX_SIMULACIONES.F_Validaciones';
      nerr              NUMBER;
      det_poliza        ob_iax_detpoliza;               --BUG 9195 ACC 240209
      ries              t_iax_riesgos;                  --BUG 9195 ACC 240209
      gars              t_iax_garantias;                --BUG 9195 ACC 240209
      verr_faltriscos   NUMBER (8);
      verr_faltgaran    NUMBER (8);
      verr_falttarifa   NUMBER (8);
   BEGIN
      IF ptipo = 'GUARDAR_SIMULACION'
      THEN
         verr_faltriscos := 9000987;
         verr_faltgaran := 9000988;
         verr_falttarifa := 9000989;
      ELSIF ptipo = 'IMPRIMIR_SIMULACION'
      THEN
         verr_faltriscos := 9001500;
         verr_faltgaran := 9001501;
         verr_falttarifa := 9001502;
      ELSIF ptipo = 'RECHAZAR_SIMULACION'
      THEN
         verr_faltriscos := 9906484;
         verr_faltgaran := 9906483;
         verr_falttarifa := 9906485;
      END IF;

      --BUG 9195 ACC 240209
      det_poliza := pac_iobj_prod.f_getpoliza (mensajes);
      vpasexec := 2;
      ries := pac_iobj_prod.f_partpolriesgos (det_poliza, mensajes);

      IF mensajes IS NOT NULL
      THEN
         IF mensajes.COUNT > 0
         THEN
            vpasexec := 3;
            RAISE e_object_error;
         END IF;
      END IF;

      vpasexec := 4;

      IF ries IS NULL
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, verr_faltriscos);
         vpasexec := 5;
         RETURN 1;
      ELSE
         IF ries.COUNT = 0
         THEN
            pac_iobj_mensajes.crea_nuevo_mensaje (mensajes,
                                                  1,
                                                  verr_faltriscos
                                                 );
            vpasexec := 6;
            RETURN 1;
         END IF;
      END IF;

      vpasexec := 7;

      FOR vrie IN ries.FIRST .. ries.LAST
      LOOP
         vpasexec := 8;

         IF ries.EXISTS (vrie)
         THEN
            gars := pac_iobj_prod.f_partriesgarantias (ries (vrie), mensajes);
            vpasexec := 9;

            IF gars IS NULL
            THEN
               pac_iobj_mensajes.crea_nuevo_mensaje (mensajes,
                                                     1,
                                                     verr_faltgaran
                                                    );
               RETURN 1;
            END IF;

            vpasexec := 10;

            IF gars.COUNT = 0
            THEN
               pac_iobj_mensajes.crea_nuevo_mensaje (mensajes,
                                                     1,
                                                     verr_faltgaran
                                                    );
               RETURN 1;
            END IF;

            vpasexec := 11;

            IF ries (vrie).needtarifar = 1
            THEN
               pac_iobj_mensajes.crea_nuevo_mensaje (mensajes,
                                                     1,
                                                     verr_falttarifa
                                                    );
               RETURN 1;
            END IF;
         END IF;
      END LOOP;                                          --BUG 9195 ACC 240209

      vpasexec := 12;
      nerr := pac_iax_validaciones.f_validadatosgestion (mensajes);

      IF nerr > 0
      THEN
         RETURN nerr;
      END IF;

      vpasexec := 13;

      IF det_poliza.cobjase NOT IN (2, 3, 4, 5)
      THEN                                          -- BUG16436:DRA:03/11/2010
         nerr := pac_iax_validaciones.f_validaasegurados (mensajes);

         IF nerr > 0
         THEN
            RETURN nerr;
         END IF;
      END IF;

      vpasexec := 14;
      nerr := pac_iax_validaciones.f_validadpreggarant (mensajes);

      IF nerr > 0
      THEN
         RETURN nerr;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
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
   END f_validaciones;

/************************************************************************
 FI VALIDACIONS
************************************************************************/

   /*************************************************************************
   Devuelve la pregunta asegurado o tomador
   param out mensajes : mensajes de error
   return : VARCHAR2 la pregunta
   NULL ha habido error
   *************************************************************************/
   FUNCTION f_get_pregasgestom(
      preguntas   OUT   t_iax_mensajes,
      mensajes    OUT   t_iax_mensajes
   )
      RETURN VARCHAR2
   IS
      nerr          NUMBER;
      det_poliza    ob_iax_detpoliza  := pac_iobj_prod.f_getpoliza (mensajes);
      asegurado     ob_iax_asegurados;
      mjs           t_iax_mensajes;
      vcestper      NUMBER;
      vpasexec      NUMBER (8)           := 1;
      vparam        VARCHAR2 (100)       := '';
      vobject       VARCHAR2 (200)
                                 := 'PAC_IAX_SIMULACIONES.F_Get_PregAsgEsTom';
      v_ppregun     NUMBER;
      mensajes2     t_iax_mensajes       := t_iax_mensajes ();
      tomadores     t_iax_tomadores;
      conductores   t_iax_autconductores;
      vnriesgo      NUMBER;
   BEGIN
      -- Bug 27429 - 30/01/2014 - JTT
      nerr :=
         pac_md_simulaciones.f_alta_persistencia_simul (det_poliza.sseguro,
                                                        mensajes
                                                       );

      IF nerr <> 0
      THEN
         RAISE e_object_error;
      END IF;

      vpasexec := 2;

      -- Fi Bug 27429
      IF NVL (pac_iaxpar_productos.f_get_parproducto ('PREG_COND_TOMASEG',
                                                      det_poliza.sproduc
                                                     ),
              0
             ) = 0
      THEN
         IF det_poliza.cobjase <> 1
         THEN
            RETURN NULL;
         END IF;

         asegurado := f_get_aseguradoprimerriesgo (mensajes);

         IF asegurado IS NOT NULL
         THEN
            -- ACC 18092008
            -- s'han de tenir encompte aquest parametres perque ha de insertar el prenador i
            -- assegurat com la mateixa persona sino al passar a nova producció dona error
            -- al tenir el param MISMO_ASEG / 2_CABEZAS ha d'insertar el prenador que alhora ja carrega
            -- el assegurat, sino com fins ara insertar el assegurat sol
            IF (   pac_iaxpar_productos.f_get_parproducto ('2_CABEZAS',
                                                           det_poliza.sproduc
                                                          ) = 1
                OR pac_iaxpar_productos.f_get_parproducto ('MISMO_ASEG',
                                                           det_poliza.sproduc
                                                          ) IN (1, 6)
                OR (    pac_iaxpar_productos.f_get_parproducto
                                                           ('MISMO_ASEG',
                                                            det_poliza.sproduc
                                                           ) = 4
                    AND asegurado.ctipper = 1
                   )
               )
            THEN                                                             --
               isparammismo_aseg := TRUE;
               -- bug 20499/101881 - 28/12/2011 - AMC
               tomadores := pac_iax_produccion.f_leetomadores (mensajes);

               IF    tomadores IS NULL
                  OR (tomadores IS NOT NULL AND tomadores.COUNT = 0)
               THEN
                  IF pac_iax_produccion.f_existtom (asegurado.sperson,
                                                    mensajes
                                                   ) = 0
                  THEN                                        -- Bug 19478 jbn
                     nerr :=
                        pac_iax_produccion.f_inserttomadores
                                                          (asegurado.sperson,
                                                           mjs,
                                                           v_ppregun
                                                          );
                  END IF;

                  IF nerr > 0
                  THEN
                     vpasexec := 6;
                     pac_iobj_mensajes.p_mergemensaje (mensajes, mjs);
                  END IF;

                  IF mensajes IS NOT NULL
                  THEN
                     IF mensajes.COUNT > 0
                     THEN
                        vpasexec := 7;
                        RAISE e_object_error;
                     END IF;
                  END IF;
               END IF;

               -- Fi bug 20499/101881 - 28/12/2011 - AMC
               isparammismo_aseg := FALSE;
               RETURN NULL;
            ELSIF pac_iaxpar_productos.f_get_parproducto ('MISMO_ASEG',
                                                          det_poliza.sproduc
                                                         ) IN (2, 5)
            THEN
               isparammismo_aseg := FALSE;
               --BUG34066 - INICIO 23/11/2015 - DCT
               --Si el tomador esta informado (venimos de simulaci�n),
               --NO debemos preguntar por: '�El tomador es el mismo que el asegurado?
               tomadores := pac_iax_produccion.f_leetomadores (mensajes);

               IF tomadores IS NOT NULL AND tomadores.COUNT <> 0
               THEN
                  RETURN NULL;
               END IF;

               --FIN 23/11/2015 - DCT

               -- BUG 9282 - 05/03/2009 - SBG - Eliminem la comprovaciÃ³ de l'estat de la persona i
               -- fem la pregunta 1000016 independentment de si l'estat val 99 o no.
               RETURN pac_iobj_mensajes.f_get_descmensaje
                                             (1000016,
                                              pac_md_common.f_get_cxtidioma
                                                                           ()
                                             );
            ELSIF    pac_iaxpar_productos.f_get_parproducto
                                                           ('MISMO_ASEG',
                                                            det_poliza.sproduc
                                                           ) = 3
                  OR (    pac_iaxpar_productos.f_get_parproducto
                                                           ('MISMO_ASEG',
                                                            det_poliza.sproduc
                                                           ) = 4
                      AND asegurado.ctipper <> 1
                     )
            THEN
               isparammismo_aseg := FALSE;
               RETURN NULL;
            END IF;

            isparammismo_aseg := FALSE;
            -- BUG 9282 - 05/03/2009 - SBG - Eliminem la comprovaciÃ³ de l'estat de la persona i
            -- fem la pregunta 1000016 independentment de si l'estat val 99 o no.
            RETURN pac_iobj_mensajes.f_get_descmensaje
                                             (1000016,
                                              pac_md_common.f_get_cxtidioma
                                                                           ()
                                             );
         ELSE
            --no existe el asegurado
            pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, 10523);
         END IF;
      ELSE
         conductores :=
            pac_iax_produccion_aut.f_lee_conductores (NVL (vnriesgo, 1),
                                                      mensajes2
                                                     );

         IF conductores IS NOT NULL AND conductores.COUNT > 0
         THEN
            tomadores := pac_iax_produccion.f_leetomadores (mensajes);
            preguntas := t_iax_mensajes ();

            IF tomadores IS NULL OR tomadores.COUNT = 0
            THEN
               preguntas.EXTEND;
               preguntas (preguntas.LAST) := ob_iax_mensajes ();
               preguntas (preguntas.LAST).tiperror := 1;
               preguntas (preguntas.LAST).cerror := 0;
               preguntas (preguntas.LAST).terror :=
                  pac_iobj_mensajes.f_get_descmensaje
                                            (9001176,
                                             pac_md_common.f_get_cxtidioma ()
                                            );
            END IF;

            asegurado := f_get_aseguradoprimerriesgo (mensajes2);

            IF asegurado IS NULL
            THEN
               preguntas.EXTEND;
               preguntas (preguntas.LAST) := ob_iax_mensajes ();
               preguntas (preguntas.LAST).tiperror := 1;
               preguntas (preguntas.LAST).cerror := 1;
               preguntas (preguntas.LAST).terror :=
                  pac_iobj_mensajes.f_get_descmensaje
                                            (9001177,
                                             pac_md_common.f_get_cxtidioma ()
                                            );
            END IF;
         END IF;
      END IF;

      RETURN NULL;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         isparammismo_aseg := FALSE;
         RETURN NULL;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         isparammismo_aseg := FALSE;
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
         isparammismo_aseg := FALSE;
         RETURN NULL;
   END f_get_pregasgestom;

   /*************************************************************************
   Devuelve la pregunta asegurado o tomador
   param in respuesta : Respuesta a la pregunta 1 si, 0 no
   param in pcsituac : Situaci plissa, si s null es deixa la que te per defecte.
   param out mensajes : mensajes de error
   return : 0 Todo bien
   1 ha habido algun error
   *************************************************************************/
   FUNCTION f_emisionsimulacion(
      respuesta   IN       NUMBER,
      pcsituac    IN       NUMBER,
           -- XPL#14/12/2010#BUG 16799: CRT003 - Alta rapida poliza correduria
      mensajes    OUT      t_iax_mensajes
   )
      RETURN NUMBER
   IS
      nerr         NUMBER                 := 1;
      det_poliza   ob_iax_detpoliza   := pac_iobj_prod.f_getpoliza (mensajes);
      riesgos      t_iax_riesgos;
      rie          ob_iax_riesgos;
      ase          t_iax_asegurados;
      asegurado    ob_iax_asegurados;
      personas     t_iax_personas;
      pers         ob_iax_personas;
      vcestper     NUMBER;
      vpasexec     NUMBER (8)             := 1;
      vparam       VARCHAR2 (1000)
                    := 'respuesta: ' || respuesta || 'pcsituac: ' || pcsituac;
      vobject      VARCHAR2 (200)
                                := 'PAC_IAX_SIMULACIONES.F_EmisionSimulacion';
      v_ppregun    NUMBER;
      v_csituac    seguros.csituac%TYPE;
   BEGIN
      --Inici XPL#14/12/2010#BUG 16799: CRT003 - Alta rapida poliza correduria
      IF pcsituac IS NOT NULL
      THEN
         det_poliza.csituac := pcsituac;
         pac_iobj_prod.p_set_poliza (det_poliza);
         pac_iax_produccion.isneedtom := TRUE;
      ELSE                     --pasamos a contrataci�n, cambiamos a propuesta
         det_poliza.csituac := 4;
         pac_iobj_prod.p_set_poliza (det_poliza);
         pac_iax_produccion.isneedtom := TRUE;
      END IF;

      IF det_poliza.riesgos IS NULL OR det_poliza.riesgos.COUNT = 0
      THEN
         vpasexec := 4;
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, 1000441);
                                         --'No existen riesgos en la póliza'
         vpasexec := 5;
         RAISE e_object_error;
      END IF;

      --ini bug 28455#c160498 JDS
      det_poliza.p_set_needtarificar (1);
      det_poliza.riesgos (det_poliza.riesgos.LAST).p_set_needtarificar (1);

      --fi bug 28455#c160498 JDS

      --Fi XPL#14/12/2010#BUG 16799: CRT003 - Alta rapida poliza correduria

      --Comprovem la data d'efecte de la simulació.
      --Si es tracta d'una data anterior a la data d'avui, la tornem a calcular
      IF det_poliza.gestion.fefecto < f_sysdate
      THEN
         vpasexec := 3;
         det_poliza.gestion.fefecto := TRUNC (f_sysdate);
         nerr :=
            pac_md_produccion.f_set_calc_fefecto (det_poliza.sproduc,
                                                  det_poliza.gestion.fefecto,
                                                  mensajes
                                                 );

         IF nerr <> 0
         THEN
            RAISE e_object_error;
         END IF;

         vpasexec := 5;
         --Gravem la nova data d'efecte a la p�lissa que passem a contractar
         nerr :=
            pac_iax_produccion.f_set_fechaefecto (det_poliza.gestion.fefecto,
                                                  mensajes
                                                 );

         IF nerr <> 0
         THEN
            RAISE e_object_error;
         END IF;

         -- 03.07.2013.NMM.i.27499
         IF pac_md_produccion.f_calcula_nrenova
                                            (det_poliza.sproduc,
                                             NVL (det_poliza.gestion.fefecto,
                                                  f_sysdate
                                                 ),
                                             det_poliza,
                                             mensajes
                                            ) <> 0
         THEN
            pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, 1000458);
            RAISE e_object_error;
         ELSE
            pac_iobj_prod.p_set_poliza (det_poliza);
         END IF;
      -- 03.07.2013.NMM.f.27499
      END IF;

      IF det_poliza.cobjase <> 1
      THEN                                                  -- Riesgo personal
         contracsimul := TRUE;                         --BUG9427-02042009-XVM
         pac_iax_produccion.issimul := FALSE;
         RETURN 0;
      END IF;

      vpasexec := 7;
      asegurado := f_get_aseguradoprimerriesgo (mensajes);

      IF asegurado IS NOT NULL
      THEN
         IF respuesta = 1
         THEN
            --Insertar tomador
            vpasexec := 9;
            nerr :=
               pac_iax_produccion.f_inserttomadores (asegurado.sperson,
                                                     mensajes,
                                                     v_ppregun
                                                    );

            IF nerr <> 0
            THEN
               RAISE e_object_error;
            END IF;
         END IF;
      ELSE
         --no existe el asegurado
         vpasexec := 11;
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, 10523);
         RAISE e_object_error;
      END IF;

      --javendano bug 34409/196980 20150420 POS
      IF NVL (pac_mdpar_productos.f_get_parproducto ('ADMITE_CERTIFICADOS',
                                                     det_poliza.sproduc
                                                    ),
              0
             ) = 1
      THEN
         SELECT s.csituac
           INTO v_csituac
           FROM seguros s
          WHERE s.npoliza = det_poliza.npoliza AND s.ncertif = 0;

         IF     pac_seguros.f_soycertifcero (det_poliza.sproduc,
                                             det_poliza.npoliza,
                                             det_poliza.sseguro
                                            ) = 1
            AND v_csituac = 4
         THEN
            pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, 9907894);
--'No se permite realizar la contrataci�n de un certificado hijo estando el certificado 0 en Propuesta de Alta'
            vpasexec := 12;
            RAISE e_object_error;
         END IF;
      END IF;

      --FIN javendano bug 34409/196980 20150420 POS
      contracsimul := TRUE;                             --BUG9427-02042009-XVM
      pac_iax_produccion.issimul := FALSE;
      -- Bug 11165 - 16/09/2009 - AMC
      nerr := pac_iax_produccion.f_simul_prestamoseg (mensajes);
      RETURN 0;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
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
   END f_emisionsimulacion;

   /*************************************************************************
   Recupera el asegurado del primer riesgo
   param out mensajes : mensajes de error
   return : OB_IAX_ASEGURADOS
   *************************************************************************/
   FUNCTION f_get_aseguradoprimerriesgo(mensajes OUT t_iax_mensajes)
      RETURN ob_iax_asegurados
   IS
      nerr         NUMBER;
      det_poliza   ob_iax_detpoliza  := pac_iobj_prod.f_getpoliza (mensajes);
      riesgos      t_iax_riesgos;
      rie          ob_iax_riesgos;
      ase          t_iax_asegurados;
      asegurado    ob_iax_asegurados;
      vcestper     NUMBER;
      vpasexec     NUMBER (8)        := 1;
      vparam       VARCHAR2 (100)    := '';
      vobject      VARCHAR2 (200)
                        := 'PAC_IAX_SIMULACIONES.F_Get_AseguradoPrimerRiesgo';
   BEGIN
      riesgos := pac_iobj_prod.f_partpolriesgos (det_poliza, mensajes);

      IF riesgos IS NULL
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, 9000775);
                                             --'No se han encontrado riesgos'
         RAISE e_object_error;
      END IF;

      IF riesgos.COUNT = 0
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, 9000775);
                                             --'No se han encontrado riesgos'
         RAISE e_object_error;
      END IF;

      vpasexec := 2;

      FOR vcg IN riesgos.FIRST .. riesgos.LAST
      LOOP
         IF riesgos.EXISTS (vcg)
         THEN
            --rie:=PAC_IOBJ_PROD.F_PartPolRiesgo(det_poliza,riesgos.nriesgo,mensajes);
            rie := riesgos (vcg);
            EXIT;
         END IF;
      END LOOP;

      IF rie IS NOT NULL
      THEN
         vpasexec := 3;
         ase := rie.riesgoase;

         FOR vaseg IN ase.FIRST .. ase.LAST
         LOOP
            IF ase.EXISTS (vaseg)
            THEN
               asegurado := ase (vaseg);
               EXIT;
            END IF;
         END LOOP;

         IF asegurado IS NOT NULL
         THEN
            RETURN asegurado;
         ELSE
            --no existe el asegurado
            pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, 10523);
         END IF;
      ELSE
         --no existe el riesgo
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, 103836);
      END IF;

      RETURN NULL;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
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
   END f_get_aseguradoprimerriesgo;

   -- Bug 9642 - 25/06/2009 - AMC
   /*************************************************************************
   Comprueba si la persona que viene de simulacion es ficticia
   param in psperson : código de la persona
   param in psproduc : código del producto
   param out pficti : indica si es ficticia
   param out mensajes : mensajes de error
   return : NUMBER
   *************************************************************************/
   FUNCTION f_actmodtom(
      psperson   IN       NUMBER,
      psproduc   IN       NUMBER,
      pficti     OUT      NUMBER,
      mensajes   OUT      t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vcestper   NUMBER;
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (100) := '';
      vobject    VARCHAR2 (200) := 'PAC_IAX_SIMULACIONES.f_actmodtom';
      num_err    NUMBER;
   BEGIN
      IF psperson IS NULL OR psproduc IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      num_err :=
         pac_md_simulaciones.f_actmodtom (psperson, psproduc, pficti,
                                          mensajes);

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
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
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
   END f_actmodtom;

-- Fi Bug 9642 - 25/06/2009 - AMC
 /*************************************************************************
 Elimina un tomador
 param in sperson : identificador del asegurado
 param out mensajes : mensajes de error
 return : 0 todo ha sido correcto
 1 ha habido un error
 *************************************************************************/
   FUNCTION f_eliminatomador(psperson IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER
   IS
      nerr             NUMBER           := 0;
      vpasexec         NUMBER (8)       := 1;
      vparam           VARCHAR2 (100)   := 'psperson=' || psperson;
      vobject          VARCHAR2 (200)
                                   := 'PAC_IAX_SIMULACIONES.F_EliminaTOMADOR';
      veliminariesgo   NUMBER           := 0;
      det_poliza       ob_iax_detpoliza;
      v_mismoaseg      NUMBER;
      ries             t_iax_riesgos;
      rie              ob_iax_riesgos;
   BEGIN
      IF pac_iax_produccion.poliza.det_poliza IS NULL
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, 1000644);
         RAISE e_param_error;
      END IF;

      det_poliza := pac_iobj_prod.f_getpoliza (mensajes);
      nerr := pac_iax_produccion.f_eliminatomador (psperson, mensajes);
      vpasexec := 5;

      IF mensajes IS NOT NULL
      THEN
         IF mensajes.COUNT > 0
         THEN
            vpasexec := 6;
            RAISE e_object_error;
         END IF;
      END IF;

      v_mismoaseg :=
         pac_iaxpar_productos.f_get_parproducto ('MISMO_ASEG',
                                                 det_poliza.sproduc
                                                );
      ries :=
         pac_iobj_prod.f_partpolriesgos (pac_iax_produccion.poliza.det_poliza,
                                         mensajes
                                        );

      IF ries IS NOT NULL AND ries.COUNT > 0
      THEN
         -- IF v_mismoaseg = 1 THEN
         nerr := pac_iax_simulaciones.f_eliminaaseg (psperson, mensajes);

         IF nerr <> 0
         THEN
            RAISE e_object_error;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
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
   END f_eliminatomador;

   FUNCTION f_grababeneficiarios(
      pnriesgo    IN       NUMBER,
      psperson    IN       NUMBER,
      pcsexper    IN       NUMBER,
      pfnacimi    IN       DATE,
      pnnumnif    IN       VARCHAR2,
      ptnombre    IN       VARCHAR2,
      ptnombre1   IN       VARCHAR2,
      ptnombre2   IN       VARCHAR2,
      ptapelli1   IN       VARCHAR2,
      ptapelli2   IN       VARCHAR2,
      pctipide    IN       NUMBER,
      pctipper    IN       NUMBER,
      pnorden     OUT      NUMBER,
      mensajes    OUT      t_iax_mensajes
   )
      RETURN NUMBER
   IS
      nerr         NUMBER           := 0;
      vsperson     NUMBER;
      mjs          t_iax_mensajes;
      tom          t_iax_tomadores;
      det_poliza   ob_iax_detpoliza;
      vpasexec     NUMBER (8)       := 1;
      pduplicada   NUMBER;
      vparam       VARCHAR2 (500)
         :=    'psperson='
            || psperson
            || ' pcsexper='
            || pcsexper
            || ' pfnacimi='
            || pfnacimi
            || ' pnnumnif='
            || pnnumnif
            || ' ptnombre='
            || ptnombre
            || ' ptapelli1='
            || ptapelli1
            || ' ptapelli2='
            || ptapelli2
            || ' pctipide='
            || pctipide
            || ' pctipper='
            || pctipper;
      vobject      VARCHAR2 (200)
                                := 'PAC_IAX_SIMULACIONES.f_grababeneficiarios';
      v_ppregun    NUMBER;
   BEGIN
      det_poliza := pac_iobj_prod.f_getpoliza (mensajes);

      IF det_poliza IS NULL
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, 1000644);
                                      --'No se ha inicializado correctamente'
         RAISE e_param_error;
      END IF;

      vpasexec := 2;

      IF NVL (psperson, 0) = 0
      THEN
         vpasexec := 4;

         IF pnnumnif IS NOT NULL
         THEN
            -- Bug 18668 - APD - 07/06/2011 - se valida que el nnumide sea correcto
            nerr :=
               pac_md_persona.f_validanif (pnnumnif,
                                           pctipide,
                                           pcsexper,
                                           pfnacimi,
                                           mensajes
                                          );

            IF nerr <> 0
            THEN
               pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, nerr);
               RAISE e_object_error;
            END IF;

            -- Fin Bug 18668 - APD - 07/06/2011
            nerr :=
               pac_md_persona.f_persona_duplicada (psperson,
                                                   pnnumnif,
                                                   pcsexper,
                                                   pfnacimi,
                                                   NULL,
                                                   NULL,
                                                   NULL,
                                                   pctipide,
                                                   pduplicada,
                                                   mensajes,
                                                   det_poliza.sseguro
                                                  );
                                         --BUG 29268/160635 - RCL - 25/12/2013

            IF pduplicada <> 0
            THEN
               nerr := 9001806;
               pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, nerr);
               RAISE e_object_error;
            END IF;
         END IF;

         nerr :=
            pac_md_simulaciones.f_grabaasegurados (det_poliza.sseguro,
                                                   pcsexper,
                                                   pfnacimi,
                                                   pnnumnif,
                                                   ptnombre,
                                                   ptnombre1,
                                                   ptnombre2,
                                                   ptapelli1,
                                                   ptapelli2,
                                                   pctipide,
                                                   pctipper,
                                                   det_poliza.cagente,
                                                   vsperson,
                                                   NULL,
                                                   NULL,
                                                   mensajes
                                                  );
         vpasexec := 5;
         nerr :=
            pac_iax_produccion.f_insert_beneident_r (pnriesgo,
                                                     vsperson,
                                                     pnorden,
                                                     mensajes
                                                    );

         IF nerr > 0
         THEN
            vpasexec := 6;
            pac_iobj_mensajes.p_mergemensaje (mensajes, mjs);
         END IF;

         IF mensajes IS NOT NULL
         THEN
            IF mensajes.COUNT > 0
            THEN
               vpasexec := 7;
               RAISE e_object_error;
            END IF;
         END IF;
      ELSE
         vsperson := psperson;
      END IF;

      vpasexec := 8;
      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
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
   END f_grababeneficiarios;

   FUNCTION f_grabaconductores(
      pnriesgo              IN       NUMBER,
      pnorden               IN       NUMBER,
      psperson              IN       NUMBER,
      pcsexper              IN       NUMBER,
      pfnacimi              IN       DATE,
      pnnumnif              IN       VARCHAR2,
      ptnombre              IN       VARCHAR2,
      ptnombre1             IN       VARCHAR2,
      ptnombre2             IN       VARCHAR2,
      ptapelli1             IN       VARCHAR2,
      ptapelli2             IN       VARCHAR2,
      pctipide              IN       NUMBER,
      pctipper              IN       NUMBER,
      pcprincipal           IN       NUMBER,
      pcdomici              IN       NUMBER,
      pcpais                IN       NUMBER,
      pcprovin              IN       NUMBER,
      pcpoblac              IN       NUMBER,
      pcocupacion           IN       NUMBER,
      pexper_manual         IN       NUMBER,
                                        -- Bug 26907/148817 - 15/07/2013 - AMC
      pexper_cexper         IN       NUMBER,
                                        -- Bug 26907/148817 - 15/07/2013 - AMC
      pexper_sinie          IN       NUMBER,
      pexper_sinie_manual   IN       NUMBER,
      pnpuntos              IN       NUMBER,
                                        -- Bug 26907/148817 - 15/07/2013 - AMC
      pfcarnet              IN       DATE,
                                        -- Bug 26907/148817 - 15/07/2013 - AMC
      mensajes              OUT      t_iax_mensajes
   )
      RETURN NUMBER
   IS
      nerr         NUMBER           := 0;
      vsperson     NUMBER;
      mjs          t_iax_mensajes;
      tom          t_iax_tomadores;
      det_poliza   ob_iax_detpoliza;
      vpasexec     NUMBER (8)       := 1;
      pduplicada   NUMBER;
      vparam       VARCHAR2 (500)
         :=    'psperson='
            || psperson
            || ' pcsexper='
            || pcsexper
            || ' pfnacimi='
            || pfnacimi
            || ' pnnumnif='
            || pnnumnif
            || ' ptnombre='
            || ptnombre
            || ' ptapelli1='
            || ptapelli1
            || ' ptapelli2='
            || ptapelli2
            || ' pctipide='
            || pctipide
            || ' pctipper='
            || pctipper
            || ' pcprincipal '
            || pcprincipal
            || ' pcdomici '
            || pcdomici
            || ' pcpais '
            || pcpais
            || ' pcprovin '
            || pcprovin
            || ' pcpoblac '
            || pcpoblac
            || ' pcocupacion '
            || pcocupacion;
      vobject      VARCHAR2 (200) := 'PAC_IAX_SIMULACIONES.f_grabaconductores';
      v_ppregun    NUMBER;
      vcdomici     NUMBER;
      vosperson    NUMBER;
      vperreal     NUMBER;
   BEGIN
      det_poliza := pac_iobj_prod.f_getpoliza (mensajes);

      IF det_poliza IS NULL
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, 1000644);
                                      --'No se ha inicializado correctamente'
         RAISE e_param_error;
      END IF;

      vpasexec := 2;

      --Bug 20499/100655 - 15/12/2011 - AMC
      /*IF NVL(pcsexper, 0) = 0 THEN
      pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9000771); --'Debe informar del sexo de la persona.'
      RAISE e_param_error;
      END IF;

      vpasexec := 3;

      IF NVL(TO_CHAR(pfnacimi), ' ') = ' ' THEN
      pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9000772); --'Debe informar de la fecha nacimiento de la persona.'
      RAISE e_param_error;
      END IF;*/
      --Fi Bug 20499/100655 - 15/12/2011 - AMC
      IF NVL (psperson, 0) = 0
      THEN
         vpasexec := 4;

         IF pnnumnif IS NOT NULL
         THEN
            -- Bug 18668 - APD - 07/06/2011 - se valida que el nnumide sea correcto
            nerr :=
               pac_md_persona.f_validanif (pnnumnif,
                                           pctipide,
                                           pcsexper,
                                           pfnacimi,
                                           mensajes
                                          );

            IF nerr <> 0
            THEN
               pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, nerr);
               RAISE e_object_error;
            END IF;

            -- Fin Bug 18668 - APD - 07/06/2011
            nerr :=
               pac_md_persona.f_persona_duplicada (psperson,
                                                   pnnumnif,
                                                   pcsexper,
                                                   pfnacimi,
                                                   NULL,
                                                   NULL,
                                                   NULL,
                                                   pctipide,
                                                   pduplicada,
                                                   mensajes,
                                                   det_poliza.sseguro
                                                  );
                                         --BUG 29268/160635 - RCL - 25/12/2013

            IF pduplicada <> 0
            THEN
               nerr := 9001806;
               pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, nerr);
               RAISE e_object_error;
            END IF;
         END IF;

         nerr :=
            pac_md_simulaciones.f_grabaasegurados (det_poliza.sseguro,
                                                   pcsexper,
                                                   pfnacimi,
                                                   pnnumnif,
                                                   ptnombre,
                                                   ptnombre1,
                                                   ptnombre2,
                                                   ptapelli1,
                                                   ptapelli2,
                                                   pctipide,
                                                   pctipper,
                                                   vsperson,
                                                   vosperson,
                                                   pcocupacion,
                                                   NULL,
                                                   mensajes
                                                  );
         vpasexec := 5;

         IF nerr > 0
         THEN
            vpasexec := 6;
            pac_iobj_mensajes.p_mergemensaje (mensajes, mjs);
         END IF;

         IF mensajes IS NOT NULL
         THEN
            IF mensajes.COUNT > 0
            THEN
               vpasexec := 7;
               RAISE e_object_error;
            END IF;
         END IF;

         IF vsperson IS NULL
         THEN
            vsperson := vosperson;
         END IF;

         vcdomici := pcdomici;

         IF pcdomici = -1
         THEN
            vcdomici := NULL;
         END IF;

         IF vsperson IS NOT NULL                    --and vcdomici is not null
         THEN
            nerr :=
               pac_iax_persona.f_set_estdireccion
                                              (vsperson,
                                               pac_md_common.f_get_cxtidioma,
                                               vcdomici,
                                               vcdomici,
                                               99,
                                               NULL,
                                               NULL,
                                               NULL,
                                               NULL,
                                               NULL,
                                               pcpoblac,
                                               pcprovin,
                                               pcpais,
                                               NULL,
                                               NULL,
                                               NULL,
                                               NULL,
                                               NULL,
                                               NULL,
                                               NULL,
                                               NULL,
                                               NULL,
                                               NULL,
                                               NULL,
                                               NULL,
                                               NULL,
                                               NULL,
                                               NULL,
                                               NULL,
                                               mensajes
                                              );

            IF nerr > 0
            THEN
               vpasexec := 6;
               pac_iobj_mensajes.p_mergemensaje (mensajes, mjs);
               RAISE e_object_error;
            END IF;
         END IF;

         -- Bug 26907/148817 - 15/07/2013 - AMC
         nerr :=
            pac_md_produccion_aut.f_set_conductor (pnriesgo,
                                                   pnorden,
                                                   vsperson,
                                                   NULL,
                                                   pnpuntos,
                                                   pfcarnet,
                                                   NULL,
                                                   vcdomici,
                                                   1,
                                                   pexper_manual,
                                                   pexper_cexper,
                                                   pexper_sinie,
                                                   pexper_sinie_manual,
                                                   mensajes
                                                  );

         -- Fi Bug 26907/148817 - 15/07/2013 - AMC
         IF nerr > 0
         THEN
            vpasexec := 6;
            pac_iobj_mensajes.p_mergemensaje (mensajes, mjs);
         END IF;

         IF mensajes IS NOT NULL
         THEN
            IF mensajes.COUNT > 0
            THEN
               vpasexec := 7;
               RAISE e_object_error;
            END IF;
         END IF;
      ELSE
         -- La persona existe!!
         vsperson := psperson;
         vcdomici := pcdomici;

         IF pcdomici IS NULL
         THEN
            IF pcdomici = -1
            THEN
               vcdomici := NULL;
            END IF;
         END IF;                        -- Bug 26907/148107 - APD - 09/07/2013

         -- Bug 26907/148107 - APD - 09/07/2013 - si la persona tiene un cdomici
         -- para la provincia y poblacion especificados, se debe escoger ese cdomici
         -- sino, se debe crear un cdomici ficticio
         IF pcpais IS NOT NULL AND pcprovin IS NOT NULL
            AND pcpoblac IS NOT NULL
         THEN
            BEGIN
               SELECT   cdomici
                   INTO vcdomici
                   FROM estper_direcciones
                  WHERE sperson = psperson
                    AND cprovin = pcprovin
                    AND cpoblac = pcpoblac
                    AND ROWNUM = 1
               ORDER BY cdomici;
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  vcdomici := NULL;
                  nerr :=
                     pac_iax_persona.f_set_estdireccion
                                              (psperson,
                                               pac_md_common.f_get_cxtidioma,
                                               vcdomici,
                                               vcdomici,
                                               99,
                                               NULL,
                                               NULL,
                                               NULL,
                                               NULL,
                                               NULL,
                                               pcpoblac,
                                               pcprovin,
                                               pcpais,
                                               NULL,
                                               NULL,
                                               NULL,
                                               NULL,
                                               NULL,
                                               NULL,
                                               NULL,
                                               NULL,
                                               NULL,
                                               NULL,
                                               NULL,
                                               NULL,
                                               NULL,
                                               NULL,
                                               NULL,
                                               NULL,
                                               mensajes
                                              );

                  IF nerr > 0
                  THEN
                     vpasexec := 6;
                     pac_iobj_mensajes.p_mergemensaje (mensajes, mjs);
                     RAISE e_object_error;
                  END IF;
            END;
         END IF;

         -- fin Bug 26907/148107 - APD - 09/07/2013

         -- Bug 29315/163319 - SHA - 17/01/2014
         SELECT spereal
           INTO vperreal
           FROM estper_personas
          WHERE sperson = vsperson;

         UPDATE estper_personas
            SET csexper = NVL (csexper, pcsexper),
                fnacimi = NVL (fnacimi, pfnacimi)
          WHERE sperson = psperson;

         UPDATE estper_detper
            SET cocupacion = pcocupacion
          WHERE sperson = psperson;

/*
 nerr :=
 pac_md_persona.f_set_persona
 (det_poliza.sseguro, --Psseguro in number,
 vsperson, -- Psperson in out number,
 vperreal, --Pspereal in number,
 det_poliza.cagente, --pcagente, -- in number, --Bug 23510 - XVM - 18/10/2012 Se añade parámetro cagente
 pctipper, --ctipper in number, -- ¿ tipo de persona (física o jurídica)
 pctipide, --Ctipide in number, -- ¿ tipo de identificación de persona
 pnnumnif, --Nnumide in varchar2, -- -- Número identificativo de la persona.
 pcsexper, --Csexper in number, -- -- sexo de la pesona.
 pfnacimi, --Fnacimi in date, -- -- Fecha de nacimiento de la persona
 NULL, --Snip in varchar2,-- -- snip
 vcestper, --Cestper in number,
 NULL, --Fjubila in date,
 NULL, --Cmutualista in number,
 NULL, --Fdefunc in date,
 NULL, --Nordide in number,
 pac_md_common.f_get_cxtidioma, --CIDIOMA in NUMBER ,--- Código idioma
 ptapelli1, --TAPELLI1 in VARCHAR2 ,-- Primer apellido
 ptapelli2, --TAPELLI2 in VARCHAR2 ,-- Segundo apellido
 ptnombre, --TNOMBRE in VARCHAR2 ,-- Nombre de la persona
 NULL, --TSIGLAS in VARCHAR2 ,-- Siglas persona jurídica
 NULL, --CPROFES in VARCHAR2 ,-- Código profesión
 NULL, --pcestciv, --CESTCIV in NUMBER ,-- Código estado civil. VALOR FIJO = 12
 pac_parametros.f_parinstalacion_n('PAIS_DEF'), --CPAIS in NUMBER ,-- Código país de residencia
 'EST', 0, NULL, ptnombre1, -- Bug 20307/99655 - 02/12/2011 - AMC
 ptnombre2, -- Bug 20307/99655 - 02/12/2011 - AMC
 NULL, --bug 20613/101749
 pcocupacion, mensajes --out t_iax_mensajes
 );*/-- Bug 29315/163319 - SHA - 17/01/2014
         COMMIT;
         -- Bug 26907/148817 - 15/07/2013 - AMC
         nerr :=
            pac_md_produccion_aut.f_set_conductor (pnriesgo,
                                                   pnorden,
                                                   vsperson,
                                                   NULL,
                                                   pnpuntos,
                                                   pfcarnet,
                                                   NULL,
                                                   vcdomici,
                                                   1,
                                                   pexper_manual,
                                                   pexper_cexper,
                                                   pexper_sinie,
                                                   pexper_sinie_manual,
                                                   mensajes
                                                  );

         -- Fi Bug 26907/148817 - 15/07/2013 - AMC
         IF nerr > 0
         THEN
            vpasexec := 6;
            pac_iobj_mensajes.p_mergemensaje (mensajes, mjs);
         END IF;
      END IF;

      vpasexec := 8;
      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
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
   END f_grabaconductores;

   FUNCTION f_inicia_psu(
      p_tablas    IN       VARCHAR2,
      p_sseguro   IN       NUMBER,
      p_accion    IN       NUMBER,
      p_campo     IN       VARCHAR2,
      mensajes    OUT      t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vobjectname         VARCHAR2 (500)        := 'PAC_IAX_psu.f_inicia_psu';
      vparam              VARCHAR2 (500)
         :=    'par�metros - p_sseguro: '
            || p_sseguro
            || ', p_tablas: '
            || p_tablas
            || ',p_accion: '
            || p_accion
            || ',p_campo: '
            || p_campo;
      w_cidioma           idiomas.cidioma%TYPE
                                           := pac_md_common.f_get_cxtidioma
                                                                           ();
      vcreteni            NUMBER;
      vnumerr             NUMBER;
      vtestpol            VARCHAR2 (1000);
      vcestpol            NUMBER;
      vcnivelbpm          NUMBER;
      vtnivelbpm          VARCHAR2 (1000);
      vpobpsu_retenidas   ob_iax_psu_retenidas;
      vp_tpsus            t_iax_psu;
      vpasexec            NUMBER;
      vnumerr2            NUMBER;
   --
   BEGIN
      vnumerr :=
            pac_md_psu.f_inicia_psu (p_tablas, p_sseguro, p_accion, mensajes);

      IF vnumerr <> 0
      THEN
         vnumerr2 :=
            pac_iax_psu.f_get_colec_psu (p_sseguro,
                                         simulacion.det_poliza.nmovimi,
                                         NULL,
                                         p_tablas,
                                         vtestpol,
                                         vcestpol,
                                         vcnivelbpm,
                                         vtnivelbpm,
                                         vpobpsu_retenidas,
                                         vp_tpsus,
                                         mensajes
                                        );

         IF vpobpsu_retenidas.ccritico > 0
         THEN
            IF (TRIM (p_campo) = 'BT_IMPRIMIR')
            THEN
               pac_iobj_mensajes.crea_nuevo_mensaje
                             (mensajes,
                              1,
                              42321,
                              f_axis_literales (9905633,
                                                pac_md_common.f_get_cxtidioma
                                               )
                             );
            ELSIF (TRIM (p_campo) = 'BT_GUARDAR')
            THEN
               pac_iobj_mensajes.crea_nuevo_mensaje
                             (mensajes,
                              1,
                              42321,
                              f_axis_literales (9905634,
                                                pac_md_common.f_get_cxtidioma
                                               )
                             );
            ELSE
               pac_iobj_mensajes.crea_nuevo_mensaje
                             (mensajes,
                              1,
                              42321,
                              f_axis_literales (9905108,
                                                pac_md_common.f_get_cxtidioma
                                               )
                             );
            END IF;
         ELSE
            vnumerr := 0;
         END IF;
      END IF;

      COMMIT;
      RETURN (vnumerr);
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobjectname,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobjectname,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         ROLLBACK;
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
         ROLLBACK;
         RETURN 1;
-----------------------------------------------------------------------------
   END f_inicia_psu;

   /*************************************************************************
   Elimina un asegurado
   param in sperson : identificador del asegurado
   param out mensajes : mensajes de error
   return : 0 todo ha sido correcto
   1 ha habido un error

   Bug 26907/147012 - 21/06/2013 - AMC
   *************************************************************************/
   FUNCTION f_eliminaconductor(psperson IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER
   IS
      nerr             NUMBER;
      vpasexec         NUMBER (8)            := 1;
      vparam           VARCHAR2 (100)        := 'psperson=' || psperson;
      vobject          VARCHAR2 (200)
                                 := 'PAC_IAX_SIMULACIONES.f_eliminaconductor';
      riesautos        t_iax_autriesgos;
      rieaut           ob_iax_autriesgos;
      rip              t_iax_personas;
      ries             t_iax_riesgos;
      rie              ob_iax_riesgos;
      conductores      t_iax_autconductores;
      conduc           ob_iax_autconductores;
      msj              t_iax_mensajes;
      msjt             t_iax_mensajes;
      veliminariesgo   NUMBER                := 0;
   BEGIN
      IF pac_iax_produccion.poliza.det_poliza IS NULL
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, 1000644);
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      ries :=
         pac_iobj_prod.f_partpolriesgos (pac_iax_produccion.poliza.det_poliza,
                                         mensajes
                                        );

      IF ries IS NULL
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, 9001040);
         vpasexec := 3;
         RAISE e_object_error;
      ELSE
         IF ries.COUNT = 0
         THEN
            pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, 9001040);
            vpasexec := 4;
            RAISE e_object_error;
         END IF;
      END IF;

      vpasexec := 5;

      IF mensajes IS NOT NULL
      THEN
         IF mensajes.COUNT > 0
         THEN
            vpasexec := 6;
            RAISE e_object_error;
         END IF;
      END IF;

      vpasexec := 7;

      -- Recoremos los riesgos
      FOR vrie IN ries.FIRST .. ries.LAST
      LOOP
         vpasexec := 8;

         IF ries.EXISTS (vrie)
         THEN
            rie := ries (vrie);
            riesautos := rie.riesautos;

            IF riesautos IS NOT NULL
            THEN
               IF riesautos.COUNT > 0
               THEN
                  -- Recoremos los autriesgos
                  FOR v IN riesautos.FIRST .. riesautos.LAST
                  LOOP
                     conductores := riesautos (v).conductores;

                     IF conductores IS NOT NULL
                     THEN
                        IF conductores.COUNT > 0
                        THEN
                           -- Recoremos los conductores
                           FOR c IN conductores.FIRST .. conductores.LAST
                           LOOP
                              conduc := conductores (c);

                              -- Si encontramos el conductor lo borramos
                              IF conduc.sperson = psperson
                              THEN
                                 conductores.DELETE (c);
                              END IF;
                           END LOOP;
                        END IF;
                     END IF;

                     riesautos (v).conductores := conductores;
                  END LOOP;
               END IF;
            END IF;
         END IF;

         rie.riesautos := riesautos;
         ries (vrie) := rie;
      END LOOP;

      vpasexec := 29;
      pac_iax_produccion.poliza.det_poliza.riesgos := ries;
      vpasexec := 30;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
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
   END f_eliminaconductor;

   --Bug: 0027955/0152213 - JSV (05/09/2013)
   FUNCTION f_testtomadores(
      psperson      IN       NUMBER,
      pcsexper      IN       NUMBER,
      pfnacimi      IN       DATE,
      pnnumnif      IN       VARCHAR2,
      ptnombre      IN       VARCHAR2,
      ptnombre1     IN       VARCHAR2,
      ptnombre2     IN       VARCHAR2,
      ptapelli1     IN       VARCHAR2,
      ptapelli2     IN       VARCHAR2,
      pctipide      IN       NUMBER,
      pctipper      IN       NUMBER,
      pcdomici      IN       NUMBER,
      pcpoblac      IN       NUMBER,
      pcprovin      IN       NUMBER,
      pcpais        IN       NUMBER,
      pcocupacion   IN       NUMBER,
      pcestciv      IN       NUMBER,
      mensajes      OUT      t_iax_mensajes
   )
      RETURN NUMBER
   IS
      nerr         NUMBER           := 0;
      vsperson     NUMBER;
      mjs          t_iax_mensajes;
      tom          t_iax_tomadores;
      det_poliza   ob_iax_detpoliza;
      vpasexec     NUMBER (8)       := 1;
      pduplicada   NUMBER;
      vparam       VARCHAR2 (500)
         :=    'psperson='
            || psperson
            || ' pcsexper='
            || pcsexper
            || ' pfnacimi='
            || pfnacimi
            || ' pnnumnif='
            || pnnumnif
            || ' ptnombre='
            || ptnombre
            || ' ptapelli1='
            || ptapelli1
            || ' ptapelli2='
            || ptapelli2
            || ' pctipide='
            || pctipide
            || ' pctipper='
            || pctipper
            || ' pcestciv='
            || pcestciv;
      vobject      VARCHAR2 (200)   := 'PAC_IAX_SIMULACIONES.f_testtomadores';
      v_ppregun    NUMBER;
      vcdomici     NUMBER;
      vosperson    NUMBER;
      vperreal     NUMBER;
   BEGIN
      det_poliza := pac_iobj_prod.f_getpoliza (mensajes);

      IF det_poliza IS NULL
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, 1000644);
         RAISE e_param_error;
      END IF;

      vpasexec := 2;

      IF NVL (psperson, 0) = 0
      THEN
         vpasexec := 4;

         IF pnnumnif IS NOT NULL
         THEN
            nerr :=
               pac_md_persona.f_validanif (pnnumnif,
                                           pctipide,
                                           pcsexper,
                                           pfnacimi,
                                           mensajes
                                          );

            IF nerr <> 0
            THEN
               pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, nerr);
               RAISE e_object_error;
            END IF;

            nerr :=
               pac_md_persona.f_persona_duplicada (psperson,
                                                   pnnumnif,
                                                   pcsexper,
                                                   pfnacimi,
                                                   NULL,
                                                   NULL,
                                                   NULL,
                                                   pctipide,
                                                   pduplicada,
                                                   mensajes,
                                                   det_poliza.sseguro
                                                  );
                                         --BUG 29268/160635 - RCL - 25/12/2013

            IF pduplicada <> 0
            THEN
               nerr := 9001806;
               pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, nerr);
               RAISE e_object_error;
            END IF;
         END IF;

         IF pcpoblac IS NOT NULL
         THEN
            nerr :=
                 pac_md_simulaciones.f_test_estdireccion (pcpoblac, pcprovin);

            IF nerr = 0
            THEN
               nerr := 102330;
               pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, nerr);
               RAISE e_object_error;
            END IF;
         END IF;
-- Bug 27304 - 20131003 - MMS
-- ELSE
-- vpasexec := 2;
-- vsperson := psperson;

      -- IF nerr <> 0 THEN
-- RAISE e_object_error;
-- END IF;

      -- IF pcpoblac IS NULL
-- AND vsperson IS NOT NULL THEN
-- nerr := pac_md_simulaciones.f_test_estdireccion(pcpoblac, pcprovin);

      -- IF nerr = 0 THEN
-- nerr := 102330;
-- pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, nerr);
-- RAISE e_object_error;
-- END IF;
-- END IF;
      END IF;

      IF pcpais IS NOT NULL AND pcprovin IS NOT NULL AND pcpoblac IS NULL
      THEN
         nerr := 102330;
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, nerr);
         RAISE e_object_error;
      END IF;

      vpasexec := 8;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
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
   END f_testtomadores;

   -- Bug27429 - 28/01/2014 -- JTT:
   /*************************************************************************
   Establece la simulacion como rechazada cambiando su situacion a 10 VF 61
   param in psseguro : cdigo de solicitud
   param in out mensajes : mensajes error
   return : 0 todo correcto
   1 ha habido un error
   *************************************************************************/
   FUNCTION f_rechazar_simul(
      psseguro   IN       NUMBER,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN NUMBER
   IS
      nerr       NUMBER         := 0;
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (100) := 'psseguro=' || psseguro;
      vobject    VARCHAR2 (200) := 'PAC_IAX_SIMULACIONES.F_rechazar_simul';
   BEGIN
      nerr := f_validaciones ('RECHAZAR_SIMULACION', mensajes);

      IF nerr > 0
      THEN
         RETURN nerr;
      END IF;

      vpasexec := 2;

      IF NVL (psseguro, 0) = 0
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, 1000644);
                                      --'No se ha inicializado correctamente'
         RAISE e_param_error;
      END IF;

      vpasexec := 3;
      nerr := pac_md_simulaciones.f_rechazar_simul (psseguro, mensajes);

      IF nerr <> 0
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, 9001916);
                                --'El cambio de estado ha producido un error'
         RAISE e_object_error;
      END IF;

      vpasexec := 4;
      /*
        Indiquem que tenim una simulaci� perque la funcio limpiartemporales ho tingui en compte i al [cancelar]
        no esborri les taules EST (si previament no hem fet un [GUARDAR]
      */
      isconsultsimul := TRUE;

      IF simulacion IS NOT NULL
      THEN          -- Si el objecte 'simulacion' existeix actualitzem l'estat
         simulacion.det_poliza.csituac := 10;         -- Simulacion rechazada
      END IF;

      COMMIT;
      pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, 9906449);
                                           --'La simulaci�n ha sido rechazada'
      RETURN 0;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
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
   END f_rechazar_simul;

   /*************************************************************************
   Recuperem la situacio de la simulacio
   param in psseguro : numero de simulacion
   param out ptsitsimul : estado de la simulacion
   param out pcsitsimul : codigo del estado de la simulacion
   param in out mensajes : mensajes error
   return : Situacion de la solicitud
   ************************************************************************/
   FUNCTION f_get_situacion_simul(
      psseguro     IN       NUMBER,
      ptsitsimul   OUT      VARCHAR2,
      pcsitsimul   OUT      NUMBER,
      mensajes     OUT      t_iax_mensajes
   )
      RETURN NUMBER
   IS
      nerr       NUMBER         := 0;
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (100) := 'psseguro=' || psseguro;
      vobject    VARCHAR2 (200)
                              := 'PAC_IAX_SIMULACIONES.F_get_situacion_simul';
   BEGIN
      IF NVL (psseguro, 0) = 0
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, 1000644);
                                      --'No se ha inicializado correctamente'
         RAISE e_param_error;
      END IF;

      nerr :=
         pac_md_simulaciones.f_get_situacion_simul (psseguro,
                                                    ptsitsimul,
                                                    pcsitsimul,
                                                    mensajes
                                                   );

      IF nerr <> 0
      THEN
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
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
   END f_get_situacion_simul;
END pac_iax_simulaciones;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_SIMULACIONES" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_SIMULACIONES" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_SIMULACIONES" TO "PROGRAMADORESCSI";
