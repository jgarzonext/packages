
  CREATE OR REPLACE PACKAGE BODY "PAC_IAX_VALIDACIONES" AS
/******************************************************************************
   NOMBRE:       PAC_IAX_VALIDACIONES
   PROPÓSITO:  Funciones de validaciones para el IAxis

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        23/11/2007   ACC                1. Creación del package.
   2.0        24/04/2009   DRA                2. 0009718: IAX - clausulas especiales por producto
   3.0        03/07/2009   ETM                3. 0009916: IAX -ACTIVIDAD - Añadir la actividad a nivel de póliza
   4.0        08/07/2009   ETM                4. 0010515: CRE069 - Validación de asegurado en ramos de salud y bajas
   5.0        08/09/2009   DRA                5. 0011047: CRE - Suplemento Baja de Asegurado
   6.0        21/09/2009   DRA                6. 0011107: CRE - Incidència suplement alta d'assegurat
   7.0        22/09/2009   AMC                7. 11165: Se sustituñe  T_iax_saldodeutorseg por t_iax_prestamoseg
   8.0        15/10/2009   FAL                8. 0011330: CRE - Bajas a al próximo recibo
   9.0        19/01/2010   RSC                9. 0011735: APR - suplemento de modificación de capital /prima
   10.0       19/02/2010   DRA                10.0011583: CRE - Incidencia en modificación de datos de Suplemento
   11.0       22/03/2010   RSC                11.0011735: APR - suplemento de modificación de capital /prima (añadimos isbajagar)
   12.0       09/09/2010   DRA                12.0015617: AGA103 - migración de pólizas - Numeración de polizas
   13.0       17/09/2010   DRA                13.0015740: CRE801 - Simulacions ram Salut
   14.0       10/03/2011   DRA                14.0017919: AGA800 - formulación de generales previsió
   15.0       15/06/2011   RSC                15.0018631: ENSA102- Alta del certificado 0 en Contribucion definida
   16.0       27/06/2011   APD                16.0018848: LCOL003 - Vigencia fecha de tarifa
   17.0       26/10/2011   ICV                17.0019152: LCOL_T001- Beneficiari Nominats - LCOL_TEC-02_Emisión_Brechas01
   18.0       14/11/2011   DRA                18.0020146: AGM - Control asegurado ya tiene pólizas pendientes de evaluación. (para asegurado)
   19.0       16/11/2011   JMC                19.0019303: LCOL_T003-Analisis Polissa saldada/prorrogada. LCOL_TEC_ProductosBrechas04
   20.0       16/12/2011   RSC                20.0019715: LCOL: Migración de productos de Vida Individual
   21.0       13/01/2012   RSC                21.0019715: LCOL: Migraci??e productos de Vida Individual
   22.0       23/01/2012   APD                22.0020995: LCOL - UAT - TEC - Incidencias de Contratacion
   23.0       30/01/2012   APD                23.0020995: LCOL - UAT - TEC - Incidencias de Contratacion
   24.0       04/06/2012   ETM                24. 0021657: MDP - TEC - Pantalla Inquilinos y Avalistas
   25.0       03/09/2012   JMF                0022701: LCOL: Implementación de Retorno
   26.0       23/01/2013   MMS                26. 0025584: (f_controledad) Agregamos el parámetro nedamar
   27.0       07/01/2013   MLR                27. 0025942: LCOL: Ajuste de q-trackers retorno
   28.0       13/02/2013   ECP                28. 0026070: LCOL_T010-LCOL - Revision incidencias qtracker (V) Nota 137995
   29.0       15/02/2013   JDS                29. 025964: LCOL - AUT - Experiencia
   30.0       06/03/2013   JMF                0025942: LCOL: Ajuste de q-trackers retorno
   31.0       11/03/2013   FPG                31  0026070: LCOL_T010-LCOL - Revision incidencias qtracker (V)
   32.0       30/04/2013   ECP                32. 0026488: LCOL_T010-LCOL - Revision incidencias qtracker (VI). Nota 143644
   33.0       23/05/2013   APD                33. 0026419: LCOL - TEC - Revisión Q-Trackers Fase 3A
   34.0       18/06/2013   MMS                34. 0026501: POSRA400-(POSRA400)-Vida Grupo (Voluntario)
   35.0       02/08/2013   SHA                35. 0027505: POSS518 (POSSF200)- Resolucion de Incidencias FASE 1-2: Tecnico - Generales
   36.0       25/11/2013   JSV                36. 0028455: LCOL_T031- TEC - Revisión Q-Trackers Fase 3A II
   37.0       03/12/2013   JDS                37. 0028455: LCOL_T031- TEC - Revisión Q-Trackers Fase 3A II
   38.0       11/12/2013   JDS                38. 0029315: LCOL_T031-Revisi?n Q-Trackers Fase 3A III
   39.0       16/01/2014   MMS                39. 0027305: POSS518 (POSSF200)- Resolucion de Incidencias FASE 1-2: Tecnico - Conmutacion Pensional
   40.0 	  17/06/2019   Sakti			  40. Cambios de IAXIS-4320 
   41.0		  08/07/2019   Shakti			  41.0 Changes for the deffect IAXIS-4740
******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;
   gidioma        NUMBER := pac_md_common.f_get_cxtidioma();

   /*************************************************************************
      Recupera la poliza como objeto persistente
      param out mensajes : mensajes de error
      return             : objeto detalle póliza
   *************************************************************************/
   FUNCTION f_getpoliza(mensajes IN OUT t_iax_mensajes)
      RETURN ob_iax_detpoliza IS
      tmpdpoliza     ob_iax_detpoliza;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_IAX_VALIDACIONES.F_GetPoliza';
   BEGIN
      tmpdpoliza := pac_iobj_prod.f_getpoliza(mensajes);
      RETURN tmpdpoliza;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_getpoliza;

   /*************************************************************************
      Valida datos tomadores
      param out mensajes : mensajes de error
      return             : 0 todo correcto
                           1 ha habido un error
   *************************************************************************/
   FUNCTION f_validatomadores(mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      tomadores      t_iax_tomadores;
      tom            ob_iax_tomadores;
      errnum         NUMBER := 0;
      poliza         ob_iax_detpoliza;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_IAX_VALIDACIONES.F_ValidaTomadores';
      vtexto         VARCHAR2(400);
      vspereal     NUMBER:= 0;
      vnumerr1     NUMBER:= 0;
   BEGIN
      poliza := f_getpoliza(mensajes);
      vpasexec := 2;
      tomadores := pac_iobj_prod.f_partpoltomadores(poliza, mensajes);
      vpasexec := 3;

      -- Bug 31686/179252 - 08/07/2014 - AMC
      IF poliza.cobjase = 5
         AND NOT pac_iax_produccion.isaltacol
         AND pac_mdpar_productos.f_get_parproducto('ADMITE_CERTIFICADOS', poliza.sproduc) = 1 THEN
         IF tomadores IS NULL THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9906837);   --'No se ha podido recuperar la información de los Conductores'
            RETURN 1;
         ELSE
            IF tomadores.COUNT = 0 THEN
               pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9906837);   --'No se ha podido recuperar la información de los Conductores'
               RETURN 1;
            END IF;
         END IF;
      ELSE
         IF tomadores IS NULL THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9000735);   --'No se ha podido recuperar la información de los Tomadores'
            RETURN 1;
         ELSE
            IF tomadores.COUNT = 0 THEN
               pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9000735);   --'No se ha podido recuperar la información de los Tomadores'
               RETURN 1;
            END IF;
         END IF;
      END IF;

      -- Fi Bug 31686/179252 - 08/07/2014 - AMC
      vpasexec := 4;

      FOR vp IN tomadores.FIRST .. tomadores.LAST LOOP
         IF tomadores.EXISTS(vp) THEN
            tom := tomadores(vp);
            -- BUG 9318 - 10/03/2009 - SBG - Diferenciem el tractament si el tipus d'identif.
            -- és nul o val 99. (Ara el tipus 0 -id. de sistema- també és vàlid)
            vpasexec := 9;

            IF NVL(tom.ctipide, -1) = -1 THEN
               pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9001178);   -- El tipus d'identificador és obligatori.
               RETURN 1;
            END IF;

            vpasexec := 10;

            IF NVL(tom.ctipide, -1) = 99 THEN
               pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9001179);   -- El tipus d'identificador (id. de simulació) no és vàlid.
               RETURN 1;
            END IF;

            BEGIN
                SELECT spereal
                INTO vspereal
                FROM estper_personas
                WHERE sperson = tom.sperson;
            EXCEPTION WHEN OTHERS THEN
                vspereal :=0;
            END;
            ---
            vnumerr1 := F_CONSORCIO (vspereal);
        
		  -----***Changes for the deffect IAXIS-4740 08/07/2019 Start 
            IF vnumerr1 <> 0 THEN --AXIS-2085 22/04/2019 AP
                IF tom.cagrupa IS NULL THEN
                vtexto := pac_iobj_mensajes.f_get_descmensaje(89906196);
                   pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, NULL, vtexto);
                ELSIF tom.cagrupa < 0 THEN
                vtexto := pac_iobj_mensajes.f_get_descmensaje(89906196);
                   pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, NULL, vtexto);
                ELSIF tom.cagrupa = 0 THEN
                vtexto := pac_iobj_mensajes.f_get_descmensaje(89906196);
                   pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, NULL, vtexto);
                   RETURN 1;
                END IF;
            END IF;
			
			 -----*** Changes for the deffect IAXIS-4740 Ends
			 
            --// ACC comentat per comentar amb ... 14052008
            --errnum := PAC_MD_VALIDACIONES.F_CONTROLEDAD(tom.fnacimi,poliza.gestion.fefecto,poliza.sproduc,mensajes);
		 
		  
            -- JLB - I - LO METO DENTRO
            IF NVL(tom.cestper, 0) = 2 THEN   -- Mort
               pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 101253);
               RETURN 1;
            END IF;

            -- JLB - F - LO METO DENTRO
            vpasexec := 5;

            IF errnum > 0 THEN
               RAISE e_object_error;
            END IF;

            vpasexec := 6;

            IF tom.direcciones IS NULL THEN
               vtexto := pac_iobj_mensajes.f_get_descmensaje(9000780);
               pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, NULL,
                                                    vtexto || ' ' || tom.tnombre || ' '
                                                    || tom.tapelli1);
               RETURN 1;
            END IF;

            vpasexec := 7;

            IF tom.direcciones.COUNT = 0 THEN
               vtexto := pac_iobj_mensajes.f_get_descmensaje(9000780);
               pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, NULL,
                                                    vtexto || ' ' || tom.tnombre || ' '
                                                    || tom.tapelli1);
               RETURN 1;
            END IF;

            vpasexec := 8;

            FOR vdi IN tom.direcciones.FIRST .. tom.direcciones.LAST LOOP
               IF tom.direcciones.EXISTS(vdi) THEN
                  IF NVL(tom.direcciones(vdi).cdomici, 0) = 0 THEN
                     vtexto := pac_iobj_mensajes.f_get_descmensaje(9000780);
                     pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, NULL,
                                                          vtexto || ' ' || tom.tnombre || ' '
                                                          || tom.tapelli1);
                     -- JLB - I - Interficies CREDIT
                     RETURN 1;
                  ELSE
                     -- Bug 25378/137309 - 19/02/2013 - AMC
                     IF NVL(tom.direcciones(vdi).cdomici, 0) = tom.direcciones(vdi).cdomici
                        AND tom.direcciones(vdi).ctipdir = 99 THEN
                        vtexto := pac_iobj_mensajes.f_get_descmensaje(9905014);
                        pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, NULL,
                                                             vtexto || ' ' || tom.tnombre
                                                             || ' ' || tom.tapelli1);
                        -- JLB - I - Interficies CREDIT
                        RETURN 1;
                     END IF;

                     -- Fi Bug 25378/137309 - 19/02/2013 - AMC
                     IF pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa(),
                                                      'VALIDADIRECCTOMADOR') = 1 THEN
                        errnum :=
                           pac_md_persona.f_valida_direccion
                                (tom.sperson, tom.direcciones(vdi).cdomici,   --?? direccion? escogida tomador
                                 mensajes);

                        IF errnum <> 0 THEN
                           pac_iobj_mensajes.crea_nuevo_mensaje
                                               (mensajes, 1, NULL,
                                                pac_iobj_mensajes.f_get_descmensaje(9000672)
                                                || ' ' || tom.tnombre || ' ' || tom.tapelli1
                                                || ' ' || tom.tapelli2);
                           RETURN 1;
                        END IF;
                     END IF;
                  -- JLB - F - Interfaz credit
                  END IF;
               END IF;
            END LOOP;

             -- JLB - I - Interfaz credit
            -- valido la persona
            IF pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa(),
                                             'VALIDADATOSTOMADOR') = 1 THEN
               errnum := pac_md_persona.f_validapersona(tom.sperson, mensajes);

               IF errnum <> 0 THEN
                  pac_iobj_mensajes.crea_nuevo_mensaje
                                               (mensajes, 1, NULL,
                                                pac_iobj_mensajes.f_get_descmensaje(9000671)
                                                || ' ' || tom.tnombre || ' ' || tom.tapelli1
                                                || ' ' || tom.tapelli2);
                  RETURN 1;
               END IF;
            END IF;

            -- JLB - F - Interfaz credit

            -- Bug 31686/177084 - 16/06/2014 - AMC
            -- Bug 31686/179793 - 16/07/2017 - AMC
            IF poliza.cobjase = 5
               AND NOT pac_iax_produccion.isaltacol
               AND pac_mdpar_productos.f_get_parproducto('ADMITE_CERTIFICADOS', poliza.sproduc) =
                                                                                              1 THEN
               IF NVL(tom.ctipper, 0) = 2 THEN   -- El tomador no puede ser persona jurídica
                  pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9001313);
                  RETURN 1;
               END IF;
            END IF;
         -- Fi Bug 31686/177084 - 16/06/2014 - AMC
         -- Fi Bug 31686/179793 - 16/07/2017 - AMC
         END IF;
      END LOOP;

      vpasexec := 9;
      --INI JBN--
      errnum := pac_md_validaciones.f_valida_edad_tomador(tomadores, poliza.sproduc, f_sysdate,
                                                          mensajes);

      --FIN JBN--
      IF errnum <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, errnum);
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_validatomadores;

   /*************************************************************************
      Valida datos asegurados
      param out mensajes : mensajes de error
      return             : 0 todo correcto
                           1 ha habido un error
   *************************************************************************/
   FUNCTION f_validaasegurados(mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      asegurados     t_iax_asegurados;
      riesgos        t_iax_riesgos;
      riesgo         ob_iax_riesgos;
      errnum         NUMBER := 0;
      poliza         ob_iax_detpoliza;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_IAX_VALIDACIONES.F_ValidaAsegurados';
      v_nerror       NUMBER;
      vfefecto       DATE;
   BEGIN
      poliza := f_getpoliza(mensajes);
      vpasexec := 2;
      riesgos := pac_iobj_prod.f_partpolriesgos(poliza, mensajes);
      vpasexec := 3;

      IF riesgos IS NULL THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000643);   --'No existen riesgos'
         RAISE e_object_error;
      ELSE
         vpasexec := 4;

         IF riesgos.COUNT = 0 THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000643);   --'No existen riesgos'
            RAISE e_object_error;
         END IF;
      END IF;

      vpasexec := 5;

      FOR vrie IN riesgos.FIRST .. riesgos.LAST LOOP
         vpasexec := 6;

         IF riesgos.EXISTS(vrie) THEN
            riesgo := riesgos(vrie);

            IF riesgos(vrie).fanulac IS NULL THEN   -- BUG11047:DRA:08/09/2009: Solo si el riesgo no está anulado
               vpasexec := 61;

               IF riesgo IS NULL THEN
                  pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000642);   --'No se ha podido recuperar la información del Riesgo'
                  RETURN 1;
               END IF;

               vpasexec := 6;
               asegurados := pac_iobj_prod.f_partriesasegurado(riesgo, mensajes);
               vpasexec := 7;

               IF asegurados IS NULL THEN
                  pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9000736);   --'No se ha podido recuperar la información de los Asegurados'
                  RETURN 1;
               ELSE
                  vpasexec := 8;

                  IF asegurados.COUNT = 0 THEN
                     pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9000736);   --'No se ha podido recuperar la información de los Asegurados'
                     RETURN 1;
                  END IF;
               END IF;

               vpasexec := 9;

               FOR i IN asegurados.FIRST .. asegurados.LAST LOOP
                  IF asegurados.EXISTS(i) THEN
                     vpasexec := 11;

                     IF NVL(asegurados(i).cestper, 0) = 2
                        AND NVL(pac_iaxpar_productos.f_get_parproducto('CONTRATA_MUERTO',
                                                                       poliza.sproduc),
                                0) = 0 THEN   -- Mort
                        pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 101253);
                        RETURN 1;
                     END IF;

                     IF poliza.cobjase = 1 THEN   -- Solo si el objeto asegurado es personal
                        -- Bug 18631 - RSC - 15/06/2011 - ENSA102- Alta del certificado 0 en Contribucion definida
                        IF NOT pac_iax_produccion.isaltacol THEN
                           -- Fin Bug 18631
                           IF NVL(asegurados(i).ctipper, 0) = 2 THEN   -- El asegurado no puede ser persona jurídica
                              pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 152093);
                              RETURN 1;
                           END IF;

                           vpasexec := 12;

                           -- Bug AMA-16 - 02/06/2016 - AMC
                           IF pac_iax_produccion.issimul and
                              nvl(pac_parametros.f_parproducto_n(poliza.sproduc, 'FNACIMI_SIMUL'),0) = 1 THEN

                              IF asegurados(i).csexper IS NULL THEN
                                pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 151133);
                                RETURN 1;
                             END IF;

                           ELSE
                             IF asegurados(i).fnacimi IS NULL
                                OR asegurados(i).csexper IS NULL THEN
                                pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 151133);
                                RETURN 1;
                             END IF;
                           END IF;
                           -- Fi Bug AMA-16 - 02/06/2016 - AMC

                           --ini BUG10798-27/07/2009-JMF: CRE - Migración Salud. Errores detectados en pruebas
                           IF (pac_iax_produccion.issuplem
                               AND(poliza.nmovimi = riesgo.nmovima))
                              OR NOT pac_iax_produccion.issuplem THEN
                              --fin BUG10798-27/07/2009-JMF: CRE - Migración Salud. Errores detectados en pruebas
                              errnum :=
                                 pac_md_validaciones.f_valida_edad_prod
                                                    (asegurados(i), poliza.sproduc,

                                                     -- poliza.gestion.fefecto,
                                                     riesgo.fefecto,   -- BUG11107:DRA:21/09/2009
                                                     mensajes);
                           END IF;
                        -- Bug 18631
                        END IF;

                        -- Fin Bug 18631
                        vpasexec := 10;

                        IF errnum > 0 THEN
                           -- JBN 16799
                           IF errnum <> 1 THEN
                              pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, errnum);
                           END IF;

                           RETURN 1;
                        END IF;
                     END IF;

                     -- BUG 11330 - 15/10/2009 - FAL - Recuperar fefecto para informar en pac_md_validaciones.f_valida_producto_unico
                     IF pac_iax_produccion.issuplem THEN
                        v_nerror :=
                           pac_md_suplementos.f_get_fefecto_supl(NVL(poliza.nsolici,
                                                                     poliza.sseguro),
                                                                 poliza.nmovimi, vfefecto,
                                                                 mensajes);

                        IF v_nerror <> 0 THEN
                           vpasexec := 12;
                           RAISE e_object_error;
                        END IF;
                     ELSE
                        vfefecto := NULL;
                     END IF;

                     -- FI BUG 11330  - 15/10/2009  FAL
                     vpasexec := 13;

                     -- BUG15740:DRA:17/09/2010:Inici
                     IF NOT pac_iax_produccion.issimul THEN
                        errnum :=
                           pac_md_validaciones.f_valida_producto_unico(poliza.sproduc,
                                                                       asegurados(i).spereal,
                                                                       poliza.ssegpol,
                                                                       vfefecto,

                                                                       -- JLB - 26301 - I - RSA - Validación póliza partner
                                                                       poliza.cagente,
                                                                       poliza.cpolcia,

                                                                       -- JLB - 26301 - F - RSA - Validación póliza partner
                                                                       mensajes);
                        vpasexec := 14;

                        IF errnum > 0 THEN
                           --pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 151240);  -- bug 10515: 08/07/2009:ETM: 2parte
                           RAISE e_object_error;
                        END IF;
                     END IF;

                     -- BUG15740:DRA:17/09/2010:Fi
                     vpasexec := 15;

                     IF NOT pac_iax_produccion.issimul THEN
                        errnum :=
                           pac_md_validaciones.f_valida_no_pol_pendientes
                                                                        (poliza.sproduc,
                                                                         asegurados(i).spereal,
                                                                         poliza.ssegpol,
                                                                         mensajes);
                        vpasexec := 16;

                        IF errnum > 0 THEN
                           pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, errnum);
                           RETURN 1;
                        END IF;
                     END IF;
                  END IF;
               END LOOP;
            END IF;
         END IF;
      END LOOP;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_validaasegurados;

-- JLB - I - INICIO
  /*************************************************************************
       Valida datos asegurados (datos , direccion )
       param out mensajes : mensajes de error
       return             : 0 todo correcto
                            1 ha habido un error
    *************************************************************************/
   FUNCTION f_validadatosasegurados(mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      asegurados     t_iax_asegurados;
      riesgos        t_iax_riesgos;
      riesgo         ob_iax_riesgos;
      errnum         NUMBER := 0;
      poliza         ob_iax_detpoliza;
      vcvalpar       NUMBER;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_IAX_VALIDACIONES.F_ValidaDatosAsegurados';
      v_nerror       NUMBER;
      vfefecto       DATE;
      v_aseg_no_riesgo NUMBER;
      vtexto         VARCHAR2(200);
      aseg           ob_iax_asegurados;
      --
      tomadores      t_iax_tomadores;
      v_val_tomase   NUMBER := 0;

      TYPE t_tomadores IS TABLE OF NUMBER
         INDEX BY BINARY_INTEGER;

      v_t_tomadores  t_tomadores;
   --
   BEGIN
      poliza := f_getpoliza(mensajes);
      vpasexec := 2;
      riesgos := pac_iobj_prod.f_partpolriesgos(poliza, mensajes);
      vpasexec := 3;
      v_val_tomase := pac_iaxpar_productos.f_get_parproducto('VALIDAR_REL_TOMASE',
                                                             poliza.sproduc);

      IF v_val_tomase = 1 THEN
         --
         tomadores := pac_iobj_prod.f_partpoltomadores(poliza, mensajes);

         --
         IF tomadores IS NULL THEN
            --
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9001039);
            RAISE e_object_error;
         --
         ELSIF tomadores.COUNT = 0 THEN
            --
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9001039);
            RAISE e_object_error;
         --
         END IF;

         --
         FOR tompol IN tomadores.FIRST .. tomadores.LAST LOOP
            --
            IF tomadores.EXISTS(tompol) THEN
               --
               v_t_tomadores(tomadores(tompol).sperson) := 1;
            --
            END IF;
         --
         END LOOP;
      --
      END IF;

      --
      IF riesgos IS NULL THEN
         -- Bug 26419/143480 - APD - 23/05/2013 - se cambia el mensaje
         --pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000643);   --'No existen riesgos'
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9001041);   --'No existen asegurados'
         -- fin Bug 26419/143480 - APD - 23/05/2013
         RAISE e_object_error;
      ELSE
         vpasexec := 4;

         IF riesgos.COUNT = 0 THEN
            -- Bug 26419/143480 - APD - 23/05/2013 - se cambia el mensaje
            --pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000643);   --'No existen riesgos'
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9001041);   --'No existen asegurados'
            -- fin Bug 26419/143480 - APD - 23/05/2013
            RAISE e_object_error;
         END IF;
      END IF;

      vpasexec := 5;

      FOR vrie IN riesgos.FIRST .. riesgos.LAST LOOP
         vpasexec := 6;

         IF riesgos.EXISTS(vrie) THEN
            riesgo := riesgos(vrie);

            IF riesgos(vrie).fanulac IS NULL THEN   -- BUG11047:DRA:08/09/2009: Solo si el riesgo no está anulado
               vpasexec := 61;

               IF riesgo IS NULL THEN
                  pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000642);   --'No se ha podido recuperar la información del Riesgo'
                  RETURN 1;
               END IF;

               vpasexec := 6;
               asegurados := pac_iobj_prod.f_partriesasegurado(riesgo, mensajes);
               vpasexec := 7;
               -- BUG20642:DRA:2/1/2012:Inici: si es un producte on l'assegurat no és el risc, no validar si es NULL
               v_aseg_no_riesgo :=
                  NVL(pac_iaxpar_productos.f_get_parproducto('ASEG_NO_RIESGO', poliza.sproduc),
                      0);

               IF (v_aseg_no_riesgo = 0
                   OR(v_aseg_no_riesgo = 1
                      AND asegurados IS NOT NULL
                      AND asegurados.COUNT > 0)) THEN
                  IF asegurados IS NULL THEN
                     pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9000736);   --'No se ha podido recuperar la información de los Asegurados'
                     RETURN 1;
                  ELSE
                     vpasexec := 8;

                     IF asegurados.COUNT = 0 THEN
                        pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9000736);   --'No se ha podido recuperar la información de los Asegurados'
                        RETURN 1;
                     END IF;
                  END IF;

                  vpasexec := 9;

                  FOR i IN asegurados.FIRST .. asegurados.LAST LOOP
                     IF asegurados.EXISTS(i) THEN
                        -- BUG 9318 - 10/03/2009 - SBG - Diferenciem el tractament si el tipus d'identif.
                        -- és nul o val 99. (Ara el tipus 0 -id. de sistema- també és vàlid)
                        vpasexec := 18;

                        IF poliza.cobjase = 5 THEN
                           aseg := asegurados(i);

                           IF aseg.direcciones IS NULL
                              AND aseg.ffecfin IS NULL THEN
                              pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9906286);
                              RETURN 1;
                           END IF;

                           vpasexec := 7;

                           IF aseg.ffecfin IS NULL THEN
                              IF aseg.direcciones.COUNT = 0 THEN
                                 pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9906286);
                                 RETURN 1;
                              END IF;

                              FOR vdi IN aseg.direcciones.FIRST .. aseg.direcciones.LAST LOOP
                                 IF aseg.direcciones.EXISTS(vdi) THEN
                                    IF aseg.direcciones(vdi).cdomici IS NULL THEN
                                       --vtexto := pac_iobj_mensajes.f_get_descmensaje(9000780);
                                       pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1,
                                                                            9906286);
                                       -- JLB - I - Interficies CREDIT
                                       RETURN 1;
                                    ELSE
                                       IF NVL(aseg.direcciones(vdi).cdomici, 0) =
                                                                 aseg.direcciones(vdi).cdomici
                                          AND aseg.direcciones(vdi).ctipdir = 99 THEN
                                          vtexto :=
                                                  pac_iobj_mensajes.f_get_descmensaje(9905014);
                                          pac_iobj_mensajes.crea_nuevo_mensaje
                                                                              (mensajes, 1,
                                                                               NULL,
                                                                               vtexto || ' '
                                                                               || aseg.tnombre
                                                                               || ' '
                                                                               || aseg.tapelli1);
                                          RETURN 1;
                                       END IF;
                                    END IF;
                                 END IF;
                              END LOOP;
                           END IF;
                        END IF;

                        IF NVL(asegurados(i).ctipide, -1) = -1 THEN
                           pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9001178);   -- El tipus d'identificador és obligatori.
                           RETURN 1;
                        END IF;

                        vpasexec := 18;

                        IF NVL(asegurados(i).ctipide, -1) = 99 THEN
                           pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9001179);   -- El tipus d'identificador (id. de simulació) no és vàlid.
                           RETURN 1;
                        END IF;

                        vpasexec := 11;

                        IF NVL(asegurados(i).cestper, 0) = 2
                           AND NVL(pac_iaxpar_productos.f_get_parproducto('CONTRATA_MUERTO',
                                                                          poliza.sproduc),
                                   0) = 0 THEN   -- Mort
                           pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 101253);
                           RETURN 1;
                        END IF;

                        IF poliza.cobjase = 1 THEN   -- Solo si el objeto asegurado es personal
                           IF NVL(asegurados(i).ctipper, 0) = 2 THEN   -- El asegurado no puede ser persona jurídica
                              pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 152093);
                              RETURN 1;
                           END IF;

                           vpasexec := 12;

                           IF asegurados(i).fnacimi IS NULL
                              OR asegurados(i).csexper IS NULL THEN
                              pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 151133);
                              RETURN 1;
                           END IF;

                           --ini BUG10798-27/07/2009-JMF: CRE - Migración Salud. Errores detectados en pruebas
                           IF (pac_iax_produccion.issuplem
                               AND(poliza.nmovimi = riesgo.nmovima))
                              OR NOT pac_iax_produccion.issuplem THEN
                              --fin BUG10798-27/07/2009-JMF: CRE - Migración Salud. Errores detectados en pruebas
                              errnum :=
                                 pac_md_validaciones.f_valida_edad_prod
                                                    (asegurados(i), poliza.sproduc,

                                                     -- poliza.gestion.fefecto,
                                                     riesgo.fefecto,   -- BUG11107:DRA:21/09/2009
                                                     mensajes);
                           END IF;

                           vpasexec := 10;

                           IF errnum > 0 THEN
                              RAISE e_object_error;
                           END IF;

                           --
                           IF v_val_tomase = 1 THEN
                              --
                              IF NOT v_t_tomadores.EXISTS(asegurados(i).sperson)
                                 AND asegurados(i).cparen IS NULL THEN
                                 --
                                 v_t_tomadores.DELETE;
                                 --
                                 pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9908161);
                                 --
                                 RETURN 1;
                              --
                              END IF;
                           --
                           END IF;
                        --
                        END IF;

                        -- BUG 11330 - 15/10/2009 - FAL - Recuperar fefecto para informar en pac_md_validaciones.f_valida_producto_unico
                        IF pac_iax_produccion.issuplem THEN
                           v_nerror :=
                              pac_md_suplementos.f_get_fefecto_supl(NVL(poliza.nsolici,
                                                                        poliza.sseguro),
                                                                    poliza.nmovimi, vfefecto,
                                                                    mensajes);

                           IF v_nerror <> 0 THEN
                              vpasexec := 12;
                              RAISE e_object_error;
                           END IF;
                        ELSE
                           vfefecto := NULL;   --poliza.gestion.fefecto;
                        END IF;

                        -- FI BUG 11330  - 15/10/2009  FAL
                        vpasexec := 13;

                        -- BUG15740:DRA:17/09/2010:Inici
                        IF NOT pac_iax_produccion.issimul THEN
                           errnum :=
                              pac_md_validaciones.f_valida_producto_unico
                                                                        (poliza.sproduc,
                                                                         asegurados(i).spereal,
                                                                         poliza.ssegpol,
                                                                         vfefecto,

                                                                         -- JLB - 26301 - I - RSA - Validación póliza partner
                                                                         poliza.cagente,
                                                                         poliza.cpolcia,

                                                                         -- JLB - 26301 - F - RSA - Validación póliza partner
                                                                         mensajes);
                           vpasexec := 14;

                           IF errnum > 0 THEN
                              -- pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 151240);  -- bug 10515: 08/07/2009:ETM: 2parte
                              RETURN 1;
                           END IF;
                        END IF;

                        -- BUG15740:DRA:17/09/2010:Fi
                        vpasexec := 15;

                        -- BUG15740:DRA:17/09/2010:Inici
                        IF NOT pac_iax_produccion.issimul THEN
                           errnum :=
                              pac_md_validaciones.f_valida_no_pol_pendientes
                                                                        (poliza.sproduc,
                                                                         asegurados(i).spereal,
                                                                         poliza.ssegpol,
                                                                         mensajes);
                           vpasexec := 16;

                           IF errnum > 0 THEN
                              pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, errnum);
                              RETURN 1;
                           END IF;
                        END IF;

                        -- BUG15740:DRA:17/09/2010:Fi
                        vpasexec := 17;

                        -- JLB - I - INTERFAZ CREDIT
                         -- si queremos que valide la direccion del producto se tiene que definir este  parproducto);
                        IF pac_mdpar_productos.f_get_parproducto('VALIDADIRECASEG',
                                                                 poliza.sproduc) = 1 THEN
                           IF asegurados(i).direcciones.COUNT > 0 THEN
                              FOR vdi IN
                                 asegurados(i).direcciones.FIRST .. asegurados(i).direcciones.LAST LOOP
                                 IF asegurados(i).direcciones.EXISTS(vdi) THEN
                                    errnum :=
                                       pac_md_persona.f_valida_direccion
                                          (asegurados(i).sperson,
                                           asegurados(i).direcciones(vdi).cdomici,   --?? direccion? escogida tomador
                                           mensajes);

                                    IF errnum <> 0 THEN
                                       pac_iobj_mensajes.crea_nuevo_mensaje
                                               (mensajes, 1, NULL,
                                                pac_iobj_mensajes.f_get_descmensaje(9000672)
                                                || ' ' || asegurados(i).tnombre || ' '
                                                || asegurados(i).tapelli1 || ' '
                                                || asegurados(i).tapelli2);
                                       RETURN 1;
                                    END IF;
                                 END IF;
                              END LOOP;
                           ELSE
                              pac_iobj_mensajes.crea_nuevo_mensaje
                                                 (mensajes, 1, NULL,
                                                  pac_iobj_mensajes.f_get_descmensaje(9905014));
                              RETURN 1;
                           END IF;
                        END IF;

                        -- valido la persona
                        IF pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa(),
                                                         'VALIDADATOSASEGURADO') = 1 THEN
                           errnum := pac_md_persona.f_validapersona(asegurados(i).sperson,
                                                                    mensajes);

                           IF errnum <> 0 THEN
                              pac_iobj_mensajes.crea_nuevo_mensaje
                                               (mensajes, 1, NULL,
                                                pac_iobj_mensajes.f_get_descmensaje(9000671)
                                                || ' ' || asegurados(i).tnombre || ' '
                                                || asegurados(i).tapelli1 || ' '
                                                || asegurados(i).tapelli2);
                              RETURN 1;
                           END IF;
                        END IF;
                     -- JLB - F - Interfaz credit
                     END IF;
                  END LOOP;
               ELSE
                  IF v_aseg_no_riesgo = 1
                     AND(asegurados IS NULL
                         OR asegurados.COUNT = 0) THEN
                     pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9001041);   --'No existen asegurados'
                     RETURN 1;
                  END IF;
               END IF;
            -- BUG20642:DRA:2/1/2012:Fi
            END IF;
         END IF;
      END LOOP;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_validadatosasegurados;

-- JLB - F - INICIO

   /*************************************************************************
      Valida datos gestión y las preguntas a nivel de póliza
      param out mensajes : mensajes de error
      return             : 0 todo correcto
                           1 ha habido un error
   *************************************************************************/
   FUNCTION f_validadatosgstpregpol(mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      gest           ob_iax_gestion;
      errnum         NUMBER := 0;
      poliza         ob_iax_detpoliza;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_IAX_VALIDACIONES.F_ValidaDatosGstPregPol';
      v_aux          NUMBER := 0;
   BEGIN
      poliza := f_getpoliza(mensajes);
      -- BUG29605:DRA:Inicializamos antes de grabar para no perder la vpmode
      -- Bug 19715 - RSC - 16/12/2011 - LCOL: Migración de productos de Vida Individual
      errnum := pac_md_grabardatos.f_inicializa(pac_iax_produccion.vpmode,
                                                pac_iax_produccion.vsolicit,
                                                pac_iax_produccion.vnmovimi, mensajes);

      IF errnum = 1 THEN
         RETURN errnum;
      END IF;

      -- BUG29605:DRA:Fi

      -- Bug 13570 - RSC - 23/07/2010 - CRE998 - Nuevo Producto Pla Estudiant Garantit
      -- Adelantamos grabación en las 'EST'
      errnum := pac_md_grabardatos.f_grabardatospoliza(poliza, mensajes);

      IF errnum = 1 THEN
         RETURN errnum;
      END IF;

      -- Fin Bug 13570
      errnum := pac_md_grabardatos.f_grabarpreguntes(poliza.preguntas, mensajes);

      IF errnum = 1 THEN
         RETURN errnum;
      END IF;

      -- Fin Bug 19715

      -- Valida Dades Gestió
      errnum := f_validadatosgestion(mensajes);

      IF errnum > 0 THEN
         RETURN errnum;
      END IF;

      --errnum:=F_ValidaPreguntas(poliza.preguntas,'P',mensajes); --BUG 7643
      IF poliza.preguntas IS NOT NULL THEN
         IF poliza.preguntas.COUNT > 0 THEN
            errnum :=
               f_validapreguntas
                         (poliza.sseguro,
                          poliza.gestion.cactivi /*bug 9916: ETM :16-06-09:--poliza.cactivi,*/,
                          NULL, NULL, NULL, NULL, 'EST',   -- BUG11091:DRA:21/09/2009
                          poliza.preguntas, 'P', mensajes);   --BUG 7643
         END IF;
      END IF;

      RETURN errnum;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_validadatosgstpregpol;

   /*************************************************************************
      Valida la gestión de riesgos, que los datos de los distintos riesgos
      esten informados
      param out mensajes : mensajes de error
      return             : 0 todo correcto
                           1 ha habido un error
   *************************************************************************/
   FUNCTION f_validagestionriesgos(mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      riesgos        t_iax_riesgos;
      garant         t_iax_garantias;
      poliza         ob_iax_detpoliza;
      nerr           NUMBER;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_IAX_VALIDACIONES.F_ValidaGestionRiesgos';
   BEGIN
      poliza := f_getpoliza(mensajes);
      vpasexec := 2;
      riesgos := pac_iobj_prod.f_partpolriesgos(poliza, mensajes);
      vpasexec := 3;

      IF riesgos IS NULL THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000441);   --'No existen riesgos asociados a la póliza'
         RETURN 1;
      ELSE
         vpasexec := 4;

         IF riesgos.COUNT = 0 THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000441);   --'No existen riesgos asociados a la póliza'
            RETURN 1;
         END IF;
      END IF;

      vpasexec := 5;

      FOR vrie IN riesgos.FIRST .. riesgos.LAST LOOP
         IF riesgos.EXISTS(vrie) THEN
            IF riesgos(vrie).fanulac IS NULL THEN   -- BUG11047:DRA:08/09/2009: Solo si el riesgo no está anulado
               vpasexec := 6;
               garant := pac_iobj_prod.f_partriesgarantias(riesgos(vrie), mensajes);
               vpasexec := 7;

               IF garant IS NULL THEN
                  pac_iobj_mensajes.crea_nuevo_mensaje
                                               (mensajes, 1, NULL,
                                                pac_iobj_mensajes.f_get_descmensaje(9000737)
                                                || ' ' || riesgos(vrie).triesgo);   --No se han seleccionado garantias para el riesgo
                  RETURN 1;
               ELSE
                  vpasexec := 8;

                  IF garant.COUNT = 0 THEN
                     pac_iobj_mensajes.crea_nuevo_mensaje
                                               (mensajes, 1, NULL,
                                                pac_iobj_mensajes.f_get_descmensaje(9000737)
                                                || ' ' || riesgos(vrie).triesgo);   --No se han seleccionado garantias para el riesgo
                     RETURN 1;
                  END IF;
               END IF;

               vpasexec := 9;

               -- nerr:=PAC_MD_VALIDACIONES.F_VALIDAR_GARANTIAS_AL_TARIFAR(poliza.sseguro,riesgos(vrie).nriesgo,poliza.nmovimi,poliza.sproduc,poliza.cactivi,mensajes);

               --                IF nerr>0 THEN
               --        RAISE e_object_error;
               --    END IF;
               FOR vgar IN garant.FIRST .. garant.LAST LOOP
                  IF garant.EXISTS(vgar) THEN
                     vpasexec := 10;

                     IF garant(vgar).primas IS NULL THEN
                        pac_iobj_mensajes.crea_nuevo_mensaje
                                               (mensajes, 1, NULL,
                                                pac_iobj_mensajes.f_get_descmensaje(9000738)
                                                || ' ' || riesgos(vrie).triesgo);   --No se han tarificado las garantias para el riesgo
                        RETURN 1;
                     END IF;

                     vpasexec := 11;

                     IF garant(vgar).primas.needtarifar = 1 THEN
                        pac_iobj_mensajes.crea_nuevo_mensaje
                                               (mensajes, 1, NULL,
                                                pac_iobj_mensajes.f_get_descmensaje(9000738)
                                                || ' ' || riesgos(vrie).triesgo);   --No se han tarificado las garantias para el riesgo
                        RETURN 1;
                     END IF;
                  END IF;
               END LOOP;

               -- ini jtg
               IF riesgos(vrie).needtarifar = 1 THEN
                  pac_iobj_mensajes.crea_nuevo_mensaje
                                               (mensajes, 1, NULL,
                                                pac_iobj_mensajes.f_get_descmensaje(9000739)
                                                || ' ' || riesgos(vrie).triesgo);   --Se debe tarifar el riesgo
                  RETURN 1;
               END IF;
            -- fin jtg
            END IF;
         END IF;
      END LOOP;

      nerr := f_validadpreggarant(mensajes);

      IF nerr > 0 THEN
         RETURN 1;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_validagestionriesgos;

   /*************************************************************************
      Valida las preguntas del riesgo y sus garantias
      param out mensajes : mensajes de error
      return             : 0 todo correcto
                           1 ha habido un error
   *************************************************************************/
   FUNCTION f_validadpreggarant(mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      poliza         ob_iax_detpoliza;
      riesgos        t_iax_riesgos;
      garant         t_iax_garantias;
      nerr           NUMBER;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_IAX_VALIDACIONES.F_ValidaDPregGarant';
   BEGIN
      poliza := f_getpoliza(mensajes);
      vpasexec := 2;
      riesgos := pac_iobj_prod.f_partpolriesgos(poliza, mensajes);

      IF riesgos IS NULL THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000441);   --'No existen riesgos asociados a la póliza'
         RETURN 1;
      ELSE
         IF riesgos.COUNT = 0 THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000441);   --'No existen riesgos asociados a la póliza'
            RETURN 1;
         END IF;
      END IF;

      vpasexec := 3;

      FOR vrie IN riesgos.FIRST .. riesgos.LAST LOOP
         vpasexec := 4;

         IF riesgos.EXISTS(vrie) THEN
            IF riesgos(vrie).fanulac IS NULL THEN   -- BUG11047:DRA:08/09/2009: Solo si el riesgo no está anulado
               nerr := f_validadpreggarantriesgo(riesgos(vrie).nriesgo, mensajes);

               IF nerr > 0 THEN   -- BUG17919:DRA:8/3/2011
                  RETURN 1;
               END IF;
            END IF;
         END IF;
      END LOOP;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_validadpreggarant;

   /*************************************************************************
      Valida las preguntas del riesgo y sus garantias de un riesgo concreto
      param out mensajes : mensajes de error
      return             : 0 todo correcto
                           1 ha habido un error
   *************************************************************************/
   FUNCTION f_validadpreggarantriesgo(pnriesgo IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(80) := 'pnriesgo=' || pnriesgo;
      vobject        VARCHAR2(200) := 'PAC_IAX_VALIDACIONES.F_ValidaDPregGarantRiesgo';
      poliza         ob_iax_detpoliza;
      riesgo         ob_iax_riesgos;
      garant         t_iax_garantias;
      nerr           NUMBER;
      vdesc          VARCHAR2(200);
   BEGIN
      nerr := pac_iaxpar_productos.f_get_prodtienepreg('R', mensajes);

      IF nerr = 0 THEN
         RETURN 0;
      END IF;

      poliza := f_getpoliza(mensajes);
      riesgo := pac_iobj_prod.f_partpolriesgo(poliza, pnriesgo, mensajes);

      IF riesgo IS NULL THEN
         -- PAC_IOBJ_MENSAJES.CREA_NUEVO_MENSAJE(mensajes,1,46661,'No existen riesgos asociados a la póliza');
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000441);
         RETURN 1;
      END IF;

      vpasexec := 5;

      IF riesgo.fanulac IS NULL THEN   -- BUG11047:DRA:08/09/2009: Solo si el riesgo no está anulado
         -- Bug 11735 - RSC - 19/01/2010 - APR - suplemento de modificación de capital /prima
         -- Bug 11735 - RSC - 22/03/2010 - APR - suplemento de modificación de capital /prima (añadimos isbajagar)
         IF NOT(pac_iax_produccion.isaltagar
                OR pac_iax_produccion.imodifgar
                OR pac_iax_produccion.isbajagar) THEN
            -- Fin Bug 11735

            -- Bug 22839 - RSC - 25/07/2012 - LCOL - Funcionalidad Certificado 0
            IF NOT pac_iax_produccion.isaltacol THEN
               -- Fin Bug 0022839
               IF riesgo.preguntas IS NULL THEN
                  -- PAC_IOBJ_MENSAJES.CREA_NUEVO_MENSAJE(mensajes,1,47161,'No existen datos del riesgo asociado al riesgo '||riesgo.triesgo);
                  vdesc :=
                     pac_iobj_mensajes.f_get_descmensaje(1000442,
                                                         pac_md_common.f_get_cxtidioma());
                  pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 0,
                                                       vdesc || riesgo.triesgo);
                  RETURN 1;
               END IF;
            -- Bug 22839 - RSC - 25/07/2012 - LCOL - Funcionalidad Certificado 0
            END IF;

            -- Fin bug 22839
            vpasexec := 6;
            --nerr:= PAC_IAX_VALIDACIONES.F_VALIDAPREGUNTAS(riesgo.preguntas,'R',mensajes);--Bug 7643
            nerr := pac_iax_validaciones.f_validapreguntas(poliza.sseguro, NULL,
                                                           riesgo.nriesgo, NULL,
                                                           poliza.nmovimi, NULL, 'EST',   -- BUG11091:DRA:21/09/2009
                                                           riesgo.preguntas, 'R', mensajes);   --bug 7643

            IF nerr <> 0 THEN   --Bug 7643
               RETURN 1;
            END IF;
         -- Bug 11735 - RSC - 19/01/2010 - APR - suplemento de modificación de capital /prima
         END IF;

         -- Fin Bug 11735
         vpasexec := 7;

         IF riesgo.garantias IS NULL THEN
            --   PAC_IOBJ_MENSAJES.CREA_NUEVO_MENSAJE(mensajes,1,47161,'No existen garantias asociadas al riesgo '||riesgo.triesgo);
            vdesc := pac_iobj_mensajes.f_get_descmensaje(1000443,
                                                         pac_md_common.f_get_cxtidioma());
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 0, vdesc || riesgo.triesgo);
            RETURN 1;
         ELSE
            IF riesgo.garantias.COUNT = 0 THEN
               --    PAC_IOBJ_MENSAJES.CREA_NUEVO_MENSAJE(mensajes,1,47161,'No existen garantias asociadas al riesgo '||riesgo.triesgo);
               vdesc := pac_iobj_mensajes.f_get_descmensaje(1000443,
                                                            pac_md_common.f_get_cxtidioma());
               pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 0, vdesc || riesgo.triesgo);
               RETURN 1;
            END IF;
         END IF;

         -- Bug 11735 - RSC - 19/01/2010 - APR - suplemento de modificación de capital /prima
         -- Bug 11735 - RSC - 22/03/2010 - APR - suplemento de modificación de capital /prima (añadimos isbajagar)
         IF NOT(pac_iax_produccion.isaltagar
                OR pac_iax_produccion.imodifgar
                OR pac_iax_produccion.isbajagar) THEN
            --JRH 03/2008 Validamos rentas irregulares
            vpasexec := 8;
            nerr := pac_md_validaciones_aho.f_valida_rentairreg(pnriesgo, mensajes);

            IF nerr <> 0 THEN
               RAISE e_object_error;
            END IF;
         -- Bug 11735 - RSC - 19/01/2010 - APR - suplemento de modificación de capital /prima
         END IF;

         -- Fin Bug 11735

         --JRH 03/2008
         vpasexec := 9;
         garant := riesgo.garantias;
         vpasexec := 10;

         IF garant IS NOT NULL THEN   -- BUG11091:DRA:21/09/2009
            vpasexec := 11;

            IF garant.COUNT <> 0 THEN   -- BUG11091:DRA:21/09/2009
               vpasexec := 12;

               FOR vgar IN garant.FIRST .. garant.LAST LOOP
                  vpasexec := 13;

                  IF garant.EXISTS(vgar) THEN
                     vpasexec := 14;

                     IF garant(vgar).cobliga = 1 THEN   -- BUG11091:DRA:21/09/2009: solo la analizamos si está marcada
                        --nerr:= PAC_IAX_VALIDACIONES.F_VALIDAPREGUNTAS(garant(vgar).preguntas,'G',mensajes,garant(vgar).cgarant);--bug 7643
                        nerr :=
                           pac_iax_validaciones.f_validapreguntas
                                                             (poliza.sseguro, NULL,
                                                              riesgo.nriesgo,
                                                              garant(vgar).cgarant,
                                                              poliza.nmovimi, riesgo.nmovima,
                                                              'EST',   -- BUG11091:DRA:21/09/2009
                                                              garant(vgar).preguntas, 'G',
                                                              mensajes);   --bug 7643

                        IF nerr > 0 THEN
                           RETURN 1;
                        END IF;
                     END IF;

                     vpasexec := 15;
                  /*IF garant(vgar).primas IS NULL THEN
                     pac_iobj_mensajes.crea_nuevo_mensaje
                                   (mensajes, 1, 56988,
                                    'No se han tarificado las garantias para el riesgo '
                                    || riesgos(vrie).nriesgo);
                     RETURN 1;
                  END IF;

                  vpasexec := 11;

                  IF garant(vgar).primas.needtarifar = 1 THEN
                     pac_iobj_mensajes.crea_nuevo_mensaje
                                   (mensajes, 1, 56988,
                                    'No se han tarificado las garantias para el riesgo '
                                    || riesgos(vrie).nriesgo);
                     RETURN 1;
                  END IF;*/
                  END IF;
               END LOOP;
            END IF;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_validadpreggarantriesgo;

   /*************************************************************************
      Valida las clausulas
      param out mensajes : mensajes de error
      return             : 0 todo correcto
                           1 ha habido un error
   *************************************************************************/
   FUNCTION f_validaclausulas(mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      poliza         ob_iax_detpoliza;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_IAX_VALIDACIONES.F_ValidaClausulas';
      clausulas      t_iax_clausulas;
      clauprod       t_iaxpar_clausulas;
      itsok          NUMBER := 0;
      nerr           NUMBER := 0;
      vdesc          VARCHAR2(200);
   BEGIN
      poliza := f_getpoliza(mensajes);
      vpasexec := 2;
      clauprod := pac_iaxpar_productos.f_get_clausulas(mensajes);
      vpasexec := 3;

      IF clauprod IS NULL THEN
         RETURN 0;
      END IF;

      IF clauprod.COUNT = 0 THEN
         RETURN 0;
      END IF;

      vpasexec := 4;
      clausulas := poliza.clausulas;
      -- BUG9718:DRA:24/04/20009:Inici:No queremos que de error si no informamos ninguna cláusula
      --IF clausulas IS NULL THEN
      --   pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9000740);   --'Debe informar las clausulas del producto'
      --   RETURN 1;
      --END IF;
      vpasexec := 5;
      --IF clausulas.COUNT = 0 THEN
      --   pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9000740);   --'Debe informar las clausulas del producto'
      --   RETURN 1;
      --END IF;
      -- BUG9718:DRA:24/04/20009:Fi
      vpasexec := 6;

      -- Bug 26070 --ECP-- 13/02/2013
      IF clausulas IS NOT NULL THEN
         IF clausulas.COUNT > 0 THEN
            FOR vcp IN clauprod.FIRST .. clauprod.LAST LOOP
               vpasexec := 7;

               IF clauprod.EXISTS(vcp) THEN
                  vpasexec := 8;

                  IF clauprod(vcp).cobliga = 1 THEN
                     vpasexec := 9;
                     itsok := 0;

                     FOR vcl IN clausulas.FIRST .. clausulas.LAST LOOP
                        vpasexec := 10;

                        IF clausulas.EXISTS(vcl) THEN
                           vpasexec := 11;

                           IF clausulas(vcl).sclagen = clauprod(vcp).sclagen THEN
                              itsok := 1;
                           END IF;
                        END IF;
                     END LOOP;

                     vpasexec := 12;

                     IF itsok = 0 THEN
                        vdesc :=
                           pac_iobj_mensajes.f_get_descmensaje
                                                              (9000741,
                                                               pac_md_common.f_get_cxtidioma
                                                                                            ());   --Debe seleccionar la clausula
                        pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 0,
                                                             vdesc || clauprod(vcp).sclagen);
                        nerr := 1;
                     END IF;
                  END IF;
               END IF;
            END LOOP;
         END IF;
      END IF;

      RETURN nerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_validaclausulas;

   /*************************************************************************
      Validación de garantias seleccionadas
      param in selgar    : 1 indica que se ha seleccionado garantia
                           0 indica que se ha deseleccionado la garantia
      param in nriego    : número de riesgo
      param in cgarant   : código garantia
      param out mensajes : mensajes de error
      return             : 0 la validación ha sido correcta
                           1 la validación no ha sido correcta
   *************************************************************************/
   FUNCTION f_validacion_cobliga(
      selgar IN NUMBER,
      nriesgo IN NUMBER,
      cgarant IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      poliza         ob_iax_detpoliza;
      rie            ob_iax_riesgos;
      gar            ob_iax_garantias;
      nerr           NUMBER;
      accio          VARCHAR2(10);
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_IAX_VALIDACIONES.F_Validacion_Cobliga';
   BEGIN
      vpasexec := 1;
      poliza := f_getpoliza(mensajes);
      vpasexec := 2;

      IF poliza IS NULL THEN
         RETURN 0;
      END IF;

      vpasexec := 3;
      rie := pac_iobj_prod.f_partpolriesgo(poliza, nriesgo, mensajes);

      IF rie IS NULL THEN
         RETURN 0;
      END IF;

      vpasexec := 4;
      gar := pac_iobj_prod.f_partriesgarantia(rie, cgarant, mensajes);

      IF gar IS NULL THEN
         RETURN 0;
      END IF;

      vpasexec := 5;

      IF selgar = 0 THEN
         accio := 'DESEL';
      ELSE
         accio := 'SEL';
      END IF;

      vpasexec := 6;
      nerr :=
         pac_md_validaciones.f_validacion_cobliga
                          (poliza.sseguro, nriesgo, gar.nmovimi, gar.cgarant, poliza.sproduc,
                           poliza.gestion.cactivi /*bug 9916: ETM :16-06-09:--poliza.cactivi,*/,
                           gar.nmovima, accio, mensajes);

      IF nerr > 0 THEN
         RAISE e_object_error;
      END IF;

      vpasexec := 7;
      RETURN nerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_validacion_cobliga;

   /*************************************************************************
      Validación de garantias seleccionadas el capital
      param in selgar    : 1 indica que se ha seleccionado garantia
                           0 indica que se ha deseleccionado la garantia
      param in nriego    : número de riesgo
      param in cgarant   : código garantia
      param out mensajes : mensajes de error
      return             : 0 la validación ha sido correcta
                           1 la validación no ha sido correcta
   *************************************************************************/
   FUNCTION f_validacion_capital(
      selgar IN NUMBER,
      nriesgo IN NUMBER,
      cgarant IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      poliza         ob_iax_detpoliza;
      rie            ob_iax_riesgos;
      gar            ob_iax_garantias;
      nerr           NUMBER;
      accio          VARCHAR2(10);
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_IAX_VALIDACIONES.F_Validacion_Capital';
   BEGIN
      vpasexec := 1;
      poliza := f_getpoliza(mensajes);
      vpasexec := 2;

      IF poliza IS NULL THEN
         RETURN 0;
      END IF;

      vpasexec := 3;
      rie := pac_iobj_prod.f_partpolriesgo(poliza, nriesgo, mensajes);

      IF rie IS NULL THEN
         RETURN 0;
      END IF;

      vpasexec := 4;
      gar := pac_iobj_prod.f_partriesgarantia(rie, cgarant, mensajes);

      IF gar IS NULL THEN
         RETURN 0;
      END IF;

      vpasexec := 5;

      IF selgar = 0 THEN
         accio := 'DESEL';
      ELSE
         accio := 'SEL';
      END IF;

      vpasexec := 6;
      nerr :=
         pac_md_validaciones.f_validacion_capital
                          (poliza.sseguro, nriesgo, gar.nmovimi, gar.cgarant, poliza.sproduc,
                           poliza.gestion.cactivi /*bug 9916: ETM :16-06-09:--poliza.cactivi,*/,
                           gar.nmovima, accio, mensajes);

      IF nerr > 0 THEN
         RAISE e_object_error;
      END IF;

      vpasexec := 7;
      --JRH 03/2008 Validamos cosas propias de productos financieros
      nerr := pac_md_validaciones_aho.f_valida_capitales_gar(poliza.sproduc, gar.cgarant,
                                                             gar.icapital, 1,
                                                             poliza.gestion.fefecto, 1,
                                                             mensajes);

      IF nerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9000742);   --'Error validando coberturas'
         RETURN 1;
      END IF;

      --JRH 03/2008
      vpasexec := 8;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_validacion_capital;

   /*************************************************************************
      Validación de garantias para tarificar
      param in psolicit  : código de seguro
      param in pnriesgo  : número de riesgo
      param in pnmovimi  : número de novimiento
      param in psproduc  : código de producto
      param in pcactivi  : código de actividad
      param out mensajes : mensajes de error
      return             : 0 la validación ha sido correcta
                           1 la validación no ha sido correcta
   *************************************************************************/
   FUNCTION f_validar_garantias_al_tarifar(
      psolicit IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_IAX_VALIDACIONES.F_Validar_Garantias_Al_Tarifar';
      nerr           NUMBER;
   BEGIN
      nerr := pac_md_validaciones.f_validar_garantias_al_tarifar(psolicit, pnriesgo, pnmovimi,
                                                                 psproduc, pcactivi, mensajes);
      RETURN nerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_validar_garantias_al_tarifar;

   /*************************************************************************
      Valida datos gestion
      param out mensajes : mensajes de error
      return             : 0 la validación ha sido correcta
                           1 la validación no ha sido correcta
   *************************************************************************/
   FUNCTION f_validadatosgestion(mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      datgest        ob_iax_gestion;
      errnum         NUMBER := 0;
      poliza         ob_iax_detpoliza;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_IAX_VALIDACIONES.F_ValidaDatosGestion';
      riesgos        t_iax_riesgos;
      riesgo         ob_iax_riesgos;
      asegurados     t_iax_asegurados;
      v_nerror       NUMBER;
      vfefecto       DATE;
      -- Bug 19715 - RSC - 13/01/2012 - LCOL: Migraci??e productos de Vida Individual
      v_cresp4044    pregunpolseg.trespue%TYPE;
      -- Fin Bug 19715
         -- Ini Bug 26488 --ECP-- 30/04/2013
      v_cresp535     pregunpolseg.crespue%TYPE;
   -- Fin Bug 26488 --ECP-- 30/04/2013
   BEGIN
      poliza := f_getpoliza(mensajes);
      -- BUG 11330 - 15/10/2009 - FAL - Incluir llamada a f_valida_producto_unico
      riesgos := pac_iobj_prod.f_partpolriesgos(poliza, mensajes);
      vpasexec := 3;

      IF riesgos IS NULL THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000643);   --'No existen riesgos'
         RAISE e_object_error;
      ELSE
         vpasexec := 4;

         IF riesgos.COUNT = 0 THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000643);   --'No existen riesgos'
            RAISE e_object_error;
         END IF;
      END IF;

      vpasexec := 5;

      FOR vrie IN riesgos.FIRST .. riesgos.LAST LOOP
         vpasexec := 6;

         IF riesgos.EXISTS(vrie) THEN
            riesgo := riesgos(vrie);

            IF riesgos(vrie).fanulac IS NULL THEN   -- BUG11047:DRA:08/09/2009: Solo si el riesgo no está anulado
               vpasexec := 61;

               IF riesgo IS NULL THEN
                  pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000642);   --'No se ha podido recuperar la información del Riesgo'
                  RETURN 1;
               END IF;

               vpasexec := 6;

               -- BUG11330:DRA:29/10/2009: Validamos el tipo de producto
               IF poliza.cobjase NOT IN(2, 3, 4, 5) THEN
                  asegurados := pac_iobj_prod.f_partriesasegurado(riesgo, mensajes);
                  vpasexec := 7;

                  IF asegurados IS NULL THEN
                     pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9000736);   --'No se ha podido recuperar la información de los Asegurados'
                     RETURN 1;
                  ELSE
                     vpasexec := 8;

                     IF asegurados.COUNT = 0 THEN
                        pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9000736);   --'No se ha podido recuperar la información de los Asegurados'
                        RETURN 1;
                     END IF;
                  END IF;

                  vpasexec := 9;

                  FOR i IN asegurados.FIRST .. asegurados.LAST LOOP
                     IF asegurados.EXISTS(i) THEN
                        vpasexec := 11;

                        IF NVL(asegurados(i).cestper, 0) = 2
                           AND NVL(pac_iaxpar_productos.f_get_parproducto('CONTRATA_MUERTO',
                                                                          poliza.sproduc),
                                   0) = 0 THEN   -- Mort
                           pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 101253);
                           RETURN 1;
                        END IF;

                        -- BUG 11330 - 15/10/2009 - FAL - Recuperar fefecto para informar en pac_md_validaciones.f_valida_producto_unico
                        IF pac_iax_produccion.issuplem THEN
                           v_nerror :=
                              pac_md_suplementos.f_get_fefecto_supl(NVL(poliza.nsolici,
                                                                        poliza.sseguro),
                                                                    poliza.nmovimi, vfefecto,
                                                                    mensajes);

                           IF v_nerror <> 0 THEN
                              vpasexec := 12;
                              RAISE e_object_error;
                           END IF;
                        ELSE
                           vfefecto := poliza.gestion.fefecto;
                        END IF;

                        -- FI BUG 11330  - 15/10/2009  FAL
                        vpasexec := 13;

                        -- BUG15740:DRA:17/09/2010:Inici
                        IF NOT pac_iax_produccion.issimul THEN
                           errnum :=
                              pac_md_validaciones.f_valida_producto_unico
                                                                        (poliza.sproduc,
                                                                         asegurados(i).spereal,
                                                                         poliza.ssegpol,
                                                                         vfefecto,

                                                                         -- JLB - 26301 - I - RSA - Validación póliza partner
                                                                         poliza.cagente,
                                                                         poliza.cpolcia,

                                                                         -- JLB - 26301 - F - RSA - Validación póliza partner
                                                                         mensajes);
                           vpasexec := 14;

                           IF errnum > 0 THEN
                              --pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 151240);  -- bug 10515: 08/07/2009:ETM: 2parte
                              RAISE e_object_error;
                           END IF;
                        END IF;

                        -- Bug 19715 - RSC - 13/01/2012 - LCOL: Migraci??e productos de Vida Individual
                        -- Aqui ya tenemos las preguntas grabadas en las EST.
                        -- Bug 25584 - FPG - 07-02-2013 - inicio
                        IF NVL(pac_parametros.f_parproducto_n(poliza.sproduc,
                                                              'VALIDA_EDAD_ASEG_PRO'),
                               1) = 0 THEN
                           --IF NVL(pac_parametros.f_parproducto_n(poliza.sproduc,
                           --                                      'VALIDA_EDAD_ASEG_PRO'),
                           --       1) = 1 THEN
                              -- Bug 25584 - FPG - 07-02-2013 - final
                           errnum := pac_preguntas.f_get_pregunpolseg_t(poliza.sseguro, 4044,
                                                                        'EST', v_cresp4044);

                           IF errnum > 0 THEN
                              IF errnum <> 120135 THEN
                                 RAISE e_object_error;
                              END IF;
                           END IF;

                           IF pac_iax_produccion.isaltacol
                              AND asegurados(i).ctipper = 2 THEN
                              NULL;
                           ELSE

                              -- Bug AMA-16 - 02/06/2016 - AMC
                               IF pac_iax_produccion.issimul and
                                  nvl(pac_parametros.f_parproducto_n(poliza.sproduc, 'FNACIMI_SIMUL'),0) = 1 THEN
                                  null;
                               ELSE
                                  errnum :=
                                     pac_md_validaciones.f_controledad
                                         (asegurados(i).fnacimi,
                                          NVL(TO_DATE(v_cresp4044, 'DD/MM/YYYY'), vfefecto),
                                          poliza.sproduc, poliza.gestion.nedamar,   -- Bug 0025584 - MMS - 23/01/2013
                                          mensajes);

                                  IF errnum > 0 THEN
                                     RAISE e_object_error;
                                  END IF;
                               END IF;
                               --Fi Bug AMA-16 - 02/06/2016 - AMC
                           END IF;
                        END IF;

                        -- Fin Bug 19715

                        -- BUG15740:DRA:17/09/2010:Fi
                        vpasexec := 15;
                     END IF;
                  END LOOP;
               END IF;
            END IF;
         END IF;
      END LOOP;

      -- FI BUG 11330  - 15/10/2009  FAL
      datgest := pac_iobj_prod.f_partpoldatosgestion(poliza, mensajes);

      IF datgest IS NULL THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9000743);   --'No se ha podido recuperar los datos de gestión'
         RETURN 1;
      END IF;

      --JRH
      IF pac_iax_produccion.isaltacol THEN
         NULL;
      ELSE
         IF datgest.ctipcob = 2
            AND datgest.cbancar IS NULL THEN
           -- pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 151033);
            --RETURN 1;
			null;
         END IF;
      END IF;

      -- Fin Bug 26488 --ECP-- 30/04/2013
      --APD
      IF datgest.cidioma IS NULL THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 102242);   -- Idioma obligatorio
         RETURN 1;
      END IF;

      -- BUG 26070 - 11/03/2013 - FPG - Inicio
      -- En coaseguro aceptado no indicar recargo de fraccionamiento
      IF poliza.ctipcoa = 8
         AND datgest.crecfra = 1 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9905090);
         RETURN 1;
      END IF;

      -- BUG 26070 - 11/03/2013 - FPG - Fin
      errnum := pac_md_validaciones.f_periodpag(datgest, poliza.sproduc, mensajes);

      IF errnum > 0 THEN
         RETURN errnum;
      END IF;

      errnum := pac_md_validaciones.f_valida_duracion(poliza, mensajes);

      IF errnum > 0 THEN
         RETURN errnum;
      END IF;

      -- Bug 8745 - 27/02/2009 - RSC - Adaptación iAxis a productos colectivos con certificados
      errnum := pac_md_validaciones.f_valida_gestioncertifs(datgest, poliza, mensajes);

      IF errnum > 0 THEN
         RETURN errnum;
      END IF;

      -- Fin Bug 8745
      IF NOT pac_iax_produccion.issuplem
         AND poliza.csituac <> 5 THEN   -- BUG11583:DRA:19/02/2010
         -- ACC 250608 no es pot comprovar si es un suplement faltari verificar tipus suplement
         -- BUG 19276 JBN
         IF poliza.reemplazos.COUNT = 0 THEN
            
			IF poliza.sproduc <> 8062 THEN 
                errnum := pac_md_validaciones.f_valida_fefecto(datgest, poliza.sproduc, mensajes);
            END IF;

         ELSE
            errnum := pac_md_validaciones.f_valida_gestion_reemplazo(poliza.reemplazos,
                                                                     poliza.gestion, mensajes);
         END IF;

         -- FI BUG 19276 JBN
         IF errnum > 0 THEN
            RETURN errnum;
         END IF;

         errnum := pac_md_validaciones.f_valida_polissaini(datgest, poliza.sproduc, mensajes);

         -- BUG15617:DRA:09/09/2010:Inici
         IF errnum <> 0 THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, errnum);
            RETURN errnum;
         END IF;
      -- BUG15617:DRA:09/09/2010:Fi
      END IF;

      -- BUG 27505 2013-08-02 SHA
      --Añadimos validaciones de num. de preimpreso y poliza manual
      IF datgest.npolizamanual = 1 THEN   -- asignacion manual
         errnum :=
            pac_md_validaciones.f_valida_polizamanual(datgest.ctipoasignum,
                                                      datgest.npolizamanual, poliza.sseguro,
                                                      poliza.sproduc,
                                                      pac_md_common.f_get_cxtempresa(),
                                                      poliza.cagente, 'EST', mensajes);

         IF errnum <> 0 THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9904933);
            RAISE e_object_error;
         END IF;
      END IF;

      IF datgest.npreimpreso IS NOT NULL THEN
         errnum := pac_md_validaciones.f_valida_npreimpreso(datgest.ctipoasignum,
                                                            datgest.npreimpreso,
                                                            poliza.sseguro, poliza.sproduc,
                                                            pac_md_common.f_get_cxtempresa(),
                                                            poliza.cagente, 'EST', mensajes);

         IF errnum <> 0 THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9904934);
            RAISE e_object_error;
         END IF;
      END IF;

      -- fin BUG 27505 2013-08-02 SHA

      --Bug 8286 AMC 04/03/2009 Validacion % de reversión y % capital fallecimiento
      -- Bug 11597 JGM - 26/10/2009 - se quita la llamada y se mueve ya que
      --La función f_valida_por_rev_fall tiene que estar en el pac_md_validaciones_aho y
      --ser llamada ya directamente desde el pac_md_validaciones_aho.f_valida_datosgest.

      /*errnum := pac_md_validaciones.f_valida_por_rev_fall(poliza.sproduc, datgest.pdoscab,
                                                          datgest.pcapfall, mensajes);

      IF errnum > 0 THEN
         RETURN errnum;
      END IF;*/

      --JRH 03/2008 Validaciones Financieras
      errnum := pac_md_validaciones_aho.f_valida_datosgest(poliza.sproduc, datgest, mensajes);

      IF errnum > 0 THEN
         RETURN errnum;
      END IF;

      errnum := pac_md_validaciones.f_valida_agente(poliza.cagente, poliza.sproduc, mensajes);

      IF errnum > 0 THEN
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_validadatosgestion;

   /*************************************************************************
      Valida garantias
      param out mensajes : mensajes de error
      return             : 0 la validación ha sido correcta
                           1 la validación no ha sido correcta
   *************************************************************************/
   FUNCTION f_validagarantias(mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      garantias      t_iax_garantias;
      riesgos        t_iax_riesgos;
      riesgo         ob_iax_riesgos;
      poliza         ob_iax_detpoliza;
      nerr           NUMBER;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_IAX_VALIDACIONES.F_ValidaGarantias';
      vdesc          VARCHAR2(200);
   BEGIN
      poliza := f_getpoliza(mensajes);
      riesgos := pac_iobj_prod.f_partpolriesgos(poliza, mensajes);

      IF riesgos IS NULL THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9000781);   --'No se ha podido recuperar la información de los Riesgos'
         RETURN 1;
      ELSE
         IF riesgos.COUNT = 0 THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9000781);   --'No se ha podido recuperar la información de los Riesgos'
            RETURN 1;
         END IF;
      END IF;

      FOR vri IN riesgos.FIRST .. riesgos.LAST LOOP
         IF riesgos.EXISTS(vri) THEN
            IF riesgos(vri).fanulac IS NULL THEN   -- BUG11047:DRA:08/09/2009: Solo si el riesgo no está anulado
               garantias := pac_iobj_prod.f_partriesgarantias(riesgos(vri), mensajes);

               IF garantias IS NULL THEN
                  vdesc :=
                     pac_iobj_mensajes.f_get_descmensaje(9000782,
                                                         pac_md_common.f_get_cxtidioma());   --No se ha podido recuperar la información de Garantias del riesgo
                  pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 0,
                                                       vdesc || riesgos(vri).triesgo);
                  RETURN 1;
               ELSE
                  IF garantias.COUNT = 0 THEN
                     vdesc :=
                        pac_iobj_mensajes.f_get_descmensaje(9000782,
                                                            pac_md_common.f_get_cxtidioma());   --No se ha podido recuperar la información de Garantias del riesgo
                     pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 0,
                                                          vdesc || riesgos(vri).triesgo);
                     RETURN 1;
                  END IF;
               END IF;

               FOR vgar IN garantias.FIRST .. garantias.LAST LOOP
                  IF garantias.EXISTS(vgar) THEN
                     nerr :=
                        f_validar_garantias_al_tarifar
                           (poliza.sseguro, riesgos(vri).nriesgo, poliza.nmovimi,
                            poliza.sproduc,
                            poliza.gestion.cactivi /*bug 9916: ETM :16-06-09:--poliza.cactivi,*/,
                            mensajes);

                     IF nerr > 0 THEN
                        RETURN nerr;
                     END IF;
                  END IF;
               END LOOP;
            END IF;
         END IF;
      END LOOP;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_validagarantias;

   /*************************************************************************
      --bug 7643 Valida preguntas a nivel de póliza, riesgo y garantías
      param in  Psseguro  : Código de Seguro       Vendrá informado siempre
      param in  Pcactivi  : Código de Actividad    Vendrá informado siempre
      param in  Pnriesgo  : Código de Riesgo       Vendrá informado si son preguntas a nivel de riesgo o garantía
      param in  Pcgarant  : Código de Garantía     Vendrá informado si son preguntas a nivel de garantía
      param in  Pnmovimi  : Número de Movimiento   Vendrá informado si son preguntas a nivel de garantía
      param in  Pnmovima  : Movimiento de alta     Vendrá informado si son preguntas a nivel de garantía --bug 7643
      param in  ptablas   : Tablas
      param in preguntas : objeto preguntas
      param in nivelPreg : P póliza - R riesgo - G garantia
      param out mensajes : mensajes de error
      --param in pcgarant  : código de la garantia (puede se nula)
      return             : 0 la validación ha sido correcta
                           1 la validación no ha sido correcta
   *************************************************************************/
   FUNCTION f_validapreguntas(
      psseguro IN NUMBER,   --Bug 7643
      pactivi IN NUMBER,   --Bug 7643
      pnriesgo IN NUMBER,   --Bug 7643
      pcgarant IN NUMBER,   --Bug 7643
      pnmovimi IN NUMBER,   --Bug 7643
      pnmovima IN NUMBER,   --Bug 7643
      ptablas IN VARCHAR2,   -- BUG11091:DRA:21/09/2009
      preguntas IN t_iax_preguntas,
      nivelpreg IN VARCHAR2,
      mensajes OUT t_iax_mensajes
                                 --,pcgarant IN NUMBER DEFAULT NULL) --Bug 7643 COMENTADO POR ORDEN
   )
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_IAX_VALIDACIONES.F_ValidaPreguntas';
      ispreg         NUMBER;
      prgpar         t_iaxpar_preguntas;
      poliza         ob_iax_detpoliza;   --7643
      garantias      ob_iax_garantias;   --7643
      vicapital      NUMBER;
      errnum         NUMBER := 0;   --7643
   BEGIN
      poliza := f_getpoliza(mensajes);   --7643
      ispreg := pac_iaxpar_productos.f_get_prodtienepreg(nivelpreg, mensajes, pcgarant);

      IF ispreg = 0 THEN
         RETURN 0;
      END IF;

      vpasexec := 2;

      -- Bug 22839 - RSC - 25/07/2012 - LCOL - Funcionalidad Certificado 0
      IF pac_iax_produccion.isaltacol
         AND nivelpreg = 'R'
         AND preguntas IS NULL THEN   -- Bug 26501 - MMS - 18/06/2013
         RETURN 0;
      END IF;

      -- Fin Bug 22839
      IF preguntas IS NULL THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9000744);   --'No se ha podido recuperar la informació de las Preguntas'
         RETURN 1;
      END IF;

      vpasexec := 3;

      IF nivelpreg = 'P' THEN
         prgpar := pac_iaxpar_productos.f_get_pregpoliza(mensajes);
      ELSIF nivelpreg = 'R' THEN
         prgpar := pac_iaxpar_productos.f_get_datosriesgos(mensajes);
      ELSE
         prgpar := pac_iaxpar_productos.f_get_preggarant(pcgarant, mensajes);
      END IF;

      vpasexec := 4;

      /* FOR vprp IN preguntas.first..preguntas.last LOOP --Bug 7643
           vpasexec:=5;
           IF preguntas.exists(vprp) THEN
               vpasexec:=6;
               FOR vprg IN prgPar.first..prgPar.last LOOP
                   vpasexec:=7;
                   IF prgPar.exists(vprg) THEN
                       vpasexec:=8;
                       IF prgPar(vprg).cpregun= preguntas(vprp).cpregun THEN
                           vpasexec:=9;
                           IF prgPar(vprg).cpreobl=1 THEN
                               vpasexec:=10;
                               IF preguntas(vprp).crespue is null AND preguntas(vprp).trespue is null THEN
                                   vpasexec:=11;
                                   vdesc := PAC_IOBJ_MENSAJES.F_Get_DescMensaje(9000686, pac_md_common.F_Get_CXTIdioma()); --Debe contestar a la pregunta
                                   PAC_IOBJ_MENSAJES.CREA_NUEVO_MENSAJE(mensajes,1,0,vdesc|| prgPar(vprg).tpregun);
                               END IF;
                           END IF;
                       END IF;
                   END IF;
               END LOOP;
           END IF;
       END LOOP;*/

      --Bug 11474: CRE - Error en la simulació de rendes - XPL 20102009
      IF prgpar IS NOT NULL
         AND preguntas IS NOT NULL THEN
         IF prgpar.COUNT > 0
            AND preguntas.COUNT > 0 THEN
            errnum :=
               pac_md_validaciones.f_validapreguntas(psseguro, pactivi,
                                                     poliza.gestion.fefecto, pnriesgo,
                                                     pcgarant, pnmovimi, pnmovima,
                                                     garantias.icapital, ptablas,   -- BUG11091:DRA:21/09/2009
                                                     preguntas, prgpar, mensajes);
         END IF;
      END IF;

      IF errnum <> 0 THEN
         RAISE e_object_error;
      END IF;

      --Fin Bug 7643
      vpasexec := 12;

      IF mensajes IS NOT NULL THEN
         IF mensajes.COUNT > 0 THEN
            RETURN 1;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_validapreguntas;

   /*************************************************************************
      Valida los datos del objeto riesgo
      param out mensajes : mensajes de error
      return             : 0 todo correcto
                           1 ha habido un error
   *************************************************************************/
   FUNCTION f_validariesgos(mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      poliza         ob_iax_detpoliza;
      riesgos        t_iax_riesgos;
      riesgo         ob_iax_riesgos;
      vpasexec       NUMBER(8) := 1;
      vobject        VARCHAR2(200) := 'PAC_IAX_VALIDACIONES.F_ValidaRiesgos';
      vparam         VARCHAR2(1) := NULL;
      vauto          ob_iax_autriesgos;
      vnumerr        NUMBER(10);
   BEGIN
      poliza := f_getpoliza(mensajes);
      vpasexec := 2;
      riesgos := pac_iobj_prod.f_partpolriesgos(poliza, mensajes);
      vpasexec := 3;

      IF riesgos IS NULL THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000643);
         RETURN 1;
      END IF;

      FOR vrie IN riesgos.FIRST .. riesgos.LAST LOOP
         vpasexec := 4;

         IF riesgos.EXISTS(vrie) THEN
            riesgo := riesgos(vrie);
            vpasexec := 5;

            IF riesgo IS NULL THEN
               pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000642);
               RETURN 1;
            END IF;

            IF riesgos(vrie).fanulac IS NULL THEN   -- BUG11047:DRA:08/09/2009: Solo si el riesgo no está anulado
               vpasexec := 6;

               IF NVL(poliza.cobjase, 0) = 2 THEN
                  IF riesgo.riesdireccion IS NOT NULL THEN
                     IF riesgo.riesdireccion.tdomici IS NULL THEN
                        vpasexec := 7;
                        pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000641);
                        RETURN 1;
                     END IF;

                     IF riesgo.riesdireccion.cpoblac IS NULL THEN
                        vpasexec := 8;
                        pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000652);
                        RETURN 1;
                     END IF;

                     IF riesgo.riesdireccion.cprovin IS NULL THEN
                        vpasexec := 9;
                        pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000640);
                        RETURN 1;
                     END IF;

                     IF riesgo.tnatrie IS NULL THEN
                        vpasexec := 10;
                        pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 102525);
                        RETURN 1;
                     END IF;

                     IF riesgo.riesdireccion.tdomici <> riesgo.tnatrie THEN
                        vpasexec := 11;
                        pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000639);
                        RETURN 1;
                     END IF;

                     -- BUG 26702 - FAL - 26/04/2013
                     IF NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa(),
                                                          'CPOSTAL_NO_OBLIGA'),
                            0) = 0 THEN
                        -- FI BUG 26702
                        IF riesgo.riesdireccion.cpostal IS NULL THEN
                           vpasexec := 7;
                           pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000651);
                           RETURN 1;
                        END IF;
                     END IF;

                     IF riesgo.riesdireccion.cpais IS NULL THEN
                        vpasexec := 7;
                        pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000653);
                        RETURN 1;
                     END IF;
                  ELSE
                     --Bug 25697/135047- XVM - 17/01/2013.Se añade ELSE
                     pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9904800);
                     RETURN 1;
                  END IF;
               ELSIF NVL(poliza.cobjase, 0) IN(3, 4) THEN
                  IF riesgo.tnatrie IS NULL THEN
                     vpasexec := 12;
                     pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 102525);
                     RETURN 1;
                  END IF;

                  IF poliza.cobjase = 4
                     AND riesgo.riesdescripcion.nasegur IS NULL THEN
                     vpasexec := 13;
                     pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 104051);
                     RETURN 1;
                  END IF;
               --BUG 9247-24022009-XVM
               ELSIF NVL(poliza.cobjase, 0) = 5 THEN   --objecte d'autos
                  IF riesgo.riesautos IS NOT NULL THEN
                     FOR vaut IN riesgo.riesautos.FIRST .. riesgo.riesautos.LAST LOOP
                        IF riesgos.EXISTS(vrie) THEN
                           vauto := riesgo.riesautos(vaut);
                           vpasexec := 14;
                           vnumerr := pac_md_validaciones_aut.f_valida_rieauto(vauto,
                                                                               mensajes);

                           IF vnumerr <> 0 THEN
                              pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
                              RAISE e_object_error;
                           END IF;
                        END IF;
                     END LOOP;
                  END IF;
               --BUG 9247-24022009-XVM
               END IF;
            END IF;
         END IF;
      END LOOP;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_validariesgos;

   /*************************************************************************
      Valida de que se ha impreso el cuestionario de salud
      param in ppulsado : 0 No pulsado, 1 pulsado
      param in pmodo : 'SIM', 'ALT' o 'SUP'
      param in psseguro : Código de Seguro
      param in pnriesgo : Código del riesgo
      param out mensajes : mensajes de error
      return             : 0 todo correcto
                           1 ha habido un error
   *************************************************************************/
   FUNCTION f_valida_cuest_salud(
      ppulsado IN NUMBER,
      pmodo IN VARCHAR2,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vobject        VARCHAR2(200) := 'PAC_IAX_VALIDACIONES.F_Valida_Cuest_Salud';
      vparam         VARCHAR2(200)
         := 'ppulsado:' || ppulsado || ' pmodo:' || pmodo || ' psseguro:' || psseguro
            || ' pnriesgo:' || pnriesgo;
      num_err        NUMBER;
   BEGIN
      -- Bug 9051 - 18/02/2009 - AMC - Validacion de los parametros obligatorios
      IF ppulsado IS NULL
         OR pmodo IS NULL
         OR psseguro IS NULL
         OR pnriesgo IS NULL THEN
         RAISE e_param_error;
      END IF;

      num_err := pac_md_validaciones.f_valida_cuest_salud(ppulsado, pmodo, psseguro, pnriesgo,
                                                          mensajes);

      IF num_err > 1 THEN
         RAISE e_object_error;
      END IF;

      RETURN num_err;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_valida_cuest_salud;

--Bug 9099
/*************************************************************************
       Valida las preguntas de la garantia
       param in    psproduc  : código del producto
       param in    pcactivi  : código de la actividad
       param in    pcgarant  : código de la garantía
       param in    pnmovimi  : Número de movimiento
       param in    pcpregun  : Código de la pregunta
       param in    pcrespue  : Código de la respuesta
       param in    ptrespue  : Respuesta de la pregunta
       param in    psseguro  : Código seguro
       param in    Pnriesgo  : Riesgo
       param in    Pfefecto  : Fecha de efecto
       param in    Pnmovima  : Número de movimiento de alta
       param in    Ptablas   : Tipo de las tablas
       param out mensajes : mensajes de error
       return             : 0 todo correcto
                            1 ha habido un error
*************************************************************************/
   FUNCTION f_validapregungaran(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      pnmovimi IN NUMBER,
      pcpregun IN NUMBER,
      pcrespue IN FLOAT,
      ptrespue IN VARCHAR2,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pfefecto IN DATE,
      pnmovima IN NUMBER,
      ptablas IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      errnum         NUMBER := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_IAX_VALIDACIONES.f_validapregungaran';
   BEGIN
      errnum := pac_md_validaciones.f_validapregungaran(psproduc, pcactivi, pcgarant,
                                                        pnmovimi, pcpregun, pcrespue,
                                                        ptrespue, psseguro, pnriesgo,
                                                        pfefecto, pnmovima, ptablas, mensajes);

      IF errnum <> 0 THEN
         RAISE e_object_error;
      END IF;

      RETURN errnum;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_validapregungaran;

--Fin Bug 9099

   --BUG 8613 - 160309 - ACC - Suplement Canvi d'agent
   /*************************************************************************
      Valida que el canvi d'agent estigui permés
      param in    pcagentini  : código agent inicial pòlissa
      param in    pcagentfin  : código agent a canviar pòlissa
      param in    pfecha      : data comprovació agent
      param out mensajes : mensajes de error
      return :  0 todo correcto
                1 ha habido un error
   *************************************************************************/
   FUNCTION f_validacanviagent(
      pcagentini IN NUMBER,
      pcagentfin IN NUMBER,
      pfecha IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_IAX_VALIDACIONES.f_validacanviagent';
      errnum         NUMBER := 0;
   BEGIN
      IF pcagentini IS NULL
         OR pcagentfin IS NULL THEN
         RAISE e_param_error;
      END IF;

      errnum := pac_md_validaciones.f_validacanviagent(pcagentini, pcagentfin, pfecha,
                                                       mensajes);

      IF errnum <> 0 THEN
         RAISE e_object_error;
      END IF;

      RETURN errnum;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_validacanviagent;

--Fi BUG 8613 - 160309 - ACC - Suplement Canvi d'agent

   /*************************************************************************
      Valida el perfil de inversión seleccionado
      param out mensajes : mensajes de error
      return             : 0 todo correcto
                           1 ha habido un error
   *************************************************************************/
   -- Bug 9031 - 11/03/2009 - RSC - Análisis adaptación productos indexados
   FUNCTION f_validaperfilinv(mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      poliza         ob_iax_detpoliza;
      distr          ob_iax_produlkmodelosinv;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_IAX_VALIDACIONES.F_ValidaClausulas';
      vsumpinvers    NUMBER := 0;
   BEGIN
      poliza := f_getpoliza(mensajes);
      vpasexec := 2;
      distr := poliza.modeloinv;

      IF distr IS NULL THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9001193);   --'Debe informar las clausulas del producto'
         RETURN 1;
      END IF;

      vpasexec := 3;

      IF distr.modinvfondo.COUNT = 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9001193);   --'Debe informar las clausulas del producto'
         RETURN 1;
      END IF;

      vpasexec := 4;

      FOR vcl IN distr.modinvfondo.FIRST .. distr.modinvfondo.LAST LOOP
         vpasexec := 5;

         IF distr.modinvfondo.EXISTS(vcl) THEN
            vpasexec := 6;
            vsumpinvers := vsumpinvers + NVL(distr.modinvfondo(vcl).pinvers, 0);
         END IF;
      END LOOP;

      -- Si porcentaje no suma 100 malo.
      IF vsumpinvers <> 100 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9001194);   --'Debe informar las clausulas del producto'
         RETURN 1;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_validaperfilinv;

-- Fin Bug 9031
   /*************************************************************************
   --BUG 9247-24022009-XVM
   FUNCTION f_valida_conductorinnominado
      Funció que valida un conductor.
      param in pnriesgo  : número risc
      param in pnorden   : número conductor
      param in pnedad    : edat
      param in pfcarnet  : data carnet
      param in psexo     : sexe
      param in pnpuntos  : número de punts
      param in  pexper_manual : Numero de años de experiencia del conductor.
      param in  pexper_cexper : Numero de años de experiencia que viene por interfaz.
      param out mensajes : missatges d'error
      return                : 1 -> Tot correcte
                              0 -> S'ha produit un error
   *************************************************************************/
   FUNCTION f_valida_conductorinnominado(
      pnriesgo IN NUMBER,
      pnorden IN NUMBER,
      pfnacimi IN DATE,
      pfcarnet IN DATE,
      psexo IN NUMBER,
      pnpuntos IN NUMBER,
      pexper_manual IN NUMBER,
      pexper_cexper IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      num_err        NUMBER;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := NULL;
      vobject        VARCHAR2(2000) := 'PAC_IAX_VALIDACIONES.f_valida_conductorinnominado';
   BEGIN
      vpasexec := 2;
      num_err := pac_md_validaciones_aut.f_validaconductorinnominado(pnriesgo, pnorden,
                                                                     pfnacimi, pfcarnet,
                                                                     psexo, pnpuntos,
                                                                     pexper_manual,
                                                                     pexper_cexper, mensajes);
      vpasexec := 3;

      IF num_err <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, num_err);
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_valida_conductorinnominado;

   /*************************************************************************
      Valida que el estado de los fondos de inversión asociados a una empresa
      se encuentren abiertos.

      param out mensajes : mensajes de error
      return             : 0 todo correcto
                           1 ha habido un error
   *************************************************************************/
   -- Bug 10040 - 12/05/2009 - RSC - Ajustes productos PPJ Dinámico y Pla Estudiant
   FUNCTION f_valida_producto(mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      errnum         NUMBER := 0;
      poliza         ob_iax_detpoliza;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_IAX_VALIDACIONES.f_valida_finversion';
   BEGIN
      poliza := f_getpoliza(mensajes);
      errnum := pac_md_validaciones.f_valida_finversion(poliza, mensajes);

      IF errnum > 0 THEN
         RETURN errnum;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_valida_producto;

-- Fin Bug 10040
 /*************************************************************************
      Valida el saldo deutor
      param out mensajes : mesajes de error
      return             : 0 todo ha sido correcto
                           1 ha habido un error
   *************************************************************************/
   -- Bug 10702 - 22/07/2009 - XPL - Nueva pantalla para contratación y suplementos que permita seleccionar cuentas aseguradas.
   -- Bug 11165 - 16/09/2009 - AMC - Se sustituñe  t_iax_saldodeutorseg por t_iax_prestamoseg
   FUNCTION f_valida_prestamoseg(
      pnriesgo IN NUMBER,
      pprestamo OUT t_iax_prestamoseg,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      verrnum        NUMBER := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'pnriesgo = ' || pnriesgo;
      vobject        VARCHAR2(2000) := 'PAC_IAX_VALIDACIONES.f_valida_saldosdeutors';
   BEGIN
      verrnum := pac_md_validaciones.f_valida_prestamoseg(pnriesgo, pprestamo, mensajes);

      IF verrnum <> 0 THEN
         IF mensajes IS NOT NULL THEN
            IF mensajes.COUNT > 0 THEN
               vpasexec := 4;
               RAISE e_object_error;
            END IF;
         END IF;
      END IF;

      pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, 111313);
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_valida_prestamoseg;

   /*************************************************************************
      FUNCTION f_validagarantia
      Validaciones garantias
      Param IN psseguro: sseguro
      Param IN pnriesgo: nriesgo
      Param IN pcgarant: cgarant
      return : 0 Si todo ha ido bien, si no el c?o de error
   *************************************************************************/
   --BUG 16106 - 05/11/2010 - JTS
   FUNCTION f_validagarantia(
      pnriesgo IN NUMBER,
      pcgarant IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vsseguro       NUMBER;
      vnmovimi       NUMBER;
      nerror         NUMBER;
      v_pasexec      NUMBER := 1;
      v_param        VARCHAR2(50) := 'pcgarant=' || pcgarant || ' pnriesgo=' || pnriesgo;
      v_object       VARCHAR2(200) := 'PAC_IAX_VALIDACIONES.f_validagarantia';
   BEGIN
      v_pasexec := 2;
      vsseguro := pac_iax_produccion.poliza.det_poliza.sseguro;
      vnmovimi := pac_iax_produccion.poliza.det_poliza.nmovimi;
      nerror := pac_iax_produccion.f_grabarobjetodb(mensajes);

      IF nerror <> 0 THEN
         v_pasexec := 3;
         RAISE e_object_error;
      END IF;

      v_pasexec := 4;
      nerror := pac_md_validaciones.f_validagarantia(vsseguro, vnmovimi, pnriesgo, pcgarant,
                                                     mensajes);

      IF nerror <> 0 THEN
         v_pasexec := 5;
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000005, v_pasexec, v_param);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000006, v_pasexec, v_param);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000001, v_pasexec, v_param,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_validagarantia;

   /*************************************************************************
      FUNCTION f_valida_simulacion
      Validaciones simulacion
      Param IN psseguro: sseguro
      Param IN pnmovimi: nmovimi
      Param IN ptablas: EST o REA
      return : 0 Si todo ha ido bien, si no el código de error
   *************************************************************************/
   -- Bug 18848 - APD - 27/06/2011 - se crea la funcion para validar una simulacion
   FUNCTION f_valida_simulacion(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      ptablas IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vsseguro       NUMBER;
      vnmovimi       NUMBER;
      nerror         NUMBER;
      v_pasexec      NUMBER := 1;
      v_param        VARCHAR2(50)
              := 'psseguro=' || psseguro || ' pnmovimi=' || pnmovimi || ' ptablas=' || ptablas;
      v_object       VARCHAR2(200) := 'PAC_IAX_VALIDACIONES.f_valida_simulacion';
   BEGIN
      v_pasexec := 2;
      nerror := pac_md_validaciones.f_valida_simulacion(psseguro, pnmovimi, ptablas, mensajes);

      IF nerror <> 0 THEN
         v_pasexec := 3;
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000005, v_pasexec, v_param);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000006, v_pasexec, v_param);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000001, v_pasexec, v_param,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_valida_simulacion;

   -- INICIO BUG 19276, JBN, REEMPLAZOS
   /*************************************************************************
      Función nueva que valida si una póliza puede ser reemplazada
      param in PSSEGURO    : Identificador del seguro a reemplazaar
      param in PSPRODUC    : Identificador del producto de la póliza nueva
      param out mensajes : mensajes de error
      return             : 0 la validación ha sido correcta
                           1 la validación no ha sido correcta
   *************************************************************************/
   FUNCTION f_valida_reemplazo(
      psseguro IN NUMBER,
      psproduc IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vsseguro       NUMBER;
      vnmovimi       NUMBER;
      nerror         NUMBER;
      v_pasexec      NUMBER := 1;
      v_param        VARCHAR2(50) := 'psseguro=' || psseguro || ' PSPRODUC=' || psproduc;
      v_object       VARCHAR2(200) := 'PAC_IAX_VALIDACIONES.f_valida_reemplazo';
   BEGIN
      v_pasexec := 2;
      nerror := pac_md_validaciones.f_valida_reemplazo(psseguro, psproduc, mensajes);

      IF nerror <> 0 THEN
         v_pasexec := 3;
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000005, v_pasexec, v_param);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000006, v_pasexec, v_param);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000001, v_pasexec, v_param,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_valida_reemplazo;

      --Bug.: 19152 - 26/10/2011 - ICV
    /*************************************************************************
      Función que valida benefeiciarios especiales
      param in ob_iax_benespeciales  : Identificador del seguro a reemplazaar
      param out mensajes : mensajes de error
      return             : 0 la validación ha sido correcta
                           1 la validación no ha sido correcta
   *************************************************************************/
   FUNCTION f_validar_beneident(benefesp IN ob_iax_benespeciales, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      nerror         NUMBER;
      v_pasexec      NUMBER := 1;
      v_param        VARCHAR2(50) := '';
      v_object       VARCHAR2(200) := 'PAC_IAX_VALIDACIONES.f_validar_beneident';
      v_porcbentit   NUMBER;
      v_porconting   NUMBER;
      v_porcbentitgar NUMBER;
      poliza         ob_iax_detpoliza;
      vpmin          NUMBER;
      vpmax          NUMBER;
      vbenefi        NUMBER;
      cur            sys_refcursor;
      vcgarant       NUMBER;
      vtgarant       VARCHAR2(100);
      trobat         NUMBER;

      TYPE t_tipocon IS TABLE OF NUMBER
         INDEX BY BINARY_INTEGER;

      x              NUMBER;
      v_porcbentitarray t_tipocon;
   BEGIN
      v_pasexec := 2;
      -- INI RLLF 13052014 No funciona en el cas de que hi hagi beneficiaris a nivell de garantia
      -- ja que l'objecte sinó arriva buit.
      poliza := f_getpoliza(mensajes);

      -- FIN RLLF 13052014 No funciona en el cas de que hi hagi beneficiaris a nivell de garantia
      IF benefesp.benef_riesgo IS NOT NULL THEN
         --Validamos beneficiarios a nivel de riesgo
         IF benefesp.benef_riesgo.COUNT <> 0 THEN
            FOR i IN benefesp.benef_riesgo.FIRST .. benefesp.benef_riesgo.LAST LOOP
               v_porcbentitarray(NVL(benefesp.benef_riesgo(i).ctipocon, 0)) := 0;
            END LOOP;

            FOR i IN benefesp.benef_riesgo.FIRST .. benefesp.benef_riesgo.LAST LOOP
               IF benefesp.benef_riesgo.EXISTS(i) THEN
                  --Beneficiario de contingencia
                  IF benefesp.benef_riesgo(i).ctipben = 3
                     AND NVL(benefesp.benef_riesgo(i).sperson_tit, 0) = 0 THEN
                     pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9902573);
                     RETURN 1;
                  END IF;

                  IF NVL(benefesp.benef_riesgo(i).ctipben, 0) = 0 THEN
                     pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9902574);
                     RETURN 1;
                  END IF;

                  IF benefesp.benef_riesgo(i).pparticip IS NULL THEN
                     pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9902575);
                     RETURN 1;
                  END IF;

                  --Bug 24497 - JMF - 16/01/2013.Inicio
                  IF NOT pac_iax_produccion.issimul THEN
                     DECLARE
                        v_ctipide      estper_personas.ctipide%TYPE;
                     BEGIN
                        SELECT MAX(ctipide)
                          INTO v_ctipide
                          FROM estper_personas
                         WHERE sperson = benefesp.benef_riesgo(i).sperson;

                        IF NVL(v_ctipide, -1) = 99 THEN
                           pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9001179);   -- El tipus d'identificador (id. de simulació) no és vàlid.
                           RETURN 1;
                        END IF;
                     END;
                  END IF;

                  --Bug 24497 - JMF - 16/01/2013.Fin

                  --Suma de beneficiarios titulares ha de sumar 100
                  IF NVL(benefesp.benef_riesgo(i).sperson_tit, 0) = 0 THEN
                     p_tab_error(f_sysdate, f_user, 'pac_iax_produccion.f_validar_beneident',
                                 v_pasexec, benefesp.benef_riesgo(i).pparticip, 'entro');
                     v_porcbentitarray(NVL(benefesp.benef_riesgo(i).ctipocon, 0)) :=
                        NVL(v_porcbentitarray(NVL(benefesp.benef_riesgo(i).ctipocon, 0)), 0)
                        + benefesp.benef_riesgo(i).pparticip;
                  ELSE
                     --suma de beneficiarios de contingencia ha de sumar 100
                     -- Bug 20995 - APD - 30/01/2012
                     -- para el mismo beneficiario principal
                     --v_porconting := NVL(v_porconting, 0) + benefesp.benef_riesgo(i).pparticip;
                     nerror :=
                        pac_md_validaciones.f_suma_particip_benef_conting
                                                         (1,
                                                          benefesp.benef_riesgo(i).sperson_tit,
                                                          benefesp, v_porconting, mensajes);

                     IF nerror <> 0 THEN
                        -- el mensaje ya lo devuelve la funcion en el parametro de entrada/salida mensajes
                        RETURN 1;
                     END IF;

                     IF NVL(v_porconting, 100) <> 100 THEN
                        pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9902577);
                        RETURN 1;
                     END IF;
                  -- fin Bug 20995 - APD - 30/01/2012
                  END IF;

                  -- Bug 20995 - APD - 23/01/2012
                  -- Se valida que un mismo beneficiario no esté repetido como beneficiario de riesgo
                  nerror :=
                     pac_md_validaciones.f_benef_repetido
                                                    (1,
                                                     --Ini 31204/12459 --ECP--06/05/2014
                                                     benefesp.benef_riesgo(i).cgarant,

                                                     --Fin31204/12459 --ECP--06/05/2014
                                                     benefesp.benef_riesgo(i).sperson,
                                                     benefesp.benef_riesgo(i).norden,
                                                     NVL(benefesp.benef_riesgo(i).sperson_tit,
                                                         0),
                                                     benefesp, mensajes);

                  IF nerror <> 0 THEN
                     -- el mensaje ya lo devuelve la funcion en el parametro de entrada/salida mensajes
                     RETURN 1;
                  END IF;
               -- fin Bug 20995 - APD - 23/01/2012
               END IF;
            END LOOP;

            -- Bug 24497 - MMS - 15/02/2013. Validar porcentajes de los beneficiarios segun tipo de renta
            poliza := f_getpoliza(mensajes);
            v_pasexec := 3;

            FOR i IN v_porcbentitarray.FIRST .. v_porcbentitarray.LAST LOOP
               IF NVL
                     (pac_mdpar_productos.f_get_parproducto
                                        ('VALIDA_PORCENT_BENEF',   -- No validem els percentatges
                                         poliza.sproduc),
                      0) = 1 THEN
                  NULL;
               ELSIF NVL
                       (pac_mdpar_productos.f_get_parproducto
                                             ('VALIDA_PORCENT_BENEF',   -- Validamos que sumen 100
                                              poliza.sproduc),
                        0) = 0 THEN
                  IF NVL(v_porcbentitarray(i), 100) <> 100 THEN
                     pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9902576);
                     RETURN 1;
                  END IF;
               ELSIF NVL
                       (pac_mdpar_productos.f_get_parproducto
                           ('VALIDA_PORCENT_BENEF',   -- Validamos que pueda ser inferior per no mayor
                            poliza.sproduc),
                        0) IN(2, 3) THEN
                  IF NVL(v_porcbentitarray(i), 100) > 100 THEN
                     pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9902576);
                     RETURN 1;
                  END IF;

                  IF NVL
                        (pac_mdpar_productos.f_get_parproducto
                            ('VALIDA_PORCENT_BENEF',   -- Validamos Un porcentaje igual a 0 no está permitido.
                             poliza.sproduc),
                         0) = 2 THEN
                     IF NVL(v_porcbentitarray(i), 100) = 0 THEN
                        pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9908727);
                        RETURN 1;
                     END IF;
                  END IF;
               END IF;
            END LOOP;

            v_pasexec := 4;
         -- Bug 24497 - MMS - 15/02/2013. Validar porcentajes de los beneficiarios segun tipo de renta

         -- Bug 20995 - APD - 30/01/2012
         --IF NVL(v_porconting, 100) <> 100 THEN
         --   pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9902577);
         --   RETURN 1;
         --END IF;
         -- fin Bug 20995 - APD - 30/01/2012
         END IF;

         v_porcbentit := NULL;
         v_porconting := NULL;
      END IF;

      IF benefesp.benefesp_gar IS NOT NULL THEN
         --Validamos beneficiarios a nivel de garantía
         IF benefesp.benefesp_gar.COUNT <> 0 THEN
            FOR i IN benefesp.benefesp_gar.FIRST .. benefesp.benefesp_gar.LAST LOOP
               IF benefesp.benefesp_gar.EXISTS(i) THEN
                  v_porcbentit := NULL;
                  v_porconting := NULL;

                  IF benefesp.benefesp_gar(i).benef_ident IS NULL THEN
                     pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 180261);
                     RETURN 1;
                  END IF;

                  IF benefesp.benefesp_gar(i).benef_ident.COUNT <> 0 THEN
                     -- INI RLLF Bug-32931 Validar el porcentaje de los beneficiarios a nivel de garantia
                     v_porcbentitgar := 0;

                     -- FIN RLLF Bug-32931 Validar el porcentaje de los beneficiarios a nivel de garantia
                     FOR j IN
                        benefesp.benefesp_gar(i).benef_ident.FIRST .. benefesp.benefesp_gar(i).benef_ident.LAST LOOP
                        IF benefesp.benefesp_gar(i).benef_ident.EXISTS(j) THEN
                           --Beneficiario de contingencia
                           IF NVL(benefesp.benefesp_gar(i).benef_ident(j).ctipben, 0) = 3
                              AND benefesp.benefesp_gar(i).benef_ident(j).sperson_tit = 0 THEN
                              pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9902573);
                              RETURN 1;
                           END IF;

                           IF NVL(benefesp.benefesp_gar(i).benef_ident(j).ctipben, 0) = 0 THEN
                              pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9902574);
                              RETURN 1;
                           END IF;

                           IF benefesp.benefesp_gar(i).benef_ident(j).pparticip IS NULL THEN
                              pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9902575);
                              RETURN 1;
                           END IF;

                           --Bug 24497 - JMF - 16/01/2013.Inicio
                           IF NOT pac_iax_produccion.issimul THEN
                              DECLARE
                                 v_ctipide      estper_personas.ctipide%TYPE;
                              BEGIN
                                 SELECT MAX(ctipide)
                                   INTO v_ctipide
                                   FROM estper_personas
                                  WHERE sperson =
                                                benefesp.benefesp_gar(i).benef_ident(j).sperson;

                                 IF NVL(v_ctipide, -1) = 99 THEN
                                    pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9001179);   -- El tipus d'identificador (id. de simulació) no és vàlid.
                                    RETURN 1;
                                 END IF;
                              END;
                           END IF;

                           --Bug 24497 - JMF - 16/01/2013.Fin

                           --Suma de beneficiarios titulares ha de sumar 100
                           IF NVL(benefesp.benefesp_gar(i).benef_ident(j).sperson_tit, 0) = 0 THEN
                              v_porcbentit := NVL(v_porcbentit, 0)
                                              + benefesp.benefesp_gar(i).benef_ident(j).pparticip;
                              -- INI RLLF Bug-32931 Validar el porcentaje de los beneficiarios a nivel de garantia
                              v_porcbentitgar :=
                                 NVL(v_porcbentitgar, 0)
                                 + benefesp.benefesp_gar(i).benef_ident(j).pparticip;
                           -- FIN RLLF Bug-32931 Validar el porcentaje de los beneficiarios a nivel de garantia
                           ELSE
                                       --suma de beneficiarios de contingencia ha de sumar 100
                              -- Bug 20995 - APD - 30/01/2012
                              -- para el mismo beneficiario principal
                              --         v_porconting := NVL(v_porconting, 0)
                              --                         + benefesp.benefesp_gar(i).benef_ident(j).pparticip;
                              nerror :=
                                 pac_md_validaciones.f_suma_particip_benef_conting
                                           (2,
                                            benefesp.benefesp_gar(i).benef_ident(j).sperson_tit,
                                            benefesp, v_porconting, mensajes);

                              IF nerror <> 0 THEN
                                 -- el mensaje ya lo devuelve la funcion en el parametro de entrada/salida mensajes
                                 RETURN 1;
                              END IF;

                              IF NVL(v_porconting, 100) <> 100 THEN
                                 pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9902577);
                                 RETURN 1;
                              END IF;
                           -- fin Bug 20995 - APD - 30/01/2012
                           END IF;

                           -- Bug 20995 - APD - 23/01/2012
                           -- Se valida que un mismo beneficiario no esté repetido como beneficiario de garantia
                           nerror :=
                              pac_md_validaciones.f_benef_repetido
                                      (2,
                                       --Ini 31204/12459 --ECP--06/05/2014
                                       benefesp.benefesp_gar(i).benef_ident(j).cgarant,

                                       --Fin 31204/12459 --ECP--06/05/2014
                                       benefesp.benefesp_gar(i).benef_ident(j).sperson,
                                       benefesp.benefesp_gar(i).benef_ident(j).norden,
                                       NVL(benefesp.benefesp_gar(i).benef_ident(j).sperson_tit,
                                           0),
                                       benefesp, mensajes);

                           IF nerror <> 0 THEN
                              -- el mensaje ya lo devuelve la funcion en el parametro de entrada/salida mensajes
                              RETURN 1;
                           END IF;
                        -- fin Bug 20995 - APD - 23/01/2012
                        END IF;
                     END LOOP;

                     -- INI RLLF Bug-32931 Validar el porcentaje de los beneficiarios a nivel de garantia no supere el 100.
                     IF NVL(pac_mdpar_productos.f_get_parproducto('VALIDA_PORCEN_BEGAR',
                                                                  poliza.sproduc),
                            0) = 1 THEN
                        IF NVL(v_porcbentit, 100) > 100 THEN
                           pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9907091);
                           RETURN 1;
                        END IF;
                     ELSE
                        IF NVL
                              (pac_mdpar_productos.f_get_parproducto('VALIDA_PORCENT_BENEF',
                                                                     poliza.sproduc),
                               0) = 0 THEN
                           IF NVL(v_porcbentit, 100) <> 100 THEN
                              pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9902576);
                              RETURN 1;
                           END IF;
                        ELSIF NVL
                                (pac_mdpar_productos.f_get_parproducto('VALIDA_PORCENT_BENEF',
                                                                       poliza.sproduc),
                                 0) = 1 THEN
                           NULL;
                        ELSIF NVL
                                (pac_mdpar_productos.f_get_parproducto('VALIDA_PORCENT_BENEF',
                                                                       poliza.sproduc),
                                 0) = 2 THEN
                           IF NVL(v_porcbentit, 100) > 100 THEN
                              pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9902576);
                              RETURN 1;
                           END IF;
                        END IF;
                     END IF;
                  -- FIN RLLF Bug-32931 Validar el porcentaje de los beneficiarios a nivel de garantia

                  -- Bug 20995 - APD - 30/01/2012
                  --IF NVL(v_porconting, 100) <> 100 THEN
                  --   pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9902577);
                  --   RETURN 1;
                  --END IF;
                  -- fin Bug 20995 - APD - 30/01/2012
                  END IF;

                  --Bug 30204/167810 - 03/03/2014 - AMC
                  vpmin :=
                     NVL(pac_parametros.f_pargaranpro_n(poliza.sproduc, poliza.gestion.cactivi,
                                                        benefesp.benefesp_gar(i).cgarant,
                                                        'NUMMINBENEGAR'),
                         -1);
                  vpmax :=
                     NVL(pac_parametros.f_pargaranpro_n(poliza.sproduc, poliza.gestion.cactivi,
                                                        benefesp.benefesp_gar(i).cgarant,
                                                        'NUMMAXBENEGAR'),
                         -1);

                  IF benefesp.benefesp_gar(i).benef_ident IS NOT NULL THEN
                     vbenefi := benefesp.benefesp_gar(i).benef_ident.COUNT;
                  ELSE
                     vbenefi := 0;
                  END IF;

                  IF vpmin <> -1 THEN
                     IF vpmin > vbenefi THEN
                        pac_iobj_mensajes.crea_nuevo_mensaje
                                    (mensajes, 1, NULL,
                                     REPLACE(f_axis_literales(9906604,
                                                              pac_md_common.f_get_cxtidioma),
                                             '#1#', vpmin));
                        RETURN 1;
                     END IF;
                  END IF;

                  IF vpmax <> -1 THEN
                     IF vpmax < vbenefi THEN
                        pac_iobj_mensajes.crea_nuevo_mensaje
                                    (mensajes, 1, NULL,
                                     REPLACE(f_axis_literales(9906605,
                                                              pac_md_common.f_get_cxtidioma),
                                             '#1#', vpmax));
                        RETURN 1;
                     END IF;
                  END IF;
               --Fi Bug 30204/167810 - 03/03/2014 - AMC
               END IF;
            END LOOP;
         END IF;
      END IF;

      --Bug 30204/167810 - 03/03/2014 - AMC
      cur := pac_md_produccion.f_get_garantias_benidgar(poliza.sseguro, mensajes);

      LOOP
         FETCH cur
          INTO vcgarant, vtgarant;

         vpmin := NVL(pac_parametros.f_pargaranpro_n(poliza.sproduc, poliza.gestion.cactivi,
                                                     vcgarant, 'NUMMINBENEGAR'),
                      -1);

         IF vpmin > 0 THEN
            trobat := 0;

            IF benefesp.benefesp_gar IS NOT NULL THEN
               IF benefesp.benefesp_gar.COUNT <> 0 THEN
                  FOR i IN benefesp.benefesp_gar.FIRST .. benefesp.benefesp_gar.LAST LOOP
                     IF benefesp.benefesp_gar.EXISTS(i) THEN
                        IF benefesp.benefesp_gar(i).cgarant = vcgarant THEN
                           trobat := 1;
                        END IF;
                     END IF;
                  END LOOP;
               END IF;
            END IF;

            IF trobat = 0 THEN
               pac_iobj_mensajes.crea_nuevo_mensaje
                                    (mensajes, 1, NULL,
                                     REPLACE(f_axis_literales(9906604,
                                                              pac_md_common.f_get_cxtidioma),
                                             '#1#', vpmin));
               RETURN 1;
            END IF;
         END IF;

         EXIT WHEN cur%NOTFOUND;
      END LOOP;

      --Fi Bug 30204/167810 - 03/03/2014 - AMC
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000005, v_pasexec, v_param);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000006, v_pasexec, v_param);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000001, v_pasexec, v_param,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_validar_beneident;

   /*************************************************************************
        Valida los datos del corretaje
        param out mensajes : mensajes de error
        return             : 0 todo correcto
                             1 ha habido un error
     *************************************************************************/
   FUNCTION f_valida_corretaje(mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      errnum         NUMBER := 0;
      poliza         ob_iax_detpoliza;
      vporcent       NUMBER;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_IAX_VALIDACIONES.F_Valida_corretaje';
      vnumlider      NUMBER := 0;
   BEGIN
      vpasexec := 1;
      poliza := f_getpoliza(mensajes);
      vpasexec := 2;
      errnum := pac_md_validaciones.f_valida_corretaje(poliza, mensajes);

      IF errnum <> 0 THEN
         vpasexec := 3;
         RAISE e_object_error;
      END IF;

      RETURN errnum;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_valida_corretaje;

--ini Bug: 19303 - JMC - 16/11/2011 - Automatización del seguro saldado y prorrogado
   /*************************************************************************
      Valida que una póliza pueda ser saldada o prorrogada.
      param out mensajes : mensajes de error
      return             : 0 todo correcto
                           <> 0 ha habido un error
   *************************************************************************/
   FUNCTION f_valida_sp(psseguro IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      errnum         NUMBER := 0;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_MD_VALIDACIONES.F_Valida_sp';
      vpasexec       NUMBER(8) := 1;
   BEGIN
      errnum := pac_md_validaciones.f_valida_sp(psseguro, mensajes);
      RETURN errnum;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_valida_sp;

--fin Bug: 19303 - JMC - 16/11/2011
-- BUG 21657--ETM --04/06/2012
   FUNCTION f_valida_inquiaval(mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      errnum         NUMBER := 0;
      vobject        VARCHAR2(200) := 'PAC_IAX_VALIDACIONES.f_valida_inquiaval';
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1000);
      poliza         ob_iax_detpoliza;
      vinquival      t_iax_inquiaval;
      vinq           ob_iax_inquiaval;
      vinqui         NUMBER := 0;
   BEGIN
      --errnum := pac_md_validaciones.f_valida_inquiaval(psseguro , psperson ,pnriesgo ,pnmovimi ,pctipfig ,pcdomici , piigrmen ,piingranual ,pffecini,pctipcontrato ,pcsitlaboral,pcsupfiltro , mensajes);
      poliza := f_getpoliza(mensajes);
      vpasexec := 2;
      vinquival := pac_iobj_prod.f_partpolinquiaval(poliza, mensajes);
      vpasexec := 3;

      IF vinquival IS NULL THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9903826);   --'No se ha introducido ningún inquilino
         RETURN 1;
      ELSE
         IF vinquival.COUNT = 0 THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9903826);   --'No se ha introducido ningún inquilino
            RETURN 1;
         END IF;
      END IF;

      vpasexec := 4;

      FOR vp IN vinquival.FIRST .. vinquival.LAST LOOP
         IF vinquival(vp).ctipfig = 1 THEN
            vinqui := 1;
         END IF;
      END LOOP;

      vpasexec := 5;

      FOR vp IN vinquival.FIRST .. vinquival.LAST LOOP
         IF vinquival(vp).ctipfig = 1 THEN
            FOR va IN vinquival.FIRST .. vinquival.LAST LOOP
               IF vinquival(va).ctipfig = 2 THEN
                  IF vinquival(vp).sperson = vinquival(va).sperson THEN
                     pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9903834);   --Los inquilinos no pueden ser avalistas
                     RETURN 1;
                  END IF;
               END IF;
            END LOOP;
         END IF;
      END LOOP;

      IF vinqui = 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9903828);   --Se tiene que introducir un inquilino
         RETURN 1;
      END IF;

      vpasexec := 6;

      FOR vp IN vinquival.FIRST .. vinquival.LAST LOOP
         IF vinquival.EXISTS(vp) THEN
            vinq := vinquival(vp);

            IF vinq.csitlaboral = 2 THEN
               IF vinq.ctipcontrato IS NULL THEN
                  pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9903827);   --Se tiene que informar el tipo de contrato
                  RETURN 1;
               END IF;
            END IF;
         END IF;
      END LOOP;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_valida_inquiaval;

--FIN  BUG 21657--ETM --04/06/2012

   /*************************************************************************
      Valida los datos del retorno
      param out mensajes : mensajes de error
      return             : 0 todo correcto
                           1 ha habido un error
   *************************************************************************/
   -- Bug 0022701 - 03/09/2012 - JMF
   FUNCTION f_valida_retorno(mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      errnum         NUMBER := 0;
      poliza         ob_iax_detpoliza;
      vporcent       NUMBER;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_IAX_VALIDACIONES.F_Valida_Retorno';
      v_cresp4817    estpregunpolseg.crespue%TYPE;
      t_tomadores    t_iax_tomadores;
      o_tom          ob_iax_tomadores;
      v_pertoma      tomadores.sperson%TYPE;
      b_faltatoma    BOOLEAN;
      n_total        NUMBER;
      -- Bug 0025942 - 06/03/2013 - JMF
      v_cestper      estper_personas.cestper%TYPE;
   BEGIN
      poliza := f_getpoliza(mensajes);
      errnum := pac_preguntas.f_get_pregunpolseg(poliza.sseguro, 4817, 'EST', v_cresp4817);
      errnum := 0;

      IF poliza.retorno IS NOT NULL THEN
         IF poliza.retorno.COUNT > 0 THEN
            n_total := 0;

            FOR cret IN poliza.retorno.FIRST .. poliza.retorno.LAST LOOP
               IF poliza.retorno(cret).pretorno <= 0
                  OR poliza.retorno(cret).pretorno >= 100 THEN   --MLR 08/02/2013 0025942: LCOL: Ajuste de q-trackers retorno
                  -- El porcentage debe estar comprendido entre 0 y 100
                  pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9904942);
                  errnum := 1;
               END IF;

               n_total := n_total + poliza.retorno(cret).pretorno;

               -- ini Bug 0025942 - 06/03/2013 - JMF
               SELECT MAX(NVL(cestper, 0))
                 INTO v_cestper
                 FROM estper_personas
                WHERE sperson = poliza.retorno(cret).sperson;

               IF v_cestper = 2 THEN
                  -- Persona fallecida
                  pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 101253,
                                                       f_axis_literales(101253) || ' '
                                                       || poliza.retorno(cret).tapelli1 || ' '
                                                       || poliza.retorno(cret).tapelli2 || ' '
                                                       || poliza.retorno(cret).tnombre);
                  errnum := 1;
               END IF;
            -- fin Bug 0025942 - 06/03/2013 - JMF
            END LOOP;

            IF n_total >= 100 THEN
               -- La suma de porcentajes no puede ser superior al 100
               pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9904941);
               errnum := 1;
            END IF;
         /***********************************************************
         -- anulat 19-09-12
         -- busca el tomador
         b_faltatoma := TRUE;
         t_tomadores := pac_iobj_prod.f_partpoltomadores(poliza, mensajes);

         FOR vp IN t_tomadores.FIRST .. t_tomadores.LAST LOOP
            IF t_tomadores.EXISTS(vp) THEN
               o_tom := t_tomadores(vp);
               v_pertoma := o_tom.sperson;

               FOR cret IN poliza.retorno.FIRST .. poliza.retorno.LAST LOOP
                  IF poliza.retorno(cret).sperson = v_pertoma THEN
                     b_faltatoma := FALSE;
                  END IF;
               END LOOP;
            END IF;
         END LOOP;

         IF b_faltatoma THEN
            -- NO EXISTE EL TOMADOR DE LA POLIZA
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 100524);
            errnum := 1;
         END IF;
         ***********************************************************/
         ELSE
            IF v_cresp4817 = 1 THEN
               -- SI SE HA CONTESTADO LA PREGUNTA Hay Retorno
               pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 120082);
               errnum := 1;
            END IF;
         END IF;
      ELSE
         IF v_cresp4817 = 1 THEN
            -- SI SE HA CONTESTADO LA PREGUNTA Hay Retorno
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 120082);
            errnum := 1;
         END IF;
      END IF;

      RETURN errnum;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           SQLCODE, SQLERRM);
         RETURN 1;
   END f_valida_retorno;

     /*************************************************************************
      Valida datos conductores
      param out mensajes : mensajes de error
      return             : 0 todo correcto
                           1 ha habido un error
      Bug 25378/138739 - 27/02/2013 - AMC
   *************************************************************************/
   FUNCTION f_validaconductores(mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      conductores    t_iax_autconductores;
      conduc         ob_iax_autconductores;
      errnum         NUMBER := 0;
      poliza         ob_iax_detpoliza;
      riesgos        t_iax_riesgos;
      riesgo         ob_iax_riesgos;
      autos          ob_iax_autriesgos;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_IAX_VALIDACIONES.f_validaconductores';
      vtexto         VARCHAR2(400);
   BEGIN
      -- Recuperamos la póliza
      poliza := f_getpoliza(mensajes);
      vpasexec := 2;
      -- Recuperamos los riesgos
      riesgos := pac_iobj_prod.f_partpolriesgos(poliza, mensajes);

      IF riesgos IS NOT NULL THEN
         IF riesgos.COUNT > 0 THEN
            FOR ris IN riesgos.FIRST .. riesgos.LAST LOOP
               IF riesgos.EXISTS(ris) THEN
                  riesgo := riesgos(ris);
                  -- Recuperamos autos
                  autos := pac_iobj_prod.f_partriesautomoviles(riesgo, mensajes);

                  IF autos IS NOT NULL THEN
                     -- Recuperamos conductores
                     conductores := pac_iobj_prod.f_partautconductores(autos, mensajes);

                     IF conductores IS NOT NULL THEN
                        IF conductores.COUNT > 0 THEN
                           FOR con IN conductores.FIRST .. conductores.LAST LOOP
                              IF conductores.EXISTS(con) THEN
                                 conduc := conductores(con);

                                 IF conduc.persona.direcciones IS NOT NULL THEN
                                    IF conduc.persona.direcciones.COUNT > 0 THEN
                                       FOR vdi IN
                                          conduc.persona.direcciones.FIRST .. conduc.persona.direcciones.LAST LOOP
                                          IF conduc.persona.direcciones.EXISTS(vdi) THEN
                                             -- Validamos que la dirección no sea de simulación
                                             IF conduc.cdomici =
                                                       conduc.persona.direcciones(vdi).cdomici
                                                AND conduc.persona.direcciones(vdi).ctipdir =
                                                                                             99 THEN
                                                vtexto :=
                                                   pac_iobj_mensajes.f_get_descmensaje
                                                                                      (9905014);
                                                pac_iobj_mensajes.crea_nuevo_mensaje
                                                                    (mensajes, 1, NULL,
                                                                     vtexto || ' '
                                                                     || conduc.persona.tnombre
                                                                     || ' '
                                                                     || conduc.persona.tapelli1);
                                                RETURN 1;
                                             END IF;
                                          END IF;
                                       END LOOP;
                                    END IF;
                                 END IF;
                              END IF;
                           END LOOP;
                        END IF;
                     END IF;
                  END IF;
               END IF;
            END LOOP;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_validaconductores;

   FUNCTION f_validaasegurados_nomodifcar(psperson IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      errnum         NUMBER := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(100) := 'psperson:' || psperson;
      vobject        VARCHAR2(200) := 'PAC_IAX_VALIDACIONES.f_validaasegurados_nomodifcar';
      v_nerror       NUMBER;
      vfefecto       DATE;
      vcont          NUMBER;
      poliza         ob_iax_detpoliza;   -- Bug 28455/0159543 - JSV - 25/11/2013
   BEGIN
      -- Bug 28455/0159543 - JSV - 25/11/2013
      poliza := f_getpoliza(mensajes);
      v_nerror := pac_md_validaciones.f_validaasegurados_nomodifcar(psperson, poliza.sseguro,
                                                                    poliza.ssegpol, mensajes);
      vpasexec := 5;
      RETURN v_nerror;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_validaasegurados_nomodifcar;

   /*************************************************************************
      f_valida_campo: valida si el valor de un campo en concreto contiene algún carácter no permitido
      param in pcempres    : Código empresa
      param in pcidcampo    : Campo a validar
      param in pcampo    : Texto introducido a validar
      return             : 0 validación correcta
                           <>0 validación incorrecta
   *************************************************************************/
   FUNCTION f_valida_campo(
      pcempres IN NUMBER,
      pcidcampo IN VARCHAR2,
      pcampo IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobject        VARCHAR2(500) := 'pac_iax_validaciones.f_valida_campo';
      vparam         VARCHAR2(500)
         := 'parámetros - pcempres: ' || pcempres || ' pcidcampo: ' || pcidcampo
            || ' pcampo: ' || pcampo;
      vpasexec       NUMBER(5) := 1;
      v_error        NUMBER := 1;
   BEGIN
      v_error := pac_md_validaciones.f_valida_campo(pcempres, pcidcampo, pcampo, mensajes);
      RETURN v_error;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1000455;   --Error no controlado.
   END f_valida_campo;

   -- Inicio Bug 27305 20140121 MMS
    /*************************************************************************
       f_valida_esclausulacertif0: Valida si una clausula pertenece al certificado 0 en un hijo y,
          por lo tanto, no se puede ni borrar ni modificar.
       param in pcempres    : Código empresa
       param in pcidcampo    : Campo a validar
       param in pcampo    : Texto introducido a validar
       return             : 0 validación correcta
                            <>0 validación incorrecta
    *************************************************************************/
   FUNCTION f_valida_esclausulacertif0(
      pnordcla IN NUMBER,
      ptclaesp IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      nerr           NUMBER;
      vpasexec       NUMBER(8) := 1;
      poliza         ob_iax_detpoliza;
      vparam         VARCHAR2(500)
         := 'parámetros - pnordcla: ' || pnordcla || ' ptclaesp: ' || SUBSTR(ptclaesp, 1, 200);
      vobject        VARCHAR2(200) := 'PAC_IAX_VALIDACIONES.F_VALIDA_ESCLAUSULACERTIF0';
   BEGIN
      poliza := f_getpoliza(mensajes);
      nerr := pac_md_validaciones.f_valida_esclausulacertif0(poliza.sseguro,
                                                             pac_iax_produccion.vpmode,
                                                             pnordcla, ptclaesp, mensajes);

      IF nerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_valida_esclausulacertif0;

-- Fin Bug 27305

   -- Bug 31208/176812 - AMC - 06/06/2014
   FUNCTION f_validamodi_plan(pnriesgo IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      errnum         NUMBER := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(100) := 'pnriesgo:' || pnriesgo;
      vobject        VARCHAR2(200) := 'PAC_IAX_VALIDACIONES.f_validamodi_plan';
      v_nerror       NUMBER;
      poliza         ob_iax_detpoliza;
   BEGIN
      poliza := f_getpoliza(mensajes);
      v_nerror :=
         pac_md_validaciones.f_validamodi_plan
                                        (poliza.sseguro, pnriesgo, poliza.nmovimi,   -- Bug 31686/179633 - 16/07/2014 - AMC
                                         mensajes);
      vpasexec := 5;
      RETURN v_nerror;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_validamodi_plan;

-- BUG 0033510 - FAL - 19/11/2014
   /*************************************************************************
      Valida exista al menos un titular y éste tenga todas las garantías contratadas por los dependientes
      param out mensajes : mensajes de error
      return :  0 todo correcto
                <>0 validación incorrecta
   *************************************************************************/
   FUNCTION f_validar_titular_salud(mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      errnum         NUMBER := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(100) := NULL;
      vobject        VARCHAR2(200) := 'PAC_IAX_VALIDACIONES.f_validar_titular_salud';
      v_nerror       NUMBER;
      poliza         ob_iax_detpoliza;
   BEGIN
      poliza := f_getpoliza(mensajes);
      v_nerror := pac_md_validaciones.f_validar_titular_salud(poliza.sseguro, poliza.nmovimi,
                                                              mensajes);
      vpasexec := 5;
      RETURN v_nerror;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_validar_titular_salud;
-- FI BUG 0033510 - FAL - 19/11/2014

-- inicio IAXIS-4207 - ACL - 04/06/2019 guilherme
/*************************************************************************
    FUNCTION F_AGENTE_BLOCK
    Funcion que retorna 1 si el agente esta bloqueado por persona, 2 si esta bloqueado por codigo o 0 si esta bien

    param IN pcagente  : codigo del agente
    return             : number
   *************************************************************************/ 
FUNCTION F_AGENTE_BLOCK(pcagente IN NUMBER, mensajes OUT t_iax_mensajes) 
    RETURN NUMBER IS
      v_permisso    number;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_IAX_VALIDACIONES.F_AGENTE_BLOCK';
   BEGIN
      v_permisso := PAC_ISQLFOR_CONF.F_AGENTE_BLOCK(pcagente);
      
      IF v_permisso = 1 then  
        pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, 9903249);
    ELSIF v_permisso = 2 THEN
        pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, 9903016);
    END IF;
      
      
      
      RETURN v_permisso;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END F_AGENTE_BLOCK;
   -- Fin IAXIS-4207 - ACL - 04/06/2019 guilherme 
END pac_iax_validaciones;

/
